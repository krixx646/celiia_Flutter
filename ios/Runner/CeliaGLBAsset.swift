import Foundation
import SceneKit
import UIKit

/// Minimal glTF 2.0 / GLB reader for Celia's bundled avatar.
///
/// Supports triangle meshes, base-color textures, and morph targets
/// (enough for VRoid face lip-sync). Skips skins/animations — the mesh is
/// already in bind pose, which is what we want for a standing bust.
final class CeliaGLBAsset {
  private let json: [String: Any]
  private let bin: Data

  /// Morph target names as declared by the model, when it declares them.
  private(set) var morphTargetNames: [String] = []

  /// Assembled byte by byte: a 4-byte chunk header sits at an arbitrary offset,
  /// and `load(as:)` traps on unaligned access.
  private static func uint32LE(_ data: Data, at offset: Int) -> UInt32 {
    let bytes = [UInt8](data.subdata(in: offset..<(offset + 4)))
    return UInt32(bytes[0])
      | UInt32(bytes[1]) << 8
      | UInt32(bytes[2]) << 16
      | UInt32(bytes[3]) << 24
  }

  init(data: Data) throws {
    guard data.count >= 12 else {
      throw CeliaGLBError.invalidFile("GLB too short")
    }
    let magic = data.subdata(in: 0..<4)
    guard magic == Data([0x67, 0x6C, 0x54, 0x46]) else { // glTF
      throw CeliaGLBError.invalidFile("Not a GLB file")
    }

    var offset = 12
    var jsonObject: [String: Any]?
    var binChunk = Data()

    while offset + 8 <= data.count {
      let chunkLength = Int(CeliaGLBAsset.uint32LE(data, at: offset))
      let chunkType = data.subdata(in: (offset + 4)..<(offset + 8))
      offset += 8
      guard offset + chunkLength <= data.count else {
        throw CeliaGLBError.invalidFile("Chunk overruns file")
      }
      let chunk = data.subdata(in: offset..<(offset + chunkLength))
      offset += chunkLength

      if chunkType == Data([0x4A, 0x53, 0x4F, 0x4E]) { // JSON
        jsonObject = try JSONSerialization.jsonObject(with: chunk) as? [String: Any]
      } else if chunkType == Data([0x42, 0x49, 0x4E, 0x00]) { // BIN
        binChunk = chunk
      }
    }

    guard let json = jsonObject else {
      throw CeliaGLBError.invalidFile("Missing JSON chunk")
    }
    self.json = json
    self.bin = binChunk
  }

  func makeSceneRoot(preferredMorphNames: [String]) throws -> SCNNode {
    let root = SCNNode()
    root.name = "celia_root"

    let meshes = json["meshes"] as? [[String: Any]] ?? []
    let materials = json["materials"] as? [[String: Any]] ?? []
    let nodes = json["nodes"] as? [[String: Any]] ?? []
    let scenes = json["scenes"] as? [[String: Any]] ?? []
    let sceneIndex = json["scene"] as? Int ?? 0
    let sceneNodes = (scenes.indices.contains(sceneIndex)
      ? scenes[sceneIndex]["nodes"] as? [Int]
      : nil) ?? Array(nodes.indices)

    for nodeIndex in sceneNodes {
      try addNode(
        index: nodeIndex,
        parent: root,
        nodes: nodes,
        meshes: meshes,
        materials: materials,
        preferredMorphNames: preferredMorphNames
      )
    }
    return root
  }

