import json
import pathlib
import re

translations = {
  "es": {
    "profileAvatarMode": "Modo avatar",
    "profileAvatarModeSubtitle": "Habla con Celia a pantalla completa",
    "avatarModeReady": "Lista",
    "avatarModeThinking": "Pensando…",
    "avatarModeSpeaking": "Hablando…",
    "avatarModeHoldToTalk": "Mantén pulsado para hablar",
    "avatarModeExit": "Modo manual",
    "avatarModeConfirmTitle": "¿Confirmar con Celia?",
    "avatarModeConfirmBody": "Celia quiere guardar algo. ¿Lo permites?",
    "avatarModeConfirmYes": "Permitir",
  },
  "fr": {
    "profileAvatarMode": "Mode avatar",
    "profileAvatarModeSubtitle": "Parlez à Celia en plein écran",
    "avatarModeReady": "Prête",
    "avatarModeThinking": "Réflexion…",
    "avatarModeSpeaking": "Elle parle…",
    "avatarModeHoldToTalk": "Maintenir pour parler",
    "avatarModeExit": "Mode manuel",
    "avatarModeConfirmTitle": "Confirmer avec Celia ?",
    "avatarModeConfirmBody": "Celia veut enregistrer quelque chose. Autoriser ?",
    "avatarModeConfirmYes": "Autoriser",
  },
  "de": {
    "profileAvatarMode": "Avatar-Modus",
    "profileAvatarModeSubtitle": "Sprich vollbild mit Celia",
    "avatarModeReady": "Bereit",
    "avatarModeThinking": "Denkt nach…",
    "avatarModeSpeaking": "Spricht…",
    "avatarModeHoldToTalk": "Zum Sprechen halten",
    "avatarModeExit": "Manueller Modus",
    "avatarModeConfirmTitle": "Mit Celia bestätigen?",
    "avatarModeConfirmBody": "Celia möchte etwas speichern. Erlauben?",
    "avatarModeConfirmYes": "Erlauben",
  },
  "pt": {
    "profileAvatarMode": "Modo avatar",
    "profileAvatarModeSubtitle": "Fale com a Celia em ecrã inteiro",
    "avatarModeReady": "Pronta",
    "avatarModeThinking": "Pensando…",
    "avatarModeSpeaking": "Falando…",
    "avatarModeHoldToTalk": "Segure para falar",
    "avatarModeExit": "Modo manual",
    "avatarModeConfirmTitle": "Confirmar com a Celia?",
    "avatarModeConfirmBody": "Celia quer guardar algo. Permitir?",
    "avatarModeConfirmYes": "Permitir",
  },
  "it": {
    "profileAvatarMode": "Modalità avatar",
    "profileAvatarModeSubtitle": "Parla con Celia a schermo intero",
    "avatarModeReady": "Pronta",
    "avatarModeThinking": "Sta pensando…",
    "avatarModeSpeaking": "Sta parlando…",
    "avatarModeHoldToTalk": "Tieni premuto per parlare",
    "avatarModeExit": "Modalità manuale",
    "avatarModeConfirmTitle": "Confermare con Celia?",
    "avatarModeConfirmBody": "Celia vuole salvare qualcosa. Consentire?",
    "avatarModeConfirmYes": "Consenti",
  },
  "nl": {
    "profileAvatarMode": "Avatarmodus",
    "profileAvatarModeSubtitle": "Praat full-screen met Celia",
    "avatarModeReady": "Klaar",
    "avatarModeThinking": "Denkt na…",
    "avatarModeSpeaking": "Spreekt…",
    "avatarModeHoldToTalk": "Houd vast om te praten",
    "avatarModeExit": "Handmatige modus",
    "avatarModeConfirmTitle": "Bevestigen met Celia?",
    "avatarModeConfirmBody": "Celia wil iets opslaan. Toestaan?",
    "avatarModeConfirmYes": "Toestaan",
  },
  "pl": {
    "profileAvatarMode": "Tryb awatara",
    "profileAvatarModeSubtitle": "Rozmawiaj z Celią na pełnym ekranie",
    "avatarModeReady": "Gotowa",
    "avatarModeThinking": "Myśli…",
    "avatarModeSpeaking": "Mówi…",
    "avatarModeHoldToTalk": "Przytrzymaj, aby mówić",
    "avatarModeExit": "Tryb ręczny",
    "avatarModeConfirmTitle": "Potwierdzić z Celią?",
    "avatarModeConfirmBody": "Celia chce coś zapisać. Zezwolić?",
    "avatarModeConfirmYes": "Zezwól",
  },
  "ru": {
    "profileAvatarMode": "Режим аватара",
    "profileAvatarModeSubtitle": "Говорите с Celia на весь экран",
    "avatarModeReady": "Готова",
    "avatarModeThinking": "Думает…",
    "avatarModeSpeaking": "Говорит…",
    "avatarModeHoldToTalk": "Удерживайте, чтобы говорить",
    "avatarModeExit": "Обычный режим",
    "avatarModeConfirmTitle": "Подтвердить с Celia?",
    "avatarModeConfirmBody": "Celia хочет что-то сохранить. Разрешить?",
    "avatarModeConfirmYes": "Разрешить",
  },
  "tr": {
    "profileAvatarMode": "Avatar modu",
    "profileAvatarModeSubtitle": "Celia ile tam ekran konuş",
    "avatarModeReady": "Hazır",
    "avatarModeThinking": "Düşünüyor…",
    "avatarModeSpeaking": "Konuşuyor…",
    "avatarModeHoldToTalk": "Konuşmak için basılı tut",
    "avatarModeExit": "Manuel mod",
    "avatarModeConfirmTitle": "Celia ile onayla?",
    "avatarModeConfirmBody": "Celia bir şey kaydetmek istiyor. İzin ver?",
    "avatarModeConfirmYes": "İzin ver",
  },
  "ar": {
    "profileAvatarMode": "وضع الصورة الرمزية",
    "profileAvatarModeSubtitle": "تحدث مع سيليا بملء الشاشة",
    "avatarModeReady": "جاهزة",
    "avatarModeThinking": "تفكّر…",
    "avatarModeSpeaking": "تتحدث…",
    "avatarModeHoldToTalk": "اضغط مع الاستمرار للتحدث",
    "avatarModeExit": "الوضع اليدوي",
    "avatarModeConfirmTitle": "تأكيد مع سيليا؟",
    "avatarModeConfirmBody": "سيليا تريد حفظ شيء. هل تسمح؟",
    "avatarModeConfirmYes": "السماح",
  },
  "hi": {
    "profileAvatarMode": "अवतार मोड",
    "profileAvatarModeSubtitle": "सीलिया से फुल स्क्रीन पर बात करें",
    "avatarModeReady": "तैयार",
    "avatarModeThinking": "सोच रही है…",
    "avatarModeSpeaking": "बोल रही है…",
    "avatarModeHoldToTalk": "बोलने के लिए दबाकर रखें",
    "avatarModeExit": "मैनुअल मोड",
    "avatarModeConfirmTitle": "सीलिया से पुष्टि करें?",
    "avatarModeConfirmBody": "सीलिया कुछ सेव करना चाहती है। अनुमति दें?",
    "avatarModeConfirmYes": "अनुमति दें",
  },
  "zh": {
    "profileAvatarMode": "虚拟形象模式",
    "profileAvatarModeSubtitle": "与 Celia 全屏语音对话",
    "avatarModeReady": "准备就绪",
    "avatarModeThinking": "思考中…",
    "avatarModeSpeaking": "说话中…",
    "avatarModeHoldToTalk": "按住说话",
    "avatarModeExit": "手动模式",
    "avatarModeConfirmTitle": "与 Celia 确认？",
    "avatarModeConfirmBody": "Celia 想保存内容。允许吗？",
    "avatarModeConfirmYes": "允许",
  },
  "ja": {
    "profileAvatarMode": "アバターモード",
    "profileAvatarModeSubtitle": "Celiaと全画面で話す",
    "avatarModeReady": "待機中",
    "avatarModeThinking": "考え中…",
    "avatarModeSpeaking": "話しています…",
    "avatarModeHoldToTalk": "長押しで話す",
    "avatarModeExit": "手動モード",
    "avatarModeConfirmTitle": "Celiaに確認しますか？",
    "avatarModeConfirmBody": "Celiaが保存しようとしています。許可しますか？",
    "avatarModeConfirmYes": "許可",
  },
  "ko": {
    "profileAvatarMode": "아바타 모드",
    "profileAvatarModeSubtitle": "Celia와 전체 화면으로 대화",
    "avatarModeReady": "준비됨",
    "avatarModeThinking": "생각 중…",
    "avatarModeSpeaking": "말하는 중…",
    "avatarModeHoldToTalk": "길게 눌러 말하기",
    "avatarModeExit": "수동 모드",
    "avatarModeConfirmTitle": "Celia에게 확인할까요?",
    "avatarModeConfirmBody": "Celia가 저장하려 합니다. 허용할까요?",
    "avatarModeConfirmYes": "허용",
  },
  "id": {
    "profileAvatarMode": "Mode avatar",
    "profileAvatarModeSubtitle": "Bicara dengan Celia layar penuh",
    "avatarModeReady": "Siap",
    "avatarModeThinking": "Berpikir…",
    "avatarModeSpeaking": "Berbicara…",
    "avatarModeHoldToTalk": "Tahan untuk berbicara",
    "avatarModeExit": "Mode manual",
    "avatarModeConfirmTitle": "Konfirmasi dengan Celia?",
    "avatarModeConfirmBody": "Celia ingin menyimpan sesuatu. Izinkan?",
    "avatarModeConfirmYes": "Izinkan",
  },
  "vi": {
    "profileAvatarMode": "Chế độ avatar",
    "profileAvatarModeSubtitle": "Nói với Celia toàn màn hình",
    "avatarModeReady": "Sẵn sàng",
    "avatarModeThinking": "Đang nghĩ…",
    "avatarModeSpeaking": "Đang nói…",
    "avatarModeHoldToTalk": "Giữ để nói",
    "avatarModeExit": "Chế độ thủ công",
    "avatarModeConfirmTitle": "Xác nhận với Celia?",
    "avatarModeConfirmBody": "Celia muốn lưu nội dung. Cho phép?",
    "avatarModeConfirmYes": "Cho phép",
  },
  "th": {
    "profileAvatarMode": "โหมดอวาตาร์",
    "profileAvatarModeSubtitle": "คุยกับ Celia แบบเต็มจอ",
    "avatarModeReady": "พร้อม",
    "avatarModeThinking": "กำลังคิด…",
    "avatarModeSpeaking": "กำลังพูด…",
    "avatarModeHoldToTalk": "กดค้างเพื่อพูด",
    "avatarModeExit": "โหมดธรรมดา",
    "avatarModeConfirmTitle": "ยืนยันกับ Celia?",
    "avatarModeConfirmBody": "Celia ต้องการบันทึกบางอย่าง อนุญาตไหม?",
    "avatarModeConfirmYes": "อนุญาต",
  },
}

