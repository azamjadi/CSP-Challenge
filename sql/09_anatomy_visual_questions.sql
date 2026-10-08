-- CSP Challenge: five visual multiple-choice anatomy questions
-- Review the illustrations and explanations before clinical deployment.
-- Run in Supabase SQL Editor after confirming your public.questions columns.
INSERT INTO public.questions
(category, difficulty, question_type, visual_key, question, answer_a, answer_b, answer_c, answer_d, correct_answer, explanation)
VALUES
('Anatomy & Imaging Fundamentals','easy','multiple_choice','anatomy-rv-apex',
 'Which anatomical region is highlighted in the schematic?',
 'Right Atrial Appendage','Right Ventricular Apex','Coronary Sinus','His Bundle',
 'B','The RV apex is the inferior apical region of the right ventricle. The schematic is simplified.'),
('Anatomy & Imaging Fundamentals','medium','multiple_choice','anatomy-rv-septum',
 'Which anatomical region is highlighted?',
 'RV Free Wall','Interventricular Septum','Tricuspid Annulus','Pulmonary Valve',
 'B','The interventricular septum separates the right and left ventricles.'),
('Anatomy & Imaging Fundamentals','medium','multiple_choice','anatomy-coronary-sinus',
 'Which cardiac venous structure is highlighted?',
 'Left Atrial Appendage','Coronary Sinus','Pulmonary Vein','Inferior Vena Cava',
 'B','The coronary sinus runs predominantly in the posterior atrioventricular groove and drains into the right atrium.'),
('Anatomy & Imaging Fundamentals','medium','multiple_choice','anatomy-lv-lead',
 'What type of pacing lead is illustrated along a coronary venous branch?',
 'Right Ventricular Lead','Left Ventricular Coronary Venous Lead','Right Atrial Lead','His Bundle Lead',
 'B','A conventional CRT LV lead is typically placed via the coronary sinus into a suitable coronary venous branch.'),
('Anatomy & Imaging Fundamentals','easy','multiple_choice','anatomy-lead-direction',
 'Which term describes the end of a lead closer to the pulse generator?',
 'Proximal','Distal','Septal','Apical',
 'A','Proximal refers to the connector/generator end; distal refers to the tip.');
