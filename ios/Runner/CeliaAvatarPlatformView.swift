import Flutter
import SceneKit
import UIKit

/// SceneKit-backed VRoid viewer for iOS (same MethodChannel as Android Filament).
///
/// Loads the bundled Celia_filament.glb (VRM mesh + morph targets, VRM
/// extensions already stripped) and applies lip/eye morph weights from Dart.
final class CeliaAvatarPlatformView: NSObject, FlutterPlatformView {
  private static let channelName = "eu.thefit.celia/vrm_avatar"
  private static let modelResource = "Celia_filament"
  private static let modelExtension = "glb"

  /// Order matches extras.targetNames on Celia.vrm Face (merged).
  private static let faceMorphs: [String] = [
    "Fcl_ALL_Neutral", "Fcl_ALL_Angry", "Fcl_ALL_Fun", "Fcl_ALL_Joy",
    "Fcl_ALL_Sorrow", "Fcl_ALL_Surprised",
    "Fcl_BRW_Angry", "Fcl_BRW_Fun", "Fcl_BRW_Joy", "Fcl_BRW_Sorrow",
    "Fcl_BRW_Surprised",
    "Fcl_EYE_Natural", "Fcl_EYE_Angry", "Fcl_EYE_Close", "Fcl_EYE_Close_R",
    "Fcl_EYE_Close_L", "Fcl_EYE_Fun", "Fcl_EYE_Joy", "Fcl_EYE_Joy_R",
    "Fcl_EYE_Joy_L", "Fcl_EYE_Sorrow", "Fcl_EYE_Surprised", "Fcl_EYE_Spread",
    "Fcl_EYE_Iris_Hide", "Fcl_EYE_Highlight_Hide",
    "Fcl_MTH_Close", "Fcl_MTH_Up", "Fcl_MTH_Down", "Fcl_MTH_Angry",
    "Fcl_MTH_Small", "Fcl_MTH_Large", "Fcl_MTH_Neutral", "Fcl_MTH_Fun",
    "Fcl_MTH_Joy", "Fcl_MTH_Sorrow", "Fcl_MTH_Surprised", "Fcl_MTH_SkinFung",
    "Fcl_MTH_SkinFung_R", "Fcl_MTH_SkinFung_L",
    "Fcl_MTH_A", "Fcl_MTH_I", "Fcl_MTH_U", "Fcl_MTH_E", "Fcl_MTH_O",
    "Fcl_HA_Hide", "Fcl_HA_Fung1", "Fcl_HA_Fung1_Low", "Fcl_HA_Fung1_Up",
    "Fcl_HA_Fung2", "Fcl_HA_Fung2_Low", "Fcl_HA_Fung2_Up", "Fcl_HA_Fung3",
    "Fcl_HA_Fung3_Up", "Fcl_HA_Fung3_Low", "Fcl_HA_Short", "Fcl_HA_Short_Up",
    "Fcl_HA_Short_Low",
  ]

  private let container: UIView
  private let scnView: SCNView
  private let channel: FlutterMethodChannel
  private var faceNodes: [SCNNode] = []
  private var morphNames: [String] = []
  private var avatarState = "idle"
  private var swayAction: SCNAction?

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    container = UIView(frame: frame)
    container.backgroundColor = UIColor.white

    scnView = SCNView(frame: container.bounds)
    scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    scnView.backgroundColor = UIColor.white
    scnView.antialiasingMode = .multisampling4X
    scnView.allowsCameraControl = false
    scnView.autoenablesDefaultLighting = false
    container.addSubview(scnView)