  private func addNode(
    index: Int,
    parent: SCNNode,
    nodes: [[String: Any]],
    meshes: [[String: Any]],
    materials: [[String: Any]],
    preferredMorphNames: [String]
  ) throws {
    guard nodes.indices.contains(index) else { return }
    let nodeDef = nodes[index]
    let node = SCNNode()
    node.name = nodeDef["name"] as? String

    if let matrix = nodeDef["matrix"] as? [Double], matrix.count == 16 {
      node.transform = SCNMatrix4(
        m11: Float(matrix[0]), m12: Float(matrix[1]), m13: Float(matrix[2]),
        m14: Float(matrix[3]),
        m21: Float(matrix[4]), m22: Float(matrix[5]), m23: Float(matrix[6]),
        m24: Float(matrix[7]),
        m31: Float(matrix[8]), m32: Float(matrix[9]), m33: Float(matrix[10]),
        m34: Float(matrix[11]),
        m41: Float(matrix[12]), m42: Float(matrix[13]), m43: Float(matrix[14]),
        m44: Float(matrix[15])
      )
    } else {
      if let t = nodeDef["translation"] as? [Double], t.count == 3 {
        node.position = SCNVector3(Float(t[0]), Float(t[1]), Float(t[2]))
      }
      if let s = nodeDef["scale"] as? [Double], s.count == 3 {
        node.scale = SCNVector3(Float(s[0]), Float(s[1]), Float(s[2]))
      }
      if let r = nodeDef["rotation"] as? [Double], r.count == 4 {
        node.orientation = SCNVector4(
          Float(r[0]), Float(r[1]), Float(r[2]), Float(r[3])
        )
      }
    }

    if let meshIndex = nodeDef["mesh"] as? Int, meshes.indices.contains(meshIndex) {
      let meshDef = meshes[meshIndex]
      let primitives = meshDef["primitives"] as? [[String: Any]] ?? []
      let targetNames =
        (meshDef["extras"] as? [String: Any])?["targetNames"] as? [String]
        ?? preferredMorphNames

      for (primIndex, primitive) in primitives.enumerated() {
        let child = try makePrimitiveNode(
          primitive: primitive,
          materials: materials,
          targetNames: targetNames,
          name: "\(node.name ?? "mesh")_\(primIndex)"
        )
        node.addChildNode(child)
      }
    }

    parent.addChildNode(node)

    if let children = nodeDef["children"] as? [Int] {
      for childIndex in children {
        try addNode(
          index: childIndex,
          parent: node,
          nodes: nodes,
          meshes: meshes,
          materials: materials,
          preferredMorphNames: preferredMorphNames
        )
      }
    }
  }

