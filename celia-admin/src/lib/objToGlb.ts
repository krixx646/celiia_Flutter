/**
 * Minimal Wavefront OBJ to binary glTF (.glb) converter.
 *
 * Bodygram's REST API returns the body avatar as a base64 `.obj` — GLB is only
 * offered through their browser SDK — while Celia's native viewers (Filament on
 * Android, a hand-written GLB parser on iOS) speak GLB. Converting once here on
 * the server means the app only ever handles one mesh format.
 *
 * This is deliberately hand-rolled rather than pulling in obj2gltf, which drags
 * in Cesium and wants real files on disk: a bad trade inside a serverless
 * function. The input is narrow — one untextured, material-less body mesh — so
 * only the OBJ subset that describes geometry is supported.
 */

const FLOAT = 5126; // GL_FLOAT
const UNSIGNED_SHORT = 5123; // GL_UNSIGNED_SHORT
const UNSIGNED_INT = 5125; // GL_UNSIGNED_INT
const ARRAY_BUFFER = 34962;
const ELEMENT_ARRAY_BUFFER = 34963;
const TRIANGLES = 4;

export type ObjToGlbResult = {
  glb: Buffer;
  vertexCount: number;
  triangleCount: number;
};

export class ObjParseError extends Error {}

/**
 * Resolves an OBJ index, which is 1-based and may be negative to count
 * backwards from the most recently declared element.
 */
function resolveIndex(raw: number, declared: number): number {
  return raw > 0 ? raw - 1 : declared + raw;
}

/**
 * Derives smooth vertex normals by accumulating the normals of the faces each
 * vertex belongs to. Needed whenever the OBJ omits `vn`: without normals a lit
 * material has nothing to shade against and the mesh reads as a flat blob.
 */
function computeNormals(positions: number[], indices: number[]): number[] {
  const normals = new Array<number>(positions.length).fill(0);

  for (let i = 0; i < indices.length; i += 3) {
    const [a, b, c] = [indices[i] * 3, indices[i + 1] * 3, indices[i + 2] * 3];

    const abx = positions[b] - positions[a];
    const aby = positions[b + 1] - positions[a + 1];
    const abz = positions[b + 2] - positions[a + 2];
    const acx = positions[c] - positions[a];
    const acy = positions[c + 1] - positions[a + 1];
    const acz = positions[c + 2] - positions[a + 2];

    // Face normal, left unnormalised so larger triangles carry more weight.
    const nx = aby * acz - abz * acy;
    const ny = abz * acx - abx * acz;
    const nz = abx * acy - aby * acx;

    for (const base of [a, b, c]) {
      normals[base] += nx;
      normals[base + 1] += ny;
      normals[base + 2] += nz;
    }
  }

  for (let i = 0; i < normals.length; i += 3) {
    const length = Math.hypot(normals[i], normals[i + 1], normals[i + 2]);
    if (length > 0) {
      normals[i] /= length;
      normals[i + 1] /= length;
      normals[i + 2] /= length;
    } else {
      normals[i + 1] = 1; // Degenerate vertex: point it somewhere valid.
    }
  }

  return normals;
}

type ParsedObj = {
  positions: number[];
  normals: number[] | null;
  indices: number[];
};

