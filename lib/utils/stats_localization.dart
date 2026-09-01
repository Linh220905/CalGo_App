import 'package:flutter/widgets.dart';

/// Localized copy for dynamic values that come from the API catalog.
///
/// The API intentionally keeps achievement ids and BMI categories stable;
/// presentation text belongs to the client so the Stats screen follows the
/// selected app locale instead of rendering server-side Vietnamese strings.
class StatsLocalization {
  static String languageCode(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  static String levelTitle(BuildContext context, int level) {
    final titles = <String, List<String>>{
      'vi': const [
        '',
        'Người mới bắt đầu',
        'Người theo dõi',
        'Người kiên trì',
        'Người có kỷ luật',
        'Người nhiệt huyết',
        'Người đam mê sức khỏe',
        'Chuyên gia dinh dưỡng',
        'Nhà vô địch',
        'Huyền thoại',
        'Master CalGo',
      ],
      'en': const [
        '',
        'Beginner',
        'Tracker',
        'Consistent',
        'Disciplined',
        'Energetic',
        'Health Enthusiast',
        'Nutrition Expert',
        'Champion',
        'Legend',
        'Master CalGo',
      ],
      'ko': const [
        '',
        '초보자',
        '기록자',
        '꾸준한 사람',
        '자기관리자',
        '열정가',
        '건강 애호가',
        '영양 전문가',
        '챔피언',
        '전설',
        'CalGo 마스터',
      ],
      'ja': const [
        '',
        '初心者',
        '記録者',
        '継続者',
        '自己管理者',
        '情熱家',
        '健康愛好家',
        '栄養の専門家',
        'チャンピオン',
        'レジェンド',
        'CalGoマスター',
      ],
      'zh': const [
        '',
        '新手',
        '记录者',
        '坚持者',
        '自律者',
        '热忱者',
        '健康达人',
        '营养专家',
        '冠军',
        '传奇',
        'CalGo大师',
      ],
      'es': const [
        '',
        'Principiante',
        'Registrador',
        'Constante',
        'Disciplinado',
        'Entusiasta',
        'Amante de la salud',
        'Experto en nutrición',
        'Campeón',
        'Leyenda',
        'Maestro CalGo',
      ],
      'fr': const [
        '',
        'Débutant',
        'Observateur',
        'Persévérant',
        'Discipliné',
        'Passionné',
        'Passionné de santé',
        'Expert en nutrition',
        'Champion',
        'Légende',
        'Maître CalGo',
      ],
      'pt': const [
        '',
        'Iniciante',
        'Registrador',
        'Persistente',
        'Disciplinado',
        'Entusiasta',
        'Amante da saúde',
        'Especialista em nutrição',
        'Campeão',
        'Lenda',
        'Mestre CalGo',
      ],
      'ru': const [
        '',
        'Новичок',
        'Наблюдатель',
        'Настойчивый',
        'Дисциплинированный',
        'Энтузиаст',
        'Любитель здоровья',
        'Эксперт по питанию',
        'Чемпион',
        'Легенда',
        'Мастер CalGo',
      ],
      'hi': const [
        '',
        'शुरुआती',
        'ट्रैकर',
        'निरंतर',
        'अनुशासित',
        'उत्साही',
        'स्वास्थ्य प्रेमी',
        'पोषण विशेषज्ञ',
        'चैंपियन',
        'किंवदंती',
        'CalGo मास्टर',
      ],
      'bn': const [
        '',
        'শিক্ষানবিস',
        'ট্র্যাকার',
        'নিয়মিত',
        'শৃঙ্খলাবদ্ধ',
        'উৎসাহী',
        'স্বাস্থ্যপ্রেমী',
        'পুষ্টি বিশেষজ্ঞ',
        'চ্যাম্পিয়ন',
        'কিংবদন্তি',
        'CalGo মাস্টার',
      ],
      'ar': const [
        '',
        'مبتدئ',
        'متابع',
        'مثابر',
        'منضبط',
        'متحمس',
        'محب للصحة',
        'خبير تغذية',
        'بطل',
        'أسطورة',
        'خبير CalGo',
      ],
    };
    final list = titles[languageCode(context)] ?? titles['en']!;
    final safeLevel = level.clamp(1, list.length - 1);
    return list[safeLevel];
  }

  static String achievementName(
    BuildContext context,
    String id,
    String fallback,
  ) {
    final code = languageCode(context);
    final values = _achievements[code] ?? _achievements['en']!;
    return values[id]?.$1 ?? fallback;
  }

  static String achievementDescription(
    BuildContext context,
    String id,
    String fallback,
  ) {
    final code = languageCode(context);
    final values = _achievements[code] ?? _achievements['en']!;
    return values[id]?.$2 ?? fallback;
  }

  static String bmiCategory(
    BuildContext context,
    String? category,
    String fallback,
  ) {
    final key = (category ?? '').trim().toLowerCase();
    final values = _bmi[languageCode(context)] ?? _bmi['en']!;
    return values[key] ?? fallback;
  }

  static String periodLabel(BuildContext context, int days) {
    switch (languageCode(context)) {
      case 'vi':
        return '$days ngày';
      case 'ja':
        return '$days日';
      case 'ko':
        return '$days일';
      case 'zh':
        return '$days天';
      case 'es':
        return '$days días';
      case 'fr':
        return '$days jours';
      case 'pt':
        return '$days dias';
      case 'ru':
        return '$days дн.';
      case 'hi':
        return '$days दिन';
      case 'bn':
        return '$days দিন';
      case 'ar':
        return '$days أيام';
      default:
        return '$days days';
    }
  }

  static String weekdayShort(BuildContext context, DateTime date) {
    final names = <String, List<String>>{
      'vi': const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
      'en': const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'ko': const ['월', '화', '수', '목', '금', '토', '일'],
      'ja': const ['月', '火', '水', '木', '金', '土', '日'],
      'zh': const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      'es': const ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'],
      'fr': const ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'],
      'pt': const ['seg.', 'ter.', 'qua.', 'qui.', 'sex.', 'sáb.', 'dom.'],
      'ru': const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
      'hi': const ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'],
      'bn': const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি', 'রবি'],
      'ar': const ['اثن', 'ثلث', 'أرب', 'خمي', 'جمع', 'سبت', 'أحد'],
    };
    final list = names[languageCode(context)] ?? names['en']!;
    return list[date.weekday - 1];
  }

  static String monthShort(BuildContext context, DateTime date) {
    final names = <String, List<String>>{
      'vi': const [
        '',
        'Thg 1',
        'Thg 2',
        'Thg 3',
        'Thg 4',
        'Thg 5',
        'Thg 6',
        'Thg 7',
        'Thg 8',
        'Thg 9',
        'Thg 10',
        'Thg 11',
        'Thg 12',
      ],
      'en': const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ],
      'ko': const [
        '',
        '1월',
        '2월',
        '3월',
        '4월',
        '5월',
        '6월',
        '7월',
        '8월',
        '9월',
        '10월',
        '11월',
        '12월',
      ],
      'ja': const [
        '',
        '1月',
        '2月',
        '3月',
        '4月',
        '5月',
        '6月',
        '7月',
        '8月',
        '9月',
        '10月',
        '11月',
        '12月',
      ],
      'zh': const [
        '',
        '1月',
        '2月',
        '3月',
        '4月',
        '5月',
        '6月',
        '7月',
        '8月',
        '9月',
        '10月',
        '11月',
        '12月',
      ],
      'es': const [
        '',
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic',
      ],
      'fr': const [
        '',
        'janv.',
        'févr.',
        'mars',
        'avr.',
        'mai',
        'juin',
        'juil.',
        'août',
        'sept.',
        'oct.',
        'nov.',
        'déc.',
      ],
      'pt': const [
        '',
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ],
      'ru': const [
        '',
        'янв',
        'фев',
        'мар',
        'апр',
        'май',
        'июн',
        'июл',
        'авг',
        'сен',
        'окт',
        'ноя',
        'дек',
      ],
      'hi': const [
        '',
        'जन॰',
        'फ़र॰',
        'मार्च',
        'अप्रैल',
        'मई',
        'जून',
        'जुल॰',
        'अग॰',
        'सित॰',
        'अक्तू॰',
        'नव॰',
        'दिस॰',
      ],
      'bn': const [
        '',
        'জানু',
        'ফেব্রু',
        'মার্চ',
        'এপ্রিল',
        'মে',
        'জুন',
        'জুলাই',
        'আগস্ট',
        'সেপ্টে',
        'অক্টো',
        'নভে',
        'ডিসে',
      ],
      'ar': const [
        '',
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ],
    };
    final list = names[languageCode(context)] ?? names['en']!;
    return date.month >= 1 && date.month <= 12
        ? list[date.month]
        : '${date.month}';
  }

