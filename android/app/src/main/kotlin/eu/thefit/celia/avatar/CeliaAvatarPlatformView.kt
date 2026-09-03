package eu.thefit.celia.avatar

import android.content.Context
import android.view.Choreographer
import android.view.TextureView
import android.view.View
import com.google.android.filament.ColorGrading
import com.google.android.filament.ToneMapper
import com.google.android.filament.utils.Manipulator
import com.google.android.filament.utils.ModelViewer
import com.google.android.filament.utils.Utils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.nio.ByteBuffer

/**
 * Filament-backed VRoid viewer for Android.
 *
 * Loads the bundled Celia_filament.glb (VRM mesh + morph targets, VRM
 * extensions stripped) and applies lip/eye morph weights from Dart.
 */
class CeliaAvatarPlatformView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
) : PlatformView, MethodChannel.MethodCallHandler, Choreographer.FrameCallback {

    companion object {
        init {
            Utils.init()
        }

        private const val CHANNEL = "eu.thefit.celia/vrm_avatar"
        private const val MODEL_ASSET = "avatars/Celia_filament.glb"

        /**
         * The orbit Manipulator below starts its eye at (0, 0, 1) and looks
         * down -Z at [TARGET_Z] (see Manipulator.Builder.orbitHomePosition).
         */
        private const val EYE_Z = 1.0f

        /** Matches ModelViewer.kDefaultObjectPosition, which we cannot read. */
        private const val TARGET_Z = -4.0f

        /** Filament assumes a 36x24mm frame, so half the frame height is 12mm. */
        private const val SENSOR_HALF_HEIGHT_MM = 12.0f

        /** Fraction of the model's height to show: head, shoulders, upper torso. */
        private const val BUST_FRACTION = 0.48f

        /** How much of the viewport the bust fills, leaving a little margin. */
        private const val BUST_FILL = 0.85f

        /** Order matches extras.targetNames on Celia.vrm Face (merged). */
        private val CELIA_FACE_MORPHS = listOf(
            "Fcl_ALL_Neutral",
            "Fcl_ALL_Angry",
            "Fcl_ALL_Fun",
            "Fcl_ALL_Joy",
            "Fcl_ALL_Sorrow",
            "Fcl_ALL_Surprised",
            "Fcl_BRW_Angry",
            "Fcl_BRW_Fun",
            "Fcl_BRW_Joy",
            "Fcl_BRW_Sorrow",
            "Fcl_BRW_Surprised",
            "Fcl_EYE_Natural",
            "Fcl_EYE_Angry",
            "Fcl_EYE_Close",
            "Fcl_EYE_Close_R",
            "Fcl_EYE_Close_L",
            "Fcl_EYE_Fun",
            "Fcl_EYE_Joy",
            "Fcl_EYE_Joy_R",
            "Fcl_EYE_Joy_L",
            "Fcl_EYE_Sorrow",
            "Fcl_EYE_Surprised",
            "Fcl_EYE_Spread",
            "Fcl_EYE_Iris_Hide",
            "Fcl_EYE_Highlight_Hide",
            "Fcl_MTH_Close",
            "Fcl_MTH_Up",
            "Fcl_MTH_Down",
            "Fcl_MTH_Angry",
            "Fcl_MTH_Small",
            "Fcl_MTH_Large",
            "Fcl_MTH_Neutral",
            "Fcl_MTH_Fun",
            "Fcl_MTH_Joy",
            "Fcl_MTH_Sorrow",
            "Fcl_MTH_Surprised",
            "Fcl_MTH_SkinFung",
            "Fcl_MTH_SkinFung_R",
            "Fcl_MTH_SkinFung_L",
            "Fcl_MTH_A",
            "Fcl_MTH_I",
            "Fcl_MTH_U",
            "Fcl_MTH_E",
            "Fcl_MTH_O",
            "Fcl_HA_Hide",
            "Fcl_HA_Fung1",
            "Fcl_HA_Fung1_Low",
            "Fcl_HA_Fung1_Up",
            "Fcl_HA_Fung2",
            "Fcl_HA_Fung2_Low",
            "Fcl_HA_Fung2_Up",
            "Fcl_HA_Fung3",
            "Fcl_HA_Fung3_Up",
            "Fcl_HA_Fung3_Low",
            "Fcl_HA_Short",
            "Fcl_HA_Short_Up",
            "Fcl_HA_Short_Low",
        )
    }

    /**
     * A TextureView, not a SurfaceView: Flutter composites platform views by
     * drawing them into its own hardware canvas, and a SurfaceView's content
     * lives on a separate hardware layer that never lands in that canvas — the
     * avatar area just came out blank.
     */
    private val textureView = TextureView(context)

    /**
     * The manipulator is built with a 1x1 viewport instead of the view's own
     * size, which is still 0x0 here; ModelViewer's default would divide by that
     * zero and feed NaN into camera.lookAt. SurfaceCallback.onResized replaces
     * it with the real viewport as soon as the surface exists.
     */
    private val modelViewer = ModelViewer(
        textureView,
        manipulator = Manipulator.Builder()
            .targetPosition(0.0f, 0.0f, TARGET_Z)
            .viewport(1, 1)
            .build(Manipulator.Mode.ORBIT),
    )
    private val choreographer = Choreographer.getInstance()
    private val channel = MethodChannel(messenger, CHANNEL)
    private val contextRef = context.applicationContext

    private var faceEntity = 0
    private var morphNames: List<String> = emptyList()
    private var morphWeights: FloatArray = FloatArray(0)
    private var framePosted = false
    private var avatarState = "idle"
    private var swayPhase = 0f
    /** Bust framing matrix; idle sway is applied on top of this each frame. */
    private var baseTransform: FloatArray? = null

    /**
     * False once the view leaves the window. ModelViewer installs its own
     * detach listener that calls destroy() — which tears down the Filament
     * engine, asset loader and resource loader — and documents itself as
     * invalid afterwards. Every call into [modelViewer] therefore has to be
     * gated on this, or we dereference freed native objects and take a SIGSEGV.
     */
    private var viewerValid = true

    /** Distinguishes "detached, already destroyed" from "never attached". */
    private var wasAttached = false

    init {
        channel.setMethodCallHandler(this)
        modelViewer.view.blendMode = com.google.android.filament.View.BlendMode.OPAQUE
        modelViewer.scene.skybox = null
        modelViewer.renderer.clearOptions = modelViewer.renderer.clearOptions.apply {
            clear = true
            clearColor = doubleArrayOf(1.0, 1.0, 1.0, 1.0)
        }
        // Post-processing tone maps the whole frame, and Filament's default
        // ACES curve turned the white clear colour beige and shifted the
        // baked VRoid textures. Celia's materials are unlit, so there is no
        // HDR range to compress and a linear pass is what we want.
        modelViewer.view.colorGrading = ColorGrading.Builder()
            .toneMapper(ToneMapper.Linear())
            .build(modelViewer.engine)
        // Added after ModelViewer's own listener, so its destroy() has already
        // run by the time this fires. Only bookkeeping happens here.
        textureView.addOnAttachStateChangeListener(
            object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(v: View) {
                    wasAttached = true
                }

                override fun onViewDetachedFromWindow(v: View) {
                    viewerValid = false
                    stopFrames()
                }
            },
        )
    }

    override fun getView(): View = textureView

    /**
     * Deliberately does not destroy the model or the engine: Flutter removes
     * the view from the window around this call, and ModelViewer's detach
     * listener performs the full teardown itself. Calling destroyModel() here
     * raced that and crashed inside ResourceLoader::asyncCancelLoad.
     */
    override fun dispose() {
        viewerValid = false
        stopFrames()
        channel.setMethodCallHandler(null)
        if (!wasAttached) {
            // No detach will ever come, so nothing else would free the engine.
            try {
                modelViewer.destroy()
            } catch (_: Throwable) {
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!viewerValid && call.method != "dispose") {
            result.error("viewer_detached", "Avatar viewer is no longer attached", null)
            return
        }
        when (call.method) {
            "attach" -> {
                startFrames()
                result.success(null)
            }
            "loadBundledModel" -> {
                try {
                    loadBundledModel()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("load_failed", e.message, null)
                }
            }
            "setState" -> {
                avatarState = call.argument<String>("state") ?: "idle"
                result.success(null)
            }
            "setMorphs" -> {
                val morphs = call.argument<Map<String, Any>>("morphs") ?: emptyMap()
                applyMorphs(morphs)
                result.success(null)
            }
            "dispose" -> {
                stopFrames()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun loadBundledModel() {
        // readBytes() loops until EOF. A single read() would stop at the first
        // chunk, because .glb is not on aapt's no-compress list and a deflated
        // asset streams back in small pieces, leaving a truncated model.
        val bytes = contextRef.assets.open(MODEL_ASSET).use { it.readBytes() }
        val byteBuffer = ByteBuffer.allocateDirect(bytes.size).apply {
            put(bytes)
            rewind()
        }
        modelViewer.destroyModel()
        modelViewer.loadModelGlb(byteBuffer)
        // Bust crop from the live AABB — do not call transformToUnitCube first,
        // or we mix unit-cube space with model-space head height and drift.
        frameBust()
        discoverFaceMorphs()
        startFrames()
    }

    /**
     * Moves Celia's head-and-shoulders in front of ModelViewer's default
     * camera, which we cannot reposition (its Manipulator is private).
     *
     * Filament's setLensProjection derives the vertical field of view from a
     * 24mm frame height, so tan(fovY/2) = 12 / focalLength and the visible
     * height at distance d is 2 * d * tan(fovY/2) — independent of the
     * viewport aspect, which is why a short, wide banner is framed vertically.
     * We solve that for d and translate the model there. Translating instead of
     * scaling keeps the mesh at VRM scale, so morph deltas stay correct.
     */
    private fun frameBust() {
        val asset = modelViewer.asset ?: return
        val tm = modelViewer.engine.transformManager
        val rootInstance = tm.getInstance(asset.root)
        if (rootInstance == 0) return

        val box = asset.boundingBox
        val center = box.center
        val half = box.halfExtent
        val maxY = center[1] + half[1]
        val height = (half[1] * 2f).coerceAtLeast(0.001f)

        val bustHeight = height * BUST_FRACTION
        val focusY = maxY - bustHeight * 0.5f
        val tanHalfFov = SENSOR_HALF_HEIGHT_MM / modelViewer.cameraFocalLength
        val distance = bustHeight / (2f * tanHalfFov * BUST_FILL)

        val transform = FloatArray(16)
        android.opengl.Matrix.setIdentityM(transform, 0)
        android.opengl.Matrix.translateM(
            transform,
            0,
            -center[0],
            -focusY,
            EYE_Z - distance - center[2],
        )
        baseTransform = transform.copyOf()
        tm.setTransform(rootInstance, transform)
    }

    private fun discoverFaceMorphs() {
        faceEntity = 0
        morphNames = emptyList()
        morphWeights = FloatArray(0)

        val asset = modelViewer.asset ?: return
        val rm = modelViewer.engine.renderableManager

        for (entity in asset.entities) {
            if (!rm.hasComponent(entity)) continue
            val ri = rm.getInstance(entity)
            val count = rm.getMorphTargetCount(ri)
            if (count <= 0) continue

            faceEntity = entity
            // Filament 1.71 does not expose morph names on FilamentAsset.
            morphNames = CELIA_FACE_MORPHS.take(count)
            morphWeights = FloatArray(count)
            break
        }
    }

    private fun applyMorphs(morphs: Map<String, Any>) {
        if (!viewerValid || faceEntity == 0 || morphWeights.isEmpty()) return
        for (i in morphWeights.indices) morphWeights[i] = 0f
        for ((name, raw) in morphs) {
            val idx = morphNames.indexOf(name)
            if (idx < 0) continue
            val value = when (raw) {
                is Number -> raw.toFloat()
                else -> 0f
            }.coerceIn(0f, 1f)
            morphWeights[idx] = value
        }
        val rm = modelViewer.engine.renderableManager
        if (!rm.hasComponent(faceEntity)) return
        val ri = rm.getInstance(faceEntity)
        rm.setMorphWeights(ri, morphWeights, 0)
    }

    private fun startFrames() {
        if (framePosted || !viewerValid) return
        framePosted = true
        choreographer.postFrameCallback(this)
    }

    private fun stopFrames() {
        framePosted = false
        choreographer.removeFrameCallback(this)
    }

    override fun doFrame(frameTimeNanos: Long) {
        if (!framePosted || !viewerValid) return
        choreographer.postFrameCallback(this)
        modelViewer.animator?.apply {
            updateBoneMatrices()
        }
        val base = baseTransform
        val asset = modelViewer.asset
        if (base != null && asset != null) {
            val tm = modelViewer.engine.transformManager
            val rootInstance = tm.getInstance(asset.root)
            if (rootInstance != 0) {
                val framed = base.copyOf()
                if (avatarState == "idle" ||
                    avatarState == "listening" ||
                    avatarState == "thinking"
                ) {
                    swayPhase += 0.02f
                    framed[12] += kotlin.math.sin(swayPhase.toDouble()).toFloat() * 0.015f
                }
                tm.setTransform(rootInstance, framed)
            }
        }
        modelViewer.render(frameTimeNanos)
    }
}
