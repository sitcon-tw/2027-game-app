import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'package:sitcon_backend/game/game_service.dart';

import 'localization.dart';

/// Formats structured domain content only; never translates or parses prose.
String gameText(BuildContext context, Object? value) {
  final l = context.l10n;
  if (value == null) return '';
  if (value is String) return value; // Already localized by the UI owner.
  if (value is GameLocalizedError) value = value.localizedMessage;
  if (value is TimeoutException) return l.domainNetworkTimeout;
  if (value is SocketException) return l.domainNetworkUnavailable;
  if (value is FileSystemException) return l.domainStorageFailure;
  if (value is PlatformException || value is MissingPluginException) {
    return l.domainUnknownError;
  }
  if (value is! GameMessage) return l.domainUnknownError;
  final message = value;
  String text(String key) => message.args[key] as String? ?? '';
  int number(String key) => message.args[key] as int? ?? 0;
  String field(String id) => switch (id) {
    'action' => l.domainFieldAction,
    'contact' => l.domainFieldContact,
    'nickname' => l.domainFieldNickname,
    'uid' => l.domainFieldUid,
    'scanId' => l.domainFieldScanId,
    'playerId' => l.domainFieldPlayerId,
    'card' => l.domainFieldCard,
    'asCard' => l.domainFieldAsCard,
    'all' => l.domainFieldAll,
    'series' => l.domainFieldSeries,
    'planet' => l.domainFieldPlanet,
    'style' => l.domainFieldStyle,
    'stationId' => l.domainFieldStationId,
    'phase' => l.domainFieldPhase,
    'slot' => l.domainFieldSlot,
    'deliveryId' => l.domainFieldDeliveryId,
    'amount' => l.domainFieldAmount,
    'reason' => l.domainFieldReason,
    'enabled' => l.domainFieldEnabled,
    'name' => l.domainFieldName,
    'packs' => l.domainFieldPacks,
    'limit' => l.domainFieldLimit,
    'remaining' => l.domainFieldRemaining,
    'open' => l.domainFieldOpen,
    'randomEggPrice' => l.domainFieldRandomEggPrice,
    'seriesEggPrice' => l.domainFieldSeriesEggPrice,
    'hintThreshold' => l.domainFieldHintThreshold,
    'missionCoins' => l.domainFieldMissionCoins,
    'agendaPacks' => l.domainFieldAgendaPacks,
    'battleWinCoins' => l.domainFieldBattleWinCoins,
    'battleDrawCoins' => l.domainFieldBattleDrawCoins,
    'battleCooldownSeconds' => l.domainFieldBattleCooldownSeconds,
    _ => l.domainField,
  };
  final label = switch (message.code) {
    'unknownParameter' => l.domainUnknownParameter,
    'invalidStation' => l.domainInvalidStation,
    'invalidUid' => l.domainInvalidUid,
    'unsupportedSave' => l.domainUnsupportedSave,
    'checkInRequired' => l.domainCheckInRequired,
    'insufficientCoins' => l.domainInsufficientCoins,
    'playerNotFound' => l.domainPlayerNotFound,
    'invalidTags' => l.domainInvalidTags,
    'badgePhase' => l.domainBadgePhase,
    'badgeTaken' => l.domainBadgeTaken,
    'notBadge' => l.domainNotBadge,
    'badgeLocked' => l.domainBadgeLocked,
    'nicknameRequired' => l.domainNicknameRequired,
    'contactTooLong' => l.domainContactTooLong,
    'earlyPhase' => l.domainEarlyPhase,
    'scanIdRequired' => l.domainScanIdRequired,
    'scanIdConflict' => l.domainScanIdConflict,
    'scanFirst' => l.domainScanFirst,
    'opponentCardsLow' => l.domainOpponentCardsLow,
    'friendRequestExpired' => l.domainFriendRequestExpired,
    'battleCannotCancel' => l.domainBattleCannotCancel,
    'noBattle' => l.domainNoBattle,
    'cardUnavailable' => l.domainCardUnavailable,
    'wildChoiceRequired' => l.domainWildChoiceRequired,
    'normalCardFixed' => l.domainNormalCardFixed,
    'battleCardsEmpty' => l.domainBattleCardsEmpty,
    'invalidCardCount' => l.domainInvalidCardCount,
    'peekTiming' => l.domainPeekTiming,
    'peekUsed' => l.domainPeekUsed,
    'peekEmpty' => l.domainPeekEmpty,
    'packsEmpty' => l.domainPacksEmpty,
    'planetLocked' => l.domainPlanetLocked,
    'styleLocked' => l.domainStyleLocked,
    'hintsExhausted' => l.domainHintsExhausted,
    'staffRequired' => l.domainStaffRequired,
    'stationNotFound' => l.domainStationNotFound,
    'uidReserved' => l.domainUidReserved,
    'agendaRequired' => l.domainAgendaRequired,
    'boothNotFound' => l.domainBoothNotFound,
    'invalidDelivery' => l.domainInvalidDelivery,
    'deliveryConflict' => l.domainDeliveryConflict,
    'battleBusy' => l.domainBattleBusy,
    'battleCooldown' => l.domainBattleCooldown,
    'cardsLow' => l.domainCardsLow,
    'apiNotFound' => l.domainApiNotFound,
    'apiCorsDenied' => l.domainApiCorsDenied,
    'apiInvalidJson' => l.domainApiInvalidJson,
    'apiRequestTimeout' => l.domainApiRequestTimeout,
    'apiInternalError' => l.domainApiInternalError,
    'apiHostDenied' => l.domainApiHostDenied,
    'apiNetworkDenied' => l.domainApiNetworkDenied,
    'apiOriginDenied' => l.domainApiOriginDenied,
    'apiClosing' => l.domainApiClosing,
    'apiMethodNotAllowed' => l.domainApiMethodNotAllowed,
    'apiJsonRequired' => l.domainApiJsonRequired,
    'apiBodyTooLarge' => l.domainApiBodyTooLarge,
    'apiInvalidBody' => l.domainApiInvalidBody,
    'apiPlayerActionForbidden' => l.domainApiPlayerActionForbidden,
    'apiPlayerNotFound' => l.domainApiPlayerNotFound,
    'apiUnknownAdminAction' => l.domainApiUnknownAdminAction,
    'invalidTagList' => l.domainInvalidTagList,
    'invalidPhase' => l.domainInvalidPhase,
    'eventInactive' => l.domainEventInactive,
    'invalidArgument' => l.domainInvalidArgument,
    'invalidBindAddress' => l.domainInvalidBindAddress,
    'invalidSeries' => l.domainInvalidSeries,
    'eventBefore' => l.domainEventBefore,
    'eventEnded' => l.domainEventEnded,
    'parameterRange' => l.domainParameterRange(field(text('parameter'))),
    'categoryTagCount' => l.domainCategoryTagCount(
      categoryName(context, text('category')),
    ),
    'opposingTags' => l.domainOpposingTags(
      tagName(context, text('first')),
      tagName(context, text('second')),
    ),
    'coinsShort' => l.domainCoinsShort(number('amount')),
    'allPlanetsOwned' => l.domainAllPlanetsOwned,
    'seriesOwned' => l.domainSeriesOwned,
    'hintsEmpty' => l.domainHintsEmpty(number('count')),
    'unknownRanking' => l.domainUnknownRanking,
    'checkpointHint' => l.domainCheckpointHint(
      number('number'),
      areaName(context, text('area')),
    ),
    'checkpointFound' => l.domainCheckpointFound(
      number('number'),
      handName(context, number('card')),
    ),
    'checkpointRepeat' => l.domainCheckpointRepeat(number('number')),
    'stationClosed' => l.domainStationClosed,
    'stationLimit' => l.domainStationLimit,
    'stationEmpty' => l.domainStationEmpty,
    'stationPacks' => l.domainStationPacks(number('count')),
    'invalidGrant' => l.domainInvalidGrant,
    'profileTagsLocked' => l.shellTagsLocked,
    'grantTooLarge' => l.domainGrantTooLarge,
    'wireVersion' => l.domainWireVersion,
    'invalidApiOrigin' => l.domainInvalidApiOrigin,
    'deviceSessionRequired' => l.domainDeviceSessionRequired,
    'deviceTransferInvalid' => l.domainDeviceTransferInvalid,
    'deviceSessionConflict' => l.domainDeviceSessionConflict,
    'deviceSecureOriginRequired' => l.domainDeviceSecureOriginRequired,
    'deviceStorageUnavailable' => l.domainDeviceStorageUnavailable,
    'notConnected' => l.domainNotConnected,
    'serviceDisposed' => l.domainServiceDisposed,
    'networkTimeout' => l.domainNetworkTimeout,
    'networkUnavailable' => l.domainNetworkUnavailable,
    'invalidResponse' => l.domainInvalidResponse,
    'serverFailure' => l.domainServerFailure,
    'corruptSave' => l.domainCorruptSave,
    'storageFailure' => l.domainStorageFailure,
    'nfcUnsupported' => l.domainNfcUnsupported,
    'nfcInterrupted' => l.domainNfcInterrupted,
    'nfcReadFailed' => l.domainNfcReadFailed,
    'nfcDisposed' => l.domainNfcDisposed,
    'nfcBusy' => l.domainNfcBusy,
    'nfcStopFailed' => l.domainNfcStopFailed,
    'nfcDisabled' => l.domainNfcDisabled,
    'nfcInvalidTag' => l.domainNfcInvalidTag,
    'nfcTimeout' => l.domainNfcTimeout,
    'nfcStartFailed' => l.domainNfcStartFailed,
    'shareNotReady' => l.domainShareNotReady,
    'shareFailed' => l.domainShareFailed,
    'invalidString' => l.domainInvalidString(
      field(text('field')),
      number('max'),
    ),
    'invalidInteger' => l.domainInvalidInteger(
      field(text('field')),
      number('min'),
      number('max'),
    ),
    'invalidBoolean' => l.domainInvalidBoolean(field(text('field'))),
    'unknownError' => l.domainUnknownError,
    'scan.self' => l.domainScanSelf,
    'scan.player' => l.domainScanPlayer,
    'scan.checkpoint' => l.domainScanCheckpoint,
    'scan.booth' => l.domainScanBooth,
    'scan.station' => l.domainScanStation,
    'scan.unknown' => l.domainScanUnknown,
    'scan.bindStation' => l.domainScanBindStation,
    'ledger.admin.parameters' => l.domainLedgerAdminParameters,
    'ledger.admin.station' => l.domainLedgerAdminStation,
    'ledger.badge.bind' => l.domainLedgerBadgeBind,
    'ledger.profile.edit' => l.domainLedgerProfileEdit,
    'ledger.checkin' => l.domainLedgerCheckin,
    'ledger.early.unlock' => l.domainLedgerEarlyUnlock,
    'ledger.early.claim' => l.domainLedgerEarlyClaim,
    'ledger.scan.self' => l.domainLedgerScanSelf,
    'ledger.scan.player' => l.domainLedgerScanPlayer,
    'ledger.scan.checkpoint.repeat' => l.domainLedgerScanCheckpointRepeat,
    'ledger.scan.checkpoint' =>
      message.args.containsKey('card')
          ? l.domainLedgerFoundCheckpoint(
              number('number'),
              handName(context, number('card')),
            )
          : l.domainLedgerScanCheckpoint,
    'ledger.scan.booth' => l.domainLedgerScanBooth,
    'ledger.scan.station' => l.domainLedgerScanStation,
    'ledger.scan.unknown' => l.domainLedgerScanUnknown,
    'ledger.friend.request' => l.domainLedgerFriendRequest,
    'ledger.battle.accept' => l.domainLedgerBattleAccept,
    'ledger.friend.add' => l.domainLedgerFriendAdd,
    'ledger.mission.complete' =>
      message.args.containsKey('tag')
          ? l.domainLedgerCompletedMission(tagName(context, text('tag')))
          : l.domainLedgerMissionComplete,
    'ledger.battle.invite' => l.domainLedgerBattleInvite,
    'ledger.battle.cancel' => l.domainLedgerBattleCancel,
    'ledger.battle.round' => l.domainLedgerBattleRound,
    'ledger.battle.settle' => l.domainLedgerBattleSettle,
    'ledger.battle.peek' => l.domainLedgerBattlePeek,
    'ledger.battle.invite.expired' => l.domainLedgerBattleInviteExpired,
    'ledger.pack.open' =>
      message.args.containsKey('count')
          ? l.domainLedgerOpenedPacks(number('count'))
          : l.domainLedgerPackOpen,
    'ledger.egg.buy' =>
      message.args.containsKey('planet')
          ? l.domainLedgerHatchedPlanet(
              l.domainPlanetLabel(
                seriesName(context, number('planet') ~/ 7),
                colorName(context, number('planet') % 7),
              ),
            )
          : l.domainLedgerEggBuy,
    'ledger.series.complete' =>
      message.args.containsKey('series')
          ? l.domainLedgerCompletedSeries(seriesName(context, number('series')))
          : l.domainLedgerSeriesComplete,
    'ledger.appearance.edit' => l.domainLedgerAppearanceEdit,
    'ledger.hint.earn' => l.domainLedgerHintEarn,
    'ledger.hint.redeem' =>
      message.args.containsKey('number')
          ? l.domainCheckpointHint(
              number('number'),
              areaName(context, text('area')),
            )
          : l.domainLedgerHintRedeem,
    'ledger.station.bind' => l.domainLedgerStationBind,
    'ledger.mock.phase' => l.domainLedgerMockPhase,
    'ledger.mock.staff' => l.domainLedgerMockStaff,
    'ledger.mock.agenda' =>
      message.args.containsKey('amount')
          ? l.domainPacksAdded(number('amount'))
          : l.domainLedgerMockAgenda,
    'ledger.mock.booth.complete' => l.domainLedgerMockBoothComplete,
    'ledger.mock.remote' =>
      message.args.containsKey('amount')
          ? l.domainPacksAdded(number('amount'))
          : l.domainLedgerMockRemote,
    'ledger.mock.photo' => l.domainLedgerMockPhoto,
    'ledger.cheat.coins' => l.domainLedgerCheatCoins,
    'ledger.cheat.packs' => l.domainPacksAdded(number('amount')),
    'operatorPermission' => l.roleDomainOperatorPermission,
    'boothAssignmentRequired' => l.roleDomainBoothAssignmentRequired,
    'operatorSelfScan' => l.roleDomainOperatorSelfScan,
    'staffIdentity' => l.roleDomainStaffIdentity,
    'boothAlreadyComplete' => l.roleDomainBoothAlreadyComplete,
    'boothTaskComplete' => l.roleDomainBoothTaskComplete,
    'attendeeBadgeRequired' => l.roleDomainAttendeeBadgeRequired,
    'staffStationInfo' => l.roleDomainStaffStationInfo,
    'operatorTagInfo' => l.roleDomainOperatorTagInfo,
    'ambiguousTag' => l.roleDomainAmbiguousTag,
    'ambiguousBadge' => l.roleDomainAmbiguousBadge,
    'invalidScannerMode' => l.roleDomainInvalidScannerMode,
    'invalidAccountRole' => l.roleDomainInvalidAccountRole,
    'ledger.admin.role' => l.roleDomainLedgerRole,
    'ledger.scan.operator' => l.roleDomainLedgerOperatorScan,
    'ledger.booth.complete' => l.roleDomainLedgerBoothComplete,
    _ => l.domainUnknownError,
  };
  if (message.code.startsWith('ledger.')) {
    final coins = number('coins');
    if (coins != 0) {
      return l.domainLedgerCoins(label, coins > 0 ? '+$coins' : '$coins');
    }
  }
  return label;
}

String? gameTextOrNull(BuildContext context, Object? value) =>
    value == null ? null : gameText(context, value);
