import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabAnalytics => 'Thống kê';

  @override
  String get tabSettings => 'Cài đặt';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get caloriesLeft => 'Calo còn lại';

  @override
  String get proteinLeft => 'Protein còn';

  @override
  String get carbsLeft => 'Carbs còn';

  @override
  String get fatsLeft => 'Fats còn';

  @override
  String get recentlyUploaded => 'Đã tải lên gần đây';

  @override
  String get noMealsUploaded => 'Chưa có bữa ăn nào';

  @override
  String get tapToScanMeal => 'Chạm để quét bữa ăn đầu tiên bằng AI';

  @override
  String get profileTitle => 'Tài khoản cá nhân';

  @override
  String get creditsLabel => 'Lượt quét';

  @override
  String get scannedCountLabel => 'Đã scan';

  @override
  String get buyCredits => 'Mua lượt quét';

  @override
  String get statistics => 'Thống kê';

  @override
  String get calorieTarget => 'Mục tiêu Calo';

  @override
  String get notifications => 'Thông báo';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageDisplayName => 'Tiếng Việt';

  @override
  String get userGuide => 'Hướng dẫn sử dụng';

  @override
  String get customerSupport => 'Hỗ trợ khách hàng';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get selectLanguageTitle => 'Chọn ngôn ngữ';

  @override
  String get scanTitle => 'Quét món ăn';

  @override
  String get scanInstructionHeader => 'Giữ món ăn trong khung hình';

  @override
  String get scanInstructionSub => 'Đảm bảo đủ ánh sáng để AI nhận diện chính xác';

  @override
  String get selectFromGallery => 'Chọn từ thư viện';

  @override
  String get outOfCreditsTitle => 'Hết lượt quét!';

  @override
  String get outOfCreditsMessage => 'Bạn đã hết lượt quét. Mua thêm lượt để tiếp tục theo dõi dinh dưỡng nhé!';

  @override
  String get buyMore => 'Mua ngay';

  @override
  String get cancel => 'Hủy';

  @override
  String get pricingTitle => 'Gói dịch vụ & Lượt quét';

  @override
  String get pricingSubtitle => 'Lựa chọn gói phù hợp để trải nghiệm AI tối đa';

  @override
  String get creditPacksTitle => 'Gói mua lượt quét';

  @override
  String get noExpiryBadge => 'Không hết hạn';

  @override
  String get popularBadge => 'Phổ biến';

  @override
  String get subscriptionsTitle => 'Gói thành viên Premium';

  @override
  String get payButton => 'Thanh toán ngay';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get termsOfService => 'Điều khoản sử dụng';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get openOnline => 'Mở bản online';

  @override
  String get onlineGuide => 'Hướng dẫn online';

  @override
  String get deleteAccountSubscriptionWarning => 'Xóa tài khoản CalGo không tự hủy subscription Google Play. Nếu đang đăng ký Premium, hãy hủy riêng trong Google Play để tránh bị gia hạn.';

  @override
  String get restorePurchases => 'Khôi phục mua hàng';

  @override
  String get privacyPolicyContent => 'Chính sách bảo mật CalGo (cập nhật ngày 05/08/2026):\n\n1. Dữ liệu thu thập: email, tên hiển thị, mã đăng nhập Google, thông tin cá nhân hóa dinh dưỡng trong onboarding, ảnh món ăn, kết quả phân tích, lịch sử bữa ăn, mã và trạng thái giao dịch, dữ liệu kỹ thuật và lựa chọn thông báo.\n2. Quyền thiết bị: camera và thư viện ảnh chỉ được dùng khi bạn chủ động chụp hoặc chọn ảnh món ăn; thông báo chỉ dùng khi bạn bật quyền.\n3. Mục đích sử dụng: cung cấp phân tích dinh dưỡng AI, đồng bộ tài khoản, xử lý giao dịch Google Play, chống lạm dụng, hỗ trợ khách hàng và cải thiện độ ổn định. Ảnh có thể được xử lý bởi nhà cung cấp máy chủ và AI cần thiết.\n4. Chia sẻ và bảo mật: CalGo không bán dữ liệu cá nhân hoặc ảnh món ăn. Nhà cung cấp hosting, AI, Google Sign-In và Google Play Billing có thể xử lý dữ liệu giới hạn để cung cấp dịch vụ. Chúng tôi dùng HTTPS và kiểm soát truy cập, nhưng không hệ thống nào an toàn tuyệt đối.\n5. Lưu trữ và xóa: dữ liệu tài khoản và lịch sử được xóa khi bạn xóa tài khoản, trừ dữ liệu cần giữ để chống gian lận, xử lý tranh chấp hoặc đáp ứng pháp luật. Bản sao lưu có thể cần thời gian hợp lý để hết hạn.\n6. Quyền của bạn: xóa tài khoản trong mục Cá nhân hoặc truy cập https://calgo.tech/delete-account. Yêu cầu truy cập, chỉnh sửa hoặc thắc mắc: support@calgo.tech. Bản đầy đủ: https://calgo.tech/privacy.';

  @override
  String get termsOfServiceContent => 'Điều khoản sử dụng CalGo:\n\n1. Dịch vụ và miễn trừ y tế: kết quả dinh dưỡng AI chỉ là ước tính tham khảo, không thay thế tư vấn, chẩn đoán hay điều trị y khoa. CalGo không phải thiết bị y tế.\n2. Thanh toán: gói credit là giao dịch mua kỹ thuật số một lần. Gói Premium tuần, tháng và năm là subscription Google Play tự động gia hạn, trừ khi bạn hủy trước kỳ gia hạn tiếp theo. Quản lý/hủy tại https://play.google.com/store/account/subscriptions.\n3. Hoàn tiền và xóa tài khoản: Google Play xử lý thanh toán/hoàn tiền Android. Xóa tài khoản CalGo không tự hủy subscription Google Play.\n4. Nội dung và sở hữu trí tuệ: bạn vẫn sở hữu ảnh đã tải lên; CalGo có quyền giới hạn để xử lý ảnh nhằm cung cấp và cải thiện dịch vụ. CalGo sở hữu ứng dụng, thương hiệu và phần mềm.\n5. Liên hệ: support@calgo.tech. Điều khoản đầy đủ: https://calgo.tech/terms.';

  @override
  String get deleteAccountConfirmMessage => 'Bạn có chắc chắn muốn xóa tài khoản CalGo và toàn bộ dữ liệu nhật ký calo của mình không?\n\nHành động này không thể hoàn tác.';

  @override
  String get historyTitle => 'Nhật Ký Ăn Uống';

  @override
  String get historySubtitle => 'Hành trình dinh dưỡng của bạn';

  @override
  String get mealsCountLabel => 'Bữa ăn';

  @override
  String get streakDaysLabel => 'Chuỗi ngày';

  @override
  String get kcalPerDay => 'Kcal/ngày';

  @override
  String get proteinPerDay => 'Protein/ngày';

  @override
  String get noMealsHistory => 'Chưa có bữa ăn nào';

  @override
  String get scanFirstMealPrompt => 'Quét bữa ăn đầu tiên để bắt đầu\nhành trình dinh dưỡng của bạn';

  @override
  String get scanFirstMealButton => 'Quét bữa ăn đầu tiên';

  @override
  String get deleteMealConfirm => 'Bạn có muốn xóa món ăn này?';

  @override
  String get cannotDeleteMeal => 'Không thể xóa món ăn. Vui lòng thử lại.';

  @override
  String get photoGalleryTitle => 'Ảnh món ăn';

  @override
  String get noPhotosYet => 'Chưa có ảnh scan món ăn nào';

  @override
  String get takePhotosPrompt => 'Hãy chụp ảnh món ăn của bạn để lưu lại bộ sưu tập!';

  @override
  String get scanFoodNow => 'Scan món ăn ngay';

  @override
  String get welcomeTo => 'Chào mừng đến với';

  @override
  String get getStarted => 'Bắt đầu';

  @override
  String get snapPhotoAiTitle => 'Chụp ảnh. Để AI lo.';

  @override
  String get snapPhotoAiDesc => 'AI tự động nhận diện món ăn và tính calo trong vài giây.';

  @override
  String get trackEasilyTitle => 'Theo dõi dễ dàng.';

  @override
  String get trackEasilyDesc => 'Theo dõi calo, protein, carb và chất béo mỗi ngày.';

  @override
  String get reachGoalsTitle => 'Đạt mục tiêu nhanh hơn.';

  @override
  String get reachGoalsDesc => 'Nhận mục tiêu cá nhân hóa và theo dõi tiến trình giảm mỡ.';

  @override
  String get nextStepButton => 'Tiếp theo';

  @override
  String get goalStepTitle => 'Mục tiêu của bạn?';

  @override
  String get goalStepSubtitle => 'Giúp CalGo xây lộ trình phù hợp';

  @override
  String get goalLoseWeight => 'Giảm cân';

  @override
  String get goalLoseWeightDesc => 'Đốt mỡ hiệu quả, săn chắc cơ thể';

  @override
  String get goalLoseWeightReason => 'Giúp CalGo xây lộ trình giảm mỡ phù hợp, ưu tiên giữ cơ và dễ duy trì.';

  @override
  String get goalGainMuscle => 'Tăng cơ';

  @override
  String get goalGainMuscleDesc => 'Tăng cơ, tăng sức mạnh';

  @override
  String get goalGainMuscleReason => 'Giúp CalGo xây lộ trình tăng cơ theo lịch tập, năng lượng và protein của bạn.';

  @override
  String get goalMaintain => 'Duy trì';

  @override
  String get goalMaintainDesc => 'Giữ vóc dáng cân đối';

  @override
  String get goalMaintainReason => 'Giúp CalGo xây lộ trình cân bằng, phù hợp với cuộc sống lâu dài của bạn.';

  @override
  String get nameStepTitle => 'Tên của bạn là...';

  @override
  String get nameStepHint => 'Nhập tên của bạn';

  @override
  String get demoStepTitle => 'Xem CalGo hoạt động';

  @override
  String get genderStepTitle => 'Giới tính của bạn?';

  @override
  String get genderStepSubtitle => 'Để tính toán chính xác hơn';

  @override
  String get genderMale => 'Nam';

  @override
  String get genderFemale => 'Nữ';

  @override
  String get genderOther => 'Khác';

  @override
  String get ageStepTitle => 'Tuổi của bạn?';

  @override
  String get heightStepTitle => 'Chiều cao của bạn?';

  @override
  String get weightStepTitle => 'Cân nặng hiện tại?';

  @override
  String get targetWeightStepTitle => 'Cân nặng mục tiêu?';

  @override
  String get activityStepTitle => 'Mức độ vận động?';

  @override
  String get dietStepTitle => 'Chế độ ăn của bạn?';

  @override
  String get analysisTitle => 'Đang phân tích dữ liệu...';

  @override
  String get accountStepTitle => 'Tạo tài khoản để lưu kế hoạch';

  @override
  String get continueWithGoogle => 'Đăng nhập với Google';

  @override
  String get continueWithApple => 'Đăng nhập với Apple';

  @override
  String get heightStepDesc => 'Điều này giúp tính chỉ số BMI và nhu cầu calo chính xác';

  @override
  String get weightStepDesc => 'Điều này giúp xác định mục tiêu dinh dưỡng của bạn';

  @override
  String get currentHeightHeader => 'Chiều cao hiện tại';

  @override
  String get currentWeightHeader => 'Cân nặng hiện tại';

  @override
  String get bmiIndexTitle => 'Chỉ số BMI';

  @override
  String get bmiUnderweight => 'Thiếu cân';

  @override
  String get bmiNormal => 'Bình thường';

  @override
  String get bmiOverweight => 'Thừa cân';

  @override
  String get bmiObese => 'Béo phì';

  @override
  String get targetWeightDesc => 'Điều này giúp xác định mục tiêu dinh dưỡng của bạn';

  @override
  String get goalMaintainLabel => 'Duy trì vóc dáng';

  @override
  String get goalLoseLabel => 'Giảm cân';

  @override
  String get goalGainLabel => 'Tăng cơ';

  @override
  String get goalMaintainHint => 'Mục tiêu duy trì bằng cân nặng hiện tại';

  @override
  String goalLoseDiffText(String kg) {
    return 'Mục tiêu giảm $kg kg';
  }

  @override
  String goalGainDiffText(String kg) {
    return 'Mục tiêu tăng $kg kg';
  }

  @override
  String get paceStepTitle => 'Tốc độ giảm/tuần?';

  @override
  String get paceStepSubtitle => 'Chọn tốc độ phù hợp với bạn';

  @override
  String get activityStepSubtitle => 'Ảnh hưởng đến lượng calo tiêu thụ';

  @override
  String get dietStepSubtitle => 'CalGo hỏi để gợi ý món phù hợp với cơ thể và mục tiêu của bạn.';

  @override
  String get socialProofTitle => 'Cộng đồng nói gì về CalGo?';

  @override
  String get socialProofSubtitle => 'Đánh giá chân thực từ người trải nghiệm';

  @override
  String get ratingTag => 'Đánh giá 5★';

  @override
  String get referralStepTitle => 'Bạn biết đến CalGo từ đâu?';

  @override
  String get referralStepSubtitle => 'Giúp chúng mình thấu hiểu hành trình của bạn';

  @override
  String get referralFriend => 'Bạn bè giới thiệu';

  @override
  String get sportsStepTitle => 'Bạn tập môn gì?';

  @override
  String get sportsStepSubtitle => 'Chọn môn bạn thường tập';

  @override
  String get accountStepSubtitle => 'Bảo mật thông tin & đồng bộ tiến trình cá nhân';

  @override
  String get dataPrivacyNote => 'Dữ liệu của bạn được bảo mật tuyệt đối';

  @override
  String analysisHello(String name) {
    return 'Xin chào, $name';
  }

  @override
  String get analysisPlanReady => 'Kế hoạch của bạn đã sẵn sàng';

  @override
  String get dailyCalorieTargetTitle => 'MỤC TIÊU CALO HẰNG NGÀY';

  @override
  String get kcalPerDayUnit => 'kcal / ngày';

  @override
  String get workoutLabel => 'Tập luyện';

  @override
  String workoutDaysText(String days) {
    return '$days ngày';
  }

  @override
  String get perWeekText => 'mỗi tuần';

  @override
  String get yourJourneyTitle => 'HÀNH TRÌNH CỦA BẠN';

  @override
  String get journeyCurrent => 'Hiện tại';

  @override
  String get journeyTarget => 'Mục tiêu';

  @override
  String get journeyTimeframe => 'Thời gian';

  @override
  String weeksUnit(int weeks) {
    return '$weeks tuần';
  }

  @override
  String completedPercent(int p) {
    return '$p% hoàn thành';
  }

  @override
  String get loginTitle => 'Chào mừng đến với CalGo';

  @override
  String get loginSubtitle => 'Đăng nhập để đồng bộ dữ liệu dinh dưỡng của bạn';

  @override
  String get loginGoogle => 'Đăng nhập với Google';

  @override
  String get loginApple => 'Đăng nhập với Apple';

  @override
  String loginFailed(String error) {
    return 'Đăng nhập thất bại: $error';
  }

  @override
  String get appleComingSoon => 'Tính năng Đăng nhập Apple sắp ra mắt!';

  @override
  String get loginRequired => 'Vui lòng đăng nhập Google để bảo vệ và đồng bộ dữ liệu.';

  @override
  String get loginRequiredButton => 'Đăng nhập là cần thiết để đồng bộ dữ liệu';

  @override
  String get progressLabel => 'Tiến trình';

  @override
  String get dataLoadFailed => 'Không thể tải dữ liệu';

  @override
  String get deleteMealQuestion => 'Bạn có muốn xóa bữa ăn này không?';

  @override
  String get deleteMealFailed => 'Không thể xóa món ăn. Vui lòng thử lại.';

  @override
  String get retry => 'Thử lại';

  @override
  String get mealTypeBreakfast => 'Bữa sáng';

  @override
  String get mealTypeLunch => 'Bữa trưa';

  @override
  String get mealTypeDinner => 'Bữa tối';

  @override
  String get mealTypeSnack => 'Bữa phụ';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get aiCoachAlmostGoal => 'Sắp đạt mục tiêu rồi! Cố lên!';

  @override
  String get aiCoachPlentyCalories => 'Hôm nay còn nhiều năng lượng. Ăn uống lành mạnh nhé!';

  @override
  String get aiCoachMomentum => 'Hãy duy trì đà này nhé!';

  @override
  String get mascotGoalTipWater => 'Làm ngụm nước cho tỉnh táo nha!';

  @override
  String get mascotGoalTipSlow => 'Ăn chậm và lắng nghe cơ thể là quá chuẩn rồi.';

  @override
  String get mascotGoalTipGreat => 'Hôm nay mình làm tốt lắm đó ✨';

  @override
  String get mascotGoalReached => 'Đủ mục tiêu calo hôm nay rồi nha! Giữ nhịp này là quá đỉnh ✨';

  @override
  String get mascotGuidanceIntro => 'Tớ lựa sẵn vài món hợp với hôm nay nè. Bấm vào xem thử ha!';

  @override
  String get mascotGuidanceOpen => 'Mấy món tớ chọn vẫn nằm ở màn gợi ý nha!';

  @override
  String get mascotGuidanceTipWater => 'Uống đủ nước chưa nè? Làm một ngụm cho tỉnh táo ha!';

  @override
  String get mascotGuidanceTipSlow => 'Ăn chậm chậm thôi nha, no lâu hơn đó!';

  @override
  String mascotGuidanceOverTarget(int calories) {
    return 'Mình đang dư $calories kcal rồi nè. Tớ lựa món nhẹ nhẹ, bấm xem ha!';
  }

  @override
  String mascotGuidanceRemaining(int calories) {
    return 'Còn $calories kcal để chạm mục tiêu nè. Tớ lựa sẵn mấy món hợp rồi, bấm xem ha!';
  }

  @override
  String get mascotTipHydration => 'Uống đủ nước chưa đấy bro, làm ngụm nước cho tỉnh táo nào';

  @override
  String get mascotTipChew => 'Ăn chậm chậm thôi nghen, vừa tốt cho dạ dày vừa no lâu';

  @override
  String get mascotTipConsistency => 'Mỗi ngày kỷ luật một xíu là dáng đẹp ngay thôi mà';

  @override
  String get mascotNoMeals => 'Chưa nạp gì đúng không bro? Chụp cái hình món ăn cho tui xem với';

  @override
  String mascotOverTarget(int calories) {
    return 'Hôm nay đang cao hơn mục tiêu khoảng $calories kcal. Không sao, bữa tiếp theo mình chọn nhẹ và đủ protein nhé.';
  }

  @override
  String mascotMissingCalories(int calories) {
    return 'Hôm nay còn thiếu tận $calories kcal đấy, làm thêm miếng gì ngon ngon đi';
  }

  @override
  String get mascotOnTrack => 'Out trình kỷ luật luôn, calo chuẩn đét không lệch phát nào';

  @override
  String mealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bữa ăn',
      one: '1 bữa ăn',
      zero: 'Chưa có bữa ăn',
    );
    return '$_temp0';
  }

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nguyên liệu',
      one: '1 nguyên liệu',
      zero: 'Chưa có nguyên liệu',
    );
    return '$_temp0';
  }

  @override
  String dishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món',
      one: '1 món',
    );
    return '$_temp0';
  }

  @override
  String monthFallback(int month) {
    return 'Tháng $month';
  }

  @override
  String get scanProcessingRecognizing => 'Đang nhận diện món ăn...';

  @override
  String get scanProcessingRecognized => 'Đã nhận diện món ăn';

  @override
  String get scanProcessingIngredients => 'Đang phân tích nguyên liệu...';

  @override
  String get scanProcessingNutrition => 'Xác định thành phần dinh dưỡng...';

  @override
  String get scanProcessingCalories => 'Đang tính toán calories...';

  @override
  String get scanProcessingPortion => 'Ước lượng khẩu phần ăn...';

  @override
  String get scanProcessingSummary => 'AI đang tổng hợp kết quả...';

  @override
  String get scanProcessingReport => 'Chuẩn bị báo cáo...';

  @override
  String get cameraPermissionDenied => 'Quyền Máy ảnh đã bị từ chối. Hãy mở Cài đặt và cấp quyền Máy ảnh cho CalGo!';

  @override
  String get cameraPermissionRequired => 'CalGo cần quyền Máy ảnh để quét món ăn.';

  @override
  String get noCamera => 'Không tìm thấy camera';

  @override
  String get cameraStartFailed => 'Không thể khởi động camera. Vui lòng đóng màn hình và thử lại!';

  @override
  String get scanInProgress => 'Một món khác đang được phân tích. Chờ xíu nha!';

  @override
  String get notLoggedIn => 'Bạn chưa đăng nhập. Vui lòng đăng nhập bằng Google để sử dụng tính năng này!';

  @override
  String get cameraPermissionMissing => 'Chưa được cấp quyền Máy ảnh. Vui lòng bật quyền Máy ảnh cho CalGo trong Cài đặt điện thoại!';

  @override
  String get networkTimeout => 'Kết nối mạng yếu hoặc quá thời gian chờ. Vui lòng kiểm tra lại 4G/Wi-Fi!';

  @override
  String scanFailed(String error) {
    return 'Không thể phân tích ảnh ($error). Vui lòng thử lại!';
  }

  @override
  String get scanAgain => 'Quét lại';

  @override
  String get nutritionTitle => 'Dinh dưỡng';

  @override
  String get guidanceRecoverySubtitle => 'Nhẹ nhàng điều chỉnh thôi';

  @override
  String get guidanceLoggedSubtitle => 'Dựa trên bữa bạn vừa ghi lại';

  @override
  String get guidanceRefreshTooltip => 'Gợi ý mới';

  @override
  String guidanceCaloriesRemaining(int calories) {
    return '$calories kcal còn lại';
  }

  @override
  String guidanceProteinRemaining(int grams) {
    return 'Thiếu ${grams}g protein';
  }

  @override
  String get guidanceAlternativesTitle => 'Hoặc chọn một trong các món này';

  @override
  String get guidanceOtherMeal => 'Tôi định ăn món khác';

  @override
  String get guidanceSeeMore => 'Xem thêm';

  @override
  String get guidanceDisclaimer => 'Gợi ý chỉ để tham khảo. Hãy scan món thực tế để ghi nhật ký chính xác.';

  @override
  String get guidanceFamiliarTag => 'QUEN';

  @override
  String guidanceDishCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String guidanceDishProtein(int grams) {
    return 'P ${grams}g';
  }

  @override
  String guidanceDishCarbs(int grams) {
    return 'C ${grams}g';
  }

  @override
  String guidancePrepTime(int minutes) {
    return '$minutes phút';
  }

  @override
  String guidancePrice(String price) {
    return '~${price}k';
  }

  @override
  String get guidanceFitGreat => 'Rất hợp';

  @override
  String get guidanceFitAdjust => 'Cần chỉnh';

  @override
  String get guidanceFitGood => 'Phù hợp';

  @override
  String get guidanceAppleTitle => 'Để Táo tính cùng bạn';

  @override
  String get guidanceFirstScanAction => 'Chụp bữa đầu tiên';

  @override
  String get guidanceAppleSuggestionTitle => 'Gợi ý của Táo';

  @override
  String get guidanceNextMealAction => 'Chụp món tiếp theo';

  @override
  String get guidanceGoalReachedTitle => 'Đủ mục tiêu hôm nay rồi!';

  @override
  String get guidanceScreenTitle => 'Ăn gì để chạm mục tiêu?';

  @override
  String get guidanceUnavailableTitle => 'Chưa có gợi ý';

  @override
  String get guidanceUnavailableMessage => 'Hãy thử lại sau khi bạn quét món ăn.';

  @override
  String get guidanceScanMeal => 'Quét món ăn';

  @override
  String get guidanceConsiderMeals => 'Món nên cân nhắc';

  @override
  String get guidanceScanForAccuracy => 'Scan để ghi chính xác';

  @override
  String get guidanceSwapWith => 'Hoặc đổi vị với';

  @override
  String get guidanceChangeSuggestion => 'Đổi gợi ý';

  @override
  String get guidancePremiumSwapTitle => 'Đổi gợi ý là tính năng Premium';

  @override
  String get guidancePremiumSwapMessage => 'Nâng cấp Premium để đổi gợi ý món ăn không giới hạn theo mục tiêu của bạn.';

  @override
  String get later => 'Để sau';

  @override
  String get upgradePremium => 'Nâng cấp Premium';

  @override
  String get guidanceTodayTitle => 'Gợi ý riêng cho hôm nay';

  @override
  String get guidanceTodaySubtitle => 'Chọn món hợp macro, rồi scan món thật trước khi ghi.';

  @override
  String get guidanceScanRealMeal => 'Scan món thực tế';

  @override
  String get guidanceNextMealGoal => 'MỤC TIÊU CHO BỮA TIẾP THEO';

  @override
  String get remainingLabel => 'Còn lại';

  @override
  String get proteinNeededLabel => 'Protein cần thêm';

  @override
  String get familiarMacroLabel => 'MÓN QUEN · HỢP MACRO';

  @override
  String get numberOneChoice => 'LỰA CHỌN SỐ 1';

  @override
  String get energyLabel => 'NĂNG LƯỢNG';

  @override
  String get familiarLabel => 'MÓN QUEN';

  @override
  String dishTip(String adjustment) {
    return 'Mẹo: $adjustment';
  }

  @override
  String dishMacroSummary(int calories, String protein) {
    return '$calories kcal · ${protein}g protein';
  }

  @override
  String get fitGoalGreat => 'Rất hợp mục tiêu';

  @override
  String get fitGoalAdjust => 'Nên điều chỉnh';

  @override
  String get fitGoalGood => 'Phù hợp mục tiêu';

  @override
  String get goalSpecificGainTitle => 'Bạn tập luyện bao nhiêu buổi mỗi tuần?';

  @override
  String get goalSpecificGainNone => 'Chưa tập';

  @override
  String get goalSpecificGain12 => '1–2 buổi';

  @override
  String get goalSpecificGain34 => '3–4 buổi';

  @override
  String get goalSpecificGain5 => '5 buổi trở lên';

  @override
  String get goalSpecificMaintainTitle => 'Điều gì quan trọng nhất khi bạn duy trì vóc dáng?';

  @override
  String get goalSpecificStable => 'Giữ cân nặng ổn định';

  @override
  String get goalSpecificBalanced => 'Ăn uống cân bằng hơn';

  @override
  String get goalSpecificHabits => 'Xây thói quen lâu dài';

  @override
  String get goalSpecificWeekends => 'Kiểm soát tốt hơn vào cuối tuần';

  @override
  String get goalSpecificLoseTitle => 'Điều gì khiến bạn khó giảm mỡ nhất?';

  @override
  String get goalSpecificHunger => 'Hay đói';

  @override
  String get goalSpecificPortions => 'Khó kiểm soát khẩu phần';

  @override
  String get goalSpecificChoices => 'Không biết nên ăn gì';

  @override
  String get goalSpecificLogging => 'Lười ghi món ăn';

  @override
  String get goalSpecificOvereat => 'Hay ăn quá mức buổi tối';

  @override
  String get goalSpecificWeekendsHard => 'Hay phá kế hoạch cuối tuần';

  @override
  String get avoidFoodsTitle => 'Bạn có dị ứng với món/nguyên liệu nào không?';

  @override
  String get foodSeafood => 'Hải sản';

  @override
  String get foodRedMeat => 'Thịt đỏ';

  @override
  String get foodEggs => 'Trứng';

  @override
  String get foodDairy => 'Sữa & phô mai';

  @override
  String get foodFried => 'Đồ chiên/rán';

  @override
  String get foodSpicy => 'Món cay';

  @override
  String get challengeTitle => 'Điều khó khăn nhất với bạn là gì?';

  @override
  String get challengeCalories => 'Không biết calo trong món ăn';

  @override
  String get challengeSweets => 'Cưỡng lại đồ ngọt';

  @override
  String get challengePortions => 'Kiểm soát khẩu phần';

  @override
  String get challengeBetweenMeals => 'Đói giữa buổi';

  @override
  String get challengeCookingTime => 'Không có thời gian nấu';

  @override
  String get challengeMotivation => 'Duy trì động lực';

  @override
  String get budgetTitle => 'Ngân sách cho 1 món ăn của bạn?';

  @override
  String get budgetNote => 'CalGo hỏi để gợi ý món hợp mục tiêu và túi tiền của bạn.';

  @override
  String get budgetLow => 'Dưới 30.000đ';

  @override
  String get budgetLowNote => 'Món bình dân, dễ tìm';

  @override
  String get budgetMid => '30.000–60.000đ';

  @override
  String get budgetMidNote => 'Mức phổ biến cho một bữa';

  @override
  String get budgetHigh => '60.000–100.000đ';

  @override
  String get budgetHighNote => 'Thoải mái chọn thêm chất lượng';

  @override
  String get budgetAny => 'Không giới hạn';

  @override
  String get budgetAnyNote => 'Ưu tiên mục tiêu dinh dưỡng';

  @override
  String get prepTitle => 'Thời gian chuẩn bị 1 bữa ăn của bạn?';

  @override
  String get prepNote => 'CalGo hỏi để gợi ý món hợp với lịch của bạn.';

  @override
  String get prepShort => 'Dưới 10 phút';

  @override
  String get prepShortNote => 'Món nhanh, tiện khi bận rộn';

  @override
  String get prepMedium => '10–20 phút';

  @override
  String get prepMediumNote => 'Vừa đủ cho một bữa gọn gàng';

  @override
  String get prepLong => 'Trên 20 phút';

  @override
  String get prepLongNote => 'Có thời gian chuẩn bị kỹ hơn';

  @override
  String get prepAny => 'Không quan trọng';

  @override
  String get prepAnyNote => 'Miễn hợp mục tiêu của mình';

  @override
  String get nutritionPriorityTitle => 'Bạn ưu tiên gì trong bữa ăn?';

  @override
  String get nutritionPriorityNote => 'CalGo hỏi để không đưa cho bạn những gợi ý chung chung.';

  @override
  String get priorityProtein => 'Giàu protein';

  @override
  String get priorityProteinNote => 'Hỗ trợ no lâu và phục hồi cơ';

  @override
  String get priorityLight => 'Nhẹ calo';

  @override
  String get priorityLightNote => 'Ưu tiên món nhẹ, dễ cân đối trong ngày';

  @override
  String get priorityBalanced => 'Cân bằng';

  @override
  String get priorityBalancedNote => 'Hợp lý giữa calo và các nhóm chất';

  @override
  String get priorityFilling => 'No lâu';

  @override
  String get priorityFillingNote => 'Ưu tiên món có protein và tinh bột vừa đủ';

  @override
  String get habitTitle => 'Thói quen ăn uống của bạn?';

  @override
  String get habitNote => 'CalGo hỏi để chọn những món dễ duy trì với nhịp sống của bạn.';

  @override
  String get habitRegular => 'Ăn đúng bữa, khoa học';

  @override
  String get habitSnacking => 'Hay ăn vặt';

  @override
  String get habitSkipBreakfast => 'Thường bỏ bữa sáng';

  @override
  String get habitLateNight => 'Ăn đêm';

  @override
  String get habitEatingOut => 'Ăn ngoài nhiều';

  @override
  String get habitCook => 'Tự nấu ở nhà';

  @override
  String get motivationTitle => 'Điều gì khiến bạn muốn thay đổi?';

  @override
  String get motivationHealth => 'Sức khỏe tốt hơn';

  @override
  String get motivationMuscle => 'Tăng cơ';

  @override
  String get motivationClothes => 'Mặc đồ đẹp hơn';

  @override
  String get motivationWeight => 'Giảm cân';

  @override
  String get motivationEnergy => 'Khỏe mạnh và nhiều năng lượng';

  @override
  String get motivationOther => 'Lý do khác';

  @override
  String get painTitle => 'Bạn đã từng...';

  @override
  String get painNote => 'Chọn những điều bạn từng gặp phải';

  @override
  String get painEatLess => 'Ăn rất ít nhưng vẫn không giảm';

  @override
  String get painCardio => 'Cardio rất nhiều';

  @override
  String get painGiveUp => 'Bỏ cuộc sau vài ngày';

  @override
  String get painUnknownCalories => 'Không biết mình ăn bao nhiêu calo';

  @override
  String get painHungry => 'Hay bị đói giữa chừng';

  @override
  String get painStressEating => 'Ăn uống stress';

  @override
  String get emotionalTitle => 'Nếu tiếp tục ăn như hiện tại...';

  @override
  String get emotionalCurrent => 'Hiện tại';

  @override
  String get emotionalAfterSixMonths => 'Sau 6 tháng';

  @override
  String get emotionalStillWeight => 'Bạn gần như vẫn ở cân nặng hiện tại. Nhưng nếu theo CalGo, bạn có thể thay đổi.';

  @override
  String get emotionalHelpChange => 'Mình sẽ giúp bạn thay đổi';

  @override
  String get referralX => 'X (Twitter)';

  @override
  String get referralOther => 'Khác';

  @override
  String get sportsRunning => 'Chạy bộ';

  @override
  String get sportsCycling => 'Đạp xe';

  @override
  String get sportsSwimming => 'Bơi';

  @override
  String get sportsFootball => 'Bóng đá';

  @override
  String get sportsBadminton => 'Cầu lông';

  @override
  String get sportsBasketball => 'Bóng rổ';

  @override
  String get sportsOther => 'Khác';

  @override
  String get durationTitle => 'Bạn muốn đạt mục tiêu trong?';

  @override
  String get durationNote => 'Chọn thời gian phù hợp với bạn';

  @override
  String get dailyCalorieGoal => 'Mục tiêu Calo hàng ngày';

  @override
  String dailyCalorieGoalMessage(int calories) {
    return 'Mục tiêu hiện tại của bạn là $calories kcal/ngày. Bạn có thể thay đổi mục tiêu này trong cài đặt Onboarding hoặc liên hệ hỗ trợ.';
  }

  @override
  String get close => 'Đóng';

  @override
  String get reminderNotifications => 'Thông báo nhắc nhở';

  @override
  String get reminderNotificationsEnabled => 'Thông báo nhắc bữa ăn và theo dõi lượng calo hằng ngày đã được bật tự động.';

  @override
  String get gotIt => 'Đã hiểu';

  @override
  String get userGuideTitle => 'Hướng dẫn sử dụng CalGo';

  @override
  String get userGuideContent => '1. Nhấn nút Scan (+) để chụp hoặc chọn ảnh món ăn.\n2. AI sẽ tự động phân tích calo và dinh dưỡng.\n3. Bạn có thể chỉnh sửa khối lượng hoặc thêm nguyên liệu trước khi lưu.\n4. Xem lại lịch sử ăn uống tại tab Lịch sử.';

  @override
  String get great => 'Tuyệt vời';

  @override
  String get customerSupportMessage => 'Nếu bạn cần hỗ trợ hoặc góp ý sản phẩm, vui lòng gửi email về: support@calgo.tech';

  @override
  String get deleteAccountFailed => 'Không thể xoá tài khoản. Vui lòng xem hướng dẫn online hoặc liên hệ hỗ trợ.';

  @override
  String get galleryLoadFailed => 'Không thể tải bộ sưu tập ảnh';

  @override
  String get viewResult => 'Xem chi tiết kết quả';

  @override
  String get shareMemoryCard => 'Chia sẻ Card Memory';

  @override
  String get deletePhoto => 'Xóa ảnh này';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String deletePhotoMessage(String meal) {
    return 'Bạn có chắc muốn xóa ảnh món \"$meal\"?';
  }

  @override
  String get mealDeleted => 'Đã xóa món ăn khỏi bộ sưu tập';

  @override
  String get deleteFailed => 'Không thể xóa. Vui lòng thử lại!';

  @override
  String get paymentProcessing => 'Đang xử lý thanh toán qua Google Play...';

  @override
  String get paymentOpenFailed => 'Không thể mở thanh toán Google Play. Vui lòng thử lại.';

  @override
  String errorWithDetails(String error) {
    return 'Lỗi: $error';
  }

  @override
  String packIncludes(int count) {
    return 'Bao gồm $count lượt quét dinh dưỡng AI';
  }

  @override
  String get permanentCredits => 'Lượt quét dùng vĩnh viễn, không giới hạn thời gian';

  @override
  String get testingFreeCredits => 'Bản testing: lượt quét Premium được mở miễn phí. Không có thanh toán Google Play.';

  @override
  String get restoreSuccess => 'Đã kiểm tra khôi phục giao dịch mua thành công!';

  @override
  String get restoreFailed => 'Không thể khôi phục giao dịch Google Play.';

  @override
  String restoreFailedWithDetails(String error) {
    return 'Khôi phục thất bại: $error';
  }

  @override
  String get moreScanCredits => 'Mua thêm lượt quét món ăn bằng AI';

  @override
  String get shareCreateFailed => 'Không thể tạo ảnh card. Vui lòng thử lại!';

  @override
  String get shareExported => 'Đã xuất Card Memory thành công!';

  @override
  String get shareResult => 'Chia sẻ kết quả';

  @override
  String get shareNutritionLabel => 'Ảnh sẽ được lưu với nhãn dinh dưỡng';

  @override
  String get saveImage => 'Lưu ảnh';

  @override
  String get share => 'Chia sẻ';

  @override
  String resultLoadFailed(String id) {
    return 'Không thể tải kết quả phân tích (ID: $id). Vui lòng thử lại!';
  }

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get done => 'Xong';

  @override
  String get healthScore => 'Điểm sức khỏe';

  @override
  String get dishesInPhoto => 'Các món trong ảnh';

  @override
  String get ingredientsInDish => 'Thành phần món ăn';

  @override
  String get addIngredient => 'Thêm nguyên liệu';

  @override
  String get feedbackThanks => 'Cảm ơn bạn đã góp ý!';

  @override
  String get feedbackPrompt => 'AI scan chưa chính xác? Hãy cho chúng tôi biết chi tiết:';

  @override
  String get feedbackHint => 'Ví dụ: Sai tên món, thiếu rau...';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get sending => 'Đang gửi...';

  @override
  String get sendFeedback => 'Gửi góp ý';

  @override
  String get newIngredient => 'Thành phần mới';

  @override
  String get choosePortion => 'Chọn khẩu phần';

  @override
  String get searchNutritionLibrary => 'Tìm trong thư viện dinh dưỡng';

  @override
  String get adjustBeforeAdding => 'Điều chỉnh khối lượng trước khi thêm';

  @override
  String get ingredientSearchHint => 'Tìm thịt bò, trứng, cơm...';

  @override
  String get ingredientNotFound => 'Không tìm thấy nguyên liệu';

  @override
  String get ingredientSearchTip => 'Thử một tên ngắn hoặc phổ biến hơn';

  @override
  String get unitPiece => 'quả';

  @override
  String get defaultUserName => 'bạn';

  @override
  String get analyzingMessage1 => 'Đang phân tích thông tin của bạn...';

  @override
  String get analyzingMessage2 => 'Đang tính toán nhu cầu calo...';

  @override
  String get analyzingMessage3 => 'Đang xây dựng mục tiêu phù hợp...';

  @override
  String get analyzingMessage4 => 'Đang tạo kế hoạch dinh dưỡng...';

  @override
  String get analyzingMessage5 => 'Sắp hoàn tất...';

  @override
  String get dietNormal => 'Ăn bình thường';

  @override
  String get dietClean => 'Eat Clean';

  @override
  String get dietKeto => 'Keto';

  @override
  String get dietLowCarb => 'Low Carb';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get activitySedentary => 'Ít vận động';

  @override
  String get activitySedentaryDesc => 'Ngồi làm việc, ít di chuyển';

  @override
  String get activityLight => 'Đi bộ nhẹ';

  @override
  String get activityLightDesc => 'Đi lại nhẹ 1-2 lần/tuần';

  @override
  String get activityModerate => 'Tập 1-3 buổi';

  @override
  String get activityModerateDesc => 'Thể dục 1-3 ngày/tuần';

  @override
  String get activityActive => 'Tập 4-5 buổi';

  @override
  String get activityActiveDesc => 'Thể dục 4-5 ngày/tuần';

  @override
  String get activityVeryActive => 'Tập hằng ngày';

  @override
  String get activityVeryActiveDesc => 'Vận động nặng hằng ngày';

  @override
  String get paceSlow => '🐢  Chậm — 0.25 kg/tuần';

  @override
  String get paceLight => '🚶  Nhẹ — 0.5 kg/tuần (Phổ biến)';

  @override
  String get paceMedium => '🏃  Trung bình — 0.75 kg/tuần';

  @override
  String get paceHigh => '🔥  Cao — 1 kg/tuần';

  @override
  String get paceHighest => '⚡  Cao nhất — 1.25-1.5 kg/tuần';

  @override
  String get weekUnit => 'tuần';

  @override
  String get sportsGym => 'Gym';

  @override
  String get sportsYoga => 'Yoga';

  @override
  String get scanResultUnavailable => 'Chưa phân tích được món này';

  @override
  String get scanResultRetryHint => 'Bạn thử quét lại nha.';

  @override
  String guidanceDishFat(int grams) {
    return 'F ${grams}g';
  }

  @override
  String get ok => 'OK';

  @override
  String get defaultProfileName => 'Người dùng CalGo';

  @override
  String get premiumMembership => 'Gói thành viên Premium';

  @override
  String creditsCount(int count) {
    return '$count lượt';
  }

  @override
  String get paymentMethods => 'Thanh toán qua Google Play / App Store';

  @override
  String get deleteAction => 'Xóa';

  @override
  String get proteinLabel => 'PROTEIN';

  @override
  String get onboardingSaveFailed => 'Không thể lưu mục tiêu dinh dưỡng. Vui lòng thử lại.';

  @override
  String get onboardingSaveNetworkFailed => 'Không thể lưu mục tiêu dinh dưỡng. Vui lòng kiểm tra mạng và thử lại.';

  @override
  String googleSignInFailed(String error) {
    return 'Đăng nhập Google thất bại: $error';
  }

  @override
  String get appleSignInPending => 'Đăng nhập Apple đang được hoàn thiện. Vui lòng dùng Google.';

  @override
  String get firstScanTitle => 'Thử quét bữa ăn đầu tiên nhé!';

  @override
  String get firstScanSubtitle => 'Nhấn vào nút Scan bên dưới để bắt đầu';

  @override
  String get scanLabel => 'Scan';

  @override
  String get startScanning => 'Bắt đầu quét';

  @override
  String get socialProofOneTag => 'Giảm 6.5 kg';

  @override
  String get socialProofOneTime => '2 ngày trước';

  @override
  String get socialProofOneTitle => 'Quét đồ ăn Việt Nam cực chuẩn!';

  @override
  String get socialProofOneBody => 'Trước đây mình dùng app ngoại tra phở, bún chả rất cực. CalGo chụp ảnh nhận diện món Việt chính xác từng gram calo luôn. 10/10!';

  @override
  String get socialProofTwoTag => 'Tăng cơ 4 kg';

  @override
  String get socialProofTwoTime => '5 ngày trước';

  @override
  String get socialProofTwoTitle => 'Giao diện mượt, tính TDEE sát thực tế';

  @override
  String get socialProofTwoBody => 'Thước đo BMI và gợi ý macro rất chi tiết. Mình tập gym kết hợp theo dõi calo mỗi ngày, cơ thể săn chắc rõ rệt sau 1 tháng.';

  @override
  String get socialProofThreeTag => 'Duy trì vóc dáng';

  @override
  String get socialProofThreeTime => '1 tuần trước';

  @override
  String get socialProofThreeTitle => 'Tạo thói quen ăn uống lành mạnh';

  @override
  String get socialProofThreeBody => 'Linh vật Táo nhắc nhở đáng yêu lắm. App không hề ép ăn kiêng hà khắc mà hướng dẫn cân bằng dinh dưỡng thông minh.';

  @override
  String get premiumActivatedMessage => 'Premium đã được kích hoạt. Chúc bạn ăn ngon!';

  @override
  String get premiumPaymentFailed => 'Không thể mở thanh toán Premium.';

  @override
  String get continueFreePremium => 'Tiếp tục · Premium miễn phí';

  @override
  String get continueLabel => 'Tiếp tục';

  @override
  String get premiumFreeUnlocked => 'Premium đã mở miễn phí';

  @override
  String get premiumActivated => 'Premium đã kích hoạt';

  @override
  String get processingShort => 'Đang xử lý…';

  @override
  String get subscribePremium => 'Đăng ký Premium';

  @override
  String get premiumTestingNote => 'Bản testing: Premium được mở miễn phí. Không có thanh toán.';

  @override
  String get premiumNoChargeNote => 'Bạn chưa bị tính phí ở bước này.';

  @override
  String get premiumAutoRenewNote => 'Tự động gia hạn. Hủy bất cứ lúc nào.';

  @override
  String get premiumHeadlineBefore => 'Thay đổi bản thân bắt đầu từ ';

  @override
  String get todayLower => 'hôm nay';

  @override
  String get yourExperience => 'Trải\nnghiệm\ncủa bạn';

  @override
  String get premiumBenefitCalories => 'Biết ngay lượng calo — quét AI không giới hạn';

  @override
  String get premiumBenefitSuggestions => 'Đổi gợi ý món ăn không giới hạn theo mục tiêu mỗi ngày';

  @override
  String get premiumBenefitDescriptions => 'Mô tả món ăn bằng AI, không cần nhập tay';

  @override
  String get premiumBenefitProgress => 'Theo dõi tiến trình cơ thể mỗi ngày';

  @override
  String get premiumBenefitSupport => 'Được hỗ trợ ưu tiên bất cứ khi nào cần';

  @override
  String get planWeek => 'Tuần';

  @override
  String get planYear => 'Năm';

  @override
  String get planMonth => 'Tháng';

  @override
  String get free => 'Miễn phí';

  @override
  String get weeklyPayment => 'thanh toán hàng tuần';

  @override
  String get popularMost => 'Phổ biến nhất';

  @override
  String get testingAccess => 'quyền truy cập testing';

  @override
  String get restoreChecked => 'Đã kiểm tra khôi phục giao dịch.';

  @override
  String restoreException(String error) {
    return 'Khôi phục thất bại: $error';
  }

  @override
  String get manageSubscription => 'Quản lý gói';

  @override
  String get manageSubscriptionFailed => 'Không thể mở trang quản lý gói.';

  @override
  String get scanCreditsExhausted => 'Bạn đã hết lượt quét.';

  @override
  String get networkRetry => 'Kết nối chậm, thử lại nhé.';

  @override
  String get scanUnavailable => 'Chưa phân tích được ảnh này.';

  @override
  String get notificationChannelName => 'Nhắc nhở bữa ăn hàng ngày';

  @override
  String get notificationChannelDescription => 'Thông báo nhắc nhở quét calo bữa sáng, trưa, tối từ CalGo';

  @override
  String get notificationBreakfastTitle => 'CalGo - Bữa Sáng';

  @override
  String get notificationBreakfastBody => 'Chào buổi sáng bro, đừng quên quét hình bữa sáng để nạp đủ năng lượng cho ngày mới nhé';

  @override
  String get notificationLunchTitle => 'CalGo - Bữa Trưa';

  @override
  String get notificationLunchBody => 'Giờ nghỉ trưa rồi nè bro, mở CalGo quét món trưa để theo dõi calo chuẩn đét nhé';

  @override
  String get notificationDinnerTitle => 'CalGo - Bữa Tối';

  @override
  String get notificationDinnerBody => 'Bữa tối đã sẵn sàng chưa bro, chụp hình quét calo để giữ kỷ luật dáng đẹp nào';

  @override
  String get notificationDirectChannel => 'Thông báo trực tiếp';

  @override
  String get caloriesLabel => 'Calo';

  @override
  String get carbsLabel => 'CARB';

  @override
  String get fatLabel => 'CHẤT BÉO';

  @override
  String get guidanceTodayShortSubtitle => 'Xem gợi ý theo mục tiêu hôm nay';

  @override
  String get ingredientBeef => 'Thịt bò tươi';

  @override
  String get ingredientChicken => 'Ức gà áp chảo';

  @override
  String get ingredientEgg => 'Trứng gà';

  @override
  String get ingredientRiceNoodles => 'Bánh phở tươi';

  @override
  String get ingredientRice => 'Cơm trắng';

  @override
  String get ingredientBun => 'Bún tươi';

  @override
  String get ingredientSalad => 'Xà lách & Cà chua';

  @override
  String get ingredientCheddar => 'Phô mai Cheddar';

  @override
  String get ingredientPassionSauce => 'Sốt chanh dây';

  @override
  String get ingredientPork => 'Thịt nạc heo';

  @override
  String get mockPhoTitle => 'Phở Bò Tái Nạm';

  @override
  String get mockPhoNoodles => 'Bánh phở tươi';

  @override
  String get mockPhoRareBeef => 'Thịt bò tái';

  @override
  String get mockPhoBrisket => 'Thịt nạm bò';

  @override
  String get mockPhoBroth => 'Nước dùng phở & Hành lá';

  @override
  String get mockRiceTitle => 'Cơm Tấm Sườn Bì Chả';

  @override
  String get mockRice => 'Cơm tấm';

  @override
  String get mockGrilledPork => 'Sườn heo nướng';

  @override
  String get mockEggCake => 'Chả trứng hấp';

  @override
  String get mockFriedEgg => 'Trứng ốp la';

  @override
  String get mockSaladTitle => 'Salad Ức Gà Sốt Chanh Dây';

  @override
  String get mockChicken => 'Ức gà áp chảo';

  @override
  String get mockSalad => 'Xà lách & Cà chua chery';

  @override
  String get mockPassionSauce => 'Sốt chanh dây';

  @override
  String motivationAdviceLose(String remaining) {
    return 'Bạn chỉ còn cách mục tiêu $remaining kg. Những thói quen nhỏ mỗi ngày sẽ hiệu quả hơn chế độ ăn kiêng khắc nghiệt.';
  }

  @override
  String get motivationAdviceGain => 'Mục tiêu calo được tối ưu để xây dựng cơ bắp săn chắc, đồng thời hạn chế tích tụ mỡ thừa.';

  @override
  String get motivationAdviceMaintain => 'Cân nặng hiện tại của bạn đã ở mức khỏe mạnh. Hãy cùng xây dựng thói quen giúp bạn luôn cảm thấy tốt nhất mỗi ngày.';

  @override
  String get motivationAdviceDefault => 'Hãy cùng nhau đạt được mục tiêu sức khỏe của bạn với những thói quen bền vững.';

  @override
  String get taoAdviceLabel => 'LỜI KHUYÊN TỪ TÁO';

  @override
  String get taoReminder => 'Táo sẽ nhắc bạn mỗi ngày';

  @override
  String get packBasic => 'Phổ thông';

  @override
  String get packPopular => 'Phổ biến';

  @override
  String get packPremium => 'Cao cấp';

  @override
  String creditPackageSummary(int count, String unit) {
    return '$count lượt • $unit';
  }

  @override
  String get perScan => '/lượt';

  @override
  String caloriesValue(int calories) {
    return '$calories kcal';
  }

  @override
  String caloriesPer100g(int calories) {
    return '$calories kcal / 100g';
  }

  @override
  String gramsValue(int grams) {
    return '${grams}g';
  }

  @override
  String weightKgValue(String weight) {
    return '$weight kg';
  }

  @override
  String galleryMacroSummary(int calories, String carbs, String protein, String fat) {
    return '$calories kcal • C:${carbs}g P:${protein}g F:${fat}g';
  }

  @override
  String sharePayload(String dish, int calories) {
    return '🔥 $dish · $calories kcal | CalGo';
  }
}