function parseObj(objText: string): ParsedObj {
  const srcPositions: number[] = [];
  const srcNormals: number[] = [];

  const positions: number[] = [];
  const normals: number[] = [];
  const indices: number[] = [];

  // OBJ addresses position and normal independently, so a single position can
  // appear with several normals. glTF has one index per vertex, so each unique
  // pairing becomes its own vertex.
  const vertexCache = new Map<string, number>();
  let sawNormals = false;

  for (const rawLine of objText.split('\n')) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;

    const space = line.indexOf(' ');
    if (space < 0) continue;
    const keyword = line.slice(0, space);
    const rest = line.slice(space + 1).trim();

    if (keyword === 'v') {
      const [x, y, z] = rest.split(/\s+/);
      srcPositions.push(Number(x), Number(y), Number(z));
      continue;
    }

    if (keyword === 'vn') {
      const [x, y, z] = rest.split(/\s+/);
      srcNormals.push(Number(x), Number(y), Number(z));
      sawNormals = true;
      continue;
    }

    if (keyword !== 'f') continue; // vt, g, o, s, usemtl, mtllib: geometry-irrelevant

    const face: number[] = [];
    for (const token of rest.split(/\s+/)) {
      if (!token) continue;

      // "v", "v/vt", "v/vt/vn" or "v//vn".
      const parts = token.split('/');
      const positionIndex = resolveIndex(Number(parts[0]), srcPositions.length / 3);
      const normalIndex =
        parts.length > 2 && parts[2]
          ? resolveIndex(Number(parts[2]), srcNormals.length / 3)
          : -1;

      if (!Number.isInteger(positionIndex) || positionIndex < 0) {
        throw new ObjParseError(`Face references an unknown vertex: ${token}`);
      }

      const cacheKey = `${positionIndex}/${normalIndex}`;
      let vertex = vertexCache.get(cacheKey);

      if (vertex === undefined) {
        vertex = positions.length / 3;
        vertexCache.set(cacheKey, vertex);

        positions.push(
          srcPositions[positionIndex * 3],
          srcPositions[positionIndex * 3 + 1],
          srcPositions[positionIndex * 3 + 2]
        );

        if (normalIndex >= 0) {
          normals.push(
            srcNormals[normalIndex * 3],
            srcNormals[normalIndex * 3 + 1],
            srcNormals[normalIndex * 3 + 2]
          );
        } else if (sawNormals) {
          // Mixed file: keep the arrays the same length so the accessor stays
          // valid, and let the placeholder be overwritten below.
          normals.push(0, 0, 0);
        }
      }

      face.push(vertex);
    }

    if (face.length < 3) continue;

    // Fan-triangulate. Body meshes are usually triangles or quads already.
    for (let i = 1; i < face.length - 1; i += 1) {
      indices.push(face[0], face[i], face[i + 1]);
    }
  }

  if (positions.length === 0) throw new ObjParseError('OBJ contains no vertices');
  if (indices.length === 0) throw new ObjParseError('OBJ contains no faces');

  const usable = normals.length === positions.length && normals.some((n) => n !== 0);

  return { positions, normals: usable ? normals : null, indices };
}

function alignTo4(value: number): number {
  return (value + 3) & ~3;
}