  static String forecastOnTrackTitle(BuildContext context) => _text(
    context,
    vi: 'Đang đi đúng hướng',
    en: 'On track',
    ko: '순조롭게 진행 중',
    ja: '順調に進んでいます',
    zh: '进展顺利',
    es: 'Vas por buen camino',
    fr: 'En bonne voie',
    pt: 'No caminho certo',
    ru: 'Всё по плану',
    hi: 'सही दिशा में',
    bn: 'সঠিক পথে',
    ar: 'على الطريق الصحيح',
  );

  static String forecastNeedsAdjustmentTitle(BuildContext context) => _text(
    context,
    vi: 'Cần điều chỉnh',
    en: 'Needs adjustment',
    ko: '조정이 필요해요',
    ja: '調整が必要です',
    zh: '需要调整',
    es: 'Necesita ajustes',
    fr: 'Ajustement nécessaire',
    pt: 'Precisa de ajuste',
    ru: 'Нужна корректировка',
    hi: 'समायोजन की आवश्यकता',
    bn: 'সমন্বয় প্রয়োজন',
    ar: 'يحتاج إلى تعديل',
  );

  static String forecastGoalReachedTitle(BuildContext context) => _text(
    context,
    vi: 'Đã đạt mục tiêu',
    en: 'Goal reached',
    ko: '목표 달성',
    ja: '目標達成',
    zh: '已达成目标',
    es: 'Objetivo alcanzado',
    fr: 'Objectif atteint',
    pt: 'Meta alcançada',
    ru: 'Цель достигнута',
    hi: 'लक्ष्य प्राप्त',
    bn: 'লক্ষ্য অর্জিত',
    ar: 'تم تحقيق الهدف',
  );

