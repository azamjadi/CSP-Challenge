-- CSP Challenge: Anatomy & Imaging Fundamentals
-- Run in Supabase SQL Editor. Safe to run more than once.
-- Six introductory multiple-choice questions (one per subcategory).

with new_questions (subcategory, question, answer_a, answer_b, answer_c, answer_d, correct_answer, explanation) as (
 values
 ('X-ray & Fluoroscopy Interpretation',
  'In fluoroscopy, what does LAO stand for?',
  'Left anterior oblique','Left atrial orientation','Lateral anterior overview','Left apical offset',
  'A','LAO means left anterior oblique: an X-ray projection used to assess cardiac anatomy and lead position.'),
 ('Anatomical Terminology & Orientation',
  'In anatomical terminology, what does distal mean?',
  'Closer to the point of origin','Farther from the point of origin','Toward the midline','Toward the head',
  'B','Distal means farther from the origin or attachment point of a structure; proximal means closer.'),
 ('Cardiac Anatomy & Conduction System',
  'Which structure normally conducts electrical impulses from the AV node toward the right and left bundle branches?',
  'Sinoatrial node','Coronary sinus','Bundle of His','Left atrial appendage',
  'C','The His bundle carries impulses from the AV node into the His–Purkinje conduction system.'),
 ('Spatial Orientation & 3D Understanding',
  'Why are two different fluoroscopic projections useful during cardiac lead placement?',
  'They eliminate the need for ECG monitoring','They provide complementary views of a three-dimensional structure','They always show the same anatomical relationships','They measure the pacing threshold',
  'B','Different projections help distinguish depth and spatial relationships that cannot be resolved reliably from a single two-dimensional view.'),
 ('Lead Position Recognition',
  'On a chest X-ray, which finding is most consistent with a coronary sinus LV pacing lead?',
  'A lead coursing through the coronary venous system along the left ventricular silhouette','A lead terminating in the right atrial appendage','A lead positioned in the superior vena cava only','A lead ending in the right ventricular apex',
  'A','An LV lead placed through the coronary sinus typically follows a coronary venous branch over the LV silhouette; confirmation may require additional views.'),
 ('Basic Clinical Measurements & Concepts',
  'Which unit is commonly used to report the duration of a paced QRS complex?',
  'Millivolts (mV)','Ohms (Ω)','Milliseconds (ms)','French (Fr)',
  'C','QRS duration is a time interval and is measured in milliseconds; mV measures voltage, ohms impedance, and French catheter diameter.')
)
insert into public.questions
 (category, subcategory, difficulty, question_type, question,
  answer_a, answer_b, answer_c, answer_d, correct_answer, explanation, active)
select 'Anatomy & Imaging Fundamentals', n.subcategory, 'easy', 'multiple_choice',
 n.question, n.answer_a, n.answer_b, n.answer_c, n.answer_d,
 n.correct_answer, n.explanation, true
from new_questions n
where not exists (
 select 1 from public.questions q
 where q.category='Anatomy & Imaging Fundamentals' and q.question=n.question
);

-- Confirm the new area and its questions:
select category, subcategory, question, correct_answer, active
from public.questions
where category='Anatomy & Imaging Fundamentals'
order by subcategory;
