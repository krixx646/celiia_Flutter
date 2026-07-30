-- Make recording a completed workout actually work.
--
-- increment_routine_completion took a parameter named routine_id, and
-- user_routines has a column of the same name, so `WHERE id = routine_id` was
-- ambiguous and the function failed every time it was called:
--   42702 column reference "routine_id" is ambiguous
-- The app swallows the error (it only debugPrints), so a completed workout
-- silently never counted: times_completed stayed 0 and last_played_at stayed
-- null, which is what the streak, the workout total and the level are all
-- derived from.
--
-- The parameter is qualified with the function name rather than renamed, so the
-- signature the app calls stays exactly as it is.

create or replace function public.increment_routine_completion(routine_id uuid)
  returns void
  language plpgsql
  as $function$
begin
  update user_routines
  set
    times_completed = times_completed + 1,
    last_played_at = now()
  where user_routines.id = increment_routine_completion.routine_id;
end;
$function$;
