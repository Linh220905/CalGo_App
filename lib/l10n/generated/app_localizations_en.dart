import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabAnalytics => 'Analytics';

  @override
  String get tabSettings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get caloriesLeft => 'Calories left';

  @override
  String get proteinLeft => 'Protein left';

  @override
  String get carbsLeft => 'Carbs left';

  @override
  String get fatsLeft => 'Fats left';

  @override
  String get recentlyUploaded => 'Recently uploaded';

  @override
  String get noMealsUploaded => 'No meals uploaded yet';

  @override
  String get tapToScanMeal => 'Tap to scan your first meal with AI';

  @override
  String get profileTitle => 'Personal Account';

  @override
  String get creditsLabel => 'Scan credits';

  @override
  String get scannedCountLabel => 'Meals scanned';

  @override
  String get buyCredits => 'Buy Credits';

  @override
  String get statistics => 'Statistics';

  @override
  String get calorieTarget => 'Calorie Goal';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get languageDisplayName => 'English';

  @override
  String get userGuide => 'User Guide';

  @override
  String get customerSupport => 'Customer Support';

  @override
  String get logout => 'Log Out';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get scanTitle => 'Scan Meal';

  @override
  String get scanInstructionHeader => 'Keep food within the frame';

  @override
  String get scanInstructionSub => 'Ensure proper lighting for accurate AI recognition';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get outOfCreditsTitle => 'Out of Scan Credits!';

  @override
  String get outOfCreditsMessage => 'You have used all your scan credits. Top up to continue tracking nutrition!';

  @override
  String get buyMore => 'Buy More';

  @override
  String get cancel => 'Cancel';

  @override
  String get pricingTitle => 'Upgrade & Credits';

  @override
  String get pricingSubtitle => 'Choose the best plan to unlock full AI capabilities';

  @override
  String get creditPacksTitle => 'Scan Credit Packages';

  @override
  String get noExpiryBadge => 'No Expiry';

  @override
  String get popularBadge => 'Popular';

  @override
  String get subscriptionsTitle => 'Pro Subscriptions';

  @override
  String get payButton => 'Pay Now';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get openOnline => 'Open online';

  @override
  String get onlineGuide => 'Online guide';

  @override
  String get deleteAccountSubscriptionWarning => 'Deleting your CalGo account does not cancel a Google Play subscription. If you have Premium, cancel it separately in Google Play to avoid a renewal charge.';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get privacyPolicyContent => 'CalGo Privacy Policy (updated 5 Aug 2026):\n\n1. Data we collect: account email, display name, Google sign-in identifier, onboarding nutrition information, meal photos, scan results, meal history, purchase metadata, app/device diagnostics and notification preferences.\n2. How permissions are used: camera and photo access are requested only when you choose to capture or select a meal photo; notifications are used only when enabled.\n3. How data is used: to provide AI nutrition analysis, sync your account, process Google Play purchases, prevent abuse, provide support and improve reliability. Photos may be processed by our hosting and AI service providers.\n4. Sharing and security: we do not sell your personal data or meal photos. Necessary providers such as hosting, AI processing, Google Sign-In and Google Play Billing may process limited data. We use HTTPS and access controls, but no system is completely secure.\n5. Retention and deletion: account data and meal history are deleted when you delete your account, except data that must be retained for fraud prevention, disputes or legal obligations. Backups may take a reasonable time to expire.\n6. Your rights: delete your account in Profile or visit https://calgo.tech/delete-account. For access, correction or questions, contact support@calgo.tech. Full policy: https://calgo.tech/privacy.';

  @override
  String get termsOfServiceContent => 'CalGo Terms of Service:\n\n1. Service and medical disclaimer: AI nutrition results are estimates for reference only and do not replace professional medical advice. CalGo is not a medical device.\n2. Payments: credit packs are one-time digital purchases. Premium weekly, monthly and annual plans are auto-renewing Google Play subscriptions unless cancelled before the next renewal. Manage or cancel at https://play.google.com/store/account/subscriptions.\n3. Refunds and deletion: Google Play handles Android billing and refunds. Deleting a CalGo account does not cancel a Google Play subscription.\n4. Content and intellectual property: you retain ownership of uploaded photos; CalGo receives a limited license to process them to provide and improve the service. CalGo owns its app, branding and software.\n5. Contact: support@calgo.tech. Full terms: https://calgo.tech/terms.';

  @override
  String get deleteAccountConfirmMessage => 'Are you sure you want to permanently delete your CalGo account and all calorie log data? This action cannot be undone.';

  @override
  String get historyTitle => 'Meal History';

  @override
  String get historySubtitle => 'Your nutrition journey';

  @override
  String get mealsCountLabel => 'Meals';

  @override
  String get streakDaysLabel => 'Streak';

  @override
  String get kcalPerDay => 'Kcal/day';

  @override
  String get proteinPerDay => 'Protein/day';

  @override
  String get noMealsHistory => 'No meals logged yet';

  @override
  String get scanFirstMealPrompt => 'Scan your first meal to start\nyour nutrition journey';

  @override
  String get scanFirstMealButton => 'Scan First Meal';

  @override
  String get deleteMealConfirm => 'Do you want to delete this meal?';

  @override
  String get cannotDeleteMeal => 'Could not delete meal. Please try again.';

  @override
  String get photoGalleryTitle => 'Food Photos';

  @override
  String get noPhotosYet => 'No food scan photos yet';

  @override
  String get takePhotosPrompt => 'Snap photos of your meals to build your collection!';

  @override
  String get scanFoodNow => 'Scan Food Now';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get getStarted => 'Get Started';

  @override
  String get snapPhotoAiTitle => 'Snap a photo. Let AI work.';

  @override
  String get snapPhotoAiDesc => 'AI automatically recognizes food and calculates calories in seconds.';

  @override
  String get trackEasilyTitle => 'Track with ease.';

  @override
  String get trackEasilyDesc => 'Track calories, protein, carbs, and fat every day.';

  @override
  String get reachGoalsTitle => 'Reach goals faster.';

  @override
  String get reachGoalsDesc => 'Get personalized targets and track fat loss progress.';

  @override
  String get nextStepButton => 'Next';

  @override
  String get goalStepTitle => 'What is your goal?';

  @override
  String get goalStepSubtitle => 'Helps CalGo build a plan that fits you';

  @override
  String get goalLoseWeight => 'Lose Weight';

  @override
  String get goalLoseWeightDesc => 'Burn fat efficiently, tone body';

  @override
  String get goalLoseWeightReason => 'This helps us build a fat-loss plan that protects muscle and stays sustainable.';

  @override
  String get goalGainMuscle => 'Gain Muscle';

  @override
  String get goalGainMuscleDesc => 'Build muscle and increase strength';

  @override
  String get goalGainMuscleReason => 'This helps us build a muscle-gain plan around your training and protein needs.';

  @override
  String get goalMaintain => 'Maintain Weight';

  @override
  String get goalMaintainDesc => 'Keep your balanced physique';

  @override
  String get goalMaintainReason => 'This helps us build a balanced plan that fits your life long term.';

  @override
  String get nameStepTitle => 'Your name is...';

  @override
  String get nameStepHint => 'Enter your name';

  @override
  String get demoStepTitle => 'See CalGo in Action';

  @override
  String get genderStepTitle => 'What is your gender?';

  @override
  String get genderStepSubtitle => 'For accurate calculations';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get ageStepTitle => 'How old are you?';

  @override
  String get heightStepTitle => 'What is your height?';

  @override
  String get weightStepTitle => 'What is your current weight?';

  @override
  String get targetWeightStepTitle => 'What is your target weight?';

  @override
  String get activityStepTitle => 'What is your activity level?';

  @override
  String get dietStepTitle => 'Do you follow any specific diet?';

  @override
  String get analysisTitle => 'Analyzing your data...';

  @override
  String get accountStepTitle => 'Create Account to Save Your Plan';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get heightStepDesc => 'Helps calculate BMI and accurate calorie needs';

  @override
  String get weightStepDesc => 'Helps determine your personalized nutrition goals';

  @override
  String get currentHeightHeader => 'Current Height';

  @override
  String get currentWeightHeader => 'Current Weight';

  @override
  String get bmiIndexTitle => 'BMI Index';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obese';

  @override
  String get targetWeightDesc => 'Helps set your personal nutritional targets';

  @override
  String get goalMaintainLabel => 'Maintain physique';

  @override
  String get goalLoseLabel => 'Weight loss';

  @override
  String get goalGainLabel => 'Muscle gain';

  @override
  String get goalMaintainHint => 'Target equals your current weight';

  @override
  String goalLoseDiffText(String kg) {
    return 'Target: Lose $kg kg';
  }

  @override
  String goalGainDiffText(String kg) {
    return 'Target: Gain $kg kg';
  }

  @override
  String get paceStepTitle => 'Pace per week?';

  @override
  String get paceStepSubtitle => 'Choose a comfortable rate for your lifestyle';

  @override
  String get activityStepSubtitle => 'Affects your daily calorie expenditure';

  @override
  String get dietStepSubtitle => 'CalGo recommends meals best suited for your body and goals.';

  @override
  String get socialProofTitle => 'What the community says about CalGo';

  @override
  String get socialProofSubtitle => 'Authentic reviews from real members';

  @override
  String get ratingTag => '5★ Rating';

  @override
  String get referralStepTitle => 'How did you hear about CalGo?';

  @override
  String get referralStepSubtitle => 'Helps us understand your journey';

  @override
  String get referralFriend => 'Friend recommendation';

  @override
  String get sportsStepTitle => 'What sports do you play?';

  @override
  String get sportsStepSubtitle => 'Select activities you do regularly';

  @override
  String get accountStepSubtitle => 'Secure information & sync personal progress';

  @override
  String get dataPrivacyNote => 'Your data is strictly encrypted & confidential';

  @override
  String analysisHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get analysisPlanReady => 'Your plan is ready';

  @override
  String get dailyCalorieTargetTitle => 'DAILY CALORIE TARGET';

  @override
  String get kcalPerDayUnit => 'kcal / day';

  @override
  String get workoutLabel => 'Workout';

  @override
  String workoutDaysText(String days) {
    return '$days days';
  }

  @override
  String get perWeekText => 'per week';

  @override
  String get yourJourneyTitle => 'YOUR JOURNEY';

  @override
  String get journeyCurrent => 'Current';

  @override
  String get journeyTarget => 'Target';

  @override
  String get journeyTimeframe => 'Timeframe';

  @override
  String weeksUnit(int weeks) {
    return '$weeks weeks';
  }

  @override
  String completedPercent(int p) {
    return '$p% completed';
  }

  @override
  String get loginTitle => 'Welcome to CalGo';

  @override
  String get loginSubtitle => 'Sign in to sync your nutrition data';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginApple => 'Continue with Apple';

  @override
  String loginFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get appleComingSoon => 'Apple sign-in is coming soon!';

  @override
  String get loginRequired => 'Please sign in with Google to protect and sync your data.';

  @override
  String get loginRequiredButton => 'Sign-in is required to sync data';

  @override
  String get progressLabel => 'Progress';

  @override
  String get dataLoadFailed => 'Unable to load data';

  @override
  String get deleteMealQuestion => 'Do you want to delete this meal?';

  @override
  String get deleteMealFailed => 'Could not delete the meal. Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get aiCoachAlmostGoal => 'Almost hit your goal! Keep going!';

  @override
  String get aiCoachPlentyCalories => 'Plenty of calories left today. Eat well!';

  @override
  String get aiCoachMomentum => 'Keep up the good momentum!';

  @override
  String get mascotGoalTipWater => 'Drink a sip of water to stay refreshed!';

  @override
  String get mascotGoalTipSlow => 'Eating slowly and listening to your body is awesome.';

  @override
  String get mascotGoalTipGreat => 'You did great today ✨';

  @override
  String get mascotGoalReached => 'Calorie goal reached for today! Keeping this pace is top tier ✨';

  @override
  String get mascotGuidanceIntro => 'I picked some nice meals for you today. Tap to check them out!';

  @override
  String get mascotGuidanceOpen => 'The recommended dishes are still in the suggestion screen!';

  @override
  String get mascotGuidanceTipWater => 'Did you drink enough water? Have a sip to refresh!';

  @override
  String get mascotGuidanceTipSlow => 'Eat slowly, you will feel full longer!';

  @override
  String mascotGuidanceOverTarget(int calories) {
    return 'You are $calories kcal over. I picked light meals for you!';
  }

  @override
  String mascotGuidanceRemaining(int calories) {
    return 'You need $calories kcal more to hit your goal. Check out my picks!';
  }

  @override
  String get mascotTipHydration => 'Hydrated yet, bro? Take a sip of water to stay sharp';

  @override
  String get mascotTipChew => 'Chew slowly, it helps digestion and keeps you full';

  @override
  String get mascotTipConsistency => 'Consistency every day builds a great physique';

  @override
  String get mascotNoMeals => 'Haven\'t logged anything yet? Snap a food photo to show me!';

  @override
  String mascotOverTarget(int calories) {
    return 'Over your target by about $calories kcal today. No worries, go light and high protein for your next meal!';
  }

  @override
  String mascotMissingCalories(int calories) {
    return 'Still missing $calories kcal today. Go grab something delicious!';
  }

  @override
  String get mascotOnTrack => 'Flawless discipline! Calories hit right on point!';

  @override
  String mealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
      zero: 'No meals',
    );
    return '$_temp0';
  }

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
      zero: 'No ingredients',
    );
    return '$_temp0';
  }

  @override
  String dishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
    );
    return '$_temp0';
  }

  @override
  String monthFallback(int month) {
    return 'Month $month';
  }

  @override
  String get scanProcessingRecognizing => 'Recognizing your meal...';

  @override
  String get scanProcessingRecognized => 'Meal recognized';

  @override
  String get scanProcessingIngredients => 'Analyzing ingredients...';

  @override
  String get scanProcessingNutrition => 'Identifying nutrition facts...';

  @override
  String get scanProcessingCalories => 'Calculating calories...';

  @override
  String get scanProcessingPortion => 'Estimating portion size...';

  @override
  String get scanProcessingSummary => 'AI is compiling your result...';

  @override
  String get scanProcessingReport => 'Preparing report...';

  @override
  String get cameraPermissionDenied => 'Camera permission was denied. Open Settings and allow camera access for CalGo!';

  @override
  String get cameraPermissionRequired => 'CalGo needs camera permission to scan meals.';

  @override
  String get noCamera => 'No camera found';

  @override
  String get cameraStartFailed => 'Could not start the camera. Close this screen and try again!';

  @override
  String get scanInProgress => 'Another meal is being analyzed. Please wait a moment!';

  @override
  String get notLoggedIn => 'You are not signed in. Sign in with Google to use this feature!';

  @override
  String get cameraPermissionMissing => 'Camera permission is not enabled. Allow camera access for CalGo in phone Settings!';

  @override
  String get networkTimeout => 'The network is slow or timed out. Check your connection and try again!';

  @override
  String scanFailed(String error) {
    return 'Could not analyze the photo ($error). Please try again!';
  }

  @override
  String get scanAgain => 'Scan again';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get guidanceRecoverySubtitle => 'A gentle adjustment';

  @override
  String get guidanceLoggedSubtitle => 'Based on your latest meal';

  @override
  String get guidanceRefreshTooltip => 'New suggestions';

  @override
  String guidanceCaloriesRemaining(int calories) {
    return '$calories kcal remaining';
  }

  @override
  String guidanceProteinRemaining(int grams) {
    return '${grams}g protein needed';
  }

  @override
  String get guidanceAlternativesTitle => 'Or choose one of these meals';

  @override
  String get guidanceOtherMeal => 'I plan to eat something else';

  @override
  String get guidanceSeeMore => 'See more';

  @override
  String get guidanceDisclaimer => 'Suggestions are for reference only. Scan the actual meal to log it accurately.';

  @override
  String get guidanceFamiliarTag => 'FAMILIAR';

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
    return '$minutes min';
  }

  @override
  String guidancePrice(String price) {
    return '~${price}k';
  }

  @override
  String get guidanceFitGreat => 'Great fit';

  @override
  String get guidanceFitAdjust => 'Needs adjustment';

  @override
  String get guidanceFitGood => 'Good fit';

  @override
  String get guidanceAppleTitle => 'Let Tao calculate with you';

  @override
  String get guidanceFirstScanAction => 'Scan your first meal';

  @override
  String get guidanceAppleSuggestionTitle => 'Tao\'s suggestions';

  @override
  String get guidanceNextMealAction => 'Scan your next meal';

  @override
  String get guidanceGoalReachedTitle => 'Today\'s goal is complete!';

  @override
  String get guidanceScreenTitle => 'What should you eat?';

  @override
  String get guidanceUnavailableTitle => 'No suggestions yet';

  @override
  String get guidanceUnavailableMessage => 'Try again after scanning a meal.';

  @override
  String get guidanceScanMeal => 'Scan a meal';

  @override
  String get guidanceConsiderMeals => 'Meals to consider';

  @override
  String get guidanceScanForAccuracy => 'Scan to log accurately';

  @override
  String get guidanceSwapWith => 'Or switch it up with';

  @override
  String get guidanceChangeSuggestion => 'Change suggestion';

  @override
  String get guidancePremiumSwapTitle => 'Changing suggestions is a Premium feature';

  @override
  String get guidancePremiumSwapMessage => 'Upgrade to Premium to change meal suggestions without limits based on your goals.';

  @override
  String get later => 'Later';

  @override
  String get upgradePremium => 'Upgrade to Premium';

  @override
  String get guidanceTodayTitle => 'Personal suggestions for today';

  @override
  String get guidanceTodaySubtitle => 'Choose a meal that fits your macros, then scan the real meal before logging it.';

  @override
  String get guidanceScanRealMeal => 'Scan the real meal';

  @override
  String get guidanceNextMealGoal => 'GOAL FOR YOUR NEXT MEAL';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get proteinNeededLabel => 'Protein needed';

  @override
  String get familiarMacroLabel => 'FAMILIAR · MACRO FIT';

  @override
  String get numberOneChoice => 'CHOICE NUMBER 1';

  @override
  String get energyLabel => 'ENERGY';

  @override
  String get familiarLabel => 'FAMILIAR';

  @override
  String dishTip(String adjustment) {
    return 'Tip: $adjustment';
  }

  @override
  String dishMacroSummary(int calories, String protein) {
    return '$calories kcal · ${protein}g protein';
  }

  @override
  String get fitGoalGreat => 'Great for your goal';

  @override
  String get fitGoalAdjust => 'Should be adjusted';

  @override
  String get fitGoalGood => 'Fits your goal';

  @override
  String get goalSpecificGainTitle => 'How often do you train each week?';

  @override
  String get goalSpecificGainNone => 'I do not train yet';

  @override
  String get goalSpecificGain12 => '1–2 sessions';

  @override
  String get goalSpecificGain34 => '3–4 sessions';

  @override
  String get goalSpecificGain5 => '5+ sessions';

  @override
  String get goalSpecificMaintainTitle => 'What matters most for maintaining your shape?';

  @override
  String get goalSpecificStable => 'Keep my weight stable';

  @override
  String get goalSpecificBalanced => 'Eat more balanced meals';

  @override
  String get goalSpecificHabits => 'Build long-term habits';

  @override
  String get goalSpecificWeekends => 'Stay on track on weekends';

  @override
  String get goalSpecificLoseTitle => 'What makes fat loss hardest for you?';

  @override
  String get goalSpecificHunger => 'I get hungry often';

  @override
  String get goalSpecificPortions => 'Portion control';

  @override
  String get goalSpecificChoices => 'I do not know what to eat';

  @override
  String get goalSpecificLogging => 'Logging feels difficult';

  @override
  String get goalSpecificOvereat => 'I overeat at night';

  @override
  String get goalSpecificWeekendsHard => 'Weekends are difficult';

  @override
  String get avoidFoodsTitle => 'Do you have allergies to any foods or ingredients?';

  @override
  String get foodSeafood => 'Seafood';

  @override
  String get foodRedMeat => 'Red meat';

  @override
  String get foodEggs => 'Eggs';

  @override
  String get foodDairy => 'Milk & cheese';

  @override
  String get foodFried => 'Fried food';

  @override
  String get foodSpicy => 'Spicy food';

  @override
  String get challengeTitle => 'What is the hardest part for you?';

  @override
  String get challengeCalories => 'I do not know the calories in my food';

  @override
  String get challengeSweets => 'Resisting sweets';

  @override
  String get challengePortions => 'Portion control';

  @override
  String get challengeBetweenMeals => 'Getting hungry between meals';

  @override
  String get challengeCookingTime => 'Not having time to cook';

  @override
  String get challengeMotivation => 'Staying motivated';

  @override
  String get budgetTitle => 'What is your budget for one meal?';

  @override
  String get budgetNote => 'CalGo asks so it can suggest meals that fit your goals and budget.';

  @override
  String get budgetLow => 'Under 30,000₫';

  @override
  String get budgetLowNote => 'Simple, easy-to-find meals';

  @override
  String get budgetMid => '30,000–60,000₫';

  @override
  String get budgetMidNote => 'Typical budget for one meal';

  @override
  String get budgetHigh => '60,000–100,000₫';

  @override
  String get budgetHighNote => 'More room for quality';

  @override
  String get budgetAny => 'No limit';

  @override
  String get budgetAnyNote => 'Prioritize nutrition goals';

  @override
  String get prepTitle => 'How much time do you have to prepare one meal?';

  @override
  String get prepNote => 'CalGo asks so it can suggest meals that fit your schedule.';

  @override
  String get prepShort => 'Under 10 minutes';

  @override
  String get prepShortNote => 'Quick and convenient when busy';

  @override
  String get prepMedium => '10–20 minutes';

  @override
  String get prepMediumNote => 'Enough for a simple meal';

  @override
  String get prepLong => 'Over 20 minutes';

  @override
  String get prepLongNote => 'More time to prepare carefully';

  @override
  String get prepAny => 'No preference';

  @override
  String get prepAnyNote => 'As long as it fits my goals';

  @override
  String get nutritionPriorityTitle => 'What do you prioritize in a meal?';

  @override
  String get nutritionPriorityNote => 'CalGo asks so it does not give you generic suggestions.';

  @override
  String get priorityProtein => 'High protein';

  @override
  String get priorityProteinNote => 'Supports fullness and muscle recovery';

  @override
  String get priorityLight => 'Light calories';

  @override
  String get priorityLightNote => 'Easy to balance throughout the day';

  @override
  String get priorityBalanced => 'Balanced';

  @override
  String get priorityBalancedNote => 'A sensible mix of calories and macros';

  @override
  String get priorityFilling => 'Keep me full';

  @override
  String get priorityFillingNote => 'Prioritize protein and enough carbs';

  @override
  String get habitTitle => 'What are your eating habits?';

  @override
  String get habitNote => 'CalGo asks so it can suggest meals that fit your lifestyle.';

  @override
  String get habitRegular => 'I eat regular, balanced meals';

  @override
  String get habitSnacking => 'I snack often';

  @override
  String get habitSkipBreakfast => 'I often skip breakfast';

  @override
  String get habitLateNight => 'I eat late at night';

  @override
  String get habitEatingOut => 'I eat out often';

  @override
  String get habitCook => 'I cook at home';

  @override
  String get motivationTitle => 'What makes you want to change?';

  @override
  String get motivationHealth => 'Better health';

  @override
  String get motivationMuscle => 'Build muscle';

  @override
  String get motivationClothes => 'Look better in clothes';

  @override
  String get motivationWeight => 'Lose weight';

  @override
  String get motivationEnergy => 'Feel healthy and energized';

  @override
  String get motivationOther => 'Other reason';

  @override
  String get painTitle => 'Have you ever...';

  @override
  String get painNote => 'Choose the things you have experienced';

  @override
  String get painEatLess => 'Eat very little but still not lose weight';

  @override
  String get painCardio => 'Do lots of cardio';

  @override
  String get painGiveUp => 'Give up after a few days';

  @override
  String get painUnknownCalories => 'Not know how many calories I eat';

  @override
  String get painHungry => 'Get hungry halfway through';

  @override
  String get painStressEating => 'Stress eating';

  @override
  String get emotionalTitle => 'If you continue eating as you do now...';

  @override
  String get emotionalCurrent => 'Now';

  @override
  String get emotionalAfterSixMonths => 'After 6 months';

  @override
  String get emotionalStillWeight => 'You may stay around your current weight. With CalGo, you can change.';

  @override
  String get emotionalHelpChange => 'I will help you change';

  @override
  String get referralX => 'X (Twitter)';

  @override
  String get referralOther => 'Other';

  @override
  String get sportsRunning => 'Running';

  @override
  String get sportsCycling => 'Cycling';

  @override
  String get sportsSwimming => 'Swimming';

  @override
  String get sportsFootball => 'Football';

  @override
  String get sportsBadminton => 'Badminton';

  @override
  String get sportsBasketball => 'Basketball';

  @override
  String get sportsOther => 'Other';

  @override
  String get durationTitle => 'When do you want to reach your goal?';

  @override
  String get durationNote => 'Choose a timeframe that feels right for you';

  @override
  String get dailyCalorieGoal => 'Daily Calorie Goal';

  @override
  String dailyCalorieGoalMessage(int calories) {
    return 'Your current goal is $calories kcal/day. You can change it in onboarding settings or contact support.';
  }

  @override
  String get close => 'Close';

  @override
  String get reminderNotifications => 'Reminder notifications';

  @override
  String get reminderNotificationsEnabled => 'Meal reminders and daily calorie tracking notifications have been enabled automatically.';

  @override
  String get gotIt => 'Got it';

  @override
  String get userGuideTitle => 'How to use CalGo';

  @override
  String get userGuideContent => '1. Tap Scan (+) to capture or select a meal photo.\n2. AI automatically analyzes calories and nutrition.\n3. Edit amounts or add ingredients before saving.\n4. Review your meal history in the History tab.';

  @override
  String get great => 'Great';

  @override
  String get customerSupportMessage => 'For help or product feedback, email us at: support@calgo.tech';

  @override
  String get deleteAccountFailed => 'Could not delete the account. See the online guide or contact support.';

  @override
  String get galleryLoadFailed => 'Could not load the photo collection';

  @override
  String get viewResult => 'View result details';

  @override
  String get shareMemoryCard => 'Share Memory Card';

  @override
  String get deletePhoto => 'Delete this photo';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String deletePhotoMessage(String meal) {
    return 'Are you sure you want to delete the meal photo \"$meal\"?';
  }

  @override
  String get mealDeleted => 'Meal removed from your collection';

  @override
  String get deleteFailed => 'Could not delete it. Please try again.';

  @override
  String get paymentProcessing => 'Processing payment through Google Play...';

  @override
  String get paymentOpenFailed => 'Could not open Google Play payment. Please try again.';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String packIncludes(int count) {
    return 'Includes $count AI nutrition scans';
  }

  @override
  String get permanentCredits => 'Scans never expire';

  @override
  String get testingFreeCredits => 'Testing build: Premium scans are free. No Google Play payment is made.';

  @override
  String get restoreSuccess => 'Purchase restoration checked successfully!';

  @override
  String get restoreFailed => 'Could not restore Google Play purchases.';

  @override
  String restoreFailedWithDetails(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get moreScanCredits => 'Buy more AI meal scans';

  @override
  String get shareCreateFailed => 'Could not create the card image. Please try again!';

  @override
  String get shareExported => 'Memory Card exported successfully!';

  @override
  String get shareResult => 'Share result';

  @override
  String get shareNutritionLabel => 'The image will be saved with nutrition labels';

  @override
  String get saveImage => 'Save image';

  @override
  String get share => 'Share';

  @override
  String resultLoadFailed(String id) {
    return 'Could not load the analysis result (ID: $id). Please try again!';
  }

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get healthScore => 'Health score';

  @override
  String get dishesInPhoto => 'Dishes in photo';

  @override
  String get ingredientsInDish => 'Ingredients';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get feedbackThanks => 'Thanks for your feedback!';

  @override
  String get feedbackPrompt => 'Was the AI scan inaccurate? Tell us what happened:';

  @override
  String get feedbackHint => 'Example: wrong dish name, missing vegetables...';

  @override
  String get skip => 'Skip';

  @override
  String get sending => 'Sending...';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get newIngredient => 'New ingredient';

  @override
  String get choosePortion => 'Choose portion';

  @override
  String get searchNutritionLibrary => 'Search nutrition library';

  @override
  String get adjustBeforeAdding => 'Adjust the amount before adding';

  @override
  String get ingredientSearchHint => 'Search beef, eggs, rice...';

  @override
  String get ingredientNotFound => 'Ingredient not found';

  @override
  String get ingredientSearchTip => 'Try a shorter or more common name';

  @override
  String get unitPiece => 'piece';

  @override
  String get defaultUserName => 'you';

  @override
  String get analyzingMessage1 => 'Analyzing your profile information...';

  @override
  String get analyzingMessage2 => 'Calculating daily calorie targets...';

  @override
  String get analyzingMessage3 => 'Designing personalized goals...';

  @override
  String get analyzingMessage4 => 'Building nutrition strategy...';

  @override
  String get analyzingMessage5 => 'Almost ready...';

  @override
  String get dietNormal => 'Regular eating';

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
  String get activitySedentary => 'Sedentary';

  @override
  String get activitySedentaryDesc => 'Desk work, little movement';

  @override
  String get activityLight => 'Light walking';

  @override
  String get activityLightDesc => 'Light movement 1–2 times/week';

  @override
  String get activityModerate => 'Train 1–3 times';

  @override
  String get activityModerateDesc => 'Exercise 1–3 days/week';

  @override
  String get activityActive => 'Train 4–5 times';

  @override
  String get activityActiveDesc => 'Exercise 4–5 days/week';

  @override
  String get activityVeryActive => 'Train daily';

  @override
  String get activityVeryActiveDesc => 'Hard exercise every day';

  @override
  String get paceSlow => '🐢  Slow — 0.25 kg/week';

  @override
  String get paceLight => '🚶  Light — 0.5 kg/week (Popular)';

  @override
  String get paceMedium => '🏃  Medium — 0.75 kg/week';

  @override
  String get paceHigh => '🔥  High — 1 kg/week';

  @override
  String get paceHighest => '⚡  Highest — 1.25–1.5 kg/week';

  @override
  String get weekUnit => 'week';

  @override
  String get sportsGym => 'Gym';

  @override
  String get sportsYoga => 'Yoga';

  @override
  String get scanResultUnavailable => 'This meal could not be analyzed';

  @override
  String get scanResultRetryHint => 'Try scanning it again.';

  @override
  String guidanceDishFat(int grams) {
    return 'F ${grams}g';
  }

  @override
  String get ok => 'OK';

  @override
  String get defaultProfileName => 'CalGo user';

  @override
  String get premiumMembership => 'Premium membership';

  @override
  String creditsCount(int count) {
    return '$count credits';
  }

  @override
  String get paymentMethods => 'Payment through Google Play / App Store';

  @override
  String get deleteAction => 'Delete';

  @override
  String get proteinLabel => 'PROTEIN';

  @override
  String get onboardingSaveFailed => 'Could not save your nutrition goal. Please try again.';

  @override
  String get onboardingSaveNetworkFailed => 'Could not save your nutrition goal. Check your connection and try again.';

  @override
  String googleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get appleSignInPending => 'Apple sign-in is still being completed. Please use Google for now.';

  @override
  String get firstScanTitle => 'Ready to scan your first meal?';

  @override
  String get firstScanSubtitle => 'Tap Scan below to get started';

  @override
  String get scanLabel => 'Scan';

  @override
  String get startScanning => 'Start scanning';

  @override
  String get socialProofOneTag => 'Lost 6.5 kg';

  @override
  String get socialProofOneTime => '2 days ago';

  @override
  String get socialProofOneTitle => 'Vietnamese food recognition is spot on!';

  @override
  String get socialProofOneBody => 'I used to struggle tracking pho and bun cha in foreign apps. CalGo recognizes Vietnamese dishes and calories accurately from a photo. 10/10!';

  @override
  String get socialProofTwoTag => 'Gained 4 kg muscle';

  @override
  String get socialProofTwoTime => '5 days ago';

  @override
  String get socialProofTwoTitle => 'Smooth UI and accurate TDEE';

  @override
  String get socialProofTwoBody => 'The BMI tracking and macro suggestions are detailed. I train and track calories every day, and my body looks stronger after a month.';

  @override
  String get socialProofThreeTag => 'Maintained my shape';

  @override
  String get socialProofThreeTime => '1 week ago';

  @override
  String get socialProofThreeTitle => 'Building healthy eating habits';

  @override
  String get socialProofThreeBody => 'Tao\'s reminders are adorable. The app never pushes extreme dieting; it guides me toward balanced nutrition.';

  @override
  String get premiumActivatedMessage => 'Premium is active. Enjoy your meals!';

  @override
  String get premiumPaymentFailed => 'Could not open Premium payment.';

  @override
  String get continueFreePremium => 'Continue · Free Premium';

  @override
  String get continueLabel => 'Continue';

  @override
  String get premiumFreeUnlocked => 'Premium unlocked for free';

  @override
  String get premiumActivated => 'Premium activated';

  @override
  String get processingShort => 'Processing…';

  @override
  String get subscribePremium => 'Subscribe to Premium';

  @override
  String get premiumTestingNote => 'Testing build: Premium is free. No payment is made.';

  @override
  String get premiumNoChargeNote => 'You will not be charged at this step.';

  @override
  String get premiumAutoRenewNote => 'Auto-renews. Cancel anytime.';

  @override
  String get premiumHeadlineBefore => 'Change starts from ';

  @override
  String get todayLower => 'today';

  @override
  String get yourExperience => 'Your\nexperience';

  @override
  String get premiumBenefitCalories => 'Know your calories instantly — unlimited AI scans';

  @override
  String get premiumBenefitSuggestions => 'Unlimited meal suggestions tailored to your daily goal';

  @override
  String get premiumBenefitDescriptions => 'AI meal descriptions without manual entry';

  @override
  String get premiumBenefitProgress => 'Track your body progress every day';

  @override
  String get premiumBenefitSupport => 'Priority support whenever you need it';

  @override
  String get planWeek => 'Week';

  @override
  String get planYear => 'Year';

  @override
  String get planMonth => 'Month';

  @override
  String get free => 'Free';

  @override
  String get weeklyPayment => 'weekly payment';

  @override
  String get popularMost => 'Most popular';

  @override
  String get testingAccess => 'testing access';

  @override
  String get restoreChecked => 'Purchase restoration checked.';

  @override
  String restoreException(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get manageSubscriptionFailed => 'Could not open subscription management.';

  @override
  String get scanCreditsExhausted => 'You have no scan credits left.';

  @override
  String get networkRetry => 'The connection is slow. Try again.';

  @override
  String get scanUnavailable => 'This image could not be analyzed.';

  @override
  String get notificationChannelName => 'Daily meal reminders';

  @override
  String get notificationChannelDescription => 'Reminders to scan breakfast, lunch and dinner with CalGo';

  @override
  String get notificationBreakfastTitle => 'CalGo - Breakfast';

  @override
  String get notificationBreakfastBody => 'Good morning! Remember to scan breakfast so you have enough energy for the day.';

  @override
  String get notificationLunchTitle => 'CalGo - Lunch';

  @override
  String get notificationLunchBody => 'It is lunch break. Scan your meal in CalGo to track calories accurately.';

  @override
  String get notificationDinnerTitle => 'CalGo - Dinner';

  @override
  String get notificationDinnerBody => 'Is dinner ready? Scan it to stay on track with your goals.';

  @override
  String get notificationDirectChannel => 'Direct notifications';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get carbsLabel => 'CARBS';

  @override
  String get fatLabel => 'FAT';

  @override
  String get guidanceTodayShortSubtitle => 'View suggestions for today\'s goal';

  @override
  String get ingredientBeef => 'Fresh beef';

  @override
  String get ingredientChicken => 'Pan-seared chicken breast';

  @override
  String get ingredientEgg => 'Egg';

  @override
  String get ingredientRiceNoodles => 'Fresh pho noodles';

  @override
  String get ingredientRice => 'White rice';

  @override
  String get ingredientBun => 'Fresh rice vermicelli';

  @override
  String get ingredientSalad => 'Lettuce & tomato';

  @override
  String get ingredientCheddar => 'Cheddar cheese';

  @override
  String get ingredientPassionSauce => 'Passion fruit sauce';

  @override
  String get ingredientPork => 'Lean pork';

  @override
  String get mockPhoTitle => 'Rare beef pho with brisket';

  @override
  String get mockPhoNoodles => 'Fresh pho noodles';

  @override
  String get mockPhoRareBeef => 'Rare beef';

  @override
  String get mockPhoBrisket => 'Beef brisket';

  @override
  String get mockPhoBroth => 'Pho broth & scallions';

  @override
  String get mockRiceTitle => 'Broken rice with grilled pork, pork skin and egg cake';

  @override
  String get mockRice => 'Broken rice';

  @override
  String get mockGrilledPork => 'Grilled pork ribs';

  @override
  String get mockEggCake => 'Steamed egg cake';

  @override
  String get mockFriedEgg => 'Fried egg';

  @override
  String get mockSaladTitle => 'Chicken salad with passion fruit dressing';

  @override
  String get mockChicken => 'Pan-seared chicken breast';

  @override
  String get mockSalad => 'Lettuce & cherry tomatoes';

  @override
  String get mockPassionSauce => 'Passion fruit dressing';

  @override
  String motivationAdviceLose(String remaining) {
    return 'You are only $remaining kg from your goal. Small daily habits work better than extreme diets.';
  }

  @override
  String get motivationAdviceGain => 'Your calorie goal is optimized to build lean muscle while limiting excess fat.';

  @override
  String get motivationAdviceMaintain => 'Your current weight is in a healthy range. Let us build habits that help you feel your best every day.';

  @override
  String get motivationAdviceDefault => 'Let us reach your health goal together with sustainable habits.';

  @override
  String get taoAdviceLabel => 'TAO\'S TIP';

  @override
  String get taoReminder => 'Tao will remind you every day';

  @override
  String get packBasic => 'Starter';

  @override
  String get packPopular => 'Popular';

  @override
  String get packPremium => 'Premium';

  @override
  String creditPackageSummary(int count, String unit) {
    return '$count credits • $unit';
  }

  @override
  String get perScan => '/scan';

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
