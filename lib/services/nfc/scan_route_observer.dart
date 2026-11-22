import 'package:flutter/widgets.dart';

/// ModalRoute deliberately includes dialogs, sheets, and popup menus, not only
/// full-screen pages: any route covering the scanner must disarm NFC.
final scanRouteObserver = RouteObserver<ModalRoute<dynamic>>();
