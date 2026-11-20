import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../models/meal_guidance.dart';
import '../l10n/generated/app_localizations.dart';
import 'weight_forecast.dart';

/// Localized copy for dynamic values that come from the API catalog.
///
/// The API intentionally keeps achievement ids and BMI categories stable;
/// presentation text belongs to the client so the Stats screen follows the
/// selected app locale instead of rendering server-side Vietnamese strings.
class StatsLocalization {
  static final _germanStrings = lookupAppLocalizations(const Locale('de'));

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
      'hr': const [
        '',
        'Početnik',
        'Promatrač',
        'Ustrajan',
        'Discipliniran',
        'Entuzijast',
        'Ljubitelj zdravlja',
        'Stručnjak za prehranu',
        'Prvak',
        'Legenda',
        'CalGo Majstor',
      ],
      'de': [
        '',
        _germanStrings.statsLevel1,
        _germanStrings.statsLevel2,
        _germanStrings.statsLevel3,
        _germanStrings.statsLevel4,
        _germanStrings.statsLevel5,
        _germanStrings.statsLevel6,
        _germanStrings.statsLevel7,
        _germanStrings.statsLevel8,
        _germanStrings.statsLevel9,
        _germanStrings.statsLevel10,
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
      case 'hr':
        return '$days dana';
      case 'de':
        return AppLocalizations.of(context)!.statsPeriodDays(days.toString());
      default:
        return '$days days';
    }
  }

  static String weekdayShort(BuildContext context, DateTime date) {
    if (languageCode(context) == 'de') return DateFormat.E('de').format(date);
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
      'hr': const ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'],
    };
    final list = names[languageCode(context)] ?? names['en']!;
    return list[date.weekday - 1];
  }

  static String monthShort(BuildContext context, DateTime date) {
    if (languageCode(context) == 'de') return DateFormat.MMM('de').format(date);
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
      'hr': const [
        '',
        'Sij',
        'Velj',
        'Ožu',
        'Tra',
        'Svi',
        'Lip',
        'Srp',
        'Kol',
        'Ruj',
        'Lis',
        'Stu',
        'Pro',
      ],
    };
    final list = names[languageCode(context)] ?? names['en']!;
    return date.month >= 1 && date.month <= 12
        ? list[date.month]
        : '${date.month}';
  }

  static String forecastOnTrackTitle(BuildContext context) =>
      AppLocalizations.of(context)!.statsOnTrack;

  static String forecastNeedsAdjustmentTitle(BuildContext context) =>
      AppLocalizations.of(context)!.statsNeedsAdjustment;

  static String forecastGoalReachedTitle(BuildContext context) =>
      AppLocalizations.of(context)!.statsGoalReached;

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
      case 'hr':
        return 'Uz prosjek od $calories kcal/dan, mogli biste dostići $target kg za oko $weeks.';
      case 'de':
        return AppLocalizations.of(
          context,
        )!.statsOnTrackBody(calories.toString(), target, weeks);
      default:
        return 'At an average of $calories kcal/day, you may reach $target kg in about $weeks.';
    }
  }

  static String forecastNeedsAdjustmentBody(
    BuildContext context, {
    required String target,
  }) => AppLocalizations.of(context)!.statsAdjustmentBody(target);

  static String forecastNoDataBody(BuildContext context) =>
      AppLocalizations.of(context)!.statsNoDataBody;

  static String caloriePeriodLabel(
    BuildContext context, {
    required bool weekly,
  }) => weekly
      ? AppLocalizations.of(context)!.statsCaloriePeriod
      : AppLocalizations.of(context)!.statsCaloriePeriodToday;

  static String forecastStatusTitle(
    BuildContext context,
    WeightForecast forecast,
  ) {
    return switch (forecast.status) {
      WeightForecastStatus.noData => AppLocalizations.of(
        context,
      )!.statsNoCalories,
      WeightForecastStatus.reached => forecastGoalReachedTitle(context),
      WeightForecastStatus.healthy => forecastOnTrackTitle(context),
      WeightForecastStatus.slow => AppLocalizations.of(context)!.statsSlow,
      WeightForecastStatus.aggressiveDeficit => AppLocalizations.of(
        context,
      )!.statsHighDeficit,
      WeightForecastStatus.aggressiveSurplus => AppLocalizations.of(
        context,
      )!.statsHighSurplus,
      WeightForecastStatus.maintenance => AppLocalizations.of(
        context,
      )!.statsStalled,
      WeightForecastStatus.opposite => AppLocalizations.of(
        context,
      )!.statsOpposite,
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
      case 'hr':
        return switch (forecast.status) {
          WeightForecastStatus.noData =>
            'Zabilježite obrok za početak prognoze temeljene na vašem stvarnom unosu.',
          WeightForecastStatus.reached =>
            'Održavajte trenutni unos i navike kako biste zadržali svoj rezultat.',
          WeightForecastStatus.healthy =>
            'Uz $periodLabel od oko $calories kcal/dan, mogli biste dostići $target kg za oko $weeksLabel.',
          WeightForecastStatus.slow =>
            'Krećete se u dobrom smjeru, ali razlika u kalorijama je mala. Dosezanje cilja od $target kg može potrajati duže.',
          WeightForecastStatus.aggressiveDeficit =>
            'Unosite oko $calories kcal/dan. Ovaj deficit možda nije siguran. Postupno povećajte unos prema $recommendedCalories kcal/dan.',
          WeightForecastStatus.aggressiveSurplus =>
            'Unosite oko $balance kcal/dan iznad održavanja. Težina bi mogla rasti brže nego planirano.',
          WeightForecastStatus.maintenance =>
            'Vaš unos je blizu razine održavanja, pa se vaša težina možda neće puno promijeniti.',
          WeightForecastStatus.opposite =>
            'Uz ovaj unos, vaša bi težina mogla ${isUp ? 'rasti' : 'padati'} suprotno od cilja od $target kg.',
        };
      case 'de':
        return switch (forecast.status) {
          WeightForecastStatus.noData => AppLocalizations.of(
            context,
          )!.statsForecastNoDataBody,
          WeightForecastStatus.reached => AppLocalizations.of(
            context,
          )!.statsForecastReachedBody,
          WeightForecastStatus.healthy =>
            AppLocalizations.of(context)!.statsForecastHealthyBody(
              balance.toString(),
              calories.toString(),
              forecast.goal,
              periodLabel,
              target,
              weeksLabel,
            ),
          WeightForecastStatus.slow => AppLocalizations.of(
            context,
          )!.statsForecastSlowBody(forecast.goal, target),
          WeightForecastStatus.aggressiveDeficit =>
            AppLocalizations.of(context)!.statsForecastAggressiveDeficitBody(
              calories.toString(),
              recommendedCalories.toString(),
            ),
          WeightForecastStatus.aggressiveSurplus => AppLocalizations.of(
            context,
          )!.statsForecastAggressiveSurplusBody(balance.toString()),
          WeightForecastStatus.maintenance => AppLocalizations.of(
            context,
          )!.statsForecastMaintenanceBody,
          WeightForecastStatus.opposite =>
            AppLocalizations.of(context)!.statsForecastOppositeBody(
              balance.toString(),
              isUp ? 'up' : 'down',
              target,
            ),
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

  static final _bmi = <String, Map<String, String>>{
    'de': {
      'underweight': _germanStrings.bmiUnderweight,
      'normal': _germanStrings.bmiNormal,
      'overweight': _germanStrings.bmiOverweight,
      'obese': _germanStrings.bmiObese,
    },
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
    'hr': {
      'underweight': 'Pothranjenost',
      'normal': 'Normalna težina',
      'overweight': 'Prekomjerna težina',
      'obese': 'Pretilost',
    },
  };

  static final _achievements = <String, Map<String, (String, String)>>{
    'de': {
      'first_scan': (
        _germanStrings.statsAchievementFirstScanName,
        _germanStrings.statsAchievementFirstScanDescription,
      ),
      'scan_master': (
        _germanStrings.statsAchievementScanMasterName,
        _germanStrings.statsAchievementScanMasterDescription,
      ),
      'protein_king': (
        _germanStrings.statsAchievementProteinKingName,
        _germanStrings.statsAchievementProteinKingDescription,
      ),
      'streak_7': (
        _germanStrings.statsAchievementStreak7Name,
        _germanStrings.statsAchievementStreak7Description,
      ),
      'calo_champ': (
        _germanStrings.statsAchievementCaloChampName,
        _germanStrings.statsAchievementCaloChampDescription,
      ),
      'legend': (
        _germanStrings.statsAchievementLegendName,
        _germanStrings.statsAchievementLegendDescription,
      ),
    },
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
    'hr': {
      'first_scan': ('Sjajan početak', 'Zabilježite svoj prvi obrok'),
      'scan_master': ('Majstor skeniranja', 'Skenirajte 10 obroka uz AI'),
      'protein_king': (
        'Kralj proteina',
        'Ostvarite 100% dnevnog cilja proteina',
      ),
      'streak_7': ('Niz od 7 dana', 'Bilježite obroke 7 dana uzastopno'),
      'calo_champ': (
        'Prvak u kalorijama',
        'Postignite cilj kalorija 5 uzastopnih dana',
      ),
      'legend': ('CalGo Legenda', 'Dosegnite razinu 10'),
    },
  };

  // ── Meal Guidance & Transformation Forecast Localization ───────────────────

  static String mealGuidanceStatusTag(BuildContext context, String rawTag) {
    final tag = rawTag.trim();
    if (tag.isEmpty) return '';

    if (tag.contains('Đang đi đúng hướng')) {
      return AppLocalizations.of(context)!.statsGuidanceOnTrack;
    }
    if (tag.contains('Cần thêm dữ liệu')) {
      return AppLocalizations.of(context)!.statsNeedData;
    }
    if (tag.contains('Chờ bữa đầu')) {
      return AppLocalizations.of(context)!.statsFirstMeal;
    }
    if (tag.contains('Cần điều chỉnh') || tag.contains('Cần điều chỉnh nhẹ')) {
      return AppLocalizations.of(context)!.statsMinorAdjustment;
    }
    if (tag.contains('Cần bổ sung thêm')) {
      return AppLocalizations.of(context)!.statsMoreSurplus;
    }
    if (tag.contains('Cân bằng vóc dáng')) {
      return AppLocalizations.of(context)!.statsBalanced;
    }
    if (tag.contains('Theo dõi thêm')) {
      return AppLocalizations.of(context)!.statsKeepTracking;
    }
    if (tag.contains('Giữ nhịp chuẩn')) {
      return AppLocalizations.of(context)!.statsSteady;
    }
    if (tag.contains('Đang tích lũy') || tag.contains('Đang tiến bộ')) {
      return AppLocalizations.of(context)!.statsBuilding;
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
        ? (forecast.projectedWeeksToGoal ==
                  forecast.projectedWeeksToGoal!.roundToDouble()
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
      return AppLocalizations.of(context)!.statsFirstMealForecast;
    }

    // Pattern 2: On track with projected weeks & target weight
    if (msg.contains('Nếu duy trì mức nạp khoảng') &&
        weeks.isNotEmpty &&
        target.isNotEmpty) {
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
        case 'hr':
          return 'Održavajući današnji unos, procjenjuje se da ćete doseći $target kg za oko $weeks tjedana$dateSuffix.';
        case 'de':
          return AppLocalizations.of(
            context,
          )!.statsGuidanceProjection(dateSuffix, target, weeks);
        default:
          return 'Maintaining today’s intake, you are projected to reach $target kg in about $weeks weeks$dateSuffix.';
      }
    }

    // Pattern 3: Low intake ratio - Need more data
    if (msg.contains('chưa muốn đoán thời gian') ||
        msg.contains('thấp hơn kế hoạch khá nhiều')) {
      return AppLocalizations.of(context)!.statsLowIntake;
    }

    // Pattern 4: Deficit too small / progress needs more days
    if (msg.contains('Mức thâm hụt thực tế chỉ khoảng') ||
        msg.contains('mức thặng dư chỉ khoảng') ||
        msg.contains('Chưa đủ dữ liệu để dự báo chắc chắn')) {
      return AppLocalizations.of(context)!.statsSmallBalance;
    }

    // Pattern 5: Calorie surplus on weight loss
    if (msg.contains('cao hơn mức tiêu hao ước tính') ||
        msg.contains('tiến độ giảm cân chưa bắt đầu')) {
      return AppLocalizations.of(context)!.statsOverIntake;
    }

    // Pattern 6: Deficit on weight gain
    if (msg.contains('thấp hơn mức tiêu hao ước tính') ||
        msg.contains('chưa có đủ thặng dư cần thiết để tăng cân')) {
      return AppLocalizations.of(context)!.statsUnderSurplus;
    }

    // Pattern 7: Maintain or general monitoring
    if (msg.contains('Cần thêm dữ liệu cân nặng') ||
        msg.contains('Cần thêm dữ liệu nhiều ngày') ||
        msg.contains('Mục tiêu cân nặng của bạn là')) {
      return AppLocalizations.of(context)!.statsKeepLogging;
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
      return AppLocalizations.of(context)!.statsFamiliarReason(reason);
    }

    // High protein boost
    if (reason.contains('protein') &&
        (reason.contains('Bổ sung khoảng') ||
            reason.contains('vừa phần calo'))) {
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
        case 'hr':
          return 'Daje oko ${proteinG}g proteina unutar vaših preostalih kalorija.';
        case 'de':
          return AppLocalizations.of(
            context,
          )!.statsProteinReason(proteinG.toString());
        default:
          return 'Adds about ${proteinG}g protein while staying within your remaining calories.';
      }
    }

    // Standard remaining fit
    if (reason.contains('Nằm trong phần calo còn lại') ||
        reason.contains('phù hợp cho bữa tiếp theo')) {
      return AppLocalizations.of(context)!.statsFitsReason;
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
      return AppLocalizations.of(context)!.statsSauceSide;
    }

    if (adj.contains('ít dầu') || adj.contains('thêm rau để bữa ăn nhẹ hơn')) {
      return AppLocalizations.of(context)!.statsLessOil;
    }

    if (adj.contains('giàu đạm') || adj.contains('ăn chậm để giữ no lâu')) {
      return AppLocalizations.of(context)!.statsHighProtein;
    }

    if (adj.contains('Giảm phần sốt hoặc dầu')) {
      return AppLocalizations.of(context)!.statsReduceSauce;
    }

    if (adj.contains('tinh bột vừa phải') ||
        adj.contains('thêm rau vào bữa này')) {
      return AppLocalizations.of(context)!.statsModerateCarbs;
    }

    if (adj.contains('trứng, đậu hũ hoặc sữa chua') ||
        adj.contains('đủ đạm hơn')) {
      return AppLocalizations.of(context)!.statsBoostProtein;
    }

    if (adj.contains('Chia khẩu phần') || adj.contains('hai phần nhỏ')) {
      return AppLocalizations.of(context)!.statsSplitPortions;
    }

    if (adj.contains('nửa khẩu phần và thêm rau') ||
        adj.contains('đã gần đủ calo')) {
      return AppLocalizations.of(context)!.statsHalfPortion;
    }

    if (adj.contains('Giữ khẩu phần vừa đủ') ||
        adj.contains('ăn chậm để nhận biết lúc no')) {
      return AppLocalizations.of(context)!.statsEatSlowly;
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
    if (guidance.needsFirstScan ||
        msg.contains('Chụp bữa đầu tiên hôm nay để mình')) {
      return AppLocalizations.of(context)!.statsScanFirst;
    }

    // Goal reached
    if (guidance.goalReached || msg.contains('Bạn đã chạm mức calo hôm nay')) {
      return AppLocalizations.of(context)!.statsReachedToday;
    }

    // Recovery mode
    if (guidance.isRecovery ||
        msg.contains('Hôm nay đã gần hoặc vượt mục tiêu')) {
      return AppLocalizations.of(context)!.statsNearTarget;
    }

    // Dynamic calorie and protein remaining message
    if (guidance.summary != null &&
        (msg.contains('Bạn còn khoảng') || msg.contains('thiếu'))) {
      final calRemaining = guidance.summary!.caloriesRemaining
          .clamp(0, 9999)
          .round();
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
        case 'hr':
          return 'Preostalo vam je oko $calRemaining kcal i potrebno vam je još ${protRemaining}g proteina.';
        case 'de':
          return AppLocalizations.of(context)!.statsRemainingMessage(
            calRemaining.toString(),
            protRemaining.toString(),
          );
        default:
          return 'You have about $calRemaining kcal left and need ${protRemaining}g more protein.';
      }
    }

    // Unavailable fallback
    if (msg.contains('Mình chưa tìm được món phù hợp')) {
      return AppLocalizations.of(context)!.statsNoMatchingMeals;
    }

    return msg;
  }
}
