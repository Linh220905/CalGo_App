import 'package:flutter/widgets.dart';

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
