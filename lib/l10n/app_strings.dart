class AppStrings {
  final String languageCode;

  const AppStrings(this.languageCode);

  static const AppStrings vi = AppStrings('vi');
  static const AppStrings en = AppStrings('en');
  static const AppStrings es = AppStrings('es');

  static AppStrings of(String code) {
    switch (code) {
      case 'en':
        return en;
      case 'es':
        return es;
      case 'vi':
      default:
        return vi;
    }
  }

  // ── Navigation Tabs ──────────────────────────────────────────
  String get tabHome {
    switch (languageCode) {
      case 'en':
        return 'Home';
      case 'es':
        return 'Inicio';
      case 'vi':
      default:
        return 'Trang chủ';
    }
  }

  String get tabAnalytics {
    switch (languageCode) {
      case 'en':
        return 'Analytics';
      case 'es':
        return 'Estadísticas';
      case 'vi':
      default:
        return 'Thống kê';
    }
  }

  String get tabSettings {
    switch (languageCode) {
      case 'en':
        return 'Settings';
      case 'es':
        return 'Ajustes';
      case 'vi':
      default:
        return 'Cài đặt';
    }
  }

  // ── Home Screen ──────────────────────────────────────────────
  String get today {
    switch (languageCode) {
      case 'en':
        return 'Today';
      case 'es':
        return 'Hoy';
      case 'vi':
      default:
        return 'Hôm nay';
    }
  }

  String get yesterday {
    switch (languageCode) {
      case 'en':
        return 'Yesterday';
      case 'es':
        return 'Ayer';
      case 'vi':
      default:
        return 'Hôm qua';
    }
  }

  String get caloriesLeft {
    switch (languageCode) {
      case 'en':
        return 'Calories left';
      case 'es':
        return 'Calorías restantes';
      case 'vi':
      default:
        return 'Calo còn lại';
    }
  }

  String get proteinLeft {
    switch (languageCode) {
      case 'en':
        return 'Protein left';
      case 'es':
        return 'Proteínas restantes';
      case 'vi':
      default:
        return 'Protein còn';
    }
  }

  String get carbsLeft {
    switch (languageCode) {
      case 'en':
        return 'Carbs left';
      case 'es':
        return 'Carbohidratos restantes';
      case 'vi':
      default:
        return 'Carbs còn';
    }
  }

  String get fatsLeft {
    switch (languageCode) {
      case 'en':
        return 'Fats left';
      case 'es':
        return 'Grasas restantes';
      case 'vi':
      default:
        return 'Fats còn';
    }
  }

  String get recentlyUploaded {
    switch (languageCode) {
      case 'en':
        return 'Recently uploaded';
      case 'es':
        return 'Subidos gần đây';
      case 'vi':
      default:
        return 'Đã tải lên gần đây';
    }
  }

  String get noMealsUploaded {
    switch (languageCode) {
      case 'en':
        return 'No meals uploaded yet';
      case 'es':
        return 'No hay comidas subidas aún';
      case 'vi':
      default:
        return 'Chưa có bữa ăn nào';
    }
  }

  String get tapToScanMeal {
    switch (languageCode) {
      case 'en':
        return 'Tap to scan your first meal with AI';
      case 'es':
        return 'Toca para escanear tu primera comida con IA';
      case 'vi':
      default:
        return 'Chạm để quét bữa ăn đầu tiên bằng AI';
    }
  }

  // ── Profile / Account Screen ───────────────────────────────
  String get profileTitle {
    switch (languageCode) {
      case 'en':
        return 'Personal Account';
      case 'es':
        return 'Cuenta Personal';
      case 'vi':
      default:
        return 'Tài khoản cá nhân';
    }
  }

  String get creditsLabel {
    switch (languageCode) {
      case 'en':
        return 'Scan credits';
      case 'es':
        return 'Créditos de escaneo';
      case 'vi':
      default:
        return 'Lượt quét';
    }
  }

  String get scannedCountLabel {
    switch (languageCode) {
      case 'en':
        return 'Meals scanned';
      case 'es':
        return 'Comidas escaneadas';
      case 'vi':
      default:
        return 'Đã scan';
    }
  }

  String get buyCredits {
    switch (languageCode) {
      case 'en':
        return 'Buy Credits';
      case 'es':
        return 'Comprar Créditos';
      case 'vi':
      default:
        return 'Mua lượt quét';
    }
  }

  String get statistics {
    switch (languageCode) {
      case 'en':
        return 'Statistics';
      case 'es':
        return 'Estadísticas';
      case 'vi':
      default:
        return 'Thống kê';
    }
  }

  String get calorieTarget {
    switch (languageCode) {
      case 'en':
        return 'Calorie Goal';
      case 'es':
        return 'Meta de Calorías';
      case 'vi':
      default:
        return 'Mục tiêu Calo';
    }
  }

  String get notifications {
    switch (languageCode) {
      case 'en':
        return 'Notifications';
      case 'es':
        return 'Notificaciones';
      case 'vi':
      default:
        return 'Thông báo';
    }
  }

  String get darkMode {
    switch (languageCode) {
      case 'en':
        return 'Dark Mode';
      case 'es':
        return 'Modo Oscuro';
      case 'vi':
      default:
        return 'Chế độ tối';
    }
  }

  String get language {
    switch (languageCode) {
      case 'en':
        return 'Language';
      case 'es':
        return 'Idioma';
      case 'vi':
      default:
        return 'Ngôn ngữ';
    }
  }

  String get languageDisplayName {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'vi':
      default:
        return 'Tiếng Việt';
    }
  }

  String get userGuide {
    switch (languageCode) {
      case 'en':
        return 'User Guide';
      case 'es':
        return 'Guía de Usuario';
      case 'vi':
      default:
        return 'Hướng dẫn sử dụng';
    }
  }

  String get customerSupport {
    switch (languageCode) {
      case 'en':
        return 'Customer Support';
      case 'es':
        return 'Soporte al Cliente';
      case 'vi':
      default:
        return 'Hỗ trợ khách hàng';
    }
  }

  String get logout {
    switch (languageCode) {
      case 'en':
        return 'Log Out';
      case 'es':
        return 'Cerrar Sesión';
      case 'vi':
      default:
        return 'Đăng xuất';
    }
  }

  String get selectLanguageTitle {
    switch (languageCode) {
      case 'en':
        return 'Select Language';
      case 'es':
        return 'Seleccionar Idioma';
      case 'vi':
      default:
        return 'Chọn ngôn ngữ';
    }
  }

  // ── Scan Screen ─────────────────────────────────────────────
  String get scanTitle {
    switch (languageCode) {
      case 'en':
        return 'Scan Meal';
      case 'es':
        return 'Escanear Comida';
      case 'vi':
      default:
        return 'Quét món ăn';
    }
  }

  String get scanInstructionHeader {
    switch (languageCode) {
      case 'en':
        return 'Keep food within the frame';
      case 'es':
        return 'Mantén la comida en el marco';
      case 'vi':
      default:
        return 'Giữ món ăn trong khung hình';
    }
  }

  String get scanInstructionSub {
    switch (languageCode) {
      case 'en':
        return 'Ensure proper lighting for accurate AI recognition';
      case 'es':
        return 'Asegúrate de tener buena luz para el reconocimiento de IA';
      case 'vi':
      default:
        return 'Đảm bảo đủ ánh sáng để AI nhận diện chính xác';
    }
  }

  String get selectFromGallery {
    switch (languageCode) {
      case 'en':
        return 'Select from Gallery';
      case 'es':
        return 'Seleccionar de la galería';
      case 'vi':
      default:
        return 'Chọn từ thư viện';
    }
  }

  String get outOfCreditsTitle {
    switch (languageCode) {
      case 'en':
        return 'Out of Scan Credits!';
      case 'es':
        return '¡Sin créditos de escaneo!';
      case 'vi':
      default:
        return 'Hết lượt quét!';
    }
  }

  String get outOfCreditsMessage {
    switch (languageCode) {
      case 'en':
        return 'You have used all your scan credits. Top up to continue tracking nutrition!';
      case 'es':
        return 'Has usado todos tus créditos. ¡Recarga para continuar!';
      case 'vi':
      default:
        return 'Bạn đã hết lượt quét. Mua thêm lượt để tiếp tục theo dõi dinh dưỡng nhé!';
    }
  }

  String get buyMore {
    switch (languageCode) {
      case 'en':
        return 'Buy More';
      case 'es':
        return 'Comprar más';
      case 'vi':
      default:
        return 'Mua ngay';
    }
  }

  String get cancel {
    switch (languageCode) {
      case 'en':
        return 'Cancel';
      case 'es':
        return 'Cancelar';
      case 'vi':
      default:
        return 'Hủy';
    }
  }

  // ── Pricing Screen ──────────────────────────────────────────
  String get pricingTitle {
    switch (languageCode) {
      case 'en':
        return 'Upgrade & Credits';
      case 'es':
        return 'Planes y Créditos';
      case 'vi':
      default:
        return 'Gói dịch vụ & Lượt quét';
    }
  }

  String get pricingSubtitle {
    switch (languageCode) {
      case 'en':
        return 'Choose the best plan to unlock full AI capabilities';
      case 'es':
        return 'Elige el mejor plan para desbloquear la IA';
      case 'vi':
      default:
        return 'Lựa chọn gói phù hợp để trải nghiệm AI tối đa';
    }
  }

  String get creditPacksTitle {
    switch (languageCode) {
      case 'en':
        return 'Scan Credit Packages';
      case 'es':
        return 'Paquetes de Créditos';
      case 'vi':
      default:
        return 'Gói mua lượt quét';
    }
  }

  String get noExpiryBadge {
    switch (languageCode) {
      case 'en':
        return 'No Expiry';
      case 'es':
        return 'Sin Caducidad';
      case 'vi':
      default:
        return 'Không hết hạn';
    }
  }

  String get popularBadge {
    switch (languageCode) {
      case 'en':
        return 'Popular';
      case 'es':
        return 'Popular';
      case 'vi':
      default:
        return 'Phổ biến';
    }
  }

  String get subscriptionsTitle {
    switch (languageCode) {
      case 'en':
        return 'Pro Subscriptions';
      case 'es':
        return 'Suscripciones Pro';
      case 'vi':
      default:
        return 'Gói thành viên Premium';
    }
  }

  String get payButton {
    switch (languageCode) {
      case 'en':
        return 'Pay Now';
      case 'es':
        return 'Pagar Ahora';
      case 'vi':
      default:
        return 'Thanh toán ngay';
    }
  }

  // ── Legal & Compliance ───────────────────────────────────────
  String get privacyPolicy {
    switch (languageCode) {
      case 'en':
        return 'Privacy Policy';
      case 'es':
        return 'Política de Privacidad';
      case 'vi':
      default:
        return 'Chính sách bảo mật';
    }
  }

  String get termsOfService {
    switch (languageCode) {
      case 'en':
        return 'Terms of Service';
      case 'es':
        return 'Términos de Servicio';
      case 'vi':
      default:
        return 'Điều khoản sử dụng';
    }
  }

  String get deleteAccount {
    switch (languageCode) {
      case 'en':
        return 'Delete Account';
      case 'es':
        return 'Eliminar Cuenta';
      case 'vi':
      default:
        return 'Xóa tài khoản';
    }
  }

  String get restorePurchases {
    switch (languageCode) {
      case 'en':
        return 'Restore Purchases';
      case 'es':
        return 'Restaurar Compras';
      case 'vi':
      default:
        return 'Khôi phục mua hàng';
    }
  }

  String get privacyPolicyContent {
    switch (languageCode) {
      case 'en':
        return 'CalGo Privacy Policy:\n\n'
            '1. Data Collection: CalGo only collects meal images and nutrition data provided by users for calorie analysis.\n'
            '2. Camera & Photo Permissions: Camera and gallery permissions are only used when you actively scan or select food photos.\n'
            '3. Data Protection: All data is encrypted and securely stored on server infrastructure.\n'
            '4. User Rights: You have the right to request data deletion or permanently delete your account at any time in Settings.';
      case 'es':
        return 'Política de Privacidad de CalGo:\n\n'
            '1. Recopilación de datos: CalGo solo recopila imágenes de comidas y datos nutricionales proporcionados por el usuario.\n'
            '2. Permisos de cámara y fotos: Solo se utilizan cuando escaneas o seleccionas fotos de alimentos.\n'
            '3. Protección de datos: Todos los datos se encriptan y almacenan de forma segura.\n'
            '4. Derechos del usuario: Tienes derecho a eliminar tu cuenta de forma permanente en cualquier momento.';
      case 'vi':
      default:
        return 'Chính sách bảo mật CalGo:\n\n'
            '1. Thu thập dữ liệu: CalGo chỉ thu thập thông tin hình ảnh món ăn và chỉ số dinh dưỡng do người dùng cung cấp nhằm mục đích phân tích calo.\n'
            '2. Quyền camera & ảnh: Ứng dụng chỉ sử dụng quyền camera và thư viện ảnh khi người dùng chủ động chụp/chọn ảnh món ăn.\n'
            '3. Bảo mật thông tin: Toàn bộ dữ liệu được mã hóa và bảo vệ an toàn trên hệ thống máy chủ.\n'
            '4. Quyền của người dùng: Bạn có quyền xuất dữ liệu hoặc xóa vĩnh viễn tài khoản bất cứ lúc nào trong mục Cài đặt.';
    }
  }

  String get termsOfServiceContent {
    switch (languageCode) {
      case 'en':
        return 'CalGo Terms of Service:\n\n'
            '1. Medical Disclaimer: CalGo uses AI technology to estimate calorie and nutrient values. Information is for reference only and does not substitute professional medical advice.\n'
            '2. Subscription & Packs: Premium plans and scan credits are priced according to app store guidelines.\n'
            '3. Intellectual Property: All images, logos, and algorithms are proprietary to CalGo.';
      case 'es':
        return 'Términos de Servicio de CalGo:\n\n'
            '1. Descargo de responsabilidad médica: CalGo utiliza IA para estimar valores nutricionales. La información es solo de referencia y no sustituye el consejo médico profesional.\n'
            '2. Suscripciones: Los planes Pro y créditos de escaneo se rigen por las normas de las tiendas de aplicaciones.\n'
            '3. Propiedad intelectual: Todos los derechos pertenecen a CalGo.';
      case 'vi':
      default:
        return 'Điều khoản sử dụng CalGo:\n\n'
            '1. Miễn trừ y tế: CalGo sử dụng công nghệ AI để ước tính lượng calo và dinh dưỡng. Thông tin chỉ mang tính chất tham khảo và không thay thế cho tư vấn, chẩn đoán hay điều trị y khoa chuyên nghiệp.\n'
            '2. Gói dịch vụ: Dịch vụ Premium và lượt quét được tính giá theo quy định trên cửa hàng ứng dụng.\n'
            '3. Quyền sở hữu trí tuệ: Tất cả hình ảnh, logo và thuật toán thuộc sở hữu của CalGo.';
    }
  }

  String get deleteAccountConfirmMessage {
    switch (languageCode) {
      case 'en':
        return 'Are you sure you want to permanently delete your CalGo account and all calorie log data? This action cannot be undone.';
      case 'es':
        return '¿Estás seguro de que deseas eliminar permanentemente tu cuenta de CalGo y todos los datos? Esta acción no se puede deshacer.';
      case 'vi':
      default:
        return 'Bạn có chắc chắn muốn xóa tài khoản CalGo và toàn bộ dữ liệu nhật ký calo của mình không?\n\nHành động này không thể hoàn tác.';
    }
  }
}
