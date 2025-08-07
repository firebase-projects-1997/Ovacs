// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `OVACS App`
  String get appTitle {
    return Intl.message('OVACS App', name: 'appTitle', desc: '', args: []);
  }

  /// `Welcome`
  String get welcome {
    return Intl.message('Welcome', name: 'welcome', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `skip`
  String get skip {
    return Intl.message('skip', name: 'skip', desc: '', args: []);
  }

  /// `Towards the world of speed in archiving`
  String get towardsWorldOfSpeedInArchiving {
    return Intl.message(
      'Towards the world of speed in archiving',
      name: 'towardsWorldOfSpeedInArchiving',
      desc: '',
      args: [],
    );
  }

  /// `We are`
  String get weAre {
    return Intl.message('We are', name: 'weAre', desc: '', args: []);
  }

  /// `A Law Firm that helps`
  String get aLawFirmThatHelps {
    return Intl.message(
      'A Law Firm that helps',
      name: 'aLawFirmThatHelps',
      desc: '',
      args: [],
    );
  }

  /// `10 Million+ people have a lot of files they want to keep, such as their court cases.`
  String get tenMillionPlusPeople {
    return Intl.message(
      '10 Million+ people have a lot of files they want to keep, such as their court cases.',
      name: 'tenMillionPlusPeople',
      desc: '',
      args: [],
    );
  }

  /// `Our mission is to`
  String get ourMissionIsTo {
    return Intl.message(
      'Our mission is to',
      name: 'ourMissionIsTo',
      desc: '',
      args: [],
    );
  }

  /// `Empower legal professionals`
  String get empowerLegalProfessionals {
    return Intl.message(
      'Empower legal professionals',
      name: 'empowerLegalProfessionals',
      desc: '',
      args: [],
    );
  }

  /// `By providing cutting-edge solutions for efficient and secure archiving of vital documents.`
  String get byProvidingCuttingEdgeSolutions {
    return Intl.message(
      'By providing cutting-edge solutions for efficient and secure archiving of vital documents.',
      name: 'byProvidingCuttingEdgeSolutions',
      desc: '',
      args: [],
    );
  }

  /// `Experience the future`
  String get experienceTheFuture {
    return Intl.message(
      'Experience the future',
      name: 'experienceTheFuture',
      desc: '',
      args: [],
    );
  }

  /// `Of legal document management`
  String get ofLegalDocumentManagement {
    return Intl.message(
      'Of legal document management',
      name: 'ofLegalDocumentManagement',
      desc: '',
      args: [],
    );
  }

  /// `With our intuitive platform, ensuring quick access and unparalleled data integrity.`
  String get withOurIntuitivePlatform {
    return Intl.message(
      'With our intuitive platform, ensuring quick access and unparalleled data integrity.',
      name: 'withOurIntuitivePlatform',
      desc: '',
      args: [],
    );
  }

  /// `Join us in`
  String get joinUsIn {
    return Intl.message('Join us in', name: 'joinUsIn', desc: '', args: []);
  }

  /// `Revolutionizing legal archiving`
  String get revolutionizingLegalArchiving {
    return Intl.message(
      'Revolutionizing legal archiving',
      name: 'revolutionizingLegalArchiving',
      desc: '',
      args: [],
    );
  }

  /// `Where speed meets security, and every file is just a click away.`
  String get whereSpeedMeetsSecurity {
    return Intl.message(
      'Where speed meets security, and every file is just a click away.',
      name: 'whereSpeedMeetsSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Enter your log ID to access your account`
  String get enterYourLogId {
    return Intl.message(
      'Enter your log ID to access your account',
      name: 'enterYourLogId',
      desc: '',
      args: [],
    );
  }

  /// `E-mail`
  String get email {
    return Intl.message('E-mail', name: 'email', desc: '', args: []);
  }

  /// `Enter your email`
  String get enterYourEmail {
    return Intl.message(
      'Enter your email',
      name: 'enterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter your password`
  String get enterYourPassword {
    return Intl.message(
      'Enter your password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Forget password?`
  String get forgetPassword {
    return Intl.message(
      'Forget password?',
      name: 'forgetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Signin`
  String get signin {
    return Intl.message('Signin', name: 'signin', desc: '', args: []);
  }

  /// `Don't have an account? `
  String get dontHaveAnAccount {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'dontHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get signIn {
    return Intl.message('Sign in', name: 'signIn', desc: '', args: []);
  }

  /// `User name`
  String get userName {
    return Intl.message('User name', name: 'userName', desc: '', args: []);
  }

  /// `Enter your name`
  String get enterYourName {
    return Intl.message(
      'Enter your name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Company name`
  String get companyName {
    return Intl.message(
      'Company name',
      name: 'companyName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your company name`
  String get enterYourCompanyName {
    return Intl.message(
      'Enter your company name',
      name: 'enterYourCompanyName',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Code`
  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `Country will appear here`
  String get countryWillAppearHere {
    return Intl.message(
      'Country will appear here',
      name: 'countryWillAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password again`
  String get enterYourPasswordAgain {
    return Intl.message(
      'Enter your password again',
      name: 'enterYourPasswordAgain',
      desc: '',
      args: [],
    );
  }

  /// `8023456789`
  String get mobileNumber {
    return Intl.message('8023456789', name: 'mobileNumber', desc: '', args: []);
  }

  /// `I have read and agree to the `
  String get iHaveReadAndAgreeTo {
    return Intl.message(
      'I have read and agree to the ',
      name: 'iHaveReadAndAgreeTo',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// ` and `
  String get and {
    return Intl.message(' and ', name: 'and', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Please agree to the Terms of Service and Privacy Policy`
  String get pleaseAgreeToTerms {
    return Intl.message(
      'Please agree to the Terms of Service and Privacy Policy',
      name: 'pleaseAgreeToTerms',
      desc: '',
      args: [],
    );
  }

  /// `Please select your country code.`
  String get pleaseSelectYourCountryCode {
    return Intl.message(
      'Please select your country code.',
      name: 'pleaseSelectYourCountryCode',
      desc: '',
      args: [],
    );
  }

  /// `Check your E-mail for confirmation code`
  String get checkYourEmailForConfirmation {
    return Intl.message(
      'Check your E-mail for confirmation code',
      name: 'checkYourEmailForConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Username is required`
  String get usernameIsRequired {
    return Intl.message(
      'Username is required',
      name: 'usernameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Company name is required`
  String get companyNameIsRequired {
    return Intl.message(
      'Company name is required',
      name: 'companyNameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a country code`
  String get pleaseSelectACountryCode {
    return Intl.message(
      'Please select a country code',
      name: 'pleaseSelectACountryCode',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number is required`
  String get mobileNumberIsRequired {
    return Intl.message(
      'Mobile number is required',
      name: 'mobileNumberIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid mobile number`
  String get enterAValidMobileNumber {
    return Intl.message(
      'Enter a valid mobile number',
      name: 'enterAValidMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get emailIsRequired {
    return Intl.message(
      'Email is required',
      name: 'emailIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get enterAValidEmailAddress {
    return Intl.message(
      'Enter a valid email address',
      name: 'enterAValidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get passwordIsRequired {
    return Intl.message(
      'Password is required',
      name: 'passwordIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters long`
  String get passwordMustBeAtLeast6Characters {
    return Intl.message(
      'Password must be at least 6 characters long',
      name: 'passwordMustBeAtLeast6Characters',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password is required`
  String get confirmPasswordIsRequired {
    return Intl.message(
      'Confirm password is required',
      name: 'confirmPasswordIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Forget Password`
  String get forgetPasswordTitle {
    return Intl.message(
      'Forget Password',
      name: 'forgetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter the email address or phone you used when you joined and we will send you instructions to reset your password`
  String get enterEmailOrPhoneForReset {
    return Intl.message(
      'Enter the email address or phone you used when you joined and we will send you instructions to reset your password',
      name: 'enterEmailOrPhoneForReset',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Create New Password`
  String get createNewPassword {
    return Intl.message(
      'Create New Password',
      name: 'createNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Set your new password so you can login and access Ovacs`
  String get setYourNewPasswordSoYouCanLoginAndAccessOvacs {
    return Intl.message(
      'Set your new password so you can login and access Ovacs',
      name: 'setYourNewPasswordSoYouCanLoginAndAccessOvacs',
      desc: '',
      args: [],
    );
  }

  /// `Pin Is Required`
  String get pinIsRequired {
    return Intl.message(
      'Pin Is Required',
      name: 'pinIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `My Schedule`
  String get mySchedule {
    return Intl.message('My Schedule', name: 'mySchedule', desc: '', args: []);
  }

  /// `Upcoming Sessions`
  String get upcomingSessions {
    return Intl.message(
      'Upcoming Sessions',
      name: 'upcomingSessions',
      desc: '',
      args: [],
    );
  }

  /// `Nothing to display here!`
  String get nothingToDisplayHere {
    return Intl.message(
      'Nothing to display here!',
      name: 'nothingToDisplayHere',
      desc: '',
      args: [],
    );
  }

  /// `You must add sessions to show them.`
  String get youMustAddSessionsToShowThem {
    return Intl.message(
      'You must add sessions to show them.',
      name: 'youMustAddSessionsToShowThem',
      desc: '',
      args: [],
    );
  }

  /// `Password Changed Successfully`
  String get passwordChangedSuccessfully {
    return Intl.message(
      'Password Changed Successfully',
      name: 'passwordChangedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `OTP Verification`
  String get otpVerification {
    return Intl.message(
      'OTP Verification',
      name: 'otpVerification',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the code we just sent to`
  String get pleaseEnterTheCodeWeJustSentTo {
    return Intl.message(
      'Please enter the code we just sent to',
      name: 'pleaseEnterTheCodeWeJustSentTo',
      desc: '',
      args: [],
    );
  }

  /// `Didn't receive OTP? `
  String get didntReceiveOTP {
    return Intl.message(
      'Didn\'t receive OTP? ',
      name: 'didntReceiveOTP',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get resendCode {
    return Intl.message('Resend Code', name: 'resendCode', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Cases`
  String get cases {
    return Intl.message('Cases', name: 'cases', desc: '', args: []);
  }

  /// `Connections`
  String get connections {
    return Intl.message('Connections', name: 'connections', desc: '', args: []);
  }

  /// `Clients`
  String get clients {
    return Intl.message('Clients', name: 'clients', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Total Cases`
  String get totalCases {
    return Intl.message('Total Cases', name: 'totalCases', desc: '', args: []);
  }

  /// `Total Clients`
  String get totalClients {
    return Intl.message(
      'Total Clients',
      name: 'totalClients',
      desc: '',
      args: [],
    );
  }

  /// `Total Documents`
  String get totalDocuments {
    return Intl.message(
      'Total Documents',
      name: 'totalDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Total SpaceUsed`
  String get totalSpaceUsed {
    return Intl.message(
      'Total SpaceUsed',
      name: 'totalSpaceUsed',
      desc: '',
      args: [],
    );
  }

  /// `All Cases`
  String get allCases {
    return Intl.message('All Cases', name: 'allCases', desc: '', args: []);
  }

  /// `Case Name: `
  String get caseName {
    return Intl.message('Case Name: ', name: 'caseName', desc: '', args: []);
  }

  /// `Lawyers: `
  String get lawyers {
    return Intl.message('Lawyers: ', name: 'lawyers', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `العربية`
  String get arabic {
    return Intl.message('العربية', name: 'arabic', desc: '', args: []);
  }

  /// `Account Information`
  String get accountInformation {
    return Intl.message(
      'Account Information',
      name: 'accountInformation',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Mobile`
  String get mobile {
    return Intl.message('Mobile', name: 'mobile', desc: '', args: []);
  }

  /// `Role`
  String get role {
    return Intl.message('Role', name: 'role', desc: '', args: []);
  }

  /// `Company Information`
  String get companyInformation {
    return Intl.message(
      'Company Information',
      name: 'companyInformation',
      desc: '',
      args: [],
    );
  }

  /// `Active?`
  String get active {
    return Intl.message('Active?', name: 'active', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Created At`
  String get createdAt {
    return Intl.message('Created At', name: 'createdAt', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Enter message here...`
  String get enterMessageHere {
    return Intl.message(
      'Enter message here...',
      name: 'enterMessageHere',
      desc: '',
      args: [],
    );
  }

  /// `voice error`
  String get voiceError {
    return Intl.message('voice error', name: 'voiceError', desc: '', args: []);
  }

  /// `Edit Message`
  String get editMessage {
    return Intl.message(
      'Edit Message',
      name: 'editMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add New Client`
  String get addNewClient {
    return Intl.message(
      'Add New Client',
      name: 'addNewClient',
      desc: '',
      args: [],
    );
  }

  /// `Client Name: `
  String get clientName {
    return Intl.message(
      'Client Name: ',
      name: 'clientName',
      desc: '',
      args: [],
    );
  }

  /// `Session`
  String get session {
    return Intl.message('Session', name: 'session', desc: '', args: []);
  }

  /// `Enter client name`
  String get enterClientName {
    return Intl.message(
      'Enter client name',
      name: 'enterClientName',
      desc: '',
      args: [],
    );
  }

  /// `Client name is required`
  String get clientNameIsRequired {
    return Intl.message(
      'Client name is required',
      name: 'clientNameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Country is required`
  String get countryIsRequired {
    return Intl.message(
      'Country is required',
      name: 'countryIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Phone is required`
  String get phoneIsRequired {
    return Intl.message(
      'Phone is required',
      name: 'phoneIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Client added successfully!`
  String get clientAddedSuccessfully {
    return Intl.message(
      'Client added successfully!',
      name: 'clientAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `All Clients`
  String get allClients {
    return Intl.message('All Clients', name: 'allClients', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Documents`
  String get documents {
    return Intl.message('Documents', name: 'documents', desc: '', args: []);
  }

  /// `You must add clients to show them..`
  String get youMustAddClientsToShowThem {
    return Intl.message(
      'You must add clients to show them..',
      name: 'youMustAddClientsToShowThem',
      desc: '',
      args: [],
    );
  }

  /// `You must add documents to show them..`
  String get youMustAddDocumentsToShowThem {
    return Intl.message(
      'You must add documents to show them..',
      name: 'youMustAddDocumentsToShowThem',
      desc: '',
      args: [],
    );
  }

  /// `You must add cases to show them..`
  String get youMustAddCasesToShowThem {
    return Intl.message(
      'You must add cases to show them..',
      name: 'youMustAddCasesToShowThem',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this client?`
  String get areYouSureYouWantToDeleteThisClient {
    return Intl.message(
      'Are you sure you want to delete this client?',
      name: 'areYouSureYouWantToDeleteThisClient',
      desc: '',
      args: [],
    );
  }

  /// `Session name: `
  String get sessionName {
    return Intl.message(
      'Session name: ',
      name: 'sessionName',
      desc: '',
      args: [],
    );
  }

  /// `view groups`
  String get viewGroups {
    return Intl.message('view groups', name: 'viewGroups', desc: '', args: []);
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `File name: `
  String get fileName {
    return Intl.message('File name: ', name: 'fileName', desc: '', args: []);
  }

  /// `Group title: `
  String get groupName {
    return Intl.message('Group title: ', name: 'groupName', desc: '', args: []);
  }

  /// `Description: `
  String get description {
    return Intl.message(
      'Description: ',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Time: `
  String get time {
    return Intl.message('Time: ', name: 'time', desc: '', args: []);
  }

  /// `Date: `
  String get date {
    return Intl.message('Date: ', name: 'date', desc: '', args: []);
  }

  /// `ID`
  String get id {
    return Intl.message('ID', name: 'id', desc: '', args: []);
  }

  /// `Account Number`
  String get accountNumber {
    return Intl.message(
      'Account Number',
      name: 'accountNumber',
      desc: '',
      args: [],
    );
  }

  /// `No time added`
  String get noTimeAdded {
    return Intl.message(
      'No time added',
      name: 'noTimeAdded',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error`
  String get unknownError {
    return Intl.message(
      'Unknown error',
      name: 'unknownError',
      desc: '',
      args: [],
    );
  }

  /// `Error loading countries: `
  String get errorLoadingCountries {
    return Intl.message(
      'Error loading countries: ',
      name: 'errorLoadingCountries',
      desc: '',
      args: [],
    );
  }

  /// `welcome back`
  String get welcomeBackMessage {
    return Intl.message(
      'welcome back',
      name: 'welcomeBackMessage',
      desc: '',
      args: [],
    );
  }

  /// `Search Clients`
  String get searchClients {
    return Intl.message(
      'Search Clients',
      name: 'searchClients',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Edit Client`
  String get editClient {
    return Intl.message('Edit Client', name: 'editClient', desc: '', args: []);
  }

  /// `Client Details`
  String get clientDetails {
    return Intl.message(
      'Client Details',
      name: 'clientDetails',
      desc: '',
      args: [],
    );
  }

  /// `Client not found.`
  String get clientNotFound {
    return Intl.message(
      'Client not found.',
      name: 'clientNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Add Client`
  String get addClient {
    return Intl.message('Add Client', name: 'addClient', desc: '', args: []);
  }

  /// `Search Cases`
  String get searchCases {
    return Intl.message(
      'Search Cases',
      name: 'searchCases',
      desc: '',
      args: [],
    );
  }

  /// `Apply Filters`
  String get applyFilters {
    return Intl.message(
      'Apply Filters',
      name: 'applyFilters',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Error loading clients:`
  String get errorLoadingClients {
    return Intl.message(
      'Error loading clients:',
      name: 'errorLoadingClients',
      desc: '',
      args: [],
    );
  }

  /// `Edit Case`
  String get editCase {
    return Intl.message('Edit Case', name: 'editCase', desc: '', args: []);
  }

  /// `No sessions available`
  String get noSessionsAvailable {
    return Intl.message(
      'No sessions available',
      name: 'noSessionsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get nA {
    return Intl.message('N/A', name: 'nA', desc: '', args: []);
  }

  /// `This Url Can't Launched`
  String get thisUrlCantLaunched {
    return Intl.message(
      'This Url Can\'t Launched',
      name: 'thisUrlCantLaunched',
      desc: '',
      args: [],
    );
  }

  /// `Order by`
  String get orderBy {
    return Intl.message('Order by', name: 'orderBy', desc: '', args: []);
  }

  /// `Created At Asc`
  String get createdAtAsc {
    return Intl.message(
      'Created At Asc',
      name: 'createdAtAsc',
      desc: '',
      args: [],
    );
  }

  /// `Created At Desc`
  String get createdAtDesc {
    return Intl.message(
      'Created At Desc',
      name: 'createdAtDesc',
      desc: '',
      args: [],
    );
  }

  /// `Date Asc`
  String get dateAsc {
    return Intl.message('Date Asc', name: 'dateAsc', desc: '', args: []);
  }

  /// `Date Desc`
  String get dateDesc {
    return Intl.message('Date Desc', name: 'dateDesc', desc: '', args: []);
  }

  /// `After`
  String get after {
    return Intl.message('After', name: 'after', desc: '', args: []);
  }

  /// `Before`
  String get before {
    return Intl.message('Before', name: 'before', desc: '', args: []);
  }

  /// `Pick date after`
  String get pickDateAfter {
    return Intl.message(
      'Pick date after',
      name: 'pickDateAfter',
      desc: '',
      args: [],
    );
  }

  /// `Pick date before`
  String get pickDateBefore {
    return Intl.message(
      'Pick date before',
      name: 'pickDateBefore',
      desc: '',
      args: [],
    );
  }

  /// `Choose your client`
  String get chooseYourClient {
    return Intl.message(
      'Choose your client',
      name: 'chooseYourClient',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Please fill all required fields`
  String get pleaseFillAllRequiredFields {
    return Intl.message(
      'Please fill all required fields',
      name: 'pleaseFillAllRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update case`
  String get failedToUpdateCase {
    return Intl.message(
      'Failed to update case',
      name: 'failedToUpdateCase',
      desc: '',
      args: [],
    );
  }

  /// `Case Title`
  String get caseTitle {
    return Intl.message('Case Title', name: 'caseTitle', desc: '', args: []);
  }

  /// `Enter case title`
  String get enterCaseTitle {
    return Intl.message(
      'Enter case title',
      name: 'enterCaseTitle',
      desc: '',
      args: [],
    );
  }

  /// `Title is required`
  String get titleIsRequired {
    return Intl.message(
      'Title is required',
      name: 'titleIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter case description`
  String get enterCaseDescription {
    return Intl.message(
      'Enter case description',
      name: 'enterCaseDescription',
      desc: '',
      args: [],
    );
  }

  /// `Description is required`
  String get descriptionIsRequired {
    return Intl.message(
      'Description is required',
      name: 'descriptionIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Appear in court on`
  String get appearInCourtOn {
    return Intl.message(
      'Appear in court on',
      name: 'appearInCourtOn',
      desc: '',
      args: [],
    );
  }

  /// `Select date`
  String get selectDate {
    return Intl.message('Select date', name: 'selectDate', desc: '', args: []);
  }

  /// `Add New Case`
  String get addNewCase {
    return Intl.message('Add New Case', name: 'addNewCase', desc: '', args: []);
  }

  /// `Enter case name`
  String get enterCaseName {
    return Intl.message(
      'Enter case name',
      name: 'enterCaseName',
      desc: '',
      args: [],
    );
  }

  /// `Case name is required`
  String get caseNameIsRequired {
    return Intl.message(
      'Case name is required',
      name: 'caseNameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `d-m-y`
  String get dateFormatHint {
    return Intl.message('d-m-y', name: 'dateFormatHint', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Please select a client`
  String get pleaseSelectAClient {
    return Intl.message(
      'Please select a client',
      name: 'pleaseSelectAClient',
      desc: '',
      args: [],
    );
  }

  /// `Case created successfully`
  String get caseCreatedSuccessfully {
    return Intl.message(
      'Case created successfully',
      name: 'caseCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Case {id} Information`
  String caseInformation(Object id) {
    return Intl.message(
      'Case $id Information',
      name: 'caseInformation',
      desc: '',
      args: [id],
    );
  }

  /// `Confirm Deletion`
  String get confirmDeletion {
    return Intl.message(
      'Confirm Deletion',
      name: 'confirmDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this case?`
  String get areYouSureYouWantToDeleteThisCase {
    return Intl.message(
      'Are you sure you want to delete this case?',
      name: 'areYouSureYouWantToDeleteThisCase',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this document?`
  String get areYouSureYouWantToDeleteThisDocument {
    return Intl.message(
      'Are you sure you want to delete this document?',
      name: 'areYouSureYouWantToDeleteThisDocument',
      desc: '',
      args: [],
    );
  }

  /// `Case`
  String get caseWord {
    return Intl.message('Case', name: 'caseWord', desc: '', args: []);
  }

  /// `Case name`
  String get caseNameLabel {
    return Intl.message('Case name', name: 'caseNameLabel', desc: '', args: []);
  }

  /// `Description`
  String get descriptionLabel {
    return Intl.message(
      'Description',
      name: 'descriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Client name`
  String get clientNameLabel {
    return Intl.message(
      'Client name',
      name: 'clientNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Appear in court on`
  String get appearInCourtOnLabel {
    return Intl.message(
      'Appear in court on',
      name: 'appearInCourtOnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sessions`
  String get sessions {
    return Intl.message('Sessions', name: 'sessions', desc: '', args: []);
  }

  /// `Session title`
  String get sessionTitle {
    return Intl.message(
      'Session title',
      name: 'sessionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Session {id} Information`
  String sessionInformation(Object id) {
    return Intl.message(
      'Session $id Information',
      name: 'sessionInformation',
      desc: '',
      args: [id],
    );
  }

  /// `Are you sure you want to delete this session?`
  String get areYouSureYouWantToDeleteThisSession {
    return Intl.message(
      'Are you sure you want to delete this session?',
      name: 'areYouSureYouWantToDeleteThisSession',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting session`
  String get errorDeletingSession {
    return Intl.message(
      'Error deleting session',
      name: 'errorDeletingSession',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting case`
  String get errorDeletingCase {
    return Intl.message(
      'Error deleting case',
      name: 'errorDeletingCase',
      desc: '',
      args: [],
    );
  }

  /// `Upload Documents`
  String get uploadDocuments {
    return Intl.message(
      'Upload Documents',
      name: 'uploadDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Select Files`
  String get selectFiles {
    return Intl.message(
      'Select Files',
      name: 'selectFiles',
      desc: '',
      args: [],
    );
  }

  /// `Selected Files: {count}`
  String selectedFilesCount(Object count) {
    return Intl.message(
      'Selected Files: $count',
      name: 'selectedFilesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Store as Group`
  String get storeAsGroup {
    return Intl.message(
      'Store as Group',
      name: 'storeAsGroup',
      desc: '',
      args: [],
    );
  }

  /// `Group Description`
  String get groupDescription {
    return Intl.message(
      'Group Description',
      name: 'groupDescription',
      desc: '',
      args: [],
    );
  }

  /// `Please select files to upload.`
  String get pleaseSelectFilesToUpload {
    return Intl.message(
      'Please select files to upload.',
      name: 'pleaseSelectFilesToUpload',
      desc: '',
      args: [],
    );
  }

  /// `Please select a security level.`
  String get pleaseSelectSecurityLevel {
    return Intl.message(
      'Please select a security level.',
      name: 'pleaseSelectSecurityLevel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a group name.`
  String get pleaseEnterGroupName {
    return Intl.message(
      'Please enter a group name.',
      name: 'pleaseEnterGroupName',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded {count} documents successfully!`
  String uploadSuccessMessage(Object count) {
    return Intl.message(
      'Uploaded $count documents successfully!',
      name: 'uploadSuccessMessage',
      desc: '',
      args: [count],
    );
  }

  /// `Upload failed: {error}`
  String uploadFailed(Object error) {
    return Intl.message(
      'Upload failed: $error',
      name: 'uploadFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Uploading...`
  String get uploading {
    return Intl.message('Uploading...', name: 'uploading', desc: '', args: []);
  }

  /// `Security Level`
  String get securityLevel {
    return Intl.message(
      'Security Level',
      name: 'securityLevel',
      desc: '',
      args: [],
    );
  }

  /// `Remove File`
  String get removeFile {
    return Intl.message('Remove File', name: 'removeFile', desc: '', args: []);
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Messages`
  String get messages {
    return Intl.message('Messages', name: 'messages', desc: '', args: []);
  }

  /// `Error loading messages`
  String get errorLoadingMessages {
    return Intl.message(
      'Error loading messages',
      name: 'errorLoadingMessages',
      desc: '',
      args: [],
    );
  }

  /// `Microphone permission is required.`
  String get microphonePermissionRequired {
    return Intl.message(
      'Microphone permission is required.',
      name: 'microphonePermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Failed to start recording.`
  String get failedToStartRecording {
    return Intl.message(
      'Failed to start recording.',
      name: 'failedToStartRecording',
      desc: '',
      args: [],
    );
  }

  /// `Failed to convert audio to mp3.`
  String get failedToConvertAudioToMp3 {
    return Intl.message(
      'Failed to convert audio to mp3.',
      name: 'failedToConvertAudioToMp3',
      desc: '',
      args: [],
    );
  }

  /// `Empty audio file.`
  String get emptyAudioFile {
    return Intl.message(
      'Empty audio file.',
      name: 'emptyAudioFile',
      desc: '',
      args: [],
    );
  }

  /// `Recording error`
  String get recordingError {
    return Intl.message(
      'Recording error',
      name: 'recordingError',
      desc: '',
      args: [],
    );
  }

  /// `Recording cancelled.`
  String get recordingCancelled {
    return Intl.message(
      'Recording cancelled.',
      name: 'recordingCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Send failed`
  String get sendFailed {
    return Intl.message('Send failed', name: 'sendFailed', desc: '', args: []);
  }

  /// `Microphone and Storage permissions are required.`
  String get microphoneAndStoragePermissionsRequired {
    return Intl.message(
      'Microphone and Storage permissions are required.',
      name: 'microphoneAndStoragePermissionsRequired',
      desc: '',
      args: [],
    );
  }

  /// `File not found.`
  String get fileNotFound {
    return Intl.message(
      'File not found.',
      name: 'fileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Enter message...`
  String get enterMessage {
    return Intl.message(
      'Enter message...',
      name: 'enterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Audio URL is missing.`
  String get audioUrlMissing {
    return Intl.message(
      'Audio URL is missing.',
      name: 'audioUrlMissing',
      desc: '',
      args: [],
    );
  }

  /// `Playback error.`
  String get playbackError {
    return Intl.message(
      'Playback error.',
      name: 'playbackError',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Edit Message`
  String get editMessageTitle {
    return Intl.message(
      'Edit Message',
      name: 'editMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Write new message`
  String get writeNewMessage {
    return Intl.message(
      'Write new message',
      name: 'writeNewMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Failed to edit message`
  String get failedToEditMessage {
    return Intl.message(
      'Failed to edit message',
      name: 'failedToEditMessage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete message`
  String get failedToDeleteMessage {
    return Intl.message(
      'Failed to delete message',
      name: 'failedToDeleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Connection Suggestions`
  String get connectionSuggestions {
    return Intl.message(
      'Connection Suggestions',
      name: 'connectionSuggestions',
      desc: '',
      args: [],
    );
  }

  /// `Connection Requests`
  String get connectionRequests {
    return Intl.message(
      'Connection Requests',
      name: 'connectionRequests',
      desc: '',
      args: [],
    );
  }

  /// `Following ({count})`
  String following(Object count) {
    return Intl.message(
      'Following ($count)',
      name: 'following',
      desc: '',
      args: [count],
    );
  }

  /// `Followers ({count})`
  String followers(Object count) {
    return Intl.message(
      'Followers ($count)',
      name: 'followers',
      desc: '',
      args: [count],
    );
  }

  /// `Received`
  String get received {
    return Intl.message('Received', name: 'received', desc: '', args: []);
  }

  /// `Sent`
  String get sent {
    return Intl.message('Sent', name: 'sent', desc: '', args: []);
  }

  /// `Connection request sent successfully`
  String get connectionRequestSentSuccess {
    return Intl.message(
      'Connection request sent successfully',
      name: 'connectionRequestSentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send connection request: {error}`
  String connectionRequestSentFailure(Object error) {
    return Intl.message(
      'Failed to send connection request: $error',
      name: 'connectionRequestSentFailure',
      desc: '',
      args: [error],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `No Name`
  String get noName {
    return Intl.message('No Name', name: 'noName', desc: '', args: []);
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `ID: {id}`
  String idWithValue(Object id) {
    return Intl.message('ID: $id', name: 'idWithValue', desc: '', args: [id]);
  }

  /// `App Color`
  String get primaryColor {
    return Intl.message('App Color', name: 'primaryColor', desc: '', args: []);
  }

  /// `People must follow you to see them here`
  String get peopleMustFollowYouToSeeThemHere {
    return Intl.message(
      'People must follow you to see them here',
      name: 'peopleMustFollowYouToSeeThemHere',
      desc: '',
      args: [],
    );
  }

  /// `Send Invitations`
  String get sendInvitations {
    return Intl.message(
      'Send Invitations',
      name: 'sendInvitations',
      desc: '',
      args: [],
    );
  }

  /// `Invitation`
  String get invitation {
    return Intl.message('Invitation', name: 'invitation', desc: '', args: []);
  }

  /// `Add More`
  String get addMore {
    return Intl.message('Add More', name: 'addMore', desc: '', args: []);
  }

  /// `Instructions`
  String get instructions {
    return Intl.message(
      'Instructions',
      name: 'instructions',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Clear All`
  String get clearAll {
    return Intl.message('Clear All', name: 'clearAll', desc: '', args: []);
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Enter email addresses and names of people you want to invite to connect with you.`
  String get invitationInstructions {
    return Intl.message(
      'Enter email addresses and names of people you want to invite to connect with you.',
      name: 'invitationInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Custom Message (Optional)`
  String get customMessageOptional {
    return Intl.message(
      'Custom Message (Optional)',
      name: 'customMessageOptional',
      desc: '',
      args: [],
    );
  }

  /// `Add a personal message to your invitation...`
  String get addPersonalMessage {
    return Intl.message(
      'Add a personal message to your invitation...',
      name: 'addPersonalMessage',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message('Full Name', name: 'fullName', desc: '', args: []);
  }

  /// `Failed to send invitations`
  String get failedToSendInvitations {
    return Intl.message(
      'Failed to send invitations',
      name: 'failedToSendInvitations',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Accounts`
  String get assignedAccounts {
    return Intl.message(
      'Assigned Accounts',
      name: 'assignedAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Assign Account`
  String get assignAccount {
    return Intl.message(
      'Assign Account',
      name: 'assignAccount',
      desc: '',
      args: [],
    );
  }

  /// `Search followers`
  String get searchFollowers {
    return Intl.message(
      'Search followers',
      name: 'searchFollowers',
      desc: '',
      args: [],
    );
  }

  /// `Type to search...`
  String get typeToSearch {
    return Intl.message(
      'Type to search...',
      name: 'typeToSearch',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load followers`
  String get failedToLoadFollowers {
    return Intl.message(
      'Failed to load followers',
      name: 'failedToLoadFollowers',
      desc: '',
      args: [],
    );
  }

  /// `No followers available`
  String get noFollowersAvailable {
    return Intl.message(
      'No followers available',
      name: 'noFollowersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `All followers are already assigned`
  String get allFollowersAlreadyAssigned {
    return Intl.message(
      'All followers are already assigned',
      name: 'allFollowersAlreadyAssigned',
      desc: '',
      args: [],
    );
  }

  /// `No followers match your search`
  String get noFollowersMatchSearch {
    return Intl.message(
      'No followers match your search',
      name: 'noFollowersMatchSearch',
      desc: '',
      args: [],
    );
  }

  /// `Assign`
  String get assign {
    return Intl.message('Assign', name: 'assign', desc: '', args: []);
  }

  /// `Account assigned successfully`
  String get accountAssignedSuccessfully {
    return Intl.message(
      'Account assigned successfully',
      name: 'accountAssignedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to assign account`
  String get failedToAssignAccount {
    return Intl.message(
      'Failed to assign account',
      name: 'failedToAssignAccount',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load`
  String get failedToLoad {
    return Intl.message(
      'Failed to load',
      name: 'failedToLoad',
      desc: '',
      args: [],
    );
  }

  /// `No accounts assigned`
  String get noAccountsAssigned {
    return Intl.message(
      'No accounts assigned',
      name: 'noAccountsAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Unknown Account`
  String get unknownAccount {
    return Intl.message(
      'Unknown Account',
      name: 'unknownAccount',
      desc: '',
      args: [],
    );
  }

  /// `Update Role`
  String get updateRole {
    return Intl.message('Update Role', name: 'updateRole', desc: '', args: []);
  }

  /// `Update role for {accountName}`
  String updateRoleFor(Object accountName) {
    return Intl.message(
      'Update role for $accountName',
      name: 'updateRoleFor',
      desc: '',
      args: [accountName],
    );
  }

  /// `Role updated successfully`
  String get roleUpdatedSuccessfully {
    return Intl.message(
      'Role updated successfully',
      name: 'roleUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update role`
  String get failedToUpdateRole {
    return Intl.message(
      'Failed to update role',
      name: 'failedToUpdateRole',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Remove Assignment`
  String get removeAssignment {
    return Intl.message(
      'Remove Assignment',
      name: 'removeAssignment',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove {accountName} from this case?`
  String confirmRemoveAccount(Object accountName) {
    return Intl.message(
      'Are you sure you want to remove $accountName from this case?',
      name: 'confirmRemoveAccount',
      desc: '',
      args: [accountName],
    );
  }

  /// `this account`
  String get thisAccount {
    return Intl.message(
      'this account',
      name: 'thisAccount',
      desc: '',
      args: [],
    );
  }

  /// `Account removed successfully`
  String get accountRemovedSuccessfully {
    return Intl.message(
      'Account removed successfully',
      name: 'accountRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to remove account`
  String get failedToRemoveAccount {
    return Intl.message(
      'Failed to remove account',
      name: 'failedToRemoveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Admin`
  String get admin {
    return Intl.message('Admin', name: 'admin', desc: '', args: []);
  }

  /// `Diamond`
  String get diamond {
    return Intl.message('Diamond', name: 'diamond', desc: '', args: []);
  }

  /// `Gold`
  String get gold {
    return Intl.message('Gold', name: 'gold', desc: '', args: []);
  }

  /// `Silver`
  String get silver {
    return Intl.message('Silver', name: 'silver', desc: '', args: []);
  }

  /// `You are now viewing the workspace of {accountName}`
  String viewingWorkspaceOf(Object accountName) {
    return Intl.message(
      'You are now viewing the workspace of $accountName',
      name: 'viewingWorkspaceOf',
      desc: '',
      args: [accountName],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Switch to Workspace`
  String get switchToWorkspace {
    return Intl.message(
      'Switch to Workspace',
      name: 'switchToWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Document Details`
  String get documentDetails {
    return Intl.message(
      'Document Details',
      name: 'documentDetails',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get errorOccurred {
    return Intl.message(
      'An error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `File Size`
  String get fileSize {
    return Intl.message('File Size', name: 'fileSize', desc: '', args: []);
  }

  /// `Uploaded At`
  String get uploadedAt {
    return Intl.message('Uploaded At', name: 'uploadedAt', desc: '', args: []);
  }

  /// `Context Information`
  String get contextInformation {
    return Intl.message(
      'Context Information',
      name: 'contextInformation',
      desc: '',
      args: [],
    );
  }

  /// `Case`
  String get case_ {
    return Intl.message('Case', name: 'case_', desc: '', args: []);
  }

  /// `Actions`
  String get actions {
    return Intl.message('Actions', name: 'actions', desc: '', args: []);
  }

  /// `Download Complete`
  String get downloadComplete {
    return Intl.message(
      'Download Complete',
      name: 'downloadComplete',
      desc: '',
      args: [],
    );
  }

  /// `Download Failed`
  String get downloadFailed {
    return Intl.message(
      'Download Failed',
      name: 'downloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Update Successful`
  String get updateSuccessful {
    return Intl.message(
      'Update Successful',
      name: 'updateSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Update Failed`
  String get updateFailed {
    return Intl.message(
      'Update Failed',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Delete Successful`
  String get deleteSuccessful {
    return Intl.message(
      'Delete Successful',
      name: 'deleteSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Delete Failed`
  String get deleteFailed {
    return Intl.message(
      'Delete Failed',
      name: 'deleteFailed',
      desc: '',
      args: [],
    );
  }

  /// `Move to Group`
  String get moveToGroup {
    return Intl.message(
      'Move to Group',
      name: 'moveToGroup',
      desc: '',
      args: [],
    );
  }

  /// `Select Group`
  String get selectGroup {
    return Intl.message(
      'Select Group',
      name: 'selectGroup',
      desc: '',
      args: [],
    );
  }

  /// `Document moved successfully`
  String get moveSuccessful {
    return Intl.message(
      'Document moved successfully',
      name: 'moveSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Failed to move document`
  String get moveFailed {
    return Intl.message(
      'Failed to move document',
      name: 'moveFailed',
      desc: '',
      args: [],
    );
  }

  /// `No groups available`
  String get noGroupsAvailable {
    return Intl.message(
      'No groups available',
      name: 'noGroupsAvailable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