export function objToGlb(objText: string): ObjToGlbResult {
  const { positions, indices, normals: parsedNormals } = parseObj(objText);
  const normals = parsedNormals ?? computeNormals(positions, indices);

  const vertexCount = positions.length / 3;

  // A real body mesh comes in around 32k vertices, which fits in 16-bit
  // indices. Since indices outnumber vertices roughly 6:1 here, halving them
  // takes about a quarter off the file the phone has to download.
  const useShortIndices = vertexCount <= 65535;
  const indexData = useShortIndices ? new Uint16Array(indices) : new Uint32Array(indices);
  const positionData = new Float32Array(positions);
  const normalData = new Float32Array(normals);

  // The spec requires min/max on the POSITION accessor; viewers use it to frame
  // the model, which is exactly what our bust/full-body framing relies on.
  const min: [number, number, number] = [Infinity, Infinity, Infinity];
  const max: [number, number, number] = [-Infinity, -Infinity, -Infinity];
  for (let i = 0; i < positionData.length; i += 3) {
    for (let axis = 0; axis < 3; axis += 1) {
      const value = positionData[i + axis];
      if (value < min[axis]) min[axis] = value;
      if (value > max[axis]) max[axis] = value;
    }
  }

  // Accessor offsets must be a multiple of their component size, so the float
  // data that follows 16-bit indices needs realigning to 4 bytes.
  const indexOffset = 0;
  const positionOffset = alignTo4(indexOffset + indexData.byteLength);
  const normalOffset = positionOffset + positionData.byteLength;
  const binLength = normalOffset + normalData.byteLength;

  const gltf = {
    asset: { version: '2.0', generator: 'celia-admin objToGlb' },
    scene: 0,
    scenes: [{ nodes: [0] }],
    nodes: [{ mesh: 0, name: 'BodyScan' }],
    meshes: [
      {
        name: 'BodyScan',
        primitives: [
          {
            attributes: { POSITION: 1, NORMAL: 2 },
            indices: 0,
            material: 0,
            mode: TRIANGLES,
          },
        ],
      },
    ],
    materials: [
      {
        name: 'BodySurface',
        // The vendor sends geometry only, with no textures or materials, so
        // this is ours to choose: a matte neutral that reads as a form under
        // the viewer's key light.
        pbrMetallicRoughness: {
          baseColorFactor: [0.82, 0.8, 0.78, 1],
          metallicFactor: 0,
          roughnessFactor: 0.85,
        },
        doubleSided: true,
      },
    ],
    accessors: [
      {
        bufferView: 0,
        componentType: useShortIndices ? UNSIGNED_SHORT : UNSIGNED_INT,
        count: indexData.length,
        type: 'SCALAR',
      },
      {
        bufferView: 1,
        componentType: FLOAT,
        count: positionData.length / 3,
        type: 'VEC3',
        min,
        max,
      },
      {
        bufferView: 2,
        componentType: FLOAT,
        count: normalData.length / 3,
        type: 'VEC3',
      },
    ],
    bufferViews: [
      {
        buffer: 0,
        byteOffset: indexOffset,
        byteLength: indexData.byteLength,
        target: ELEMENT_ARRAY_BUFFER,
      },
      {
        buffer: 0,
        byteOffset: positionOffset,
        byteLength: positionData.byteLength,
        target: ARRAY_BUFFER,
      },
      {
        buffer: 0,
        byteOffset: normalOffset,
        byteLength: normalData.byteLength,
        target: ARRAY_BUFFER,
      },
    ],
    buffers: [{ byteLength: binLength }],
  };

  // Chunks are padded to 4 bytes: JSON with spaces, BIN with zeros.
  const jsonChunk = Buffer.from(JSON.stringify(gltf), 'utf8');
  const jsonPadded = Buffer.alloc(alignTo4(jsonChunk.length), 0x20);
  jsonChunk.copy(jsonPadded);

  const binPadded = Buffer.alloc(alignTo4(binLength), 0);
  Buffer.from(indexData.buffer, indexData.byteOffset, indexData.byteLength).copy(
    binPadded,
    indexOffset
  );
  Buffer.from(
    positionData.buffer,
    positionData.byteOffset,
    positionData.byteLength
  ).copy(binPadded, positionOffset);
  Buffer.from(normalData.buffer, normalData.byteOffset, normalData.byteLength).copy(
    binPadded,
    normalOffset
  );

  const header = Buffer.alloc(12);
  header.write('glTF', 0, 'ascii');
  header.writeUInt32LE(2, 4);
  header.writeUInt32LE(12 + 8 + jsonPadded.length + 8 + binPadded.length, 8);

  const jsonHeader = Buffer.alloc(8);
  jsonHeader.writeUInt32LE(jsonPadded.length, 0);
  jsonHeader.write('JSON', 4, 'ascii');

  const binHeader = Buffer.alloc(8);
  binHeader.writeUInt32LE(binPadded.length, 0);
  binHeader.write('BIN\0', 4, 'ascii');

  return {
    glb: Buffer.concat([header, jsonHeader, jsonPadded, binHeader, binPadded]),
    vertexCount,
    triangleCount: indexData.length / 3,
  };
}
