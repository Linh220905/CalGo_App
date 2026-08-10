import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
    Locale('ru'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tabAnalytics;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @caloriesLeft.
  ///
  /// In en, this message translates to:
  /// **'Calories left'**
  String get caloriesLeft;

  /// No description provided for @proteinLeft.
  ///
  /// In en, this message translates to:
  /// **'Protein left'**
  String get proteinLeft;

  /// No description provided for @carbsLeft.
  ///
  /// In en, this message translates to:
  /// **'Carbs left'**
  String get carbsLeft;

  /// No description provided for @fatsLeft.
  ///
  /// In en, this message translates to:
  /// **'Fats left'**
  String get fatsLeft;

  /// No description provided for @recentlyUploaded.
  ///
  /// In en, this message translates to:
  /// **'Recently uploaded'**
  String get recentlyUploaded;

  /// No description provided for @noMealsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No meals uploaded yet'**
  String get noMealsUploaded;

  /// No description provided for @tapToScanMeal.
  ///
  /// In en, this message translates to:
  /// **'Tap to scan your first meal with AI'**
  String get tapToScanMeal;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Account'**
  String get profileTitle;

  /// No description provided for @creditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan credits'**
  String get creditsLabel;

  /// No description provided for @scannedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Meals scanned'**
  String get scannedCountLabel;

  /// No description provided for @buyCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get buyCredits;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @calorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Calorie Goal'**
  String get calorieTarget;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDisplayName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageDisplayName;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuide;

  /// No description provided for @customerSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get customerSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Meal'**
  String get scanTitle;

  /// No description provided for @scanInstructionHeader.
  ///
  /// In en, this message translates to:
  /// **'Keep food within the frame'**
  String get scanInstructionHeader;

  /// No description provided for @scanInstructionSub.
  ///
  /// In en, this message translates to:
  /// **'Ensure proper lighting for accurate AI recognition'**
  String get scanInstructionSub;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @outOfCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of Scan Credits!'**
  String get outOfCreditsTitle;

  /// No description provided for @outOfCreditsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used all your scan credits. Top up to continue tracking nutrition!'**
  String get outOfCreditsMessage;

  /// No description provided for @buyMore.
  ///
  /// In en, this message translates to:
  /// **'Buy More'**
  String get buyMore;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @pricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade & Credits'**
  String get pricingTitle;

  /// No description provided for @pricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the best plan to unlock full AI capabilities'**
  String get pricingSubtitle;

  /// No description provided for @creditPacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Credit Packages'**
  String get creditPacksTitle;

  /// No description provided for @noExpiryBadge.
  ///
  /// In en, this message translates to:
  /// **'No Expiry'**
  String get noExpiryBadge;

  /// No description provided for @popularBadge.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popularBadge;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Subscriptions'**
  String get subscriptionsTitle;

  /// No description provided for @payButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payButton;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @openOnline.
  ///
  /// In en, this message translates to:
  /// **'Open online'**
  String get openOnline;

  /// No description provided for @onlineGuide.
  ///
  /// In en, this message translates to:
  /// **'Online guide'**
  String get onlineGuide;

  /// No description provided for @deleteAccountSubscriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'Deleting your CalGo account does not cancel a Google Play subscription. If you have Premium, cancel it separately in Google Play to avoid a renewal charge.'**
  String get deleteAccountSubscriptionWarning;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'CalGo Privacy Policy (updated 5 Aug 2026):\n\n1. Data we collect: account email, display name, Google sign-in identifier, onboarding nutrition information, meal photos, scan results, meal history, purchase metadata, app/device diagnostics and notification preferences.\n2. How permissions are used: camera and photo access are requested only when you choose to capture or select a meal photo; notifications are used only when enabled.\n3. How data is used: to provide AI nutrition analysis, sync your account, process Google Play purchases, prevent abuse, provide support and improve reliability. Photos may be processed by our hosting and AI service providers.\n4. Sharing and security: we do not sell your personal data or meal photos. Necessary providers such as hosting, AI processing, Google Sign-In and Google Play Billing may process limited data. We use HTTPS and access controls, but no system is completely secure.\n5. Retention and deletion: account data and meal history are deleted when you delete your account, except data that must be retained for fraud prevention, disputes or legal obligations. Backups may take a reasonable time to expire.\n6. Your rights: delete your account in Profile or visit https://calgo.tech/delete-account. For access, correction or questions, contact support@calgo.tech. Full policy: https://calgo.tech/privacy.'**
  String get privacyPolicyContent;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In en, this message translates to:
  /// **'CalGo Terms of Service:\n\n1. Service and medical disclaimer: AI nutrition results are estimates for reference only and do not replace professional medical advice. CalGo is not a medical device.\n2. Payments: credit packs are one-time digital purchases. Premium weekly, monthly and annual plans are auto-renewing Google Play subscriptions unless cancelled before the next renewal. Manage or cancel at https://play.google.com/store/account/subscriptions.\n3. Refunds and deletion: Google Play handles Android billing and refunds. Deleting a CalGo account does not cancel a Google Play subscription.\n4. Content and intellectual property: you retain ownership of uploaded photos; CalGo receives a limited license to process them to provide and improve the service. CalGo owns its app, branding and software.\n5. Contact: support@calgo.tech. Full terms: https://calgo.tech/terms.'**
  String get termsOfServiceContent;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your CalGo account and all calorie log data? This action cannot be undone.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your nutrition journey'**
  String get historySubtitle;

  /// No description provided for @mealsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsCountLabel;

  /// No description provided for @streakDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakDaysLabel;

  /// No description provided for @kcalPerDay.
  ///
  /// In en, this message translates to:
  /// **'Kcal/day'**
  String get kcalPerDay;

  /// No description provided for @proteinPerDay.
  ///
  /// In en, this message translates to:
  /// **'Protein/day'**
  String get proteinPerDay;

  /// No description provided for @noMealsHistory.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get noMealsHistory;

  /// No description provided for @scanFirstMealPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan your first meal to start\nyour nutrition journey'**
  String get scanFirstMealPrompt;

  /// No description provided for @scanFirstMealButton.
  ///
  /// In en, this message translates to:
  /// **'Scan First Meal'**
  String get scanFirstMealButton;

  /// No description provided for @deleteMealConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this meal?'**
  String get deleteMealConfirm;

  /// No description provided for @cannotDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Could not delete meal. Please try again.'**
  String get cannotDeleteMeal;

  /// No description provided for @photoGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Photos'**
  String get photoGalleryTitle;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No food scan photos yet'**
  String get noPhotosYet;

  /// No description provided for @takePhotosPrompt.
  ///
  /// In en, this message translates to:
  /// **'Snap photos of your meals to build your collection!'**
  String get takePhotosPrompt;

  /// No description provided for @scanFoodNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Food Now'**
  String get scanFoodNow;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @snapPhotoAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo. Let AI work.'**
  String get snapPhotoAiTitle;

  /// No description provided for @snapPhotoAiDesc.
  ///
  /// In en, this message translates to:
  /// **'AI automatically recognizes food and calculates calories in seconds.'**
  String get snapPhotoAiDesc;

  /// No description provided for @trackEasilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Track with ease.'**
  String get trackEasilyTitle;

  /// No description provided for @trackEasilyDesc.
  ///
  /// In en, this message translates to:
  /// **'Track calories, protein, carbs, and fat every day.'**
  String get trackEasilyDesc;

  /// No description provided for @reachGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach goals faster.'**
  String get reachGoalsTitle;

  /// No description provided for @reachGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get personalized targets and track fat loss progress.'**
  String get reachGoalsDesc;

  /// No description provided for @nextStepButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStepButton;

  /// No description provided for @goalStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get goalStepTitle;

  /// No description provided for @goalStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps CalGo build a plan that fits you'**
  String get goalStepSubtitle;

  /// No description provided for @goalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get goalLoseWeight;

  /// No description provided for @goalLoseWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Burn fat efficiently, tone body'**
  String get goalLoseWeightDesc;

  /// No description provided for @goalLoseWeightReason.
  ///
  /// In en, this message translates to:
  /// **'This helps us build a fat-loss plan that protects muscle and stays sustainable.'**
  String get goalLoseWeightReason;

  /// No description provided for @goalGainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain Muscle'**
  String get goalGainMuscle;

  /// No description provided for @goalGainMuscleDesc.
  ///
  /// In en, this message translates to:
  /// **'Build muscle and increase strength'**
  String get goalGainMuscleDesc;

  /// No description provided for @goalGainMuscleReason.
  ///
  /// In en, this message translates to:
  /// **'This helps us build a muscle-gain plan around your training and protein needs.'**
  String get goalGainMuscleReason;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get goalMaintain;

  /// No description provided for @goalMaintainDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your balanced physique'**
  String get goalMaintainDesc;

  /// No description provided for @goalMaintainReason.
  ///
  /// In en, this message translates to:
  /// **'This helps us build a balanced plan that fits your life long term.'**
  String get goalMaintainReason;

  /// No description provided for @nameStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Your name is...'**
  String get nameStepTitle;

  /// No description provided for @nameStepHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameStepHint;

  /// No description provided for @demoStepTitle.
  ///
  /// In en, this message translates to:
  /// **'See CalGo in Action'**
  String get demoStepTitle;

  /// No description provided for @genderStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your gender?'**
  String get genderStepTitle;

  /// No description provided for @genderStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For accurate calculations'**
  String get genderStepSubtitle;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @ageStepTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get ageStepTitle;

  /// No description provided for @heightStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your height?'**
  String get heightStepTitle;

  /// No description provided for @weightStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your current weight?'**
  String get weightStepTitle;

  /// No description provided for @targetWeightStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your target weight?'**
  String get targetWeightStepTitle;

  /// No description provided for @activityStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your activity level?'**
  String get activityStepTitle;

  /// No description provided for @dietStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you follow any specific diet?'**
  String get dietStepTitle;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your data...'**
  String get analysisTitle;

  /// No description provided for @accountStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account to Save Your Plan'**
  String get accountStepTitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @heightStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Helps calculate BMI and accurate calorie needs'**
  String get heightStepDesc;

  /// No description provided for @weightStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Helps determine your personalized nutrition goals'**
  String get weightStepDesc;

  /// No description provided for @currentHeightHeader.
  ///
  /// In en, this message translates to:
  /// **'Current Height'**
  String get currentHeightHeader;

  /// No description provided for @currentWeightHeader.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeightHeader;

  /// No description provided for @bmiIndexTitle.
  ///
  /// In en, this message translates to:
  /// **'BMI Index'**
  String get bmiIndexTitle;

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// No description provided for @targetWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Helps set your personal nutritional targets'**
  String get targetWeightDesc;

  /// No description provided for @goalMaintainLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintain physique'**
  String get goalMaintainLabel;

  /// No description provided for @goalLoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight loss'**
  String get goalLoseLabel;

  /// No description provided for @goalGainLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle gain'**
  String get goalGainLabel;

  /// No description provided for @goalMaintainHint.
  ///
  /// In en, this message translates to:
  /// **'Target equals your current weight'**
  String get goalMaintainHint;

  /// Localized UI text: goalLoseDiffText
  ///
  /// In en, this message translates to:
  /// **'Target: Lose {kg} kg'**
  String goalLoseDiffText(String kg);

  /// Localized UI text: goalGainDiffText
  ///
  /// In en, this message translates to:
  /// **'Target: Gain {kg} kg'**
  String goalGainDiffText(String kg);

  /// No description provided for @paceStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Pace per week?'**
  String get paceStepTitle;

  /// No description provided for @paceStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a comfortable rate for your lifestyle'**
  String get paceStepSubtitle;

  /// No description provided for @activityStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Affects your daily calorie expenditure'**
  String get activityStepSubtitle;

  /// No description provided for @dietStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CalGo recommends meals best suited for your body and goals.'**
  String get dietStepSubtitle;

  /// No description provided for @socialProofTitle.
  ///
  /// In en, this message translates to:
  /// **'What the community says about CalGo'**
  String get socialProofTitle;

  /// No description provided for @socialProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Authentic reviews from real members'**
  String get socialProofSubtitle;

  /// No description provided for @ratingTag.
  ///
  /// In en, this message translates to:
  /// **'5★ Rating'**
  String get ratingTag;

  /// No description provided for @referralStepTitle.
  ///
  /// In en, this message translates to:
  /// **'How did you hear about CalGo?'**
  String get referralStepTitle;

  /// No description provided for @referralStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps us understand your journey'**
  String get referralStepSubtitle;

  /// No description provided for @referralFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend recommendation'**
  String get referralFriend;

  /// No description provided for @sportsStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What sports do you play?'**
  String get sportsStepTitle;

  /// No description provided for @sportsStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select activities you do regularly'**
  String get sportsStepSubtitle;

  /// No description provided for @accountStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure information & sync personal progress'**
  String get accountStepSubtitle;

  /// No description provided for @dataPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is strictly encrypted & confidential'**
  String get dataPrivacyNote;

  /// Localized UI text: analysisHello
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String analysisHello(String name);

  /// No description provided for @analysisPlanReady.
  ///
  /// In en, this message translates to:
  /// **'Your plan is ready'**
  String get analysisPlanReady;

  /// No description provided for @dailyCalorieTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY CALORIE TARGET'**
  String get dailyCalorieTargetTitle;

  /// No description provided for @kcalPerDayUnit.
  ///
  /// In en, this message translates to:
  /// **'kcal / day'**
  String get kcalPerDayUnit;

  /// No description provided for @workoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutLabel;

  /// Localized UI text: workoutDaysText
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String workoutDaysText(String days);

  /// No description provided for @perWeekText.
  ///
  /// In en, this message translates to:
  /// **'per week'**
  String get perWeekText;

  /// No description provided for @yourJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR JOURNEY'**
  String get yourJourneyTitle;

  /// No description provided for @journeyCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get journeyCurrent;

  /// No description provided for @journeyTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get journeyTarget;

  /// No description provided for @journeyTimeframe.
  ///
  /// In en, this message translates to:
  /// **'Timeframe'**
  String get journeyTimeframe;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks'**
  String weeksUnit(int weeks);

  /// Localized UI text: completedPercent
  ///
  /// In en, this message translates to:
  /// **'{p}% completed'**
  String completedPercent(int p);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CalGo'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your nutrition data'**
  String get loginSubtitle;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogle;

  /// No description provided for @loginApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginApple;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @appleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in is coming soon!'**
  String get appleComingSoon;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in with Google to protect and sync your data.'**
  String get loginRequired;

  /// No description provided for @loginRequiredButton.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is required to sync data'**
  String get loginRequiredButton;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @dataLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data'**
  String get dataLoadFailed;

  /// No description provided for @deleteMealQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this meal?'**
  String get deleteMealQuestion;

  /// No description provided for @deleteMealFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the meal. Please try again.'**
  String get deleteMealFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealTypeSnack;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @aiCoachAlmostGoal.
  ///
  /// In en, this message translates to:
  /// **'Almost hit your goal! Keep going!'**
  String get aiCoachAlmostGoal;

  /// No description provided for @aiCoachPlentyCalories.
  ///
  /// In en, this message translates to:
  /// **'Plenty of calories left today. Eat well!'**
  String get aiCoachPlentyCalories;

  /// No description provided for @aiCoachMomentum.
  ///
  /// In en, this message translates to:
  /// **'Keep up the good momentum!'**
  String get aiCoachMomentum;

  /// No description provided for @mascotGoalTipWater.
  ///
  /// In en, this message translates to:
  /// **'Drink a sip of water to stay refreshed!'**
  String get mascotGoalTipWater;

  /// No description provided for @mascotGoalTipSlow.
  ///
  /// In en, this message translates to:
  /// **'Eating slowly and listening to your body is awesome.'**
  String get mascotGoalTipSlow;

  /// No description provided for @mascotGoalTipGreat.
  ///
  /// In en, this message translates to:
  /// **'You did great today ✨'**
  String get mascotGoalTipGreat;

  /// No description provided for @mascotGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Calorie goal reached for today! Keeping this pace is top tier ✨'**
  String get mascotGoalReached;

  /// No description provided for @mascotGuidanceIntro.
  ///
  /// In en, this message translates to:
  /// **'I picked some nice meals for you today. Tap to check them out!'**
  String get mascotGuidanceIntro;

  /// No description provided for @mascotGuidanceOpen.
  ///
  /// In en, this message translates to:
  /// **'The recommended dishes are still in the suggestion screen!'**
  String get mascotGuidanceOpen;

  /// No description provided for @mascotGuidanceTipWater.
  ///
  /// In en, this message translates to:
  /// **'Did you drink enough water? Have a sip to refresh!'**
  String get mascotGuidanceTipWater;

  /// No description provided for @mascotGuidanceTipSlow.
  ///
  /// In en, this message translates to:
  /// **'Eat slowly, you will feel full longer!'**
  String get mascotGuidanceTipSlow;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'You are {calories} kcal over. I picked light meals for you!'**
  String mascotGuidanceOverTarget(int calories);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'You need {calories} kcal more to hit your goal. Check out my picks!'**
  String mascotGuidanceRemaining(int calories);

  /// No description provided for @mascotTipHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydrated yet, bro? Take a sip of water to stay sharp'**
  String get mascotTipHydration;

  /// No description provided for @mascotTipChew.
  ///
  /// In en, this message translates to:
  /// **'Chew slowly, it helps digestion and keeps you full'**
  String get mascotTipChew;

  /// No description provided for @mascotTipConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency every day builds a great physique'**
  String get mascotTipConsistency;

  /// No description provided for @mascotNoMeals.
  ///
  /// In en, this message translates to:
  /// **'Haven\'t logged anything yet? Snap a food photo to show me!'**
  String get mascotNoMeals;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Over your target by about {calories} kcal today. No worries, go light and high protein for your next meal!'**
  String mascotOverTarget(int calories);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Still missing {calories} kcal today. Go grab something delicious!'**
  String mascotMissingCalories(int calories);

  /// No description provided for @mascotOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Flawless discipline! Calories hit right on point!'**
  String get mascotOnTrack;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No meals} =1 {1 meal} other {{count} meals}}'**
  String mealCount(int count);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No ingredients} =1 {1 ingredient} other {{count} ingredients}}'**
  String ingredientCount(int count);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 dish} other {{count} dishes}}'**
  String dishCount(int count);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Month {month}'**
  String monthFallback(int month);

  /// No description provided for @scanProcessingRecognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing your meal...'**
  String get scanProcessingRecognizing;

  /// No description provided for @scanProcessingRecognized.
  ///
  /// In en, this message translates to:
  /// **'Meal recognized'**
  String get scanProcessingRecognized;

  /// No description provided for @scanProcessingIngredients.
  ///
  /// In en, this message translates to:
  /// **'Analyzing ingredients...'**
  String get scanProcessingIngredients;

  /// No description provided for @scanProcessingNutrition.
  ///
  /// In en, this message translates to:
  /// **'Identifying nutrition facts...'**
  String get scanProcessingNutrition;

  /// No description provided for @scanProcessingCalories.
  ///
  /// In en, this message translates to:
  /// **'Calculating calories...'**
  String get scanProcessingCalories;

  /// No description provided for @scanProcessingPortion.
  ///
  /// In en, this message translates to:
  /// **'Estimating portion size...'**
  String get scanProcessingPortion;

  /// No description provided for @scanProcessingSummary.
  ///
  /// In en, this message translates to:
  /// **'AI is compiling your result...'**
  String get scanProcessingSummary;

  /// No description provided for @scanProcessingReport.
  ///
  /// In en, this message translates to:
  /// **'Preparing report...'**
  String get scanProcessingReport;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was denied. Open Settings and allow camera access for CalGo!'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'CalGo needs camera permission to scan meals.'**
  String get cameraPermissionRequired;

  /// No description provided for @noCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera found'**
  String get noCamera;

  /// No description provided for @cameraStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the camera. Close this screen and try again!'**
  String get cameraStartFailed;

  /// No description provided for @scanInProgress.
  ///
  /// In en, this message translates to:
  /// **'Another meal is being analyzed. Please wait a moment!'**
  String get scanInProgress;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in. Sign in with Google to use this feature!'**
  String get notLoggedIn;

  /// No description provided for @cameraPermissionMissing.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is not enabled. Allow camera access for CalGo in phone Settings!'**
  String get cameraPermissionMissing;

  /// No description provided for @networkTimeout.
  ///
  /// In en, this message translates to:
  /// **'The network is slow or timed out. Check your connection and try again!'**
  String get networkTimeout;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Could not analyze the photo ({error}). Please try again!'**
  String scanFailed(String error);

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scanAgain;

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionTitle;

  /// No description provided for @guidanceRecoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A gentle adjustment'**
  String get guidanceRecoverySubtitle;

  /// No description provided for @guidanceLoggedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your latest meal'**
  String get guidanceLoggedSubtitle;

  /// No description provided for @guidanceRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'New suggestions'**
  String get guidanceRefreshTooltip;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal remaining'**
  String guidanceCaloriesRemaining(int calories);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{grams}g protein needed'**
  String guidanceProteinRemaining(int grams);

  /// No description provided for @guidanceAlternativesTitle.
  ///
  /// In en, this message translates to:
  /// **'Or choose one of these meals'**
  String get guidanceAlternativesTitle;

  /// No description provided for @guidanceOtherMeal.
  ///
  /// In en, this message translates to:
  /// **'I plan to eat something else'**
  String get guidanceOtherMeal;

  /// No description provided for @guidanceSeeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get guidanceSeeMore;

  /// No description provided for @guidanceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Suggestions are for reference only. Scan the actual meal to log it accurately.'**
  String get guidanceDisclaimer;

  /// No description provided for @guidanceFamiliarTag.
  ///
  /// In en, this message translates to:
  /// **'FAMILIAR'**
  String get guidanceFamiliarTag;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String guidanceDishCalories(int calories);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'P {grams}g'**
  String guidanceDishProtein(int grams);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'C {grams}g'**
  String guidanceDishCarbs(int grams);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String guidancePrepTime(int minutes);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'~{price}k'**
  String guidancePrice(String price);

  /// No description provided for @guidanceFitGreat.
  ///
  /// In en, this message translates to:
  /// **'Great fit'**
  String get guidanceFitGreat;

  /// No description provided for @guidanceFitAdjust.
  ///
  /// In en, this message translates to:
  /// **'Needs adjustment'**
  String get guidanceFitAdjust;

  /// No description provided for @guidanceFitGood.
  ///
  /// In en, this message translates to:
  /// **'Good fit'**
  String get guidanceFitGood;

  /// No description provided for @guidanceAppleTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Tao calculate with you'**
  String get guidanceAppleTitle;

  /// No description provided for @guidanceFirstScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan your first meal'**
  String get guidanceFirstScanAction;

  /// No description provided for @guidanceAppleSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tao\'s suggestions'**
  String get guidanceAppleSuggestionTitle;

  /// No description provided for @guidanceNextMealAction.
  ///
  /// In en, this message translates to:
  /// **'Scan your next meal'**
  String get guidanceNextMealAction;

  /// No description provided for @guidanceGoalReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal is complete!'**
  String get guidanceGoalReachedTitle;

  /// No description provided for @guidanceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'What should you eat?'**
  String get guidanceScreenTitle;

  /// No description provided for @guidanceUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No suggestions yet'**
  String get guidanceUnavailableTitle;

  /// No description provided for @guidanceUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Try again after scanning a meal.'**
  String get guidanceUnavailableMessage;

  /// No description provided for @guidanceScanMeal.
  ///
  /// In en, this message translates to:
  /// **'Scan a meal'**
  String get guidanceScanMeal;

  /// No description provided for @guidanceConsiderMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals to consider'**
  String get guidanceConsiderMeals;

  /// No description provided for @guidanceScanForAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Scan to log accurately'**
  String get guidanceScanForAccuracy;

  /// No description provided for @guidanceSwapWith.
  ///
  /// In en, this message translates to:
  /// **'Or switch it up with'**
  String get guidanceSwapWith;

  /// No description provided for @guidanceChangeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Change suggestion'**
  String get guidanceChangeSuggestion;

  /// No description provided for @guidancePremiumSwapTitle.
  ///
  /// In en, this message translates to:
  /// **'Changing suggestions is a Premium feature'**
  String get guidancePremiumSwapTitle;

  /// No description provided for @guidancePremiumSwapMessage.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to change meal suggestions without limits based on your goals.'**
  String get guidancePremiumSwapMessage;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @upgradePremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradePremium;

  /// No description provided for @guidanceTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal suggestions for today'**
  String get guidanceTodayTitle;

  /// No description provided for @guidanceTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a meal that fits your macros, then scan the real meal before logging it.'**
  String get guidanceTodaySubtitle;

  /// No description provided for @guidanceScanRealMeal.
  ///
  /// In en, this message translates to:
  /// **'Scan the real meal'**
  String get guidanceScanRealMeal;

  /// No description provided for @guidanceNextMealGoal.
  ///
  /// In en, this message translates to:
  /// **'GOAL FOR YOUR NEXT MEAL'**
  String get guidanceNextMealGoal;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingLabel;

  /// No description provided for @proteinNeededLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein needed'**
  String get proteinNeededLabel;

  /// No description provided for @familiarMacroLabel.
  ///
  /// In en, this message translates to:
  /// **'FAMILIAR · MACRO FIT'**
  String get familiarMacroLabel;

  /// No description provided for @numberOneChoice.
  ///
  /// In en, this message translates to:
  /// **'CHOICE NUMBER 1'**
  String get numberOneChoice;

  /// No description provided for @energyLabel.
  ///
  /// In en, this message translates to:
  /// **'ENERGY'**
  String get energyLabel;

  /// No description provided for @familiarLabel.
  ///
  /// In en, this message translates to:
  /// **'FAMILIAR'**
  String get familiarLabel;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Tip: {adjustment}'**
  String dishTip(String adjustment);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal · {protein}g protein'**
  String dishMacroSummary(int calories, String protein);

  /// No description provided for @fitGoalGreat.
  ///
  /// In en, this message translates to:
  /// **'Great for your goal'**
  String get fitGoalGreat;

  /// No description provided for @fitGoalAdjust.
  ///
  /// In en, this message translates to:
  /// **'Should be adjusted'**
  String get fitGoalAdjust;

  /// No description provided for @fitGoalGood.
  ///
  /// In en, this message translates to:
  /// **'Fits your goal'**
  String get fitGoalGood;

  /// No description provided for @goalSpecificGainTitle.
  ///
  /// In en, this message translates to:
  /// **'How often do you train each week?'**
  String get goalSpecificGainTitle;

  /// No description provided for @goalSpecificGainNone.
  ///
  /// In en, this message translates to:
  /// **'I do not train yet'**
  String get goalSpecificGainNone;

  /// No description provided for @goalSpecificGain12.
  ///
  /// In en, this message translates to:
  /// **'1–2 sessions'**
  String get goalSpecificGain12;

  /// No description provided for @goalSpecificGain34.
  ///
  /// In en, this message translates to:
  /// **'3–4 sessions'**
  String get goalSpecificGain34;

  /// No description provided for @goalSpecificGain5.
  ///
  /// In en, this message translates to:
  /// **'5+ sessions'**
  String get goalSpecificGain5;

  /// No description provided for @goalSpecificMaintainTitle.
  ///
  /// In en, this message translates to:
  /// **'What matters most for maintaining your shape?'**
  String get goalSpecificMaintainTitle;

  /// No description provided for @goalSpecificStable.
  ///
  /// In en, this message translates to:
  /// **'Keep my weight stable'**
  String get goalSpecificStable;

  /// No description provided for @goalSpecificBalanced.
  ///
  /// In en, this message translates to:
  /// **'Eat more balanced meals'**
  String get goalSpecificBalanced;

  /// No description provided for @goalSpecificHabits.
  ///
  /// In en, this message translates to:
  /// **'Build long-term habits'**
  String get goalSpecificHabits;

  /// No description provided for @goalSpecificWeekends.
  ///
  /// In en, this message translates to:
  /// **'Stay on track on weekends'**
  String get goalSpecificWeekends;

  /// No description provided for @goalSpecificLoseTitle.
  ///
  /// In en, this message translates to:
  /// **'What makes fat loss hardest for you?'**
  String get goalSpecificLoseTitle;

  /// No description provided for @goalSpecificHunger.
  ///
  /// In en, this message translates to:
  /// **'I get hungry often'**
  String get goalSpecificHunger;

  /// No description provided for @goalSpecificPortions.
  ///
  /// In en, this message translates to:
  /// **'Portion control'**
  String get goalSpecificPortions;

  /// No description provided for @goalSpecificChoices.
  ///
  /// In en, this message translates to:
  /// **'I do not know what to eat'**
  String get goalSpecificChoices;

  /// No description provided for @goalSpecificLogging.
  ///
  /// In en, this message translates to:
  /// **'Logging feels difficult'**
  String get goalSpecificLogging;

  /// No description provided for @goalSpecificOvereat.
  ///
  /// In en, this message translates to:
  /// **'I overeat at night'**
  String get goalSpecificOvereat;

  /// No description provided for @goalSpecificWeekendsHard.
  ///
  /// In en, this message translates to:
  /// **'Weekends are difficult'**
  String get goalSpecificWeekendsHard;

  /// No description provided for @avoidFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you have allergies to any foods or ingredients?'**
  String get avoidFoodsTitle;

  /// No description provided for @foodSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get foodSeafood;

  /// No description provided for @foodRedMeat.
  ///
  /// In en, this message translates to:
  /// **'Red meat'**
  String get foodRedMeat;

  /// No description provided for @foodEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get foodEggs;

  /// No description provided for @foodDairy.
  ///
  /// In en, this message translates to:
  /// **'Milk & cheese'**
  String get foodDairy;

  /// No description provided for @foodFried.
  ///
  /// In en, this message translates to:
  /// **'Fried food'**
  String get foodFried;

  /// No description provided for @foodSpicy.
  ///
  /// In en, this message translates to:
  /// **'Spicy food'**
  String get foodSpicy;

  /// No description provided for @challengeTitle.
  ///
  /// In en, this message translates to:
  /// **'What is the hardest part for you?'**
  String get challengeTitle;

  /// No description provided for @challengeCalories.
  ///
  /// In en, this message translates to:
  /// **'I do not know the calories in my food'**
  String get challengeCalories;

  /// No description provided for @challengeSweets.
  ///
  /// In en, this message translates to:
  /// **'Resisting sweets'**
  String get challengeSweets;

  /// No description provided for @challengePortions.
  ///
  /// In en, this message translates to:
  /// **'Portion control'**
  String get challengePortions;

  /// No description provided for @challengeBetweenMeals.
  ///
  /// In en, this message translates to:
  /// **'Getting hungry between meals'**
  String get challengeBetweenMeals;

  /// No description provided for @challengeCookingTime.
  ///
  /// In en, this message translates to:
  /// **'Not having time to cook'**
  String get challengeCookingTime;

  /// No description provided for @challengeMotivation.
  ///
  /// In en, this message translates to:
  /// **'Staying motivated'**
  String get challengeMotivation;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your budget for one meal?'**
  String get budgetTitle;

  /// No description provided for @budgetNote.
  ///
  /// In en, this message translates to:
  /// **'CalGo asks so it can suggest meals that fit your goals and budget.'**
  String get budgetNote;

  /// No description provided for @budgetLow.
  ///
  /// In en, this message translates to:
  /// **'Under 30,000₫'**
  String get budgetLow;

  /// No description provided for @budgetLowNote.
  ///
  /// In en, this message translates to:
  /// **'Simple, easy-to-find meals'**
  String get budgetLowNote;

  /// No description provided for @budgetMid.
  ///
  /// In en, this message translates to:
  /// **'30,000–60,000₫'**
  String get budgetMid;

  /// No description provided for @budgetMidNote.
  ///
  /// In en, this message translates to:
  /// **'Typical budget for one meal'**
  String get budgetMidNote;

  /// No description provided for @budgetHigh.
  ///
  /// In en, this message translates to:
  /// **'60,000–100,000₫'**
  String get budgetHigh;

  /// No description provided for @budgetHighNote.
  ///
  /// In en, this message translates to:
  /// **'More room for quality'**
  String get budgetHighNote;

  /// No description provided for @budgetAny.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get budgetAny;

  /// No description provided for @budgetAnyNote.
  ///
  /// In en, this message translates to:
  /// **'Prioritize nutrition goals'**
  String get budgetAnyNote;

  /// No description provided for @prepTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time do you have to prepare one meal?'**
  String get prepTitle;

  /// No description provided for @prepNote.
  ///
  /// In en, this message translates to:
  /// **'CalGo asks so it can suggest meals that fit your schedule.'**
  String get prepNote;

  /// No description provided for @prepShort.
  ///
  /// In en, this message translates to:
  /// **'Under 10 minutes'**
  String get prepShort;

  /// No description provided for @prepShortNote.
  ///
  /// In en, this message translates to:
  /// **'Quick and convenient when busy'**
  String get prepShortNote;

  /// No description provided for @prepMedium.
  ///
  /// In en, this message translates to:
  /// **'10–20 minutes'**
  String get prepMedium;

  /// No description provided for @prepMediumNote.
  ///
  /// In en, this message translates to:
  /// **'Enough for a simple meal'**
  String get prepMediumNote;

  /// No description provided for @prepLong.
  ///
  /// In en, this message translates to:
  /// **'Over 20 minutes'**
  String get prepLong;

  /// No description provided for @prepLongNote.
  ///
  /// In en, this message translates to:
  /// **'More time to prepare carefully'**
  String get prepLongNote;

  /// No description provided for @prepAny.
  ///
  /// In en, this message translates to:
  /// **'No preference'**
  String get prepAny;

  /// No description provided for @prepAnyNote.
  ///
  /// In en, this message translates to:
  /// **'As long as it fits my goals'**
  String get prepAnyNote;

  /// No description provided for @nutritionPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you prioritize in a meal?'**
  String get nutritionPriorityTitle;

  /// No description provided for @nutritionPriorityNote.
  ///
  /// In en, this message translates to:
  /// **'CalGo asks so it does not give you generic suggestions.'**
  String get nutritionPriorityNote;

  /// No description provided for @priorityProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get priorityProtein;

  /// No description provided for @priorityProteinNote.
  ///
  /// In en, this message translates to:
  /// **'Supports fullness and muscle recovery'**
  String get priorityProteinNote;

  /// No description provided for @priorityLight.
  ///
  /// In en, this message translates to:
  /// **'Light calories'**
  String get priorityLight;

  /// No description provided for @priorityLightNote.
  ///
  /// In en, this message translates to:
  /// **'Easy to balance throughout the day'**
  String get priorityLightNote;

  /// No description provided for @priorityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get priorityBalanced;

  /// No description provided for @priorityBalancedNote.
  ///
  /// In en, this message translates to:
  /// **'A sensible mix of calories and macros'**
  String get priorityBalancedNote;

  /// No description provided for @priorityFilling.
  ///
  /// In en, this message translates to:
  /// **'Keep me full'**
  String get priorityFilling;

  /// No description provided for @priorityFillingNote.
  ///
  /// In en, this message translates to:
  /// **'Prioritize protein and enough carbs'**
  String get priorityFillingNote;

  /// No description provided for @habitTitle.
  ///
  /// In en, this message translates to:
  /// **'What are your eating habits?'**
  String get habitTitle;

  /// No description provided for @habitNote.
  ///
  /// In en, this message translates to:
  /// **'CalGo asks so it can suggest meals that fit your lifestyle.'**
  String get habitNote;

  /// No description provided for @habitRegular.
  ///
  /// In en, this message translates to:
  /// **'I eat regular, balanced meals'**
  String get habitRegular;

  /// No description provided for @habitSnacking.
  ///
  /// In en, this message translates to:
  /// **'I snack often'**
  String get habitSnacking;

  /// No description provided for @habitSkipBreakfast.
  ///
  /// In en, this message translates to:
  /// **'I often skip breakfast'**
  String get habitSkipBreakfast;

  /// No description provided for @habitLateNight.
  ///
  /// In en, this message translates to:
  /// **'I eat late at night'**
  String get habitLateNight;

  /// No description provided for @habitEatingOut.
  ///
  /// In en, this message translates to:
  /// **'I eat out often'**
  String get habitEatingOut;

  /// No description provided for @habitCook.
  ///
  /// In en, this message translates to:
  /// **'I cook at home'**
  String get habitCook;

  /// No description provided for @motivationTitle.
  ///
  /// In en, this message translates to:
  /// **'What makes you want to change?'**
  String get motivationTitle;

  /// No description provided for @motivationHealth.
  ///
  /// In en, this message translates to:
  /// **'Better health'**
  String get motivationHealth;

  /// No description provided for @motivationMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get motivationMuscle;

  /// No description provided for @motivationClothes.
  ///
  /// In en, this message translates to:
  /// **'Look better in clothes'**
  String get motivationClothes;

  /// No description provided for @motivationWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get motivationWeight;

  /// No description provided for @motivationEnergy.
  ///
  /// In en, this message translates to:
  /// **'Feel healthy and energized'**
  String get motivationEnergy;

  /// No description provided for @motivationOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get motivationOther;

  /// No description provided for @painTitle.
  ///
  /// In en, this message translates to:
  /// **'Have you ever...'**
  String get painTitle;

  /// No description provided for @painNote.
  ///
  /// In en, this message translates to:
  /// **'Choose the things you have experienced'**
  String get painNote;

  /// No description provided for @painEatLess.
  ///
  /// In en, this message translates to:
  /// **'Eat very little but still not lose weight'**
  String get painEatLess;

  /// No description provided for @painCardio.
  ///
  /// In en, this message translates to:
  /// **'Do lots of cardio'**
  String get painCardio;

  /// No description provided for @painGiveUp.
  ///
  /// In en, this message translates to:
  /// **'Give up after a few days'**
  String get painGiveUp;

  /// No description provided for @painUnknownCalories.
  ///
  /// In en, this message translates to:
  /// **'Not know how many calories I eat'**
  String get painUnknownCalories;

  /// No description provided for @painHungry.
  ///
  /// In en, this message translates to:
  /// **'Get hungry halfway through'**
  String get painHungry;

  /// No description provided for @painStressEating.
  ///
  /// In en, this message translates to:
  /// **'Stress eating'**
  String get painStressEating;

  /// No description provided for @emotionalTitle.
  ///
  /// In en, this message translates to:
  /// **'If you continue eating as you do now...'**
  String get emotionalTitle;

  /// No description provided for @emotionalCurrent.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get emotionalCurrent;

  /// No description provided for @emotionalAfterSixMonths.
  ///
  /// In en, this message translates to:
  /// **'After 6 months'**
  String get emotionalAfterSixMonths;

  /// No description provided for @emotionalStillWeight.
  ///
  /// In en, this message translates to:
  /// **'You may stay around your current weight. With CalGo, you can change.'**
  String get emotionalStillWeight;

  /// No description provided for @emotionalHelpChange.
  ///
  /// In en, this message translates to:
  /// **'I will help you change'**
  String get emotionalHelpChange;

  /// No description provided for @referralX.
  ///
  /// In en, this message translates to:
  /// **'X (Twitter)'**
  String get referralX;

  /// No description provided for @referralOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get referralOther;

  /// No description provided for @sportsRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get sportsRunning;

  /// No description provided for @sportsCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get sportsCycling;

  /// No description provided for @sportsSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get sportsSwimming;

  /// No description provided for @sportsFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get sportsFootball;

  /// No description provided for @sportsBadminton.
  ///
  /// In en, this message translates to:
  /// **'Badminton'**
  String get sportsBadminton;

  /// No description provided for @sportsBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get sportsBasketball;

  /// No description provided for @sportsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sportsOther;

  /// No description provided for @durationTitle.
  ///
  /// In en, this message translates to:
  /// **'When do you want to reach your goal?'**
  String get durationTitle;

  /// No description provided for @durationNote.
  ///
  /// In en, this message translates to:
  /// **'Choose a timeframe that feels right for you'**
  String get durationNote;

  /// No description provided for @dailyCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Goal'**
  String get dailyCalorieGoal;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Your current goal is {calories} kcal/day. You can change it in onboarding settings or contact support.'**
  String dailyCalorieGoalMessage(int calories);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications'**
  String get reminderNotifications;

  /// No description provided for @reminderNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Meal reminders and daily calorie tracking notifications have been enabled automatically.'**
  String get reminderNotificationsEnabled;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @userGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use CalGo'**
  String get userGuideTitle;

  /// No description provided for @userGuideContent.
  ///
  /// In en, this message translates to:
  /// **'1. Tap Scan (+) to capture or select a meal photo.\n2. AI automatically analyzes calories and nutrition.\n3. Edit amounts or add ingredients before saving.\n4. Review your meal history in the History tab.'**
  String get userGuideContent;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get great;

  /// No description provided for @customerSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'For help or product feedback, email us at: support@calgo.tech'**
  String get customerSupportMessage;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account. See the online guide or contact support.'**
  String get deleteAccountFailed;

  /// No description provided for @galleryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the photo collection'**
  String get galleryLoadFailed;

  /// No description provided for @viewResult.
  ///
  /// In en, this message translates to:
  /// **'View result details'**
  String get viewResult;

  /// No description provided for @shareMemoryCard.
  ///
  /// In en, this message translates to:
  /// **'Share Memory Card'**
  String get shareMemoryCard;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo'**
  String get deletePhoto;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the meal photo \"{meal}\"?'**
  String deletePhotoMessage(String meal);

  /// No description provided for @mealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal removed from your collection'**
  String get mealDeleted;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete it. Please try again.'**
  String get deleteFailed;

  /// No description provided for @paymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment through Google Play...'**
  String get paymentProcessing;

  /// No description provided for @paymentOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Play payment. Please try again.'**
  String get paymentOpenFailed;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Includes {count} AI nutrition scans'**
  String packIncludes(int count);

  /// No description provided for @permanentCredits.
  ///
  /// In en, this message translates to:
  /// **'Scans never expire'**
  String get permanentCredits;

  /// No description provided for @testingFreeCredits.
  ///
  /// In en, this message translates to:
  /// **'Testing build: Premium scans are free. No Google Play payment is made.'**
  String get testingFreeCredits;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration checked successfully!'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore Google Play purchases.'**
  String get restoreFailed;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailedWithDetails(String error);

  /// No description provided for @moreScanCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy more AI meal scans'**
  String get moreScanCredits;

  /// No description provided for @shareCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the card image. Please try again!'**
  String get shareCreateFailed;

  /// No description provided for @shareExported.
  ///
  /// In en, this message translates to:
  /// **'Memory Card exported successfully!'**
  String get shareExported;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get shareResult;

  /// No description provided for @shareNutritionLabel.
  ///
  /// In en, this message translates to:
  /// **'The image will be saved with nutrition labels'**
  String get shareNutritionLabel;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get saveImage;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Could not load the analysis result (ID: {id}). Please try again!'**
  String resultLoadFailed(String id);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get healthScore;

  /// No description provided for @dishesInPhoto.
  ///
  /// In en, this message translates to:
  /// **'Dishes in photo'**
  String get dishesInPhoto;

  /// No description provided for @ingredientsInDish.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsInDish;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get feedbackThanks;

  /// No description provided for @feedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Was the AI scan inaccurate? Tell us what happened:'**
  String get feedbackPrompt;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Example: wrong dish name, missing vegetables...'**
  String get feedbackHint;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @newIngredient.
  ///
  /// In en, this message translates to:
  /// **'New ingredient'**
  String get newIngredient;

  /// No description provided for @choosePortion.
  ///
  /// In en, this message translates to:
  /// **'Choose portion'**
  String get choosePortion;

  /// No description provided for @searchNutritionLibrary.
  ///
  /// In en, this message translates to:
  /// **'Search nutrition library'**
  String get searchNutritionLibrary;

  /// No description provided for @adjustBeforeAdding.
  ///
  /// In en, this message translates to:
  /// **'Adjust the amount before adding'**
  String get adjustBeforeAdding;

  /// No description provided for @ingredientSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search beef, eggs, rice...'**
  String get ingredientSearchHint;

  /// No description provided for @ingredientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Ingredient not found'**
  String get ingredientNotFound;

  /// No description provided for @ingredientSearchTip.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter or more common name'**
  String get ingredientSearchTip;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get unitPiece;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get defaultUserName;

  /// No description provided for @analyzingMessage1.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your profile information...'**
  String get analyzingMessage1;

  /// No description provided for @analyzingMessage2.
  ///
  /// In en, this message translates to:
  /// **'Calculating daily calorie targets...'**
  String get analyzingMessage2;

  /// No description provided for @analyzingMessage3.
  ///
  /// In en, this message translates to:
  /// **'Designing personalized goals...'**
  String get analyzingMessage3;

  /// No description provided for @analyzingMessage4.
  ///
  /// In en, this message translates to:
  /// **'Building nutrition strategy...'**
  String get analyzingMessage4;

  /// No description provided for @analyzingMessage5.
  ///
  /// In en, this message translates to:
  /// **'Almost ready...'**
  String get analyzingMessage5;

  /// No description provided for @dietNormal.
  ///
  /// In en, this message translates to:
  /// **'Regular eating'**
  String get dietNormal;

  /// No description provided for @dietClean.
  ///
  /// In en, this message translates to:
  /// **'Eat Clean'**
  String get dietClean;

  /// No description provided for @dietKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get dietKeto;

  /// No description provided for @dietLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get dietLowCarb;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietVegan;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activitySedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Desk work, little movement'**
  String get activitySedentaryDesc;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Light walking'**
  String get activityLight;

  /// No description provided for @activityLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Light movement 1–2 times/week'**
  String get activityLightDesc;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Train 1–3 times'**
  String get activityModerate;

  /// No description provided for @activityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 1–3 days/week'**
  String get activityModerateDesc;

  /// No description provided for @activityActive.
  ///
  /// In en, this message translates to:
  /// **'Train 4–5 times'**
  String get activityActive;

  /// No description provided for @activityActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 4–5 days/week'**
  String get activityActiveDesc;

  /// No description provided for @activityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Train daily'**
  String get activityVeryActive;

  /// No description provided for @activityVeryActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Hard exercise every day'**
  String get activityVeryActiveDesc;

  /// No description provided for @paceSlow.
  ///
  /// In en, this message translates to:
  /// **'🐢  Slow — 0.25 kg/week'**
  String get paceSlow;

  /// No description provided for @paceLight.
  ///
  /// In en, this message translates to:
  /// **'🚶  Light — 0.5 kg/week (Popular)'**
  String get paceLight;

  /// No description provided for @paceMedium.
  ///
  /// In en, this message translates to:
  /// **'🏃  Medium — 0.75 kg/week'**
  String get paceMedium;

  /// No description provided for @paceHigh.
  ///
  /// In en, this message translates to:
  /// **'🔥  High — 1 kg/week'**
  String get paceHigh;

  /// No description provided for @paceHighest.
  ///
  /// In en, this message translates to:
  /// **'⚡  Highest — 1.25–1.5 kg/week'**
  String get paceHighest;

  /// No description provided for @weekUnit.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get weekUnit;

  /// No description provided for @sportsGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get sportsGym;

  /// No description provided for @sportsYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get sportsYoga;

  /// No description provided for @scanResultUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This meal could not be analyzed'**
  String get scanResultUnavailable;

  /// No description provided for @scanResultRetryHint.
  ///
  /// In en, this message translates to:
  /// **'Try scanning it again.'**
  String get scanResultRetryHint;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'F {grams}g'**
  String guidanceDishFat(int grams);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @defaultProfileName.
  ///
  /// In en, this message translates to:
  /// **'CalGo user'**
  String get defaultProfileName;

  /// No description provided for @premiumMembership.
  ///
  /// In en, this message translates to:
  /// **'Premium membership'**
  String get premiumMembership;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{count} credits'**
  String creditsCount(int count);

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment through Google Play / App Store'**
  String get paymentMethods;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'PROTEIN'**
  String get proteinLabel;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your nutrition goal. Please try again.'**
  String get onboardingSaveFailed;

  /// No description provided for @onboardingSaveNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your nutrition goal. Check your connection and try again.'**
  String get onboardingSaveNetworkFailed;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String googleSignInFailed(String error);

  /// No description provided for @appleSignInPending.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in is still being completed. Please use Google for now.'**
  String get appleSignInPending;

  /// No description provided for @firstScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan your first meal?'**
  String get firstScanTitle;

  /// No description provided for @firstScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Scan below to get started'**
  String get firstScanSubtitle;

  /// No description provided for @scanLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanLabel;

  /// No description provided for @startScanning.
  ///
  /// In en, this message translates to:
  /// **'Start scanning'**
  String get startScanning;

  /// No description provided for @socialProofOneTag.
  ///
  /// In en, this message translates to:
  /// **'Lost 6.5 kg'**
  String get socialProofOneTag;

  /// No description provided for @socialProofOneTime.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get socialProofOneTime;

  /// No description provided for @socialProofOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese food recognition is spot on!'**
  String get socialProofOneTitle;

  /// No description provided for @socialProofOneBody.
  ///
  /// In en, this message translates to:
  /// **'I used to struggle tracking pho and bun cha in foreign apps. CalGo recognizes Vietnamese dishes and calories accurately from a photo. 10/10!'**
  String get socialProofOneBody;

  /// No description provided for @socialProofTwoTag.
  ///
  /// In en, this message translates to:
  /// **'Gained 4 kg muscle'**
  String get socialProofTwoTag;

  /// No description provided for @socialProofTwoTime.
  ///
  /// In en, this message translates to:
  /// **'5 days ago'**
  String get socialProofTwoTime;

  /// No description provided for @socialProofTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Smooth UI and accurate TDEE'**
  String get socialProofTwoTitle;

  /// No description provided for @socialProofTwoBody.
  ///
  /// In en, this message translates to:
  /// **'The BMI tracking and macro suggestions are detailed. I train and track calories every day, and my body looks stronger after a month.'**
  String get socialProofTwoBody;

  /// No description provided for @socialProofThreeTag.
  ///
  /// In en, this message translates to:
  /// **'Maintained my shape'**
  String get socialProofThreeTag;

  /// No description provided for @socialProofThreeTime.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get socialProofThreeTime;

  /// No description provided for @socialProofThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Building healthy eating habits'**
  String get socialProofThreeTitle;

  /// No description provided for @socialProofThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Tao\'s reminders are adorable. The app never pushes extreme dieting; it guides me toward balanced nutrition.'**
  String get socialProofThreeBody;

  /// No description provided for @premiumActivatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Premium is active. Enjoy your meals!'**
  String get premiumActivatedMessage;

  /// No description provided for @premiumPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Premium payment.'**
  String get premiumPaymentFailed;

  /// No description provided for @continueFreePremium.
  ///
  /// In en, this message translates to:
  /// **'Continue · Free Premium'**
  String get continueFreePremium;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @premiumFreeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Premium unlocked for free'**
  String get premiumFreeUnlocked;

  /// No description provided for @premiumActivated.
  ///
  /// In en, this message translates to:
  /// **'Premium activated'**
  String get premiumActivated;

  /// No description provided for @processingShort.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processingShort;

  /// No description provided for @subscribePremium.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Premium'**
  String get subscribePremium;

  /// No description provided for @premiumTestingNote.
  ///
  /// In en, this message translates to:
  /// **'Testing build: Premium is free. No payment is made.'**
  String get premiumTestingNote;

  /// No description provided for @premiumNoChargeNote.
  ///
  /// In en, this message translates to:
  /// **'You will not be charged at this step.'**
  String get premiumNoChargeNote;

  /// No description provided for @premiumAutoRenewNote.
  ///
  /// In en, this message translates to:
  /// **'Auto-renews. Cancel anytime.'**
  String get premiumAutoRenewNote;

  /// No description provided for @premiumHeadlineBefore.
  ///
  /// In en, this message translates to:
  /// **'Change starts from '**
  String get premiumHeadlineBefore;

  /// No description provided for @todayLower.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get todayLower;

  /// No description provided for @yourExperience.
  ///
  /// In en, this message translates to:
  /// **'Your\nexperience'**
  String get yourExperience;

  /// No description provided for @premiumBenefitCalories.
  ///
  /// In en, this message translates to:
  /// **'Know your calories instantly — unlimited AI scans'**
  String get premiumBenefitCalories;

  /// No description provided for @premiumBenefitSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Unlimited meal suggestions tailored to your daily goal'**
  String get premiumBenefitSuggestions;

  /// No description provided for @premiumBenefitDescriptions.
  ///
  /// In en, this message translates to:
  /// **'AI meal descriptions without manual entry'**
  String get premiumBenefitDescriptions;

  /// No description provided for @premiumBenefitProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your body progress every day'**
  String get premiumBenefitProgress;

  /// No description provided for @premiumBenefitSupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support whenever you need it'**
  String get premiumBenefitSupport;

  /// No description provided for @planWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get planWeek;

  /// No description provided for @planYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get planYear;

  /// No description provided for @planMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get planMonth;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @weeklyPayment.
  ///
  /// In en, this message translates to:
  /// **'weekly payment'**
  String get weeklyPayment;

  /// No description provided for @popularMost.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get popularMost;

  /// No description provided for @testingAccess.
  ///
  /// In en, this message translates to:
  /// **'testing access'**
  String get testingAccess;

  /// No description provided for @restoreChecked.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration checked.'**
  String get restoreChecked;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreException(String error);

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @manageSubscriptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open subscription management.'**
  String get manageSubscriptionFailed;

  /// No description provided for @scanCreditsExhausted.
  ///
  /// In en, this message translates to:
  /// **'You have no scan credits left.'**
  String get scanCreditsExhausted;

  /// No description provided for @networkRetry.
  ///
  /// In en, this message translates to:
  /// **'The connection is slow. Try again.'**
  String get networkRetry;

  /// No description provided for @scanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This image could not be analyzed.'**
  String get scanUnavailable;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily meal reminders'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders to scan breakfast, lunch and dinner with CalGo'**
  String get notificationChannelDescription;

  /// No description provided for @notificationBreakfastTitle.
  ///
  /// In en, this message translates to:
  /// **'CalGo - Breakfast'**
  String get notificationBreakfastTitle;

  /// No description provided for @notificationBreakfastBody.
  ///
  /// In en, this message translates to:
  /// **'Good morning! Remember to scan breakfast so you have enough energy for the day.'**
  String get notificationBreakfastBody;

  /// No description provided for @notificationLunchTitle.
  ///
  /// In en, this message translates to:
  /// **'CalGo - Lunch'**
  String get notificationLunchTitle;

  /// No description provided for @notificationLunchBody.
  ///
  /// In en, this message translates to:
  /// **'It is lunch break. Scan your meal in CalGo to track calories accurately.'**
  String get notificationLunchBody;

  /// No description provided for @notificationDinnerTitle.
  ///
  /// In en, this message translates to:
  /// **'CalGo - Dinner'**
  String get notificationDinnerTitle;

  /// No description provided for @notificationDinnerBody.
  ///
  /// In en, this message translates to:
  /// **'Is dinner ready? Scan it to stay on track with your goals.'**
  String get notificationDinnerBody;

  /// No description provided for @notificationDirectChannel.
  ///
  /// In en, this message translates to:
  /// **'Direct notifications'**
  String get notificationDirectChannel;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'CARBS'**
  String get carbsLabel;

  /// No description provided for @fatLabel.
  ///
  /// In en, this message translates to:
  /// **'FAT'**
  String get fatLabel;

  /// No description provided for @guidanceTodayShortSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View suggestions for today\'s goal'**
  String get guidanceTodayShortSubtitle;

  /// No description provided for @ingredientBeef.
  ///
  /// In en, this message translates to:
  /// **'Fresh beef'**
  String get ingredientBeef;

  /// No description provided for @ingredientChicken.
  ///
  /// In en, this message translates to:
  /// **'Pan-seared chicken breast'**
  String get ingredientChicken;

  /// No description provided for @ingredientEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get ingredientEgg;

  /// No description provided for @ingredientRiceNoodles.
  ///
  /// In en, this message translates to:
  /// **'Fresh pho noodles'**
  String get ingredientRiceNoodles;

  /// No description provided for @ingredientRice.
  ///
  /// In en, this message translates to:
  /// **'White rice'**
  String get ingredientRice;

  /// No description provided for @ingredientBun.
  ///
  /// In en, this message translates to:
  /// **'Fresh rice vermicelli'**
  String get ingredientBun;

  /// No description provided for @ingredientSalad.
  ///
  /// In en, this message translates to:
  /// **'Lettuce & tomato'**
  String get ingredientSalad;

  /// No description provided for @ingredientCheddar.
  ///
  /// In en, this message translates to:
  /// **'Cheddar cheese'**
  String get ingredientCheddar;

  /// No description provided for @ingredientPassionSauce.
  ///
  /// In en, this message translates to:
  /// **'Passion fruit sauce'**
  String get ingredientPassionSauce;

  /// No description provided for @ingredientPork.
  ///
  /// In en, this message translates to:
  /// **'Lean pork'**
  String get ingredientPork;

  /// No description provided for @mockPhoTitle.
  ///
  /// In en, this message translates to:
  /// **'Rare beef pho with brisket'**
  String get mockPhoTitle;

  /// No description provided for @mockPhoNoodles.
  ///
  /// In en, this message translates to:
  /// **'Fresh pho noodles'**
  String get mockPhoNoodles;

  /// No description provided for @mockPhoRareBeef.
  ///
  /// In en, this message translates to:
  /// **'Rare beef'**
  String get mockPhoRareBeef;

  /// No description provided for @mockPhoBrisket.
  ///
  /// In en, this message translates to:
  /// **'Beef brisket'**
  String get mockPhoBrisket;

  /// No description provided for @mockPhoBroth.
  ///
  /// In en, this message translates to:
  /// **'Pho broth & scallions'**
  String get mockPhoBroth;

  /// No description provided for @mockRiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Broken rice with grilled pork, pork skin and egg cake'**
  String get mockRiceTitle;

  /// No description provided for @mockRice.
  ///
  /// In en, this message translates to:
  /// **'Broken rice'**
  String get mockRice;

  /// No description provided for @mockGrilledPork.
  ///
  /// In en, this message translates to:
  /// **'Grilled pork ribs'**
  String get mockGrilledPork;

  /// No description provided for @mockEggCake.
  ///
  /// In en, this message translates to:
  /// **'Steamed egg cake'**
  String get mockEggCake;

  /// No description provided for @mockFriedEgg.
  ///
  /// In en, this message translates to:
  /// **'Fried egg'**
  String get mockFriedEgg;

  /// No description provided for @mockSaladTitle.
  ///
  /// In en, this message translates to:
  /// **'Chicken salad with passion fruit dressing'**
  String get mockSaladTitle;

  /// No description provided for @mockChicken.
  ///
  /// In en, this message translates to:
  /// **'Pan-seared chicken breast'**
  String get mockChicken;

  /// No description provided for @mockSalad.
  ///
  /// In en, this message translates to:
  /// **'Lettuce & cherry tomatoes'**
  String get mockSalad;

  /// No description provided for @mockPassionSauce.
  ///
  /// In en, this message translates to:
  /// **'Passion fruit dressing'**
  String get mockPassionSauce;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'You are only {remaining} kg from your goal. Small daily habits work better than extreme diets.'**
  String motivationAdviceLose(String remaining);

  /// No description provided for @motivationAdviceGain.
  ///
  /// In en, this message translates to:
  /// **'Your calorie goal is optimized to build lean muscle while limiting excess fat.'**
  String get motivationAdviceGain;

  /// No description provided for @motivationAdviceMaintain.
  ///
  /// In en, this message translates to:
  /// **'Your current weight is in a healthy range. Let us build habits that help you feel your best every day.'**
  String get motivationAdviceMaintain;

  /// No description provided for @motivationAdviceDefault.
  ///
  /// In en, this message translates to:
  /// **'Let us reach your health goal together with sustainable habits.'**
  String get motivationAdviceDefault;

  /// No description provided for @taoAdviceLabel.
  ///
  /// In en, this message translates to:
  /// **'TAO\'S TIP'**
  String get taoAdviceLabel;

  /// No description provided for @taoReminder.
  ///
  /// In en, this message translates to:
  /// **'Tao will remind you every day'**
  String get taoReminder;

  /// No description provided for @packBasic.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get packBasic;

  /// No description provided for @packPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get packPopular;

  /// No description provided for @packPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get packPremium;

  /// Localized UI text
  ///
  /// In en, this message translates to:
  /// **'{count} credits • {unit}'**
  String creditPackageSummary(int count, String unit);

  /// No description provided for @perScan.
  ///
  /// In en, this message translates to:
  /// **'/scan'**
  String get perScan;

  /// No description provided for @caloriesValue.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String caloriesValue(int calories);

  /// No description provided for @caloriesPer100g.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal / 100g'**
  String caloriesPer100g(int calories);

  /// No description provided for @gramsValue.
  ///
  /// In en, this message translates to:
  /// **'{grams}g'**
  String gramsValue(int grams);

  /// No description provided for @weightKgValue.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String weightKgValue(String weight);

  /// No description provided for @galleryMacroSummary.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal • C:{carbs}g P:{protein}g F:{fat}g'**
  String galleryMacroSummary(int calories, String carbs, String protein, String fat);

  /// No description provided for @sharePayload.
  ///
  /// In en, this message translates to:
  /// **'🔥 {dish} · {calories} kcal | CalGo'**
  String sharePayload(String dish, int calories);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'bn', 'en', 'es', 'fr', 'hi', 'pt', 'ru', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
