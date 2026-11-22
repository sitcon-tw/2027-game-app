import 'package:sitcon_backend/testing/test_tag_ids.dart';

import 'package:flutter/material.dart';

import 'package:sitcon_backend/game/game_service.dart';

import 'app_localizations.dart';

String handName(BuildContext context, int card) {
  final l = AppLocalizations.of(context);
  return switch (card) {
    0 => l.cardScissors,
    1 => l.cardRock,
    2 => l.cardPaper,
    3 => l.cardWild,
    _ => throw RangeError.range(card, 0, 3),
  };
}

String seriesName(BuildContext context, int series) {
  final l = AppLocalizations.of(context);
  return switch (series) {
    0 => l.seriesSun,
    1 => l.seriesEarth,
    2 => l.seriesMercury,
    3 => l.seriesMars,
    4 => l.seriesSaturn,
    5 => l.seriesMoon,
    _ => throw RangeError.range(series, 0, 5),
  };
}

String colorName(BuildContext context, int color) {
  final l = AppLocalizations.of(context);
  return switch (color) {
    0 => l.colorGreen,
    1 => l.colorPink,
    2 => l.colorOrange,
    3 => l.colorYellow,
    4 => l.colorLightBlue,
    5 => l.colorDarkBlue,
    6 => l.colorPurple,
    _ => throw RangeError.range(color, 0, 6),
  };
}

// These values are canonical game identifiers; localization never changes them.
String categoryName(BuildContext context, String category) {
  final l = AppLocalizations.of(context);
  return switch (category) {
    '技術' => l.categoryTechnology,
    '派系' => l.categoryFaction,
    '興趣' => l.categoryInterest,
    _ => category,
  };
}

String tagName(BuildContext context, String tag) {
  final l = AppLocalizations.of(context);
  return switch (tag) {
    '資安' => l.tagSecurity,
    '網頁前端' => l.tagFrontend,
    '後端' => l.tagBackend,
    'App開發' => l.tagAppDevelopment,
    '遊戲開發' => l.tagGameDevelopment,
    '物聯網' => l.tagIot,
    '區塊鏈' => l.tagBlockchain,
    '競程' => l.tagCompetitiveProgramming,
    '各種程式語言' => l.tagProgrammingLanguages,
    'Vim派' => l.tagVim,
    'VSCode派' => l.tagVsCode,
    'Tab派' => l.tagTabs,
    '空格派' => l.tagSpaces,
    '深色模式派' => l.tagDarkMode,
    '貓派' => l.tagCats,
    '狗派' => l.tagDogs,
    '咖哩不拌' => l.tagUnmixedCurry,
    '咖哩拌爆' => l.tagMixedCurry,
    '香菜是邪教' => l.tagNoCilantro,
    '火鍋加芋頭' => l.tagTaroHotpot,
    '夜貓族' => l.tagNightOwl,
    '咖啡續命' => l.tagCoffee,
    '手搖飲' => l.tagBubbleTea,
    '動漫' => l.tagAnime,
    '電玩' => l.tagVideoGames,
    '桌遊' => l.tagBoardGames,
    '運動' => l.tagSports,
    '音樂' => l.tagMusic,
    '攝影' => l.tagPhotography,
    '創客' => l.tagMaker,
    _ => tag,
  };
}

String roleName(BuildContext context, String role) {
  final l = AppLocalizations.of(context);
  return switch (role) {
    '會眾' => l.attendee,
    '講者' => l.speaker,
    '工人' || '工作人員' => l.staff,
    '贊助者' => l.sponsor,
    _ => role,
  };
}

String areaName(BuildContext context, String area) {
  final l = AppLocalizations.of(context);
  return switch (area) {
    '議程廳' => l.areaSessions,
    '白板大戰' => l.areaWhiteboard,
    '乾爹攤位' => l.areaSponsors,
    'Demo 展攤位' => l.areaDemos,
    '攤位區' => l.areaBooths,
    '1F Welcoming Zone' => l.areaWelcome,
    '用餐區' => l.areaDining,
    '樓梯間' => l.areaStairs,
    '移動的活動組們' => l.areaEventTeam,
    '限定款' => l.areaLimited,
    '機動' => l.areaMobile,
    _ => area,
  };
}

String boothName(BuildContext context, Booth booth) {
  final l = AppLocalizations.of(context);
  return switch (booth.id) {
    'booth-1' => l.boothCommunity,
    'booth-2' => l.boothOpenSource,
    'booth-3' => l.boothEvent,
    _ => booth.name,
  };
}

String stationName(BuildContext context, Station station) {
  final l = AppLocalizations.of(context);
  // Only translate seed labels; names entered in the dashboard remain unchanged.
  return switch ((station.id, station.name)) {
    ('station-1', '服務台（模擬）') => l.stationHelpDesk,
    ('station-2', '限量走動站（模擬）') => l.stationRoaming,
    ('station-3', '未開放站（模擬）') => l.stationClosed,
    ('station-4', '已發完站（模擬）') => l.stationEmpty,
    _ => station.name,
  };
}

final _fixturePlayerNumbers = {
  for (var number = 1; number <= 18; number++)
    TestTagIds.playerUid(number): number,
};

String playerName(BuildContext context, PlayerCard player) {
  final number = _fixturePlayerNumbers[player.id];
  return number == null
      ? player.name
      : AppLocalizations.of(context).fixturePlayer(number);
}

String playerContact(PlayerCard player) =>
    _fixturePlayerNumbers.containsKey(player.id) ? '' : player.contact;