  private func makePrimitiveNode(
    primitive: [String: Any],
    materials: [[String: Any]],
    targetNames: [String],
    name: String
  ) throws -> SCNNode {
    let attributes = primitive["attributes"] as? [String: Any] ?? [:]
    guard let positionAccessor = attributes["POSITION"] as? Int else {
      throw CeliaGLBError.invalidFile("Primitive missing POSITION")
    }

    let positions = try float3Array(accessorIndex: positionAccessor)
    let normals: [SIMD3<Float>]
    if let normalAccessor = attributes["NORMAL"] as? Int {
      normals = try float3Array(accessorIndex: normalAccessor)
    } else {
      normals = Array(repeating: SIMD3<Float>(0, 1, 0), count: positions.count)
    }

    var uvs: [SIMD2<Float>] = []
    if let uvAccessor = attributes["TEXCOORD_0"] as? Int {
      uvs = try float2Array(accessorIndex: uvAccessor)
    }
    // SceneKit requires every source to describe the same vertices; a partial
    // UV set would render garbage, so drop it rather than mismatch.
    if uvs.count != positions.count {
      uvs = []
    }

    let indices: [UInt32]
    if let indicesAccessor = primitive["indices"] as? Int {
      indices = try indexArray(accessorIndex: indicesAccessor)
    } else {
      indices = (0..<UInt32(positions.count)).map { $0 }
    }

    // The UV source and index element are identical for the base mesh and all
    // of its morph targets, so build them once and share the objects. With 57
    // VRoid blendshapes per face primitive, rebuilding them per target costs
    // tens of megabytes and a visible hitch when the chat screen opens.
    let normalSource = vectorSource(normals, semantic: .normal)
    let uvSource = uvs.isEmpty ? nil : texcoordSource(uvs)
    let element = indexElement(indices)

    let baseGeometry = geometry(
      positionSource: vectorSource(positions, semantic: .vertex),
      normalSource: normalSource,
      uvSource: uvSource,
      element: element
    )

    if let materialIndex = primitive["material"] as? Int,
      materials.indices.contains(materialIndex)
    {
      baseGeometry.materials = [try makeMaterial(materials[materialIndex])]
    } else {
      let mat = SCNMaterial()
      mat.lightingModel = .constant
      mat.diffuse.contents = UIColor.white
      baseGeometry.materials = [mat]
    }

    let node = SCNNode(geometry: baseGeometry)
    node.name = name

    let targets = primitive["targets"] as? [[String: Any]] ?? []
    if !targets.isEmpty {
      var morphGeometries: [SCNGeometry] = []
      for target in targets {
        guard let posIndex = target["POSITION"] as? Int else { continue }
        let deltas = try float3Array(accessorIndex: posIndex)
        var morphed = positions
        for i in 0..<min(morphed.count, deltas.count) {
          morphed[i] += deltas[i]
        }

        var targetNormals = normalSource
        if let nIndex = target["NORMAL"] as? Int {
          let nDeltas = try float3Array(accessorIndex: nIndex)
          var morphedNormals = normals
          for i in 0..<min(morphedNormals.count, nDeltas.count) {
            morphedNormals[i] += nDeltas[i]
          }
          targetNormals = vectorSource(morphedNormals, semantic: .normal)
        }

        morphGeometries.append(
          geometry(
            positionSource: vectorSource(morphed, semantic: .vertex),
            normalSource: targetNormals,
            uvSource: uvSource,
            element: element
          )
        )
      }

      if !morphGeometries.isEmpty {
        let morpher = SCNMorpher()
        morpher.targets = morphGeometries
        node.morpher = morpher
        if morphTargetNames.isEmpty, targetNames.count >= morphGeometries.count {
          morphTargetNames = Array(targetNames.prefix(morphGeometries.count))
        }
      }
    }

    return node
  }

  private func geometry(
    positionSource: SCNGeometrySource,
    normalSource: SCNGeometrySource,
    uvSource: SCNGeometrySource?,
    element: SCNGeometryElement
  ) -> SCNGeometry {
    var sources = [positionSource, normalSource]
    if let uvSource {
      sources.append(uvSource)
    }
    return SCNGeometry(sources: sources, elements: [element])
  }

  private func vectorSource(
    _ values: [SIMD3<Float>],
    semantic: SCNGeometrySource.Semantic
  ) -> SCNGeometrySource {
    var data = Data(count: values.count * MemoryLayout<SCNVector3>.stride)
    data.withUnsafeMutableBytes { raw in
      let ptr = raw.bindMemory(to: SCNVector3.self)
      for i in values.indices {
        ptr[i] = SCNVector3(values[i].x, values[i].y, values[i].z)
      }
    }
    return SCNGeometrySource(
      data: data,
      semantic: semantic,
      vectorCount: values.count,
      usesFloatComponents: true,
      componentsPerVector: 3,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: 0,
      dataStride: MemoryLayout<SCNVector3>.stride
    )
  }

  private func texcoordSource(_ uvs: [SIMD2<Float>]) -> SCNGeometrySource {
    var data = Data(count: uvs.count * MemoryLayout<SIMD2<Float>>.stride)
    data.withUnsafeMutableBytes { raw in
      let ptr = raw.bindMemory(to: SIMD2<Float>.self)
      for i in uvs.indices {
        // glTF UVs are top-left origin; SceneKit expects bottom-left.
        ptr[i] = SIMD2<Float>(uvs[i].x, 1.0 - uvs[i].y)
      }
    }
    return SCNGeometrySource(
      data: data,
      semantic: .texcoord,
      vectorCount: uvs.count,
      usesFloatComponents: true,
      componentsPerVector: 2,
      bytesPerComponent: MemoryLayout<Float>.size,
      dataOffset: 0,
      dataStride: MemoryLayout<SIMD2<Float>>.stride
    )
  }

