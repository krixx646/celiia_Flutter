"""Insert the Body Scan strings into app_en.arb.

Line-based on purpose: re-serialising the JSON would reflow the whole file and
bury the new keys in an unreadable diff. Keys already present are left alone.

Run tool/i18n/translate_missing.py afterwards to fill the other locales.
"""

import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
EN = os.path.join(ROOT, "lib", "l10n", "app_en.arb")

# Copy rules that matter here:
#  - never say "measured", always "estimate"
#  - never say "muscle protein"; lean mass is muscle + water + bone + organs
#  - the capture guidance is what decides whether a scan succeeds, so it is
#    specific rather than encouraging
STRINGS = {
    "bodyScanTitle": "Body scan",
    "bodyScanContinue": "Continue",
    "bodyScanDone": "Done",

    # Consent
    "bodyScanConsentTitle": "Before you scan",
    "bodyScanConsentBody": "A body scan estimates your body composition from two photos. Here is exactly what happens to them.",
    "bodyScanConsentPhotosTitle": "Two photos, taken by you",
    "bodyScanConsentPhotosBody": "One facing the camera, one from your right side. Wear close-fitting clothing so your outline is clear.",
    "bodyScanConsentProcessingTitle": "Analysed by Bodygram",
    "bodyScanConsentProcessingBody": "Your photos are sent to our scanning provider, Bodygram, to estimate your measurements. They are used for nothing else.",
    "bodyScanConsentStorageTitle": "Your photos are never stored",
    "bodyScanConsentStorageBody": "Celia does not keep them. Only the resulting numbers and your 3D model are saved to your account, and deleting your account deletes them.",
    "bodyScanConsentAgeTitle": "You must be 18 or over",
    "bodyScanConsentAgeBody": "Body scanning is not available to under-18s.",
    "bodyScanConsentAgree": "I understand and agree to my photos being analysed",

    # Stats
    "bodyScanStatsTitle": "Confirm your details",
    "bodyScanStatsBody": "These feed directly into the estimate, so an out-of-date weight will skew your results.",
    "bodyScanStatsHeight": "Height",
    "bodyScanStatsWeight": "Weight",
    "bodyScanStatsAge": "Age",
    "bodyScanStatsSex": "Sex",
    "bodyScanStatsSexNote": "The scanning model is built on two reference groups only. Choose the one closer to your body; it affects the estimate, not how Celia treats you.",
    "bodyScanStatsFemale": "Female",
    "bodyScanStatsMale": "Male",
    "bodyScanStatsInvalid": "Enter a valid height, weight and age. You must be 18 or over to scan.",

    # Capture
    "bodyScanCaptureFrontTitle": "Face the camera",
    "bodyScanCaptureRightTitle": "Turn to your right",
    "bodyScanCaptureHowTo": "Prop your phone up about 3 m away, step back until your whole body fits the outline, then start the timer.",
    "bodyScanCaptureTips": "Close-fitting clothes, plain background, good even light, arms slightly away from your sides.",
    "bodyScanPoseFront": "Front",
    "bodyScanPoseRight": "Right side",
    "bodyScanStartTimer": "Start timer",
    "bodyScanCancelTimer": "Cancel timer",
    "bodyScanRetake": "Retake",
    "bodyScanNextPose": "Next photo",
    "bodyScanGetResults": "Get my results",

    # Processing + results
    "bodyScanProcessingTitle": "Analysing your scan",
    "bodyScanProcessingBody": "Building your 3D model and estimating your measurements. This takes up to a minute.",
    "bodyScanResultTitle": "Your body scan",
    "bodyScanResultSubtitle": "Estimated from your photos. Best used to follow a trend over time.",
    "bodyScanBodyFat": "Body fat",
    "bodyScanLeanMass": "Lean mass",
    "bodyScanFatMass": "Fat mass",
    "bodyScanWaist": "Waist",
    "bodyScanHip": "Hips",
    "bodyScanChest": "Chest",
    "bodyScanWaistToHip": "Waist to hip",
    "bodyScanQuotaRemaining": "{count, plural, =0{No scans left this period} =1{1 scan left this period} other{{count} scans left this period}}",

    # Hub
    "bodyScanEmptyTitle": "See how your body is changing",
    "bodyScanEmptyBody": "Two photos give you an estimate of your body fat, lean mass and key measurements, plus a 3D model you can compare over time.",
    "bodyScanLatestTitle": "Latest scan",
    "bodyScanHistoryTitle": "Previous scans",
    "bodyScanStartCta": "Start a body scan",
    "bodyScanRescanCta": "Scan again",
    "bodyScanRescanHint": "Body composition changes slowly. Scanning about once a month gives the most meaningful comparison.",
    "bodyScanDeltaSinceLast": "{value}% change since your last scan",
    "bodyScanNoComposition": "No estimate",

    # Sources (App Store 1.4.1)
    "bodyScanSourcesTitle": "How this is worked out",
    "bodyScanSourcesBody": "Your photos are turned into a 3D outline of your body, and body fat and lean mass are estimated from that shape together with your height, weight, age and sex. Lean mass covers muscle, water, bone and organs together, not protein on its own.",
    "bodyScanDisclaimer": "These are estimates, not medical measurements. Studies of this method report an average error of about 3.5% body fat against a clinical DXA scan, and agreement is weaker for tracking change than for a single reading. Not for diagnosis. Talk to a healthcare professional about health decisions.",

    # Errors
    "bodyScanErrorCameraPermission": "Celia needs camera access to scan your body.",
    "bodyScanErrorNoCamera": "No camera is available on this device.",
    "bodyScanErrorFraming": "Your whole body needs to be in the frame. Move the phone further away and make sure your head and feet are both visible.",
    "bodyScanErrorQuality": "The photos were too dark or too blurry. Find brighter, even lighting and keep still while the timer runs.",
    "bodyScanErrorPose": "Your pose was not quite right. Stand upright facing the camera, arms slightly away from your sides, then turn fully to your right for the second photo.",
    "bodyScanErrorClothing": "Loose clothing hides your outline. Close-fitting clothes give a usable scan.",
    "bodyScanErrorPhotoUnknown": "Those photos could not be used. Try again against a plain background in good light.",
    "bodyScanErrorPhotosTooLarge": "Those photos were too large to upload. Try again.",
    "bodyScanErrorQuota": "You have used your scans for this period. You can scan again once it resets.",
    "bodyScanErrorAge": "Body scanning is only available to users aged 18 and over.",
    "bodyScanErrorStats": "Check your height, weight, age and sex, then try again.",
    "bodyScanErrorSignedIn": "Please sign in again to scan.",
    "bodyScanErrorUnavailable": "Body scanning is not available right now.",
    "bodyScanErrorNetwork": "Could not reach Celia. Check your connection and try again.",
    "bodyScanErrorServer": "Something went wrong with your scan. Please try again.",
    "bodyScanErrorLoadHistory": "Could not load your previous scans.",

    # Entry points
    "profileBodyScan": "Body scan",
    "homeBodyScan": "Body scan",
    "homeBodyScanSubtitle": "Estimate body fat from two photos",
}