  static String forecastOnTrackBody(
    BuildContext context, {
    required int calories,
    required String target,
    required String weeks,
  }) {
    final code = languageCode(context);
    switch (code) {
      case 'vi':
        return 'Nếu duy trì trung bình $calories kcal/ngày, bạn có thể đạt $target kg trong khoảng $weeks.';
      case 'ko':
        return '하루 평균 $calories kcal를 유지하면 약 $weeks 후 $target kg에 도달할 수 있어요.';
      case 'ja':
        return '1日平均$calories kcalを維持すると、約$weeksで$target kgに到達できます。';
      case 'zh':
        return '保持每天平均 $calories kcal，预计约 $weeks 后达到 $target kg。';
      case 'es':
        return 'Con una media de $calories kcal al día, podrías alcanzar $target kg en unos $weeks.';
      case 'fr':
        return 'Avec une moyenne de $calories kcal par jour, vous pourriez atteindre $target kg en environ $weeks.';
      case 'pt':
        return 'Com uma média de $calories kcal por dia, você pode chegar a $target kg em cerca de $weeks.';
      case 'ru':
        return 'При среднем рационе $calories ккал в день вы можете достичь $target кг примерно за $weeks.';
      case 'hi':
        return 'प्रतिदिन औसतन $calories kcal पर आप लगभग $weeks में $target kg तक पहुँच सकते हैं।';
      case 'bn':
        return 'প্রতিদিন গড়ে $calories kcal রাখলে প্রায় $weeks-এ $target kg-এ পৌঁছাতে পারেন।';
      case 'ar':
        return 'بمتوسط $calories سعرة يوميًا، يمكنك الوصول إلى $target كجم خلال نحو $weeks.';
      default:
        return 'At an average of $calories kcal/day, you may reach $target kg in about $weeks.';
    }
  }

