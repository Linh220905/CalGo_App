import json
import os

L10N_DIR = "/home/linh/Documents/SAAS/mobile/lib/l10n"

TRANSLATIONS = {
    "en": {
        "sourceActivityFactor": "FAO/WHO — Energy requirements & activity factors",
        "nutritionSourcesTitle": "Scientific & Medical Sources",
        "nutritionSourcesSubtitle": "Formulas and dietary guidelines used in CalGo",
        "calorieCalculationSourceTitle": "Daily Calorie Target & BMR",
        "calorieCalculationSourceDesc": "Basal Metabolic Rate is calculated using the Mifflin–St Jeor equation, adjusted with FAO/WHO Physical Activity Level (PAL) factors.",
        "macroDistributionSourceTitle": "Macronutrient Distribution",
        "macroDistributionSourceDesc": "Protein, carbohydrate, and fat targets follow Acceptable Macronutrient Distribution Ranges (AMDR) from the USDA and Dietary Guidelines for Americans.",
        "safeWeightRateSourceTitle": "Safe Rate of Weight Change",
        "safeWeightRateSourceDesc": "Calorie deficits are safely capped between 500–1000 kcal/day (0.5–1.0 kg/week) in accordance with CDC and NIH guidelines, with minimum safety floors.",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — Resting Energy Equation (1990)",
        "faoWhoEnergyCitation": "FAO/WHO/UNU — Human Energy Requirements & Activity Factors",
        "usdaDietaryCitation": "USDA Dietary Guidelines for Americans (Macronutrients)",
        "cdcWeightLossCitation": "CDC — Healthy Weight Loss Guidelines (0.5–1 kg/week)",
        "bmiMicronutrientSourceTitle": "BMI & Micronutrient Standards",
        "bmiMicronutrientSourceDesc": "Body Mass Index classification (18.5–24.9 normal range) and daily micronutrient thresholds (Fiber 14g/1000kcal, Free Sugars <10%, Sodium <2000mg)."
    },
    "vi": {
        "sourceActivityFactor": "FAO/WHO — Nhu cầu năng lượng & hệ số vận động",
        "nutritionSourcesTitle": "Nguồn khoa học & Y khoa",
        "nutritionSourcesSubtitle": "Công thức tính toán và hướng dẫn dinh dưỡng trong CalGo",
        "calorieCalculationSourceTitle": "Mục tiêu calo hàng ngày & BMR",
        "calorieCalculationSourceDesc": "Tỷ lệ trao đổi chất cơ bản (BMR) được tính theo công thức Mifflin–St Jeor, kết hợp hệ số hoạt động thể chất (PAL) của FAO/WHO.",
        "macroDistributionSourceTitle": "Phân bổ nhóm chất đa lượng",
        "macroDistributionSourceDesc": "Mục tiêu đạm, tinh bột và chất béo tuân theo Khung phân bổ chấp nhận được (AMDR) từ USDA và Hướng dẫn dinh dưỡng Hoa Kỳ.",
        "safeWeightRateSourceTitle": "Tốc độ thay đổi cân nặng an toàn",
        "safeWeightRateSourceDesc": "Mức thâm hụt calo được giới hạn an toàn 500–1000 kcal/ngày (0.5–1.0 kg/tuần) theo khuyến nghị của CDC và NIH, kèm mức calo sàn tối thiểu.",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — Công thức năng lượng nghỉ ngơi (1990)",
        "faoWhoEnergyCitation": "FAO/WHO/UNU — Nhu cầu năng lượng con người & Hệ số vận động",
        "usdaDietaryCitation": "USDA Hướng dẫn dinh dưỡng cho người Mỹ (Đa lượng)",
        "cdcWeightLossCitation": "CDC — Hướng dẫn giảm cân lành mạnh (0.5–1 kg/tuần)",
        "bmiMicronutrientSourceTitle": "Tiêu chuẩn BMI & Vi chất",
        "bmiMicronutrientSourceDesc": "Phân loại chỉ số khối cơ thể BMI (chuẩn 18.5–24.9) và ngưỡng vi chất hàng ngày (Chất xơ 14g/1000kcal, Đường tự do <10%, Natri <2000mg)."
    },
    "es": {
        "sourceActivityFactor": "FAO/OMS — Requerimientos energéticos y factores de actividad",
        "nutritionSourcesTitle": "Fuentes científicas y médicas",
        "nutritionSourcesSubtitle": "Fórmulas y pautas dietéticas utilizadas en CalGo",
        "calorieCalculationSourceTitle": "Objetivo calórico diario y TMB",
        "calorieCalculationSourceDesc": "La tasa metabólica basal se calcula con la ecuación de Mifflin–St Jeor, ajustada con factores de nivel de actividad física (PAL) de la FAO/OMS.",
        "macroDistributionSourceTitle": "Distribución de macronutrientes",
        "macroDistributionSourceDesc": "Los objetivos de proteínas, carbohidratos y grasas siguen los rangos de distribución aceptable de macronutrientes (AMDR) del USDA.",
        "safeWeightRateSourceTitle": "Ritmo seguro de cambio de peso",
        "safeWeightRateSourceDesc": "El déficit calórico se limita de forma segura a 500–1000 kcal/día (0,5–1,0 kg/semana) según las guías del CDC y los NIH.",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — Ecuación de energía en reposo (1990)",
        "faoWhoEnergyCitation": "FAO/OMS/UNU — Requerimientos de energía humana y factores de actividad",
        "usdaDietaryCitation": "Pautas dietéticas del USDA para estadounidenses (Macronutrientes)",
        "cdcWeightLossCitation": "CDC — Pautas para una pérdida de peso saludable (0,5–1 kg/semana)",
        "bmiMicronutrientSourceTitle": "Estándares de IMC y micronutrientes",
        "bmiMicronutrientSourceDesc": "Clasificación del IMC (rango normal 18,5–24,9) y límites de micronutrientes (Fibra 14g/1000kcal, Azúcares libres <10%, Sodio <2000mg)."
    },
    "fr": {
        "sourceActivityFactor": "FAO/OMS — Besoins énergétiques et facteurs d'activité",
        "nutritionSourcesTitle": "Sources scientifiques et médicales",
        "nutritionSourcesSubtitle": "Formules et directives nutritionnelles utilisées dans CalGo",
        "calorieCalculationSourceTitle": "Objectif calorique quotidien et MB",
        "calorieCalculationSourceDesc": "Le métabolisme de base est calculé selon la formule de Mifflin–St Jeor, ajustée avec les facteurs de niveau d'activité physique (PAL) de la FAO/OMS.",
        "macroDistributionSourceTitle": "Répartition des macronutriments",
        "macroDistributionSourceDesc": "Les objectifs en protéines, glucides et lipides respectent les fourchettes acceptables de distribution des macronutriments (AMDR) de l'USDA.",
        "safeWeightRateSourceTitle": "Rythme de perte de poids sécurisé",
        "safeWeightRateSourceDesc": "Le déficit calorique est plafonné en toute sécurité entre 500 et 1000 kcal/jour (0,5 à 1,0 kg/semaine) selon le CDC et le NIH.",
        "mifflinStJeorCitation": "PubMed : Mifflin et al. — Équation d'énergie au repos (1990)",
        "faoWhoEnergyCitation": "FAO/OMS/UNU — Besoins énergétiques humains et facteurs d'activité",
        "usdaDietaryCitation": "Directives diététiques de l'USDA pour les Américains (Macronutriments)",
        "cdcWeightLossCitation": "CDC — Recommandations pour une perte de poids saine (0,5–1 kg/semaine)",
        "bmiMicronutrientSourceTitle": "Normes d'IMC et de micronutriments",
        "bmiMicronutrientSourceDesc": "Classification de l'IMC (18,5–24,9 normal) et seuils de micronutriments (Fibres 14g/1000kcal, Sucres libres <10%, Sodium <2000mg)."
    },
    "ja": {
        "sourceActivityFactor": "FAO/WHO — エネルギー必要量と身体活動レベル",
        "nutritionSourcesTitle": "科学的・医学的根拠",
        "nutritionSourcesSubtitle": "CalGoで使用されている計算式と栄養ガイドライン",
        "calorieCalculationSourceTitle": "1日の目標カロリーと基礎代謝（BMR）",
        "calorieCalculationSourceDesc": "基礎代謝率はMifflin–St Jeor式に基づいて算出され、FAO/WHOの身体活動レベル（PAL）係数で調整されています。",
        "macroDistributionSourceTitle": "三大栄養素の比率（PFCバランス）",
        "macroDistributionSourceDesc": "タンパク質、炭水化物、脂質の目標値は、USDAおよび米国食事摂取基準のAMDRガイドラインに準拠しています。",
        "safeWeightRateSourceTitle": "安全な体重変化ペース",
        "safeWeightRateSourceDesc": "カロリー制限はCDCおよびNIHの安全基準に基づき、1日500〜1000kcal（週0.5〜1.0kg）を上限として安全に設定されています。",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — 安静時エネルギー消費量算出式 (1990)",
        "faoWhoEnergyCitation": "FAO/WHO/UNU — ヒトのエネルギー必要量と活動係数",
        "usdaDietaryCitation": "USDA 米国食事ガイドライン（三大栄養素）",
        "cdcWeightLossCitation": "CDC — 健康的な体重減少ガイドライン (週0.5〜1kg)",
        "bmiMicronutrientSourceTitle": "BMIおよび微量栄養素基準",
        "bmiMicronutrientSourceDesc": "BMI分類（普通体重18.5〜24.9）および微量栄養素の推奨基準値（食物繊維14g/1000kcal、遊離糖類<10%、ナトリウム<2000mg）。"
    },
    "ko": {
        "sourceActivityFactor": "FAO/WHO — 에너지 필요량 및 활동 계수",
        "nutritionSourcesTitle": "과학 및 의학적 근거",
        "nutritionSourcesSubtitle": "CalGo에 적용된 계산 공식 및 영양 가이드라인",
        "calorieCalculationSourceTitle": "일일 목표 칼로리 및 기초대사량(BMR)",
        "calorieCalculationSourceDesc": "기초대사량은 검증된 Mifflin–St Jeor 공식으로 계산되며, FAO/WHO 신체활동수준(PAL) 계수로 조정됩니다.",
        "macroDistributionSourceTitle": "주요 영양소(탄단지) 배분",
        "macroDistributionSourceDesc": "단백질, 탄수화물, 지방 목표는 USDA 및 미국 식이지침의 적정 다량영양소 섭취비율(AMDR)을 따릅니다.",
        "safeWeightRateSourceTitle": "안전한 체중 감량 속도",
        "safeWeightRateSourceDesc": "CDC 및 NIH 지침에 따라 일일 500~1000kcal(주당 0.5~1.0kg) 내에서 안전하게 제한됩니다.",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — 휴식기 에너지 소비량 공식 (1990)",
        "faoWhoEnergyCitation": "FAO/WHO/UNU — 인간 에너지 필요량 및 활동 계수",
        "usdaDietaryCitation": "USDA 미국 식생활 지침 (다량영양소)",
        "cdcWeightLossCitation": "CDC — 건강한 체중 감량 가이드라인 (주당 0.5~1kg)",
        "bmiMicronutrientSourceTitle": "BMI 및 미량영양소 기준",
        "bmiMicronutrientSourceDesc": "체질량지수(BMI) 분류(정상 18.5~24.9) 및 일일 미량영양소 권장 기준(식이섬유 14g/1000kcal, 유리당 <10%, 나트륨 <2000mg)."
    },
    "pt": {
        "sourceActivityFactor": "FAO/OMS — Requisitos de energia e fatores de atividade",
        "nutritionSourcesTitle": "Fontes Científicas e Médicas",
        "nutritionSourcesSubtitle": "Fórmulas e diretrizes nutricionais usadas no CalGo",
        "calorieCalculationSourceTitle": "Meta Diária de Calorias e TMB",
        "calorieCalculationSourceDesc": "A Taxa Metabólica Basal é calculada pela fórmula Mifflin–St Jeor, ajustada pelos fatores de nível de atividade física da FAO/OMS.",
        "macroDistributionSourceTitle": "Distribuição de Macronutrientes",
        "macroDistributionSourceDesc": "As metas de proteínas, carboidratos e gorduras seguem as faixas de distribuição aceitável de macronutrientes (AMDR) do USDA.",
        "safeWeightRateSourceTitle": "Ritmo Seguro de Mudança de Peso",
        "safeWeightRateSourceDesc": "O déficit calórico é limitado com segurança entre 500 e 1000 kcal/dia (0,5 a 1,0 kg/semana), conforme diretrizes do CDC e NIH.",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — Equação de Gasto Energético em Repouso (1990)",
        "faoWhoEnergyCitation": "FAO/OMS/UNU — Requisitos de Energia Humana e Fatores de Atividade",
        "usdaDietaryCitation": "Diretrizes Dietéticas do USDA para Americanos (Macronutrientes)",
        "cdcWeightLossCitation": "CDC — Diretrizes para Perda de Peso Saudável (0,5–1 kg/semana)",
        "bmiMicronutrientSourceTitle": "Padrões de IMC e Micronutrientes",
        "bmiMicronutrientSourceDesc": "Classificação de IMC (18,5–24,9 normal) e limites diários de micronutrientes (Fibras 14g/1000kcal, Açúcares livres <10%, Sódio <2000mg)."
    },
    "ru": {
        "sourceActivityFactor": "ФАО/ВОЗ — Потребность в энергии и коэффициенты активности",
        "nutritionSourcesTitle": "Научные и медицинские источники",
        "nutritionSourcesSubtitle": "Формулы и рекомендации по питанию, используемые в CalGo",
        "calorieCalculationSourceTitle": "Целевые суточные калории и BMR",
        "calorieCalculationSourceDesc": "Базовый уровень метаболизма рассчитывается по формуле Миффлина–Сент-Джеора с учетом коэффициентов физической активности ФАО/ВОЗ.",
        "macroDistributionSourceTitle": "Распределение макронутриентов (БЖУ)",
        "macroDistributionSourceDesc": "Целевые показатели белков, жиров и углеводов соответствуют нормам AMDR Министерства сельского хозяйства США (USDA).",
        "safeWeightRateSourceTitle": "Безопасный темп изменения веса",
        "safeWeightRateSourceDesc": "Дефицит калорий безопасно ограничен 500–1000 ккал/день (0,5–1,0 кг/неделю) согласно рекомендациям CDC и NIH.",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — Формула расхода энергии в покое (1990)",
        "faoWhoEnergyCitation": "ФАО/ВОЗ/УООН — Потребность человека в энергии и коэффициенты активности",
        "usdaDietaryCitation": "Диетические рекомендации USDA для американцев (Макронутриенты)",
        "cdcWeightLossCitation": "CDC — Рекомендации по здоровому снижению веса (0,5–1 кг/неделю)",
        "bmiMicronutrientSourceTitle": "Стандарты ИМТ и микронутриентов",
        "bmiMicronutrientSourceDesc": "Классификация ИМТ (норма 18,5–24,9) и суточные нормы микронутриентов (Клетчатка 14г/1000ккал, Сахар <10%, Натрий <2000мг)."
    },
    "zh": {
        "sourceActivityFactor": "粮农组织/世卫组织 — 人体能量需求与活动系数",
        "nutritionSourcesTitle": "科学与医学来源",
        "nutritionSourcesSubtitle": "CalGo中使用的计算公式和饮食指南",
        "calorieCalculationSourceTitle": "每日卡路里目标与基础代谢率（BMR）",
        "calorieCalculationSourceDesc": "基础代谢率采用Mifflin–St Jeor公式计算，并根据FAO/WHO身体活动水平（PAL）系数进行调整。",
        "macroDistributionSourceTitle": "宏量营养素分布",
        "macroDistributionSourceDesc": "蛋白质、碳水化合物和脂肪目标符合美国农业部（USDA）和膳食指南的可接受宏量营养素分布范围（AMDR）。",
        "safeWeightRateSourceTitle": "安全减重速率",
        "safeWeightRateSourceDesc": "根据CDC和NIH指南，热量缺口安全限制在每天500–1000 kcal（每周0.5–1.0 kg），并设有最低安全摄入底线。",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — 静息能量消耗公式 (1990)",
        "faoWhoEnergyCitation": "粮农组织/世卫组织/联合国大学 — 人体能量需求与活动系数",
        "usdaDietaryCitation": "USDA 美国人饮食指南（宏量营养素）",
        "cdcWeightLossCitation": "CDC — 健康减重指南 (每周0.5–1公斤)",
        "bmiMicronutrientSourceTitle": "BMI与微量营养素标准",
        "bmiMicronutrientSourceDesc": "身体质量指数BMI分类（正常范围18.5–24.9）及每日微量营养素限额（膳食纤维14g/1000kcal，游离糖<10%，钠<2000mg）。"
    },
    "ar": {
        "sourceActivityFactor": "منظمة الأغذية والزراعة / منظمة الصحة العالمية — متطلبات الطاقة ومعاملات النشاط",
        "nutritionSourcesTitle": "المصادر العلمية والطبية",
        "nutritionSourcesSubtitle": "المعادلات والإرشادات الغذائية المعتمدة في CalGo",
        "calorieCalculationSourceTitle": "الهدف اليومي للسُّعرات ومعدل الأيض الأساسي (BMR)",
        "calorieCalculationSourceDesc": "يتم حساب معدل الأيض الأساسي باستخدام معادلة ميفلين-سانت جور، وتعديلها بمعاملات مستوى النشاط البدني المعتمدة من منظمة الصحة العالمية.",
        "macroDistributionSourceTitle": "توزيع المغذيات الكبرى",
        "macroDistributionSourceDesc": "تتبع أهداف البروتين والكربوهيدرات والدهون نطاقات التوزيع المقبولة للمغذيات الكبرى (AMDR) الصادرة عن وزارة الزراعة الأمريكية.",
        "safeWeightRateSourceTitle": "معدل آمن لتغير الوزن",
        "safeWeightRateSourceDesc": "يتم تحديد عجز السعرات الحرارية بأمان بين 500 و1000 سعرة/يوم (0.5 إلى 1.0 كجم/أسبوع) وفقًا لإرشادات CDC وNIH.",
        "mifflinStJeorCitation": "PubMed: ميفلين وآخرون — معادلة استهلاك الطاقة أثناء الراحة (1990)",
        "faoWhoEnergyCitation": "الفاو / الصحة العالمية — متطلبات الطاقة البشرية ومعاملات النشاط",
        "usdaDietaryCitation": "الإرشادات الغذائية الأمريكية الصادرة عن USDA (المغذيات الكبرى)",
        "cdcWeightLossCitation": "CDC — إرشادات فقدان الوزن الصحي (0.5–1 كجم/أسبوع)",
        "bmiMicronutrientSourceTitle": "معايير مؤشر كتلة الجسم والمغذيات الدقيقة",
        "bmiMicronutrientSourceDesc": "تصنيف مؤشر كتلة الجسم (المعدل الطبيعي 18.5–24.9) والحدود اليومية (ألياف 14 جم/1000 سعرة، سكريات حرة <10%، صوديوم <2000 ملجم)."
    },
    "bn": {
        "sourceActivityFactor": "FAO/WHO — শক্তির প্রয়োজনীয়তা এবং কার্যকলাপের গুণক",
        "nutritionSourcesTitle": "বৈজ্ঞানিক ও চিকিৎসা তথ্যসূত্র",
        "nutritionSourcesSubtitle": "CalGo-তে ব্যবহৃত গণনার সূত্র এবং পুষ্টি নির্দেশিকা",
        "calorieCalculationSourceTitle": "দৈনিক ক্যালোরি লক্ষ্য ও বিএমআর (BMR)",
        "calorieCalculationSourceDesc": "বেসাল মেটাবলিক রেট Mifflin–St Jeor সূত্রের মাধ্যমে গণনা করা হয় এবং FAO/WHO এর কার্যকলাপের মাত্রা অনুযায়ী সমন্বয় করা হয়।",
        "macroDistributionSourceTitle": "ম্যাক্রোনিউট্রিয়েন্ট বণ্টন",
        "macroDistributionSourceDesc": "প্রোটিন, কার্বোহাইড্রেট এবং ফ্যাটের লক্ষ্য USDA এবং আমেরিকান ডায়েটরি নির্দেশিকার AMDR অনুসরণ করে।",
        "safeWeightRateSourceTitle": "ওজন পরিবর্তনের নিরাপদ হার",
        "safeWeightRateSourceDesc": "CDC এবং NIH নির্দেশিকা অনুসারে ক্যালোরির ঘাটতি নিরাপদে ৫০০–১০০০ ক্যালোরি/দিন (০.৫–১.০ কেজি/সপ্তাহ) এর মধ্যে সীমাবদ্ধ থাকে।",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — বিশ্রামের শক্তি ব্যয় সমীকরণ (১৯৯০)",
        "faoWhoEnergyCitation": "FAO/WHO/UNU — মানব শক্তি প্রয়োজনীয়তা ও কার্যকলাপ গুণক",
        "usdaDietaryCitation": "আমেরিকানদের জন্য USDA ডায়েটরি নির্দেশিকা (ম্যাক্রোনিউট্রিয়েন্ট)",
        "cdcWeightLossCitation": "CDC — স্বাস্থ্যকর ওজন কমানোর নির্দেশিকা (সপ্তাহে ০.৫–১ কেজি)",
        "bmiMicronutrientSourceTitle": "বিএমআই এবং মাইক্রোনিউট্রিয়েন্ট মান",
        "bmiMicronutrientSourceDesc": "বডি ম্যাস ইনডেক্স শ্রেণিবিভাগ (স্বাভাবিক ১৮.৫–২৪.৯) এবং দৈনিক মাইক্রোনিউট্রিয়েন্ট সীমা (ফাইবার ১৪ গ্রাম/১০০০ক্যালোরি, চিনি <১০%, সোডিয়াম <২০০০মিলিগ্রাম)।"
    },
    "hi": {
        "sourceActivityFactor": "FAO/WHO — ऊर्जा आवश्यकताएं और गतिविधि गुणक",
        "nutritionSourcesTitle": "वैज्ञानिक और चिकित्सा स्रोत",
        "nutritionSourcesSubtitle": "CalGo में उपयोग किए जाने वाले सूत्र और पोषण दिशानिर्देश",
        "calorieCalculationSourceTitle": "दैनिक कैलोरी लक्ष्य और बीएमआर (BMR)",
        "calorieCalculationSourceDesc": "बेसल मेटाबॉलिक रेट की गणना Mifflin–St Jeor सूत्र द्वारा की जाती है और FAO/WHO गतिविधि स्तरों से समायोजित की जाती है।",
        "macroDistributionSourceTitle": "मैक्रोन्यूट्रिएंट वितरण",
        "macroDistributionSourceDesc": "प्रोटीन, कार्ब्स और फैट के लक्ष्य USDA और अमेरिकी आहार दिशानिर्देशों के AMDR मानकों का पालन करते हैं।",
        "safeWeightRateSourceTitle": "वजन घटाने की सुरक्षित दर",
        "safeWeightRateSourceDesc": "CDC और NIH दिशानिर्देशों के अनुसार कैलोरी की कमी को सुरक्षित रूप से 500-1000 किलोकैलोरी/दिन (0.5-1.0 किग्रा/सप्ताह) तक सीमित रखा जाता है।",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — विश्राम ऊर्जा व्यय समीकरण (1990)",
        "faoWhoEnergyCitation": "FAO/WHO/UNU — मानव ऊर्जा आवश्यकताएं और गतिविधि कारक",
        "usdaDietaryCitation": "अमेरिकियों के लिए USDA आहार दिशानिर्देश (मैक्रोन्यूट्रिएंट्स)",
        "cdcWeightLossCitation": "CDC — स्वस्थ वजन घटाने के दिशानिर्देश (0.5-1 किग्रा/सप्ताह)",
        "bmiMicronutrientSourceTitle": "बीएमआई और माइक्रोन्यूट्रिएंट मानक",
        "bmiMicronutrientSourceDesc": "बीएमआई वर्गीकरण (सामान्य 18.5-24.9) और दैनिक सीमाएं (फाइबर 14g/1000kcal, मुक्त शर्करा <10%, सोडियम <2000mg)।"
    },
    "ro": {
        "sourceActivityFactor": "FAO/OMS — Necesarul de energie și factorii de activitate",
        "nutritionSourcesTitle": "Surse științifice și medicale",
        "nutritionSourcesSubtitle": "Formule și ghiduri nutriționale utilizate în CalGo",
        "calorieCalculationSourceTitle": "Obiectiv caloric zilnic și RMB",
        "calorieCalculationSourceDesc": "Rata metabolică bazală este calculată utilizând ecuația Mifflin–St Jeor, ajustată cu factorii de activitate fizică FAO/OMS.",
        "macroDistributionSourceTitle": "Distribuția macronutrienților",
        "macroDistributionSourceDesc": "Obiectivele pentru proteine, carbohidrați și grăsimi respectă intervalele acceptabile de distribuție a macronutrienților (AMDR) ale USDA.",
        "safeWeightRateSourceTitle": "Ritm sigur de schimbare a greutății",
        "safeWeightRateSourceDesc": "Deficitul caloric este limitat în siguranță între 500 și 1000 kcal/zi (0,5–1,0 kg/săptămână), conform ghidurilor CDC și NIH.",
        "mifflinStJeorCitation": "PubMed: Mifflin et al. — Ecuația de energie în repaus (1990)",
        "faoWhoEnergyCitation": "FAO/OMS/UNU — Necesarul de energie umană și factorii de activitate",
        "usdaDietaryCitation": "Ghidurile dietetice USDA pentru americani (Macronutrienți)",
        "cdcWeightLossCitation": "CDC — Ghid pentru o scădere sănătoasă în greutate (0,5–1 kg/săptămână)",
        "bmiMicronutrientSourceTitle": "Standarde IMC și micronutrienți",
        "bmiMicronutrientSourceDesc": "Clasificarea indicelui de masă corporală (18,5–24,9 normal) și limitele zilnice de micronutrienți (Fibre 14g/1000kcal, Zaharuri libere <10%, Sodiu <2000mg)."
    }
}

for lang, data in TRANSLATIONS.items():
    file_path = os.path.join(L10N_DIR, f"app_{lang}.arb")
    if not os.path.exists(file_path):
        print(f"Skipping {file_path}, does not exist")
        continue

    with open(file_path, "r", encoding="utf-8") as f:
        arb_content = json.load(f)

    for k, v in data.items():
        arb_content[k] = v

    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(arb_content, f, ensure_ascii=False, indent=2)
    print(f"Updated {file_path}")
print("Done all arb files!")
