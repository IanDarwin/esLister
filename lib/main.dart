import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eslister/provider/item_provider.dart';
import 'package:eslister/provider/project_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:eslister/ui/item_edit_page.dart';
import 'package:eslister/model/item.dart';
import 'package:eslister/ui/item_list_view.dart';
import 'package:eslister/data/local_db_provider.dart';
import 'package:eslister/settings/settings_controller.dart';
import 'package:eslister/settings/settings_view.dart';
import 'package:eslister/settings/settings_service.dart';

late LocalDbProvider localDbProvider;
late SettingsController settingsController;
late List cameras;
late Directory appDocsDir;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up local database
  localDbProvider = LocalDbProvider();
  await localDbProvider.open('listings.db');

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  settingsController = SettingsController(SettingsService());

  // Setup up for camera use
  cameras = await availableCameras();

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Load the application storage directory
  appDocsDir = Platform.isAndroid ?
    (await getDownloadsDirectory())! :
    (await getApplicationDocumentsDirectory())!;

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectProvider>(create: (_) => ProjectProvider()),
          ChangeNotifierProvider<ItemProvider>(create: (_) => ItemProvider()),
        ],
      child: MyApp(settingsController: settingsController))
  );
}

/// The "home" Widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  static List<Item> itemList = [];

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(

          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            // AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          // onGenerateTitle: (BuildContext context) =>
          //     AppLocalizations.of(context)!.appTitle,
          title: "Fixme I18N",

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            primaryColor: Colors.amber,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case ItemPage.routeName:
                    return ItemPage(item: Item("", []));
                    // TakePictureScreen route not useful on its own, so not here
                  case ItemListView.routeName:
                  default:
                    return const ItemListView();
                }
              },
            );
          },
        );
      },
    );
  }
}