  private func indexElement(_ indices: [UInt32]) -> SCNGeometryElement {
    var data = Data(count: indices.count * MemoryLayout<UInt32>.size)
    data.withUnsafeMutableBytes { raw in
      let ptr = raw.bindMemory(to: UInt32.self)
      for i in indices.indices {
        ptr[i] = indices[i]
      }
    }
    return SCNGeometryElement(
      data: data,
      primitiveType: .triangles,
      primitiveCount: indices.count / 3,
      bytesPerIndex: MemoryLayout<UInt32>.size
    )
  }

  private func makeMaterial(_ def: [String: Any]) throws -> SCNMaterial {
    let mat = SCNMaterial()
    // Celia's GLB uses KHR_materials_unlit — constant lighting matches Filament.
    mat.lightingModel = .constant
    mat.isDoubleSided = def["doubleSided"] as? Bool ?? false

    let pbr = def["pbrMetallicRoughness"] as? [String: Any]
    if let baseColorFactor = pbr?["baseColorFactor"] as? [Double], baseColorFactor.count >= 3 {
      mat.diffuse.contents = UIColor(
        red: CGFloat(baseColorFactor[0]),
        green: CGFloat(baseColorFactor[1]),
        blue: CGFloat(baseColorFactor[2]),
        alpha: CGFloat(baseColorFactor.count > 3 ? baseColorFactor[3] : 1)
      )
    }
    if let texInfo = pbr?["baseColorTexture"] as? [String: Any],
      let texIndex = texInfo["index"] as? Int,
      let image = try loadTextureImage(textureIndex: texIndex)
    {
      mat.diffuse.contents = image
    }

    let alphaMode = def["alphaMode"] as? String ?? "OPAQUE"
    if alphaMode == "BLEND" {
      mat.transparencyMode = .aOne
      mat.writesToDepthBuffer = false
    } else if alphaMode == "MASK" {
      mat.transparencyMode = .aOne
    }
    return mat
  }

  private func loadTextureImage(textureIndex: Int) throws -> UIImage? {
    let textures = json["textures"] as? [[String: Any]] ?? []
    let images = json["images"] as? [[String: Any]] ?? []
    guard textures.indices.contains(textureIndex) else { return nil }
    guard let source = textures[textureIndex]["source"] as? Int,
      images.indices.contains(source)
    else { return nil }
    let imageDef = images[source]
    guard let bufferViewIndex = imageDef["bufferView"] as? Int else { return nil }
    let bytes = try bufferViewData(bufferViewIndex: bufferViewIndex)
    return UIImage(data: bytes)
  }

  private func float3Array(accessorIndex: Int) throws -> [SIMD3<Float>] {
    let (data, count, _) = try accessorBytes(accessorIndex: accessorIndex)
    var values: [SIMD3<Float>] = []
    values.reserveCapacity(count)
    data.withUnsafeBytes { raw in
      let floats = raw.bindMemory(to: Float.self)
      for i in 0..<count {
        let base = i * 3
        values.append(SIMD3(floats[base], floats[base + 1], floats[base + 2]))
      }
    }
    return values
  }

  private func float2Array(accessorIndex: Int) throws -> [SIMD2<Float>] {
    let (data, count, _) = try accessorBytes(accessorIndex: accessorIndex)
    var values: [SIMD2<Float>] = []
    values.reserveCapacity(count)
    data.withUnsafeBytes { raw in
      let floats = raw.bindMemory(to: Float.self)
      for i in 0..<count {
        let base = i * 2
        values.append(SIMD2(floats[base], floats[base + 1]))
      }
    }
    return values
  }

