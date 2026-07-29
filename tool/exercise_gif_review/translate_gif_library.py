"""
Scans the client's purchased stock GIF exercise pack (Portuguese filenames),
translates + categorizes every usable file into English, and writes two
review files:

  1. exercise_gif_catalog_en.csv
     Full machine-readable catalog (every usable file), fully in English,
     ready to become the seed data for the `exercise_media` Supabase table.

  2. NEEDS_YOUR_INPUT.md
     A short, plain-English list of only the ambiguous items that need a
     human decision (yes/no or a corrected name). Everything else was
     translated with high confidence and does not need review.

Nothing in this script touches Supabase, the app, or any production data.
It only reads local files on disk and writes two review files locally.

Usage:
    python translate_gif_library.py
"""

from __future__ import annotations

import csv
import os
import re
import unicodedata
from dataclasses import dataclass, field

# ---------------------------------------------------------------------------
# Configuration: source pack location + which folders are actually usable.
# ---------------------------------------------------------------------------

PACK_ROOT = r"C:\Users\ADMIN\Desktop\gif exercises\BIBLIOTECA DE EJERCICIOS"

OUTPUT_DIR = os.path.join(os.path.dirname(__file__))
CATALOG_CSV = os.path.join(OUTPUT_DIR, "exercise_gif_catalog_en.csv")
NEEDS_INPUT_MD = os.path.join(OUTPUT_DIR, "NEEDS_YOUR_INPUT.md")

# Folder -> (category, muscle_group_or_none). muscle_group=None means the
# folder itself doesn't imply a single muscle group (e.g. calisthenics/HIIT
# mix many muscle groups; the muscle group there is left blank).
MUSCULACION_DIR = "5\u00b0 GIFs DE MUSCULACI\u00d3N"
CALISTENIA_DIR = "6\u00b0 GIFs DE CALISTENIA"
FUNCIONAL_HIIT_DIR = "7\u00b0 GIFs DE ENTRENAMIENTO FUNCIONAL Y HIIT"
STRETCH_DIR = "8\u00b0 MANUAL DE ESTIRAMIENTO Y MOVILIDAD"

# Sub-folder (Spanish or Portuguese) -> English muscle group label.
MUSCLE_GROUP_MAP = {
    "abdomen core (1)": "core_abs",
    "b\u00edceps y antebrazo (1)": "biceps_forearms",
    "deltoides (1)": "shoulders",
    "espalda y trapecio (1)": "back_traps",
    "miembros inferiores y gl\u00fateos (1)": "legs_glutes",
    "pantorrilla (1)": "calves",
    "pectoral (1)": "chest",
    "tr\u00edceps (1)": "triceps",
    # Bonus sub-set inside "GIFs - BONOS (1)", folder names in Portuguese.
    "abdominal": "core_abs",
    "anteboaco": "biceps_forearms",  # defensive, unlikely
    "antebra\u00e7o": "biceps_forearms",
    "b\u00edceps": "biceps_forearms",
    "costas": "back_traps",
    "membros inferiores": "legs_glutes",
    "ombro": "shoulders",
    "peito": "chest",
    "trap\u00e9zio": "back_traps",
    "tr\u00edceps": "triceps",
}

# Directory names to skip entirely (accidental duplicate Italian re-export of
# the whole pack, nested by mistake inside the Musculaci\u00f3n folder).
EXCLUDE_DIR_NAMES = {
    "biblioteca di esercizi",
}

# ---------------------------------------------------------------------------
# Portuguese -> English fitness vocabulary.
# Longer phrases are matched before single words so compound terms translate
# as a unit (e.g. "peso corporal" -> "bodyweight", not "weight body").
# ---------------------------------------------------------------------------

