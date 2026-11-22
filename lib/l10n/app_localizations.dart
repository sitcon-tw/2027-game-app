import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SITCON'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get noRecords;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @packs.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get packs;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @handCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get handCards;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @planets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get planets;

  /// No description provided for @checkpoints.
  ///
  /// In en, this message translates to:
  /// **'Checkpoints'**
  String get checkpoints;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get games;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'My card'**
  String get profile;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChinese;

  /// No description provided for @categoryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get categoryTechnology;

  /// No description provided for @categoryFaction.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get categoryFaction;

  /// No description provided for @categoryInterest.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get categoryInterest;

  /// No description provided for @cardScissors.
  ///
  /// In en, this message translates to:
  /// **'Scissors'**
  String get cardScissors;

  /// No description provided for @cardRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get cardRock;

  /// No description provided for @cardPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get cardPaper;

  /// No description provided for @cardWild.
  ///
  /// In en, this message translates to:
  /// **'Wild'**
  String get cardWild;

  /// No description provided for @seriesSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get seriesSun;

  /// No description provided for @seriesEarth.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get seriesEarth;

  /// No description provided for @seriesMercury.
  ///
  /// In en, this message translates to:
  /// **'Mercury'**
  String get seriesMercury;

  /// No description provided for @seriesMars.
  ///
  /// In en, this message translates to:
  /// **'Mars'**
  String get seriesMars;

  /// No description provided for @seriesSaturn.
  ///
  /// In en, this message translates to:
  /// **'Saturn'**
  String get seriesSaturn;

  /// No description provided for @seriesMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get seriesMoon;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorLightBlue.
  ///
  /// In en, this message translates to:
  /// **'Light blue'**
  String get colorLightBlue;

  /// No description provided for @colorDarkBlue.
  ///
  /// In en, this message translates to:
  /// **'Dark blue'**
  String get colorDarkBlue;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get win;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @baseCard.
  ///
  /// In en, this message translates to:
  /// **'Default card'**
  String get baseCard;

  /// No description provided for @notAcquired.
  ///
  /// In en, this message translates to:
  /// **'Not collected'**
  String get notAcquired;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @attendee.
  ///
  /// In en, this message translates to:
  /// **'Attendee'**
  String get attendee;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @sponsor.
  ///
  /// In en, this message translates to:
  /// **'Sponsor'**
  String get sponsor;

  /// No description provided for @tagSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get tagSecurity;

  /// No description provided for @tagFrontend.
  ///
  /// In en, this message translates to:
  /// **'Frontend'**
  String get tagFrontend;

  /// No description provided for @tagBackend.
  ///
  /// In en, this message translates to:
  /// **'Backend'**
  String get tagBackend;

  /// No description provided for @tagAppDevelopment.
  ///
  /// In en, this message translates to:
  /// **'App development'**
  String get tagAppDevelopment;

  /// No description provided for @tagGameDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Game development'**
  String get tagGameDevelopment;

  /// No description provided for @tagIot.
  ///
  /// In en, this message translates to:
  /// **'IoT'**
  String get tagIot;

  /// No description provided for @tagBlockchain.
  ///
  /// In en, this message translates to:
  /// **'Blockchain'**
  String get tagBlockchain;

  /// No description provided for @tagCompetitiveProgramming.
  ///
  /// In en, this message translates to:
  /// **'Competitive programming'**
  String get tagCompetitiveProgramming;

  /// No description provided for @tagProgrammingLanguages.
  ///
  /// In en, this message translates to:
  /// **'Programming languages'**
  String get tagProgrammingLanguages;

  /// No description provided for @tagVim.
  ///
  /// In en, this message translates to:
  /// **'Vim'**
  String get tagVim;

  /// No description provided for @tagVsCode.
  ///
  /// In en, this message translates to:
  /// **'VS Code'**
  String get tagVsCode;

  /// No description provided for @tagTabs.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get tagTabs;

  /// No description provided for @tagSpaces.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get tagSpaces;

  /// No description provided for @tagDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get tagDarkMode;

  /// No description provided for @tagCats.
  ///
  /// In en, this message translates to:
  /// **'Cats'**
  String get tagCats;

  /// No description provided for @tagDogs.
  ///
  /// In en, this message translates to:
  /// **'Dogs'**
  String get tagDogs;

  /// No description provided for @tagUnmixedCurry.
  ///
  /// In en, this message translates to:
  /// **'Unmixed curry'**
  String get tagUnmixedCurry;

  /// No description provided for @tagMixedCurry.
  ///
  /// In en, this message translates to:
  /// **'Mixed curry'**
  String get tagMixedCurry;

  /// No description provided for @tagNoCilantro.
  ///
  /// In en, this message translates to:
  /// **'No cilantro'**
  String get tagNoCilantro;

  /// No description provided for @tagTaroHotpot.
  ///
  /// In en, this message translates to:
  /// **'Taro in hotpot'**
  String get tagTaroHotpot;

  /// No description provided for @tagNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Night owl'**
  String get tagNightOwl;

  /// No description provided for @tagCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get tagCoffee;

  /// No description provided for @tagBubbleTea.
  ///
  /// In en, this message translates to:
  /// **'Bubble tea'**
  String get tagBubbleTea;

  /// No description provided for @tagAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get tagAnime;

  /// No description provided for @tagVideoGames.
  ///
  /// In en, this message translates to:
  /// **'Video games'**
  String get tagVideoGames;

  /// No description provided for @tagBoardGames.
  ///
  /// In en, this message translates to:
  /// **'Board games'**
  String get tagBoardGames;

  /// No description provided for @tagSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get tagSports;

  /// No description provided for @tagMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get tagMusic;

  /// No description provided for @tagPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get tagPhotography;

  /// No description provided for @tagMaker.
  ///
  /// In en, this message translates to:
  /// **'Maker'**
  String get tagMaker;

  /// No description provided for @areaSessions.
  ///
  /// In en, this message translates to:
  /// **'Session halls'**
  String get areaSessions;

  /// No description provided for @areaWhiteboard.
  ///
  /// In en, this message translates to:
  /// **'Whiteboard challenge'**
  String get areaWhiteboard;

  /// No description provided for @areaSponsors.
  ///
  /// In en, this message translates to:
  /// **'Sponsor booths'**
  String get areaSponsors;

  /// No description provided for @areaDemos.
  ///
  /// In en, this message translates to:
  /// **'Demo booths'**
  String get areaDemos;

  /// No description provided for @areaBooths.
  ///
  /// In en, this message translates to:
  /// **'Booth area'**
  String get areaBooths;

  /// No description provided for @areaWelcome.
  ///
  /// In en, this message translates to:
  /// **'1F Welcoming Zone'**
  String get areaWelcome;

  /// No description provided for @areaDining.
  ///
  /// In en, this message translates to:
  /// **'Dining area'**
  String get areaDining;

  /// No description provided for @areaStairs.
  ///
  /// In en, this message translates to:
  /// **'Stairwell'**
  String get areaStairs;

  /// No description provided for @areaEventTeam.
  ///
  /// In en, this message translates to:
  /// **'Event team'**
  String get areaEventTeam;

  /// No description provided for @areaLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited edition'**
  String get areaLimited;

  /// No description provided for @areaMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile checkpoints'**
  String get areaMobile;

  /// No description provided for @boothCommunity.
  ///
  /// In en, this message translates to:
  /// **'SITCON community'**
  String get boothCommunity;

  /// No description provided for @boothOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open-source demo'**
  String get boothOpenSource;

  /// No description provided for @boothEvent.
  ///
  /// In en, this message translates to:
  /// **'Event team'**
  String get boothEvent;

  /// No description provided for @stationHelpDesk.
  ///
  /// In en, this message translates to:
  /// **'Help desk'**
  String get stationHelpDesk;

  /// No description provided for @stationRoaming.
  ///
  /// In en, this message translates to:
  /// **'Roaming station'**
  String get stationRoaming;

  /// No description provided for @stationClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed station'**
  String get stationClosed;

  /// No description provided for @stationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Out-of-stock station'**
  String get stationEmpty;

  /// No description provided for @fixturePlayer.
  ///
  /// In en, this message translates to:
  /// **'Demo {number}'**
  String fixturePlayer(int number);

  /// No description provided for @domainUnknownParameter.
  ///
  /// In en, this message translates to:
  /// **'Unknown game parameter.'**
  String get domainUnknownParameter;

  /// No description provided for @domainInvalidStation.
  ///
  /// In en, this message translates to:
  /// **'Invalid station settings.'**
  String get domainInvalidStation;

  /// No description provided for @domainInvalidUid.
  ///
  /// In en, this message translates to:
  /// **'Use a 7-byte NTAG UID (14 hexadecimal digits).'**
  String get domainInvalidUid;

  /// No description provided for @domainUnsupportedSave.
  ///
  /// In en, this message translates to:
  /// **'Saved data version is unsupported. Your progress was kept.'**
  String get domainUnsupportedSave;

  /// No description provided for @domainCheckInRequired.
  ///
  /// In en, this message translates to:
  /// **'Bind your badge and choose your hashtags first.'**
  String get domainCheckInRequired;

  /// No description provided for @domainInsufficientCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins.'**
  String get domainInsufficientCoins;

  /// No description provided for @domainPlayerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Player not found.'**
  String get domainPlayerNotFound;

  /// No description provided for @domainInvalidTags.
  ///
  /// In en, this message translates to:
  /// **'Hashtags are duplicated or invalid.'**
  String get domainInvalidTags;

  /// No description provided for @domainBadgePhase.
  ///
  /// In en, this message translates to:
  /// **'Badges can only be bound during the event.'**
  String get domainBadgePhase;

  /// No description provided for @domainBadgeTaken.
  ///
  /// In en, this message translates to:
  /// **'This badge is already bound to another player.'**
  String get domainBadgeTaken;

  /// No description provided for @domainNotBadge.
  ///
  /// In en, this message translates to:
  /// **'Scan your own badge.'**
  String get domainNotBadge;

  /// No description provided for @domainBadgeLocked.
  ///
  /// In en, this message translates to:
  /// **'Your badge is already bound.'**
  String get domainBadgeLocked;

  /// No description provided for @domainNicknameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a nickname.'**
  String get domainNicknameRequired;

  /// No description provided for @domainContactTooLong.
  ///
  /// In en, this message translates to:
  /// **'Contact details must be at most 1,000 characters.'**
  String get domainContactTooLong;

  /// No description provided for @domainEarlyPhase.
  ///
  /// In en, this message translates to:
  /// **'Register for the early reward before the event.'**
  String get domainEarlyPhase;

  /// No description provided for @domainScanIdRequired.
  ///
  /// In en, this message translates to:
  /// **'A scan ID is required.'**
  String get domainScanIdRequired;

  /// No description provided for @domainScanIdConflict.
  ///
  /// In en, this message translates to:
  /// **'This scan ID belongs to another tag.'**
  String get domainScanIdConflict;

  /// No description provided for @domainScanFirst.
  ///
  /// In en, this message translates to:
  /// **'Scan the other player’s badge first.'**
  String get domainScanFirst;

  /// No description provided for @domainOpponentCardsLow.
  ///
  /// In en, this message translates to:
  /// **'Your opponent needs at least 3 cards.'**
  String get domainOpponentCardsLow;

  /// No description provided for @domainFriendRequestExpired.
  ///
  /// In en, this message translates to:
  /// **'Friend request expired. Scan and invite again.'**
  String get domainFriendRequestExpired;

  /// No description provided for @domainBattleCannotCancel.
  ///
  /// In en, this message translates to:
  /// **'A started battle cannot be cancelled. Timed-out turns play automatically.'**
  String get domainBattleCannotCancel;

  /// No description provided for @domainNoBattle.
  ///
  /// In en, this message translates to:
  /// **'No battle is in progress.'**
  String get domainNoBattle;

  /// No description provided for @domainCardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'You do not have that card.'**
  String get domainCardUnavailable;

  /// No description provided for @domainWildChoiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose scissors, rock or paper for the wild card.'**
  String get domainWildChoiceRequired;

  /// No description provided for @domainNormalCardFixed.
  ///
  /// In en, this message translates to:
  /// **'Only a wild card can change its hand.'**
  String get domainNormalCardFixed;

  /// No description provided for @domainBattleCardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Battle cards are depleted.'**
  String get domainBattleCardsEmpty;

  /// No description provided for @domainInvalidCardCount.
  ///
  /// In en, this message translates to:
  /// **'Invalid card inventory.'**
  String get domainInvalidCardCount;

  /// No description provided for @domainPeekTiming.
  ///
  /// In en, this message translates to:
  /// **'Use a peek card before playing your turn.'**
  String get domainPeekTiming;

  /// No description provided for @domainPeekUsed.
  ///
  /// In en, this message translates to:
  /// **'A peek card can only be used once per battle.'**
  String get domainPeekUsed;

  /// No description provided for @domainPeekEmpty.
  ///
  /// In en, this message translates to:
  /// **'No peek cards.'**
  String get domainPeekEmpty;

  /// No description provided for @domainPacksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No packs to open.'**
  String get domainPacksEmpty;

  /// No description provided for @domainPlanetLocked.
  ///
  /// In en, this message translates to:
  /// **'Choose an unlocked planet.'**
  String get domainPlanetLocked;

  /// No description provided for @domainStyleLocked.
  ///
  /// In en, this message translates to:
  /// **'This card style is locked.'**
  String get domainStyleLocked;

  /// No description provided for @domainHintsExhausted.
  ///
  /// In en, this message translates to:
  /// **'No new checkpoint hints are available.'**
  String get domainHintsExhausted;

  /// No description provided for @domainStaffRequired.
  ///
  /// In en, this message translates to:
  /// **'Staff permission is required.'**
  String get domainStaffRequired;

  /// No description provided for @domainStationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Station not found.'**
  String get domainStationNotFound;

  /// No description provided for @domainUidReserved.
  ///
  /// In en, this message translates to:
  /// **'This UID is already assigned.'**
  String get domainUidReserved;

  /// No description provided for @domainAgendaRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an agenda slot.'**
  String get domainAgendaRequired;

  /// No description provided for @domainBoothNotFound.
  ///
  /// In en, this message translates to:
  /// **'Booth not found.'**
  String get domainBoothNotFound;

  /// No description provided for @domainInvalidDelivery.
  ///
  /// In en, this message translates to:
  /// **'Enter a delivery ID, positive pack count and reason.'**
  String get domainInvalidDelivery;

  /// No description provided for @domainDeliveryConflict.
  ///
  /// In en, this message translates to:
  /// **'This delivery ID already has different content.'**
  String get domainDeliveryConflict;

  /// No description provided for @domainBattleBusy.
  ///
  /// In en, this message translates to:
  /// **'Finish your current battle or invitation first.'**
  String get domainBattleBusy;

  /// No description provided for @domainBattleCooldown.
  ///
  /// In en, this message translates to:
  /// **'Battle cooldown is active.'**
  String get domainBattleCooldown;

  /// No description provided for @domainCardsLow.
  ///
  /// In en, this message translates to:
  /// **'You need at least 3 cards.'**
  String get domainCardsLow;

  /// No description provided for @domainApiNotFound.
  ///
  /// In en, this message translates to:
  /// **'API not found.'**
  String get domainApiNotFound;

  /// No description provided for @domainApiCorsDenied.
  ///
  /// In en, this message translates to:
  /// **'Cross-origin request denied.'**
  String get domainApiCorsDenied;

  /// No description provided for @domainApiInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON.'**
  String get domainApiInvalidJson;

  /// No description provided for @domainApiRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out.'**
  String get domainApiRequestTimeout;

  /// No description provided for @domainApiInternalError.
  ///
  /// In en, this message translates to:
  /// **'The server could not complete the request.'**
  String get domainApiInternalError;

  /// No description provided for @domainApiHostDenied.
  ///
  /// In en, this message translates to:
  /// **'Only the local server host is allowed.'**
  String get domainApiHostDenied;

  /// No description provided for @domainApiNetworkDenied.
  ///
  /// In en, this message translates to:
  /// **'This network cannot access the test API.'**
  String get domainApiNetworkDenied;

  /// No description provided for @domainApiOriginDenied.
  ///
  /// In en, this message translates to:
  /// **'This website cannot access the API.'**
  String get domainApiOriginDenied;

  /// No description provided for @domainApiClosing.
  ///
  /// In en, this message translates to:
  /// **'The server is stopping.'**
  String get domainApiClosing;

  /// No description provided for @domainApiMethodNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'HTTP method not supported.'**
  String get domainApiMethodNotAllowed;

  /// No description provided for @domainApiJsonRequired.
  ///
  /// In en, this message translates to:
  /// **'Send application/json with UTF-8 encoding.'**
  String get domainApiJsonRequired;

  /// No description provided for @domainApiBodyTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Request body exceeds 128 KiB.'**
  String get domainApiBodyTooLarge;

  /// No description provided for @domainApiInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'Send a JSON object.'**
  String get domainApiInvalidBody;

  /// No description provided for @domainApiPlayerActionForbidden.
  ///
  /// In en, this message translates to:
  /// **'Player actions cannot use administrator or cheat controls.'**
  String get domainApiPlayerActionForbidden;

  /// No description provided for @domainApiPlayerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Select an initialized player.'**
  String get domainApiPlayerNotFound;

  /// No description provided for @domainApiUnknownAdminAction.
  ///
  /// In en, this message translates to:
  /// **'Unknown administrator action.'**
  String get domainApiUnknownAdminAction;

  /// No description provided for @domainInvalidTagList.
  ///
  /// In en, this message translates to:
  /// **'Choose at most 9 hashtags.'**
  String get domainInvalidTagList;

  /// No description provided for @domainInvalidPhase.
  ///
  /// In en, this message translates to:
  /// **'Invalid event phase.'**
  String get domainInvalidPhase;

  /// No description provided for @domainEventInactive.
  ///
  /// In en, this message translates to:
  /// **'The event is not active.'**
  String get domainEventInactive;

  /// No description provided for @domainInvalidArgument.
  ///
  /// In en, this message translates to:
  /// **'Invalid request arguments.'**
  String get domainInvalidArgument;

  /// No description provided for @domainInvalidBindAddress.
  ///
  /// In en, this message translates to:
  /// **'The test server only accepts a loopback address.'**
  String get domainInvalidBindAddress;

  /// No description provided for @domainEventBefore.
  ///
  /// In en, this message translates to:
  /// **'The event has not started.'**
  String get domainEventBefore;

  /// No description provided for @domainEventEnded.
  ///
  /// In en, this message translates to:
  /// **'The event has ended.'**
  String get domainEventEnded;

  /// No description provided for @domainParameterRange.
  ///
  /// In en, this message translates to:
  /// **'Parameter {parameter} is out of range.'**
  String domainParameterRange(String parameter);

  /// No description provided for @domainCategoryTagCount.
  ///
  /// In en, this message translates to:
  /// **'Choose 1–3 hashtags in {category}.'**
  String domainCategoryTagCount(String category);

  /// No description provided for @domainOpposingTags.
  ///
  /// In en, this message translates to:
  /// **'Choose either {first} or {second}.'**
  String domainOpposingTags(String first, String second);

  /// No description provided for @domainCoinsShort.
  ///
  /// In en, this message translates to:
  /// **'{amount, plural, one{You need 1 more coin.} other{You need {amount} more coins.}}'**
  String domainCoinsShort(int amount);

  /// No description provided for @domainAllPlanetsOwned.
  ///
  /// In en, this message translates to:
  /// **'All 42 planets are collected.'**
  String get domainAllPlanetsOwned;

  /// No description provided for @domainSeriesOwned.
  ///
  /// In en, this message translates to:
  /// **'This series is complete.'**
  String get domainSeriesOwned;

  /// No description provided for @domainHintsEmpty.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Complete 1 battle or booth task to earn a hint.} other{Complete {count} battles or booth tasks to earn a hint.}}'**
  String domainHintsEmpty(int count);

  /// No description provided for @domainUnknownRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking not supported.'**
  String get domainUnknownRanking;

  /// No description provided for @domainCheckpointHint.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint {number}: near {area}.'**
  String domainCheckpointHint(int number, String area);

  /// No description provided for @domainCheckpointFound.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint {number}: +1 {card}.'**
  String domainCheckpointFound(int number, String card);

  /// No description provided for @domainCheckpointRepeat.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint {number} already collected.'**
  String domainCheckpointRepeat(int number);

  /// No description provided for @domainStationClosed.
  ///
  /// In en, this message translates to:
  /// **'This station is closed.'**
  String get domainStationClosed;

  /// No description provided for @domainStationLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached this station’s claim limit.'**
  String get domainStationLimit;

  /// No description provided for @domainStationEmpty.
  ///
  /// In en, this message translates to:
  /// **'This station is out of packs.'**
  String get domainStationEmpty;

  /// No description provided for @domainStationPacks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Received 1 pack.} other{Received {count} packs.}}'**
  String domainStationPacks(int count);

  /// No description provided for @domainInvalidGrant.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive whole number.'**
  String get domainInvalidGrant;

  /// No description provided for @domainWireVersion.
  ///
  /// In en, this message translates to:
  /// **'Update the app to connect to this server.'**
  String get domainWireVersion;

  /// No description provided for @domainInvalidApiOrigin.
  ///
  /// In en, this message translates to:
  /// **'Invalid server address.'**
  String get domainInvalidApiOrigin;

  /// No description provided for @domainDeviceSessionRequired.
  ///
  /// In en, this message translates to:
  /// **'This device is signed out. Use a transfer code from the active device.'**
  String get domainDeviceSessionRequired;

  /// No description provided for @domainDeviceTransferInvalid.
  ///
  /// In en, this message translates to:
  /// **'The transfer code is invalid or expired. Get a new one from the active device.'**
  String get domainDeviceTransferInvalid;

  /// No description provided for @domainDeviceSessionConflict.
  ///
  /// In en, this message translates to:
  /// **'This device connection conflicts with an existing session.'**
  String get domainDeviceSessionConflict;

  /// No description provided for @domainDeviceSecureOriginRequired.
  ///
  /// In en, this message translates to:
  /// **'Use HTTPS to connect. HTTP is allowed only for loopback testing.'**
  String get domainDeviceSecureOriginRequired;

  /// No description provided for @domainDeviceStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Secure device storage is unavailable. Try again after unlocking the device.'**
  String get domainDeviceStorageUnavailable;

  /// No description provided for @domainNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected to the server.'**
  String get domainNotConnected;

  /// No description provided for @domainServiceDisposed.
  ///
  /// In en, this message translates to:
  /// **'This session is closed.'**
  String get domainServiceDisposed;

  /// No description provided for @domainNetworkTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Try again.'**
  String get domainNetworkTimeout;

  /// No description provided for @domainNetworkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check your connection.'**
  String get domainNetworkUnavailable;

  /// No description provided for @domainInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response.'**
  String get domainInvalidResponse;

  /// No description provided for @domainServerFailure.
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed. Try again.'**
  String get domainServerFailure;

  /// No description provided for @domainCorruptSave.
  ///
  /// In en, this message translates to:
  /// **'Saved data is damaged or unsupported. Your file and progress were kept.'**
  String get domainCorruptSave;

  /// No description provided for @domainStorageFailure.
  ///
  /// In en, this message translates to:
  /// **'Cannot read or save data. Your last saved progress was kept.'**
  String get domainStorageFailure;

  /// No description provided for @domainNfcUnsupported.
  ///
  /// In en, this message translates to:
  /// **'NFC requires an iOS or Android phone.'**
  String get domainNfcUnsupported;

  /// No description provided for @domainNfcInterrupted.
  ///
  /// In en, this message translates to:
  /// **'NFC was interrupted. Scan again.'**
  String get domainNfcInterrupted;

  /// No description provided for @domainNfcReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the tag. Scan again.'**
  String get domainNfcReadFailed;

  /// No description provided for @domainNfcDisposed.
  ///
  /// In en, this message translates to:
  /// **'NFC reader is closed.'**
  String get domainNfcDisposed;

  /// No description provided for @domainNfcBusy.
  ///
  /// In en, this message translates to:
  /// **'Another NFC scan is in progress.'**
  String get domainNfcBusy;

  /// No description provided for @domainNfcStopFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not stop NFC. Try again.'**
  String get domainNfcStopFailed;

  /// No description provided for @domainNfcDisabled.
  ///
  /// In en, this message translates to:
  /// **'NFC is unavailable or turned off.'**
  String get domainNfcDisabled;

  /// No description provided for @domainNfcInvalidTag.
  ///
  /// In en, this message translates to:
  /// **'Scan an NTAG213, 215 or 216 tag.'**
  String get domainNfcInvalidTag;

  /// No description provided for @domainNfcTimeout.
  ///
  /// In en, this message translates to:
  /// **'Scan timed out. Try again.'**
  String get domainNfcTimeout;

  /// No description provided for @domainNfcStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start NFC. Try again.'**
  String get domainNfcStartFailed;

  /// No description provided for @domainShareNotReady.
  ///
  /// In en, this message translates to:
  /// **'Share image is not ready. Try again.'**
  String get domainShareNotReady;

  /// No description provided for @domainShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the share image.'**
  String get domainShareFailed;

  /// No description provided for @domainInvalidString.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid {field} (up to {max} characters).'**
  String domainInvalidString(String field, int max);

  /// No description provided for @domainInvalidInteger.
  ///
  /// In en, this message translates to:
  /// **'{field} must be a whole number from {min} to {max}.'**
  String domainInvalidInteger(String field, int min, int max);

  /// No description provided for @domainInvalidBoolean.
  ///
  /// In en, this message translates to:
  /// **'Invalid value for {field}.'**
  String domainInvalidBoolean(String field);

  /// No description provided for @domainUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get domainUnknownError;

  /// No description provided for @domainScanSelf.
  ///
  /// In en, this message translates to:
  /// **'Your card'**
  String get domainScanSelf;

  /// No description provided for @domainScanPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add friend or battle'**
  String get domainScanPlayer;

  /// No description provided for @domainScanCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint scanned'**
  String get domainScanCheckpoint;

  /// No description provided for @domainScanBooth.
  ///
  /// In en, this message translates to:
  /// **'Booth scanned'**
  String get domainScanBooth;

  /// No description provided for @domainScanStation.
  ///
  /// In en, this message translates to:
  /// **'Station scanned'**
  String get domainScanStation;

  /// No description provided for @domainScanUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown NTAG'**
  String get domainScanUnknown;

  /// No description provided for @domainScanBindStation.
  ///
  /// In en, this message translates to:
  /// **'Unassigned tag. Choose a station.'**
  String get domainScanBindStation;

  /// No description provided for @domainLedgerAdminParameters.
  ///
  /// In en, this message translates to:
  /// **'Game settings updated'**
  String get domainLedgerAdminParameters;

  /// No description provided for @domainLedgerAdminStation.
  ///
  /// In en, this message translates to:
  /// **'Station updated'**
  String get domainLedgerAdminStation;

  /// No description provided for @domainLedgerBadgeBind.
  ///
  /// In en, this message translates to:
  /// **'Badge bound'**
  String get domainLedgerBadgeBind;

  /// No description provided for @domainLedgerProfileEdit.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get domainLedgerProfileEdit;

  /// No description provided for @domainLedgerCheckin.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get domainLedgerCheckin;

  /// No description provided for @domainLedgerEarlyUnlock.
  ///
  /// In en, this message translates to:
  /// **'Early reward unlocked'**
  String get domainLedgerEarlyUnlock;

  /// No description provided for @domainLedgerEarlyClaim.
  ///
  /// In en, this message translates to:
  /// **'Early reward registered'**
  String get domainLedgerEarlyClaim;

  /// No description provided for @domainLedgerScanSelf.
  ///
  /// In en, this message translates to:
  /// **'Own badge scanned'**
  String get domainLedgerScanSelf;

  /// No description provided for @domainLedgerScanPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player scanned'**
  String get domainLedgerScanPlayer;

  /// No description provided for @domainLedgerScanCheckpointRepeat.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint already collected'**
  String get domainLedgerScanCheckpointRepeat;

  /// No description provided for @domainLedgerScanCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint collected'**
  String get domainLedgerScanCheckpoint;

  /// No description provided for @domainLedgerScanBooth.
  ///
  /// In en, this message translates to:
  /// **'Booth visited'**
  String get domainLedgerScanBooth;

  /// No description provided for @domainLedgerScanStation.
  ///
  /// In en, this message translates to:
  /// **'Station scanned'**
  String get domainLedgerScanStation;

  /// No description provided for @domainLedgerScanUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown tag scanned'**
  String get domainLedgerScanUnknown;

  /// No description provided for @domainLedgerFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend invited'**
  String get domainLedgerFriendRequest;

  /// No description provided for @domainLedgerBattleAccept.
  ///
  /// In en, this message translates to:
  /// **'Battle accepted'**
  String get domainLedgerBattleAccept;

  /// No description provided for @domainLedgerFriendAdd.
  ///
  /// In en, this message translates to:
  /// **'Friend added'**
  String get domainLedgerFriendAdd;

  /// No description provided for @domainLedgerMissionComplete.
  ///
  /// In en, this message translates to:
  /// **'Hashtag task completed'**
  String get domainLedgerMissionComplete;

  /// No description provided for @domainLedgerBattleInvite.
  ///
  /// In en, this message translates to:
  /// **'Battle invited'**
  String get domainLedgerBattleInvite;

  /// No description provided for @domainLedgerBattleCancel.
  ///
  /// In en, this message translates to:
  /// **'Battle invitation cancelled'**
  String get domainLedgerBattleCancel;

  /// No description provided for @domainLedgerBattleRound.
  ///
  /// In en, this message translates to:
  /// **'Battle round played'**
  String get domainLedgerBattleRound;

  /// No description provided for @domainLedgerBattleSettle.
  ///
  /// In en, this message translates to:
  /// **'Battle completed'**
  String get domainLedgerBattleSettle;

  /// No description provided for @domainLedgerBattlePeek.
  ///
  /// In en, this message translates to:
  /// **'Peek card used'**
  String get domainLedgerBattlePeek;

  /// No description provided for @domainLedgerBattleInviteExpired.
  ///
  /// In en, this message translates to:
  /// **'Battle invitation expired'**
  String get domainLedgerBattleInviteExpired;

  /// No description provided for @domainLedgerPackOpen.
  ///
  /// In en, this message translates to:
  /// **'Packs opened'**
  String get domainLedgerPackOpen;

  /// No description provided for @domainLedgerEggBuy.
  ///
  /// In en, this message translates to:
  /// **'Planet hatched'**
  String get domainLedgerEggBuy;

  /// No description provided for @domainLedgerSeriesComplete.
  ///
  /// In en, this message translates to:
  /// **'Planet series completed'**
  String get domainLedgerSeriesComplete;

  /// No description provided for @domainLedgerAppearanceEdit.
  ///
  /// In en, this message translates to:
  /// **'Appearance updated'**
  String get domainLedgerAppearanceEdit;

  /// No description provided for @domainLedgerHintEarn.
  ///
  /// In en, this message translates to:
  /// **'Hint earned'**
  String get domainLedgerHintEarn;

  /// No description provided for @domainLedgerHintRedeem.
  ///
  /// In en, this message translates to:
  /// **'Hint redeemed'**
  String get domainLedgerHintRedeem;

  /// No description provided for @domainLedgerStationBind.
  ///
  /// In en, this message translates to:
  /// **'Station tag bound'**
  String get domainLedgerStationBind;

  /// No description provided for @domainLedgerMockPhase.
  ///
  /// In en, this message translates to:
  /// **'Event phase changed'**
  String get domainLedgerMockPhase;

  /// No description provided for @domainLedgerMockStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff permission changed'**
  String get domainLedgerMockStaff;

  /// No description provided for @domainLedgerMockAgenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda packs received'**
  String get domainLedgerMockAgenda;

  /// No description provided for @domainLedgerMockBoothComplete.
  ///
  /// In en, this message translates to:
  /// **'Booth task completed'**
  String get domainLedgerMockBoothComplete;

  /// No description provided for @domainLedgerMockRemote.
  ///
  /// In en, this message translates to:
  /// **'Packs received'**
  String get domainLedgerMockRemote;

  /// No description provided for @domainLedgerMockPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo reward received'**
  String get domainLedgerMockPhoto;

  /// No description provided for @domainLedgerCheatCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins added'**
  String get domainLedgerCheatCoins;

  /// No description provided for @domainNfcPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone near an NTAG badge or checkpoint.'**
  String get domainNfcPrompt;

  /// No description provided for @domainLedgerCoins.
  ///
  /// In en, this message translates to:
  /// **'{label} · Coins {delta}'**
  String domainLedgerCoins(String label, String delta);

  /// No description provided for @domainPacksAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Added 1 pack} other{Added {count} packs}}'**
  String domainPacksAdded(int count);

  /// No description provided for @domainFieldAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get domainFieldAction;

  /// No description provided for @domainFieldContact.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get domainFieldContact;

  /// No description provided for @domainFieldNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get domainFieldNickname;

  /// No description provided for @domainFieldUid.
  ///
  /// In en, this message translates to:
  /// **'Tag UID'**
  String get domainFieldUid;

  /// No description provided for @domainFieldScanId.
  ///
  /// In en, this message translates to:
  /// **'Scan ID'**
  String get domainFieldScanId;

  /// No description provided for @domainFieldPlayerId.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get domainFieldPlayerId;

  /// No description provided for @domainFieldCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get domainFieldCard;

  /// No description provided for @domainFieldAsCard.
  ///
  /// In en, this message translates to:
  /// **'Wild card choice'**
  String get domainFieldAsCard;

  /// No description provided for @domainFieldAll.
  ///
  /// In en, this message translates to:
  /// **'Open all'**
  String get domainFieldAll;

  /// No description provided for @domainFieldSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get domainFieldSeries;

  /// No description provided for @domainFieldPlanet.
  ///
  /// In en, this message translates to:
  /// **'Planet'**
  String get domainFieldPlanet;

  /// No description provided for @domainFieldStyle.
  ///
  /// In en, this message translates to:
  /// **'Card style'**
  String get domainFieldStyle;

  /// No description provided for @domainFieldStationId.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get domainFieldStationId;

  /// No description provided for @domainFieldPhase.
  ///
  /// In en, this message translates to:
  /// **'Event phase'**
  String get domainFieldPhase;

  /// No description provided for @domainFieldSlot.
  ///
  /// In en, this message translates to:
  /// **'Agenda slot'**
  String get domainFieldSlot;

  /// No description provided for @domainFieldDeliveryId.
  ///
  /// In en, this message translates to:
  /// **'Delivery ID'**
  String get domainFieldDeliveryId;

  /// No description provided for @domainFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get domainFieldAmount;

  /// No description provided for @domainFieldReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get domainFieldReason;

  /// No description provided for @domainFieldEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get domainFieldEnabled;

  /// No description provided for @domainFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get domainFieldName;

  /// No description provided for @domainFieldPacks.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get domainFieldPacks;

  /// No description provided for @domainFieldLimit.
  ///
  /// In en, this message translates to:
  /// **'Claim limit'**
  String get domainFieldLimit;

  /// No description provided for @domainFieldRemaining.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get domainFieldRemaining;

  /// No description provided for @domainFieldOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get domainFieldOpen;

  /// No description provided for @domainFieldRandomEggPrice.
  ///
  /// In en, this message translates to:
  /// **'Random egg price'**
  String get domainFieldRandomEggPrice;

  /// No description provided for @domainFieldSeriesEggPrice.
  ///
  /// In en, this message translates to:
  /// **'Series egg price'**
  String get domainFieldSeriesEggPrice;

  /// No description provided for @domainFieldHintThreshold.
  ///
  /// In en, this message translates to:
  /// **'Hint threshold'**
  String get domainFieldHintThreshold;

  /// No description provided for @domainFieldMissionCoins.
  ///
  /// In en, this message translates to:
  /// **'Task coins'**
  String get domainFieldMissionCoins;

  /// No description provided for @domainFieldAgendaPacks.
  ///
  /// In en, this message translates to:
  /// **'Agenda packs'**
  String get domainFieldAgendaPacks;

  /// No description provided for @domainFieldBattleWinCoins.
  ///
  /// In en, this message translates to:
  /// **'Battle win coins'**
  String get domainFieldBattleWinCoins;

  /// No description provided for @domainFieldBattleDrawCoins.
  ///
  /// In en, this message translates to:
  /// **'Battle draw coins'**
  String get domainFieldBattleDrawCoins;

  /// No description provided for @domainFieldBattleCooldownSeconds.
  ///
  /// In en, this message translates to:
  /// **'Battle cooldown'**
  String get domainFieldBattleCooldownSeconds;

  /// No description provided for @domainField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get domainField;

  /// No description provided for @domainInvalidSeries.
  ///
  /// In en, this message translates to:
  /// **'Choose a planet series from 1 to 6.'**
  String get domainInvalidSeries;

  /// No description provided for @domainLedgerOpenedPacks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Opened 1 pack} other{Opened {count} packs}}'**
  String domainLedgerOpenedPacks(int count);

  /// No description provided for @domainLedgerFoundCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint {number}: +1 {card}'**
  String domainLedgerFoundCheckpoint(int number, String card);

  /// No description provided for @domainPlanetLabel.
  ///
  /// In en, this message translates to:
  /// **'{series} · {color}'**
  String domainPlanetLabel(String series, String color);

  /// No description provided for @domainLedgerHatchedPlanet.
  ///
  /// In en, this message translates to:
  /// **'Hatched {planet}'**
  String domainLedgerHatchedPlanet(String planet);

  /// No description provided for @domainLedgerCompletedSeries.
  ///
  /// In en, this message translates to:
  /// **'{series} series completed'**
  String domainLedgerCompletedSeries(String series);

  /// No description provided for @domainLedgerCompletedMission.
  ///
  /// In en, this message translates to:
  /// **'#{tag} task completed'**
  String domainLedgerCompletedMission(String tag);

  /// No description provided for @domainGrantTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The amount exceeds the inventory limit.'**
  String get domainGrantTooLarge;

  /// No description provided for @shellOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline · saved on this device'**
  String get shellOffline;

  /// No description provided for @shellConnected.
  ///
  /// In en, this message translates to:
  /// **'Test server'**
  String get shellConnected;

  /// No description provided for @shellServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Test server URL'**
  String get shellServerUrl;

  /// No description provided for @deviceTransferIn.
  ///
  /// In en, this message translates to:
  /// **'Transfer to this device'**
  String get deviceTransferIn;

  /// No description provided for @deviceTransferOut.
  ///
  /// In en, this message translates to:
  /// **'Transfer to another device'**
  String get deviceTransferOut;

  /// No description provided for @deviceTransferCode.
  ///
  /// In en, this message translates to:
  /// **'Transfer code'**
  String get deviceTransferCode;

  /// No description provided for @deviceTransferWarning.
  ///
  /// In en, this message translates to:
  /// **'This replaces any saved player for this server. The device that issued the code will be signed out.'**
  String get deviceTransferWarning;

  /// No description provided for @deviceTransferResume.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to retry a submitted code.'**
  String get deviceTransferResume;

  /// No description provided for @deviceTransferShare.
  ///
  /// In en, this message translates to:
  /// **'Enter this code on the new device within 10 minutes. Keep it private. Using it signs this device out.'**
  String get deviceTransferShare;

  /// No description provided for @deviceTransferCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get deviceTransferCopy;

  /// No description provided for @deviceTransferCopied.
  ///
  /// In en, this message translates to:
  /// **'Transfer code copied.'**
  String get deviceTransferCopied;

  /// No description provided for @deviceTransferCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy the code.'**
  String get deviceTransferCopyFailed;

  /// No description provided for @shellInvalidServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter an HTTP or HTTPS server address without a path.'**
  String get shellInvalidServerUrl;

  /// No description provided for @shellUnsupportedMode.
  ///
  /// In en, this message translates to:
  /// **'Unsupported mode: {mode}'**
  String shellUnsupportedMode(String mode);

  /// No description provided for @shellChooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose mode'**
  String get shellChooseMode;

  /// No description provided for @shellIdentity.
  ///
  /// In en, this message translates to:
  /// **'SITCON 2027 · Player card'**
  String get shellIdentity;

  /// No description provided for @shellCountdown.
  ///
  /// In en, this message translates to:
  /// **'{label}: {seconds} seconds left'**
  String shellCountdown(String label, int seconds);

  /// No description provided for @shellRevealCard.
  ///
  /// In en, this message translates to:
  /// **'Unrevealed card. Tap to reveal.'**
  String get shellRevealCard;

  /// No description provided for @shellRevealSpecial.
  ///
  /// In en, this message translates to:
  /// **'Unrevealed special card. Tap to reveal.'**
  String get shellRevealSpecial;

  /// No description provided for @shellNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a nickname'**
  String get shellNameRequired;

  /// No description provided for @shellTagRange.
  ///
  /// In en, this message translates to:
  /// **'Choose 1–3 {category} tags'**
  String shellTagRange(String category);

  /// No description provided for @shellTagConflict.
  ///
  /// In en, this message translates to:
  /// **'Choose only one: {tags}'**
  String shellTagConflict(String tags);

  /// No description provided for @shellCreateCard.
  ///
  /// In en, this message translates to:
  /// **'Create card'**
  String get shellCreateCard;

  /// No description provided for @shellEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get shellEditCard;

  /// No description provided for @shellNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get shellNickname;

  /// No description provided for @shellContact.
  ///
  /// In en, this message translates to:
  /// **'Contact (optional)'**
  String get shellContact;

  /// No description provided for @shellPublicContact.
  ///
  /// In en, this message translates to:
  /// **'Visible on your card'**
  String get shellPublicContact;

  /// No description provided for @shellTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose 1–3 public tags per category. Tags lock after saving.'**
  String get shellTagsHint;

  /// No description provided for @shellTagsLocked.
  ///
  /// In en, this message translates to:
  /// **'Tags cannot be changed after saving.'**
  String get shellTagsLocked;

  /// No description provided for @shellOpposingTag.
  ///
  /// In en, this message translates to:
  /// **'Conflicts with a selected tag'**
  String get shellOpposingTag;

  /// No description provided for @shellTagLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 per category'**
  String get shellTagLimit;

  /// No description provided for @shellFinishCard.
  ///
  /// In en, this message translates to:
  /// **'Create card'**
  String get shellFinishCard;

  /// No description provided for @shellCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get shellCheckIn;

  /// No description provided for @shellBindBadge.
  ///
  /// In en, this message translates to:
  /// **'Bind your badge'**
  String get shellBindBadge;

  /// No description provided for @shellBadgeHint.
  ///
  /// In en, this message translates to:
  /// **'Binding cannot be undone here; contact the help desk if lost.'**
  String get shellBadgeHint;

  /// No description provided for @shellScanBadge.
  ///
  /// In en, this message translates to:
  /// **'Scan my badge'**
  String get shellScanBadge;

  /// No description provided for @shellCheckInNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Check-in has not opened'**
  String get shellCheckInNotOpen;

  /// No description provided for @shellTestCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Use test badge'**
  String get shellTestCheckIn;

  /// No description provided for @shellEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early-bird rewards'**
  String get shellEarlyBird;

  /// No description provided for @shellEarlyHint.
  ///
  /// In en, this message translates to:
  /// **'1 random egg + 1 pack, once per player. Unlocks after check-in when the event starts.'**
  String get shellEarlyHint;

  /// No description provided for @shellEarlyClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get shellEarlyClaimed;

  /// No description provided for @shellEarlyClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim test QR reward'**
  String get shellEarlyClaim;

  /// No description provided for @shellEarlyUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked in collection and packs'**
  String get shellEarlyUnlocked;

  /// No description provided for @shellEarlyLocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocks after event check-in'**
  String get shellEarlyLocked;

  /// No description provided for @shellEarlyClosed.
  ///
  /// In en, this message translates to:
  /// **'Available before the event only'**
  String get shellEarlyClosed;

  /// No description provided for @shellTutorialScan.
  ///
  /// In en, this message translates to:
  /// **'Scan badges, checkpoints and stations. Friends and battles require both players to scan.'**
  String get shellTutorialScan;

  /// No description provided for @shellTutorialEggs.
  ///
  /// In en, this message translates to:
  /// **'Earn coins from tasks and battles. Random eggs cost {random}; series eggs cost {series}.'**
  String shellTutorialEggs(int random, int series);

  /// No description provided for @shellTutorialTasks.
  ///
  /// In en, this message translates to:
  /// **'Find 3 friends per task for {coins} coins. Each checkpoint gives 1 card.'**
  String shellTutorialTasks(int coins);

  /// No description provided for @shellTutorialStep.
  ///
  /// In en, this message translates to:
  /// **'Tutorial {step}/3'**
  String shellTutorialStep(int step);

  /// No description provided for @shellStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get shellStart;

  /// No description provided for @shellNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get shellNext;

  /// No description provided for @shellSkipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get shellSkipTutorial;

  /// No description provided for @shellViewTasks.
  ///
  /// In en, this message translates to:
  /// **'View tasks'**
  String get shellViewTasks;

  /// No description provided for @shellMissionComplete.
  ///
  /// In en, this message translates to:
  /// **'Task complete'**
  String get shellMissionComplete;

  /// No description provided for @shellHintEarned.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint hint'**
  String get shellHintEarned;

  /// No description provided for @shellCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get shellCheckedIn;

  /// No description provided for @shellReward.
  ///
  /// In en, this message translates to:
  /// **'Reward received'**
  String get shellReward;

  /// No description provided for @shellInventoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Inventory added'**
  String get shellInventoryAdded;

  /// No description provided for @shellInventoryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Inventory removed'**
  String get shellInventoryRemoved;

  /// No description provided for @shellInventoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Inventory updated'**
  String get shellInventoryUpdated;

  /// No description provided for @shellInventoryPeekCards.
  ///
  /// In en, this message translates to:
  /// **'Peek cards'**
  String get shellInventoryPeekCards;

  /// No description provided for @shellInventoryHints.
  ///
  /// In en, this message translates to:
  /// **'Hint credits'**
  String get shellInventoryHints;

  /// No description provided for @shellCheckInReward.
  ///
  /// In en, this message translates to:
  /// **'12 starter cards: 4 scissors, 4 rock, 4 paper. Six tasks are ready.'**
  String get shellCheckInReward;

  /// No description provided for @shellMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get shellMore;

  /// No description provided for @shellCheats.
  ///
  /// In en, this message translates to:
  /// **'Cheats'**
  String get shellCheats;

  /// No description provided for @shellOpenPacks.
  ///
  /// In en, this message translates to:
  /// **'Open packs'**
  String get shellOpenPacks;

  /// No description provided for @shellEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get shellEggs;

  /// No description provided for @shellShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shellShop;

  /// No description provided for @shellCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get shellCollection;

  /// No description provided for @shellFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get shellFriends;

  /// No description provided for @shellRankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get shellRankings;

  /// No description provided for @shellAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get shellAppearance;

  /// No description provided for @shellLedger.
  ///
  /// In en, this message translates to:
  /// **'Card & coin history'**
  String get shellLedger;

  /// No description provided for @shellBattleHistory.
  ///
  /// In en, this message translates to:
  /// **'Battle history'**
  String get shellBattleHistory;

  /// No description provided for @shellRecap.
  ///
  /// In en, this message translates to:
  /// **'Recap'**
  String get shellRecap;

  /// No description provided for @shellTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get shellTutorial;

  /// No description provided for @shellPhaseBefore.
  ///
  /// In en, this message translates to:
  /// **'Before event'**
  String get shellPhaseBefore;

  /// No description provided for @shellPhaseEnded.
  ///
  /// In en, this message translates to:
  /// **'Event ended'**
  String get shellPhaseEnded;

  /// No description provided for @shellPhaseActive.
  ///
  /// In en, this message translates to:
  /// **'Event active'**
  String get shellPhaseActive;

  /// No description provided for @shellWaitingOpponent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent scan'**
  String get shellWaitingOpponent;

  /// No description provided for @shellMyCard.
  ///
  /// In en, this message translates to:
  /// **'My card'**
  String get shellMyCard;

  /// No description provided for @shellScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan a badge, checkpoint or station'**
  String get shellScanHint;

  /// No description provided for @shellCheckInFirst.
  ///
  /// In en, this message translates to:
  /// **'Check in first'**
  String get shellCheckInFirst;

  /// No description provided for @shellBattleClosed.
  ///
  /// In en, this message translates to:
  /// **'Battles are closed'**
  String get shellBattleClosed;

  /// No description provided for @shellBattleOngoing.
  ///
  /// In en, this message translates to:
  /// **'A battle is in progress'**
  String get shellBattleOngoing;

  /// No description provided for @shellNotEnoughCards.
  ///
  /// In en, this message translates to:
  /// **'At least 3 hand cards required'**
  String get shellNotEnoughCards;

  /// No description provided for @shellBattle.
  ///
  /// In en, this message translates to:
  /// **'Rock paper scissors'**
  String get shellBattle;

  /// No description provided for @shellBattleReady.
  ///
  /// In en, this message translates to:
  /// **'Scan a player badge to battle.'**
  String get shellBattleReady;

  /// No description provided for @shellCooldown.
  ///
  /// In en, this message translates to:
  /// **'Battle cooldown'**
  String get shellCooldown;

  /// No description provided for @shellEndedHint.
  ///
  /// In en, this message translates to:
  /// **'Battles and shop are closed.'**
  String get shellEndedHint;

  /// No description provided for @shellHand.
  ///
  /// In en, this message translates to:
  /// **'Hand cards'**
  String get shellHand;

  /// No description provided for @shellNoPacks.
  ///
  /// In en, this message translates to:
  /// **'Get packs from sessions, photos or roaming stations.'**
  String get shellNoPacks;

  /// No description provided for @shellBattleRound.
  ///
  /// In en, this message translates to:
  /// **'Battle · round {round}'**
  String shellBattleRound(int round);

  /// No description provided for @shellBattleRemaining.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s left · Return to battle'**
  String shellBattleRemaining(int seconds);

  /// No description provided for @shellCoins.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String shellCoins(int count);

  /// No description provided for @shellCards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hand card} other{{count} hand cards}}'**
  String shellCards(int count);

  /// No description provided for @shellPacks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unopened pack} other{{count} unopened packs}}'**
  String shellPacks(int count);

  /// No description provided for @shellCooldownRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cooldown: {seconds}s'**
  String shellCooldownRemaining(int seconds);

  /// No description provided for @shellBattleStats.
  ///
  /// In en, this message translates to:
  /// **'{total} battles · {wins} wins · {draws} draws · {losses} losses'**
  String shellBattleStats(int total, int wins, int draws, int losses);

  /// No description provided for @shellPointsRank.
  ///
  /// In en, this message translates to:
  /// **'{points} points · Rank {rank}'**
  String shellPointsRank(int points, String rank);

  /// No description provided for @shellCollectionProgress.
  ///
  /// In en, this message translates to:
  /// **'{planets}/42 planets · {series}/6 complete series'**
  String shellCollectionProgress(int planets, int series);

  /// No description provided for @shellPeekCards.
  ///
  /// In en, this message translates to:
  /// **'{count} peek cards (not hand cards)'**
  String shellPeekCards(int count);

  /// No description provided for @shellApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get shellApplied;

  /// No description provided for @shellPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive whole number'**
  String get shellPositiveAmount;

  /// No description provided for @shellAddResource.
  ///
  /// In en, this message translates to:
  /// **'Add {resource}'**
  String shellAddResource(String resource);

  /// No description provided for @shellOfflineOnly.
  ///
  /// In en, this message translates to:
  /// **'Available offline only'**
  String get shellOfflineOnly;

  /// No description provided for @shellScenarios.
  ///
  /// In en, this message translates to:
  /// **'Scenarios'**
  String get shellScenarios;

  /// No description provided for @shellPhaseHint.
  ///
  /// In en, this message translates to:
  /// **'Rewards require check-in while the event is active.'**
  String get shellPhaseHint;

  /// No description provided for @shellDeliveryId.
  ///
  /// In en, this message translates to:
  /// **'Delivery ID'**
  String get shellDeliveryId;

  /// No description provided for @shellSimulateDelivery.
  ///
  /// In en, this message translates to:
  /// **'Simulate pack delivery'**
  String get shellSimulateDelivery;

  /// No description provided for @shellDeliveryHint.
  ///
  /// In en, this message translates to:
  /// **'Each delivery ID is processed once.'**
  String get shellDeliveryHint;

  /// No description provided for @shellAgendaId.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get shellAgendaId;

  /// No description provided for @shellAgendaReward.
  ///
  /// In en, this message translates to:
  /// **'Session reward'**
  String get shellAgendaReward;

  /// No description provided for @shellPhotoReward.
  ///
  /// In en, this message translates to:
  /// **'Photo reward'**
  String get shellPhotoReward;

  /// No description provided for @shellScenarioLimits.
  ///
  /// In en, this message translates to:
  /// **'Once per session; photo once per player.'**
  String get shellScenarioLimits;

  /// No description provided for @shellCompleteBooth.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get shellCompleteBooth;

  /// No description provided for @shellBoothHint.
  ///
  /// In en, this message translates to:
  /// **'Booth confirmations advance hints, not coins or packs.'**
  String get shellBoothHint;

  /// No description provided for @shellStaffPermission.
  ///
  /// In en, this message translates to:
  /// **'Station binding permission'**
  String get shellStaffPermission;

  /// No description provided for @shellStaffHint.
  ///
  /// In en, this message translates to:
  /// **'Bind an unknown NTAG as a station in Scan.'**
  String get shellStaffHint;

  /// No description provided for @collectionChooseSeries.
  ///
  /// In en, this message translates to:
  /// **'Choose a series'**
  String get collectionChooseSeries;

  /// No description provided for @collectionSeriesComplete.
  ///
  /// In en, this message translates to:
  /// **'{series} · complete'**
  String collectionSeriesComplete(String series);

  /// No description provided for @collectionSeriesProgress.
  ///
  /// In en, this message translates to:
  /// **'{series} · {count}/7'**
  String collectionSeriesProgress(String series, int count);

  /// No description provided for @collectionBuyRandomTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy a random egg?'**
  String get collectionBuyRandomTitle;

  /// No description provided for @collectionBuySeriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy a {series} egg?'**
  String collectionBuySeriesTitle(String series);

  /// No description provided for @collectionRandomConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Unlock one of {remaining, plural, one{your last unowned planet} other{your {remaining} unowned planets}} at random.\n\nPrice: {price} coins\nBalance after purchase: {balance} coins\n\nPurchases cannot be undone.'**
  String collectionRandomConfirmation(int remaining, int price, int balance);

  /// No description provided for @collectionSeriesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Unlock one of {remaining, plural, one{your last unowned color} other{your {remaining} unowned colors}} at random.\n\nPrice: {price} coins\nBalance after purchase: {balance} coins\n\nPurchases cannot be undone.'**
  String collectionSeriesConfirmation(int remaining, int price, int balance);

  /// No description provided for @collectionConfirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get collectionConfirmPurchase;

  /// No description provided for @collectionCheckInFirst.
  ///
  /// In en, this message translates to:
  /// **'Check in first'**
  String get collectionCheckInFirst;

  /// No description provided for @collectionShopActiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Shop opens during the event'**
  String get collectionShopActiveOnly;

  /// No description provided for @collectionAllPlanets.
  ///
  /// In en, this message translates to:
  /// **'All planets collected'**
  String get collectionAllPlanets;

  /// No description provided for @collectionMissingCoins.
  ///
  /// In en, this message translates to:
  /// **'Need {count, plural, one{1 more coin} other{{count} more coins}}'**
  String collectionMissingCoins(int count);

  /// No description provided for @collectionRandomEggPrice.
  ///
  /// In en, this message translates to:
  /// **'Random egg · {price} coins'**
  String collectionRandomEggPrice(int price);

  /// No description provided for @collectionSeriesEggPrice.
  ///
  /// In en, this message translates to:
  /// **'Series egg · {price} coins'**
  String collectionSeriesEggPrice(int price);

  /// No description provided for @collectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get collectionAppearance;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Planet collection'**
  String get collectionTitle;

  /// No description provided for @collectionPlanetProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/42 planets'**
  String collectionPlanetProgress(int count);

  /// No description provided for @collectionCompletedSeries.
  ///
  /// In en, this message translates to:
  /// **'{count}/6 series complete · checkpoints counted separately'**
  String collectionCompletedSeries(int count);

  /// No description provided for @collectionBaseCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Available to everyone; not part of the 42 planets'**
  String get collectionBaseCardDescription;

  /// No description provided for @collectionAcquiredAt.
  ///
  /// In en, this message translates to:
  /// **'Acquired: {time}'**
  String collectionAcquiredAt(String time);

  /// No description provided for @collectionPlanetLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked. A {series} egg unlocks a random unowned color in this series.'**
  String collectionPlanetLocked(String series);

  /// No description provided for @collectionSetRepresentative.
  ///
  /// In en, this message translates to:
  /// **'Use this planet'**
  String get collectionSetRepresentative;

  /// No description provided for @collectionCardStyles.
  ///
  /// In en, this message translates to:
  /// **'Card style'**
  String get collectionCardStyles;

  /// No description provided for @collectionDefaultStyle.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get collectionDefaultStyle;

  /// No description provided for @collectionApplyStyle.
  ///
  /// In en, this message translates to:
  /// **'Apply {series} style'**
  String collectionApplyStyle(String series);

  /// No description provided for @collectionUnlockStyle.
  ///
  /// In en, this message translates to:
  /// **'Collect all 7 {series} colors to unlock'**
  String collectionUnlockStyle(String series);

  /// No description provided for @collectionShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Egg shop'**
  String get collectionShopTitle;

  /// No description provided for @collectionHatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Hatch an egg'**
  String get collectionHatchTitle;

  /// No description provided for @collectionRevealEgg.
  ///
  /// In en, this message translates to:
  /// **'Hatch'**
  String get collectionRevealEgg;

  /// No description provided for @collectionRepresentativeSelected.
  ///
  /// In en, this message translates to:
  /// **'Current planet ✓'**
  String get collectionRepresentativeSelected;

  /// No description provided for @collectionSeriesRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards: 1 wild card, 1 peek card, 1 pack and this series’ card style. Tap to reveal your special cards.'**
  String get collectionSeriesRewards;

  /// No description provided for @collectionWildReward.
  ///
  /// In en, this message translates to:
  /// **'Wild card ×1'**
  String get collectionWildReward;

  /// No description provided for @collectionPeekReward.
  ///
  /// In en, this message translates to:
  /// **'Peek card ×1'**
  String get collectionPeekReward;

  /// No description provided for @collectionChangeStyle.
  ///
  /// In en, this message translates to:
  /// **'Change card style'**
  String get collectionChangeStyle;

  /// No description provided for @collectionOpenRewardPack.
  ///
  /// In en, this message translates to:
  /// **'Open reward pack'**
  String get collectionOpenRewardPack;

  /// No description provided for @collectionBuyAnotherEgg.
  ///
  /// In en, this message translates to:
  /// **'Buy another random egg'**
  String get collectionBuyAnotherEgg;

  /// No description provided for @collectionShopClosed.
  ///
  /// In en, this message translates to:
  /// **'Shop closed'**
  String get collectionShopClosed;

  /// No description provided for @collectionPacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Card packs'**
  String get collectionPacksTitle;

  /// No description provided for @collectionUnopenedPacks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 unopened pack} other{{count} unopened packs}}'**
  String collectionUnopenedPacks(int count);

  /// No description provided for @collectionSkipAnimation.
  ///
  /// In en, this message translates to:
  /// **'Skip animation'**
  String get collectionSkipAnimation;

  /// No description provided for @collectionPackContents.
  ///
  /// In en, this message translates to:
  /// **'3 regular cards. Pack selection doesn\'t affect odds.'**
  String get collectionPackContents;

  /// No description provided for @collectionPreviousPack.
  ///
  /// In en, this message translates to:
  /// **'Previous pack'**
  String get collectionPreviousPack;

  /// No description provided for @collectionPackPosition.
  ///
  /// In en, this message translates to:
  /// **'Pack {number} of {total}'**
  String collectionPackPosition(int number, int total);

  /// No description provided for @collectionNextPack.
  ///
  /// In en, this message translates to:
  /// **'Next pack'**
  String get collectionNextPack;

  /// No description provided for @collectionOpenPackSemantics.
  ///
  /// In en, this message translates to:
  /// **'Card pack. Swipe right or tap to open.'**
  String get collectionOpenPackSemantics;

  /// No description provided for @collectionPackBrand.
  ///
  /// In en, this message translates to:
  /// **'SITCON\nCARD PACK'**
  String get collectionPackBrand;

  /// No description provided for @collectionTearRight.
  ///
  /// In en, this message translates to:
  /// **'Tear right →'**
  String get collectionTearRight;

  /// No description provided for @collectionOpenPack.
  ///
  /// In en, this message translates to:
  /// **'Open pack'**
  String get collectionOpenPack;

  /// No description provided for @collectionOpenAllPacks.
  ///
  /// In en, this message translates to:
  /// **'Open all {count, plural, one{1 pack} other{{count} packs}}'**
  String collectionOpenAllPacks(int count);

  /// No description provided for @collectionNoPacks.
  ///
  /// In en, this message translates to:
  /// **'No packs'**
  String get collectionNoPacks;

  /// No description provided for @collectionCardsAdded.
  ///
  /// In en, this message translates to:
  /// **'Cards added to your hand'**
  String get collectionCardsAdded;

  /// No description provided for @collectionRevealCards.
  ///
  /// In en, this message translates to:
  /// **'Reveal your cards'**
  String get collectionRevealCards;

  /// No description provided for @collectionCardsRevealed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 card revealed} other{{count} cards revealed}}'**
  String collectionCardsRevealed(int count);

  /// No description provided for @collectionAddToHand.
  ///
  /// In en, this message translates to:
  /// **'Add to hand'**
  String get collectionAddToHand;

  /// No description provided for @collectionRevealLastCard.
  ///
  /// In en, this message translates to:
  /// **'Reveal last card'**
  String get collectionRevealLastCard;

  /// No description provided for @collectionRevealNextCard.
  ///
  /// In en, this message translates to:
  /// **'Reveal next card'**
  String get collectionRevealNextCard;

  /// No description provided for @collectionPacksOpened.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 pack opened} other{{count} packs opened}}'**
  String collectionPacksOpened(int count);

  /// No description provided for @collectionHandChange.
  ///
  /// In en, this message translates to:
  /// **'{before} → {after}'**
  String collectionHandChange(int before, int after);

  /// No description provided for @collectionOpenAnotherPack.
  ///
  /// In en, this message translates to:
  /// **'Open another pack'**
  String get collectionOpenAnotherPack;

  /// No description provided for @taskHashtags.
  ///
  /// In en, this message translates to:
  /// **'Hashtags'**
  String get taskHashtags;

  /// No description provided for @taskBooths.
  ///
  /// In en, this message translates to:
  /// **'Booths'**
  String get taskBooths;

  /// No description provided for @taskMissionSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed}/6 completed · {coins} coins earned'**
  String taskMissionSummary(int completed, int coins);

  /// No description provided for @taskMissionRules.
  ///
  /// In en, this message translates to:
  /// **'3 confirmed friends → {coins} coins per mission'**
  String taskMissionRules(int coins);

  /// No description provided for @taskMissionProgress.
  ///
  /// In en, this message translates to:
  /// **'{kind} · {count}/3 · {status}'**
  String taskMissionProgress(String kind, int count, String status);

  /// No description provided for @taskOwnTag.
  ///
  /// In en, this message translates to:
  /// **'Your tag'**
  String get taskOwnTag;

  /// No description provided for @taskNewTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get taskNewTag;

  /// No description provided for @taskInProgress.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get taskInProgress;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;

  /// No description provided for @taskNoMatchingFriends.
  ///
  /// In en, this message translates to:
  /// **'No matching friends yet'**
  String get taskNoMatchingFriends;

  /// No description provided for @taskCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed: {time}'**
  String taskCompletedAt(String time);

  /// No description provided for @taskCheckpointProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/42 collected · 1 card for each first scan'**
  String taskCheckpointProgress(int count);

  /// No description provided for @taskPostcardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Postcard unlocked'**
  String get taskPostcardUnlocked;

  /// No description provided for @taskPostcard.
  ///
  /// In en, this message translates to:
  /// **'Postcard'**
  String get taskPostcard;

  /// No description provided for @taskPostcardRemaining.
  ///
  /// In en, this message translates to:
  /// **'Find {count, plural, one{1 more checkpoint} other{{count} more checkpoints}} to unlock your postcard.'**
  String taskPostcardRemaining(int count);

  /// No description provided for @taskOpenPostcard.
  ///
  /// In en, this message translates to:
  /// **'Open postcard'**
  String get taskOpenPostcard;

  /// No description provided for @taskRedeemHint.
  ///
  /// In en, this message translates to:
  /// **'Redeem hint · {count} available'**
  String taskRedeemHint(int count);

  /// No description provided for @taskNextHint.
  ///
  /// In en, this message translates to:
  /// **'Complete {count, plural, one{1 more battle or booth mission} other{{count} more battles or booth missions}} to earn a hint'**
  String taskNextHint(int count);

  /// No description provided for @taskAllCheckpointsFound.
  ///
  /// In en, this message translates to:
  /// **'All checkpoints found'**
  String get taskAllCheckpointsFound;

  /// No description provided for @taskHintsActiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Hints are available during the event'**
  String get taskHintsActiveOnly;

  /// No description provided for @taskHint.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint hint'**
  String get taskHint;

  /// No description provided for @taskLimitedCheckpoints.
  ///
  /// In en, this message translates to:
  /// **'Limited editions · speakers / staff / sponsors'**
  String get taskLimitedCheckpoints;

  /// No description provided for @taskCheckpointNumber.
  ///
  /// In en, this message translates to:
  /// **'#{number}'**
  String taskCheckpointNumber(int number);

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get taskNotFound;

  /// No description provided for @taskCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get taskCollected;

  /// No description provided for @taskCheckpointTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint #{number}'**
  String taskCheckpointTitle(int number);

  /// No description provided for @taskAreaHidden.
  ///
  /// In en, this message translates to:
  /// **'Redeem a hint to reveal the area'**
  String get taskAreaHidden;

  /// No description provided for @taskCollectedAt.
  ///
  /// In en, this message translates to:
  /// **'Collected: {time}'**
  String taskCollectedAt(String time);

  /// No description provided for @taskHintNotRedeemed.
  ///
  /// In en, this message translates to:
  /// **'No hint redeemed for this checkpoint'**
  String get taskHintNotRedeemed;

  /// No description provided for @taskBoothRules.
  ///
  /// In en, this message translates to:
  /// **'Staff must scan your badge to confirm. Website visits don\'t complete tasks.'**
  String get taskBoothRules;

  /// No description provided for @taskBoothStatus.
  ///
  /// In en, this message translates to:
  /// **'{visit} · {mission}\n{url}'**
  String taskBoothStatus(String visit, String mission, String url);

  /// No description provided for @taskVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get taskVisited;

  /// No description provided for @taskNotVisited.
  ///
  /// In en, this message translates to:
  /// **'Not visited'**
  String get taskNotVisited;

  /// No description provided for @taskPostcardHeading.
  ///
  /// In en, this message translates to:
  /// **'SITCON 2027 / POSTCARD'**
  String get taskPostcardHeading;

  /// No description provided for @taskPostcardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Dear {name},'**
  String taskPostcardGreeting(String name);

  /// No description provided for @taskPostcardBody.
  ///
  /// In en, this message translates to:
  /// **'You found {count, plural, one{1 checkpoint} other{{count} checkpoints}} at SITCON 2027.'**
  String taskPostcardBody(int count);

  /// No description provided for @taskPhysicalPostcardNotice.
  ///
  /// In en, this message translates to:
  /// **'Physical postcard pickup and mailing details are pending. Check on-site announcements.'**
  String get taskPhysicalPostcardNotice;

  /// No description provided for @socialBoothOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the booth website. Try again.'**
  String get socialBoothOpenError;

  /// No description provided for @socialCheckpointNumber.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint #{number}'**
  String socialCheckpointNumber(int number);

  /// No description provided for @socialCheckpointProgress.
  ///
  /// In en, this message translates to:
  /// **'Checkpoints {count}/42'**
  String socialCheckpointProgress(int count);

  /// No description provided for @socialPostcardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Postcard unlocked'**
  String get socialPostcardUnlocked;

  /// No description provided for @socialViewCheckpoints.
  ///
  /// In en, this message translates to:
  /// **'View checkpoints'**
  String get socialViewCheckpoints;

  /// No description provided for @socialStationSupply.
  ///
  /// In en, this message translates to:
  /// **'Station supply'**
  String get socialStationSupply;

  /// No description provided for @socialScanResult.
  ///
  /// In en, this message translates to:
  /// **'Scan result'**
  String get socialScanResult;

  /// No description provided for @socialScanPaused.
  ///
  /// In en, this message translates to:
  /// **'NFC paused'**
  String get socialScanPaused;

  /// No description provided for @socialScanStarting.
  ///
  /// In en, this message translates to:
  /// **'Preparing NFC'**
  String get socialScanStarting;

  /// No description provided for @socialScanReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get socialScanReady;

  /// No description provided for @socialScanProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing scan'**
  String get socialScanProcessing;

  /// No description provided for @socialScanCancelled.
  ///
  /// In en, this message translates to:
  /// **'NFC cancelled'**
  String get socialScanCancelled;

  /// No description provided for @socialScanError.
  ///
  /// In en, this message translates to:
  /// **'NFC unavailable'**
  String get socialScanError;

  /// No description provided for @socialScanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Hold a tag to the back of your phone'**
  String get socialScanInstruction;

  /// No description provided for @socialScanDuplicateHint.
  ///
  /// In en, this message translates to:
  /// **'Same tag? Reopen Scan to scan again.'**
  String get socialScanDuplicateHint;

  /// No description provided for @socialTestScan.
  ///
  /// In en, this message translates to:
  /// **'Test scan'**
  String get socialTestScan;

  /// No description provided for @socialUid.
  ///
  /// In en, this message translates to:
  /// **'NTAG UID'**
  String get socialUid;

  /// No description provided for @socialSubmitTestScan.
  ///
  /// In en, this message translates to:
  /// **'Submit test scan'**
  String get socialSubmitTestScan;

  /// No description provided for @socialScanFixtures.
  ///
  /// In en, this message translates to:
  /// **'Test tags'**
  String get socialScanFixtures;

  /// No description provided for @socialOwnBadge.
  ///
  /// In en, this message translates to:
  /// **'My badge'**
  String get socialOwnBadge;

  /// No description provided for @socialCheckpointFixtures.
  ///
  /// In en, this message translates to:
  /// **'42 checkpoints'**
  String get socialCheckpointFixtures;

  /// No description provided for @socialStationFixture.
  ///
  /// In en, this message translates to:
  /// **'{packs} packs/visit · {status} · {remaining} left'**
  String socialStationFixture(int packs, String status, int remaining);

  /// No description provided for @socialOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get socialOpen;

  /// No description provided for @socialClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get socialClosed;

  /// No description provided for @socialUnknownTag.
  ///
  /// In en, this message translates to:
  /// **'Unassigned NTAG'**
  String get socialUnknownTag;

  /// No description provided for @socialMyCard.
  ///
  /// In en, this message translates to:
  /// **'My card'**
  String get socialMyCard;

  /// No description provided for @socialPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get socialPlayer;

  /// No description provided for @socialScanPlayerFirst.
  ///
  /// In en, this message translates to:
  /// **'Scan their badge first'**
  String get socialScanPlayerFirst;

  /// No description provided for @socialCooldownSeconds.
  ///
  /// In en, this message translates to:
  /// **'Cooldown: {seconds}s'**
  String socialCooldownSeconds(int seconds);

  /// No description provided for @socialMissionProgress.
  ///
  /// In en, this message translates to:
  /// **'Matching missions'**
  String get socialMissionProgress;

  /// No description provided for @socialMissionStep.
  ///
  /// In en, this message translates to:
  /// **'#{tag}  {before}/3 → {after}/3'**
  String socialMissionStep(String tag, int before, int after);

  /// No description provided for @socialAlreadyFriends.
  ///
  /// In en, this message translates to:
  /// **'Already friends'**
  String get socialAlreadyFriends;

  /// No description provided for @socialExchangeCards.
  ///
  /// In en, this message translates to:
  /// **'Exchange cards'**
  String get socialExchangeCards;

  /// No description provided for @socialAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get socialAddFriend;

  /// No description provided for @socialFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get socialFriendRequests;

  /// No description provided for @socialFriendRequestPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for them to accept'**
  String get socialFriendRequestPending;

  /// No description provided for @socialAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get socialAccept;

  /// No description provided for @socialDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get socialDecline;

  /// No description provided for @socialWaitingReciprocal.
  ///
  /// In en, this message translates to:
  /// **'Waiting for their return scan'**
  String get socialWaitingReciprocal;

  /// No description provided for @socialFriendActiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Friend requests open during the event'**
  String get socialFriendActiveOnly;

  /// No description provided for @socialAskReciprocal.
  ///
  /// In en, this message translates to:
  /// **'Ask them to scan your badge'**
  String get socialAskReciprocal;

  /// No description provided for @socialTestAcceptFriend.
  ///
  /// In en, this message translates to:
  /// **'Test: accept friend request'**
  String get socialTestAcceptFriend;

  /// No description provided for @socialFriendExpired.
  ///
  /// In en, this message translates to:
  /// **'Request expired'**
  String get socialFriendExpired;

  /// No description provided for @socialBattle.
  ///
  /// In en, this message translates to:
  /// **'Battle'**
  String get socialBattle;

  /// No description provided for @socialInviteBattle.
  ///
  /// In en, this message translates to:
  /// **'Invite to battle'**
  String get socialInviteBattle;

  /// No description provided for @socialBattleRules.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 × 10s rounds · {seconds}s cooldown'**
  String socialBattleRules(int seconds);

  /// No description provided for @socialInviteCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled'**
  String get socialInviteCancelled;

  /// No description provided for @socialInviteCancelledHint.
  ///
  /// In en, this message translates to:
  /// **'No cards were spent.'**
  String get socialInviteCancelledHint;

  /// No description provided for @socialInviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get socialInviteSent;

  /// No description provided for @socialInviteReceived.
  ///
  /// In en, this message translates to:
  /// **'Battle invitation'**
  String get socialInviteReceived;

  /// No description provided for @socialBattleRespond.
  ///
  /// In en, this message translates to:
  /// **'Accept or decline'**
  String get socialBattleRespond;

  /// No description provided for @socialWaitingBattleAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent to accept'**
  String get socialWaitingBattleAcceptance;

  /// No description provided for @socialWaitingOpponentCard.
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent\'s card'**
  String get socialWaitingOpponentCard;

  /// No description provided for @socialReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get socialReady;

  /// No description provided for @socialWaitingForReady.
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent to be ready'**
  String get socialWaitingForReady;

  /// No description provided for @socialBattleResult.
  ///
  /// In en, this message translates to:
  /// **'Battle result'**
  String get socialBattleResult;

  /// No description provided for @socialBattleAcceptanceHint.
  ///
  /// In en, this message translates to:
  /// **'Cards are spent only after the return scan starts the battle.'**
  String get socialBattleAcceptanceHint;

  /// No description provided for @socialTestAcceptBattle.
  ///
  /// In en, this message translates to:
  /// **'Test: accept battle'**
  String get socialTestAcceptBattle;

  /// No description provided for @socialBattleRewards.
  ///
  /// In en, this message translates to:
  /// **'Battle rewards'**
  String get socialBattleRewards;

  /// No description provided for @socialBattleRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Points +{points} · Coins +{coins}'**
  String socialBattleRewardSummary(int points, int coins);

  /// No description provided for @socialNoCardDraw.
  ///
  /// In en, this message translates to:
  /// **'No card drawn'**
  String get socialNoCardDraw;

  /// No description provided for @socialCardDraw.
  ///
  /// In en, this message translates to:
  /// **'Drew {card} ×1'**
  String socialCardDraw(String card);

  /// No description provided for @socialCardsUsed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hand card used} other{{count} hand cards used}}'**
  String socialCardsUsed(int count);

  /// No description provided for @socialBattleFriendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friendship and matching mission progress updated.'**
  String get socialBattleFriendAdded;

  /// No description provided for @socialBattleCooldown.
  ///
  /// In en, this message translates to:
  /// **'Battle cooldown'**
  String get socialBattleCooldown;

  /// No description provided for @socialRoundScore.
  ///
  /// In en, this message translates to:
  /// **'Round {round}/3 · {wins} : {losses}'**
  String socialRoundScore(int round, int wins, int losses);

  /// No description provided for @socialChooseCard.
  ///
  /// In en, this message translates to:
  /// **'Choose a card'**
  String get socialChooseCard;

  /// No description provided for @socialAutoPlayHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-play when time runs out.'**
  String get socialAutoPlayHint;

  /// No description provided for @socialWildHint.
  ///
  /// In en, this message translates to:
  /// **'Wild card move'**
  String get socialWildHint;

  /// No description provided for @socialPeekUsed.
  ///
  /// In en, this message translates to:
  /// **'Peek used this battle'**
  String get socialPeekUsed;

  /// No description provided for @socialPeekConfirm.
  ///
  /// In en, this message translates to:
  /// **'Tap again to confirm ({seconds}s)'**
  String socialPeekConfirm(int seconds);

  /// No description provided for @socialPeekAction.
  ///
  /// In en, this message translates to:
  /// **'Peek ×{count} · Tap twice to use'**
  String socialPeekAction(int count);

  /// No description provided for @socialPeekResult.
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s hand'**
  String get socialPeekResult;

  /// No description provided for @socialPeekHint.
  ///
  /// In en, this message translates to:
  /// **'Opponent notified'**
  String get socialPeekHint;

  /// No description provided for @socialRoundHistory.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get socialRoundHistory;

  /// No description provided for @socialCardVersus.
  ///
  /// In en, this message translates to:
  /// **'{mine} vs {opponent}'**
  String socialCardVersus(String mine, String opponent);

  /// No description provided for @socialWildMove.
  ///
  /// In en, this message translates to:
  /// **'{card} (Wild)'**
  String socialWildMove(String card);

  /// No description provided for @socialAutomaticResult.
  ///
  /// In en, this message translates to:
  /// **'{result} · Automatic play'**
  String socialAutomaticResult(String result);

  /// No description provided for @socialRoundReveal.
  ///
  /// In en, this message translates to:
  /// **'Round {round} · Reveal'**
  String socialRoundReveal(int round);

  /// No description provided for @socialArena.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get socialArena;

  /// No description provided for @socialMyMove.
  ///
  /// In en, this message translates to:
  /// **'My move'**
  String get socialMyMove;

  /// No description provided for @socialWaitingMove.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a card'**
  String get socialWaitingMove;

  /// No description provided for @socialOpponentMove.
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s move'**
  String get socialOpponentMove;

  /// No description provided for @socialRevealHint.
  ///
  /// In en, this message translates to:
  /// **'Cards are revealed when both players submit.'**
  String get socialRevealHint;

  /// No description provided for @socialFriendCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend} other{{count} friends}}'**
  String socialFriendCount(int count);

  /// No description provided for @socialSearchNickname.
  ///
  /// In en, this message translates to:
  /// **'Search nickname'**
  String get socialSearchNickname;

  /// No description provided for @socialAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get socialAll;

  /// No description provided for @socialNoMatchingFriends.
  ///
  /// In en, this message translates to:
  /// **'No matching friends'**
  String get socialNoMatchingFriends;

  /// No description provided for @socialRanking.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get socialRanking;

  /// No description provided for @socialRankingFinal.
  ///
  /// In en, this message translates to:
  /// **'Event ended · Rankings final'**
  String get socialRankingFinal;

  /// No description provided for @socialNotRanked.
  ///
  /// In en, this message translates to:
  /// **'Not ranked yet'**
  String get socialNotRanked;

  /// No description provided for @socialMyRank.
  ///
  /// In en, this message translates to:
  /// **'My rank: #{rank}'**
  String socialMyRank(int rank);

  /// No description provided for @socialBindStation.
  ///
  /// In en, this message translates to:
  /// **'Bind station'**
  String get socialBindStation;

  /// No description provided for @socialStationDetails.
  ///
  /// In en, this message translates to:
  /// **'{packs} packs/visit · {limit} visits/person\n{remaining} packs left · {status}'**
  String socialStationDetails(
    int packs,
    int limit,
    int remaining,
    String status,
  );

  /// No description provided for @socialConfirmBinding.
  ///
  /// In en, this message translates to:
  /// **'Bind tag'**
  String get socialConfirmBinding;

  /// No description provided for @socialBindingUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Station binding permission required'**
  String get socialBindingUnauthorized;

  /// No description provided for @socialChooseStation.
  ///
  /// In en, this message translates to:
  /// **'Select a station first'**
  String get socialChooseStation;

  /// No description provided for @socialBindingComplete.
  ///
  /// In en, this message translates to:
  /// **'Tag bound'**
  String get socialBindingComplete;

  /// No description provided for @socialBindingCompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Players can scan this tag in Player mode when the station is open.'**
  String get socialBindingCompleteHint;

  /// No description provided for @utilityBattleHistory.
  ///
  /// In en, this message translates to:
  /// **'Battle history'**
  String get utilityBattleHistory;

  /// No description provided for @utilityLedger.
  ///
  /// In en, this message translates to:
  /// **'Cards and coins'**
  String get utilityLedger;

  /// No description provided for @utilityRoundResult.
  ///
  /// In en, this message translates to:
  /// **'Round {round} · {result}'**
  String utilityRoundResult(int round, String result);

  /// No description provided for @utilityAutomaticPlay.
  ///
  /// In en, this message translates to:
  /// **'Automatic play'**
  String get utilityAutomaticPlay;

  /// No description provided for @utilityCoinBalance.
  ///
  /// In en, this message translates to:
  /// **'Coin balance: {count}'**
  String utilityCoinBalance(int count);

  /// No description provided for @utilityPointsSeparate.
  ///
  /// In en, this message translates to:
  /// **'Coins do not affect ranking points.'**
  String get utilityPointsSeparate;

  /// No description provided for @utilityRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'My SITCON 2027'**
  String get utilityRecapTitle;

  /// No description provided for @utilityNoMoves.
  ///
  /// In en, this message translates to:
  /// **'No moves yet'**
  String get utilityNoMoves;

  /// No description provided for @utilityStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'SITCON 2027\nMY RECAP'**
  String get utilityStoryTitle;

  /// No description provided for @utilityBattles.
  ///
  /// In en, this message translates to:
  /// **'Battles'**
  String get utilityBattles;

  /// No description provided for @utilityBattleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 battle} other{{count} battles}}'**
  String utilityBattleCount(int count);

  /// No description provided for @utilityWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get utilityWinRate;

  /// No description provided for @utilityCompleteSeries.
  ///
  /// In en, this message translates to:
  /// **'Complete series'**
  String get utilityCompleteSeries;

  /// No description provided for @utilityPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend} other{{count} friends}}'**
  String utilityPeopleCount(int count);

  /// No description provided for @utilityHashtagMissions.
  ///
  /// In en, this message translates to:
  /// **'Hashtag missions'**
  String get utilityHashtagMissions;

  /// No description provided for @utilityFavoriteMove.
  ///
  /// In en, this message translates to:
  /// **'Favorite move'**
  String get utilityFavoriteMove;

  /// No description provided for @utilityOfflineRecord.
  ///
  /// In en, this message translates to:
  /// **'Offline demo record'**
  String get utilityOfflineRecord;

  /// No description provided for @utilityTestRecord.
  ///
  /// In en, this message translates to:
  /// **'Test server record'**
  String get utilityTestRecord;

  /// No description provided for @utilityGeneratingImage.
  ///
  /// In en, this message translates to:
  /// **'Creating image…'**
  String get utilityGeneratingImage;

  /// No description provided for @utilityShareStory.
  ///
  /// In en, this message translates to:
  /// **'Share recap image'**
  String get utilityShareStory;

  /// No description provided for @utilityRecapAfterEvent.
  ///
  /// In en, this message translates to:
  /// **'Final recap available after the event'**
  String get utilityRecapAfterEvent;

  /// No description provided for @operatorRoleUser.
  ///
  /// In en, this message translates to:
  /// **'Attendee'**
  String get operatorRoleUser;

  /// No description provided for @operatorRoleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get operatorRoleStaff;

  /// No description provided for @operatorRoleBooth.
  ///
  /// In en, this message translates to:
  /// **'Booth staff'**
  String get operatorRoleBooth;

  /// No description provided for @operatorModeUser.
  ///
  /// In en, this message translates to:
  /// **'Attendee'**
  String get operatorModeUser;

  /// No description provided for @operatorModeStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get operatorModeStaff;

  /// No description provided for @operatorModeBooth.
  ///
  /// In en, this message translates to:
  /// **'Booth'**
  String get operatorModeBooth;

  /// No description provided for @operatorAssignedBooth.
  ///
  /// In en, this message translates to:
  /// **'Assigned booth'**
  String get operatorAssignedBooth;

  /// No description provided for @operatorNoBooth.
  ///
  /// In en, this message translates to:
  /// **'Ask an administrator to assign a booth.'**
  String get operatorNoBooth;

  /// No description provided for @operatorReadOnlyResult.
  ///
  /// In en, this message translates to:
  /// **'Tag details'**
  String get operatorReadOnlyResult;

  /// No description provided for @operatorCompletionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Booth task'**
  String get operatorCompletionReceipt;

  /// No description provided for @operatorPermissionChanged.
  ///
  /// In en, this message translates to:
  /// **'Assignment changed. Return to Scan.'**
  String get operatorPermissionChanged;

  /// No description provided for @operatorAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Already completed'**
  String get operatorAlreadyCompleted;

  /// No description provided for @operatorCompletionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get operatorCompletionRecorded;

  /// No description provided for @operatorScanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Scan badge to complete task'**
  String get operatorScanInstruction;

  /// No description provided for @operatorDemoRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get operatorDemoRole;

  /// No description provided for @roleDomainOperatorPermission.
  ///
  /// In en, this message translates to:
  /// **'This account cannot use that scanner mode.'**
  String get roleDomainOperatorPermission;

  /// No description provided for @roleDomainBoothAssignmentRequired.
  ///
  /// In en, this message translates to:
  /// **'A valid booth assignment is required.'**
  String get roleDomainBoothAssignmentRequired;

  /// No description provided for @roleDomainOperatorSelfScan.
  ///
  /// In en, this message translates to:
  /// **'Scan an attendee’s badge.'**
  String get roleDomainOperatorSelfScan;

  /// No description provided for @roleDomainStaffIdentity.
  ///
  /// In en, this message translates to:
  /// **'Attendee badge'**
  String get roleDomainStaffIdentity;

  /// No description provided for @roleDomainBoothAlreadyComplete.
  ///
  /// In en, this message translates to:
  /// **'Already completed'**
  String get roleDomainBoothAlreadyComplete;

  /// No description provided for @roleDomainBoothTaskComplete.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get roleDomainBoothTaskComplete;

  /// No description provided for @roleDomainAttendeeBadgeRequired.
  ///
  /// In en, this message translates to:
  /// **'Scan a checked-in attendee’s badge.'**
  String get roleDomainAttendeeBadgeRequired;

  /// No description provided for @roleDomainStaffStationInfo.
  ///
  /// In en, this message translates to:
  /// **'Station details'**
  String get roleDomainStaffStationInfo;

  /// No description provided for @roleDomainOperatorTagInfo.
  ///
  /// In en, this message translates to:
  /// **'Event tag'**
  String get roleDomainOperatorTagInfo;

  /// No description provided for @roleDomainAmbiguousTag.
  ///
  /// In en, this message translates to:
  /// **'This tag has conflicting saved bindings. Ask an administrator to resolve them.'**
  String get roleDomainAmbiguousTag;

  /// No description provided for @roleDomainAmbiguousBadge.
  ///
  /// In en, this message translates to:
  /// **'This badge has conflicting assignments.'**
  String get roleDomainAmbiguousBadge;

  /// No description provided for @roleDomainInvalidScannerMode.
  ///
  /// In en, this message translates to:
  /// **'Unknown scanner mode.'**
  String get roleDomainInvalidScannerMode;

  /// No description provided for @roleDomainInvalidAccountRole.
  ///
  /// In en, this message translates to:
  /// **'Unknown account role.'**
  String get roleDomainInvalidAccountRole;

  /// No description provided for @roleDomainLedgerRole.
  ///
  /// In en, this message translates to:
  /// **'Account role assignment updated'**
  String get roleDomainLedgerRole;

  /// No description provided for @roleDomainLedgerOperatorScan.
  ///
  /// In en, this message translates to:
  /// **'Staff scan'**
  String get roleDomainLedgerOperatorScan;

  /// No description provided for @roleDomainLedgerBoothComplete.
  ///
  /// In en, this message translates to:
  /// **'Booth task completed'**
  String get roleDomainLedgerBoothComplete;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