  private func indexArray(accessorIndex: Int) throws -> [UInt32] {
    let accessors = json["accessors"] as? [[String: Any]] ?? []
    guard accessors.indices.contains(accessorIndex) else {
      throw CeliaGLBError.invalidFile("Bad accessor \(accessorIndex)")
    }
    let accessor = accessors[accessorIndex]
    let count = accessor["count"] as? Int ?? 0
    let componentType = accessor["componentType"] as? Int ?? 5123
    let (data, _, _) = try accessorBytes(accessorIndex: accessorIndex)
    var indices: [UInt32] = []
    indices.reserveCapacity(count)
    data.withUnsafeBytes { raw in
      switch componentType {
      case 5121: // UNSIGNED_BYTE
        let ptr = raw.bindMemory(to: UInt8.self)
        for i in 0..<count { indices.append(UInt32(ptr[i])) }
      case 5123: // UNSIGNED_SHORT
        let ptr = raw.bindMemory(to: UInt16.self)
        for i in 0..<count { indices.append(UInt32(ptr[i].littleEndian)) }
      case 5125: // UNSIGNED_INT
        let ptr = raw.bindMemory(to: UInt32.self)
        for i in 0..<count { indices.append(ptr[i].littleEndian) }
      default:
        break
      }
    }
    return indices
  }

  private func accessorBytes(accessorIndex: Int) throws -> (Data, Int, Int) {
    let accessors = json["accessors"] as? [[String: Any]] ?? []
    guard accessors.indices.contains(accessorIndex) else {
      throw CeliaGLBError.invalidFile("Bad accessor \(accessorIndex)")
    }
    let accessor = accessors[accessorIndex]
    let count = accessor["count"] as? Int ?? 0
    let componentType = accessor["componentType"] as? Int ?? 5126
    let type = accessor["type"] as? String ?? "SCALAR"
    let comps = componentsPerElement(type)
    let bytesPerComponent = bytesForComponentType(componentType)
    let byteOffset = accessor["byteOffset"] as? Int ?? 0
    guard let bufferViewIndex = accessor["bufferView"] as? Int else {
      throw CeliaGLBError.invalidFile("Accessor missing bufferView")
    }
    // This reader assumes tightly packed accessors. Fail loudly on interleaved
    // data rather than reading neighbouring attributes as vertex positions.
    let tightStride = comps * bytesPerComponent
    if let stride = bufferViewStride(bufferViewIndex: bufferViewIndex),
      stride != tightStride
    {
      throw CeliaGLBError.invalidFile(
        "Interleaved bufferView \(bufferViewIndex) is not supported"
      )
    }

    let viewData = try bufferViewData(bufferViewIndex: bufferViewIndex)
    let length = count * comps * bytesPerComponent
    let slice = viewData.subdata(in: byteOffset..<(byteOffset + length))
    return (slice, count, comps)
  }

  private func bufferViewStride(bufferViewIndex: Int) -> Int? {
    let views = json["bufferViews"] as? [[String: Any]] ?? []
    guard views.indices.contains(bufferViewIndex) else { return nil }
    return views[bufferViewIndex]["byteStride"] as? Int
  }

  private func bufferViewData(bufferViewIndex: Int) throws -> Data {
    let views = json["bufferViews"] as? [[String: Any]] ?? []
    guard views.indices.contains(bufferViewIndex) else {
      throw CeliaGLBError.invalidFile("Bad bufferView \(bufferViewIndex)")
    }
    let view = views[bufferViewIndex]
    let offset = view["byteOffset"] as? Int ?? 0
    let length = view["byteLength"] as? Int ?? 0
    guard offset + length <= bin.count else {
      throw CeliaGLBError.invalidFile("bufferView overruns BIN")
    }
    return bin.subdata(in: offset..<(offset + length))
  }

  private func componentsPerElement(_ type: String) -> Int {
    switch type {
    case "SCALAR": return 1
    case "VEC2": return 2
    case "VEC3": return 3
    case "VEC4": return 4
    case "MAT4": return 16
    default: return 1
    }
  }

  private func bytesForComponentType(_ type: Int) -> Int {
    switch type {
    case 5120, 5121: return 1
    case 5122, 5123: return 2
    case 5125, 5126: return 4
    default: return 4
    }
  }
}

enum CeliaGLBError: LocalizedError {
  case invalidFile(String)

  var errorDescription: String? {
    switch self {
    case .invalidFile(let message):
      return message
    }
  }
}