  static String forecastNeedsAdjustmentBody(
    BuildContext context, {
    required String target,
  }) => _text(
    context,
    vi: 'Mức nạp hiện tại chưa phù hợp để dự báo chắc chắn thời điểm đạt $target kg. Hãy ghi nhận đều đặn và điều chỉnh theo mục tiêu.',
    en: 'Your current intake does not support a reliable estimate for reaching $target kg. Keep logging and adjust toward your goal.',
    ko: '현재 섭취량으로는 $target kg 도달 시점을 정확히 예측하기 어려워요. 꾸준히 기록하며 목표에 맞게 조정하세요.',
    ja: '現在の摂取量では$target kgに到達する時期を正確に予測できません。記録を続けて目標に合わせて調整しましょう。',
    zh: '当前摄入量不足以可靠预测何时达到 $target kg。请持续记录并根据目标调整。',
    es: 'Tu ingesta actual no permite estimar con fiabilidad cuándo llegarás a $target kg. Sigue registrando y ajusta tu plan.',
    fr: 'Votre apport actuel ne permet pas d’estimer précisément quand vous atteindrez $target kg. Continuez à noter et ajustez votre plan.',
    pt: 'A ingestão atual não permite estimar com segurança quando você chegará a $target kg. Continue registrando e ajuste o plano.',
    ru: 'Текущего рациона недостаточно для надёжной оценки достижения $target кг. Продолжайте записывать питание и корректируйте план.',
    hi: 'आपका वर्तमान सेवन $target kg तक पहुँचने का विश्वसनीय अनुमान देने के लिए पर्याप्त नहीं है। रिकॉर्ड करते रहें और लक्ष्य के अनुसार समायोजित करें।',
    bn: 'বর্তমান গ্রহণ $target kg-এ পৌঁছানোর নির্ভরযোগ্য সময় অনুমানের জন্য যথেষ্ট নয়। নিয়মিত রেকর্ড করুন ও লক্ষ্য অনুযায়ী সামঞ্জস্য করুন।',
    ar: 'مدخولك الحالي لا يكفي لتقدير موثوق لموعد الوصول إلى $target كجم. واصل التسجيل واضبط خطتك نحو هدفك.',
  );

  static String forecastNoDataBody(BuildContext context) => _text(
    context,
    vi: 'Hãy ghi nhận thêm dữ liệu cân nặng và dinh dưỡng để bắt đầu dự báo.',
    en: 'Log more weight and nutrition data to start a reliable forecast.',
    ko: '신뢰할 수 있는 예측을 시작하려면 체중과 영양 데이터를 더 기록하세요.',
    ja: '信頼できる予測を始めるには、体重と栄養データをさらに記録してください。',
    zh: '请记录更多体重和营养数据，以开始可靠预测。',
    es: 'Registra más datos de peso y nutrición para iniciar una previsión fiable.',
    fr: 'Enregistrez davantage de données de poids et de nutrition pour commencer une prévision fiable.',
    pt: 'Registre mais dados de peso e nutrição para iniciar uma previsão confiável.',
    ru: 'Добавьте данные о весе и питании, чтобы начать надёжный прогноз.',
    hi: 'विश्वसनीय पूर्वानुमान शुरू करने के लिए अधिक वजन और पोषण डेटा दर्ज करें।',
    bn: 'নির্ভরযোগ্য পূর্বাভাস শুরু করতে আরও ওজন ও পুষ্টির তথ্য রেকর্ড করুন।',
    ar: 'سجّل المزيد من بيانات الوزن والتغذية لبدء توقع موثوق.',
  );

  static String _text(
    BuildContext context, {
    required String vi,
    required String en,
    required String ko,
    required String ja,
    required String zh,
    required String es,
    required String fr,
    required String pt,
    required String ru,
    required String hi,
    required String bn,
    required String ar,
  }) {
    return switch (languageCode(context)) {
      'vi' => vi,
      'ko' => ko,
      'ja' => ja,
      'zh' => zh,
      'es' => es,
      'fr' => fr,
      'pt' => pt,
      'ru' => ru,
      'hi' => hi,
      'bn' => bn,
      'ar' => ar,
      _ => en,
    };
  }