PHRASE_TRANSLATIONS: list[tuple[str, str]] = [
    ("peso corporal", "bodyweight"),
    ("faixa el\u00e1stica", "resistance band"),
    ("bola de exerc\u00edcio", "stability ball"),
    ("bola de rea\u00e7\u00e3o", "reaction ball"),
    ("medicina bola", "medicine ball"),
    ("bola bosu", "bosu ball"),
    ("rolo de espuma", "foam roller"),
    ("cabe\u00e7a para baixo", "head down"),
    ("por tr\u00e1s do pesco\u00e7o", "behind the neck"),
    ("ao ar livre", "outdoor"),
    ("sem pesos", "unweighted"),
    ("sem peso", "unweighted"),
    ("com peso", "weighted"),
    ("com salto", "with jump"),
    ("com giro", "with rotation"),
    ("na parede", "against wall"),
    ("em p\u00e9", "standing"),
    ("em cima", "on top"),
    ("deitado de lado", "lying on side"),
    ("dec\u00fabito lateral", "side-lying"),
    ("pernas afastadas", "legs apart"),
    ("uma perna esticada", "one leg extended"),
    ("joelho alto", "high knee"),
    ("joelho elevado", "raised knee"),
    ("eleva\u00e7\u00e3o dos joelhos", "knee raise"),
    ("toque no calcanhar", "heel touch"),
    ("descida do calcanhar", "heel drop"),
    ("levantamento de tronco", "trunk raise"),
    ("pegada fechada", "close grip"),
    ("pegada neutra", "neutral grip"),
    ("pegada supinada", "supinated grip"),
    ("pegada invertida", "reverse grip"),
    ("bra\u00e7os alternados", "alternating arms"),
    ("apoio em caixa", "box support"),
    ("na caixa", "on box"),
    ("no banco", "on bench"),
    ("com apoio", "with support"),
    ("frontal de rack", "front rack position"),
    ("dividido profundo", "deep split"),
    ("unilateral cruzado", "unilateral crossed"),
    ("chute lateral", "side kick"),
    ("adutor maior", "adductor magnus"),
    ("ombro reverso", "reverse shoulder"),
    ("parte superior das costas", "upper back"),
    ("levantamento terra", "deadlift"),
    ("rosca direta", "biceps curl"),
    ("rosca alternada", "alternating curl"),
    ("rosca martelo", "hammer curl"),
    ("rosca scott", "preacher curl"),
    ("elevacao lateral", "lateral raise"),
    ("elevacao frontal", "front raise"),
    ("puxada frontal", "lat pulldown"),
    ("puxada alta", "high pulldown"),
    ("remada baixa", "seated cable row"),
    ("remada curvada", "bent-over row"),
    ("remada unilateral", "single-arm row"),
    ("supino reto", "flat bench press"),
    ("supino inclinado", "incline bench press"),
    ("supino declinado", "decline bench press"),
    ("crucifixo reto", "flat bench fly"),
    ("crucifixo inclinado", "incline bench fly"),
    ("panturrilha em pe", "standing calf raise"),
    ("panturrilha sentado", "seated calf raise"),
    ("extensao de perna", "leg extension"),
    ("flexao de perna", "leg curl"),
    ("flexao de braco", "push-up"),
    ("mesa flexora", "leg curl machine"),
    ("cadeira extensora", "leg extension machine"),
    ("cadeira flexora", "leg curl machine"),
    ("cadeira adutora", "hip adductor machine"),
    ("cadeira abdutora", "hip abductor machine"),
    ("banco romano", "roman chair"),
    ("barra paralela", "parallel bars"),
    ("barras paralelas", "parallel bars"),
]