    channel = FlutterMethodChannel(
      name: CeliaAvatarPlatformView.channelName,
      binaryMessenger: messenger
    )
    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  func view() -> UIView { container }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "attach":
      result(nil)
    case "loadBundledModel":
      do {
        try loadBundledModel()
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "load_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    case "setState":
      let args = call.arguments as? [String: Any]
      avatarState = args?["state"] as? String ?? "idle"
      updateIdleSway()
      result(nil)
    case "setMorphs":
      let args = call.arguments as? [String: Any]
      let morphs = args?["morphs"] as? [String: Any] ?? [:]
      applyMorphs(morphs)
      result(nil)
    case "dispose":
      scnView.scene = nil
      faceNodes.removeAll()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func loadBundledModel() throws {
    guard
      let url = Bundle.main.url(
        forResource: Self.modelResource,
        withExtension: Self.modelExtension
      )
    else {
      throw NSError(
        domain: "CeliaAvatar",
        code: 1,
        userInfo: [
          NSLocalizedDescriptionKey:
            "Celia_filament.glb missing from the app bundle",
        ]
      )
    }

    let data = try Data(contentsOf: url)
    let asset = try CeliaGLBAsset(data: data)
    let root = try asset.makeSceneRoot(
      preferredMorphNames: Self.faceMorphs
    )

    let scene = SCNScene()
    scene.rootNode.addChildNode(root)
    scene.background.contents = UIColor.white

    // Soft fill so unlit textures still read in SceneKit's default pipeline.
    let key = SCNNode()
    key.light = SCNLight()
    key.light?.type = .directional
    key.light?.intensity = 900
    key.light?.color = UIColor(red: 1, green: 0.98, blue: 0.95, alpha: 1)
    key.eulerAngles = SCNVector3(-0.9, -0.35, 0)
    scene.rootNode.addChildNode(key)

    let ambient = SCNNode()
    ambient.light = SCNLight()
    ambient.light?.type = .ambient
    ambient.light?.intensity = 400
    ambient.light?.color = UIColor.white
    scene.rootNode.addChildNode(ambient)

    frameBust(root: root, in: scene)
    scnView.scene = scene
    scnView.pointOfView = scene.rootNode.childNode(withName: "celia_camera", recursively: false)

    faceNodes = root.childNodes(passingTest: { node, _ in
      node.morpher != nil
    })
    if let morpher = faceNodes.first?.morpher {
      let count = morpher.targets.count
      // Prefer the names the model actually declares; the hardcoded list is
      // only a fallback for a GLB stripped of extras.targetNames.
      morphNames = asset.morphTargetNames.count >= count
        ? Array(asset.morphTargetNames.prefix(count))
        : Array(Self.faceMorphs.prefix(count))
    } else {
      morphNames = []
    }
    updateIdleSway()
  }

  /// Head-and-shoulders crop for a full-screen portrait (more torso than the
  /// old chat banner crop).
  private func frameBust(root: SCNNode, in scene: SCNScene) {
    let (minVec, maxVec) = root.boundingBox
    let height = max(maxVec.y - minVec.y, 0.001)
    let visibleHeight = height * 0.48
    let headY = maxVec.y - visibleHeight * 0.5
    let centerX = (minVec.x + maxVec.x) * 0.5
    let centerZ = (minVec.z + maxVec.z) * 0.5
    let distance = visibleHeight * 2.0

    let cameraNode = SCNNode()
    cameraNode.name = "celia_camera"
    cameraNode.camera = SCNCamera()
    cameraNode.camera?.fieldOfView = 35
    cameraNode.camera?.zNear = 0.01
    cameraNode.camera?.zFar = 100
    cameraNode.position = SCNVector3(centerX, headY, centerZ + distance)
    cameraNode.look(at: SCNVector3(centerX, headY, centerZ))
    scene.rootNode.addChildNode(cameraNode)
  }

  private func updateIdleSway() {
    guard let root = scnView.scene?.rootNode.childNodes.first else { return }
    root.removeAction(forKey: "idleSway")
    let shouldSway =
      avatarState == "idle" || avatarState == "listening" || avatarState == "thinking"
    guard shouldSway else { return }
    let left = SCNAction.moveBy(x: 0.012, y: 0, z: 0, duration: 1.6)
    left.timingMode = .easeInEaseOut
    let right = SCNAction.moveBy(x: -0.012, y: 0, z: 0, duration: 1.6)
    right.timingMode = .easeInEaseOut
    root.runAction(SCNAction.repeatForever(SCNAction.sequence([left, right])), forKey: "idleSway")
  }

  private func applyMorphs(_ morphs: [String: Any]) {
    guard !faceNodes.isEmpty, !morphNames.isEmpty else { return }
    for node in faceNodes {
      guard let morpher = node.morpher else { continue }
      for i in 0..<morpher.targets.count {
        morpher.setWeight(0, forTargetAt: i)
      }
      for (name, raw) in morphs {
        guard let idx = morphNames.firstIndex(of: name) else { continue }
        let value: CGFloat
        if let number = raw as? NSNumber {
          value = CGFloat(truncating: number)
        } else {
          value = 0
        }
        morpher.setWeight(min(max(value, 0), 1), forTargetAt: idx)
      }
    }
  }
}

final class CeliaAvatarViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    CeliaAvatarPlatformView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      messenger: messenger
    )
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}
