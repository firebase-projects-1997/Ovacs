import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OVACS App'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get skip;

  /// No description provided for @towardsWorldOfSpeedInArchiving.
  ///
  /// In en, this message translates to:
  /// **'Towards the world of speed in archiving'**
  String get towardsWorldOfSpeedInArchiving;

  /// No description provided for @weAre.
  ///
  /// In en, this message translates to:
  /// **'We are'**
  String get weAre;

  /// No description provided for @aLawFirmThatHelps.
  ///
  /// In en, this message translates to:
  /// **'A Law Firm that helps'**
  String get aLawFirmThatHelps;

  /// No description provided for @tenMillionPlusPeople.
  ///
  /// In en, this message translates to:
  /// **'10 Million+ people have a lot of files they want to keep, such as their court cases.'**
  String get tenMillionPlusPeople;

  /// No description provided for @ourMissionIsTo.
  ///
  /// In en, this message translates to:
  /// **'Our mission is to'**
  String get ourMissionIsTo;

  /// No description provided for @empowerLegalProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Empower legal professionals'**
  String get empowerLegalProfessionals;

  /// No description provided for @byProvidingCuttingEdgeSolutions.
  ///
  /// In en, this message translates to:
  /// **'By providing cutting-edge solutions for efficient and secure archiving of vital documents.'**
  String get byProvidingCuttingEdgeSolutions;

  /// No description provided for @experienceTheFuture.
  ///
  /// In en, this message translates to:
  /// **'Experience the future'**
  String get experienceTheFuture;

  /// No description provided for @ofLegalDocumentManagement.
  ///
  /// In en, this message translates to:
  /// **'Of legal document management'**
  String get ofLegalDocumentManagement;

  /// No description provided for @withOurIntuitivePlatform.
  ///
  /// In en, this message translates to:
  /// **'With our intuitive platform, ensuring quick access and unparalleled data integrity.'**
  String get withOurIntuitivePlatform;

  /// No description provided for @joinUsIn.
  ///
  /// In en, this message translates to:
  /// **'Join us in'**
  String get joinUsIn;

  /// No description provided for @revolutionizingLegalArchiving.
  ///
  /// In en, this message translates to:
  /// **'Revolutionizing legal archiving'**
  String get revolutionizingLegalArchiving;

  /// No description provided for @whereSpeedMeetsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Where speed meets security, and every file is just a click away.'**
  String get whereSpeedMeetsSecurity;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @enterYourLogId.
  ///
  /// In en, this message translates to:
  /// **'Enter your log ID to access your account'**
  String get enterYourLogId;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget password?'**
  String get forgetPassword;

  /// No description provided for @signin.
  ///
  /// In en, this message translates to:
  /// **'Signin'**
  String get signin;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAnAccount;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAnAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get userName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// No description provided for @enterYourCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter your company name'**
  String get enterYourCompanyName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @countryWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Country will appear here'**
  String get countryWillAppearHere;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @enterYourPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Enter your password again'**
  String get enterYourPasswordAgain;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'8023456789'**
  String get mobileNumber;

  /// No description provided for @iHaveReadAndAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get iHaveReadAndAgreeTo;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service and Privacy Policy'**
  String get pleaseAgreeToTerms;

  /// No description provided for @pleaseSelectYourCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Please select your country code.'**
  String get pleaseSelectYourCountryCode;

  /// No description provided for @checkYourEmailForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Check your E-mail for confirmation code'**
  String get checkYourEmailForConfirmation;

  /// No description provided for @usernameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameIsRequired;

  /// No description provided for @companyNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Company name is required'**
  String get companyNameIsRequired;

  /// No description provided for @pleaseSelectACountryCode.
  ///
  /// In en, this message translates to:
  /// **'Please select a country code'**
  String get pleaseSelectACountryCode;

  /// No description provided for @mobileNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileNumberIsRequired;

  /// No description provided for @enterAValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get enterAValidMobileNumber;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @enterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterAValidEmailAddress;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @confirmPasswordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordIsRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @forgetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forgetPasswordTitle;

  /// No description provided for @enterEmailOrPhoneForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address or phone you used when you joined and we will send you instructions to reset your password'**
  String get enterEmailOrPhoneForReset;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @setYourNewPasswordSoYouCanLoginAndAccessOvacs.
  ///
  /// In en, this message translates to:
  /// **'Set your new password so you can login and access Ovacs'**
  String get setYourNewPasswordSoYouCanLoginAndAccessOvacs;

  /// No description provided for @pinIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Pin Is Required'**
  String get pinIsRequired;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @upcomingSessions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Sessions'**
  String get upcomingSessions;

  /// No description provided for @nothingToDisplayHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing to display here!'**
  String get nothingToDisplayHere;

  /// No description provided for @youMustAddSessionsToShowThem.
  ///
  /// In en, this message translates to:
  /// **'You must add sessions to show them.'**
  String get youMustAddSessionsToShowThem;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @pleaseEnterTheCodeWeJustSentTo.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code we just sent to'**
  String get pleaseEnterTheCodeWeJustSentTo;

  /// No description provided for @didntReceiveOTP.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP? '**
  String get didntReceiveOTP;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// No description provided for @connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connections;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalCases.
  ///
  /// In en, this message translates to:
  /// **'Total Cases'**
  String get totalCases;

  /// No description provided for @totalClients.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClients;

  /// No description provided for @totalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Total Documents'**
  String get totalDocuments;

  /// No description provided for @totalSpaceUsed.
  ///
  /// In en, this message translates to:
  /// **'Total SpaceUsed'**
  String get totalSpaceUsed;

  /// No description provided for @allCases.
  ///
  /// In en, this message translates to:
  /// **'All Cases'**
  String get allCases;

  /// No description provided for @caseName.
  ///
  /// In en, this message translates to:
  /// **'Case Name: '**
  String get caseName;

  /// No description provided for @lawyers.
  ///
  /// In en, this message translates to:
  /// **'Lawyers: '**
  String get lawyers;

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

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @companyInformation.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyInformation;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active?'**
  String get active;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @enterMessageHere.
  ///
  /// In en, this message translates to:
  /// **'Enter message here...'**
  String get enterMessageHere;

  /// No description provided for @voiceError.
  ///
  /// In en, this message translates to:
  /// **'voice error'**
  String get voiceError;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @addNewClient.
  ///
  /// In en, this message translates to:
  /// **'Add New Client'**
  String get addNewClient;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name: '**
  String get clientName;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @enterClientName.
  ///
  /// In en, this message translates to:
  /// **'Enter client name'**
  String get enterClientName;

  /// No description provided for @clientNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Client name is required'**
  String get clientNameIsRequired;

  /// No description provided for @countryIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryIsRequired;

  /// No description provided for @phoneIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneIsRequired;

  /// No description provided for @clientAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Client added successfully!'**
  String get clientAddedSuccessfully;

  /// No description provided for @allClients.
  ///
  /// In en, this message translates to:
  /// **'All Clients'**
  String get allClients;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @youMustAddClientsToShowThem.
  ///
  /// In en, this message translates to:
  /// **'You must add clients to show them..'**
  String get youMustAddClientsToShowThem;

  /// No description provided for @youMustAddDocumentsToShowThem.
  ///
  /// In en, this message translates to:
  /// **'You must add documents to show them..'**
  String get youMustAddDocumentsToShowThem;

  /// No description provided for @youMustAddCasesToShowThem.
  ///
  /// In en, this message translates to:
  /// **'You must add cases to show them..'**
  String get youMustAddCasesToShowThem;

  /// No description provided for @areYouSureYouWantToDeleteThisClient.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this client?'**
  String get areYouSureYouWantToDeleteThisClient;

  /// No description provided for @sessionName.
  ///
  /// In en, this message translates to:
  /// **'Session name: '**
  String get sessionName;

  /// No description provided for @viewGroups.
  ///
  /// In en, this message translates to:
  /// **'view groups'**
  String get viewGroups;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name: '**
  String get fileName;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group title: '**
  String get groupName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description: '**
  String get description;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time: '**
  String get time;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get date;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @noTimeAdded.
  ///
  /// In en, this message translates to:
  /// **'No time added'**
  String get noTimeAdded;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @errorLoadingCountries.
  ///
  /// In en, this message translates to:
  /// **'Error loading countries: '**
  String get errorLoadingCountries;

  /// No description provided for @welcomeBackMessage.
  ///
  /// In en, this message translates to:
  /// **'welcome back'**
  String get welcomeBackMessage;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search Clients'**
  String get searchClients;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @clientDetails.
  ///
  /// In en, this message translates to:
  /// **'Client Details'**
  String get clientDetails;

  /// No description provided for @clientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Client not found.'**
  String get clientNotFound;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @searchCases.
  ///
  /// In en, this message translates to:
  /// **'Search Cases'**
  String get searchCases;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @errorLoadingClients.
  ///
  /// In en, this message translates to:
  /// **'Error loading clients:'**
  String get errorLoadingClients;

  /// No description provided for @editCase.
  ///
  /// In en, this message translates to:
  /// **'Edit Case'**
  String get editCase;

  /// No description provided for @noSessionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sessions available'**
  String get noSessionsAvailable;

  /// No description provided for @nA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get nA;

  /// No description provided for @thisUrlCantLaunched.
  ///
  /// In en, this message translates to:
  /// **'This Url Can\'t Launched'**
  String get thisUrlCantLaunched;

  /// No description provided for @orderBy.
  ///
  /// In en, this message translates to:
  /// **'Order by'**
  String get orderBy;

  /// No description provided for @createdAtAsc.
  ///
  /// In en, this message translates to:
  /// **'Created At Asc'**
  String get createdAtAsc;

  /// No description provided for @createdAtDesc.
  ///
  /// In en, this message translates to:
  /// **'Created At Desc'**
  String get createdAtDesc;

  /// No description provided for @dateAsc.
  ///
  /// In en, this message translates to:
  /// **'Date Asc'**
  String get dateAsc;

  /// No description provided for @dateDesc.
  ///
  /// In en, this message translates to:
  /// **'Date Desc'**
  String get dateDesc;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @pickDateAfter.
  ///
  /// In en, this message translates to:
  /// **'Pick date after'**
  String get pickDateAfter;

  /// No description provided for @pickDateBefore.
  ///
  /// In en, this message translates to:
  /// **'Pick date before'**
  String get pickDateBefore;

  /// No description provided for @chooseYourClient.
  ///
  /// In en, this message translates to:
  /// **'Choose your client'**
  String get chooseYourClient;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @pleaseFillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllRequiredFields;

  /// No description provided for @failedToUpdateCase.
  ///
  /// In en, this message translates to:
  /// **'Failed to update case'**
  String get failedToUpdateCase;

  /// No description provided for @caseTitle.
  ///
  /// In en, this message translates to:
  /// **'Case Title'**
  String get caseTitle;

  /// No description provided for @enterCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter case title'**
  String get enterCaseTitle;

  /// No description provided for @titleIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleIsRequired;

  /// No description provided for @enterCaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter case description'**
  String get enterCaseDescription;

  /// No description provided for @descriptionIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionIsRequired;

  /// No description provided for @appearInCourtOn.
  ///
  /// In en, this message translates to:
  /// **'Appear in court on'**
  String get appearInCourtOn;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @addNewCase.
  ///
  /// In en, this message translates to:
  /// **'Add New Case'**
  String get addNewCase;

  /// No description provided for @enterCaseName.
  ///
  /// In en, this message translates to:
  /// **'Enter case name'**
  String get enterCaseName;

  /// No description provided for @caseNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Case name is required'**
  String get caseNameIsRequired;

  /// No description provided for @dateFormatHint.
  ///
  /// In en, this message translates to:
  /// **'d-m-y'**
  String get dateFormatHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @pleaseSelectAClient.
  ///
  /// In en, this message translates to:
  /// **'Please select a client'**
  String get pleaseSelectAClient;

  /// No description provided for @caseCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Case created successfully'**
  String get caseCreatedSuccessfully;

  /// No description provided for @caseInformation.
  ///
  /// In en, this message translates to:
  /// **'Case {id} Information'**
  String caseInformation(Object id);

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @areYouSureYouWantToDeleteThisCase.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this case?'**
  String get areYouSureYouWantToDeleteThisCase;

  /// No description provided for @areYouSureYouWantToDeleteThisDocument.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this document?'**
  String get areYouSureYouWantToDeleteThisDocument;

  /// No description provided for @caseWord.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get caseWord;

  /// No description provided for @caseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Case name'**
  String get caseNameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @clientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get clientNameLabel;

  /// No description provided for @appearInCourtOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Appear in court on'**
  String get appearInCourtOnLabel;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session title'**
  String get sessionTitle;

  /// No description provided for @sessionInformation.
  ///
  /// In en, this message translates to:
  /// **'Session {id} Information'**
  String sessionInformation(Object id);

  /// No description provided for @areYouSureYouWantToDeleteThisSession.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this session?'**
  String get areYouSureYouWantToDeleteThisSession;

  /// No description provided for @errorDeletingSession.
  ///
  /// In en, this message translates to:
  /// **'Error deleting session'**
  String get errorDeletingSession;

  /// No description provided for @errorDeletingCase.
  ///
  /// In en, this message translates to:
  /// **'Error deleting case'**
  String get errorDeletingCase;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get uploadDocuments;

  /// No description provided for @selectFiles.
  ///
  /// In en, this message translates to:
  /// **'Select Files'**
  String get selectFiles;

  /// No description provided for @selectedFilesCount.
  ///
  /// In en, this message translates to:
  /// **'Selected Files: {count}'**
  String selectedFilesCount(Object count);

  /// No description provided for @storeAsGroup.
  ///
  /// In en, this message translates to:
  /// **'Store as Group'**
  String get storeAsGroup;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Group Description'**
  String get groupDescription;

  /// No description provided for @pleaseSelectFilesToUpload.
  ///
  /// In en, this message translates to:
  /// **'Please select files to upload.'**
  String get pleaseSelectFilesToUpload;

  /// No description provided for @pleaseSelectSecurityLevel.
  ///
  /// In en, this message translates to:
  /// **'Please select a security level.'**
  String get pleaseSelectSecurityLevel;

  /// No description provided for @pleaseEnterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name.'**
  String get pleaseEnterGroupName;

  /// No description provided for @uploadSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {count} documents successfully!'**
  String uploadSuccessMessage(Object count);

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(Object error);

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @securityLevel.
  ///
  /// In en, this message translates to:
  /// **'Security Level'**
  String get securityLevel;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove File'**
  String get removeFile;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get errorLoadingMessages;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required.'**
  String get microphonePermissionRequired;

  /// No description provided for @failedToStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Failed to start recording.'**
  String get failedToStartRecording;

  /// No description provided for @failedToConvertAudioToMp3.
  ///
  /// In en, this message translates to:
  /// **'Failed to convert audio to mp3.'**
  String get failedToConvertAudioToMp3;

  /// No description provided for @emptyAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Empty audio file.'**
  String get emptyAudioFile;

  /// No description provided for @recordingError.
  ///
  /// In en, this message translates to:
  /// **'Recording error'**
  String get recordingError;

  /// No description provided for @recordingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Recording cancelled.'**
  String get recordingCancelled;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed'**
  String get sendFailed;

  /// No description provided for @microphoneAndStoragePermissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone and Storage permissions are required.'**
  String get microphoneAndStoragePermissionsRequired;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found.'**
  String get fileNotFound;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter message...'**
  String get enterMessage;

  /// No description provided for @audioUrlMissing.
  ///
  /// In en, this message translates to:
  /// **'Audio URL is missing.'**
  String get audioUrlMissing;

  /// No description provided for @playbackError.
  ///
  /// In en, this message translates to:
  /// **'Playback error.'**
  String get playbackError;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessageTitle;

  /// No description provided for @writeNewMessage.
  ///
  /// In en, this message translates to:
  /// **'Write new message'**
  String get writeNewMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @failedToEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to edit message'**
  String get failedToEditMessage;

  /// No description provided for @failedToDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete message'**
  String get failedToDeleteMessage;

  /// No description provided for @connectionSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Connection Suggestions'**
  String get connectionSuggestions;

  /// No description provided for @connectionRequests.
  ///
  /// In en, this message translates to:
  /// **'Connection Requests'**
  String get connectionRequests;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following ({count})'**
  String following(Object count);

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers ({count})'**
  String followers(Object count);

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @connectionRequestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection request sent successfully'**
  String get connectionRequestSentSuccess;

  /// No description provided for @connectionRequestSentFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to send connection request: {error}'**
  String connectionRequestSentFailure(Object error);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @idWithValue.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idWithValue(Object id);

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'App Color'**
  String get primaryColor;

  /// No description provided for @peopleMustFollowYouToSeeThemHere.
  ///
  /// In en, this message translates to:
  /// **'People must follow you to see them here'**
  String get peopleMustFollowYouToSeeThemHere;

  /// No description provided for @sendInvitations.
  ///
  /// In en, this message translates to:
  /// **'Send Invitations'**
  String get sendInvitations;

  /// No description provided for @invitation.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get invitation;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @invitationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter email addresses and names of people you want to invite to connect with you.'**
  String get invitationInstructions;

  /// No description provided for @customMessageOptional.
  ///
  /// In en, this message translates to:
  /// **'Custom Message (Optional)'**
  String get customMessageOptional;

  /// No description provided for @addPersonalMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a personal message to your invitation...'**
  String get addPersonalMessage;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @failedToSendInvitations.
  ///
  /// In en, this message translates to:
  /// **'Failed to send invitations'**
  String get failedToSendInvitations;

  /// No description provided for @assignedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Assigned Accounts'**
  String get assignedAccounts;

  /// No description provided for @assignAccount.
  ///
  /// In en, this message translates to:
  /// **'Assign Account'**
  String get assignAccount;

  /// No description provided for @searchFollowers.
  ///
  /// In en, this message translates to:
  /// **'Search followers'**
  String get searchFollowers;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search...'**
  String get typeToSearch;

  /// No description provided for @failedToLoadFollowers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load followers'**
  String get failedToLoadFollowers;

  /// No description provided for @noFollowersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No followers available'**
  String get noFollowersAvailable;

  /// No description provided for @allFollowersAlreadyAssigned.
  ///
  /// In en, this message translates to:
  /// **'All followers are already assigned'**
  String get allFollowersAlreadyAssigned;

  /// No description provided for @noFollowersMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No followers match your search'**
  String get noFollowersMatchSearch;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @accountAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account assigned successfully'**
  String get accountAssignedSuccessfully;

  /// No description provided for @failedToAssignAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign account'**
  String get failedToAssignAccount;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @noAccountsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No accounts assigned'**
  String get noAccountsAssigned;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownAccount.
  ///
  /// In en, this message translates to:
  /// **'Unknown Account'**
  String get unknownAccount;

  /// No description provided for @updateRole.
  ///
  /// In en, this message translates to:
  /// **'Update Role'**
  String get updateRole;

  /// No description provided for @updateRoleFor.
  ///
  /// In en, this message translates to:
  /// **'Update role for {accountName}'**
  String updateRoleFor(Object accountName);

  /// No description provided for @roleUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Role updated successfully'**
  String get roleUpdatedSuccessfully;

  /// No description provided for @failedToUpdateRole.
  ///
  /// In en, this message translates to:
  /// **'Failed to update role'**
  String get failedToUpdateRole;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @removeAssignment.
  ///
  /// In en, this message translates to:
  /// **'Remove Assignment'**
  String get removeAssignment;

  /// No description provided for @confirmRemoveAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {accountName} from this case?'**
  String confirmRemoveAccount(Object accountName);

  /// No description provided for @thisAccount.
  ///
  /// In en, this message translates to:
  /// **'this account'**
  String get thisAccount;

  /// No description provided for @accountRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account removed successfully'**
  String get accountRemovedSuccessfully;

  /// No description provided for @failedToRemoveAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove account'**
  String get failedToRemoveAccount;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamond;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @viewingWorkspaceOf.
  ///
  /// In en, this message translates to:
  /// **'You are now viewing the workspace of {accountName}'**
  String viewingWorkspaceOf(Object accountName);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @switchToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch to Workspace'**
  String get switchToWorkspace;

  /// No description provided for @documentDetails.
  ///
  /// In en, this message translates to:
  /// **'Document Details'**
  String get documentDetails;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @uploadedAt.
  ///
  /// In en, this message translates to:
  /// **'Uploaded At'**
  String get uploadedAt;

  /// No description provided for @contextInformation.
  ///
  /// In en, this message translates to:
  /// **'Context Information'**
  String get contextInformation;

  /// No description provided for @case_.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get case_;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download Complete'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get downloadFailed;

  /// No description provided for @updateSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Update Successful'**
  String get updateSuccessful;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateFailed;

  /// No description provided for @deleteSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Delete Successful'**
  String get deleteSuccessful;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete Failed'**
  String get deleteFailed;

  /// No description provided for @moveToGroup.
  ///
  /// In en, this message translates to:
  /// **'Move to Group'**
  String get moveToGroup;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get selectGroup;

  /// No description provided for @moveSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Document moved successfully'**
  String get moveSuccessful;

  /// No description provided for @moveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to move document'**
  String get moveFailed;

  /// No description provided for @noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No groups available'**
  String get noGroupsAvailable;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