WORD_TRANSLATIONS: dict[str, str] = {
    "afundo": "lunge",
    "avan\u00e7o": "lunge",
    "agachamento": "squat",
    "b\u00falgaro": "bulgarian",
    "camar\u00e3o": "shrimp",
    "sustenta\u00e7\u00e3o": "hold",
    "eleva\u00e7\u00e3o": "raise",
    "panturrilha": "calf",
    "panturrilhas": "calves",
    "havaiano": "hawaiian",
    "banco": "bench",
    "apoiado": "supported",
    "apoiada": "supported",
    "caixa": "box",
    "ajoelhado": "kneeling",
    "ajoelhada": "kneeling",
    "sum\u00f4": "sumo",
    "sumo": "sumo",
    "alongamento": "stretch",
    "peitoral": "chest",
    "peito": "chest",
    "reverso": "reverse",
    "reversa": "reverse",
    "pato": "duck",
    "andar": "walk",
    "barra": "bar",
    "fixa": "pull-up",
    "assistida": "assisted",
    "assistido": "assisted",
    "arco": "arch",
    "gyro": "spin",
    "giro": "spin",
    "pegada": "grip",
    "fechada": "closed",
    "fechado": "closed",
    "invertida": "reversed",
    "invertido": "reversed",
    "neutra": "neutral",
    "neutro": "neutral",
    "supinada": "supinated",
    "supinado": "supinated",
    "peso": "weight",
    "pesos": "weights",
    "salto": "jump",
    "cabe\u00e7a": "head",
    "baixo": "down",
    "braquial": "brachialis",
    "abdu\u00e7\u00e3o": "abduction",
    "adu\u00e7\u00e3o": "adduction",
    "quadril": "hip",
    "lateral": "lateral",
    "sentado": "seated",
    "sentada": "seated",
    "ombro": "shoulder",
    "ombros": "shoulders",
    "chute": "kick",
    "calcanhar": "heel",
    "joelho": "knee",
    "joelhos": "knees",
    "elevado": "raised",
    "elevada": "raised",
    "parede": "wall",
    "bola": "ball",
    "exerc\u00edcio": "exercise",
    "cossaco": "cossack",
    "profundo": "deep",
    "profunda": "deep",
    "dividido": "split",
    "unilateral": "unilateral",
    "cruzado": "crossed",
    "cruzada": "crossed",
    "bicicleta": "bicycle",
    "livre": "free",
    "arremesso": "throw",
    "medicina": "medicine",
    "levantamento": "raise",
    "tronco": "trunk",
    "caminhada": "walking",
    "balan\u00e7o": "swing",
    "abra\u00e7os": "hugs",
    "abra\u00e7o": "hug",
    "adutor": "adductor",
    "adutores": "adductors",
    "maior": "major",
    "borboleta": "butterfly",
    "esfinge": "sphinx",
    "descida": "drop",
    "rolo": "roller",
    "espuma": "foam",
    "pernas": "legs",
    "perna": "leg",
    "afastadas": "apart",
    "gl\u00fateos": "glutes",
    "gluteos": "glutes",
    "deitado": "lying",
    "deitada": "lying",
    "isquiotibiais": "hamstrings",
    "bra\u00e7o": "arm",
    "bra\u00e7os": "arms",
    "corda": "rope",
    "esticada": "extended",
    "esticado": "extended",
    "uma": "one",
    "um": "one",
    "com": "with",
    "sem": "without",
    "no": "on",
    "na": "on",
    "nos": "on",
    "nas": "on",
    "de": "of",
    "do": "of the",
    "da": "of the",
    "das": "of the",
    "dos": "of the",
    "e": "and",
    "para": "for",
    "costas": "back",
    "trap\u00e9zio": "trapezius",
    "antebra\u00e7o": "forearm",
    "b\u00edceps": "biceps",
    "tr\u00edceps": "triceps",
    "abdominal": "abdominal",
    "membros": "limbs",
    "inferiores": "lower",
    "superior": "upper",
    "superiores": "upper",
    "flexao": "flexion",
    "flexoes": "flexions",
    "remada": "row",
    "halteres": "dumbbells",
    "halter": "dumbbell",
    "supino": "bench press",
    "rotacao": "rotation",
    "maquina": "machine",
    "crucifixo": "fly",
    "desenvolvimento": "shoulder press",
    "cabo": "cable",
    "inclinado": "incline",
    "inclinada": "incline",
    "inclinacao": "incline",
    "alta": "high",
    "alto": "high",
    "altos": "high",
    "frontal": "front",
    "puxada": "pulldown",
    "aberta": "wide",
    "resistencia": "resistance",
    "extensao": "extension",
    "pes": "feet",
    "pe": "foot",
    "apoio": "support",
    "faixa": "band",
    "declinado": "decline",
    "declinada": "decline",
    "polia": "pulley",
    "frente": "front",
    "externa": "external",
    "pronada": "pronated",
    "corrida": "running",
    "tras": "behind",
    "baixa": "low",
    "baixa1": "low",
    "elastico": "elastic",
    "dedos": "toes",
    "medicinal": "medicine",
    "postura": "posture",
    "nuca": "neck",
    "interna": "internal",
    "reto": "straight",
    "cotovelo": "elbow",
    "encolhimento": "shrug",
    "toque": "touch",
    "estabilidade": "stability",
    "ponte": "bridge",
    "rosca": "curl",
    "coice": "kickback",
    "banda": "band",
    "posicao": "position",
    "alternado": "alternating",
    "alternada": "alternating",
    "alternando": "alternating",
    "obliquo": "oblique",
    "prancha": "plank",
    "curvada": "bent-over",
    "curvado": "bent-over",
    "inverso": "reverse",
    "inversa": "reverse",
    "pelvica": "pelvic",
    "paralelas": "parallel bars",
    "paralela": "parallel bar",
    "gluteo": "glute",
    "posterior": "posterior",
    "rolamento": "roll",
    "saltos": "jumps",
    "completo": "full",
    "completa": "full",
    "flexionados": "bent",
    "flexionado": "bent",
    "punho": "wrist",
    "cadeira": "chair",
    "passada": "stride",
    "toalha": "towel",
    "exercicios": "exercises",
    "passo": "step",
    "passos": "steps",
    "quadriceps": "quadriceps",
    "rolinho": "ab wheel",
    "carga": "load",
    "tesoura": "scissor",
    "escalador": "mountain climber",
    "mao": "hand",
    "graviton": "gravitron",
    "triangulo": "triangle",
    "remanda": "row",
    "voador": "fly machine",
    "adutora": "adductor",
    "plantar": "plantar",
    "mesa": "table",
    "dorsal": "lat",
    "pivo": "pivot",
    "hindu": "hindu",
    "mergulho": "dip",
    "escapular": "scapular",
    "corpo": "body",
    "direita": "right",
    "esquerda": "left",
    "sapo": "frog",
    "exercicio": "exercise",
    "acima": "overhead",
    "flexores": "flexors",
    "circulos": "circles",
    "tocando": "touching",
    "elevadas": "raised",
    "elevados": "raised",
    "infra": "lower",
    "extendidas": "extended",
    "extendidos": "extended",
    "diagonal": "diagonal",
    "inverto": "inverted",
    "invertidos": "inverted",
    "serrote": "saw",
    "concentrado": "concentration",
    "estendidos": "extended",
    "estendida": "extended",
    "romano": "roman",
    "hiperextensao": "hyperextension",
    "costa": "back",
    "articulada": "articulated",
    "unil": "unilateral",
    "tracao": "pull",
    "afastados": "apart",
    "bicleta": "bicycle",
    "abducao": "abduction",
    "pegando": "holding",
    "em": "in",
    "por": "for",
    "atras": "behind",
    "cross": "cross",
    "smith": "smith machine",
    "stiff": "stiff-leg",
    "flex": "flex",
    "retrocesso": "reverse",
    "smth": "smith machine",
    "medball": "medicine ball",
    "bilateral": "bilateral",
    "crossover": "crossover",
    "suica": "swiss",
    "articulado": "articulated",
    "articulada": "articulated",
    "palmas": "clap",
    "parada": "handstand",
    "escapula": "scapula",
    "cotovelos": "elbows",
    "diamante": "diamond",
    "decubito": "lying",
    "entre": "between",
    "cadeiras": "chairs",
    "modificada": "modified",
    "modificado": "modified",
    "porta": "doorway",
    "distancia": "distance",
    "boxe": "boxing",
    "gancho": "hook",
    "chutes": "kicks",
    "ate": "to",
    "flexionada": "bent",
    "deltoides": "deltoids",
    "militar": "military",
    "reta": "straight",
    "escada": "ladder",
    "agilidade": "agility",
    "cobra": "cobra",
    "lancamento": "throw",
    "quatro": "four",
    "apoios": "supports",
    "pulos": "jumps",
    "quadrupede": "quadruped",
    "contralateral": "contralateral",
    "frances": "french",
    "coluna": "spine",
    "parte": "part",
    "piriforme": "piriformis",
    "abertas": "open",
    "coxa": "thigh",
    "retracao": "retraction",
    "graus": "degrees",
    "curto": "short",
    "isometrico": "isometric",
    "isometrica": "isometric",
    "remador": "rower",
    "dinamica": "dynamic",
    "arnol": "arnold",
    "arnolda": "arnold",
    "femino": "female",
    "juntas": "joints",
    "uni": "unilateral",
    "tradicional": "traditional",
    "gravitan": "gravitron",
    "dispositivo": "device",
    "puxador": "pulldown bar",
    "pega": "grip",
    "pegaga": "grip",
    "fechda": "closed",
    "beixa": "low",
    "haltres": "dumbbells",
    "inclinda": "incline",
    "hiperextensoes": "hyperextensions",
    "abd": "abs",
    "maqina": "machine",
    "crcifixo": "fly",
    "pulldown1": "pulldown",
    "flog": "flow",
    "desenvolmento": "shoulder press",
    "desnvolvimento": "shoulder press",
    "supinda": "bench press",
    "supindo": "bench press",
    "remo": "row",
    "juntos": "together",
    "terra": "ground",
    "tarra": "ground",
    "terrra": "ground",
    "lado": "side",
    "panturrinha": "calf",
    "kettibel": "kettlebell",
    "pegda": "grip",
    "letaral": "lateral",
    "leteral": "lateral",
    "haltrers": "dumbbells",
    "beixo": "low",
    "croos": "cross",
    "aberto": "open",
    "utilizando": "using",
    "barrapegada": "bar grip",
    "smit": "smith machine",
    "incliado": "incline",
    "incliando": "incline",
    "aparelho": "machine",
    "vertical": "vertical",
    "gemeos": "calves",
    "soleo": "soleus",
    "batendo": "clapping",
    "peck": "pec",
    "crucifico": "fly",
    "instabilidade": "instability",
    "canadense": "canadian",
    "bandeira": "flag",
    "humana": "human",
    "elevacoes": "raises",
    "barras": "bars",
    "cruzamento": "crossover",
    "maos": "hands",
    "arqueamento": "arching",
    "queda": "drop",
    "sobrecarga": "overload",
    "coreano": "korean",
    "mergulhos": "dips",
    "chao": "floor",
    "argola": "gymnastic ring",
    "argolas": "gymnastic rings",
    "pulo": "jump",
    "impulso": "impulse",
    "concentrada": "concentrated",
    "suspensao": "suspension",
    "passiva": "passive",
    "sobre": "over",
    "lancada": "throw",
    "cima": "up",
    "bom": "good",
    "dia": "morning",
    "sombra": "shadow",
    "caminhar": "walking",
    "boxeador": "boxer",
    "alternados": "alternating",
    "burro": "donkey",
    "batalha": "battle",
    "rapidos": "fast",
    "curtos": "short",
    "assistencia": "assistance",
    "estacionaria": "stationary",
    "latera": "lateral",
    "cruz": "cross",
    "ferro": "iron",
    "copia": "copy",
    "oposto": "opposite",
    "unica": "single",
    "equilibrio": "balance",
    "estilo": "style",
    "montanha": "mountain",
    "esquiador": "skier",
    "pliometrico": "plyometric",
    "pliometricos": "plyometric",
    "marcas": "marks",
    "faixas": "bands",
    "elasticas": "elastic",
    "contra": "against",
    "minhoca": "inchworm",
    "nave": "ship",
    "passagem": "passage",
    "esqui": "ski",
    "velocidade": "speed",
    "patinador": "skater",
    "polichinelo": "jumping jack",
    "polichinelos": "jumping jacks",
    "levantada": "raised",
    "pular": "jump",
    "abertura": "opening",
    "puxar": "pull",
    "rastejo": "crawl",
    "urso": "bear",
    "afastada": "apart",
    "garrafa": "bottle",
    "agua": "water",
    "afastamento": "spread",
    "zigue-zague": "zigzag",
    "potentes": "powerful",
    "soco": "punch",
    "direto": "direct",
    "socos": "punches",
    "subida": "climb",
    "torcoes": "twists",
    "testa": "forehead",
    "tapinhas": "taps",
    "agachado": "squatting",
    "largo": "wide",
    "estatica": "static",
    "duplo": "double",
    "dinamico": "dynamic",
    "desviador": "deflector",
    "ulnar": "ulnar",
    "extensor": "extensor",
    "gastrocnemio": "gastrocnemius",
    "manguito": "rotator cuff",
    "rotador": "rotator",
    "tendao": "tendon",
    "aquiles": "achilles",
    "tibial": "tibial",
    "trato": "tract",
    "iliotibial": "iliotibial",
    "extensores": "extensors",
    "latissimos": "lats",
    "dorsais": "back",
    "punhos": "wrists",
    "canto": "corner",
    "pulso": "wrist",
    "alongamentos": "stretches",
    "tornozelos": "ankles",
    "cavalinho": "seated machine",
    "cavalinha": "seated machine",
    "cavalindo": "seated machine",
    "cavalino": "seated machine",
    "bebe": "baby",
    "feliz": "happy",
    "peixe": "fish",
    "virilha": "groin",
    "espinhal": "spinal",
    "toracica": "thoracic",
    "romboides": "rhomboids",
    "fascite": "fasciitis",
    "tornozelo": "ankle",
    "catavento": "pinwheel",
    "bailarina": "ballerina",
    "deslize": "slide",
    "serratil": "serratus",
    "contracao": "contraction",
    "dorsiflexao": "dorsiflexion",
    "oscilante": "oscillating",
    "meio": "half",
    "pendulo": "pendulum",
    "protracao": "protraction",
    "rolagem": "rolling",
    "rolando": "rolling",
    "toques": "taps",
    "torcao": "twist",
    "obliqua": "oblique",
    "corporal": "body",
    "nvertido": "inverted",
    "haltere": "dumbbell",
    "deltoide": "deltoid",
    "como": "like",
    "rapida": "fast",
    "ra": "row",
}

