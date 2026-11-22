// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SITCON';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading…';

  @override
  String get noRecords => 'No records';

  @override
  String get coins => 'Coins';

  @override
  String get packs => 'Packs';

  @override
  String get points => 'Points';

  @override
  String get handCards => 'Cards';

  @override
  String get friends => 'Friends';

  @override
  String get planets => 'Planets';

  @override
  String get checkpoints => 'Checkpoints';

  @override
  String get tasks => 'Tasks';

  @override
  String get games => 'Game';

  @override
  String get profile => 'My card';

  @override
  String get more => 'More';

  @override
  String get scan => 'Scan';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryFaction => 'Preferences';

  @override
  String get categoryInterest => 'Interests';

  @override
  String get cardScissors => 'Scissors';

  @override
  String get cardRock => 'Rock';

  @override
  String get cardPaper => 'Paper';

  @override
  String get cardWild => 'Wild';

  @override
  String get seriesSun => 'Sun';

  @override
  String get seriesEarth => 'Earth';

  @override
  String get seriesMercury => 'Mercury';

  @override
  String get seriesMars => 'Mars';

  @override
  String get seriesSaturn => 'Saturn';

  @override
  String get seriesMoon => 'Moon';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorLightBlue => 'Light blue';

  @override
  String get colorDarkBlue => 'Dark blue';

  @override
  String get colorPurple => 'Purple';

  @override
  String get win => 'Win';

  @override
  String get loss => 'Loss';

  @override
  String get draw => 'Draw';

  @override
  String get baseCard => 'Default card';

  @override
  String get notAcquired => 'Not collected';

  @override
  String get locked => 'Locked';

  @override
  String get attendee => 'Attendee';

  @override
  String get speaker => 'Speaker';

  @override
  String get staff => 'Staff';

  @override
  String get sponsor => 'Sponsor';

  @override
  String get tagSecurity => 'Security';

  @override
  String get tagFrontend => 'Frontend';

  @override
  String get tagBackend => 'Backend';

  @override
  String get tagAppDevelopment => 'App development';

  @override
  String get tagGameDevelopment => 'Game development';

  @override
  String get tagIot => 'IoT';

  @override
  String get tagBlockchain => 'Blockchain';

  @override
  String get tagCompetitiveProgramming => 'Competitive programming';

  @override
  String get tagProgrammingLanguages => 'Programming languages';

  @override
  String get tagVim => 'Vim';

  @override
  String get tagVsCode => 'VS Code';

  @override
  String get tagTabs => 'Tabs';

  @override
  String get tagSpaces => 'Spaces';

  @override
  String get tagDarkMode => 'Dark mode';

  @override
  String get tagCats => 'Cats';

  @override
  String get tagDogs => 'Dogs';

  @override
  String get tagUnmixedCurry => 'Unmixed curry';

  @override
  String get tagMixedCurry => 'Mixed curry';

  @override
  String get tagNoCilantro => 'No cilantro';

  @override
  String get tagTaroHotpot => 'Taro in hotpot';

  @override
  String get tagNightOwl => 'Night owl';

  @override
  String get tagCoffee => 'Coffee';

  @override
  String get tagBubbleTea => 'Bubble tea';

  @override
  String get tagAnime => 'Anime';

  @override
  String get tagVideoGames => 'Video games';

  @override
  String get tagBoardGames => 'Board games';

  @override
  String get tagSports => 'Sports';

  @override
  String get tagMusic => 'Music';

  @override
  String get tagPhotography => 'Photography';

  @override
  String get tagMaker => 'Maker';

  @override
  String get areaSessions => 'Session halls';

  @override
  String get areaWhiteboard => 'Whiteboard challenge';

  @override
  String get areaSponsors => 'Sponsor booths';

  @override
  String get areaDemos => 'Demo booths';

  @override
  String get areaBooths => 'Booth area';

  @override
  String get areaWelcome => '1F Welcoming Zone';

  @override
  String get areaDining => 'Dining area';

  @override
  String get areaStairs => 'Stairwell';

  @override
  String get areaEventTeam => 'Event team';

  @override
  String get areaLimited => 'Limited edition';

  @override
  String get areaMobile => 'Mobile checkpoints';

  @override
  String get boothCommunity => 'SITCON community';

  @override
  String get boothOpenSource => 'Open-source demo';

  @override
  String get boothEvent => 'Event team';

  @override
  String get stationHelpDesk => 'Help desk';

  @override
  String get stationRoaming => 'Roaming station';

  @override
  String get stationClosed => 'Closed station';

  @override
  String get stationEmpty => 'Out-of-stock station';

  @override
  String fixturePlayer(int number) {
    return 'Demo $number';
  }

  @override
  String get domainUnknownParameter => 'Unknown game parameter.';

  @override
  String get domainInvalidStation => 'Invalid station settings.';

  @override
  String get domainInvalidUid =>
      'Use a 7-byte NTAG UID (14 hexadecimal digits).';

  @override
  String get domainUnsupportedSave =>
      'Saved data version is unsupported. Your progress was kept.';

  @override
  String get domainCheckInRequired =>
      'Bind your badge and choose your hashtags first.';

  @override
  String get domainInsufficientCoins => 'Not enough coins.';

  @override
  String get domainPlayerNotFound => 'Player not found.';

  @override
  String get domainInvalidTags => 'Hashtags are duplicated or invalid.';

  @override
  String get domainBadgePhase => 'Badges can only be bound during the event.';

  @override
  String get domainBadgeTaken =>
      'This badge is already bound to another player.';

  @override
  String get domainNotBadge => 'Scan your own badge.';

  @override
  String get domainBadgeLocked => 'Your badge is already bound.';

  @override
  String get domainNicknameRequired => 'Enter a nickname.';

  @override
  String get domainContactTooLong =>
      'Contact details must be at most 1,000 characters.';

  @override
  String get domainEarlyPhase =>
      'Register for the early reward before the event.';

  @override
  String get domainScanIdRequired => 'A scan ID is required.';

  @override
  String get domainScanIdConflict => 'This scan ID belongs to another tag.';

  @override
  String get domainScanFirst => 'Scan the other player’s badge first.';

  @override
  String get domainOpponentCardsLow => 'Your opponent needs at least 3 cards.';

  @override
  String get domainFriendRequestExpired =>
      'Friend request expired. Scan and invite again.';

  @override
  String get domainBattleCannotCancel =>
      'A started battle cannot be cancelled. Timed-out turns play automatically.';

  @override
  String get domainNoBattle => 'No battle is in progress.';

  @override
  String get domainCardUnavailable => 'You do not have that card.';

  @override
  String get domainWildChoiceRequired =>
      'Choose scissors, rock or paper for the wild card.';

  @override
  String get domainNormalCardFixed => 'Only a wild card can change its hand.';

  @override
  String get domainBattleCardsEmpty => 'Battle cards are depleted.';

  @override
  String get domainInvalidCardCount => 'Invalid card inventory.';

  @override
  String get domainPeekTiming => 'Use a peek card before playing your turn.';

  @override
  String get domainPeekUsed => 'A peek card can only be used once per battle.';

  @override
  String get domainPeekEmpty => 'No peek cards.';

  @override
  String get domainPacksEmpty => 'No packs to open.';

  @override
  String get domainPlanetLocked => 'Choose an unlocked planet.';

  @override
  String get domainStyleLocked => 'This card style is locked.';

  @override
  String get domainHintsExhausted => 'No new checkpoint hints are available.';

  @override
  String get domainStaffRequired => 'Staff permission is required.';

  @override
  String get domainStationNotFound => 'Station not found.';

  @override
  String get domainUidReserved => 'This UID is already assigned.';

  @override
  String get domainAgendaRequired => 'Enter an agenda slot.';

  @override
  String get domainBoothNotFound => 'Booth not found.';

  @override
  String get domainInvalidDelivery =>
      'Enter a delivery ID, positive pack count and reason.';

  @override
  String get domainDeliveryConflict =>
      'This delivery ID already has different content.';

  @override
  String get domainBattleBusy =>
      'Finish your current battle or invitation first.';

  @override
  String get domainBattleCooldown => 'Battle cooldown is active.';

  @override
  String get domainCardsLow => 'You need at least 3 cards.';

  @override
  String get domainApiNotFound => 'API not found.';

  @override
  String get domainApiCorsDenied => 'Cross-origin request denied.';

  @override
  String get domainApiInvalidJson => 'Invalid JSON.';

  @override
  String get domainApiRequestTimeout => 'Request timed out.';

  @override
  String get domainApiInternalError =>
      'The server could not complete the request.';

  @override
  String get domainApiHostDenied => 'Only the local server host is allowed.';

  @override
  String get domainApiNetworkDenied =>
      'This network cannot access the test API.';

  @override
  String get domainApiOriginDenied => 'This website cannot access the API.';

  @override
  String get domainApiClosing => 'The server is stopping.';

  @override
  String get domainApiMethodNotAllowed => 'HTTP method not supported.';

  @override
  String get domainApiJsonRequired =>
      'Send application/json with UTF-8 encoding.';

  @override
  String get domainApiBodyTooLarge => 'Request body exceeds 128 KiB.';

  @override
  String get domainApiInvalidBody => 'Send a JSON object.';

  @override
  String get domainApiPlayerActionForbidden =>
      'Player actions cannot use administrator or cheat controls.';

  @override
  String get domainApiPlayerNotFound => 'Select an initialized player.';

  @override
  String get domainApiUnknownAdminAction => 'Unknown administrator action.';

  @override
  String get domainInvalidTagList => 'Choose at most 9 hashtags.';

  @override
  String get domainInvalidPhase => 'Invalid event phase.';

  @override
  String get domainEventInactive => 'The event is not active.';

  @override
  String get domainInvalidArgument => 'Invalid request arguments.';

  @override
  String get domainInvalidBindAddress =>
      'The test server only accepts a loopback address.';

  @override
  String get domainEventBefore => 'The event has not started.';

  @override
  String get domainEventEnded => 'The event has ended.';

  @override
  String domainParameterRange(String parameter) {
    return 'Parameter $parameter is out of range.';
  }

  @override
  String domainCategoryTagCount(String category) {
    return 'Choose 1–3 hashtags in $category.';
  }

  @override
  String domainOpposingTags(String first, String second) {
    return 'Choose either $first or $second.';
  }

  @override
  String domainCoinsShort(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'You need $amount more coins.',
      one: 'You need 1 more coin.',
    );
    return '$_temp0';
  }

  @override
  String get domainAllPlanetsOwned => 'All 42 planets are collected.';

  @override
  String get domainSeriesOwned => 'This series is complete.';

  @override
  String domainHintsEmpty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Complete $count battles or booth tasks to earn a hint.',
      one: 'Complete 1 battle or booth task to earn a hint.',
    );
    return '$_temp0';
  }

  @override
  String get domainUnknownRanking => 'Ranking not supported.';

  @override
  String domainCheckpointHint(int number, String area) {
    return 'Checkpoint $number: near $area.';
  }

  @override
  String domainCheckpointFound(int number, String card) {
    return 'Checkpoint $number: +1 $card.';
  }

  @override
  String domainCheckpointRepeat(int number) {
    return 'Checkpoint $number already collected.';
  }

  @override
  String get domainStationClosed => 'This station is closed.';

  @override
  String get domainStationLimit =>
      'You have reached this station’s claim limit.';

  @override
  String get domainStationEmpty => 'This station is out of packs.';

  @override
  String domainStationPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Received $count packs.',
      one: 'Received 1 pack.',
    );
    return '$_temp0';
  }

  @override
  String get domainInvalidGrant => 'Enter a positive whole number.';

  @override
  String get domainWireVersion => 'Update the app to connect to this server.';

  @override
  String get domainInvalidApiOrigin => 'Invalid server address.';

  @override
  String get domainDeviceSessionRequired =>
      'This device is signed out. Use a transfer code from the active device.';

  @override
  String get domainDeviceTransferInvalid =>
      'The transfer code is invalid or expired. Get a new one from the active device.';

  @override
  String get domainDeviceSessionConflict =>
      'This device connection conflicts with an existing session.';

  @override
  String get domainDeviceSecureOriginRequired =>
      'Use HTTPS to connect. HTTP is allowed only for loopback testing.';

  @override
  String get domainDeviceStorageUnavailable =>
      'Secure device storage is unavailable. Try again after unlocking the device.';

  @override
  String get domainNotConnected => 'Not connected to the server.';

  @override
  String get domainServiceDisposed => 'This session is closed.';

  @override
  String get domainNetworkTimeout => 'Connection timed out. Try again.';

  @override
  String get domainNetworkUnavailable =>
      'Cannot reach the server. Check your connection.';

  @override
  String get domainInvalidResponse => 'Invalid server response.';

  @override
  String get domainServerFailure =>
      'The request could not be completed. Try again.';

  @override
  String get domainCorruptSave =>
      'Saved data is damaged or unsupported. Your file and progress were kept.';

  @override
  String get domainStorageFailure =>
      'Cannot read or save data. Your last saved progress was kept.';

  @override
  String get domainNfcUnsupported => 'NFC requires an iOS or Android phone.';

  @override
  String get domainNfcInterrupted => 'NFC was interrupted. Scan again.';

  @override
  String get domainNfcReadFailed => 'Could not read the tag. Scan again.';

  @override
  String get domainNfcDisposed => 'NFC reader is closed.';

  @override
  String get domainNfcBusy => 'Another NFC scan is in progress.';

  @override
  String get domainNfcStopFailed => 'Could not stop NFC. Try again.';

  @override
  String get domainNfcDisabled => 'NFC is unavailable or turned off.';

  @override
  String get domainNfcInvalidTag => 'Scan an NTAG213, 215 or 216 tag.';

  @override
  String get domainNfcTimeout => 'Scan timed out. Try again.';

  @override
  String get domainNfcStartFailed => 'Could not start NFC. Try again.';

  @override
  String get domainShareNotReady => 'Share image is not ready. Try again.';

  @override
  String get domainShareFailed => 'Could not create the share image.';

  @override
  String domainInvalidString(String field, int max) {
    return 'Enter a valid $field (up to $max characters).';
  }

  @override
  String domainInvalidInteger(String field, int min, int max) {
    return '$field must be a whole number from $min to $max.';
  }

  @override
  String domainInvalidBoolean(String field) {
    return 'Invalid value for $field.';
  }

  @override
  String get domainUnknownError => 'Something went wrong. Try again.';

  @override
  String get domainScanSelf => 'Your card';

  @override
  String get domainScanPlayer => 'Add friend or battle';

  @override
  String get domainScanCheckpoint => 'Checkpoint scanned';

  @override
  String get domainScanBooth => 'Booth scanned';

  @override
  String get domainScanStation => 'Station scanned';

  @override
  String get domainScanUnknown => 'Unknown NTAG';

  @override
  String get domainScanBindStation => 'Unassigned tag. Choose a station.';

  @override
  String get domainLedgerAdminParameters => 'Game settings updated';

  @override
  String get domainLedgerAdminStation => 'Station updated';

  @override
  String get domainLedgerBadgeBind => 'Badge bound';

  @override
  String get domainLedgerProfileEdit => 'Profile updated';

  @override
  String get domainLedgerCheckin => 'Checked in';

  @override
  String get domainLedgerEarlyUnlock => 'Early reward unlocked';

  @override
  String get domainLedgerEarlyClaim => 'Early reward registered';

  @override
  String get domainLedgerScanSelf => 'Own badge scanned';

  @override
  String get domainLedgerScanPlayer => 'Player scanned';

  @override
  String get domainLedgerScanCheckpointRepeat => 'Checkpoint already collected';

  @override
  String get domainLedgerScanCheckpoint => 'Checkpoint collected';

  @override
  String get domainLedgerScanBooth => 'Booth visited';

  @override
  String get domainLedgerScanStation => 'Station scanned';

  @override
  String get domainLedgerScanUnknown => 'Unknown tag scanned';

  @override
  String get domainLedgerFriendRequest => 'Friend invited';

  @override
  String get domainLedgerBattleAccept => 'Battle accepted';

  @override
  String get domainLedgerFriendAdd => 'Friend added';

  @override
  String get domainLedgerMissionComplete => 'Hashtag task completed';

  @override
  String get domainLedgerBattleInvite => 'Battle invited';

  @override
  String get domainLedgerBattleCancel => 'Battle invitation cancelled';

  @override
  String get domainLedgerBattleRound => 'Battle round played';

  @override
  String get domainLedgerBattleSettle => 'Battle completed';

  @override
  String get domainLedgerBattlePeek => 'Peek card used';

  @override
  String get domainLedgerBattleInviteExpired => 'Battle invitation expired';

  @override
  String get domainLedgerPackOpen => 'Packs opened';

  @override
  String get domainLedgerEggBuy => 'Planet hatched';

  @override
  String get domainLedgerSeriesComplete => 'Planet series completed';

  @override
  String get domainLedgerAppearanceEdit => 'Appearance updated';

  @override
  String get domainLedgerHintEarn => 'Hint earned';

  @override
  String get domainLedgerHintRedeem => 'Hint redeemed';

  @override
  String get domainLedgerStationBind => 'Station tag bound';

  @override
  String get domainLedgerMockPhase => 'Event phase changed';

  @override
  String get domainLedgerMockStaff => 'Staff permission changed';

  @override
  String get domainLedgerMockAgenda => 'Agenda packs received';

  @override
  String get domainLedgerMockBoothComplete => 'Booth task completed';

  @override
  String get domainLedgerMockRemote => 'Packs received';

  @override
  String get domainLedgerMockPhoto => 'Photo reward received';

  @override
  String get domainLedgerCheatCoins => 'Coins added';

  @override
  String get domainNfcPrompt =>
      'Hold your phone near an NTAG badge or checkpoint.';

  @override
  String domainLedgerCoins(String label, String delta) {
    return '$label · Coins $delta';
  }

  @override
  String domainPacksAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count packs',
      one: 'Added 1 pack',
    );
    return '$_temp0';
  }

  @override
  String get domainFieldAction => 'Action';

  @override
  String get domainFieldContact => 'Contact details';

  @override
  String get domainFieldNickname => 'Nickname';

  @override
  String get domainFieldUid => 'Tag UID';

  @override
  String get domainFieldScanId => 'Scan ID';

  @override
  String get domainFieldPlayerId => 'Player';

  @override
  String get domainFieldCard => 'Card';

  @override
  String get domainFieldAsCard => 'Wild card choice';

  @override
  String get domainFieldAll => 'Open all';

  @override
  String get domainFieldSeries => 'Series';

  @override
  String get domainFieldPlanet => 'Planet';

  @override
  String get domainFieldStyle => 'Card style';

  @override
  String get domainFieldStationId => 'Station';

  @override
  String get domainFieldPhase => 'Event phase';

  @override
  String get domainFieldSlot => 'Agenda slot';

  @override
  String get domainFieldDeliveryId => 'Delivery ID';

  @override
  String get domainFieldAmount => 'Amount';

  @override
  String get domainFieldReason => 'Reason';

  @override
  String get domainFieldEnabled => 'Enabled';

  @override
  String get domainFieldName => 'Name';

  @override
  String get domainFieldPacks => 'Packs';

  @override
  String get domainFieldLimit => 'Claim limit';

  @override
  String get domainFieldRemaining => 'Stock';

  @override
  String get domainFieldOpen => 'Open';

  @override
  String get domainFieldRandomEggPrice => 'Random egg price';

  @override
  String get domainFieldSeriesEggPrice => 'Series egg price';

  @override
  String get domainFieldHintThreshold => 'Hint threshold';

  @override
  String get domainFieldMissionCoins => 'Task coins';

  @override
  String get domainFieldAgendaPacks => 'Agenda packs';

  @override
  String get domainFieldBattleWinCoins => 'Battle win coins';

  @override
  String get domainFieldBattleDrawCoins => 'Battle draw coins';

  @override
  String get domainFieldBattleCooldownSeconds => 'Battle cooldown';

  @override
  String get domainField => 'Field';

  @override
  String get domainInvalidSeries => 'Choose a planet series from 1 to 6.';

  @override
  String domainLedgerOpenedPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Opened $count packs',
      one: 'Opened 1 pack',
    );
    return '$_temp0';
  }

  @override
  String domainLedgerFoundCheckpoint(int number, String card) {
    return 'Checkpoint $number: +1 $card';
  }

  @override
  String domainPlanetLabel(String series, String color) {
    return '$series · $color';
  }

  @override
  String domainLedgerHatchedPlanet(String planet) {
    return 'Hatched $planet';
  }

  @override
  String domainLedgerCompletedSeries(String series) {
    return '$series series completed';
  }

  @override
  String domainLedgerCompletedMission(String tag) {
    return '#$tag task completed';
  }

  @override
  String get domainGrantTooLarge => 'The amount exceeds the inventory limit.';

  @override
  String get shellOffline => 'Offline · saved on this device';

  @override
  String get shellConnected => 'Test server';

  @override
  String get shellServerUrl => 'Test server URL';

  @override
  String get deviceTransferIn => 'Transfer to this device';

  @override
  String get deviceTransferOut => 'Transfer to another device';

  @override
  String get deviceTransferCode => 'Transfer code';

  @override
  String get deviceTransferWarning =>
      'This replaces any saved player for this server. The device that issued the code will be signed out.';

  @override
  String get deviceTransferResume => 'Leave blank to retry a submitted code.';

  @override
  String get deviceTransferShare =>
      'Enter this code on the new device within 10 minutes. Keep it private. Using it signs this device out.';

  @override
  String get deviceTransferCopy => 'Copy code';

  @override
  String get deviceTransferCopied => 'Transfer code copied.';

  @override
  String get deviceTransferCopyFailed => 'Couldn\'t copy the code.';

  @override
  String get shellInvalidServerUrl =>
      'Enter an HTTP or HTTPS server address without a path.';

  @override
  String shellUnsupportedMode(String mode) {
    return 'Unsupported mode: $mode';
  }

  @override
  String get shellChooseMode => 'Choose mode';

  @override
  String get shellIdentity => 'SITCON 2027 · Player card';

  @override
  String shellCountdown(String label, int seconds) {
    return '$label: $seconds seconds left';
  }

  @override
  String get shellRevealCard => 'Unrevealed card. Tap to reveal.';

  @override
  String get shellRevealSpecial => 'Unrevealed special card. Tap to reveal.';

  @override
  String get shellNameRequired => 'Enter a nickname';

  @override
  String shellTagRange(String category) {
    return 'Choose 1–3 $category tags';
  }

  @override
  String shellTagConflict(String tags) {
    return 'Choose only one: $tags';
  }

  @override
  String get shellCreateCard => 'Create card';

  @override
  String get shellEditCard => 'Edit card';

  @override
  String get shellNickname => 'Nickname';

  @override
  String get shellContact => 'Contact (optional)';

  @override
  String get shellPublicContact => 'Visible on your card';

  @override
  String get shellTagsHint =>
      'Choose 1–3 public tags per category. Tags lock after saving.';

  @override
  String get shellTagsLocked => 'Tags cannot be changed after saving.';

  @override
  String get shellOpposingTag => 'Conflicts with a selected tag';

  @override
  String get shellTagLimit => 'Up to 3 per category';

  @override
  String get shellFinishCard => 'Create card';

  @override
  String get shellCheckIn => 'Check in';

  @override
  String get shellBindBadge => 'Bind your badge';

  @override
  String get shellBadgeHint =>
      'Binding cannot be undone here; contact the help desk if lost.';

  @override
  String get shellScanBadge => 'Scan my badge';

  @override
  String get shellCheckInNotOpen => 'Check-in has not opened';

  @override
  String get shellTestCheckIn => 'Use test badge';

  @override
  String get shellEarlyBird => 'Early-bird rewards';

  @override
  String get shellEarlyHint =>
      '1 random egg + 1 pack, once per player. Unlocks after check-in when the event starts.';

  @override
  String get shellEarlyClaimed => 'Claimed';

  @override
  String get shellEarlyClaim => 'Claim test QR reward';

  @override
  String get shellEarlyUnlocked => 'Unlocked in collection and packs';

  @override
  String get shellEarlyLocked => 'Unlocks after event check-in';

  @override
  String get shellEarlyClosed => 'Available before the event only';

  @override
  String get shellTutorialScan =>
      'Scan badges, checkpoints and stations. Friends and battles require both players to scan.';

  @override
  String shellTutorialEggs(int random, int series) {
    return 'Earn coins from tasks and battles. Random eggs cost $random; series eggs cost $series.';
  }

  @override
  String shellTutorialTasks(int coins) {
    return 'Find 3 friends per task for $coins coins. Each checkpoint gives 1 card.';
  }

  @override
  String shellTutorialStep(int step) {
    return 'Tutorial $step/3';
  }

  @override
  String get shellStart => 'Start';

  @override
  String get shellNext => 'Next';

  @override
  String get shellSkipTutorial => 'Skip';

  @override
  String get shellViewTasks => 'View tasks';

  @override
  String get shellMissionComplete => 'Task complete';

  @override
  String get shellHintEarned => 'Checkpoint hint';

  @override
  String get shellCheckedIn => 'Checked in';

  @override
  String get shellReward => 'Reward received';

  @override
  String get shellInventoryAdded => 'Inventory added';

  @override
  String get shellInventoryRemoved => 'Inventory removed';

  @override
  String get shellInventoryUpdated => 'Inventory updated';

  @override
  String get shellInventoryPeekCards => 'Peek cards';

  @override
  String get shellInventoryHints => 'Hint credits';

  @override
  String get shellCheckInReward =>
      '12 starter cards: 4 scissors, 4 rock, 4 paper. Six tasks are ready.';

  @override
  String get shellMore => 'More';

  @override
  String get shellCheats => 'Cheats';

  @override
  String get shellOpenPacks => 'Open packs';

  @override
  String get shellEggs => 'Eggs';

  @override
  String get shellShop => 'Shop';

  @override
  String get shellCollection => 'Collection';

  @override
  String get shellFriends => 'Friends';

  @override
  String get shellRankings => 'Rankings';

  @override
  String get shellAppearance => 'Appearance';

  @override
  String get shellLedger => 'Card & coin history';

  @override
  String get shellBattleHistory => 'Battle history';

  @override
  String get shellRecap => 'Recap';

  @override
  String get shellTutorial => 'Tutorial';

  @override
  String get shellPhaseBefore => 'Before event';

  @override
  String get shellPhaseEnded => 'Event ended';

  @override
  String get shellPhaseActive => 'Event active';

  @override
  String get shellWaitingOpponent => 'Waiting for opponent scan';

  @override
  String get shellMyCard => 'My card';

  @override
  String get shellScanHint => 'Scan a badge, checkpoint or station';

  @override
  String get shellCheckInFirst => 'Check in first';

  @override
  String get shellBattleClosed => 'Battles are closed';

  @override
  String get shellBattleOngoing => 'A battle is in progress';

  @override
  String get shellNotEnoughCards => 'At least 3 hand cards required';

  @override
  String get shellBattle => 'Rock paper scissors';

  @override
  String get shellBattleReady => 'Scan a player badge to battle.';

  @override
  String get shellCooldown => 'Battle cooldown';

  @override
  String get shellEndedHint => 'Battles and shop are closed.';

  @override
  String get shellHand => 'Hand cards';

  @override
  String get shellNoPacks =>
      'Get packs from sessions, photos or roaming stations.';

  @override
  String shellBattleRound(int round) {
    return 'Battle · round $round';
  }

  @override
  String shellBattleRemaining(int seconds) {
    return '${seconds}s left · Return to battle';
  }

  @override
  String shellCoins(int count) {
    return '$count coins';
  }

  @override
  String shellCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hand cards',
      one: '1 hand card',
    );
    return '$_temp0';
  }

  @override
  String shellPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unopened packs',
      one: '1 unopened pack',
    );
    return '$_temp0';
  }

  @override
  String shellCooldownRemaining(int seconds) {
    return 'Cooldown: ${seconds}s';
  }

  @override
  String shellBattleStats(int total, int wins, int draws, int losses) {
    return '$total battles · $wins wins · $draws draws · $losses losses';
  }

  @override
  String shellPointsRank(int points, String rank) {
    return '$points points · Rank $rank';
  }

  @override
  String shellCollectionProgress(int planets, int series) {
    return '$planets/42 planets · $series/6 complete series';
  }

  @override
  String shellPeekCards(int count) {
    return '$count peek cards (not hand cards)';
  }

  @override
  String get shellApplied => 'Applied';

  @override
  String get shellPositiveAmount => 'Enter a positive whole number';

  @override
  String shellAddResource(String resource) {
    return 'Add $resource';
  }

  @override
  String get shellOfflineOnly => 'Available offline only';

  @override
  String get shellScenarios => 'Scenarios';

  @override
  String get shellPhaseHint =>
      'Rewards require check-in while the event is active.';

  @override
  String get shellDeliveryId => 'Delivery ID';

  @override
  String get shellSimulateDelivery => 'Simulate pack delivery';

  @override
  String get shellDeliveryHint => 'Each delivery ID is processed once.';

  @override
  String get shellAgendaId => 'Session ID';

  @override
  String get shellAgendaReward => 'Session reward';

  @override
  String get shellPhotoReward => 'Photo reward';

  @override
  String get shellScenarioLimits => 'Once per session; photo once per player.';

  @override
  String get shellCompleteBooth => 'Complete';

  @override
  String get shellBoothHint =>
      'Booth confirmations advance hints, not coins or packs.';

  @override
  String get shellStaffPermission => 'Station binding permission';

  @override
  String get shellStaffHint => 'Bind an unknown NTAG as a station in Scan.';

  @override
  String get collectionChooseSeries => 'Choose a series';

  @override
  String collectionSeriesComplete(String series) {
    return '$series · complete';
  }

  @override
  String collectionSeriesProgress(String series, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$series · $countString/7';
  }

  @override
  String get collectionBuyRandomTitle => 'Buy a random egg?';

  @override
  String collectionBuySeriesTitle(String series) {
    return 'Buy a $series egg?';
  }

  @override
  String collectionRandomConfirmation(int remaining, int price, int balance) {
    final intl.NumberFormat remainingNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String remainingString = remainingNumberFormat.format(remaining);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);
    final intl.NumberFormat balanceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String balanceString = balanceNumberFormat.format(balance);

    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'your $remainingString unowned planets',
      one: 'your last unowned planet',
    );
    return 'Unlock one of $_temp0 at random.\n\nPrice: $priceString coins\nBalance after purchase: $balanceString coins\n\nPurchases cannot be undone.';
  }

  @override
  String collectionSeriesConfirmation(int remaining, int price, int balance) {
    final intl.NumberFormat remainingNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String remainingString = remainingNumberFormat.format(remaining);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);
    final intl.NumberFormat balanceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String balanceString = balanceNumberFormat.format(balance);

    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'your $remainingString unowned colors',
      one: 'your last unowned color',
    );
    return 'Unlock one of $_temp0 at random.\n\nPrice: $priceString coins\nBalance after purchase: $balanceString coins\n\nPurchases cannot be undone.';
  }

  @override
  String get collectionConfirmPurchase => 'Buy';

  @override
  String get collectionCheckInFirst => 'Check in first';

  @override
  String get collectionShopActiveOnly => 'Shop opens during the event';

  @override
  String get collectionAllPlanets => 'All planets collected';

  @override
  String collectionMissingCoins(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString more coins',
      one: '1 more coin',
    );
    return 'Need $_temp0';
  }

  @override
  String collectionRandomEggPrice(int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return 'Random egg · $priceString coins';
  }

  @override
  String collectionSeriesEggPrice(int price) {
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return 'Series egg · $priceString coins';
  }

  @override
  String get collectionAppearance => 'Appearance';

  @override
  String get collectionTitle => 'Planet collection';

  @override
  String collectionPlanetProgress(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/42 planets';
  }

  @override
  String collectionCompletedSeries(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/6 series complete · checkpoints counted separately';
  }

  @override
  String get collectionBaseCardDescription =>
      'Available to everyone; not part of the 42 planets';

  @override
  String collectionAcquiredAt(String time) {
    return 'Acquired: $time';
  }

  @override
  String collectionPlanetLocked(String series) {
    return 'Locked. A $series egg unlocks a random unowned color in this series.';
  }

  @override
  String get collectionSetRepresentative => 'Use this planet';

  @override
  String get collectionCardStyles => 'Card style';

  @override
  String get collectionDefaultStyle => 'Default';

  @override
  String collectionApplyStyle(String series) {
    return 'Apply $series style';
  }

  @override
  String collectionUnlockStyle(String series) {
    return 'Collect all 7 $series colors to unlock';
  }

  @override
  String get collectionShopTitle => 'Egg shop';

  @override
  String get collectionHatchTitle => 'Hatch an egg';

  @override
  String get collectionRevealEgg => 'Hatch';

  @override
  String get collectionRepresentativeSelected => 'Current planet ✓';

  @override
  String get collectionSeriesRewards =>
      'Rewards: 1 wild card, 1 peek card, 1 pack and this series’ card style. Tap to reveal your special cards.';

  @override
  String get collectionWildReward => 'Wild card ×1';

  @override
  String get collectionPeekReward => 'Peek card ×1';

  @override
  String get collectionChangeStyle => 'Change card style';

  @override
  String get collectionOpenRewardPack => 'Open reward pack';

  @override
  String get collectionBuyAnotherEgg => 'Buy another random egg';

  @override
  String get collectionShopClosed => 'Shop closed';

  @override
  String get collectionPacksTitle => 'Card packs';

  @override
  String collectionUnopenedPacks(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString unopened packs',
      one: '1 unopened pack',
    );
    return '$_temp0';
  }

  @override
  String get collectionSkipAnimation => 'Skip animation';

  @override
  String get collectionPackContents =>
      '3 regular cards. Pack selection doesn\'t affect odds.';

  @override
  String get collectionPreviousPack => 'Previous pack';

  @override
  String collectionPackPosition(int number, int total) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Pack $numberString of $totalString';
  }

  @override
  String get collectionNextPack => 'Next pack';

  @override
  String get collectionOpenPackSemantics =>
      'Card pack. Swipe right or tap to open.';

  @override
  String get collectionPackBrand => 'SITCON\nCARD PACK';

  @override
  String get collectionTearRight => 'Tear right →';

  @override
  String get collectionOpenPack => 'Open pack';

  @override
  String collectionOpenAllPacks(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString packs',
      one: '1 pack',
    );
    return 'Open all $_temp0';
  }

  @override
  String get collectionNoPacks => 'No packs';

  @override
  String get collectionCardsAdded => 'Cards added to your hand';

  @override
  String get collectionRevealCards => 'Reveal your cards';

  @override
  String collectionCardsRevealed(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString cards revealed',
      one: '1 card revealed',
    );
    return '$_temp0';
  }

  @override
  String get collectionAddToHand => 'Add to hand';

  @override
  String get collectionRevealLastCard => 'Reveal last card';

  @override
  String get collectionRevealNextCard => 'Reveal next card';

  @override
  String collectionPacksOpened(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString packs opened',
      one: '1 pack opened',
    );
    return '$_temp0';
  }

  @override
  String collectionHandChange(int before, int after) {
    final intl.NumberFormat beforeNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String beforeString = beforeNumberFormat.format(before);
    final intl.NumberFormat afterNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String afterString = afterNumberFormat.format(after);

    return '$beforeString → $afterString';
  }

  @override
  String get collectionOpenAnotherPack => 'Open another pack';

  @override
  String get taskHashtags => 'Hashtags';

  @override
  String get taskBooths => 'Booths';

  @override
  String taskMissionSummary(int completed, int coins) {
    final intl.NumberFormat completedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String completedString = completedNumberFormat.format(completed);
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return '$completedString/6 completed · $coinsString coins earned';
  }

  @override
  String taskMissionRules(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return '3 confirmed friends → $coinsString coins per mission';
  }

  @override
  String taskMissionProgress(String kind, int count, String status) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$kind · $countString/3 · $status';
  }

  @override
  String get taskOwnTag => 'Your tag';

  @override
  String get taskNewTag => 'New tag';

  @override
  String get taskInProgress => 'Incomplete';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskNoMatchingFriends => 'No matching friends yet';

  @override
  String taskCompletedAt(String time) {
    return 'Completed: $time';
  }

  @override
  String taskCheckpointProgress(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/42 collected · 1 card for each first scan';
  }

  @override
  String get taskPostcardUnlocked => 'Postcard unlocked';

  @override
  String get taskPostcard => 'Postcard';

  @override
  String taskPostcardRemaining(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString more checkpoints',
      one: '1 more checkpoint',
    );
    return 'Find $_temp0 to unlock your postcard.';
  }

  @override
  String get taskOpenPostcard => 'Open postcard';

  @override
  String taskRedeemHint(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Redeem hint · $countString available';
  }

  @override
  String taskNextHint(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString more battles or booth missions',
      one: '1 more battle or booth mission',
    );
    return 'Complete $_temp0 to earn a hint';
  }

  @override
  String get taskAllCheckpointsFound => 'All checkpoints found';

  @override
  String get taskHintsActiveOnly => 'Hints are available during the event';

  @override
  String get taskHint => 'Checkpoint hint';

  @override
  String get taskLimitedCheckpoints =>
      'Limited editions · speakers / staff / sponsors';

  @override
  String taskCheckpointNumber(int number) {
    return '#$number';
  }

  @override
  String get taskNotFound => 'Not found';

  @override
  String get taskCollected => 'Collected';

  @override
  String taskCheckpointTitle(int number) {
    return 'Checkpoint #$number';
  }

  @override
  String get taskAreaHidden => 'Redeem a hint to reveal the area';

  @override
  String taskCollectedAt(String time) {
    return 'Collected: $time';
  }

  @override
  String get taskHintNotRedeemed => 'No hint redeemed for this checkpoint';

  @override
  String get taskBoothRules =>
      'Staff must scan your badge to confirm. Website visits don\'t complete tasks.';

  @override
  String taskBoothStatus(String visit, String mission, String url) {
    return '$visit · $mission\n$url';
  }

  @override
  String get taskVisited => 'Visited';

  @override
  String get taskNotVisited => 'Not visited';

  @override
  String get taskPostcardHeading => 'SITCON 2027 / POSTCARD';

  @override
  String taskPostcardGreeting(String name) {
    return 'Dear $name,';
  }

  @override
  String taskPostcardBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString checkpoints',
      one: '1 checkpoint',
    );
    return 'You found $_temp0 at SITCON 2027.';
  }

  @override
  String get taskPhysicalPostcardNotice =>
      'Physical postcard pickup and mailing details are pending. Check on-site announcements.';

  @override
  String get socialBoothOpenError =>
      'Could not open the booth website. Try again.';

  @override
  String socialCheckpointNumber(int number) {
    return 'Checkpoint #$number';
  }

  @override
  String socialCheckpointProgress(int count) {
    return 'Checkpoints $count/42';
  }

  @override
  String get socialPostcardUnlocked => 'Postcard unlocked';

  @override
  String get socialViewCheckpoints => 'View checkpoints';

  @override
  String get socialStationSupply => 'Station supply';

  @override
  String get socialScanResult => 'Scan result';

  @override
  String get socialScanPaused => 'NFC paused';

  @override
  String get socialScanStarting => 'Preparing NFC';

  @override
  String get socialScanReady => 'Ready to scan';

  @override
  String get socialScanProcessing => 'Processing scan';

  @override
  String get socialScanCancelled => 'NFC cancelled';

  @override
  String get socialScanError => 'NFC unavailable';

  @override
  String get socialScanInstruction => 'Hold a tag to the back of your phone';

  @override
  String get socialScanDuplicateHint => 'Same tag? Reopen Scan to scan again.';

  @override
  String get socialTestScan => 'Test scan';

  @override
  String get socialUid => 'NTAG UID';

  @override
  String get socialSubmitTestScan => 'Submit test scan';

  @override
  String get socialScanFixtures => 'Test tags';

  @override
  String get socialOwnBadge => 'My badge';

  @override
  String get socialCheckpointFixtures => '42 checkpoints';

  @override
  String socialStationFixture(int packs, String status, int remaining) {
    return '$packs packs/visit · $status · $remaining left';
  }

  @override
  String get socialOpen => 'Open';

  @override
  String get socialClosed => 'Closed';

  @override
  String get socialUnknownTag => 'Unassigned NTAG';

  @override
  String get socialMyCard => 'My card';

  @override
  String get socialPlayer => 'Player';

  @override
  String get socialScanPlayerFirst => 'Scan their badge first';

  @override
  String socialCooldownSeconds(int seconds) {
    return 'Cooldown: ${seconds}s';
  }

  @override
  String get socialMissionProgress => 'Matching missions';

  @override
  String socialMissionStep(String tag, int before, int after) {
    return '#$tag  $before/3 → $after/3';
  }

  @override
  String get socialAlreadyFriends => 'Already friends';

  @override
  String get socialExchangeCards => 'Exchange cards';

  @override
  String get socialAddFriend => 'Add friend';

  @override
  String get socialFriendRequests => 'Friend requests';

  @override
  String get socialFriendRequestPending => 'Waiting for them to accept';

  @override
  String get socialAccept => 'Accept';

  @override
  String get socialDecline => 'Decline';

  @override
  String get socialWaitingReciprocal => 'Waiting for their return scan';

  @override
  String get socialFriendActiveOnly => 'Friend requests open during the event';

  @override
  String get socialAskReciprocal => 'Ask them to scan your badge';

  @override
  String get socialTestAcceptFriend => 'Test: accept friend request';

  @override
  String get socialFriendExpired => 'Request expired';

  @override
  String get socialBattle => 'Battle';

  @override
  String get socialInviteBattle => 'Invite to battle';

  @override
  String socialBattleRules(int seconds) {
    return 'Up to 3 × 10s rounds · ${seconds}s cooldown';
  }

  @override
  String get socialInviteCancelled => 'Invitation cancelled';

  @override
  String get socialInviteCancelledHint => 'No cards were spent.';

  @override
  String get socialInviteSent => 'Invitation sent';

  @override
  String get socialInviteReceived => 'Battle invitation';

  @override
  String get socialBattleRespond => 'Accept or decline';

  @override
  String get socialWaitingBattleAcceptance => 'Waiting for opponent to accept';

  @override
  String get socialWaitingOpponentCard => 'Waiting for opponent\'s card';

  @override
  String get socialReady => 'Ready';

  @override
  String get socialWaitingForReady => 'Waiting for opponent to be ready';

  @override
  String get socialBattleResult => 'Battle result';

  @override
  String get socialBattleAcceptanceHint =>
      'Cards are spent only after the return scan starts the battle.';

  @override
  String get socialTestAcceptBattle => 'Test: accept battle';

  @override
  String get socialBattleRewards => 'Battle rewards';

  @override
  String socialBattleRewardSummary(int points, int coins) {
    return 'Points +$points · Coins +$coins';
  }

  @override
  String get socialNoCardDraw => 'No card drawn';

  @override
  String socialCardDraw(String card) {
    return 'Drew $card ×1';
  }

  @override
  String socialCardsUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hand cards used',
      one: '1 hand card used',
    );
    return '$_temp0';
  }

  @override
  String get socialBattleFriendAdded =>
      'Friendship and matching mission progress updated.';

  @override
  String get socialBattleCooldown => 'Battle cooldown';

  @override
  String socialRoundScore(int round, int wins, int losses) {
    return 'Round $round/3 · $wins : $losses';
  }

  @override
  String get socialChooseCard => 'Choose a card';

  @override
  String get socialAutoPlayHint => 'Auto-play when time runs out.';

  @override
  String get socialWildHint => 'Wild card move';

  @override
  String get socialPeekUsed => 'Peek used this battle';

  @override
  String socialPeekConfirm(int seconds) {
    return 'Tap again to confirm (${seconds}s)';
  }

  @override
  String socialPeekAction(int count) {
    return 'Peek ×$count · Tap twice to use';
  }

  @override
  String get socialPeekResult => 'Opponent\'s hand';

  @override
  String get socialPeekHint => 'Opponent notified';

  @override
  String get socialRoundHistory => 'Rounds';

  @override
  String socialCardVersus(String mine, String opponent) {
    return '$mine vs $opponent';
  }

  @override
  String socialWildMove(String card) {
    return '$card (Wild)';
  }

  @override
  String socialAutomaticResult(String result) {
    return '$result · Automatic play';
  }

  @override
  String socialRoundReveal(int round) {
    return 'Round $round · Reveal';
  }

  @override
  String get socialArena => 'Cards';

  @override
  String get socialMyMove => 'My move';

  @override
  String get socialWaitingMove => 'Waiting for a card';

  @override
  String get socialOpponentMove => 'Opponent\'s move';

  @override
  String get socialRevealHint => 'Cards are revealed when both players submit.';

  @override
  String socialFriendCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friends',
      one: '1 friend',
    );
    return '$_temp0';
  }

  @override
  String get socialSearchNickname => 'Search nickname';

  @override
  String get socialAll => 'All';

  @override
  String get socialNoMatchingFriends => 'No matching friends';

  @override
  String get socialRanking => 'Rankings';

  @override
  String get socialRankingFinal => 'Event ended · Rankings final';

  @override
  String get socialNotRanked => 'Not ranked yet';

  @override
  String socialMyRank(int rank) {
    return 'My rank: #$rank';
  }

  @override
  String get socialBindStation => 'Bind station';

  @override
  String socialStationDetails(
    int packs,
    int limit,
    int remaining,
    String status,
  ) {
    return '$packs packs/visit · $limit visits/person\n$remaining packs left · $status';
  }

  @override
  String get socialConfirmBinding => 'Bind tag';

  @override
  String get socialBindingUnauthorized => 'Station binding permission required';

  @override
  String get socialChooseStation => 'Select a station first';

  @override
  String get socialBindingComplete => 'Tag bound';

  @override
  String get socialBindingCompleteHint =>
      'Scan this tag to claim the station\'s packs.';

  @override
  String get utilityBattleHistory => 'Battle history';

  @override
  String get utilityLedger => 'Cards and coins';

  @override
  String utilityRoundResult(int round, String result) {
    return 'Round $round · $result';
  }

  @override
  String get utilityAutomaticPlay => 'Automatic play';

  @override
  String utilityCoinBalance(int count) {
    return 'Coin balance: $count';
  }

  @override
  String get utilityPointsSeparate => 'Coins do not affect ranking points.';

  @override
  String get utilityRecapTitle => 'My SITCON 2027';

  @override
  String get utilityNoMoves => 'No moves yet';

  @override
  String get utilityStoryTitle => 'SITCON 2027\nMY RECAP';

  @override
  String get utilityBattles => 'Battles';

  @override
  String utilityBattleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count battles',
      one: '1 battle',
    );
    return '$_temp0';
  }

  @override
  String get utilityWinRate => 'Win rate';

  @override
  String get utilityCompleteSeries => 'Complete series';

  @override
  String utilityPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friends',
      one: '1 friend',
    );
    return '$_temp0';
  }

  @override
  String get utilityHashtagMissions => 'Hashtag missions';

  @override
  String get utilityFavoriteMove => 'Favorite move';

  @override
  String get utilityOfflineRecord => 'Offline demo record';

  @override
  String get utilityTestRecord => 'Test server record';

  @override
  String get utilityGeneratingImage => 'Creating image…';

  @override
  String get utilityShareStory => 'Share recap image';

  @override
  String get utilityRecapAfterEvent => 'Final recap available after the event';

  @override
  String get operatorRoleUser => 'Attendee';

  @override
  String get operatorRoleStaff => 'Staff';

  @override
  String get operatorRoleBooth => 'Booth staff';

  @override
  String get operatorModeUser => 'Attendee';

  @override
  String get operatorModeStaff => 'Staff';

  @override
  String get operatorModeBooth => 'Booth';

  @override
  String get operatorAssignedBooth => 'Assigned booth';

  @override
  String get operatorNoBooth => 'Ask an administrator to assign a booth.';

  @override
  String get operatorReadOnlyResult => 'Tag details';

  @override
  String get operatorCompletionReceipt => 'Booth task';

  @override
  String get operatorPermissionChanged => 'Assignment changed. Return to Scan.';

  @override
  String get operatorAlreadyCompleted => 'Already completed';

  @override
  String get operatorCompletionRecorded => 'Completed';

  @override
  String get operatorScanInstruction => 'Scan badge to complete task';

  @override
  String get operatorDemoRole => 'Role';

  @override
  String get roleDomainOperatorPermission =>
      'This account cannot use that scanner mode.';

  @override
  String get roleDomainBoothAssignmentRequired =>
      'A valid booth assignment is required.';

  @override
  String get roleDomainOperatorSelfScan => 'Scan an attendee’s badge.';

  @override
  String get roleDomainStaffIdentity => 'Attendee badge';

  @override
  String get roleDomainBoothAlreadyComplete => 'Already completed';

  @override
  String get roleDomainBoothTaskComplete => 'Task completed';

  @override
  String get roleDomainAttendeeBadgeRequired =>
      'Scan a checked-in attendee’s badge.';

  @override
  String get roleDomainStaffStationInfo => 'Station details';

  @override
  String get roleDomainOperatorTagInfo => 'Event tag';

  @override
  String get roleDomainAmbiguousTag =>
      'This tag has conflicting saved bindings. Ask an administrator to resolve them.';

  @override
  String get roleDomainAmbiguousBadge =>
      'This badge has conflicting assignments.';

  @override
  String get roleDomainInvalidScannerMode => 'Unknown scanner mode.';

  @override
  String get roleDomainInvalidAccountRole => 'Unknown account role.';

  @override
  String get roleDomainLedgerRole => 'Account role assignment updated';

  @override
  String get roleDomainLedgerOperatorScan => 'Staff scan';

  @override
  String get roleDomainLedgerBoothComplete => 'Booth task completed';
}
