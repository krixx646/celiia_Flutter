import { FOOD_DATABASE, type FoodReference } from './foodDatabase';

export type GroundableFoodItem = {
  name: string;
  servingGrams: number;
  calories: number;
  proteinGrams: number;
  carbsGrams: number;
  fatGrams: number;
  confidence: number;
  notes?: string;
  box?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
};

export type GroundableMealAnalysis<T extends GroundableFoodItem> = {
  title: string;
  provider: string;
  summary: string;
  confidence: number;
  totalCalories: number;
  totalProteinGrams: number;
  totalCarbsGrams: number;
  totalFatGrams: number;
  items: T[];
  warnings: string[];
};

function normalizeFoodName(name: string): string {
  return name
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function round1(n: number): number {
  return Math.round(n * 10) / 10;
}

/** Exact alias first, then longest alias contained in the name. */
export function findFoodReference(name: string): FoodReference | null {
  const normalized = normalizeFoodName(name);
  if (!normalized) return null;

  for (const food of FOOD_DATABASE) {
    for (const alias of food.aliases) {
      if (normalized === alias) return food;
    }
  }

  let best: { food: FoodReference; aliasLen: number } | null = null;
  for (const food of FOOD_DATABASE) {
    for (const alias of food.aliases) {
      if (alias.length < 3) continue;
      if (normalized.includes(alias) || alias.includes(normalized)) {
        if (!best || alias.length > best.aliasLen) {
          best = { food, aliasLen: alias.length };
        }
      }
    }
  }
  return best?.food ?? null;
}

function scaleFromReference(food: FoodReference, servingGrams: number) {
  const factor = servingGrams / 100;
  return {
    calories: Math.round(food.caloriesPer100g * factor),
    proteinGrams: round1(food.proteinPer100g * factor),
    carbsGrams: round1(food.carbsPer100g * factor),
    fatGrams: round1(food.fatPer100g * factor),
  };
}

/**
 * After vision identifies items, replace macros with DB values when a match
 * exists. Unmatched items (incl. brand packages) keep AI estimates.
 */
export function groundMealAnalysis<T extends GroundableFoodItem>(
  analysis: GroundableMealAnalysis<T>
): GroundableMealAnalysis<T> {
  let groundedCount = 0;

  const items = analysis.items.map((item) => {
    if (!(item.servingGrams > 0)) return item;
    const ref = findFoodReference(item.name);
    if (!ref) return item;

    groundedCount += 1;
    const macros = scaleFromReference(ref, item.servingGrams);
    const noteParts = [
      item.notes?.trim(),
      `Macros grounded from nutrition reference (${ref.id}).`,
    ].filter(Boolean);

    return {
      ...item,
      ...macros,
      confidence: Math.min(1, Math.max(item.confidence, 0.55) + 0.05),
      notes: noteParts.join(' '),
    };
  });

  const totals = items.reduce(
    (acc, item) => ({
      calories: acc.calories + item.calories,
      protein: acc.protein + item.proteinGrams,
      carbs: acc.carbs + item.carbsGrams,
      fat: acc.fat + item.fatGrams,
    }),
    { calories: 0, protein: 0, carbs: 0, fat: 0 }
  );

  const warnings = [...analysis.warnings];
  if (groundedCount > 0) {
    const msg =
      groundedCount === items.length
        ? 'Macros matched to Celia nutrition reference where possible.'
        : `${groundedCount}/${items.length} items matched to nutrition reference; others keep AI estimates.`;
    if (!warnings.includes(msg)) warnings.unshift(msg);
  }

  const avgItemConfidence =
    items.length > 0
      ? items.reduce((sum, item) => sum + item.confidence, 0) / items.length
      : analysis.confidence;

  return {
    ...analysis,
    confidence: Math.min(1, Math.max(analysis.confidence, avgItemConfidence)),
    totalCalories: Math.round(totals.calories),
    totalProteinGrams: round1(totals.protein),
    totalCarbsGrams: round1(totals.carbs),
    totalFatGrams: round1(totals.fat),
    items,
    warnings,
  };
}