# Short function words that add no meaning and should be silently dropped
# instead of flagged for review (accent-stripped form).
SKIP_WORDS = {"a", "o", "os", "as"}

# Proper nouns / equipment names kept as-is (do not flag these as unknown).
KEEP_AS_IS = {
    "trx", "pvc", "l-sit", "gymstick", "bosu", "goblet", "kettlebell",
    "skater", "sissy", "pistol", "pistola", "back", "lever", "drill",
    "balloon", "human", "flag",
}

# A number of source filenames are already written in English, usually as
# hyphenated compound terms (e.g. "single-arm-dumbbell-row",
# "close-grip-lat-pulldown"). Any hyphenated token where every part is in
# this whitelist (or already a translated Portuguese word) is treated as
# already-resolved English rather than flagged for review.
ENGLISH_GYM_WORDS = {
    "press", "pull", "push", "row", "curl", "raise", "raises", "extension",
    "machine", "cable", "dumbbell", "barbell", "band", "banded", "grip",
    "wide", "close", "seated", "standing", "single", "arm", "back", "front",
    "rear", "face", "lat", "pulldown", "pulldowns", "chin", "chinup", "chinups",
    "ups", "up", "dip", "dips", "plank", "crunch", "crunches", "twist", "twists",
    "mountain", "climber", "climbers", "jumping", "jack", "jacks", "bicycle",
    "superman", "cobra", "bridge", "hip", "thrust", "lunge", "lunges", "squat",
    "squats", "deadlift", "bench", "incline", "decline", "flat", "fly", "flys",
    "flyes", "shrug", "shrugs", "kickback", "kickbacks", "overhead", "military",
    "landmine", "jefferson", "eccentric", "assisted", "reverse", "neutral",
    "pronated", "supinated", "wall", "floor", "box", "step", "jump", "jumps",
    "knee", "knees", "leg", "legs", "calf", "calves", "glute", "glutes", "core",
    "oblique", "obliques", "side", "attachment", "standard", "bar", "muscles",
    "muscle", "sit", "situp", "situps", "russian", "dragon", "hanging", "floor",
    "weighted", "conventional", "solo", "dead", "bug", "arnold", "swiss", "ball",
    "v", "t", "y", "w", "one", "two", "handed", "alternating", "elbow", "row",
    "renegade", "pushup", "pushups", "facepull", "pullover", "pec", "deck",
    "abs", "pulley", "over", "horizontal", "medicine", "throw", "rotational",
    "swimming", "burpee", "burpees", "planche", "seal", "jab", "snap",
    "sprint", "cardio", "plyometric", "feet", "chest", "donkey", "negative",
    "high", "low", "cross", "cable", "chin-up", "chinup", "with", "plus",
    "drop", "jerk", "pin", "delt", "yates", "deficit", "pike", "bars",
}