root = pathlib.Path("lib/l10n")
chat_avatar_line = re.compile(r'^\s*"chatAvatar[^"]*"\s*:.*$', re.M)
chat_avatar_meta = re.compile(r'^\s*"@chatAvatarSemantics"\s*:.*$', re.M)

for lang, vals in translations.items():
    path = root / f"app_{lang}.arb"
    text = path.read_text(encoding="utf-8")
    text = chat_avatar_line.sub("", text)
    text = chat_avatar_meta.sub("", text)
    # Fix possible trailing commas before closing brace after deletions
    text = re.sub(r",(\s*})", r"\1", text)
    data = json.loads(text)
    for key, value in vals.items():
        data[key] = value
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("ok", lang)

en = root / "app_en.arb"
etext = en.read_text(encoding="utf-8")
etext = chat_avatar_line.sub("", etext)
etext = chat_avatar_meta.sub("", etext)
etext = re.sub(r",(\s*})", r"\1", etext)
data = json.loads(etext)
# Ensure English avatar keys exist (may already)
en_defaults = {
    "profileAvatarMode": "Avatar Mode",
    "profileAvatarModeSubtitle": "Talk to Celia full-screen, hands-free",
    "avatarModeReady": "Ready",
    "avatarModeThinking": "Thinking…",
    "avatarModeSpeaking": "Speaking…",
    "avatarModeHoldToTalk": "Hold to talk",
    "avatarModeExit": "Manual mode",
    "avatarModeConfirmTitle": "Confirm with Celia?",
    "avatarModeConfirmBody": "Celia wants to save something. Allow it?",
    "avatarModeConfirmYes": "Allow",
}
for key, value in en_defaults.items():
    data.setdefault(key, value)
en.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("ok en")
