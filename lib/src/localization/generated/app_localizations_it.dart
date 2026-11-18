// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get telemetry => 'Telemetria';

  @override
  String get trips => 'Viaggi';

  @override
  String get profile => 'Profilo';

  @override
  String get demo => 'Demo';

  @override
  String get obdConnected => 'OBD connesso';

  @override
  String get offline => 'Offline';

  @override
  String get homeTitle => 'La tua auto';

  @override
  String get homeSubtitle => 'La tua auto, un viaggio alla volta.';

  @override
  String get garage => 'NEL TUO GARAGE';

  @override
  String get vehicleSpecs => '2021 · 1.0 EcoBoost\n125 CV · mild hybrid';

  @override
  String get dismissMessage => 'Chiudi messaggio';

  @override
  String get demoActive => 'Demo attiva · dati simulati';

  @override
  String get foregroundNotice =>
      'La raccolta si mette in pausa quando l’app passa in background. Lo schermo resta acceso mentre OBD è connesso.';

  @override
  String get tripPaused => 'Viaggio in pausa';

  @override
  String get recordingActive => 'Registrazione attiva';

  @override
  String get nextTrip => 'Il tuo prossimo viaggio';

  @override
  String get recordingNotice =>
      'I dati vengono salvati sul telefono. Lascia DriveMap aperta durante il viaggio.';

  @override
  String get startNotice =>
      'Avvia prima di partire. Al termine potrai ritrovare ed esportare i tuoi dati in Viaggi.';

  @override
  String get startTrip => 'Inizia viaggio';

  @override
  String get resume => 'Riprendi';

  @override
  String get pause => 'Pausa';

  @override
  String get finishSave => 'Termina e salva';

  @override
  String get savedOpenArchive => 'Viaggio salvato · apri archivio';

  @override
  String get obdConnection => 'Connessione OBDLink MX+';

  @override
  String get validReadings => 'Letture valide';

  @override
  String get lastResponse => 'Ultima risposta';

  @override
  String get reconnections => 'Riconnessioni';

  @override
  String get openTelemetry => 'Apri telemetria';

  @override
  String get disconnect => 'Disconnetti';

  @override
  String get connectInstructions =>
      'Accendi il quadro, chiudi le altre app OBD e seleziona il tuo adattatore.';

  @override
  String get searching => 'Ricerca…';

  @override
  String get pairedDevices => 'Dispositivi associati';

  @override
  String get pairDevice => 'Associa dispositivo';

  @override
  String get desktopNotice => 'Su desktop: importa i viaggi.';

  @override
  String get diagnosticsLogs => 'Diagnostica e log OBD';

  @override
  String get cancelConnection => 'Annulla connessione';

  @override
  String get exploreDemo => 'Esplora con la demo';

  @override
  String get telemetryTitle => 'Telemetria live';

  @override
  String get recordingInProgress => 'Registrazione in corso';

  @override
  String get manage => 'Gestisci';

  @override
  String get availableParameters => 'Parametri disponibili';

  @override
  String get available => 'disponibile';

  @override
  String get unsupported => 'non supportato';

  @override
  String get missingParameters =>
      'I parametri non disponibili sono indicati con —.';

  @override
  String get liveTelemetry => 'TELEMETRIA LIVE';

  @override
  String get waitingData => 'In attesa dei dati del veicolo';

  @override
  String get screenRefresh => 'Schermo aggiornato ogni 0,5 s';

  @override
  String get profileTitle => 'Il tuo profilo';

  @override
  String get engine => 'Motore';

  @override
  String get engineSpecs => '125 CV · mild hybrid';

  @override
  String get fuelType => 'Alimentazione';

  @override
  String get petrol => 'Benzina';

  @override
  String get adapter => 'Adattatore';

  @override
  String get analysisSettings => 'Parametri di analisi';

  @override
  String get analysisSettingsSubtitle =>
      'Personalizza soglie e pesi della guida.';

  @override
  String get localTripsNotice =>
      'I viaggi restano sul tuo telefono. Puoi esportarli dalla sezione Viaggi per consultarli anche sul computer.';

  @override
  String get language => 'Lingua';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHint =>
      'Scegli la lingua dell’app. La preferenza resta salvata su questo telefono.';

  @override
  String get languageSaveFailed => 'Impossibile salvare la lingua. Riprova.';

  @override
  String get languageLoadFailed => 'Impossibile caricare la lingua salvata.';

  @override
  String get restoreModel => 'Ripristina modello iniziale';

  @override
  String get settingsTitle => 'Uno score che puoi capire.';

  @override
  String get settingsSubtitle =>
      'Regole esplicite per valutare il comportamento di guida; il consumo è mostrato separatamente.';

  @override
  String get heuristicModel => 'Modello euristico · rules-2.0.0';

  @override
  String get settingsNotice =>
      'Questi parametri si applicano a tutti i viaggi, anche a quelli già salvati. Modificandoli, lo score viene ricalcolato con le stesse regole per l’intero archivio.';

  @override
  String get loadNotice =>
      'Calculated load è un proxy del carico. L’indice delle zone favorevoli segue soglie euristiche: non misura efficienza, coppia o potenza. Il consumo del viaggio resta una metrica separata.';

  @override
  String get componentWeights => 'Il peso di ogni componente';

  @override
  String get weightsNotice =>
      'Lo score combina zone operative, regolarità e riscaldamento. I pesi sono rinormalizzati se mancano dati per una componente. Valori iniziali: 0,40 / 0,25 / 0,20.';

  @override
  String get operatingZones => 'Zone operative';

  @override
  String get smoothness => 'Regolarità';

  @override
  String get warmup => 'Riscaldamento';

  @override
  String get engineZones => 'Le zone del motore';

  @override
  String get engineZonesNotice =>
      'Zona favorevole: regime tra le soglie e carico tra 20% e soglia alta. Penalità 0,5 negli altri casi; 1 ad alto regime o a basso regime con carico elevato.';

  @override
  String get lowRpm => 'Regime minimo favorevole · rpm';

  @override
  String get highRpm => 'Soglia alto regime · rpm';

  @override
  String get highLoad => 'Soglia alto carico · %';

  @override
  String get warmupSmoothness => 'Riscaldamento e regolarità';

  @override
  String get accelerationNotice =>
      'Le accelerazioni sono derivate dai timestamp originali della velocità OBD. Gli eventi sono conteggiati all’ingresso nella condizione e rapportati al minuto.';

  @override
  String get warmTemperature => 'Fine riscaldamento · °C';

  @override
  String get coldLoad => 'Carico consentito a freddo · %';

  @override
  String get hardAccelerationThreshold => 'Accelerazione brusca · m/s²';

  @override
  String get hardAccelerationEvent => 'Accelerazione brusca';

  @override
  String get hardBrakingEvent => 'Frenata brusca';

  @override
  String get hardBrakingThreshold => 'Frenata brusca · m/s²';

  @override
  String get saving => 'Salvataggio…';

  @override
  String get saveModel => 'Salva modello';

  @override
  String get defaults => 'Valori iniziali';

  @override
  String get studyProfile =>
      'Profilo di studio: Ford Fiesta 2021 · OBDLink MX+\nAcquisizione Android in primo piano tramite Bluetooth RFCOMM. L’app legge i dati OBD senza scrivere sulla centralina né cancellare errori.';

  @override
  String get modelSaved => 'Modello salvato per i prossimi viaggi.';

  @override
  String get tripsTitle => 'I tuoi viaggi';

  @override
  String get importing => 'Importazione…';

  @override
  String get importData => 'Importa CSV / DriveMap';

  @override
  String get refreshTrips => 'Aggiorna viaggi';

  @override
  String get archiveUnavailable => 'Archivio non disponibile';

  @override
  String get retry => 'Riprova';

  @override
  String get firstTrip => 'Il primo viaggio ti aspetta';

  @override
  String get firstTripNotice =>
      'Inizia un viaggio dalla Home oppure importa un CSV. Puoi provare anche la demo: i dati simulati saranno riconoscibili in archivio.';

  @override
  String get importedCsv => 'CSV importato';

  @override
  String get realObd => 'OBD reale';

  @override
  String get interruptedRecovered => 'Interrotto · recuperato';

  @override
  String get openSession => 'Sessione aperta';

  @override
  String get analyzeTrip => 'Analizza viaggio';

  @override
  String get deleteTrip => 'Elimina viaggio';

  @override
  String get deleteTripQuestion => 'Eliminare il viaggio?';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get fileSizeLimit =>
      'Limite file: 30 MB. Suddividi i viaggi più grandi.';

  @override
  String get unknownBundle => 'Formato DriveMap non riconosciuto.';

  @override
  String get invalidFrameCount => 'Numero di frame non valido (2–200.000).';

  @override
  String get tooManyRaw => 'Troppi campioni raw.';

  @override
  String get tripAnalysis => 'Analisi viaggio';

  @override
  String get exportTrip => 'Esporta viaggio';

  @override
  String get exportBundle => 'DriveMap · dati, raw e modello';

  @override
  String get exportTelemetry => 'CSV · telemetria e orari PID';

  @override
  String get exportRaw => 'CSV · risposte OBD raw';

  @override
  String get demoTripNotice => 'Viaggio dimostrativo · telemetria simulata';

  @override
  String get csvTripNotice => 'CSV · origine e unità definite in importazione';

  @override
  String get tripEvents => 'Gli eventi del viaggio';

  @override
  String get noEvents => 'Nessun evento rilevato nei campioni disponibili.';

  @override
  String get firstHundredEvents =>
      'Visualizzati i primi 100 eventi. Tutti i dati sono disponibili in esportazione.';

  @override
  String get exportCompleted => 'Esportazione completata.';

  @override
  String get observedTime => 'Tempo osservato';

  @override
  String get integratedDistance => 'Distanza integrata';

  @override
  String get integratedFuel => 'Carburante integrato';

  @override
  String get estimatedConsumption => 'Consumo stimato';

  @override
  String get yourScore => 'IL TUO SCORE';

  @override
  String get explainable => 'Spiegabile · v1';

  @override
  String get notCalculated => 'Non calcolato';

  @override
  String get compareTrips => 'Due viaggi, a confronto';

  @override
  String get comparisonNotice =>
      'Gli score usano gli stessi parametri. Confronta comunque percorsi e condizioni simili: traffico, temperatura e pendenza possono cambiare i risultati. La colonna Δ è Viaggio B meno Viaggio A.';

  @override
  String get differentModels =>
      'Modelli diversi: score non direttamente comparabili';

  @override
  String get differentSources => 'Origini dei dati diverse';

  @override
  String get metric => 'Metrica';

  @override
  String get tripA => 'Viaggio A';

  @override
  String get tripB => 'Viaggio B';

  @override
  String get scoreMetric => 'Score / 100';

  @override
  String get distanceMetric => 'Distanza km';

  @override
  String get consumptionMetric => 'Consumo l/100 km';

  @override
  String get favorableZones => 'Zone favorevoli';

  @override
  String get drivingEvents => 'Eventi di guida';

  @override
  String get mappedTime => 'Tempo mappato';

  @override
  String get comparisonDuration => 'Durata osservata';

  @override
  String get comparisonFuelLiters => 'Carburante stimato · L';

  @override
  String get comparisonAverageSpeed => 'Velocità media valida · km/h';

  @override
  String get comparisonEventRate => 'Eventi bruschi · al minuto';

  @override
  String get comparisonMapCoverage => 'Copertura mappa · %';

  @override
  String get comparisonSpeedCoverage => 'Copertura velocità · %';

  @override
  String get comparisonFuelCoverage => 'Copertura fuel rate · %';

  @override
  String get comparisonDelta => 'Δ (B − A)';

  @override
  String get comparisonMetrics => 'Riepilogo delle metriche';

  @override
  String get comparisonScoreBreakdown =>
      'Confronto delle componenti dello score';

  @override
  String get comparisonMaps => 'Distribuzione RPM–carico';

  @override
  String comparisonHigherScore(Object name, Object score) {
    return 'Score maggiore: $name · $score/100';
  }

  @override
  String get comparisonSimilarScores => 'Score sostanzialmente uguali';

  @override
  String get comparisonDifferentCoverage =>
      'I due score usano componenti diverse perché alcuni dati OBD mancano in uno dei viaggi: il confronto del totale è indicativo.';

  @override
  String get mapCsvColumns => 'Associa le colonne del CSV';

  @override
  String get time => 'Tempo';

  @override
  String get elapsedSeconds => 'Tempo in secondi dall’inizio';

  @override
  String get isoTimeNotice =>
      'Disattiva per timestamp ISO 8601 con fuso orario.';

  @override
  String get tripStartIso => 'Inizio viaggio · ISO 8601 con fuso';

  @override
  String get invalidOrigin =>
      'Inserisci un inizio viaggio ISO con fuso, ad esempio 2026-10-01T10:00:00+02:00.';

  @override
  String get importTrip => 'Importa viaggio';

  @override
  String get notPresent => 'Non presente';

  @override
  String get engineMap => 'Mappa RPM–carico';

  @override
  String get engineMapSubtitle =>
      'Raggruppa i campioni del viaggio per regime motore e carico: ogni cella copre 500 rpm e 10% di carico.';

  @override
  String get occupancy => 'Permanenza';

  @override
  String get fuel => 'Carburante';

  @override
  String get zoneFavorability => 'Zone favorevoli';

  @override
  String get penalty => 'Penalità';

  @override
  String get mapRequiresData =>
      'Servono RPM e calculated load validi\nper costruire la mappa.';

  @override
  String get occupancyLegend => 'Da meno a più tempo · celle da 500 rpm × 10%';

  @override
  String get fuelLegend => 'Flusso medio in l/h · solo dati disponibili';

  @override
  String get favorabilityLegend =>
      'Da 0 a 100 · favorevolezza secondo le regole';

  @override
  String get penaltyLegend => 'Da 0 a 1 · costo medio delle zone';

  @override
  String get mapNotice =>
      'È una distribuzione dei dati osservati durante il viaggio, non la mappa ECU né una misura di potenza o rendimento. Cambia colore selezionando tempo, flusso carburante, favorevolezza stimata o penalità media.';

  @override
  String get loadAxis => 'Carico %';

  @override
  String get rpmAxis => 'Regime motore · rpm';

  @override
  String get timelineTitle => 'Il viaggio, istante per istante';

  @override
  String get timelineSubtitle =>
      'Tocca il grafico per leggere un campione. I punti arancioni indicano eventi di guida.';

  @override
  String get insufficientSamples => 'Campioni insufficienti';

  @override
  String get parameterUnavailable =>
      'Parametro non disponibile in questo viaggio';

  @override
  String get connectObdLink => 'Collega la tua OBDLink';

  @override
  String get scanInstructions =>
      'Accendi il quadro e metti l’adattatore in modalità associazione. La ricerca usa Bluetooth Classic.';

  @override
  String get addObd => 'Aggiungi OBD';

  @override
  String get androidScanOnly =>
      'La ricerca Bluetooth Classic è disponibile su Android.';

  @override
  String get bluetoothDevices => 'Dispositivi Bluetooth';

  @override
  String get stopSearch => 'Ferma ricerca';

  @override
  String get searchAgain => 'Cerca di nuovo';

  @override
  String get onlyObdLink => 'Mostra solo OBDLink';

  @override
  String get scanningNearby =>
      'Ricerca in corso… Avvicina il telefono e attiva il pairing su MX+.';

  @override
  String get noVisibleDevices =>
      'Nessun dispositivo visibile. Riprova o disattiva il filtro OBDLink.';

  @override
  String get unnamedDevice => 'Dispositivo senza nome';

  @override
  String get alreadyPaired => 'Già associato';

  @override
  String get notPaired => 'Da associare';

  @override
  String get standardPids => 'PID standard disponibili';

  @override
  String get repeatAti => 'Ripeti ATI';

  @override
  String get bluetoothSettings => 'Impostazioni Bluetooth';

  @override
  String get exportLogs => 'Esporta log in un file .txt';

  @override
  String get commandsResponses => 'Comandi e risposte';

  @override
  String get noCommands => 'Nessun comando inviato.';

  @override
  String get pidTestTitle => 'Test dei parametri · 30 secondi';

  @override
  String get pidTestNotice =>
      'Interroga in sequenza i PID principali, il livello carburante e il contachilometri. Il carburante è espresso in percentuale, non in litri. Avvia il test a veicolo fermo; non usare il telefono durante la guida.';

  @override
  String get testConsumption => 'Consumo medio stimato nel test';

  @override
  String get testConsumptionUnavailable =>
      '— L/100 km · distanza troppo breve o letture non disponibili';

  @override
  String get stopTest => 'Interrompi test';

  @override
  String get startPidTest => 'Avvia test PID 30 s';

  @override
  String get noTestablePids => 'Nessun PID principale disponibile per il test.';

  @override
  String get diagnosticLog => 'DriveMap · log diagnostico';

  @override
  String get noLogEvents => 'Nessun evento registrato in questa sessione.';

  @override
  String get serialEvents => 'Eventi e traffico seriale:';

  @override
  String get none => 'nessuno';

  @override
  String get notDetected => 'non rilevata';

  @override
  String get protocolNotDetected => 'non rilevato';

  @override
  String get noPidsDetected => 'nessuno rilevato';

  @override
  String get pidLoad => 'Carico motore';

  @override
  String get pidCoolant => 'Refrigerante';

  @override
  String get pidManifold => 'Pressione collettore';

  @override
  String get pidRpm => 'Regime motore';

  @override
  String get pidSpeed => 'Velocità';

  @override
  String get pidThrottle => 'Farfalla';

  @override
  String get pidVoltage => 'Tensione centralina';

  @override
  String get pidFuelRate => 'Flusso carburante';

  @override
  String get pidFuelLevel => 'Livello carburante';

  @override
  String get pidTorque => 'Coppia motore effettiva';

  @override
  String get pidReferenceTorque => 'Coppia motore di riferimento';

  @override
  String get pidOdometer => 'Contachilometri totale';

  @override
  String get connectCar => 'Collega la tua auto';

  @override
  String get bluetoothConnecting => 'Connessione Bluetooth…';

  @override
  String get telemetryActive => 'Telemetria attiva';

  @override
  String get connectionFailedNotice =>
      'Connessione non riuscita. Controlla quadro acceso, Bluetooth e che OBDLink sia chiusa, poi riprova.';

  @override
  String get initializingAdapter => 'Inizializzazione OBDLink…';

  @override
  String get discoveringPids => 'Verifica centralina e PID supportati…';

  @override
  String get disconnected => 'Disconnesso';

  @override
  String get pidsNotChecked => 'PID non ancora verificati';

  @override
  String get bluetoothSearching => 'Ricerca Bluetooth in corso…';

  @override
  String get searchFinished => 'Ricerca terminata';

  @override
  String get connectionFailed => 'Connessione non riuscita';

  @override
  String get linkNeedsRestore => 'Collegamento da ripristinare';

  @override
  String get noMainPids => 'Nessun PID principale supportato da interrogare.';

  @override
  String get stopRequested => 'Interruzione richiesta…';

  @override
  String get adapterIdentifiedSearching =>
      'Adattatore identificato · ricerca PID in corso';

  @override
  String get adapterConfiguring =>
      'Configuro l’adattatore e interrogo la centralina…';

  @override
  String get standardPidsQuery => 'Interrogo i PID standard (01–20)…';

  @override
  String get ecuNoData => 'La centralina non ha risposto a 0100 (NO DATA).';

  @override
  String get invalid0100 => 'Nessuna risposta OBD valida a 0100.';

  @override
  String get adapterNoEcu => 'Adattatore connesso · centralina non rilevata';

  @override
  String get noStandardPids => 'Nessun PID standard supportato rilevato.';

  @override
  String get adapterIdentified => 'Adattatore identificato';

  @override
  String get adapterIncompletePids =>
      'Adattatore connesso · verifica PID incompleta';

  @override
  String get disconnecting => 'Disconnessione…';

  @override
  String get simulator => 'Simulatore OBD';

  @override
  String get demoTrip => 'Viaggio dimostrativo';

  @override
  String get linkLostTripPaused =>
      'Collegamento OBD perso dopo i tentativi di riconnessione. Il viaggio è in pausa: riconnetti l’adattatore e tocca Riprendi.';

  @override
  String zoneReason(String lowRpm, String highRpm, String highLoad) {
    return 'Zona favorevole: $lowRpm ≤ RPM < $highRpm e 20% ≤ carico < $highLoad%; costo 0,5 nelle altre zone e 1 ad alto regime o a bassi giri con carico elevato.';
  }

  @override
  String smoothReason(String acceleration, String braking) {
    return '−5 punti per evento al minuto; accelerazione derivata dalla velocità OBD. Soglie: +$acceleration e −$braking m/s².';
  }

  @override
  String get scoreRequiresData =>
      'Servono almeno 5 secondi di dati validi per calcolare le componenti dello score.';

  @override
  String get scoreNoMap => 'Mappa non disponibile: RPM o carico mancanti. ';

  @override
  String get scoreWeightsNormalized =>
      'Le componenti con meno di 5 secondi di dati validi sono escluse e i pesi rimanenti sono rinormalizzati. ';

  @override
  String scoreFormula(String formula) {
    return 'Media ponderata dei contributi: $formula. ';
  }

  @override
  String scoreContribution(
    String name,
    String value,
    String weight,
    String points,
  ) {
    return '$name $value/100 × $weight% = $points punti';
  }

  @override
  String scoreEventsDetailed(String accelerations, String brakings) {
    return 'Eventi inclusi: $accelerations accelerazioni brusche e $brakings frenate brusche, rilevate dalla velocità OBD. ';
  }

  @override
  String get saveSettingsFailed => 'Impossibile salvare le impostazioni.';

  @override
  String get finiteParameters => 'I parametri devono essere numeri finiti.';

  @override
  String get invalidSettings =>
      'Controlla pesi e soglie: i valori non sono validi.';

  @override
  String get csvRequiresRows =>
      'Il CSV deve contenere un’intestazione e almeno una riga.';

  @override
  String get csvRowLimit =>
      'Limite di importazione: 200.000 righe per viaggio.';

  @override
  String get selectTimeColumn => 'Seleziona la colonna del tempo.';

  @override
  String get mapObdParameter => 'Associa almeno un parametro OBD.';

  @override
  String get distinctColumns =>
      'Ogni parametro deve usare una colonna distinta.';

  @override
  String get fuelRateUnits =>
      'Il fuel rate deve essere in l/h. g/s e gal/h richiedono una conversione esplicita.';

  @override
  String get useCalculatedLoad =>
      'Usa calculated load (PID 04), non absolute load (PID 43).';

  @override
  String get twoValidRows =>
      'Servono almeno due righe con tempo e dati validi.';

  @override
  String get maxTripDuration => 'Durata massima: 24 ore.';

  @override
  String get notElmAdapter => 'L’adattatore non risponde come ELM/STN.';

  @override
  String get ecuNotResponding =>
      'La centralina non risponde. Accendi il quadro.';

  @override
  String get noExpectedPids => 'Nessuno dei PID previsti è disponibile.';

  @override
  String get ecuStoppedData => 'La centralina non fornisce più dati.';

  @override
  String get invalidAti => 'Risposta ATI non valida.';

  @override
  String get bluetoothInterrupted => 'Collegamento Bluetooth interrotto.';

  @override
  String get longObdResponse => 'Risposta OBD troppo lunga.';

  @override
  String get reconnectChannel => 'Canale OBD da riconnettere.';

  @override
  String get sessionClosed => 'Sessione chiusa.';

  @override
  String get incompleteBitmap => 'Bitmap PID incompleta';

  @override
  String get mobileAcquisitionOnly =>
      'Su desktop puoi importare e analizzare i viaggi. L’acquisizione Bluetooth è disponibile su mobile.';

  @override
  String get bondTimeout =>
      'Associazione scaduta. Riprova con OBDLink in modalità pairing.';

  @override
  String get bondCanceled => 'Associazione non riuscita o annullata.';

  @override
  String get scanPermissionRevoked =>
      'Permesso Bluetooth revocato durante la ricerca.';

  @override
  String get permissionsBusy => 'Richiesta permessi già in corso.';

  @override
  String get missingScanPermission =>
      'Permesso di scansione Bluetooth mancante.';

  @override
  String get missingDevice => 'Dispositivo mancante.';

  @override
  String get bondInterrupted => 'Associazione interrotta nell’app.';

  @override
  String get bluetoothDisconnected => 'Bluetooth disconnesso.';

  @override
  String get bluetoothUnavailable => 'Bluetooth non disponibile.';

  @override
  String get enableBluetoothSettings =>
      'Attiva il Bluetooth nelle impostazioni.';

  @override
  String get nearbyPermission =>
      'Consenti l’accesso ai dispositivi nelle vicinanze nelle impostazioni dell’app.';

  @override
  String get bluetoothPermissionDenied =>
      'Permesso Bluetooth negato. Consenti Dispositivi nelle vicinanze (e Posizione su Android 11 o meno) nelle impostazioni dell’app.';

  @override
  String get scanFailed => 'Impossibile avviare la ricerca Bluetooth.';

  @override
  String get bondBusy => 'Associazione già in corso.';

  @override
  String get enableBluetooth => 'Attiva il Bluetooth.';

  @override
  String get bondStartFailed => 'Impossibile avviare l’associazione.';

  @override
  String get bondFailed => 'Associazione non riuscita.';

  @override
  String get deviceNotPaired =>
      'Dispositivo non associato. Associalo nelle impostazioni Bluetooth.';

  @override
  String get connectionCanceled => 'Connessione annullata.';

  @override
  String get obdInterrupted => 'Connessione OBD interrotta.';

  @override
  String get activityClosed => 'Attività chiusa.';

  @override
  String get bluetoothDevice => 'Dispositivo Bluetooth';

  @override
  String get invalidNumber => 'Inserisci un numero valido.';

  @override
  String obdStatus(String status) {
    return 'Collegamento OBD: $status';
  }

  @override
  String frameCount(String count) {
    return '$count frame';
  }

  @override
  String compareCount(String count) {
    return 'Confronta ($count/2)';
  }

  @override
  String deleteTripNotice(String name) {
    return '“$name” e i suoi dati saranno eliminati dal dispositivo.';
  }

  @override
  String importResult(String frames, String discarded, String invalid) {
    return 'Importati $frames frame. Righe scartate: $discarded; valori invalidi: $invalid.';
  }

  @override
  String eventCount(String count) {
    return '$count eventi · soglie del modello salvato con il viaggio';
  }

  @override
  String coverageNotice(String speed, String fuel) {
    return 'Copertura: velocità $speed% · fuel rate $fuel%. Distanza e carburante si riferiscono agli intervalli validi.';
  }

  @override
  String excludedWeight(String coverage) {
    return 'Copertura $coverage% · peso escluso';
  }

  @override
  String effectiveWeight(String coverage, String weight, String contribution) {
    return 'Copertura $coverage% · peso effettivo $weight% · contributo $contribution punti';
  }

  @override
  String csvPreview(String rows) {
    return '$rows righe. Conferma le unità: velocità km/h (o mph indicato), RPM, carico/farfalla %, temperatura °C (o °F indicato), fuel rate l/h.';
  }

  @override
  String mapSemantics(String cells, String duration) {
    return 'Mappa operativa: $cells celle, $duration di dati validi. Tocca una cella per i dettagli.';
  }

  @override
  String mapCellRange(
    String rpmMin,
    String rpmMax,
    String loadMin,
    String loadMax,
  ) {
    return '$rpmMin–$rpmMax rpm · $loadMin–$loadMax% carico';
  }

  @override
  String mapCellDetails(
    String duration,
    String frames,
    String speed,
    String fuel,
    String penalty,
    String points,
  ) {
    return '$duration · $frames frame\nVelocità media $speed km/h · carburante $fuel l/h\nPenalità $penalty · contributo allo score zone −$points punti';
  }

  @override
  String timelineSemantics(String parameter, String samples) {
    return 'Timeline $parameter. $samples campioni.';
  }

  @override
  String statusLabel(String status) {
    return 'Stato: $status';
  }

  @override
  String selectedDevice(String name) {
    return 'Dispositivo selezionato: $name';
  }

  @override
  String ecuLabel(String ecu) {
    return 'Centralina $ecu';
  }

  @override
  String testProgress(String seconds) {
    return 'Test in corso · $seconds / 30 s';
  }

  @override
  String testConsumptionNotice(String distance, String fuel) {
    return 'Calcolato da portata carburante e velocità; non è una media storica. Distanza $distance km · carburante stimato $fuel L.';
  }

  @override
  String noValidSamples(String failures) {
    return 'Nessun valore valido · $failures risposte non valide';
  }

  @override
  String sampleSummary(
    String average,
    String unit,
    String minimum,
    String maximum,
    String count,
  ) {
    return 'Media $average $unit · min $minimum · max $maximum · $count letture';
  }

  @override
  String failedSamples(String count) {
    return ' · $count senza dato';
  }

  @override
  String logExported(String time) {
    return 'Esportato: $time';
  }

  @override
  String logDevice(String name) {
    return 'Dispositivo: $name';
  }

  @override
  String logConnection(String status) {
    return 'Stato connessione: $status';
  }

  @override
  String logPids(String status) {
    return 'Stato PID: $status';
  }

  @override
  String logEcu(String ecu) {
    return 'Centralina: $ecu';
  }

  @override
  String logProtocol(String protocol) {
    return 'Protocollo: $protocol';
  }

  @override
  String logPidList(String pids) {
    return 'PID standard: $pids';
  }

  @override
  String logSaved(String path) {
    return 'Log salvato in $path';
  }

  @override
  String exportFailed(String error) {
    return 'Esportazione non riuscita: $error';
  }

  @override
  String reconnectingAttempt(String attempt) {
    return 'Riconnessione $attempt di 3…';
  }

  @override
  String connectingDevice(String name) {
    return 'Connessione a $name…';
  }

  @override
  String pairingDevice(String name) {
    return 'Associazione a $name… Conferma la richiesta Android.';
  }

  @override
  String connectedDevice(String name) {
    return 'Connesso a $name';
  }

  @override
  String pidsQueryRange(String first, String last) {
    return 'Interrogo i PID $first–$last…';
  }

  @override
  String pidsFound(String count, String ecu) {
    return '$count PID standard rilevati sulla centralina $ecu.';
  }

  @override
  String pidCheckFailed(String error) {
    return 'Verifica PID non completata: $error';
  }

  @override
  String testInterrupted(String seconds, String count) {
    return 'Test interrotto dopo ${seconds}s · $count letture valide';
  }

  @override
  String testCompleted(String count) {
    return 'Test completato · 30 s · $count letture valide';
  }

  @override
  String testFailed(String error) {
    return 'Test interrotto: $error';
  }

  @override
  String warmupReason(String load, String temperature) {
    return 'Penalità per carico oltre $load% sotto $temperature °C, sul tempo osservato.';
  }

  @override
  String scoreIntro(String score, String components) {
    return 'Score $score/100, media ponderata di $components componenti di guida. ';
  }

  @override
  String scoreMapPortion(String percent) {
    return '$percent% del tempo mappato è ricaduto nelle zone classificate favorevoli dalle soglie configurate. ';
  }

  @override
  String scoreMapCoverage(String percent) {
    return 'Copertura RPM-carico: $percent%. Il consumo è mostrato separatamente e non pesa nello score; il modello resta euristico.';
  }

  @override
  String unsupportedModel(String version) {
    return 'Modello $version non supportato';
  }

  @override
  String initializationFailed(String command) {
    return 'Inizializzazione fallita: $command.';
  }

  @override
  String unconfirmedCommand(String command) {
    return 'L’adattatore non ha confermato $command.';
  }

  @override
  String incompleteResponse(String command) {
    return 'Risposta $command incompleta';
  }

  @override
  String incompletePidResponse(String command) {
    return 'Risposta PID $command incompleta';
  }

  @override
  String undecodedPid(String pid) {
    return 'PID standard non decodificato: $pid';
  }

  @override
  String noResponse(String command) {
    return 'Nessuna risposta a $command';
  }

  @override
  String connectionError(String error) {
    return 'Collegamento non riuscito: $error';
  }

  @override
  String saveRecordingFailed(String error) {
    return 'Salvataggio non riuscito; registrazione in pausa. I dati in memoria sono conservati. $error';
  }

  @override
  String automaticTripName(String date) {
    return 'Viaggio $date';
  }
}