def strip_accents(text: str) -> str:
    normalized = unicodedata.normalize("NFKD", text)
    return "".join(c for c in normalized if not unicodedata.combining(c))


# Normalize dictionary keys once, up front, since incoming tokens are always
# accent-stripped before lookup (e.g. "eleva\u00e7\u00e3o" -> "elevacao").
WORD_TRANSLATIONS = {
    strip_accents(key): value for key, value in WORD_TRANSLATIONS.items()
}


def slugify(text: str) -> str:
    text = strip_accents(text).lower()
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return re.sub(r"-{2,}", "-", text)


@dataclass
class CatalogEntry:
    slug: str
    display_name_en: str
    muscle_group: str
    category: str
    confidence: str
    source_folder_en: str
    source_filename_reference_only: str
    source_abs_path: str
    is_duplicate_slug: bool = False
    unresolved_terms: list[str] = field(default_factory=list)


def translate_name(raw_name: str) -> tuple[str, list[str]]:
    """Translate a Portuguese exercise phrase to English.

    Returns (english_phrase, unresolved_terms). unresolved_terms is empty
    when every word was confidently translated or recognized as a proper
    noun/equipment name.
    """
    name = raw_name.strip()
    lowered = strip_accents(name.lower())

    # Apply multi-word (and single-word) phrases first, on accent-stripped
    # lowercase text. Wrapped in \x01 markers (with \x02 standing in for
    # internal spaces) so the resulting token is recognized as *already
    # resolved* below, whether it's one word ("bodyweight") or several
    # ("close grip") — this must not depend on the output containing a space.
    working = lowered
    for pt_phrase, en_phrase in sorted(
        PHRASE_TRANSLATIONS, key=lambda pair: -len(pair[0])
    ):
        pt_key = strip_accents(pt_phrase)
        marker = f"\x01{en_phrase.replace(' ', chr(2))}\x01"
        working = re.sub(rf"\b{re.escape(pt_key)}\b", f" {marker} ", working)

    tokens = [t for t in re.split(r"[\s]+", working) if t]
    translated_tokens: list[str] = []
    unresolved: list[str] = []

    for token in tokens:
        if token.startswith("\x01") and token.endswith("\x01"):
            # Already-translated phrase from the pass above; fully resolved.
            translated_tokens.append(token.strip("\x01").replace(chr(2), " "))
            continue
        clean = token.strip("().,")
        if not clean:
            continue
        key = strip_accents(clean.lower())
        if key in SKIP_WORDS:
            continue

        if "-" in key and key not in KEEP_AS_IS:
            # Already-English hyphenated compound term, e.g.
            # "single-arm-dumbbell-row". Resolved only if every part is a
            # recognized English gym word (or digit); otherwise fall through
            # to per-part translation below.
            parts = [p for p in key.split("-") if p]
            if parts and all(
                p in ENGLISH_GYM_WORDS or p.isdigit() for p in parts
            ):
                translated_tokens.append(clean.replace("-", " "))
                continue

        if key in WORD_TRANSLATIONS:
            translated_tokens.append(WORD_TRANSLATIONS[key])
        elif key in KEEP_AS_IS or key in ENGLISH_GYM_WORDS:
            translated_tokens.append(clean)
        elif key.isdigit():
            translated_tokens.append(clean)
        else:
            # Unknown token: keep the original word but flag for review.
            translated_tokens.append(clean)
            unresolved.append(clean)

    english = " ".join(translated_tokens)
    english = re.sub(r"\s{2,}", " ", english).strip()
    english = english[:1].upper() + english[1:] if english else raw_name
    return english, unresolved


