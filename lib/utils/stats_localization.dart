import 'package:flutter/widgets.dart';

import '../models/meal_guidance.dart';
import 'weight_forecast.dart';

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
      'ro': const [
        '',
        'Începător',
        'Observator',
        'Perseverent',
        'Disciplinat',
        'Entuziast',
        'Pasionat de sănătate',
        'Expert în nutriție',
        'Campion',
        'Legendă',
        'Maestru CalGo',
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
      case 'ro':
        return '$days zile';
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
      'ro': const ['Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm', 'Dum'],
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
      'ro': const [
        '',
        'Ian',
        'Feb',
        'Mar',
        'Apr',
        'Mai',
        'Iun',
        'Iul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
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
      case 'ro':
        return 'Cu o medie de $calories kcal/zi, ai putea atinge $target kg în aproximativ $weeks.';
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

  static String caloriePeriodLabel(
    BuildContext context, {
    required bool weekly,
  }) => _text(
    context,
    vi: weekly ? 'trung bình 7 ngày qua' : 'hôm nay',
    en: weekly ? 'the past 7-day average' : 'today',
    ko: weekly ? '최근 7일 평균' : '오늘',
    ja: weekly ? '過去7日間の平均' : '今日',
    zh: weekly ? '过去7天平均' : '今天',
    es: weekly ? 'el promedio de los últimos 7 días' : 'hoy',
    fr: weekly ? 'la moyenne des 7 derniers jours' : "aujourd’hui",
    pt: weekly ? 'a média dos últimos 7 dias' : 'hoje',
    ru: weekly ? 'среднем за последние 7 дней' : 'сегодня',
    hi: weekly ? 'पिछले 7 दिनों के औसत' : 'आज',
    bn: weekly ? 'গত ৭ দিনের গড়' : 'আজ',
    ar: weekly ? 'متوسط آخر 7 أيام' : 'اليوم',
  );

  static String forecastStatusTitle(
    BuildContext context,
    WeightForecast forecast,
  ) {
    return switch (forecast.status) {
      WeightForecastStatus.noData => _text(
        context,
        vi: 'Chưa có dữ liệu calo',
        en: 'No calorie data yet',
        ko: '아직 칼로리 데이터가 없어요',
        ja: 'カロリーデータがありません',
        zh: '暂无热量数据',
        es: 'Aún no hay datos de calorías',
        fr: 'Aucune donnée calorique',
        pt: 'Ainda não há dados de calorias',
        ru: 'Пока нет данных о калориях',
        hi: 'अभी कैलोरी डेटा नहीं है',
        bn: 'এখনও ক্যালোরির তথ্য নেই',
        ar: 'لا توجد بيانات سعرات بعد',
      ),
      WeightForecastStatus.reached => forecastGoalReachedTitle(context),
      WeightForecastStatus.healthy => forecastOnTrackTitle(context),
      WeightForecastStatus.slow => _text(
        context,
        vi: 'Đang tiến bộ chậm nhưng ổn định',
        en: 'Progressing slowly but steadily',
        ko: '느리지만 꾸준히 진행 중',
        ja: 'ゆっくりですが順調です',
        zh: '进展较慢但稳定',
        es: 'Progreso lento pero constante',
        fr: 'Progression lente mais régulière',
        pt: 'Progresso lento, mas constante',
        ru: 'Медленный, но стабильный прогресс',
        hi: 'धीमी लेकिन स्थिर प्रगति',
        bn: 'ধীর কিন্তু স্থির অগ্রগতি',
        ar: 'تقدم بطيء لكنه ثابت',
      ),
      WeightForecastStatus.aggressiveDeficit => _text(
        context,
        vi: 'Thâm hụt calo quá mức',
        en: 'Calorie deficit is too high',
        ko: '칼로리 적자가 너무 커요',
        ja: 'カロリー赤字が大きすぎます',
        zh: '热量缺口过大',
        es: 'El déficit calórico es demasiado alto',
        fr: 'Déficit calorique trop élevé',
        pt: 'Déficit calórico muito alto',
        ru: 'Слишком большой дефицит калорий',
        hi: 'कैलोरी की कमी बहुत अधिक है',
        bn: 'ক্যালোরির ঘাটতি খুব বেশি',
        ar: 'عجز السعرات مرتفع جدًا',
      ),
      WeightForecastStatus.aggressiveSurplus => _text(
        context,
        vi: 'Thặng dư calo hơi cao',
        en: 'Calorie surplus is quite high',
        ko: '칼로리 흑자가 조금 높아요',
        ja: 'カロリー余剰がやや多めです',
        zh: '热量盈余偏高',
        es: 'El superávit calórico es alto',
        fr: 'Excédent calorique assez élevé',
        pt: 'Superávit calórico um pouco alto',
        ru: 'Избыток калорий довольно большой',
        hi: 'कैलोरी अधिशेष काफी अधिक है',
        bn: 'ক্যালোরির উদ্বৃত্ত বেশ বেশি',
        ar: 'فائض السعرات مرتفع نسبيًا',
      ),
      WeightForecastStatus.maintenance => _text(
        context,
        vi: 'Tiến độ đang chững lại',
        en: 'Progress is currently stalled',
        ko: '진행이 잠시 멈춰 있어요',
        ja: '進捗が一時的に停滞しています',
        zh: '进度暂时停滞',
        es: 'El progreso está estancado',
        fr: 'La progression stagne',
        pt: 'O progresso está parado',
        ru: 'Прогресс пока остановился',
        hi: 'प्रगति फिलहाल रुक गई है',
        bn: 'অগ্রগতি আপাতত থেমে আছে',
        ar: 'التقدم متوقف حاليًا',
      ),
      WeightForecastStatus.opposite => _text(
        context,
        vi: 'Đang đi ngược mục tiêu',
        en: 'Moving away from your goal',
        ko: '목표에서 멀어지고 있어요',
        ja: '目標から遠ざかっています',
        zh: '正在偏离目标',
        es: 'Te alejas de tu objetivo',
        fr: 'Vous vous éloignez de votre objectif',
        pt: 'Você está se afastando da meta',
        ru: 'Вы удаляетесь от цели',
        hi: 'आप अपने लक्ष्य से दूर जा रहे हैं',
        bn: 'আপনি আপনার লক্ষ্য থেকে দূরে সরে যাচ্ছেন',
        ar: 'أنت تبتعد عن هدفك',
      ),
    };
  }

  static String forecastStatusBody(
    BuildContext context,
    WeightForecast forecast, {
    required String periodLabel,
    required String weeksLabel,
    required int recommendedCalories,
  }) {
    final calories = forecast.calories.round();
    final target = forecast.targetWeight.toStringAsFixed(1);
    final balance = forecast.dailyBalance.abs().round();
    final code = languageCode(context);
    final isUp = forecast.isMovingUp;

    switch (code) {
      case 'vi':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Hãy ghi nhận bữa ăn để bắt đầu dự báo theo lượng calo thực tế.',
          WeightForecastStatus.reached =>
            'Hãy duy trì mức calo và thói quen hiện tại để giữ cân ổn định.',
          WeightForecastStatus.healthy =>
            'Với $periodLabel khoảng $calories kcal/ngày, bạn đang tạo ${forecast.goal == 'lose' ? 'thâm hụt' : 'thặng dư'} khoảng $balance kcal/ngày. Nếu duy trì, bạn có thể đạt $target kg trong khoảng $weeksLabel nữa.',
          WeightForecastStatus.slow =>
            'Bạn vẫn đang đi đúng hướng nhưng mức ${forecast.goal == 'lose' ? 'thâm hụt' : 'thặng dư'} còn nhẹ. Cân nặng sẽ thay đổi chậm hơn và có thể cần lâu hơn để đạt $target kg.',
          WeightForecastStatus.aggressiveDeficit =>
            'Bạn đang nạp khoảng $calories kcal/ngày. Mức thâm hụt hiện tại có thể không an toàn và không nên dùng để giảm cân nhanh hơn. Hãy tăng dần về khoảng $recommendedCalories kcal/ngày.',
          WeightForecastStatus.aggressiveSurplus =>
            'Bạn đang nạp cao hơn mức duy trì khoảng $balance kcal/ngày. Cân nặng có thể tăng nhanh hơn kế hoạch; hãy điều chỉnh về mức thặng dư vừa phải.',
          WeightForecastStatus.maintenance =>
            'Lượng calo hiện tại gần bằng mức duy trì. Nếu tiếp tục như vậy, cân nặng có thể không thay đổi đáng kể.',
          WeightForecastStatus.opposite =>
            'Bạn đang nạp ${isUp ? 'cao hơn' : 'thấp hơn'} mức duy trì khoảng $balance kcal/ngày. Nếu tiếp tục, cân nặng sẽ có xu hướng ${isUp ? 'tăng' : 'giảm'} và mục tiêu $target kg sẽ khó đạt hơn.',
        };
      case 'ko':
        return switch (forecast.status) {
          WeightForecastStatus.noData => '식사를 기록하면 실제 섭취량을 바탕으로 예측을 시작할 수 있어요.',
          WeightForecastStatus.reached => '현재 섭취량과 습관을 유지해 체중을 안정적으로 유지하세요.',
          WeightForecastStatus.healthy =>
            '$periodLabel 약 $calories kcal를 유지하면 약 $weeksLabel 후 $target kg에 도달할 수 있어요.',
          WeightForecastStatus.slow =>
            '목표 방향으로 가고 있지만 ${forecast.goal == 'lose' ? '적자' : '흑자'}가 작아요. 목표까지 더 오래 걸릴 수 있어요.',
          WeightForecastStatus.aggressiveDeficit =>
            '하루 약 $calories kcal를 섭취하고 있어요. 현재 적자는 안전하지 않을 수 있어요. 약 $recommendedCalories kcal까지 서서히 늘려 보세요.',
          WeightForecastStatus.aggressiveSurplus =>
            '유지 칼로리보다 약 $balance kcal를 더 섭취하고 있어요. 체중이 계획보다 빠르게 늘 수 있어요.',
          WeightForecastStatus.maintenance =>
            '현재 섭취량이 유지 칼로리와 비슷해 체중 변화가 크지 않을 수 있어요.',
          WeightForecastStatus.opposite =>
            '현재 섭취량으로는 체중이 목표에서 ${isUp ? '늘어나며' : '줄어들며'} 멀어질 수 있어요.',
        };
      case 'ja':
        return switch (forecast.status) {
          WeightForecastStatus.noData => '食事を記録すると、実際の摂取量に基づく予測を始められます。',
          WeightForecastStatus.reached => '現在の食事量と習慣を続けて、体重を安定させましょう。',
          WeightForecastStatus.healthy =>
            '$periodLabel $calories kcal前後を続けると、約$weeksLabelで$target kgに到達できます。',
          WeightForecastStatus.slow =>
            '目標の方向には進んでいますが、変化はゆっくりです。目標まで時間がかかる可能性があります。',
          WeightForecastStatus.aggressiveDeficit =>
            '現在の摂取量は約$calories kcalです。赤字が大きすぎる可能性があるため、約$recommendedCalories kcalまで少しずつ増やしましょう。',
          WeightForecastStatus.aggressiveSurplus =>
            '維持カロリーを約$balance kcal上回っています。計画より早く体重が増える可能性があります。',
          WeightForecastStatus.maintenance =>
            '摂取量が維持カロリーに近いため、体重は大きく変わらない可能性があります。',
          WeightForecastStatus.opposite => 'この摂取量を続けると、体重が目標から遠ざかる可能性があります。',
        };
      case 'zh':
        return switch (forecast.status) {
          WeightForecastStatus.noData => '记录一餐后，我们就能根据实际摄入量开始预测。',
          WeightForecastStatus.reached => '保持当前摄入量和习惯，稳定维持体重。',
          WeightForecastStatus.healthy =>
            '按$periodLabel每天约摄入 $calories kcal，预计约 $weeksLabel 后达到 $target kg。',
          WeightForecastStatus.slow => '你正在朝目标前进，但热量差较小，达到 $target kg 可能需要更久。',
          WeightForecastStatus.aggressiveDeficit =>
            '你每天约摄入 $calories kcal，热量缺口可能过大。建议逐步提高到约 $recommendedCalories kcal。',
          WeightForecastStatus.aggressiveSurplus =>
            '你每天比维持所需多摄入约 $balance kcal，体重可能增长过快。',
          WeightForecastStatus.maintenance => '当前摄入接近维持水平，体重可能不会有明显变化。',
          WeightForecastStatus.opposite =>
            '按当前摄入，体重可能${isUp ? '增加' : '减少'}，并进一步偏离 $target kg。',
        };
      case 'es':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Registra una comida para empezar una previsión basada en tu ingesta real.',
          WeightForecastStatus.reached =>
            'Mantén tu ingesta y tus hábitos actuales para conservar el resultado.',
          WeightForecastStatus.healthy =>
            'Con $periodLabel de unos $calories kcal al día, podrías alcanzar $target kg en aproximadamente $weeksLabel.',
          WeightForecastStatus.slow =>
            'Avanzas hacia tu objetivo, pero el balance calórico es pequeño. Podrías tardar más en llegar a $target kg.',
          WeightForecastStatus.aggressiveDeficit =>
            'Estás consumiendo unas $calories kcal al día. Este déficit podría no ser seguro. Acércate poco a poco a $recommendedCalories kcal.',
          WeightForecastStatus.aggressiveSurplus =>
            'Consumes unas $balance kcal al día por encima del mantenimiento. Tu peso podría subir más rápido de lo previsto.',
          WeightForecastStatus.maintenance =>
            'Tu ingesta está cerca del mantenimiento, por lo que tu peso podría cambiar poco.',
          WeightForecastStatus.opposite =>
            'Con esta ingesta, tu peso podría ${isUp ? 'subir' : 'bajar'} y alejarse de $target kg.',
        };
      case 'fr':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Enregistrez un repas pour commencer une prévision basée sur votre apport réel.',
          WeightForecastStatus.reached =>
            'Conservez votre apport et vos habitudes actuels pour stabiliser votre poids.',
          WeightForecastStatus.healthy =>
            'Avec $periodLabel autour de $calories kcal par jour, vous pourriez atteindre $target kg dans environ $weeksLabel.',
          WeightForecastStatus.slow =>
            'Vous avancez vers votre objectif, mais l’écart calorique est faible. L’objectif $target kg peut prendre plus de temps.',
          WeightForecastStatus.aggressiveDeficit =>
            'Vous consommez environ $calories kcal par jour. Ce déficit peut être trop important. Revenez progressivement vers $recommendedCalories kcal.',
          WeightForecastStatus.aggressiveSurplus =>
            'Vous dépassez le maintien d’environ $balance kcal par jour. Votre poids pourrait augmenter trop vite.',
          WeightForecastStatus.maintenance =>
            'Votre apport est proche du maintien, votre poids pourrait donc peu changer.',
          WeightForecastStatus.opposite =>
            'Avec cet apport, votre poids pourrait ${isUp ? 'augmenter' : 'diminuer'} et s’éloigner de $target kg.',
        };
      case 'pt':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Registre uma refeição para iniciar uma previsão baseada no seu consumo real.',
          WeightForecastStatus.reached =>
            'Mantenha o consumo e os hábitos atuais para estabilizar o peso.',
          WeightForecastStatus.healthy =>
            'Com $periodLabel de cerca de $calories kcal por dia, você pode chegar a $target kg em aproximadamente $weeksLabel.',
          WeightForecastStatus.slow =>
            'Você está avançando, mas o saldo calórico é pequeno. Pode levar mais tempo para chegar a $target kg.',
          WeightForecastStatus.aggressiveDeficit =>
            'Você está consumindo cerca de $calories kcal por dia. Esse déficit pode não ser seguro. Aumente gradualmente até $recommendedCalories kcal.',
          WeightForecastStatus.aggressiveSurplus =>
            'Você consome cerca de $balance kcal por dia acima da manutenção. O peso pode subir mais rápido que o planejado.',
          WeightForecastStatus.maintenance =>
            'Seu consumo está próximo da manutenção, então o peso pode mudar pouco.',
          WeightForecastStatus.opposite =>
            'Com esse consumo, seu peso pode ${isUp ? 'aumentar' : 'diminuir'} e se afastar de $target kg.',
        };
      case 'ru':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Запишите приём пищи, чтобы начать прогноз по фактическому рациону.',
          WeightForecastStatus.reached =>
            'Сохраняйте текущий рацион и привычки, чтобы удерживать результат.',
          WeightForecastStatus.healthy =>
            'При $periodLabel около $calories ккал в день вы можете достичь $target кг примерно за $weeksLabel.',
          WeightForecastStatus.slow =>
            'Вы движетесь к цели, но разница калорий небольшая. Достижение $target кг может занять больше времени.',
          WeightForecastStatus.aggressiveDeficit =>
            'Вы употребляете около $calories ккал в день. Такой дефицит может быть небезопасным. Постепенно приблизьтесь к $recommendedCalories ккал.',
          WeightForecastStatus.aggressiveSurplus =>
            'Вы получаете примерно на $balance ккал в день больше уровня поддержания. Вес может расти слишком быстро.',
          WeightForecastStatus.maintenance =>
            'Ваш рацион близок к уровню поддержания, поэтому вес может почти не меняться.',
          WeightForecastStatus.opposite =>
            'При таком рационе вес может ${isUp ? 'увеличиваться' : 'снижаться'} и удаляться от $target кг.',
        };
      case 'hi':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'वास्तविक सेवन के आधार पर पूर्वानुमान शुरू करने के लिए भोजन दर्ज करें।',
          WeightForecastStatus.reached =>
            'परिणाम बनाए रखने के लिए अपना वर्तमान सेवन और आदतें जारी रखें।',
          WeightForecastStatus.healthy =>
            '$periodLabel लगभग $calories kcal प्रतिदिन रखने पर आप लगभग $weeksLabel में $target kg तक पहुँच सकते हैं।',
          WeightForecastStatus.slow =>
            'आप लक्ष्य की ओर बढ़ रहे हैं, लेकिन कैलोरी अंतर कम है। $target kg तक पहुँचने में अधिक समय लग सकता है।',
          WeightForecastStatus.aggressiveDeficit =>
            'आप लगभग $calories kcal प्रतिदिन ले रहे हैं। यह कमी सुरक्षित नहीं हो सकती। धीरे-धीरे $recommendedCalories kcal तक बढ़ाएँ।',
          WeightForecastStatus.aggressiveSurplus =>
            'आप रखरखाव स्तर से लगभग $balance kcal अधिक ले रहे हैं। वजन योजना से तेज़ी से बढ़ सकता है।',
          WeightForecastStatus.maintenance =>
            'आपका सेवन रखरखाव स्तर के करीब है, इसलिए वजन में अधिक बदलाव नहीं हो सकता।',
          WeightForecastStatus.opposite =>
            'इस सेवन पर वजन ${isUp ? 'बढ़' : 'घट'} सकता है और $target kg से दूर जा सकता है।',
        };
      case 'bn':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'বাস্তব গ্রহণের ভিত্তিতে পূর্বাভাস শুরু করতে একটি খাবার রেকর্ড করুন।',
          WeightForecastStatus.reached =>
            'ফল ধরে রাখতে বর্তমান গ্রহণ ও অভ্যাস বজায় রাখুন।',
          WeightForecastStatus.healthy =>
            '$periodLabel প্রতিদিন প্রায় $calories kcal রাখলে প্রায় $weeksLabel-এ $target kg-এ পৌঁছাতে পারেন।',
          WeightForecastStatus.slow =>
            'আপনি লক্ষ্যের দিকে এগোচ্ছেন, তবে ক্যালোরির পার্থক্য কম। $target kg-এ পৌঁছাতে বেশি সময় লাগতে পারে।',
          WeightForecastStatus.aggressiveDeficit =>
            'আপনি প্রতিদিন প্রায় $calories kcal নিচ্ছেন। এই ঘাটতি নিরাপদ নাও হতে পারে। ধীরে ধীরে $recommendedCalories kcal-এর দিকে বাড়ান।',
          WeightForecastStatus.aggressiveSurplus =>
            'আপনি রক্ষণাবেক্ষণ মাত্রার চেয়ে প্রতিদিন প্রায় $balance kcal বেশি নিচ্ছেন। ওজন পরিকল্পনার চেয়ে দ্রুত বাড়তে পারে।',
          WeightForecastStatus.maintenance =>
            'আপনার গ্রহণ রক্ষণাবেক্ষণ মাত্রার কাছাকাছি, তাই ওজনের পরিবর্তন কম হতে পারে।',
          WeightForecastStatus.opposite =>
            'এই গ্রহণে ওজন ${isUp ? 'বাড়তে' : 'কমতে'} পারে এবং $target kg থেকে দূরে সরে যেতে পারে।',
        };
      case 'ar':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'سجّل وجبة لبدء توقع يعتمد على مدخولك الفعلي.',
          WeightForecastStatus.reached =>
            'حافظ على مدخولك وعاداتك الحالية للحفاظ على النتيجة.',
          WeightForecastStatus.healthy =>
            'مع $periodLabel بنحو $calories سعرة يوميًا، يمكنك الوصول إلى $target كجم خلال نحو $weeksLabel.',
          WeightForecastStatus.slow =>
            'أنت تتقدم نحو هدفك، لكن الفارق في السعرات صغير. قد يستغرق الوصول إلى $target كجم وقتًا أطول.',
          WeightForecastStatus.aggressiveDeficit =>
            'تتناول نحو $calories سعرة يوميًا. قد لا يكون هذا العجز آمنًا. زد المدخول تدريجيًا نحو $recommendedCalories سعرة.',
          WeightForecastStatus.aggressiveSurplus =>
            'تتناول نحو $balance سعرة يوميًا فوق مستوى المحافظة. قد يزيد وزنك أسرع من المخطط.',
          WeightForecastStatus.maintenance =>
            'مدخولك قريب من مستوى المحافظة، لذلك قد لا يتغير وزنك كثيرًا.',
          WeightForecastStatus.opposite =>
            'مع هذا المدخول قد ${isUp ? 'يزداد' : 'ينخفض'} وزنك ويبتعد عن $target كجم.',
        };
      case 'ro':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Înregistrează o masă pentru a începe o prognoză bazată pe aportul tău real.',
          WeightForecastStatus.reached =>
            'Păstrează aportul și obiceiurile actuale pentru a-ți menține rezultatul.',
          WeightForecastStatus.healthy =>
            'Cu $periodLabel de aproximativ $calories kcal/zi, ai putea atinge $target kg în circa $weeksLabel.',
          WeightForecastStatus.slow =>
            'Mergi în direcția bună, dar deficitul/surplusul caloric este mic. Atingerea țintei de $target kg poate dura mai mult.',
          WeightForecastStatus.aggressiveDeficit =>
            'Consumi aproximativ $calories kcal/zi. Acest deficit poate să nu fie sigur. Crește treptat spre aproximativ $recommendedCalories kcal/zi.',
          WeightForecastStatus.aggressiveSurplus =>
            'Consumi cu aproximativ $balance kcal/zi peste nivelul de menținere. Greutatea ar putea crește mai repede decât ai planificat.',
          WeightForecastStatus.maintenance =>
            'Aportul tău caloric este aproape de menținere, așa că greutatea s-ar putea să nu se schimbe prea mult.',
          WeightForecastStatus.opposite =>
            'Cu acest aport caloric, greutatea tinde să ${isUp ? 'crească' : 'scadă'} și să se îndepărteze de $target kg.',
        };
      default:
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Log a meal to start a forecast based on your actual intake.',
          WeightForecastStatus.reached =>
            'Keep your current intake and habits to maintain your result.',
          WeightForecastStatus.healthy =>
            'At about $calories kcal/day over $periodLabel, you may reach $target kg in about $weeksLabel.',
          WeightForecastStatus.slow =>
            'You are moving toward your goal, but the calorie balance is small. Reaching $target kg may take longer.',
          WeightForecastStatus.aggressiveDeficit =>
            'You are eating about $calories kcal/day. This deficit may not be safe. Gradually move toward about $recommendedCalories kcal/day.',
          WeightForecastStatus.aggressiveSurplus =>
            'You are about $balance kcal/day above maintenance. Your weight may rise faster than planned.',
          WeightForecastStatus.maintenance =>
            'Your intake is close to maintenance, so your weight may not change much.',
          WeightForecastStatus.opposite =>
            'At this intake, your weight is likely to ${isUp ? 'increase' : 'decrease'} and move farther from $target kg.',
        };
    }
  }

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
    String? ro,
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
      'ro' => ro ?? en,
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
    'ro': {
      'underweight': 'Subponderal',
      'normal': 'Normal',
      'overweight': 'Supraponderal',
      'obese': 'Obezitate',
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
    'ro': {
      'first_scan': ('Început excelent', 'Înregistrează prima ta masă'),
      'scan_master': ('Maestru al scanării', 'Scanează 10 mese cu AI'),
      'protein_king': (
        'Regele proteinelor',
        'Atinge 100% din obiectivul zilnic de proteine',
      ),
      'streak_7': (
        'Serie de 7 zile',
        'Înregistrează mese timp de 7 zile consecutive',
      ),
      'calo_champ': (
        'Campionul caloriilor',
        'Atinge obiectivul caloric 5 zile la rând',
      ),
      'legend': ('Legendă CalGo', 'Atinge nivelul 10'),
    },
  };

  // ── Meal Guidance & Transformation Forecast Localization ───────────────────

  static String mealGuidanceStatusTag(BuildContext context, String rawTag) {
    final tag = rawTag.trim();
    if (tag.isEmpty) return '';

    if (tag.contains('Đang đi đúng hướng')) {
      return _text(
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
        ro: 'Pe drumul cel bun',
      );
    }
    if (tag.contains('Cần thêm dữ liệu')) {
      return _text(
        context,
        vi: 'Cần thêm dữ liệu',
        en: 'Need more data',
        ko: '추가 데이터 필요',
        ja: 'データ不足',
        zh: '需要更多数据',
        es: 'Se necesitan más datos',
        fr: 'Plus de données nécessaires',
        pt: 'Mais dados necessários',
        ru: 'Нужно больше данных',
        hi: 'अधिक डेटा चाहिए',
        bn: 'আরও তথ্যের প্রয়োজন',
        ar: 'بحاجة لمزيد من البيانات',
        ro: 'Sunt necesare mai multe date',
      );
    }
    if (tag.contains('Chờ bữa đầu')) {
      return _text(
        context,
        vi: 'Chờ bữa đầu',
        en: 'Awaiting 1st meal',
        ko: '첫 식사 대기',
        ja: '最初の食事待ち',
        zh: '等待首餐',
        es: 'Esperando 1ª comida',
        fr: 'En attente 1er repas',
        pt: 'Aguardando 1ª refeição',
        ru: 'Ждем первый прием',
        hi: 'पहले भोजन की प्रतीक्षा',
        bn: 'প্রথম খাবারের অপেক্ষা',
        ar: 'بانتظار الوجبة الأولى',
        ro: 'Așteptare prima masă',
      );
    }
    if (tag.contains('Cần điều chỉnh') || tag.contains('Cần điều chỉnh nhẹ')) {
      return _text(
        context,
        vi: 'Cần điều chỉnh nhẹ',
        en: 'Minor adjustment',
        ko: '가벼운 조정 필요',
        ja: '少し調整が必要',
        zh: '需要微调',
        es: 'Ajuste leve',
        fr: 'Léger ajustement',
        pt: 'Pequeno ajuste',
        ru: 'Небольшая корректировка',
        hi: 'हल्का समायोजन',
        bn: 'সামান্য সমন্বয় প্রয়োজন',
        ar: 'تعديل بسيط',
        ro: 'Ajustare minoră',
      );
    }
    if (tag.contains('Cần bổ sung thêm')) {
      return _text(
        context,
        vi: 'Cần bổ sung thêm',
        en: 'Need more surplus',
        ko: '추가 보충 필요',
        ja: '追加補給が必要',
        zh: '需要补充热量',
        es: 'Necesitas más calorías',
        fr: 'Apport supplémentaire requis',
        pt: 'Precisa suplementar',
        ru: 'Нужно больше калорий',
        hi: 'और अधिक सेवन चाहिए',
        bn: 'আরও অতিরিক্ত গ্রহণ প্রয়োজন',
        ar: 'بحاجة للمزيد من السعرات',
        ro: 'E nevoie de suplimentare',
      );
    }
    if (tag.contains('Cân bằng vóc dáng')) {
      return _text(
        context,
        vi: 'Cân bằng vóc dáng',
        en: 'Balanced body',
        ko: '체형 균형 유지',
        ja: '体型バランス維持',
        zh: '平衡体态',
        es: 'Equilibrio corporal',
        fr: 'Équilibre silhouette',
        pt: 'Equilíbrio corporal',
        ru: 'Баланс формы',
        hi: 'संतुलित शारीरिक बनावट',
        bn: 'শারীরিক ভারসাম্য',
        ar: 'توازن القوام',
        ro: 'Echilibru corporal',
      );
    }
    if (tag.contains('Theo dõi thêm')) {
      return _text(
        context,
        vi: 'Theo dõi thêm',
        en: 'Keep tracking',
        ko: '추가 관찰 필요',
        ja: '継続して観察',
        zh: '持续观察',
        es: 'Seguir observando',
        fr: 'Suivre de près',
        pt: 'Acompanhar mais',
        ru: 'Продолжайте следить',
        hi: 'और ट्रैक करें',
        bn: 'আরও পর্যবেক্ষণ করুন',
        ar: 'متابعة إضافية',
        ro: 'Urmărește în continuare',
      );
    }
    if (tag.contains('Giữ nhịp chuẩn')) {
      return _text(
        context,
        vi: 'Giữ nhịp chuẩn',
        en: 'Steady pace',
        ko: '안정적인 리듬',
        ja: '安定したペース',
        zh: '保持良好节奏',
        es: 'Ritmo constante',
        fr: 'Rythme régulier',
        pt: 'Ritmo constante',
        ru: 'Стабильный ритм',
        hi: 'स्थिर लय',
        bn: 'স্থির ছন্দ',
        ar: 'إيقاع ثابت',
        ro: 'Ritm stabil',
      );
    }
    if (tag.contains('Đang tích lũy') || tag.contains('Đang tiến bộ')) {
      return _text(
        context,
        vi: 'Đang tích lũy',
        en: 'Building progress',
        ko: '진행 중',
        ja: '蓄積中',
        zh: '正在累积',
        es: 'Acumulando progreso',
        fr: 'Progression en cours',
        pt: 'Construindo progresso',
        ru: 'Набираем темп',
        hi: 'प्रगति जारी है',
        bn: 'অগ্রগতি তৈরি হচ্ছে',
        ar: 'بناء التقدم',
        ro: 'Construire progres',
      );
    }

    return tag;
  }

  static String mealGuidanceForecastMessage(
    BuildContext context,
    ProgressForecast forecast,
  ) {
    final msg = forecast.forecastMessage.trim();
    if (msg.isEmpty) return '';

    final weeks = forecast.projectedWeeksToGoal != null
        ? (forecast.projectedWeeksToGoal == forecast.projectedWeeksToGoal!.roundToDouble()
            ? forecast.projectedWeeksToGoal!.toStringAsFixed(0)
            : forecast.projectedWeeksToGoal!.toStringAsFixed(1))
        : '';
    final target = forecast.targetWeightKg != null
        ? (forecast.targetWeightKg == forecast.targetWeightKg!.roundToDouble()
            ? forecast.targetWeightKg!.toStringAsFixed(0)
            : forecast.targetWeightKg!.toStringAsFixed(1))
        : '';
    final date = forecast.projectedGoalDate ?? '';

    // Pattern 1: Initial empty state awaiting first scan
    if (msg.contains('Chụp bữa đầu tiên hôm nay') ||
        msg.contains('Hãy chụp bữa đầu tiên')) {
      return _text(
        context,
        vi: 'Hãy chụp bữa đầu tiên hôm nay để mình bắt đầu tính toán tiến trình dự báo nhé.',
        en: 'Log your first meal today to start calculating your progress forecast.',
        ko: '오늘의 첫 식사를 기록하여 진행 상황 예측 계산을 시작해보세요.',
        ja: '今日の最初の食事を記録して、進捗予測の計算を始めましょう。',
        zh: '记录今天的首餐，即可开始计算进度预测。',
        es: 'Registra tu primera comida de hoy para calcular tu previsión de progreso.',
        fr: 'Enregistrez votre premier repas aujourd’hui pour calculer votre progression.',
        pt: 'Registre sua primeira refeição de hoje para calcular a previsão de progresso.',
        ru: 'Запишите первый приём пищи за сегодня, чтобы рассчитать прогноз прогресса.',
        hi: 'प्रगति पूर्वानुमान की गणना शुरू करने के लिए आज का अपना पहला भोजन दर्ज करें।',
        bn: 'অগ্রগতির পূর্বাভাস গণনা শুরু করতে আজকের প্রথম খাবারটি রেকর্ড করুন।',
        ar: 'سجّل وجبتك الأولى اليوم لبدء حساب توقعات تقدمك.',
        ro: 'Înregistrează prima masă de azi pentru a calcula prognoza progresului.',
      );
    }

    // Pattern 2: On track with projected weeks & target weight
    if (msg.contains('Nếu duy trì mức nạp khoảng') && weeks.isNotEmpty && target.isNotEmpty) {
      final code = languageCode(context);
      final isLoss = forecast.goalType == 'lose';
      final dateSuffix = date.isNotEmpty ? ' ($date)' : '';

      switch (code) {
        case 'vi':
          return isLoss
              ? 'Nếu duy trì mức nạp như hôm nay, bạn ước tính sẽ đạt $target kg sau khoảng $weeks tuần$dateSuffix.'
              : 'Nếu duy trì mức nạp như hôm nay, bạn ước tính sẽ đạt $target kg sau khoảng $weeks tuần$dateSuffix.';
        case 'ko':
          return '오늘과 같은 섭취량을 유지하면 약 $weeks주 후 $target kg에 도달할 것으로 예상됩니다$dateSuffix.';
        case 'ja':
          return '今日のような摂取量を維持すると、約$weeks週間で$target kgに到達する見込みです$dateSuffix。';
        case 'zh':
          return '保持今天的摄入水平，预计约 $weeks 周后达到 $target kg$dateSuffix。';
        case 'es':
          return 'Si mantienes la ingesta de hoy, se estima que alcanzarás $target kg en unas $weeks semanas$dateSuffix.';
        case 'fr':
          return 'En maintenant l’apport d’aujourd’hui, vous devriez atteindre $target kg en environ $weeks semaines$dateSuffix.';
        case 'pt':
          return 'Mantendo o consumo de hoje, estima-se que você alcance $target kg em cerca de $weeks semanas$dateSuffix.';
        case 'ru':
          return 'Сохраняя сегодняшнее питание, вы достигнете $target кг примерно за $weeks нед.$dateSuffix.';
        case 'hi':
          return 'यदि आप आज जैसा सेवन जारी रखते हैं, तो लगभग $weeks सप्ताह में $target kg तक पहुँचने का अनुमान है$dateSuffix।';
        case 'bn':
          return 'আজকের মতো গ্রহণ বজায় রাখলে আনুমানিক $weeks সপ্তাহে $target kg-এ পৌঁছাতে পারেন$dateSuffix।';
        case 'ar':
          return 'إذا حافظت على مدخول اليوم، فمن المتوقع أن تصل إلى $target كجم خلال نحو $weeks أسبوعًا$dateSuffix.';
        case 'ro':
          return 'Dacă menții aportul de azi, se estimează că vei atinge $target kg în circa $weeks săptămâni$dateSuffix.';
        default:
          return 'Maintaining today’s intake, you are projected to reach $target kg in about $weeks weeks$dateSuffix.';
      }
    }

    // Pattern 3: Low intake ratio - Need more data
    if (msg.contains('chưa muốn đoán thời gian') ||
        msg.contains('thấp hơn kế hoạch khá nhiều')) {
      return _text(
        context,
        vi: 'Lượng calo hôm nay còn khá thấp so với kế hoạch. Hãy ghi đủ các bữa để CalGo dự báo chính xác hơn.',
        en: 'Today’s intake is lower than planned. Log all your meals for a more accurate forecast.',
        ko: '오늘 섭취량이 계획보다 적습니다. 더 정확한 예측을 위해 모든 식사를 기록해주세요.',
        ja: '今日の摂取量は計画より少なめです。より正確な予測のためにすべての食事を記録してください。',
        zh: '今天的摄入量低于计划。请完整记录所有餐次以获得更准确的预测。',
        es: 'La ingesta de hoy es menor de lo planeado. Registra todas tus comidas para una previsión más precisa.',
        fr: 'L’apport d’aujourd’hui est inférieur aux prévisions. Notez tous vos repas pour une prévision plus précise.',
        pt: 'A ingestão de hoje está abaixo do planejado. Registre todas as refeições para uma previsão mais precisa.',
        ru: 'Сегодняшний рацион ниже плана. Записывайте все приёмы пищи для точного прогноза.',
        hi: 'आज का सेवन योजना से कम है। अधिक सटीक पूर्वानुमान के लिए अपने सभी भोजन दर्ज करें।',
        bn: 'আজকের গ্রহণ পরিকল্পনার চেয়ে কম। আরও সঠিক পূর্বাভাসে জন্য সব খাবার রেকর্ড করুন।',
        ar: 'مدخول اليوم أقل من المخطط. سجّل جميع وجباتك للحصول على توقع أكثر دقة.',
        ro: 'Aportul de azi este mai mic decât planul. Înregistrează toate mesele pentru o prognoză mai exactă.',
      );
    }

    // Pattern 4: Deficit too small / progress needs more days
    if (msg.contains('Mức thâm hụt thực tế chỉ khoảng') ||
        msg.contains('mức thặng dư chỉ khoảng') ||
        msg.contains('Chưa đủ dữ liệu để dự báo chắc chắn')) {
      return _text(
        context,
        vi: 'Chênh lệch calo hôm nay còn nhỏ. Hãy tiếp tục ghi nhận thêm vài ngày để dự báo rõ nét hơn.',
        en: 'Today’s calorie balance is small. Keep logging for a few more days for a clearer projection.',
        ko: '오늘의 칼로리 차이가 작습니다. 더 명확한 예측을 위해 며칠 더 꾸준히 기록해주세요.',
        ja: '今日のカロリー差は小さめです。より明確な予測のため、数日間記録を続けてみましょう。',
        zh: '今天的热量差较小。请再记录几天以获得更清晰的预测。',
        es: 'El balance de hoy es pequeño. Sigue registrando unos días más para una proyección más clara.',
        fr: 'L’équilibre d’aujourd’hui est léger. Continuez à noter quelques jours pour une prévision plus claire.',
        pt: 'O balanço de hoje é pequeno. Continue registrando mais alguns dias para uma projeção mais clara.',
        ru: 'Разница калорий за сегодня невелика. Записывайте питание ещё несколько дней для чёткого прогноза.',
        hi: 'आज का कैलोरी संतुलन कम है। स्पष्ट अनुमान के लिए कुछ और दिनों तक रिकॉर्ड करते रहें।',
        bn: 'আজকের ক্যালোরির ব্যবধান কম। স্পষ্ট পূর্বাভাসের জন্য আরও কয়েক দিন রেকর্ড চালিয়ে যান।',
        ar: 'فارق السعرات اليوم صغير. واصل التسجيل لبضعة أيام أخرى للحصول على توقع أوضح.',
        ro: 'Balanța de azi este mică. Înregistrează încă câteva zile pentru o proiecție mai clară.',
      );
    }

    // Pattern 5: Calorie surplus on weight loss
    if (msg.contains('cao hơn mức tiêu hao ước tính') ||
        msg.contains('tiến độ giảm cân chưa bắt đầu')) {
      return _text(
        context,
        vi: 'Lượng nạp hôm nay cao hơn mức tiêu hao. Hãy điều chỉnh nhẹ lại vào ngày mai để tiếp tục tiến trình.',
        en: 'Today’s intake exceeded estimated burn. Make a gentle adjustment tomorrow to stay on track.',
        ko: '오늘 섭취량이 예상 소비량보다 높습니다. 내일 가볍게 조절하여 페이스를 되찾아보세요.',
        ja: '今日の摂取量が推定消費量を上回りました。明日少し調整してペースを維持しましょう。',
        zh: '今天摄入量高于预估消耗。明天稍作调整即可重回正轨。',
        es: 'La ingesta de hoy superó el gasto estimado. Ajusta suavemente mañana para retomar el rumbo.',
        fr: 'L’apport d’aujourd’hui a dépassé la dépense estimée. Réajustez demain pour garder le cap.',
        pt: 'A ingestão de hoje superou o gasto estimado. Faça um leve ajuste amanhã para manter o ritmo.',
        ru: 'Сегодняшний рацион превысил расход. Скорректируйте питание завтра, чтобы вернуться к цели.',
        hi: 'आज का सेवन अनुमानित खर्च से अधिक था। पटरी पर लौटने के लिए कल हल्का समायोजन करें।',
        bn: 'আজকের গ্রহণ আনুমানিক ব্যয়ের চেয়ে বেশি ছিল। ট্র্যাকে ফিরতে আগামীকাল সামান্য সমন্বয় করুন।',
        ar: 'تجاوز مدخول اليوم معدل الحرق المقدر. قم بتعديل بسيط غدًا للمحافظة على مسارك.',
        ro: 'Aportul de azi a depășit consumul estimat. Fă o mică ajustare mâine pentru a rămâne pe drum.',
      );
    }

    // Pattern 6: Deficit on weight gain
    if (msg.contains('thấp hơn mức tiêu hao ước tính') ||
        msg.contains('chưa có đủ thặng dư cần thiết để tăng cân')) {
      return _text(
        context,
        vi: 'Lượng nạp hôm nay chưa đủ thặng dư để tăng cân. Ngày mai hãy bổ sung thêm dinh dưỡng trong từng bữa nhé.',
        en: 'Today’s intake didn’t reach the surplus needed for weight gain. Add extra nutrition to each meal tomorrow.',
        ko: '오늘 섭취량은 증량에 필요한 흑자에 도달하지 못했습니다. 내일 각 식사마다 영양을 조금 더 보충해보세요.',
        ja: '今日の摂取量は体重増加に必要な余剰に届きませんでした。明日は各食事に栄養を少し足してみましょう。',
        zh: '今天的摄入量未达到增重所需盈余。明天请在每餐中补充更多营养。',
        es: 'La ingesta de hoy no alcanzó el superávit para ganar peso. Añade más nutrientes en cada comida mañana.',
        fr: 'L’apport d’aujourd’hui n’a pas atteint le surplus pour prendre du poids. Ajoutez de la nutrition demain.',
        pt: 'A ingestão de hoje não atingiu o superávit para ganho de peso. Adicione mais nutrição a cada refeição amanhã.',
        ru: 'Сегодняшний рацион не создал нужного избытка для набора веса. Добавьте питательности завтра.',
        hi: 'आज का सेवन वजन बढ़ाने के लिए आवश्यक अधिशेष तक नहीं पहुँचा। कल प्रत्येक भोजन में पोषण जोड़ें।',
        bn: 'আজকের গ্রহণ ওজন বৃদ্ধির জন্য প্রয়োজনীয় উদ্বৃত্তে পৌঁছায়নি। আগামীকাল খাবারে পুষ্টি যোগ করুন।',
        ar: 'لم يصل مدخول اليوم إلى الفائض المطلوب لزيادة الوزن. أضف المزيد من العناصر الغذائية غدًا.',
        ro: 'Aportul de azi nu a atins surplusul necesar pentru creșterea în greutate. Adaugă mai multă hrană mâine.',
      );
    }

    // Pattern 7: Maintain or general monitoring
    if (msg.contains('Cần thêm dữ liệu cân nặng') ||
        msg.contains('Cần thêm dữ liệu nhiều ngày') ||
        msg.contains('Mục tiêu cân nặng của bạn là')) {
      return _text(
        context,
        vi: 'Tiếp tục ghi nhận bữa ăn và cân nặng đều đặn để CalGo dự báo xu hướng thực tế của bạn.',
        en: 'Keep logging meals and weight regularly so CalGo can forecast your true trend.',
        ko: 'CalGo가 실제 추세를 예측할 수 있도록 식사와 체중을 꾸준히 기록해주세요.',
        ja: 'CalGoが実際の傾向を予測できるよう、食事と体重を定期的に記録しましょう。',
        zh: '请持续记录饮食和体重，以便 CalGo 预测您的真实趋势。',
        es: 'Sigue registrando comidas y peso con regularidad para que CalGo proyecte tu tendencia real.',
        fr: 'Notez vos repas et votre poids régulièrement pour que CalGo prévoie votre tendance réelle.',
        pt: 'Continue registrando refeições e peso regularmente para o CalGo projetar sua tendência real.',
        ru: 'Продолжайте регулярно записывать питание и вес, чтобы CalGo показал ваш реальный тренд.',
        hi: 'नियमित रूप से भोजन और वजन दर्ज करते रहें ताकि CalGo आपकी वास्तविक प्रवृत्ति का अनुमान लगा सके।',
        bn: 'নিয়মিত খাবার ও ওজন রেকর্ড করুন যাতে CalGo আপনার আসল প্রবণতা পূর্বাভাস দিতে পারে।',
        ar: 'واصل تسجيل الوجبات والوزن بانتظام حتى يتمكن CalGo من توقع اتجاهك الحقيقي.',
        ro: 'Înregistrează mesele și greutatea în mod regulat pentru ca CalGo să îți poată prognoza trendul.',
      );
    }

    return msg;
  }

  static String mealGuidanceDishReason(
    BuildContext context,
    MealGuidanceDish dish,
    MealGuidanceSummary? summary,
  ) {
    final reason = dish.reason.trim();
    if (reason.isEmpty) return '';

    // Familiar match from history
    if (reason.contains('Bạn đã quét món này') ||
        reason.contains('khẩu phần trước đó')) {
      return _text(
        context,
        vi: reason,
        en: 'Matches a portion you scanned previously and fits your remaining macros today.',
        ko: '이전에 스캔한 식사와 일치하며 오늘 남은 영양 목표에 잘 맞습니다.',
        ja: '以前スキャンした食事と一致し、今日の残りの栄養目標に適しています。',
        zh: '与您之前扫描过的分量相符，且适合今天剩余的营养目标。',
        es: 'Coincide con una porción que escaneaste antes y se ajusta a tus macros restantes de hoy.',
        fr: 'Correspond à une portion enregistrée précédemment et convient à vos macros restantes.',
        pt: 'Combina com uma porção escaneada antes e cabe nos seus macros restantes de hoje.',
        ru: 'Соответствует ранее отсканированной порции и подходит под оставшиеся макросы.',
        hi: 'यह आपके पहले स्कैन किए गए हिस्से से मेल खाता है और आज के शेष मैक्रोज़ में फिट बैठता है।',
        bn: 'এটি আপনার আগে স্ক্যান করা খাবারের সাথে মিলে যায় এবং আজকের বাকি লক্ষ্যের জন্য উপযুক্ত।',
        ar: 'يطابق حصة قمت بمسحها سابقًا ويناسب عناصرك الغذائية المتبقية اليوم.',
        ro: 'Se potrivește cu o porție scanată anterior și cu macronutrienții rămași azi.',
      );
    }

    // High protein boost
    if (reason.contains('protein') && (reason.contains('Bổ sung khoảng') || reason.contains('vừa phần calo'))) {
      final proteinG = dish.protein.round();
      final code = languageCode(context);
      switch (code) {
        case 'vi':
          return 'Bổ sung khoảng ${proteinG}g protein mà vẫn vừa phần calo còn lại.';
        case 'ko':
          return '남은 칼로리 범위 내에서 약 ${proteinG}g의 단백질을 보충해줍니다.';
        case 'ja':
          return '残りのカロリー内で約${proteinG}gのたんぱく質を補給できます。';
        case 'zh':
          return '在剩余热量范围内补充约 ${proteinG}g 蛋白质。';
        case 'es':
          return 'Aporta unos ${proteinG}g de proteína dentro de tus calorías restantes.';
        case 'fr':
          return 'Apporte environ ${proteinG}g de protéines dans votre budget calorique restant.';
        case 'pt':
          return 'Adiciona cerca de ${proteinG}g de proteína dentro das calorias restantes.';
        case 'ru':
          return 'Добавляет около ${proteinG} г белка в пределах оставшихся калорий.';
        case 'hi':
          return 'शेष कैलोरी के भीतर लगभग ${proteinG}g प्रोटीन प्रदान करता है।';
        case 'bn':
          return 'বাকি ক্যালোরির মধ্যেই প্রায় ${proteinG}g প্রোটিন সরবরাহ করে।';
        case 'ar':
          return 'يمدك بنحو ${proteinG} جم بروتين ضمن السعرات المتبقية.';
        case 'ro':
          return 'Oferă aproximativ ${proteinG}g de proteine în limita caloriilor rămase.';
        default:
          return 'Adds about ${proteinG}g protein while staying within your remaining calories.';
      }
    }

    // Standard remaining fit
    if (reason.contains('Nằm trong phần calo còn lại') ||
        reason.contains('phù hợp cho bữa tiếp theo')) {
      return _text(
        context,
        vi: 'Nằm trong phần calo còn lại và phù hợp cho bữa tiếp theo.',
        en: 'Fits within your remaining calories and works well for your next meal.',
        ko: '남은 칼로리 범위에 맞으며 다음 식사로 적합합니다.',
        ja: '残りのカロリー内に収まり、次の食事に適しています。',
        zh: '符合剩余热量预算，非常适合作为下一餐。',
        es: 'Encaja en tus calorías restantes y es ideal para tu próxima comida.',
        fr: 'S’intègre dans vos calories restantes et convient pour le prochain repas.',
        pt: 'Cabe nas calorias restantes e funciona bem para a próxima refeição.',
        ru: 'Вписывается в оставшиеся калории и отлично подходит для следующего приёма.',
        hi: 'आपकी शेष कैलोरी के भीतर फिट बैठता है और अगले भोजन के लिए उपयुक्त है।',
        bn: 'আপনার বাকি ক্যালোরির মধ্যে উপযুক্ত এবং পরবর্তী খাবারের জন্য ভালো।',
        ar: 'يناسب سعراتك المتبقية ومثالي لوجبتك القادمة.',
        ro: 'Se încadrează în caloriile rămase și este potrivit pentru următoarea masă.',
      );
    }

    return reason;
  }

  static String mealGuidanceDishAdjustment(
    BuildContext context,
    String rawAdjustment,
  ) {
    final adj = rawAdjustment.trim();
    if (adj.isEmpty) return '';

    if (adj.contains('Để sốt riêng') || adj.contains('sốt riêng')) {
      return _text(
        context,
        vi: 'Để sốt riêng để dễ kiểm soát lượng calo.',
        en: 'Keep sauce on the side for easier calorie control.',
        ko: '칼로리 조절을 위해 소스를 따로 덜어 드세요.',
        ja: 'カロリー管理のため、ドレッシングは別添えにしましょう。',
        zh: '酱汁单独分装以便更好地控制热量。',
        es: 'Pide la salsa aparte para controlar mejor las calorías.',
        fr: 'Gardez la sauce à part pour mieux contrôler les calories.',
        pt: 'Deixe o molho à parte para controlar melhor as calorias.',
        ru: 'Попросите соус отдельно, чтобы контролировать калории.',
        hi: 'कैलोरी नियंत्रण आसान बनाने के लिए सॉस अलग रखें।',
        bn: 'ক্যালোরি সহজে নিয়ন্ত্রণ করতে সস আলাদা রাখুন।',
        ar: 'اجعل الصلصة جانبية للتحكم في السعرات بسهولة.',
        ro: 'Păstrează sosul separat pentru un control mai ușor al caloriilor.',
      );
    }

    if (adj.contains('ít dầu') || adj.contains('thêm rau để bữa ăn nhẹ hơn')) {
      return _text(
        context,
        vi: 'Ưu tiên phần ít dầu và thêm rau để bữa ăn nhẹ hơn.',
        en: 'Opt for less oil and add vegetables for a lighter meal.',
        ko: '기름기를 줄이고 채소를 추가해 가볍게 즐겨보세요.',
        ja: '油分を控えめにし、野菜を加えて軽めの食事にしましょう。',
        zh: '选择少油做法并增加蔬菜，让这一餐更清爽。',
        es: 'Elige menos aceite y añade verduras para una comida más ligera.',
        fr: 'Privilégiez moins d’huile et ajoutez des légumes pour alléger le repas.',
        pt: 'Prefira menos óleo e adicione vegetais para uma refeição mais leve.',
        ru: 'Выбирайте меньше масла и добавьте овощей для лёгкости блюда.',
        hi: 'हल्के भोजन के लिए कम तेल चुनें और सब्जियाँ जोड़ें।',
        bn: 'হালকা খাবারের জন্য কম তেল বেছে নিন এবং শাকসবজি যোগ করুন।',
        ar: 'اختر زيتًا أقل وأضف الخضار لوجبة أخف.',
        ro: 'Alege mai puțin ulei și adaugă legume pentru o masă mai ușoară.',
      );
    }

    if (adj.contains('giàu đạm') || adj.contains('ăn chậm để giữ no lâu')) {
      return _text(
        context,
        vi: 'Đây là lựa chọn giàu đạm; ăn chậm để giữ no lâu.',
        en: 'High-protein option; eat slowly to stay full longer.',
        ko: '고단백 식단입니다. 천천히 드시면 포만감이 오래 유지됩니다.',
        ja: '高たんぱくなメニューです。ゆっくり食べて満腹感を持続させましょう。',
        zh: '高蛋白之选，细嚼慢咽能维持更长久的饱腹感。',
        es: 'Opción rica en proteínas; come despacio para mayor saciedad.',
        fr: 'Riche en protéines; mangez lentement pour prolonger la satiété.',
        pt: 'Opção rica em proteína; coma devagar para manter a saciedade.',
        ru: 'Блюдо богато белком; ешьте медленно для долгого насыщения.',
        hi: 'उच्च प्रोटीन विकल्प; लंबे समय तक तृप्त रहने के लिए धीरे-धीरे खाएं।',
        bn: 'উচ্চ প্রোটিনযুক্ত খাবার; দীর্ঘক্ষণ তৃপ্ত থাকতে ধীরে খান।',
        ar: 'خيار غني بالبروتين؛ تناول الطعام ببطء للشبع لفترة أطول.',
        ro: 'Opțiune bogată în proteine; mănâncă încet pentru a menține sațietatea.',
      );
    }

    if (adj.contains('Giảm phần sốt hoặc dầu')) {
      return _text(
        context,
        vi: 'Giảm phần sốt hoặc dầu nếu muốn món này nhẹ hơn.',
        en: 'Reduce sauce or oil if you want a lighter version.',
        ko: '더 가볍게 드시려면 소스나 기름 양을 줄여보세요.',
        ja: 'より軽めにしたい場合は、ソースや油を控えめにしましょう。',
        zh: '如需更清淡，可减少酱料或用油量。',
        es: 'Reduce la salsa o el aceite si prefieres una versión más ligera.',
        fr: 'Diminuez la sauce ou l’huile pour une version plus légère.',
        pt: 'Reduza o molho ou o óleo se quiser uma versão mais leve.',
        ru: 'Уменьшите количество соуса или масла, если хотите облегчить блюдо.',
        hi: 'यदि आप हल्का विकल्प चाहते हैं तो सॉस या तेल कम करें।',
        bn: 'হালকা সংস্করণ চাইলে সস বা তেল কমিয়ে নিন।',
        ar: 'قلل الصلصة أو الزيت إذا أردت وجبة أخف.',
        ro: 'Redu sosul sau uleiul dacă vrei o variantă mai ușoară.',
      );
    }

    if (adj.contains('tinh bột vừa phải') || adj.contains('thêm rau vào bữa này')) {
      return _text(
        context,
        vi: 'Giữ phần tinh bột vừa phải và thêm rau vào bữa này.',
        en: 'Keep carbs moderate and add vegetables to this meal.',
        ko: '탄수화물은 적당히 유지하고 채소를 곁들여보세요.',
        ja: '炭水化物は適量にし、野菜をプラスしましょう。',
        zh: '保持适量碳水并在此餐中加入蔬菜。',
        es: 'Modera los carbohidratos y añade verduras a esta comida.',
        fr: 'Modérez les féculents et ajoutez des légumes à ce repas.',
        pt: 'Mantenha os carboidratos moderados e adicione vegetais.',
        ru: 'Соблюдайте умеренность в углеводах и добавьте овощи.',
        hi: 'कार्ब्स को मध्यम रखें और इस भोजन में सब्जियां शामिल करें।',
        bn: 'কার্বোহাইড্রেট পরিমিত রাখুন এবং এই খাবারে শাকসবজি যোগ করুন।',
        ar: 'حافظ على كربوهيدرات معتدلة وأضف الخضار إلى هذه الوجبة.',
        ro: 'Păstrează carbohidrații moderați și adaugă legume la această masă.',
      );
    }

    if (adj.contains('trứng, đậu hũ hoặc sữa chua') || adj.contains('đủ đạm hơn')) {
      return _text(
        context,
        vi: 'Có thể ăn kèm trứng, đậu hũ hoặc sữa chua để đủ đạm hơn.',
        en: 'Pair with eggs, tofu, or yogurt to boost protein.',
        ko: '단백질 보충을 위해 계란, 두부 또는 요거트를 곁들여보세요.',
        ja: '卵や豆腐、ヨーグルトを添えてたんぱく質をプラスしましょう。',
        zh: '可搭配鸡蛋、豆腐或酸奶以补充蛋白质。',
        es: 'Acompaña con huevo, tofu o yogur para más proteína.',
        fr: 'Accompagnez d’œuf, de tofu ou de yaourt pour plus de protéines.',
        pt: 'Acompanhe com ovo, tofu ou iogurte para reforçar as proteínas.',
        ru: 'Добавьте яйцо, тофу или йогурт для повышения белка.',
        hi: 'प्रोटीन बढ़ाने के लिए अंडे, टोफू या दही के साथ लें।',
        bn: 'প্রোটিন বাড়াতে ডিম, তোফু বা দইয়ের সাথে খেতে পারেন।',
        ar: 'تناولها مع البيض أو التوفو أو الزبادي لزيادة البروتين.',
        ro: 'Combină cu ou, tofu sau iaurt pentru mai multe proteine.',
      );
    }

    if (adj.contains('Chia khẩu phần') || adj.contains('hai phần nhỏ')) {
      return _text(
        context,
        vi: 'Chia khẩu phần thành hai phần nhỏ nếu bạn còn nhiều bữa.',
        en: 'Split into smaller portions if you have more meals ahead.',
        ko: '남은 식사가 있다면 작은 두 부분으로 나누어 드세요.',
        ja: 'この後まだ食事があるなら、小さめのポーションに分けましょう。',
        zh: '如果后面还有餐次，可将分量分成两份小餐。',
        es: 'Divide en porciones más pequeñas si te quedan más comidas.',
        fr: 'Divisez en petites portions s’il vous reste d’autres repas.',
        pt: 'Divida em porções menores se ainda tiver outras refeições.',
        ru: 'Разделите на небольшие порции, если впереди ещё есть приёмы пищи.',
        hi: 'यदि आपके आगे और भोजन हैं तो इसे छोटे भागों में बांटें।',
        bn: 'সামনে আরও খাবার থাকলে এটিকে ছোট অংশে ভাগ করে নিন।',
        ar: 'قسم الوجبة إلى حصص أصغر إذا كانت لديك وجبات أخرى قادمة.',
        ro: 'Împarte în porții mai mici dacă mai ai mese de luat azi.',
      );
    }

    if (adj.contains('nửa khẩu phần và thêm rau') || adj.contains('đã gần đủ calo')) {
      return _text(
        context,
        vi: 'Nếu hôm nay đã gần đủ calo, chọn nửa khẩu phần và thêm rau.',
        en: 'If near your calorie limit today, opt for half a portion with extra greens.',
        ko: '오늘 칼로리가 거의 찼다면 반 공기만 드시고 채소를 더해보세요.',
        ja: '今日すでにカロリー上限に近いなら、半分のポーションにして野菜を足しましょう。',
        zh: '若今天热量接近达标，建议选择半份并多配蔬菜。',
        es: 'Si estás cerca de tu límite de calorías, elige media porción con verduras.',
        fr: 'Si vous êtes proche de votre limite calorique, prenez une demi-portion avec des légumes.',
        pt: 'Se já estiver perto do limite calórico, escolha meia porção com mais verduras.',
        ru: 'Если вы близки к лимиту калорий, выберите полпорции и добавьте овощей.',
        hi: 'यदि आज आपकी कैलोरी सीमा पूरी होने वाली है, तो आधा हिस्सा लें और सब्जियां जोड़ें।',
        bn: 'আজ ক্যালোরি প্রায় পূর্ণ হয়ে থাকলে অর্ধেক অংশ নিন এবং বেশি সবজি খান।',
        ar: 'إذا اقتربت من حد السعرات اليوم، اختر نصف حصة مع إضافة الخضار.',
        ro: 'Dacă ești aproape de limita calorică, alege o jumătate de porție cu legume.',
      );
    }

    if (adj.contains('Giữ khẩu phần vừa đủ') || adj.contains('ăn chậm để nhận biết lúc no')) {
      return _text(
        context,
        vi: 'Giữ khẩu phần vừa đủ và ăn chậm để nhận biết lúc no.',
        en: 'Keep portions moderate and eat slowly to feel fullness.',
        ko: '적당한 양을 유지하고 천천히 드시면서 포만감을 느껴보세요.',
        ja: '適量を守り、ゆっくり食べて満腹感を感じましょう。',
        zh: '保持适中分量，细嚼慢咽以便及时感知饱腹。',
        es: 'Mantén porciones moderadas y come despacio para notar la saciedad.',
        fr: 'Gardez des portions modérées et mangez lentement pour ressentir la satiété.',
        pt: 'Mantenha porções moderadas e coma devagar para sentir a saciedade.',
        ru: 'Контролируйте порцию и ешьте медленно, чтобы почувствовать насыщение.',
        hi: 'मध्यम मात्रा रखें और तृप्ति महसूस करने के लिए धीरे-धीरे खाएं।',
        bn: 'পরিমিত অংশ রাখুন এবং তৃপ্তি বুঝতে ধীরে ধীরে খান।',
        ar: 'حافظ على حصص معتدلة وتناول الطعام ببطء للشعور بالشبع.',
        ro: 'Păstrează porții moderate și mănâncă încet pentru a simți sațietatea.',
      );
    }

    return adj;
  }

  static String mealGuidanceStateMessage(
    BuildContext context,
    MealGuidance guidance,
  ) {
    final msg = guidance.message.trim();
    if (msg.isEmpty) return '';

    // Needs first scan
    if (guidance.needsFirstScan || msg.contains('Chụp bữa đầu tiên hôm nay để mình')) {
      return _text(
        context,
        vi: 'Chụp bữa đầu tiên hôm nay để mình tính phần còn lại và gợi ý bữa tiếp theo cho bạn.',
        en: 'Scan your first meal today so I can calculate what remains and suggest your next meal.',
        ko: '오늘 첫 식사를 스캔해주시면 남은 목표를 계산해 다음 식사를 추천해 드릴게요.',
        ja: '今日の最初の食事をスキャンしてください。残りの目標を計算して次の食事を提案します。',
        zh: '拍摄今天的第一餐，我来帮您计算剩余配额并推荐下一餐。',
        es: 'Escanea tu primera comida de hoy para calcular lo restante y sugerirte la siguiente.',
        fr: 'Scannez votre premier repas pour que je calcule le reste et vous propose le suivant.',
        pt: 'Escaneie a primeira refeição de hoje para calcular o restante e sugerir a próxima.',
        ru: 'Отсканируйте первый приём пищи за сегодня, чтобы рассчитать остаток и предложить блюда.',
        hi: 'आज का अपना पहला भोजन स्कैन करें ताकि मैं शेष गणना कर सकूँ और अगले भोजन का सुझाव दे सकूँ।',
        bn: 'আজকের প্রথম খাবারটি স্ক্যান করুন যাতে আমি বাকি অংশ হিসাব করে পরের খাবারের পরামর্শ দিতে পারি।',
        ar: 'امسح وجبتك الأولى اليوم حتى أحسب ما تبقى وأقترح وجبتك القادمة.',
        ro: 'Scanează prima masă de azi ca să pot calcula ce a rămas și să-ți sugerez următoarea masă.',
      );
    }

    // Goal reached
    if (guidance.goalReached || msg.contains('Bạn đã chạm mức calo hôm nay')) {
      return _text(
        context,
        vi: 'Bạn đã chạm mức calo hôm nay. Cứ giữ nhịp này nha; nếu còn đói, ưu tiên nước và món thật nhẹ.',
        en: 'You’ve reached today’s calorie target. Keep this momentum; if still hungry, stick to water or light snacks.',
        ko: '오늘의 칼로리 목표를 달성했습니다. 이 페이스를 유지하세요. 출출하다면 물이나 가벼운 음식을 드세요.',
        ja: '今日のカロリー目標に到達しました！この調子を維持しましょう。空腹なら水分や軽めの軽食を選んでください。',
        zh: '您已达到今日热量目标！继续保持好节奏；如果还饿，建议多喝水或选极轻负担的食物。',
        es: '¡Has alcanzado tu objetivo calórico de hoy! Mantén este ritmo; si tienes hambre, opta por agua o algo ligero.',
        fr: 'Vous avez atteint votre objectif calorique ! Gardez ce rythme ; si vous avez faim, buvez de l’eau ou prenez du léger.',
        pt: 'Você atingiu a meta de calorias de hoje! Mantenha o ritmo; se ainda tiver fome, prefira água ou algo bem leve.',
        ru: 'Вы достигли дневной нормы калорий! Держите темп; если ещё голодны, отдайте предпочтение воде или лёгкому перекусу.',
        hi: 'आपने आज का कैलोरी लक्ष्य पूरा कर लिया है। इस लय को बनाए रखें; यदि अभी भी भूख लगी है, तो पानी या हल्का नाश्ता लें।',
        bn: 'আপনি আজকের ক্যালোরির লক্ষ্য পূরণ করেছেন। এই ধারাবাহিকতা ধরে রাখুন; এখনও ক্ষুধা পেলে পানি বা হালকা খাবার বেছে নিন।',
        ar: 'لقد حققت هدف السعرات لليوم! حافظ على هذا الإيقاع؛ إن كنت جائعًا، اختر الماء أو وجبة خفيفة جدًا.',
        ro: 'Ai atins ținta de calorii de azi! Menține acest ritm; dacă mai ai poftă, alege apă sau ceva foarte ușor.',
      );
    }

    // Recovery mode
    if (guidance.isRecovery || msg.contains('Hôm nay đã gần hoặc vượt mục tiêu')) {
      return _text(
        context,
        vi: 'Hôm nay đã gần hoặc vượt mục tiêu, nhưng ngày chưa hề hỏng. Nếu còn đói, ưu tiên một lựa chọn nhẹ và có protein nhé.',
        en: 'You’re near or past your target today, but your day is still on track! If hungry, choose a light protein option.',
        ko: '오늘 목표에 근접했거나 조금 넘었지만 괜찮습니다! 배가 고프다면 가벼운 단백질 위주로 선택해보세요.',
        ja: '今日の目標に近づいたか少し超えましたが大丈夫！お腹が空いたら、軽めのたんぱく質を選びましょう。',
        zh: '今天已接近或略超目标，但完全没关系！如果还饿，优先选择清淡且富含蛋白质的食物。',
        es: 'Estás cerca o superaste tu meta de hoy, ¡pero vas bien! Si tienes hambre, elige una opción ligera con proteína.',
        fr: 'Vous êtes proche ou avez dépassé votre objectif, mais tout va bien ! Si vous avez faim, privilégiez des protéines légères.',
        pt: 'Você está perto ou passou da meta de hoje, mas está tudo bem! Se tiver fome, escolha algo leve com proteína.',
        ru: 'Вы около или чуть превысили норму, но всё в порядке! Если голодны, выберите лёгкий белковый перекус.',
        hi: 'आप आज अपने लक्ष्य के करीब हैं या उससे आगे निकल गए हैं, लेकिन सब ठीक है! भूख लगने पर हल्का प्रोटीन विकल्प चुनें।',
        bn: 'আজ লক্ষ্যমাত্রার কাছাকাছি বা কিছুটা বেশি হলেও কোনো সমস্যা নেই! ক্ষুধা লাগলে হালকা প্রোটিনযুক্ত খাবার বেছে নিন।',
        ar: 'أنت قريب من هدفك أو تجاوزته اليوم، لكن لا تقلق! إذا شعرت بالجوع، اختر بروتينًا خفيفًا.',
        ro: 'Ești aproape sau ai depășit ținta de azi, dar e în regulă! Dacă ți-e foame, alege o opțiune ușoară cu proteine.',
      );
    }

    // Dynamic calorie and protein remaining message
    if (guidance.summary != null && (msg.contains('Bạn còn khoảng') || msg.contains('thiếu'))) {
      final calRemaining = guidance.summary!.caloriesRemaining.clamp(0, 9999).round();
      final protRemaining = guidance.summary!.proteinRemaining.round();
      final code = languageCode(context);
      switch (code) {
        case 'vi':
          return 'Bạn còn khoảng $calRemaining kcal và thiếu ${protRemaining}g protein.';
        case 'ko':
          return '약 $calRemaining kcal 남았으며, 단백질은 ${protRemaining}g 더 필요합니다.';
        case 'ja':
          return '残り約$calRemaining kcalで、たんぱく質はあと${protRemaining}g必要です。';
        case 'zh':
          return '您还剩约 $calRemaining kcal 配额，蛋白质还差 ${protRemaining}g。';
        case 'es':
          return 'Te quedan unas $calRemaining kcal y te faltan ${protRemaining}g de proteína.';
        case 'fr':
          return 'Il vous reste environ $calRemaining kcal et il vous manque ${protRemaining}g de protéines.';
        case 'pt':
          return 'Restam cerca de $calRemaining kcal e faltam ${protRemaining}g de proteína.';
        case 'ru':
          return 'У вас осталось около $calRemaining ккал и не хватает ${protRemaining} г белка.';
        case 'hi':
          return 'आपके पास लगभग $calRemaining kcal बचे हैं और ${protRemaining}g प्रोटीन की आवश्यकता है।';
        case 'bn':
          return 'আপনার প্রায় $calRemaining kcal বাকি আছে এবং ${protRemaining}g প্রোটিন প্রয়োজন।';
        case 'ar':
          return 'متبقي لديك نحو $calRemaining سعرة حرارية وينقصك ${protRemaining} جم بروتين.';
        case 'ro':
          return 'Îți mai rămân aproximativ $calRemaining kcal și ai nevoie de încă ${protRemaining}g de proteine.';
        default:
          return 'You have about $calRemaining kcal left and need ${protRemaining}g more protein.';
      }
    }

    // Unavailable fallback
    if (msg.contains('Mình chưa tìm được món phù hợp')) {
      return _text(
        context,
        vi: 'Mình chưa tìm được món phù hợp từ dữ liệu hiện có. Bạn có thể chụp món tiếp theo để mình tính chính xác hơn.',
        en: 'Could not find matching meals from current data. Scan your next meal for more accurate suggestions.',
        ko: '현재 데이터에서 적절한 식사를 찾지 못했습니다. 더 정확한 추천을 위해 다음 식사를 스캔해주세요.',
        ja: '現在のデータから適切なメニューが見つかりませんでした。より正確な提案のため次の食事をスキャンしてください。',
        zh: '暂未从现有数据中找到匹配的菜品。您可以拍摄下一餐，让我帮您更准确地计算。',
        es: 'No encontramos platos adecuados con los datos actuales. Escanea tu próxima comida para sugerencias precisas.',
        fr: 'Aucun plat correspondant trouvé dans les données actuelles. Scannez votre prochain repas pour plus de précision.',
        pt: 'Não encontramos pratos adequados com os dados atuais. Escaneie sua próxima refeição para sugestões mais precisas.',
        ru: 'Не удалось подобрать блюда по текущим данным. Отсканируйте следующий приём пищи для точных рекомендаций.',
        hi: 'वर्तमान डेटा से उपयुक्त भोजन नहीं मिला। अधिक सटीक सुझावों के लिए अपना अगला भोजन स्कैन करें।',
        bn: 'বর্তমান তথ্য থেকে উপযুক্ত খাবার পাওয়া যায়নি। আরও সঠিক পরামর্শের জন্য আপনার পরবর্তী খাবার স্ক্যান করুন।',
        ar: 'لم نتمكن من العثور على وجبات مناسبة من البيانات الحالية. امسح وجبتك التالية للحصول على اقتراحات أدق.',
        ro: 'Nu am găsit mâncăruri potrivite din datele actuale. Scanează următoarea masă pentru sugestii mai exacte.',
      );
    }

    return msg;
  }
}
