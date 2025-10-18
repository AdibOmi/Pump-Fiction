import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Pump Fiction'**
  String get appTitle;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Fitness page title
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// Social page title
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// Chat page title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Marketplace page title
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// Appearance section in settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode toggle in settings
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language section in settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title for language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// About section in settings
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version label in settings
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Dashboard placeholder text
  ///
  /// In en, this message translates to:
  /// **'Your fitness dashboard will be here'**
  String get yourFitnessDashboardWillBeHere;

  /// Fitness page placeholder text
  ///
  /// In en, this message translates to:
  /// **'Your fitness routines and exercises will be here'**
  String get yourFitnessRoutinesAndExercisesWillBeHere;

  /// Marketplace page placeholder text
  ///
  /// In en, this message translates to:
  /// **'Shop for fitness equipment and supplements'**
  String get shopForFitnessEquipmentAndSupplements;

  /// Drawer menu title
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Logout option
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Routine section in fitness
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// Workout section in fitness
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// Nutrition section in fitness
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// Progress section in fitness
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Workout progress title
  ///
  /// In en, this message translates to:
  /// **'Workout Progress'**
  String get workoutProgress;

  /// Workout progress description
  ///
  /// In en, this message translates to:
  /// **'Graphs based on your logged workouts'**
  String get graphsBasedOnYourLoggedWorkouts;

  /// Trackers title
  ///
  /// In en, this message translates to:
  /// **'Your Trackers'**
  String get yourTrackers;

  /// Trackers description
  ///
  /// In en, this message translates to:
  /// **'Create custom trackers and log values'**
  String get createCustomTrackersAndLogValues;

  /// Social feed
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// New post title
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPost;

  /// Create routine page title
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get createRoutine;

  /// Routine title input label
  ///
  /// In en, this message translates to:
  /// **'Routine Title'**
  String get routineTitle;

  /// Plan type label
  ///
  /// In en, this message translates to:
  /// **'Plan Type'**
  String get planType;

  /// Weekly plan type
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Number of days plan type
  ///
  /// In en, this message translates to:
  /// **'Number of Days'**
  String get numberOfDays;

  /// Days label
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// Rename day dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename Day'**
  String get renameDay;

  /// Day name input label
  ///
  /// In en, this message translates to:
  /// **'Day name'**
  String get dayName;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Add exercise dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// Exercise name label
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseName;

  /// Sets unit
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get sets;

  /// Minimum reps input label
  ///
  /// In en, this message translates to:
  /// **'Min reps'**
  String get minReps;

  /// Maximum reps input label
  ///
  /// In en, this message translates to:
  /// **'Max reps'**
  String get maxReps;

  /// Required field validation
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Sets validation message
  ///
  /// In en, this message translates to:
  /// **'Enter sets'**
  String get enterSets;

  /// Min reps validation message
  ///
  /// In en, this message translates to:
  /// **'Enter min'**
  String get enterMin;

  /// Max reps validation message
  ///
  /// In en, this message translates to:
  /// **'Enter max'**
  String get enterMax;

  /// Max reps validation message
  ///
  /// In en, this message translates to:
  /// **'Max must be >= min'**
  String get maxMustBeGreaterThanMin;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No exercises message
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get noExercisesYet;

  /// Add exercises instruction
  ///
  /// In en, this message translates to:
  /// **'Tap + to add exercises'**
  String get tapToAddExercises;

  /// Exercises label
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No exercises instruction message
  ///
  /// In en, this message translates to:
  /// **'No exercises yet. Tap \'Add exercise\' to start.'**
  String get noExercisesYetTapAddExerciseToStart;

  /// Save day button
  ///
  /// In en, this message translates to:
  /// **'Save Day'**
  String get saveDay;

  /// Add exercise button text
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExerciseButton;

  /// Our Programs section title
  ///
  /// In en, this message translates to:
  /// **'Our Programs'**
  String get ourPrograms;

  /// Save routine button
  ///
  /// In en, this message translates to:
  /// **'Save Routine'**
  String get saveRoutine;

  /// Number of days input hint
  ///
  /// In en, this message translates to:
  /// **'How many days is your program (including rest days)?'**
  String get howManyDaysIsYourProgram;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Description for curated programs
  ///
  /// In en, this message translates to:
  /// **'Curated plans (PPL, UL, Full-body)'**
  String get curatedPlansDescription;

  /// Custom Routines section title
  ///
  /// In en, this message translates to:
  /// **'Custom Routines'**
  String get customRoutines;

  /// Description for custom routines
  ///
  /// In en, this message translates to:
  /// **'Build your own weekly plan'**
  String get buildYourOwnWeeklyPlan;

  /// Custom Programs page title
  ///
  /// In en, this message translates to:
  /// **'Custom Programs'**
  String get customPrograms;

  /// Add new routine button text
  ///
  /// In en, this message translates to:
  /// **'Add New Routine'**
  String get addNewRoutine;

  /// Add routine floating button text
  ///
  /// In en, this message translates to:
  /// **'Add Routine'**
  String get addRoutine;

  /// Message when routine is saved
  ///
  /// In en, this message translates to:
  /// **'Routine saved'**
  String get routineSaved;

  /// Message when routine is updated
  ///
  /// In en, this message translates to:
  /// **'Routine updated'**
  String get routineUpdated;

  /// Delete routine confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete routine?'**
  String get deleteRoutineQuestion;

  /// Delete routine confirmation content
  ///
  /// In en, this message translates to:
  /// **'This will remove \"{routineName}\".'**
  String deleteRoutineContent(String routineName);

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Message when routine is deleted
  ///
  /// In en, this message translates to:
  /// **'Routine deleted'**
  String get routineDeleted;

  /// Default name for untitled routines
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get untitled;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Start workout button text
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Select photo button
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// Caption label
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get caption;

  /// Caption placeholder text
  ///
  /// In en, this message translates to:
  /// **'Write a caption...'**
  String get writeACaption;

  /// Add location option
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// Tag people option
  ///
  /// In en, this message translates to:
  /// **'Tag People'**
  String get tagPeople;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Location feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Location feature coming soon!'**
  String get locationFeatureComingSoon;

  /// Tag people feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Tag people feature coming soon!'**
  String get tagPeopleFeatureComingSoon;

  /// Image selection success message
  ///
  /// In en, this message translates to:
  /// **'Image selected successfully!'**
  String get imageSelectedSuccessfully;

  /// Error selecting image message
  ///
  /// In en, this message translates to:
  /// **'Error selecting image: {error}'**
  String errorSelectingImage(String error);

  /// No image selected error
  ///
  /// In en, this message translates to:
  /// **'Please select an image first'**
  String get pleaseSelectAnImageFirst;

  /// Post creation success message
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreatedSuccessfully;

  /// Workout date label
  ///
  /// In en, this message translates to:
  /// **'Workout date:'**
  String get workoutDate;

  /// Routine selection text
  ///
  /// In en, this message translates to:
  /// **'Pick your current routine'**
  String get pickYourCurrentRoutine;

  /// Day selection text
  ///
  /// In en, this message translates to:
  /// **'Which day are you training?'**
  String get whichDayAreYouTraining;

  /// Additional exercises label
  ///
  /// In en, this message translates to:
  /// **'Additional exercises'**
  String get additionalExercises;

  /// Add set title
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Reps label
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// Finish workout button
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// Recent workouts section
  ///
  /// In en, this message translates to:
  /// **'Recent Workouts'**
  String get recentWorkouts;

  /// Workout logged dialog title
  ///
  /// In en, this message translates to:
  /// **'Workout Logged'**
  String get workoutLogged;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Target label
  ///
  /// In en, this message translates to:
  /// **'Target:'**
  String get target;

  /// Logged sets label
  ///
  /// In en, this message translates to:
  /// **'Logged sets:'**
  String get loggedSets;

  /// Add set button text
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSet2;

  /// No exercises message
  ///
  /// In en, this message translates to:
  /// **'Your routine has no exercises yet.'**
  String get yourRoutineHasNoExercisesYet;

  /// Log workout page title
  ///
  /// In en, this message translates to:
  /// **'Log Today\'s workout'**
  String get logTodaysWorkout;

  /// Create routine first message
  ///
  /// In en, this message translates to:
  /// **'Create a routine first'**
  String get createARoutineFirst;

  /// Add additional exercise dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Additional Exercise'**
  String get addAdditionalExercise;

  /// Weight validation message
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// Reps validation message
  ///
  /// In en, this message translates to:
  /// **'Enter reps'**
  String get enterReps;

  /// No workouts for specific day message
  ///
  /// In en, this message translates to:
  /// **'No workouts logged for {day} yet.'**
  String noWorkoutsLoggedForDay(String day);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