def iter_source_files():
    """Yield (absolute_path, category, muscle_group, source_folder_en) for
    every usable file in the pack, skipping excluded/duplicate folders."""

    # 1) Musculaci\u00f3n: top-level muscle-group folders + the nested bonus set.
    musculacion_path = os.path.join(PACK_ROOT, MUSCULACION_DIR)
    for dirpath, dirnames, filenames in os.walk(musculacion_path):
        dirnames[:] = [
            d for d in dirnames if strip_accents(d.lower()) not in EXCLUDE_DIR_NAMES
        ]
        rel_folder = os.path.relpath(dirpath, musculacion_path)
        folder_key = strip_accents(os.path.basename(dirpath).lower())
        # Bonus subfolders carry a trailing item count, e.g. "Costas (55)".
        folder_key_no_count = re.sub(r"\s*\(\d+\)\s*$", "", folder_key).strip()
        muscle_group = MUSCLE_GROUP_MAP.get(folder_key) or MUSCLE_GROUP_MAP.get(
            folder_key_no_count, ""
        )
        for filename in filenames:
            if not filename.lower().endswith(".gif"):
                continue
            if not muscle_group:
                # Skip files sitting directly in the root of the musculacion
                # folder or in unrecognized folders (shouldn't normally occur).
                continue
            yield (
                os.path.join(dirpath, filename),
                "strength",
                muscle_group,
                f"Strength / {muscle_group.replace('_', ' ').title()} ({rel_folder})",
            )

    # 2) Calisthenics.
    calistenia_path = os.path.join(PACK_ROOT, CALISTENIA_DIR)
    for filename in os.listdir(calistenia_path):
        if filename.lower().endswith(".gif"):
            yield (
                os.path.join(calistenia_path, filename),
                "calisthenics",
                "",
                "Calisthenics",
            )

    # 3) Functional / HIIT.
    hiit_path = os.path.join(PACK_ROOT, FUNCIONAL_HIIT_DIR)
    for filename in os.listdir(hiit_path):
        if filename.lower().endswith(".gif"):
            yield (
                os.path.join(hiit_path, filename),
                "functional_hiit",
                "",
                "Functional / HIIT",
            )

    # 4) Stretching & mobility (nested one level under the manual folder).
    stretch_root = os.path.join(PACK_ROOT, STRETCH_DIR)
    for dirpath, _dirnames, filenames in os.walk(stretch_root):
        for filename in filenames:
            if filename.lower().endswith(".gif"):
                yield (
                    os.path.join(dirpath, filename),
                    "stretching_mobility",
                    "",
                    "Stretching / Mobility",
                )