METADATA = {
    "bodyScanQuotaRemaining": {
        "placeholders": {"count": {"type": "int"}}
    },
    "bodyScanDeltaSinceLast": {
        "placeholders": {"value": {"type": "String"}}
    },
}


def main() -> int:
    with open(EN, encoding="utf-8") as handle:
        existing = json.load(handle)

    missing = [k for k in STRINGS if k not in existing]
    if not missing:
        print("all body scan keys already present")
        return 0

    with open(EN, encoding="utf-8") as handle:
        lines = handle.read().rstrip("\n").split("\n")

    # The file ends with the closing brace; everything goes just above it.
    assert lines[-1].strip() == "}", "unexpected end of app_en.arb"
    body = lines[:-1]
    if not body[-1].rstrip().endswith(","):
        body[-1] = body[-1].rstrip() + ","

    block: list[str] = ["", "  \"@@bodyScan\": \"--- Body Scan ---\","]
    for index, key in enumerate(missing):
        value = json.dumps(STRINGS[key], ensure_ascii=False)
        meta = METADATA.get(key)
        trailing = "" if index == len(missing) - 1 and not meta else ","
        block.append(f"  {json.dumps(key)}: {value}{trailing}")
        if meta:
            rendered = json.dumps(meta, ensure_ascii=False, indent=2).split("\n")
            rendered = [rendered[0]] + ["  " + line for line in rendered[1:]]
            suffix = "" if index == len(missing) - 1 else ","
            block.append(f"  {json.dumps('@' + key)}: " + "\n".join(rendered) + suffix)

    out = body + block + ["}"]
    with open(EN, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(out) + "\n")

    # Fail loudly rather than leaving a broken ARB behind.
    with open(EN, encoding="utf-8") as handle:
        json.load(handle)

    print(f"added {len(missing)} keys to app_en.arb")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
