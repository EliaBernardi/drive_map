import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('it'),
    Locale('en'),
  ];

  /// No description provided for @home.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @telemetry.
  ///
  /// In it, this message translates to:
  /// **'Telemetria'**
  String get telemetry;

  /// No description provided for @trips.
  ///
  /// In it, this message translates to:
  /// **'Viaggi'**
  String get trips;

  /// No description provided for @profile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profile;

  /// No description provided for @demo.
  ///
  /// In it, this message translates to:
  /// **'Demo'**
  String get demo;

  /// No description provided for @obdConnected.
  ///
  /// In it, this message translates to:
  /// **'OBD connesso'**
  String get obdConnected;

  /// No description provided for @offline.
  ///
  /// In it, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @homeTitle.
  ///
  /// In it, this message translates to:
  /// **'Si parte?'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In it, this message translates to:
  /// **'La tua auto, un viaggio alla volta.'**
  String get homeSubtitle;

  /// No description provided for @garage.
  ///
  /// In it, this message translates to:
  /// **'NEL TUO GARAGE'**
  String get garage;

  /// No description provided for @vehicleSpecs.
  ///
  /// In it, this message translates to:
  /// **'2021 · 1.0 EcoBoost\n125 CV · mild hybrid'**
  String get vehicleSpecs;

  /// No description provided for @dismissMessage.
  ///
  /// In it, this message translates to:
  /// **'Chiudi messaggio'**
  String get dismissMessage;

  /// No description provided for @demoActive.
  ///
  /// In it, this message translates to:
  /// **'Demo attiva · dati simulati'**
  String get demoActive;

  /// No description provided for @foregroundNotice.
  ///
  /// In it, this message translates to:
  /// **'La raccolta si mette in pausa quando l’app passa in background. Lo schermo resta acceso mentre OBD è connesso.'**
  String get foregroundNotice;

  /// No description provided for @tripPaused.
  ///
  /// In it, this message translates to:
  /// **'Viaggio in pausa'**
  String get tripPaused;

  /// No description provided for @recordingActive.
  ///
  /// In it, this message translates to:
  /// **'Registrazione attiva'**
  String get recordingActive;

  /// No description provided for @nextTrip.
  ///
  /// In it, this message translates to:
  /// **'Il tuo prossimo viaggio'**
  String get nextTrip;

  /// No description provided for @recordingNotice.
  ///
  /// In it, this message translates to:
  /// **'I dati vengono salvati sul telefono. Lascia DriveMap aperta durante il viaggio.'**
  String get recordingNotice;

  /// No description provided for @startNotice.
  ///
  /// In it, this message translates to:
  /// **'Avvia prima di partire. Al termine potrai ritrovare ed esportare i tuoi dati in Viaggi.'**
  String get startNotice;

  /// No description provided for @startTrip.
  ///
  /// In it, this message translates to:
  /// **'Inizia viaggio'**
  String get startTrip;

  /// No description provided for @resume.
  ///
  /// In it, this message translates to:
  /// **'Riprendi'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In it, this message translates to:
  /// **'Pausa'**
  String get pause;

  /// No description provided for @finishSave.
  ///
  /// In it, this message translates to:
  /// **'Termina e salva'**
  String get finishSave;

  /// No description provided for @savedOpenArchive.
  ///
  /// In it, this message translates to:
  /// **'Viaggio salvato · apri archivio'**
  String get savedOpenArchive;

  /// No description provided for @obdConnection.
  ///
  /// In it, this message translates to:
  /// **'Connessione OBD'**
  String get obdConnection;

  /// No description provided for @validReadings.
  ///
  /// In it, this message translates to:
  /// **'Letture valide'**
  String get validReadings;

  /// No description provided for @lastResponse.
  ///
  /// In it, this message translates to:
  /// **'Ultima risposta'**
  String get lastResponse;

  /// No description provided for @reconnections.
  ///
  /// In it, this message translates to:
  /// **'Riconnessioni'**
  String get reconnections;

  /// No description provided for @openTelemetry.
  ///
  /// In it, this message translates to:
  /// **'Apri telemetria'**
  String get openTelemetry;

  /// No description provided for @disconnect.
  ///
  /// In it, this message translates to:
  /// **'Disconnetti'**
  String get disconnect;

  /// No description provided for @connectInstructions.
  ///
  /// In it, this message translates to:
  /// **'Accendi il quadro, chiudi le altre app OBD e seleziona il tuo adattatore.'**
  String get connectInstructions;

  /// No description provided for @searching.
  ///
  /// In it, this message translates to:
  /// **'Ricerca…'**
  String get searching;

  /// No description provided for @pairedDevices.
  ///
  /// In it, this message translates to:
  /// **'Dispositivi associati'**
  String get pairedDevices;

  /// No description provided for @pairDevice.
  ///
  /// In it, this message translates to:
  /// **'Associa dispositivo'**
  String get pairDevice;

  /// No description provided for @desktopNotice.
  ///
  /// In it, this message translates to:
  /// **'Su desktop: importa i viaggi o esplora la demo.'**
  String get desktopNotice;

  /// No description provided for @diagnosticsLogs.
  ///
  /// In it, this message translates to:
  /// **'Diagnostica e log OBD'**
  String get diagnosticsLogs;

  /// No description provided for @cancelConnection.
  ///
  /// In it, this message translates to:
  /// **'Annulla connessione'**
  String get cancelConnection;

  /// No description provided for @exploreDemo.
  ///
  /// In it, this message translates to:
  /// **'Esplora con la demo'**
  String get exploreDemo;

  /// No description provided for @telemetryTitle.
  ///
  /// In it, this message translates to:
  /// **'Il motore, dal vivo.'**
  String get telemetryTitle;

  /// No description provided for @telemetrySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Uno sguardo ai valori della centralina.'**
  String get telemetrySubtitle;

  /// No description provided for @waitingCar.
  ///
  /// In it, this message translates to:
  /// **'In attesa della tua auto'**
  String get waitingCar;

  /// No description provided for @connectFromHome.
  ///
  /// In it, this message translates to:
  /// **'Collega dalla Home'**
  String get connectFromHome;

  /// No description provided for @recordingInProgress.
  ///
  /// In it, this message translates to:
  /// **'Registrazione in corso'**
  String get recordingInProgress;

  /// No description provided for @manage.
  ///
  /// In it, this message translates to:
  /// **'Gestisci'**
  String get manage;

  /// No description provided for @availableParameters.
  ///
  /// In it, this message translates to:
  /// **'Parametri disponibili'**
  String get availableParameters;

  /// No description provided for @available.
  ///
  /// In it, this message translates to:
  /// **'disponibile'**
  String get available;

  /// No description provided for @unsupported.
  ///
  /// In it, this message translates to:
  /// **'non supportato'**
  String get unsupported;

  /// No description provided for @missingParameters.
  ///
  /// In it, this message translates to:
  /// **'I parametri non disponibili sono indicati con —.'**
  String get missingParameters;

  /// No description provided for @liveTelemetry.
  ///
  /// In it, this message translates to:
  /// **'TELEMETRIA LIVE'**
  String get liveTelemetry;

  /// No description provided for @waitingData.
  ///
  /// In it, this message translates to:
  /// **'In attesa dei dati del veicolo'**
  String get waitingData;

  /// No description provided for @screenRefresh.
  ///
  /// In it, this message translates to:
  /// **'Schermo aggiornato ogni 0,5 s'**
  String get screenRefresh;

  /// No description provided for @profileTitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo veicolo.'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In it, this message translates to:
  /// **'La tua Fiesta e gli strumenti di bordo.'**
  String get profileSubtitle;

  /// No description provided for @engine.
  ///
  /// In it, this message translates to:
  /// **'Motore'**
  String get engine;

  /// No description provided for @engineSpecs.
  ///
  /// In it, this message translates to:
  /// **'125 CV · mild hybrid'**
  String get engineSpecs;

  /// No description provided for @fuelType.
  ///
  /// In it, this message translates to:
  /// **'Alimentazione'**
  String get fuelType;

  /// No description provided for @petrol.
  ///
  /// In it, this message translates to:
  /// **'Benzina'**
  String get petrol;

  /// No description provided for @adapter.
  ///
  /// In it, this message translates to:
  /// **'Adattatore'**
  String get adapter;

  /// No description provided for @analysisSettings.
  ///
  /// In it, this message translates to:
  /// **'Parametri di analisi'**
  String get analysisSettings;

  /// No description provided for @analysisSettingsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Personalizza soglie e pesi della guida.'**
  String get analysisSettingsSubtitle;

  /// No description provided for @localTripsNotice.
  ///
  /// In it, this message translates to:
  /// **'I viaggi restano sul tuo telefono. Puoi esportarli dalla sezione Viaggi per consultarli anche sul computer.'**
  String get localTripsNotice;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @languageItalian.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageEnglish.
  ///
  /// In it, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHint.
  ///
  /// In it, this message translates to:
  /// **'Scegli la lingua dell’app. La preferenza resta salvata su questo telefono.'**
  String get languageHint;

  /// No description provided for @languageSaveFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare la lingua. Riprova.'**
  String get languageSaveFailed;

  /// No description provided for @languageLoadFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare la lingua salvata.'**
  String get languageLoadFailed;

  /// No description provided for @restoreModel.
  ///
  /// In it, this message translates to:
  /// **'Ripristina modello iniziale'**
  String get restoreModel;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Uno score che puoi capire.'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Regole esplicite, pesi modificabili e nessuna scatola nera.'**
  String get settingsSubtitle;

  /// No description provided for @heuristicModel.
  ///
  /// In it, this message translates to:
  /// **'Modello euristico · rules-1.0.0'**
  String get heuristicModel;

  /// No description provided for @settingsNotice.
  ///
  /// In it, this message translates to:
  /// **'Le impostazioni si applicano ai nuovi viaggi. Ogni viaggio conserva la propria configurazione, così lo score può essere ricalcolato in modo riproducibile.'**
  String get settingsNotice;

  /// No description provided for @loadNotice.
  ///
  /// In it, this message translates to:
  /// **'Calculated load è un proxy del carico. L’indice relativo rappresenta la favorevolezza delle zone secondo queste regole; non è una misura di coppia, potenza o rendimento termico.'**
  String get loadNotice;

  /// No description provided for @componentWeights.
  ///
  /// In it, this message translates to:
  /// **'Il peso di ogni componente'**
  String get componentWeights;

  /// No description provided for @weightsNotice.
  ///
  /// In it, this message translates to:
  /// **'I pesi vengono rinormalizzati sulle componenti disponibili. Valori iniziali: 0,40 / 0,25 / 0,20 / 0,15.'**
  String get weightsNotice;

  /// No description provided for @operatingZones.
  ///
  /// In it, this message translates to:
  /// **'Zone operative'**
  String get operatingZones;

  /// No description provided for @smoothness.
  ///
  /// In it, this message translates to:
  /// **'Regolarità'**
  String get smoothness;

  /// No description provided for @warmup.
  ///
  /// In it, this message translates to:
  /// **'Riscaldamento'**
  String get warmup;

  /// No description provided for @relativeEconomy.
  ///
  /// In it, this message translates to:
  /// **'Consumo relativo'**
  String get relativeEconomy;

  /// No description provided for @engineZones.
  ///
  /// In it, this message translates to:
  /// **'Le zone del motore'**
  String get engineZones;

  /// No description provided for @engineZonesNotice.
  ///
  /// In it, this message translates to:
  /// **'Favorevole: regime tra le soglie e carico tra 20% e soglia alta. Sfavorevole: alto regime, oppure basso regime con carico elevato.'**
  String get engineZonesNotice;

  /// No description provided for @lowRpm.
  ///
  /// In it, this message translates to:
  /// **'Regime minimo favorevole · rpm'**
  String get lowRpm;

  /// No description provided for @highRpm.
  ///
  /// In it, this message translates to:
  /// **'Soglia alto regime · rpm'**
  String get highRpm;

  /// No description provided for @highLoad.
  ///
  /// In it, this message translates to:
  /// **'Soglia alto carico · %'**
  String get highLoad;

  /// No description provided for @warmupSmoothness.
  ///
  /// In it, this message translates to:
  /// **'Riscaldamento e regolarità'**
  String get warmupSmoothness;

  /// No description provided for @accelerationNotice.
  ///
  /// In it, this message translates to:
  /// **'Le accelerazioni sono derivate dai timestamp originali della velocità OBD. Gli eventi sono conteggiati all’ingresso nella condizione e rapportati al minuto.'**
  String get accelerationNotice;

  /// No description provided for @warmTemperature.
  ///
  /// In it, this message translates to:
  /// **'Fine riscaldamento · °C'**
  String get warmTemperature;

  /// No description provided for @coldLoad.
  ///
  /// In it, this message translates to:
  /// **'Carico consentito a freddo · %'**
  String get coldLoad;

  /// No description provided for @hardAccelerationThreshold.
  ///
  /// In it, this message translates to:
  /// **'Accelerazione brusca · m/s²'**
  String get hardAccelerationThreshold;

  /// No description provided for @hardAccelerationEvent.
  ///
  /// In it, this message translates to:
  /// **'Accelerazione brusca'**
  String get hardAccelerationEvent;

  /// No description provided for @hardBrakingEvent.
  ///
  /// In it, this message translates to:
  /// **'Frenata brusca'**
  String get hardBrakingEvent;

  /// No description provided for @hardBrakingThreshold.
  ///
  /// In it, this message translates to:
  /// **'Frenata brusca · m/s²'**
  String get hardBrakingThreshold;

  /// No description provided for @economyBaseline.
  ///
  /// In it, this message translates to:
  /// **'Baseline di consumo'**
  String get economyBaseline;

  /// No description provided for @baselineNotice.
  ///
  /// In it, this message translates to:
  /// **'Imposta 0 per escludere la componente economy. Una baseline deve provenire da viaggi comparabili per percorso, temperatura e traffico. La sola quantità di carburante non misura l’efficienza.'**
  String get baselineNotice;

  /// No description provided for @baselineConsumption.
  ///
  /// In it, this message translates to:
  /// **'Consumo di riferimento · l/100 km'**
  String get baselineConsumption;

  /// No description provided for @saving.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio…'**
  String get saving;

  /// No description provided for @saveModel.
  ///
  /// In it, this message translates to:
  /// **'Salva modello'**
  String get saveModel;

  /// No description provided for @defaults.
  ///
  /// In it, this message translates to:
  /// **'Valori iniziali'**
  String get defaults;

  /// No description provided for @studyProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo di studio: Ford Fiesta 2021 · OBDLink MX+\nAcquisizione mobile in primo piano. Android: RFCOMM. iOS: ExternalAccessory, previa configurazione e abilitazione del produttore. Desktop: importazione e analisi.\nNessuna scrittura ECU o cancellazione errori è esposta nell’app.'**
  String get studyProfile;

  /// No description provided for @modelSaved.
  ///
  /// In it, this message translates to:
  /// **'Modello salvato per i prossimi viaggi.'**
  String get modelSaved;

  /// No description provided for @tripsTitle.
  ///
  /// In it, this message translates to:
  /// **'Ogni viaggio ha una storia.'**
  String get tripsTitle;

  /// No description provided for @tripsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ritrova i percorsi, esplora il motore e confronta i risultati.'**
  String get tripsSubtitle;

  /// No description provided for @importing.
  ///
  /// In it, this message translates to:
  /// **'Importazione…'**
  String get importing;

  /// No description provided for @importData.
  ///
  /// In it, this message translates to:
  /// **'Importa CSV / DriveMap'**
  String get importData;

  /// No description provided for @refreshTrips.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna viaggi'**
  String get refreshTrips;

  /// No description provided for @archiveUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Archivio non disponibile'**
  String get archiveUnavailable;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @firstTrip.
  ///
  /// In it, this message translates to:
  /// **'Il primo viaggio ti aspetta'**
  String get firstTrip;

  /// No description provided for @firstTripNotice.
  ///
  /// In it, this message translates to:
  /// **'Inizia un viaggio dalla Home oppure importa un CSV. Puoi provare anche la demo: i dati simulati saranno riconoscibili in archivio.'**
  String get firstTripNotice;

  /// No description provided for @importedCsv.
  ///
  /// In it, this message translates to:
  /// **'CSV importato'**
  String get importedCsv;

  /// No description provided for @realObd.
  ///
  /// In it, this message translates to:
  /// **'OBD reale'**
  String get realObd;

  /// No description provided for @interruptedRecovered.
  ///
  /// In it, this message translates to:
  /// **'Interrotto · recuperato'**
  String get interruptedRecovered;

  /// No description provided for @openSession.
  ///
  /// In it, this message translates to:
  /// **'Sessione aperta'**
  String get openSession;

  /// No description provided for @analyzeTrip.
  ///
  /// In it, this message translates to:
  /// **'Analizza viaggio'**
  String get analyzeTrip;

  /// No description provided for @deleteTrip.
  ///
  /// In it, this message translates to:
  /// **'Elimina viaggio'**
  String get deleteTrip;

  /// No description provided for @deleteTripQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il viaggio?'**
  String get deleteTripQuestion;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @fileSizeLimit.
  ///
  /// In it, this message translates to:
  /// **'Limite file: 30 MB. Suddividi i viaggi più grandi.'**
  String get fileSizeLimit;

  /// No description provided for @unknownBundle.
  ///
  /// In it, this message translates to:
  /// **'Formato DriveMap non riconosciuto.'**
  String get unknownBundle;

  /// No description provided for @invalidFrameCount.
  ///
  /// In it, this message translates to:
  /// **'Numero di frame non valido (2–200.000).'**
  String get invalidFrameCount;

  /// No description provided for @tooManyRaw.
  ///
  /// In it, this message translates to:
  /// **'Troppi campioni raw.'**
  String get tooManyRaw;

  /// No description provided for @tripAnalysis.
  ///
  /// In it, this message translates to:
  /// **'Analisi viaggio'**
  String get tripAnalysis;

  /// No description provided for @exportTrip.
  ///
  /// In it, this message translates to:
  /// **'Esporta viaggio'**
  String get exportTrip;

  /// No description provided for @exportBundle.
  ///
  /// In it, this message translates to:
  /// **'DriveMap · dati, raw e modello'**
  String get exportBundle;

  /// No description provided for @exportTelemetry.
  ///
  /// In it, this message translates to:
  /// **'CSV · telemetria e orari PID'**
  String get exportTelemetry;

  /// No description provided for @exportRaw.
  ///
  /// In it, this message translates to:
  /// **'CSV · risposte OBD raw'**
  String get exportRaw;

  /// No description provided for @demoTripNotice.
  ///
  /// In it, this message translates to:
  /// **'Viaggio dimostrativo · telemetria simulata'**
  String get demoTripNotice;

  /// No description provided for @csvTripNotice.
  ///
  /// In it, this message translates to:
  /// **'CSV · origine e unità definite in importazione'**
  String get csvTripNotice;

  /// No description provided for @tripEvents.
  ///
  /// In it, this message translates to:
  /// **'Gli eventi del viaggio'**
  String get tripEvents;

  /// No description provided for @noEvents.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento rilevato nei campioni disponibili.'**
  String get noEvents;

  /// No description provided for @firstHundredEvents.
  ///
  /// In it, this message translates to:
  /// **'Visualizzati i primi 100 eventi. Tutti i dati sono disponibili in esportazione.'**
  String get firstHundredEvents;

  /// No description provided for @exportCompleted.
  ///
  /// In it, this message translates to:
  /// **'Esportazione completata.'**
  String get exportCompleted;

  /// No description provided for @observedTime.
  ///
  /// In it, this message translates to:
  /// **'Tempo osservato'**
  String get observedTime;

  /// No description provided for @integratedDistance.
  ///
  /// In it, this message translates to:
  /// **'Distanza integrata'**
  String get integratedDistance;

  /// No description provided for @integratedFuel.
  ///
  /// In it, this message translates to:
  /// **'Carburante integrato'**
  String get integratedFuel;

  /// No description provided for @estimatedConsumption.
  ///
  /// In it, this message translates to:
  /// **'Consumo stimato'**
  String get estimatedConsumption;

  /// No description provided for @yourScore.
  ///
  /// In it, this message translates to:
  /// **'IL TUO SCORE'**
  String get yourScore;

  /// No description provided for @explainable.
  ///
  /// In it, this message translates to:
  /// **'Spiegabile · v1'**
  String get explainable;

  /// No description provided for @notCalculated.
  ///
  /// In it, this message translates to:
  /// **'Non calcolato'**
  String get notCalculated;

  /// No description provided for @compareTrips.
  ///
  /// In it, this message translates to:
  /// **'Due viaggi, a confronto'**
  String get compareTrips;

  /// No description provided for @comparisonNotice.
  ///
  /// In it, this message translates to:
  /// **'Confronta percorsi e condizioni simili. Traffico, temperatura e pendenza possono cambiare i risultati.'**
  String get comparisonNotice;

  /// No description provided for @differentModels.
  ///
  /// In it, this message translates to:
  /// **'Modelli diversi: score non direttamente comparabili'**
  String get differentModels;

  /// No description provided for @differentSources.
  ///
  /// In it, this message translates to:
  /// **'Origini dei dati diverse'**
  String get differentSources;

  /// No description provided for @metric.
  ///
  /// In it, this message translates to:
  /// **'Metrica'**
  String get metric;

  /// No description provided for @tripA.
  ///
  /// In it, this message translates to:
  /// **'Viaggio A'**
  String get tripA;

  /// No description provided for @tripB.
  ///
  /// In it, this message translates to:
  /// **'Viaggio B'**
  String get tripB;

  /// No description provided for @scoreMetric.
  ///
  /// In it, this message translates to:
  /// **'Score / 100'**
  String get scoreMetric;

  /// No description provided for @distanceMetric.
  ///
  /// In it, this message translates to:
  /// **'Distanza km'**
  String get distanceMetric;

  /// No description provided for @consumptionMetric.
  ///
  /// In it, this message translates to:
  /// **'Consumo l/100 km'**
  String get consumptionMetric;

  /// No description provided for @favorableZones.
  ///
  /// In it, this message translates to:
  /// **'Zone favorevoli'**
  String get favorableZones;

  /// No description provided for @drivingEvents.
  ///
  /// In it, this message translates to:
  /// **'Eventi di guida'**
  String get drivingEvents;

  /// No description provided for @mappedTime.
  ///
  /// In it, this message translates to:
  /// **'Tempo mappato'**
  String get mappedTime;

  /// No description provided for @mapCsvColumns.
  ///
  /// In it, this message translates to:
  /// **'Associa le colonne del CSV'**
  String get mapCsvColumns;

  /// No description provided for @time.
  ///
  /// In it, this message translates to:
  /// **'Tempo'**
  String get time;

  /// No description provided for @elapsedSeconds.
  ///
  /// In it, this message translates to:
  /// **'Tempo in secondi dall’inizio'**
  String get elapsedSeconds;

  /// No description provided for @isoTimeNotice.
  ///
  /// In it, this message translates to:
  /// **'Disattiva per timestamp ISO 8601 con fuso orario.'**
  String get isoTimeNotice;

  /// No description provided for @tripStartIso.
  ///
  /// In it, this message translates to:
  /// **'Inizio viaggio · ISO 8601 con fuso'**
  String get tripStartIso;

  /// No description provided for @invalidOrigin.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un inizio viaggio ISO con fuso, ad esempio 2026-10-01T10:00:00+02:00.'**
  String get invalidOrigin;

  /// No description provided for @importTrip.
  ///
  /// In it, this message translates to:
  /// **'Importa viaggio'**
  String get importTrip;

  /// No description provided for @notPresent.
  ///
  /// In it, this message translates to:
  /// **'Non presente'**
  String get notPresent;

  /// No description provided for @engineMap.
  ///
  /// In it, this message translates to:
  /// **'La mappa del tuo motore'**
  String get engineMap;

  /// No description provided for @engineMapSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Dove ha lavorato il motore, e con quale costo osservato.'**
  String get engineMapSubtitle;

  /// No description provided for @occupancy.
  ///
  /// In it, this message translates to:
  /// **'Permanenza'**
  String get occupancy;

  /// No description provided for @fuel.
  ///
  /// In it, this message translates to:
  /// **'Carburante'**
  String get fuel;

  /// No description provided for @relativeIndex.
  ///
  /// In it, this message translates to:
  /// **'Indice relativo'**
  String get relativeIndex;

  /// No description provided for @penalty.
  ///
  /// In it, this message translates to:
  /// **'Penalità'**
  String get penalty;

  /// No description provided for @mapRequiresData.
  ///
  /// In it, this message translates to:
  /// **'Servono RPM e calculated load validi\nper costruire la mappa.'**
  String get mapRequiresData;

  /// No description provided for @occupancyLegend.
  ///
  /// In it, this message translates to:
  /// **'Da meno a più tempo · celle da 500 rpm × 10%'**
  String get occupancyLegend;

  /// No description provided for @fuelLegend.
  ///
  /// In it, this message translates to:
  /// **'Flusso medio in l/h · solo dati disponibili'**
  String get fuelLegend;

  /// No description provided for @relativeLegend.
  ///
  /// In it, this message translates to:
  /// **'Da 0 a 100 · favorevolezza secondo le regole'**
  String get relativeLegend;

  /// No description provided for @penaltyLegend.
  ///
  /// In it, this message translates to:
  /// **'Da 0 a 1 · costo medio delle zone'**
  String get penaltyLegend;

  /// No description provided for @mapNotice.
  ///
  /// In it, this message translates to:
  /// **'Mappa delle condizioni osservate. L’indice relativo descrive le regole del modello: non misura il rendimento termico o la BSFC.'**
  String get mapNotice;

  /// No description provided for @loadAxis.
  ///
  /// In it, this message translates to:
  /// **'Carico %'**
  String get loadAxis;

  /// No description provided for @rpmAxis.
  ///
  /// In it, this message translates to:
  /// **'Regime motore · rpm'**
  String get rpmAxis;

  /// No description provided for @timelineTitle.
  ///
  /// In it, this message translates to:
  /// **'Il viaggio, istante per istante'**
  String get timelineTitle;

  /// No description provided for @timelineSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tocca il grafico per leggere un campione. I punti arancioni indicano eventi di guida.'**
  String get timelineSubtitle;

  /// No description provided for @insufficientSamples.
  ///
  /// In it, this message translates to:
  /// **'Campioni insufficienti'**
  String get insufficientSamples;

  /// No description provided for @parameterUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Parametro non disponibile in questo viaggio'**
  String get parameterUnavailable;

  /// No description provided for @connectObdLink.
  ///
  /// In it, this message translates to:
  /// **'Collega la tua OBDLink'**
  String get connectObdLink;

  /// No description provided for @scanInstructions.
  ///
  /// In it, this message translates to:
  /// **'Accendi il quadro e metti l’adattatore in modalità associazione. La ricerca usa Bluetooth Classic.'**
  String get scanInstructions;

  /// No description provided for @addObd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi OBD'**
  String get addObd;

  /// No description provided for @androidScanOnly.
  ///
  /// In it, this message translates to:
  /// **'La ricerca Bluetooth Classic è disponibile su Android.'**
  String get androidScanOnly;

  /// No description provided for @bluetoothDevices.
  ///
  /// In it, this message translates to:
  /// **'Dispositivi Bluetooth'**
  String get bluetoothDevices;

  /// No description provided for @stopSearch.
  ///
  /// In it, this message translates to:
  /// **'Ferma ricerca'**
  String get stopSearch;

  /// No description provided for @searchAgain.
  ///
  /// In it, this message translates to:
  /// **'Cerca di nuovo'**
  String get searchAgain;

  /// No description provided for @onlyObdLink.
  ///
  /// In it, this message translates to:
  /// **'Mostra solo OBDLink'**
  String get onlyObdLink;

  /// No description provided for @scanningNearby.
  ///
  /// In it, this message translates to:
  /// **'Ricerca in corso… Avvicina il telefono e attiva il pairing su MX+.'**
  String get scanningNearby;

  /// No description provided for @noVisibleDevices.
  ///
  /// In it, this message translates to:
  /// **'Nessun dispositivo visibile. Riprova o disattiva il filtro OBDLink.'**
  String get noVisibleDevices;

  /// No description provided for @unnamedDevice.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo senza nome'**
  String get unnamedDevice;

  /// No description provided for @alreadyPaired.
  ///
  /// In it, this message translates to:
  /// **'Già associato'**
  String get alreadyPaired;

  /// No description provided for @notPaired.
  ///
  /// In it, this message translates to:
  /// **'Da associare'**
  String get notPaired;

  /// No description provided for @standardPids.
  ///
  /// In it, this message translates to:
  /// **'PID standard disponibili'**
  String get standardPids;

  /// No description provided for @repeatAti.
  ///
  /// In it, this message translates to:
  /// **'Ripeti ATI'**
  String get repeatAti;

  /// No description provided for @bluetoothSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni Bluetooth'**
  String get bluetoothSettings;

  /// No description provided for @exportLogs.
  ///
  /// In it, this message translates to:
  /// **'Esporta log in un file .txt'**
  String get exportLogs;

  /// No description provided for @commandsResponses.
  ///
  /// In it, this message translates to:
  /// **'Comandi e risposte'**
  String get commandsResponses;

  /// No description provided for @noCommands.
  ///
  /// In it, this message translates to:
  /// **'Nessun comando inviato.'**
  String get noCommands;

  /// No description provided for @pidTestTitle.
  ///
  /// In it, this message translates to:
  /// **'Test dei parametri · 30 secondi'**
  String get pidTestTitle;

  /// No description provided for @pidTestNotice.
  ///
  /// In it, this message translates to:
  /// **'Interroga in sequenza i PID principali, il livello carburante e il contachilometri. Il carburante è espresso in percentuale, non in litri. Avvia il test a veicolo fermo; non usare il telefono durante la guida.'**
  String get pidTestNotice;

  /// No description provided for @testConsumption.
  ///
  /// In it, this message translates to:
  /// **'Consumo medio stimato nel test'**
  String get testConsumption;

  /// No description provided for @testConsumptionUnavailable.
  ///
  /// In it, this message translates to:
  /// **'— L/100 km · distanza troppo breve o letture non disponibili'**
  String get testConsumptionUnavailable;

  /// No description provided for @stopTest.
  ///
  /// In it, this message translates to:
  /// **'Interrompi test'**
  String get stopTest;

  /// No description provided for @startPidTest.
  ///
  /// In it, this message translates to:
  /// **'Avvia test PID 30 s'**
  String get startPidTest;

  /// No description provided for @noTestablePids.
  ///
  /// In it, this message translates to:
  /// **'Nessun PID principale disponibile per il test.'**
  String get noTestablePids;

  /// No description provided for @diagnosticLog.
  ///
  /// In it, this message translates to:
  /// **'DriveMap · log diagnostico'**
  String get diagnosticLog;

  /// No description provided for @noLogEvents.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento registrato in questa sessione.'**
  String get noLogEvents;

  /// No description provided for @serialEvents.
  ///
  /// In it, this message translates to:
  /// **'Eventi e traffico seriale:'**
  String get serialEvents;

  /// No description provided for @none.
  ///
  /// In it, this message translates to:
  /// **'nessuno'**
  String get none;

  /// No description provided for @notDetected.
  ///
  /// In it, this message translates to:
  /// **'non rilevata'**
  String get notDetected;

  /// No description provided for @protocolNotDetected.
  ///
  /// In it, this message translates to:
  /// **'non rilevato'**
  String get protocolNotDetected;

  /// No description provided for @noPidsDetected.
  ///
  /// In it, this message translates to:
  /// **'nessuno rilevato'**
  String get noPidsDetected;

  /// No description provided for @pidLoad.
  ///
  /// In it, this message translates to:
  /// **'Carico motore'**
  String get pidLoad;

  /// No description provided for @pidCoolant.
  ///
  /// In it, this message translates to:
  /// **'Refrigerante'**
  String get pidCoolant;

  /// No description provided for @pidManifold.
  ///
  /// In it, this message translates to:
  /// **'Pressione collettore'**
  String get pidManifold;

  /// No description provided for @pidRpm.
  ///
  /// In it, this message translates to:
  /// **'Regime motore'**
  String get pidRpm;

  /// No description provided for @pidSpeed.
  ///
  /// In it, this message translates to:
  /// **'Velocità'**
  String get pidSpeed;

  /// No description provided for @pidThrottle.
  ///
  /// In it, this message translates to:
  /// **'Farfalla'**
  String get pidThrottle;

  /// No description provided for @pidVoltage.
  ///
  /// In it, this message translates to:
  /// **'Tensione centralina'**
  String get pidVoltage;

  /// No description provided for @pidFuelRate.
  ///
  /// In it, this message translates to:
  /// **'Flusso carburante'**
  String get pidFuelRate;

  /// No description provided for @pidFuelLevel.
  ///
  /// In it, this message translates to:
  /// **'Livello carburante'**
  String get pidFuelLevel;

  /// No description provided for @pidTorque.
  ///
  /// In it, this message translates to:
  /// **'Coppia motore effettiva'**
  String get pidTorque;

  /// No description provided for @pidReferenceTorque.
  ///
  /// In it, this message translates to:
  /// **'Coppia motore di riferimento'**
  String get pidReferenceTorque;

  /// No description provided for @pidOdometer.
  ///
  /// In it, this message translates to:
  /// **'Contachilometri totale'**
  String get pidOdometer;

  /// No description provided for @connectCar.
  ///
  /// In it, this message translates to:
  /// **'Collega la tua auto'**
  String get connectCar;

  /// No description provided for @bluetoothConnecting.
  ///
  /// In it, this message translates to:
  /// **'Connessione Bluetooth…'**
  String get bluetoothConnecting;

  /// No description provided for @telemetryActive.
  ///
  /// In it, this message translates to:
  /// **'Telemetria attiva'**
  String get telemetryActive;

  /// No description provided for @connectionFailedNotice.
  ///
  /// In it, this message translates to:
  /// **'Connessione non riuscita. Controlla quadro acceso, Bluetooth e che OBDLink sia chiusa, poi riprova.'**
  String get connectionFailedNotice;

  /// No description provided for @initializingAdapter.
  ///
  /// In it, this message translates to:
  /// **'Inizializzazione OBDLink…'**
  String get initializingAdapter;

  /// No description provided for @discoveringPids.
  ///
  /// In it, this message translates to:
  /// **'Verifica centralina e PID supportati…'**
  String get discoveringPids;

  /// No description provided for @disconnected.
  ///
  /// In it, this message translates to:
  /// **'Disconnesso'**
  String get disconnected;

  /// No description provided for @pidsNotChecked.
  ///
  /// In it, this message translates to:
  /// **'PID non ancora verificati'**
  String get pidsNotChecked;

  /// No description provided for @bluetoothSearching.
  ///
  /// In it, this message translates to:
  /// **'Ricerca Bluetooth in corso…'**
  String get bluetoothSearching;

  /// No description provided for @searchFinished.
  ///
  /// In it, this message translates to:
  /// **'Ricerca terminata'**
  String get searchFinished;

  /// No description provided for @connectionFailed.
  ///
  /// In it, this message translates to:
  /// **'Connessione non riuscita'**
  String get connectionFailed;

  /// No description provided for @linkNeedsRestore.
  ///
  /// In it, this message translates to:
  /// **'Collegamento da ripristinare'**
  String get linkNeedsRestore;

  /// No description provided for @noMainPids.
  ///
  /// In it, this message translates to:
  /// **'Nessun PID principale supportato da interrogare.'**
  String get noMainPids;

  /// No description provided for @stopRequested.
  ///
  /// In it, this message translates to:
  /// **'Interruzione richiesta…'**
  String get stopRequested;

  /// No description provided for @adapterIdentifiedSearching.
  ///
  /// In it, this message translates to:
  /// **'Adattatore identificato · ricerca PID in corso'**
  String get adapterIdentifiedSearching;

  /// No description provided for @adapterConfiguring.
  ///
  /// In it, this message translates to:
  /// **'Configuro l’adattatore e interrogo la centralina…'**
  String get adapterConfiguring;

  /// No description provided for @standardPidsQuery.
  ///
  /// In it, this message translates to:
  /// **'Interrogo i PID standard (01–20)…'**
  String get standardPidsQuery;

  /// No description provided for @ecuNoData.
  ///
  /// In it, this message translates to:
  /// **'La centralina non ha risposto a 0100 (NO DATA).'**
  String get ecuNoData;

  /// No description provided for @invalid0100.
  ///
  /// In it, this message translates to:
  /// **'Nessuna risposta OBD valida a 0100.'**
  String get invalid0100;

  /// No description provided for @adapterNoEcu.
  ///
  /// In it, this message translates to:
  /// **'Adattatore connesso · centralina non rilevata'**
  String get adapterNoEcu;

  /// No description provided for @noStandardPids.
  ///
  /// In it, this message translates to:
  /// **'Nessun PID standard supportato rilevato.'**
  String get noStandardPids;

  /// No description provided for @adapterIdentified.
  ///
  /// In it, this message translates to:
  /// **'Adattatore identificato'**
  String get adapterIdentified;

  /// No description provided for @adapterIncompletePids.
  ///
  /// In it, this message translates to:
  /// **'Adattatore connesso · verifica PID incompleta'**
  String get adapterIncompletePids;

  /// No description provided for @disconnecting.
  ///
  /// In it, this message translates to:
  /// **'Disconnessione…'**
  String get disconnecting;

  /// No description provided for @simulator.
  ///
  /// In it, this message translates to:
  /// **'Simulatore OBD'**
  String get simulator;

  /// No description provided for @demoTrip.
  ///
  /// In it, this message translates to:
  /// **'Viaggio dimostrativo'**
  String get demoTrip;

  /// No description provided for @linkLostTripPaused.
  ///
  /// In it, this message translates to:
  /// **'Collegamento OBD perso dopo i tentativi di riconnessione. Il viaggio è in pausa: riconnetti l’adattatore e tocca Riprendi.'**
  String get linkLostTripPaused;

  /// No description provided for @zoneReason.
  ///
  /// In it, this message translates to:
  /// **'Tempo ponderato nelle zone RPM–carico: costo 0, 0,5 o 1.'**
  String get zoneReason;

  /// No description provided for @smoothReason.
  ///
  /// In it, this message translates to:
  /// **'−5 punti per evento al minuto; accelerazione derivata dalla velocità OBD.'**
  String get smoothReason;

  /// No description provided for @economyExcluded.
  ///
  /// In it, this message translates to:
  /// **'Escluso: configura una baseline di viaggi comparabili per questo veicolo.'**
  String get economyExcluded;

  /// No description provided for @scoreRequiresData.
  ///
  /// In it, this message translates to:
  /// **'Servono almeno 5 secondi di dati validi per calcolare le componenti dello score.'**
  String get scoreRequiresData;

  /// No description provided for @scoreNoMap.
  ///
  /// In it, this message translates to:
  /// **'Mappa non disponibile: RPM o carico mancanti. '**
  String get scoreNoMap;

  /// No description provided for @scoreWeightsNormalized.
  ///
  /// In it, this message translates to:
  /// **'I pesi delle componenti disponibili sono rinormalizzati. '**
  String get scoreWeightsNormalized;

  /// No description provided for @saveSettingsFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare le impostazioni.'**
  String get saveSettingsFailed;

  /// No description provided for @finiteParameters.
  ///
  /// In it, this message translates to:
  /// **'I parametri devono essere numeri finiti.'**
  String get finiteParameters;

  /// No description provided for @invalidSettings.
  ///
  /// In it, this message translates to:
  /// **'Controlla pesi, soglie e baseline: i valori non sono validi.'**
  String get invalidSettings;

  /// No description provided for @csvRequiresRows.
  ///
  /// In it, this message translates to:
  /// **'Il CSV deve contenere un’intestazione e almeno una riga.'**
  String get csvRequiresRows;

  /// No description provided for @csvRowLimit.
  ///
  /// In it, this message translates to:
  /// **'Limite di importazione: 200.000 righe per viaggio.'**
  String get csvRowLimit;

  /// No description provided for @selectTimeColumn.
  ///
  /// In it, this message translates to:
  /// **'Seleziona la colonna del tempo.'**
  String get selectTimeColumn;

  /// No description provided for @mapObdParameter.
  ///
  /// In it, this message translates to:
  /// **'Associa almeno un parametro OBD.'**
  String get mapObdParameter;

  /// No description provided for @distinctColumns.
  ///
  /// In it, this message translates to:
  /// **'Ogni parametro deve usare una colonna distinta.'**
  String get distinctColumns;

  /// No description provided for @fuelRateUnits.
  ///
  /// In it, this message translates to:
  /// **'Il fuel rate deve essere in l/h. g/s e gal/h richiedono una conversione esplicita.'**
  String get fuelRateUnits;

  /// No description provided for @useCalculatedLoad.
  ///
  /// In it, this message translates to:
  /// **'Usa calculated load (PID 04), non absolute load (PID 43).'**
  String get useCalculatedLoad;

  /// No description provided for @twoValidRows.
  ///
  /// In it, this message translates to:
  /// **'Servono almeno due righe con tempo e dati validi.'**
  String get twoValidRows;

  /// No description provided for @maxTripDuration.
  ///
  /// In it, this message translates to:
  /// **'Durata massima: 24 ore.'**
  String get maxTripDuration;

  /// No description provided for @notElmAdapter.
  ///
  /// In it, this message translates to:
  /// **'L’adattatore non risponde come ELM/STN.'**
  String get notElmAdapter;

  /// No description provided for @ecuNotResponding.
  ///
  /// In it, this message translates to:
  /// **'La centralina non risponde. Accendi il quadro.'**
  String get ecuNotResponding;

  /// No description provided for @noExpectedPids.
  ///
  /// In it, this message translates to:
  /// **'Nessuno dei PID previsti è disponibile.'**
  String get noExpectedPids;

  /// No description provided for @ecuStoppedData.
  ///
  /// In it, this message translates to:
  /// **'La centralina non fornisce più dati.'**
  String get ecuStoppedData;

  /// No description provided for @invalidAti.
  ///
  /// In it, this message translates to:
  /// **'Risposta ATI non valida.'**
  String get invalidAti;

  /// No description provided for @bluetoothInterrupted.
  ///
  /// In it, this message translates to:
  /// **'Collegamento Bluetooth interrotto.'**
  String get bluetoothInterrupted;

  /// No description provided for @longObdResponse.
  ///
  /// In it, this message translates to:
  /// **'Risposta OBD troppo lunga.'**
  String get longObdResponse;

  /// No description provided for @reconnectChannel.
  ///
  /// In it, this message translates to:
  /// **'Canale OBD da riconnettere.'**
  String get reconnectChannel;

  /// No description provided for @sessionClosed.
  ///
  /// In it, this message translates to:
  /// **'Sessione chiusa.'**
  String get sessionClosed;

  /// No description provided for @incompleteBitmap.
  ///
  /// In it, this message translates to:
  /// **'Bitmap PID incompleta'**
  String get incompleteBitmap;

  /// No description provided for @mobileAcquisitionOnly.
  ///
  /// In it, this message translates to:
  /// **'Su desktop puoi importare e analizzare i viaggi. L’acquisizione Bluetooth è disponibile su mobile.'**
  String get mobileAcquisitionOnly;

  /// No description provided for @bondTimeout.
  ///
  /// In it, this message translates to:
  /// **'Associazione scaduta. Riprova con OBDLink in modalità pairing.'**
  String get bondTimeout;

  /// No description provided for @bondCanceled.
  ///
  /// In it, this message translates to:
  /// **'Associazione non riuscita o annullata.'**
  String get bondCanceled;

  /// No description provided for @scanPermissionRevoked.
  ///
  /// In it, this message translates to:
  /// **'Permesso Bluetooth revocato durante la ricerca.'**
  String get scanPermissionRevoked;

  /// No description provided for @permissionsBusy.
  ///
  /// In it, this message translates to:
  /// **'Richiesta permessi già in corso.'**
  String get permissionsBusy;

  /// No description provided for @missingScanPermission.
  ///
  /// In it, this message translates to:
  /// **'Permesso di scansione Bluetooth mancante.'**
  String get missingScanPermission;

  /// No description provided for @missingDevice.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo mancante.'**
  String get missingDevice;

  /// No description provided for @bondInterrupted.
  ///
  /// In it, this message translates to:
  /// **'Associazione interrotta nell’app.'**
  String get bondInterrupted;

  /// No description provided for @bluetoothDisconnected.
  ///
  /// In it, this message translates to:
  /// **'Bluetooth disconnesso.'**
  String get bluetoothDisconnected;

  /// No description provided for @bluetoothUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Bluetooth non disponibile.'**
  String get bluetoothUnavailable;

  /// No description provided for @enableBluetoothSettings.
  ///
  /// In it, this message translates to:
  /// **'Attiva il Bluetooth nelle impostazioni.'**
  String get enableBluetoothSettings;

  /// No description provided for @nearbyPermission.
  ///
  /// In it, this message translates to:
  /// **'Consenti l’accesso ai dispositivi nelle vicinanze nelle impostazioni dell’app.'**
  String get nearbyPermission;

  /// No description provided for @bluetoothPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso Bluetooth negato. Consenti Dispositivi nelle vicinanze (e Posizione su Android 11 o meno) nelle impostazioni dell’app.'**
  String get bluetoothPermissionDenied;

  /// No description provided for @scanFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile avviare la ricerca Bluetooth.'**
  String get scanFailed;

  /// No description provided for @bondBusy.
  ///
  /// In it, this message translates to:
  /// **'Associazione già in corso.'**
  String get bondBusy;

  /// No description provided for @enableBluetooth.
  ///
  /// In it, this message translates to:
  /// **'Attiva il Bluetooth.'**
  String get enableBluetooth;

  /// No description provided for @bondStartFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile avviare l’associazione.'**
  String get bondStartFailed;

  /// No description provided for @bondFailed.
  ///
  /// In it, this message translates to:
  /// **'Associazione non riuscita.'**
  String get bondFailed;

  /// No description provided for @deviceNotPaired.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo non associato. Associalo nelle impostazioni Bluetooth.'**
  String get deviceNotPaired;

  /// No description provided for @connectionCanceled.
  ///
  /// In it, this message translates to:
  /// **'Connessione annullata.'**
  String get connectionCanceled;

  /// No description provided for @obdInterrupted.
  ///
  /// In it, this message translates to:
  /// **'Connessione OBD interrotta.'**
  String get obdInterrupted;

  /// No description provided for @activityClosed.
  ///
  /// In it, this message translates to:
  /// **'Attività chiusa.'**
  String get activityClosed;

  /// No description provided for @bluetoothDevice.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo Bluetooth'**
  String get bluetoothDevice;

  /// No description provided for @invalidNumber.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un numero valido.'**
  String get invalidNumber;

  /// No description provided for @obdStatus.
  ///
  /// In it, this message translates to:
  /// **'Collegamento OBD: {status}'**
  String obdStatus(String status);

  /// No description provided for @frameCount.
  ///
  /// In it, this message translates to:
  /// **'{count} frame'**
  String frameCount(String count);

  /// No description provided for @compareCount.
  ///
  /// In it, this message translates to:
  /// **'Confronta ({count}/2)'**
  String compareCount(String count);

  /// No description provided for @deleteTripNotice.
  ///
  /// In it, this message translates to:
  /// **'“{name}” e i suoi dati saranno eliminati dal dispositivo.'**
  String deleteTripNotice(String name);

  /// No description provided for @importResult.
  ///
  /// In it, this message translates to:
  /// **'Importati {frames} frame. Righe scartate: {discarded}; valori invalidi: {invalid}.'**
  String importResult(String frames, String discarded, String invalid);

  /// No description provided for @eventCount.
  ///
  /// In it, this message translates to:
  /// **'{count} eventi · soglie del modello salvato con il viaggio'**
  String eventCount(String count);

  /// No description provided for @coverageNotice.
  ///
  /// In it, this message translates to:
  /// **'Copertura: velocità {speed}% · fuel rate {fuel}%. Distanza e carburante si riferiscono agli intervalli validi.'**
  String coverageNotice(String speed, String fuel);

  /// No description provided for @excludedWeight.
  ///
  /// In it, this message translates to:
  /// **'Copertura {coverage}% · peso escluso'**
  String excludedWeight(String coverage);

  /// No description provided for @effectiveWeight.
  ///
  /// In it, this message translates to:
  /// **'Copertura {coverage}% · peso effettivo {weight}% · contributo {contribution} punti'**
  String effectiveWeight(String coverage, String weight, String contribution);

  /// No description provided for @csvPreview.
  ///
  /// In it, this message translates to:
  /// **'{rows} righe. Conferma le unità: velocità km/h (o mph indicato), RPM, carico/farfalla %, temperatura °C (o °F indicato), fuel rate l/h.'**
  String csvPreview(String rows);

  /// No description provided for @mapSemantics.
  ///
  /// In it, this message translates to:
  /// **'Mappa operativa: {cells} celle, {duration} di dati validi. Tocca una cella per i dettagli.'**
  String mapSemantics(String cells, String duration);

  /// No description provided for @mapCellRange.
  ///
  /// In it, this message translates to:
  /// **'{rpmMin}–{rpmMax} rpm · {loadMin}–{loadMax}% carico'**
  String mapCellRange(
    String rpmMin,
    String rpmMax,
    String loadMin,
    String loadMax,
  );

  /// No description provided for @mapCellDetails.
  ///
  /// In it, this message translates to:
  /// **'{duration} · {frames} frame\nVelocità media {speed} km/h · carburante {fuel} l/h\nPenalità {penalty} · contributo allo score zone −{points} punti'**
  String mapCellDetails(
    String duration,
    String frames,
    String speed,
    String fuel,
    String penalty,
    String points,
  );

  /// No description provided for @timelineSemantics.
  ///
  /// In it, this message translates to:
  /// **'Timeline {parameter}. {samples} campioni.'**
  String timelineSemantics(String parameter, String samples);

  /// No description provided for @statusLabel.
  ///
  /// In it, this message translates to:
  /// **'Stato: {status}'**
  String statusLabel(String status);

  /// No description provided for @selectedDevice.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo selezionato: {name}'**
  String selectedDevice(String name);

  /// No description provided for @ecuLabel.
  ///
  /// In it, this message translates to:
  /// **'Centralina {ecu}'**
  String ecuLabel(String ecu);

  /// No description provided for @testProgress.
  ///
  /// In it, this message translates to:
  /// **'Test in corso · {seconds} / 30 s'**
  String testProgress(String seconds);

  /// No description provided for @testConsumptionNotice.
  ///
  /// In it, this message translates to:
  /// **'Calcolato da portata carburante e velocità; non è una media storica. Distanza {distance} km · carburante stimato {fuel} L.'**
  String testConsumptionNotice(String distance, String fuel);

  /// No description provided for @noValidSamples.
  ///
  /// In it, this message translates to:
  /// **'Nessun valore valido · {failures} risposte non valide'**
  String noValidSamples(String failures);

  /// No description provided for @sampleSummary.
  ///
  /// In it, this message translates to:
  /// **'Media {average} {unit} · min {minimum} · max {maximum} · {count} letture'**
  String sampleSummary(
    String average,
    String unit,
    String minimum,
    String maximum,
    String count,
  );

  /// No description provided for @failedSamples.
  ///
  /// In it, this message translates to:
  /// **' · {count} senza dato'**
  String failedSamples(String count);

  /// No description provided for @logExported.
  ///
  /// In it, this message translates to:
  /// **'Esportato: {time}'**
  String logExported(String time);

  /// No description provided for @logDevice.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo: {name}'**
  String logDevice(String name);

  /// No description provided for @logConnection.
  ///
  /// In it, this message translates to:
  /// **'Stato connessione: {status}'**
  String logConnection(String status);

  /// No description provided for @logPids.
  ///
  /// In it, this message translates to:
  /// **'Stato PID: {status}'**
  String logPids(String status);

  /// No description provided for @logEcu.
  ///
  /// In it, this message translates to:
  /// **'Centralina: {ecu}'**
  String logEcu(String ecu);

  /// No description provided for @logProtocol.
  ///
  /// In it, this message translates to:
  /// **'Protocollo: {protocol}'**
  String logProtocol(String protocol);

  /// No description provided for @logPidList.
  ///
  /// In it, this message translates to:
  /// **'PID standard: {pids}'**
  String logPidList(String pids);

  /// No description provided for @logSaved.
  ///
  /// In it, this message translates to:
  /// **'Log salvato in {path}'**
  String logSaved(String path);

  /// No description provided for @exportFailed.
  ///
  /// In it, this message translates to:
  /// **'Esportazione non riuscita: {error}'**
  String exportFailed(String error);

  /// No description provided for @reconnectingAttempt.
  ///
  /// In it, this message translates to:
  /// **'Riconnessione {attempt} di 3…'**
  String reconnectingAttempt(String attempt);

  /// No description provided for @connectingDevice.
  ///
  /// In it, this message translates to:
  /// **'Connessione a {name}…'**
  String connectingDevice(String name);

  /// No description provided for @pairingDevice.
  ///
  /// In it, this message translates to:
  /// **'Associazione a {name}… Conferma la richiesta Android.'**
  String pairingDevice(String name);

  /// No description provided for @connectedDevice.
  ///
  /// In it, this message translates to:
  /// **'Connesso a {name}'**
  String connectedDevice(String name);

  /// No description provided for @pidsQueryRange.
  ///
  /// In it, this message translates to:
  /// **'Interrogo i PID {first}–{last}…'**
  String pidsQueryRange(String first, String last);

  /// No description provided for @pidsFound.
  ///
  /// In it, this message translates to:
  /// **'{count} PID standard rilevati sulla centralina {ecu}.'**
  String pidsFound(String count, String ecu);

  /// No description provided for @pidCheckFailed.
  ///
  /// In it, this message translates to:
  /// **'Verifica PID non completata: {error}'**
  String pidCheckFailed(String error);

  /// No description provided for @testInterrupted.
  ///
  /// In it, this message translates to:
  /// **'Test interrotto dopo {seconds}s · {count} letture valide'**
  String testInterrupted(String seconds, String count);

  /// No description provided for @testCompleted.
  ///
  /// In it, this message translates to:
  /// **'Test completato · 30 s · {count} letture valide'**
  String testCompleted(String count);

  /// No description provided for @testFailed.
  ///
  /// In it, this message translates to:
  /// **'Test interrotto: {error}'**
  String testFailed(String error);

  /// No description provided for @warmupReason.
  ///
  /// In it, this message translates to:
  /// **'Penalità per carico oltre {load}% sotto {temperature} °C, sul tempo osservato.'**
  String warmupReason(String load, String temperature);

  /// No description provided for @economyReason.
  ///
  /// In it, this message translates to:
  /// **'Rapporto rispetto alla baseline {baseline} l/100 km; richiede copertura ≥80% e distanza ≥100 m.'**
  String economyReason(String baseline);

  /// No description provided for @scoreIntro.
  ///
  /// In it, this message translates to:
  /// **'Score {score}/100 su {components} componenti disponibili. '**
  String scoreIntro(String score, String components);

  /// No description provided for @scoreMapPortion.
  ///
  /// In it, this message translates to:
  /// **'{percent}% del tempo mappato in zone favorevoli secondo le regole configurate. '**
  String scoreMapPortion(String percent);

  /// No description provided for @scoreEventCount.
  ///
  /// In it, this message translates to:
  /// **'{count} eventi di accelerazione o frenata. '**
  String scoreEventCount(String count);

  /// No description provided for @scoreMapCoverage.
  ///
  /// In it, this message translates to:
  /// **'Copertura della mappa: {percent}%. Modello euristico, da calibrare su viaggi reali.'**
  String scoreMapCoverage(String percent);

  /// No description provided for @unsupportedModel.
  ///
  /// In it, this message translates to:
  /// **'Modello {version} non supportato'**
  String unsupportedModel(String version);

  /// No description provided for @initializationFailed.
  ///
  /// In it, this message translates to:
  /// **'Inizializzazione fallita: {command}.'**
  String initializationFailed(String command);

  /// No description provided for @unconfirmedCommand.
  ///
  /// In it, this message translates to:
  /// **'L’adattatore non ha confermato {command}.'**
  String unconfirmedCommand(String command);

  /// No description provided for @incompleteResponse.
  ///
  /// In it, this message translates to:
  /// **'Risposta {command} incompleta'**
  String incompleteResponse(String command);

  /// No description provided for @incompletePidResponse.
  ///
  /// In it, this message translates to:
  /// **'Risposta PID {command} incompleta'**
  String incompletePidResponse(String command);

  /// No description provided for @undecodedPid.
  ///
  /// In it, this message translates to:
  /// **'PID standard non decodificato: {pid}'**
  String undecodedPid(String pid);

  /// No description provided for @noResponse.
  ///
  /// In it, this message translates to:
  /// **'Nessuna risposta a {command}'**
  String noResponse(String command);

  /// No description provided for @connectionError.
  ///
  /// In it, this message translates to:
  /// **'Collegamento non riuscito: {error}'**
  String connectionError(String error);

  /// No description provided for @saveRecordingFailed.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio non riuscito; registrazione in pausa. I dati in memoria sono conservati. {error}'**
  String saveRecordingFailed(String error);

  /// No description provided for @automaticTripName.
  ///
  /// In it, this message translates to:
  /// **'Viaggio {date}'**
  String automaticTripName(String date);
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