def build_catalog() -> list[CatalogEntry]:
    seen_slugs: dict[str, CatalogEntry] = {}
    entries: list[CatalogEntry] = []

    for abs_path, category, muscle_group, source_folder_en in iter_source_files():
        filename = os.path.basename(abs_path)
        raw_name = os.path.splitext(filename)[0]
        english_name, unresolved = translate_name(raw_name)
        slug = slugify(english_name)
        if not slug:
            continue

        is_dup = slug in seen_slugs
        confidence = "high" if not unresolved else "needs_review"

        entry = CatalogEntry(
            slug=slug,
            display_name_en=english_name,
            muscle_group=muscle_group,
            category=category,
            confidence=confidence,
            source_folder_en=source_folder_en,
            source_filename_reference_only=filename,
            source_abs_path=abs_path,
            is_duplicate_slug=is_dup,
            unresolved_terms=unresolved,
        )
        entries.append(entry)
        if not is_dup:
            seen_slugs[slug] = entry

    return entries


def write_catalog_csv(entries: list[CatalogEntry]) -> None:
    with open(CATALOG_CSV, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(
            [
                "slug",
                "display_name_en",
                "category",
                "muscle_group",
                "confidence",
                "duplicate_of_existing_slug",
                "source_folder_en",
                "source_filename_reference_only",
                "unresolved_terms_debug",
                "source_abs_path",
            ]
        )
        for e in entries:
            writer.writerow(
                [
                    e.slug,
                    e.display_name_en,
                    e.category,
                    e.muscle_group,
                    e.confidence,
                    "yes" if e.is_duplicate_slug else "no",
                    e.source_folder_en,
                    e.source_filename_reference_only,
                    " ".join(e.unresolved_terms),
                    e.source_abs_path,
                ]
            )


def write_needs_input_md(entries: list[CatalogEntry]) -> None:
    flagged = [e for e in entries if e.confidence == "needs_review" and not e.is_duplicate_slug]
    unique_first_pass = [e for e in entries if not e.is_duplicate_slug]

    with open(NEEDS_INPUT_MD, "w", encoding="utf-8") as f:
        f.write("# Exercise GIF Review — Needs Your Input\n\n")
        f.write(
            "Everything below is in English. You do not need to read or "
            "understand any Portuguese to use this file.\n\n"
        )
        f.write(
            f"- Total usable exercise GIFs found: **{len(entries)}**\n"
            f"- Unique exercises (after removing duplicates): **{len(unique_first_pass)}**\n"
            f"- Auto-translated with high confidence (no action needed): "
            f"**{len(unique_first_pass) - len(flagged)}**\n"
            f"- Flagged for your review: **{len(flagged)}**\n\n"
        )
        f.write("## How to use this list\n\n")
        f.write(
            "For each row, the **My Best Guess** column is what I translated "
            "the exercise name to. If it looks correct, you don't need to do "
            "anything. If it looks wrong or confusing, just reply with the "
            "correct English exercise name for that row (you can reference the "
            "row number).\n\n"
        )
        f.write("| # | My Best Guess (English) | Category | Muscle Group |\n")
        f.write("|---|---|---|---|\n")
        for i, e in enumerate(flagged, start=1):
            muscle = e.muscle_group.replace("_", " ").title() if e.muscle_group else "-"
            category = e.category.replace("_", " ").title()
            f.write(f"| {i} | {e.display_name_en} | {category} | {muscle} |\n")


def main() -> None:
    entries = build_catalog()
    write_catalog_csv(entries)
    write_needs_input_md(entries)

    unique = [e for e in entries if not e.is_duplicate_slug]
    flagged = [e for e in unique if e.confidence == "needs_review"]

    print(f"Scanned pack at: {PACK_ROOT}")
    print(f"Total usable GIF files found: {len(entries)}")
    print(f"Unique exercises (after de-duplication): {len(unique)}")
    print(f"High-confidence auto-translations: {len(unique) - len(flagged)}")
    print(f"Flagged for your review: {len(flagged)}")
    print()
    print(f"Full catalog written to: {CATALOG_CSV}")
    print(f"Review-only summary written to: {NEEDS_INPUT_MD}")


if __name__ == "__main__":
    main()