  static const _bmi = <String, Map<String, String>>{
    'en': {
      'underweight': 'Underweight',
      'normal': 'Normal',
      'overweight': 'Overweight',
      'obese': 'Obese',
    },
    'vi': {
      'underweight': 'Thiếu cân',
      'normal': 'Bình thường',
      'overweight': 'Thừa cân',
      'obese': 'Béo phì',
    },
    'ko': {
      'underweight': '저체중',
      'normal': '정상',
      'overweight': '과체중',
      'obese': '비만',
    },
    'ja': {
      'underweight': '低体重',
      'normal': '標準',
      'overweight': '過体重',
      'obese': '肥満',
    },
    'zh': {
      'underweight': '体重不足',
      'normal': '正常',
      'overweight': '超重',
      'obese': '肥胖',
    },
    'es': {
      'underweight': 'Bajo peso',
      'normal': 'Normal',
      'overweight': 'Sobrepeso',
      'obese': 'Obesidad',
    },
    'fr': {
      'underweight': 'Poids insuffisant',
      'normal': 'Normal',
      'overweight': 'Surpoids',
      'obese': 'Obésité',
    },
    'pt': {
      'underweight': 'Abaixo do peso',
      'normal': 'Normal',
      'overweight': 'Sobrepeso',
      'obese': 'Obesidade',
    },
    'ru': {
      'underweight': 'Недостаточный вес',
      'normal': 'Норма',
      'overweight': 'Избыточный вес',
      'obese': 'Ожирение',
    },
    'hi': {
      'underweight': 'कम वजन',
      'normal': 'सामान्य',
      'overweight': 'अधिक वजन',
      'obese': 'मोटापा',
    },
    'bn': {
      'underweight': 'কম ওজন',
      'normal': 'স্বাভাবিক',
      'overweight': 'অতিরিক্ত ওজন',
      'obese': 'স্থূলতা',
    },
    'ar': {
      'underweight': 'نقص الوزن',
      'normal': 'طبيعي',
      'overweight': 'زيادة الوزن',
      'obese': 'السمنة',
    },
  };

