/**
 * Sanity check for nutrition grounding.
 * Run: npx --yes tsx scripts/verify_meal_grounding.ts
 */
import {
  findFoodReference,
  groundMealAnalysis,
} from '../src/lib/nutrition/groundMealAnalysis';

const chicken = findFoodReference('Grilled Chicken Breast');
if (!chicken || chicken.id !== 'chicken_breast') {
  throw new Error('Expected chicken_breast match');
}

const analysis = groundMealAnalysis({
  title: 'Lunch',
  provider: 'openai',
  summary: 'test',
  confidence: 0.5,
  totalCalories: 999,
  totalProteinGrams: 0,
  totalCarbsGrams: 0,
  totalFatGrams: 0,
  items: [
    {
      name: 'Chicken breast',
      servingGrams: 100,
      calories: 400,
      proteinGrams: 10,
      carbsGrams: 10,
      fatGrams: 10,
      confidence: 0.5,
    },
    {
      name: 'Rare Brand Protein Bar XYZ',
      servingGrams: 60,
      calories: 210,
      proteinGrams: 20,
      carbsGrams: 15,
      fatGrams: 8,
      confidence: 0.42,
    },
  ],
  warnings: [],
});

if (analysis.items[0].calories !== 165) {
  throw new Error(`Expected grounded chicken calories 165, got ${analysis.items[0].calories}`);
}
if (analysis.items[1].calories !== 210) {
  throw new Error('Brand item should keep AI estimate');
}

console.log('OK');