  static const _achievements = <String, Map<String, (String, String)>>{
    'en': {
      'first_scan': ('Bright Start', 'Record your first meal'),
      'scan_master': ('Scan Master', 'Scan 10 meals with AI'),
      'protein_king': ('Protein King', 'Reach 100% of your daily protein goal'),
      'streak_7': ('7-Day Streak', 'Log meals for 7 consecutive days'),
      'calo_champ': (
        'Calorie Champion',
        'Reach your calorie goal for 5 consecutive days',
      ),
      'legend': ('CalGo Legend', 'Reach level 10'),
    },
    'vi': {
      'first_scan': ('Khởi đầu rực rỡ', 'Ghi nhận bữa ăn đầu tiên'),
      'scan_master': ('Chuyên gia Scan', 'Quét đủ 10 bữa ăn bằng AI'),
      'protein_king': ('Vua Protein', 'Đạt 100% mục tiêu đạm trong ngày'),
      'streak_7': ('7 Ngày Siêu Cấp', 'Duy trì ghi chép liên tục 7 ngày'),
      'calo_champ': ('Chiến Thắng Calo', 'Đạt mục tiêu Calo 5 ngày liên tiếp'),
      'legend': ('Huyền Thoại CalGo', 'Đạt Cấp độ 10'),
    },
    'ko': {
      'first_scan': ('멋진 시작', '첫 식사를 기록하세요'),
      'scan_master': ('스캔 마스터', 'AI로 식사 10개를 스캔하세요'),
      'protein_king': ('단백질 왕', '하루 단백질 목표의 100% 달성'),
      'streak_7': ('7일 연속 기록', '7일 연속 식사를 기록하세요'),
      'calo_champ': ('칼로리 챔피언', '5일 연속 칼로리 목표 달성'),
      'legend': ('CalGo 전설', '레벨 10 달성'),
    },
    'ja': {
      'first_scan': ('輝かしいスタート', '最初の食事を記録'),
      'scan_master': ('スキャンマスター', 'AIで10食をスキャン'),
      'protein_king': ('プロテインキング', '1日のたんぱく質目標を100%達成'),
      'streak_7': ('7日間連続', '7日連続で食事を記録'),
      'calo_champ': ('カロリーチャンピオン', '5日連続でカロリー目標を達成'),
      'legend': ('CalGoレジェンド', 'レベル10に到達'),
    },
    'zh': {
      'first_scan': ('精彩开始', '记录第一餐'),
      'scan_master': ('扫描达人', '用 AI 扫描 10 餐'),
      'protein_king': ('蛋白质之王', '达到每日蛋白质目标的 100%'),
      'streak_7': ('连续 7 天', '连续 7 天记录饮食'),
      'calo_champ': ('热量冠军', '连续 5 天达到热量目标'),
      'legend': ('CalGo 传奇', '达到 10 级'),
    },
    'es': {
      'first_scan': ('Gran comienzo', 'Registra tu primera comida'),
      'scan_master': ('Maestro del escaneo', 'Escanea 10 comidas con IA'),
      'protein_king': (
        'Rey de la proteína',
        'Alcanza el 100% de tu objetivo diario de proteína',
      ),
      'streak_7': (
        'Racha de 7 días',
        'Registra comidas durante 7 días seguidos',
      ),
      'calo_champ': (
        'Campeón de calorías',
        'Alcanza tu objetivo calórico 5 días seguidos',
      ),
      'legend': ('Leyenda CalGo', 'Alcanza el nivel 10'),
    },
    'fr': {
      'first_scan': ('Excellent départ', 'Enregistrez votre premier repas'),
      'scan_master': ('Maître du scan', 'Scannez 10 repas avec l’IA'),
      'protein_king': (
        'Roi des protéines',
        'Atteignez 100 % de votre objectif quotidien',
      ),
      'streak_7': ('Série de 7 jours', 'Notez vos repas 7 jours de suite'),
      'calo_champ': (
        'Champion des calories',
        'Atteignez votre objectif 5 jours de suite',
      ),
      'legend': ('Légende CalGo', 'Atteignez le niveau 10'),
    },
    'pt': {
      'first_scan': ('Começo brilhante', 'Registre sua primeira refeição'),
      'scan_master': ('Mestre do scan', 'Escaneie 10 refeições com IA'),
      'protein_king': (
        'Rei da proteína',
        'Alcance 100% da meta diária de proteína',
      ),
      'streak_7': (
        'Sequência de 7 dias',
        'Registre refeições por 7 dias seguidos',
      ),
      'calo_champ': (
        'Campeão das calorias',
        'Alcance a meta por 5 dias seguidos',
      ),
      'legend': ('Lenda CalGo', 'Alcance o nível 10'),
    },
    'ru': {
      'first_scan': ('Яркий старт', 'Запишите первый приём пищи'),
      'scan_master': ('Мастер сканирования', 'Отсканируйте 10 блюд с ИИ'),
      'protein_king': (
        'Белковый чемпион',
        'Достигните 100% дневной цели белка',
      ),
      'streak_7': ('Серия 7 дней', 'Записывайте питание 7 дней подряд'),
      'calo_champ': ('Чемпион калорий', 'Достигайте цели 5 дней подряд'),
      'legend': ('Легенда CalGo', 'Достигните 10 уровня'),
    },
    'hi': {
      'first_scan': ('शानदार शुरुआत', 'अपना पहला भोजन दर्ज करें'),
      'scan_master': ('स्कैन मास्टर', 'AI से 10 भोजन स्कैन करें'),
      'protein_king': (
        'प्रोटीन किंग',
        'दैनिक प्रोटीन लक्ष्य का 100% पूरा करें',
      ),
      'streak_7': ('7 दिन की स्ट्रीक', 'लगातार 7 दिन भोजन दर्ज करें'),
      'calo_champ': ('कैलोरी चैंपियन', 'लगातार 5 दिन कैलोरी लक्ष्य पूरा करें'),
      'legend': ('CalGo लीजेंड', 'लेवल 10 तक पहुँचें'),
    },
    'bn': {
      'first_scan': ('দারুণ শুরু', 'প্রথম খাবার রেকর্ড করুন'),
      'scan_master': ('স্ক্যান মাস্টার', 'AI দিয়ে ১০টি খাবার স্ক্যান করুন'),
      'protein_king': ('প্রোটিন কিং', 'দৈনিক প্রোটিন লক্ষ্যের ১০০% পূরণ করুন'),
      'streak_7': ('৭ দিনের ধারাবাহিকতা', 'টানা ৭ দিন খাবার রেকর্ড করুন'),
      'calo_champ': (
        'ক্যালরি চ্যাম্পিয়ন',
        'টানা ৫ দিন ক্যালরি লক্ষ্য পূরণ করুন',
      ),
      'legend': ('CalGo কিংবদন্তি', 'লেভেল ১০-এ পৌঁছান'),
    },
    'ar': {
      'first_scan': ('بداية رائعة', 'سجّل وجبتك الأولى'),
      'scan_master': ('خبير المسح', 'امسح 10 وجبات بالذكاء الاصطناعي'),
      'protein_king': ('ملك البروتين', 'حقق 100% من هدف البروتين اليومي'),
      'streak_7': ('سلسلة 7 أيام', 'سجّل وجباتك 7 أيام متتالية'),
      'calo_champ': ('بطل السعرات', 'حقق هدف السعرات 5 أيام متتالية'),
      'legend': ('أسطورة CalGo', 'الوصول إلى المستوى 10'),
    },
  };
}
