// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get telemetry => 'Telemetry';

  @override
  String get trips => 'Trips';

  @override
  String get profile => 'Profile';

  @override
  String get demo => 'Demo';

  @override
  String get obdConnected => 'OBD connected';

  @override
  String get offline => 'Offline';

  @override
  String get homeTitle => 'Ready to go?';

  @override
  String get homeSubtitle => 'Your car, one trip at a time.';

  @override
  String get garage => 'IN YOUR GARAGE';

  @override
  String get vehicleSpecs => '2021 · 1.0 EcoBoost\n125 PS · mild hybrid';

  @override
  String get dismissMessage => 'Dismiss message';

  @override
  String get demoActive => 'Demo active · simulated data';

  @override
  String get foregroundNotice =>
      'Data collection pauses when the app goes into the background. The screen stays awake while OBD is connected.';

  @override
  String get tripPaused => 'Trip paused';

  @override
  String get recordingActive => 'Recording active';

  @override
  String get nextTrip => 'Your next trip';

  @override
  String get recordingNotice =>
      'Data is saved on your phone. Keep DriveMap open during the trip.';

  @override
  String get startNotice =>
      'Start before you set off. Afterwards, find and export your data in Trips.';

  @override
  String get startTrip => 'Start trip';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get finishSave => 'Finish and save';

  @override
  String get savedOpenArchive => 'Trip saved · open archive';

  @override
  String get obdConnection => 'OBD connection';

  @override
  String get validReadings => 'Valid readings';

  @override
  String get lastResponse => 'Last response';

  @override
  String get reconnections => 'Reconnections';

  @override
  String get openTelemetry => 'Open telemetry';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connectInstructions =>
      'Turn on the ignition, close other OBD apps and select your adapter.';

  @override
  String get searching => 'Searching…';

  @override
  String get pairedDevices => 'Paired devices';

  @override
  String get pairDevice => 'Pair device';

  @override
  String get desktopNotice => 'On desktop: import trips or explore the demo.';

  @override
  String get diagnosticsLogs => 'OBD diagnostics and logs';

  @override
  String get cancelConnection => 'Cancel connection';

  @override
  String get exploreDemo => 'Explore the demo';

  @override
  String get telemetryTitle => 'Your engine, live.';

  @override
  String get telemetrySubtitle => 'A look at the ECU readings.';

  @override
  String get waitingCar => 'Waiting for your car';

  @override
  String get connectFromHome => 'Connect from Home';

  @override
  String get recordingInProgress => 'Recording in progress';

  @override
  String get manage => 'Manage';

  @override
  String get availableParameters => 'Available parameters';

  @override
  String get available => 'available';

  @override
  String get unsupported => 'not supported';

  @override
  String get missingParameters => 'Unavailable parameters are shown as —.';

  @override
  String get liveTelemetry => 'LIVE TELEMETRY';

  @override
  String get waitingData => 'Waiting for vehicle data';

  @override
  String get screenRefresh => 'Screen updated every 0.5 s';

  @override
  String get profileTitle => 'Your vehicle.';

  @override
  String get profileSubtitle => 'Your Fiesta and its onboard tools.';

  @override
  String get engine => 'Engine';

  @override
  String get engineSpecs => '125 PS · mild hybrid';

  @override
  String get fuelType => 'Fuel type';

  @override
  String get petrol => 'Petrol';

  @override
  String get adapter => 'Adapter';

  @override
  String get analysisSettings => 'Analysis settings';

  @override
  String get analysisSettingsSubtitle =>
      'Customize driving thresholds and weights.';

  @override
  String get localTripsNotice =>
      'Trips stay on your phone. Export them from Trips to view them on your computer.';

  @override
  String get language => 'Language';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHint =>
      'Choose the app language. Your preference is saved on this phone.';

  @override
  String get languageSaveFailed =>
      'Could not save the language. Please try again.';

  @override
  String get languageLoadFailed => 'Could not load the saved language.';

  @override
  String get restoreModel => 'Restore default model';

  @override
  String get settingsTitle => 'A score you can understand.';

  @override
  String get settingsSubtitle =>
      'Clear rules and adjustable weights, with a transparent model.';

  @override
  String get heuristicModel => 'Heuristic model · rules-1.0.0';

  @override
  String get settingsNotice =>
      'Settings apply to new trips. Each trip keeps its own configuration so its score can be recalculated reproducibly.';

  @override
  String get loadNotice =>
      'Calculated load is a load proxy. The relative index represents how favorable the zones are under these rules; it does not measure torque, power or thermal efficiency.';

  @override
  String get componentWeights => 'Each component’s weight';

  @override
  String get weightsNotice =>
      'Weights are normalized across available components. Defaults: 0.40 / 0.25 / 0.20 / 0.15.';

  @override
  String get operatingZones => 'Operating zones';

  @override
  String get smoothness => 'Smoothness';

  @override
  String get warmup => 'Warm-up';

  @override
  String get relativeEconomy => 'Relative consumption';

  @override
  String get engineZones => 'Engine zones';

  @override
  String get engineZonesNotice =>
      'Favorable: RPM between the thresholds and load between 20% and the upper threshold. Unfavorable: high RPM, or low RPM with high load.';

  @override
  String get lowRpm => 'Minimum favorable speed · rpm';

  @override
  String get highRpm => 'High engine speed threshold · rpm';

  @override
  String get highLoad => 'High load threshold · %';

  @override
  String get warmupSmoothness => 'Warm-up and smoothness';

  @override
  String get accelerationNotice =>
      'Acceleration is derived from the original OBD speed timestamps. Events are counted when the condition is entered and expressed per minute.';

  @override
  String get warmTemperature => 'End of warm-up · °C';

  @override
  String get coldLoad => 'Allowed load when cold · %';

  @override
  String get hardAccelerationThreshold => 'Hard acceleration · m/s²';

  @override
  String get hardAccelerationEvent => 'Hard acceleration';

  @override
  String get hardBrakingEvent => 'Hard braking';

  @override
  String get hardBrakingThreshold => 'Hard braking · m/s²';

  @override
  String get economyBaseline => 'Consumption baseline';

  @override
  String get baselineNotice =>
      'Set to 0 to exclude the economy component. A baseline must come from trips with comparable routes, temperatures and traffic. Fuel quantity alone does not measure efficiency.';

  @override
  String get baselineConsumption => 'Reference consumption · l/100 km';

  @override
  String get saving => 'Saving…';

  @override
  String get saveModel => 'Save model';

  @override
  String get defaults => 'Defaults';

  @override
  String get studyProfile =>
      'Study vehicle: Ford Fiesta 2021 · OBDLink MX+\nMobile acquisition in the foreground. Android: RFCOMM. iOS: ExternalAccessory, subject to manufacturer configuration and approval. Desktop: import and analysis.\nThe app offers no ECU writing or fault clearing.';

  @override
  String get modelSaved => 'Model saved for future trips.';

  @override
  String get tripsTitle => 'Every trip has a story.';

  @override
  String get tripsSubtitle =>
      'Find your trips, explore the engine and compare results.';

  @override
  String get importing => 'Importing…';

  @override
  String get importData => 'Import CSV / DriveMap';

  @override
  String get refreshTrips => 'Refresh trips';

  @override
  String get archiveUnavailable => 'Archive unavailable';

  @override
  String get retry => 'Try again';

  @override
  String get firstTrip => 'Your first trip awaits';

  @override
  String get firstTripNotice =>
      'Start a trip from Home or import a CSV. You can also try the demo: simulated data is clearly marked in the archive.';

  @override
  String get importedCsv => 'Imported CSV';

  @override
  String get realObd => 'Real OBD';

  @override
  String get interruptedRecovered => 'Interrupted · recovered';

  @override
  String get openSession => 'Open session';

  @override
  String get analyzeTrip => 'Analyze trip';

  @override
  String get deleteTrip => 'Delete trip';

  @override
  String get deleteTripQuestion => 'Delete this trip?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get fileSizeLimit => 'File limit: 30 MB. Split larger trips.';

  @override
  String get unknownBundle => 'Unrecognized DriveMap format.';

  @override
  String get invalidFrameCount => 'Invalid frame count (2–200,000).';

  @override
  String get tooManyRaw => 'Too many raw samples.';

  @override
  String get tripAnalysis => 'Trip analysis';

  @override
  String get exportTrip => 'Export trip';

  @override
  String get exportBundle => 'DriveMap · data, raw samples and model';

  @override
  String get exportTelemetry => 'CSV · telemetry and PID timestamps';

  @override
  String get exportRaw => 'CSV · raw OBD responses';

  @override
  String get demoTripNotice => 'Demo trip · simulated telemetry';

  @override
  String get csvTripNotice => 'CSV · source and units defined during import';

  @override
  String get tripEvents => 'Trip events';

  @override
  String get noEvents => 'No events detected in the available samples.';

  @override
  String get firstHundredEvents =>
      'Showing the first 100 events. All data is available for export.';

  @override
  String get exportCompleted => 'Export complete.';

  @override
  String get observedTime => 'Observed time';

  @override
  String get integratedDistance => 'Integrated distance';

  @override
  String get integratedFuel => 'Integrated fuel';

  @override
  String get estimatedConsumption => 'Estimated consumption';

  @override
  String get yourScore => 'YOUR SCORE';

  @override
  String get explainable => 'Explainable · v1';

  @override
  String get notCalculated => 'Not calculated';

  @override
  String get compareTrips => 'Two trips, compared';

  @override
  String get comparisonNotice =>
      'Compare similar routes and conditions. Traffic, temperature and gradients can change the results.';

  @override
  String get differentModels =>
      'Different models: scores cannot be compared directly';

  @override
  String get differentSources => 'Different data sources';

  @override
  String get metric => 'Metric';

  @override
  String get tripA => 'Trip A';

  @override
  String get tripB => 'Trip B';

  @override
  String get scoreMetric => 'Score / 100';

  @override
  String get distanceMetric => 'Distance km';

  @override
  String get consumptionMetric => 'Consumption l/100 km';

  @override
  String get favorableZones => 'Favorable zones';

  @override
  String get drivingEvents => 'Driving events';

  @override
  String get mappedTime => 'Mapped time';

  @override
  String get mapCsvColumns => 'Map CSV columns';

  @override
  String get time => 'Time';

  @override
  String get elapsedSeconds => 'Time in seconds from start';

  @override
  String get isoTimeNotice =>
      'Turn off for ISO 8601 timestamps with a time zone.';

  @override
  String get tripStartIso => 'Trip start · ISO 8601 with time zone';

  @override
  String get invalidOrigin =>
      'Enter an ISO trip start with a time zone, e.g. 2026-10-01T10:00:00+02:00.';

  @override
  String get importTrip => 'Import trip';

  @override
  String get notPresent => 'Not present';

  @override
  String get engineMap => 'Your engine map';

  @override
  String get engineMapSubtitle =>
      'Where the engine worked and its observed cost.';

  @override
  String get occupancy => 'Time spent';

  @override
  String get fuel => 'Fuel';

  @override
  String get relativeIndex => 'Relative index';

  @override
  String get penalty => 'Penalty';

  @override
  String get mapRequiresData =>
      'Valid RPM and calculated load readings\nare needed to build the map.';

  @override
  String get occupancyLegend => 'Less to more time · 500 rpm × 10% cells';

  @override
  String get fuelLegend => 'Mean flow in l/h · available data only';

  @override
  String get relativeLegend => '0 to 100 · favorability under the rules';

  @override
  String get penaltyLegend => '0 to 1 · mean zone cost';

  @override
  String get mapNotice =>
      'Map of observed conditions. The relative index describes the model rules: it does not measure thermal efficiency or BSFC.';

  @override
  String get loadAxis => 'Load %';

  @override
  String get rpmAxis => 'Engine speed · rpm';

  @override
  String get timelineTitle => 'Your trip, moment by moment';

  @override
  String get timelineSubtitle =>
      'Tap the chart to read a sample. Orange dots indicate driving events.';

  @override
  String get insufficientSamples => 'Insufficient samples';

  @override
  String get parameterUnavailable => 'Parameter unavailable for this trip';

  @override
  String get connectObdLink => 'Connect your OBDLink';

  @override
  String get scanInstructions =>
      'Turn on the ignition and put the adapter into pairing mode. Discovery uses Bluetooth Classic.';

  @override
  String get addObd => 'Add OBD';

  @override
  String get androidScanOnly =>
      'Bluetooth Classic discovery is available on Android.';

  @override
  String get bluetoothDevices => 'Bluetooth devices';

  @override
  String get stopSearch => 'Stop search';

  @override
  String get searchAgain => 'Search again';

  @override
  String get onlyObdLink => 'Show OBDLink only';

  @override
  String get scanningNearby =>
      'Searching… Move your phone closer and enable pairing on the MX+.';

  @override
  String get noVisibleDevices =>
      'No devices found. Try again or turn off the OBDLink filter.';

  @override
  String get unnamedDevice => 'Unnamed device';

  @override
  String get alreadyPaired => 'Already paired';

  @override
  String get notPaired => 'Not paired';

  @override
  String get standardPids => 'Available standard PIDs';

  @override
  String get repeatAti => 'Repeat ATI';

  @override
  String get bluetoothSettings => 'Bluetooth settings';

  @override
  String get exportLogs => 'Export logs to a .txt file';

  @override
  String get commandsResponses => 'Commands and responses';

  @override
  String get noCommands => 'No commands sent.';

  @override
  String get pidTestTitle => 'Parameter test · 30 seconds';

  @override
  String get pidTestNotice =>
      'Reads the main PIDs, fuel level and odometer in sequence. Fuel is expressed as a percentage, not in liters. Start the test while parked; do not use your phone while driving.';

  @override
  String get testConsumption => 'Estimated average consumption during the test';

  @override
  String get testConsumptionUnavailable =>
      '— L/100 km · distance too short or readings unavailable';

  @override
  String get stopTest => 'Stop test';

  @override
  String get startPidTest => 'Start 30 s PID test';

  @override
  String get noTestablePids => 'No main PIDs available for testing.';

  @override
  String get diagnosticLog => 'DriveMap · diagnostic log';

  @override
  String get noLogEvents => 'No events recorded in this session.';

  @override
  String get serialEvents => 'Events and serial traffic:';

  @override
  String get none => 'none';

  @override
  String get notDetected => 'not detected';

  @override
  String get protocolNotDetected => 'not detected';

  @override
  String get noPidsDetected => 'none detected';

  @override
  String get pidLoad => 'Engine load';

  @override
  String get pidCoolant => 'Coolant';

  @override
  String get pidManifold => 'Manifold pressure';

  @override
  String get pidRpm => 'Engine speed';

  @override
  String get pidSpeed => 'Speed';

  @override
  String get pidThrottle => 'Throttle';

  @override
  String get pidVoltage => 'ECU voltage';

  @override
  String get pidFuelRate => 'Fuel flow';

  @override
  String get pidFuelLevel => 'Fuel level';

  @override
  String get pidTorque => 'Actual engine torque';

  @override
  String get pidReferenceTorque => 'Reference engine torque';

  @override
  String get pidOdometer => 'Total odometer';

  @override
  String get connectCar => 'Connect your car';

  @override
  String get bluetoothConnecting => 'Connecting Bluetooth…';

  @override
  String get telemetryActive => 'Telemetry active';

  @override
  String get connectionFailedNotice =>
      'Connection failed. Check the ignition and Bluetooth, close the OBDLink app, then try again.';

  @override
  String get initializingAdapter => 'Initializing OBDLink…';

  @override
  String get discoveringPids => 'Checking ECU and supported PIDs…';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get pidsNotChecked => 'PIDs not checked yet';

  @override
  String get bluetoothSearching => 'Searching for Bluetooth devices…';

  @override
  String get searchFinished => 'Search finished';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get linkNeedsRestore => 'Connection needs restoring';

  @override
  String get noMainPids => 'No supported main PIDs to read.';

  @override
  String get stopRequested => 'Stop requested…';

  @override
  String get adapterIdentifiedSearching => 'Adapter identified · checking PIDs';

  @override
  String get adapterConfiguring =>
      'Configuring the adapter and querying the ECU…';

  @override
  String get standardPidsQuery => 'Querying standard PIDs (01–20)…';

  @override
  String get ecuNoData => 'The ECU did not respond to 0100 (NO DATA).';

  @override
  String get invalid0100 => 'No valid OBD response to 0100.';

  @override
  String get adapterNoEcu => 'Adapter connected · ECU not detected';

  @override
  String get noStandardPids => 'No supported standard PIDs detected.';

  @override
  String get adapterIdentified => 'Adapter identified';

  @override
  String get adapterIncompletePids =>
      'Adapter connected · PID check incomplete';

  @override
  String get disconnecting => 'Disconnecting…';

  @override
  String get simulator => 'OBD simulator';

  @override
  String get demoTrip => 'Demo trip';

  @override
  String get linkLostTripPaused =>
      'OBD connection lost after reconnection attempts. The trip is paused: reconnect the adapter and tap Resume.';

  @override
  String get zoneReason =>
      'Time weighted across RPM–load zones: cost 0, 0.5 or 1.';

  @override
  String get smoothReason =>
      '−5 points per event per minute; acceleration derived from OBD speed.';

  @override
  String get economyExcluded =>
      'Excluded: configure a baseline from comparable trips for this vehicle.';

  @override
  String get scoreRequiresData =>
      'At least 5 seconds of valid data are needed to calculate score components.';

  @override
  String get scoreNoMap => 'Map unavailable: RPM or load missing. ';

  @override
  String get scoreWeightsNormalized =>
      'Weights of available components are normalized. ';

  @override
  String get saveSettingsFailed => 'Could not save settings.';

  @override
  String get finiteParameters => 'Parameters must be finite numbers.';

  @override
  String get invalidSettings =>
      'Check weights, thresholds and baseline: the values are invalid.';

  @override
  String get csvRequiresRows =>
      'The CSV must contain a header and at least one row.';

  @override
  String get csvRowLimit => 'Import limit: 200,000 rows per trip.';

  @override
  String get selectTimeColumn => 'Select the time column.';

  @override
  String get mapObdParameter => 'Map at least one OBD parameter.';

  @override
  String get distinctColumns => 'Each parameter must use a different column.';

  @override
  String get fuelRateUnits =>
      'Fuel flow must be in l/h. g/s and gal/h require an explicit conversion.';

  @override
  String get useCalculatedLoad =>
      'Use calculated load (PID 04), not absolute load (PID 43).';

  @override
  String get twoValidRows =>
      'At least two rows with valid times and data are required.';

  @override
  String get maxTripDuration => 'Maximum duration: 24 hours.';

  @override
  String get notElmAdapter => 'The adapter does not respond as ELM/STN.';

  @override
  String get ecuNotResponding =>
      'The ECU is not responding. Turn on the ignition.';

  @override
  String get noExpectedPids => 'None of the expected PIDs is available.';

  @override
  String get ecuStoppedData => 'The ECU is no longer providing data.';

  @override
  String get invalidAti => 'Invalid ATI response.';

  @override
  String get bluetoothInterrupted => 'Bluetooth connection interrupted.';

  @override
  String get longObdResponse => 'OBD response too long.';

  @override
  String get reconnectChannel => 'The OBD channel needs reconnecting.';

  @override
  String get sessionClosed => 'Session closed.';

  @override
  String get incompleteBitmap => 'Incomplete PID bitmap';

  @override
  String get mobileAcquisitionOnly =>
      'On desktop you can import and analyze trips. Bluetooth acquisition is available on mobile.';

  @override
  String get bondTimeout =>
      'Pairing timed out. Try again with OBDLink in pairing mode.';

  @override
  String get bondCanceled => 'Pairing failed or was canceled.';

  @override
  String get scanPermissionRevoked =>
      'Bluetooth permission revoked during discovery.';

  @override
  String get permissionsBusy => 'A permission request is already in progress.';

  @override
  String get missingScanPermission => 'Bluetooth scan permission is missing.';

  @override
  String get missingDevice => 'No device specified.';

  @override
  String get bondInterrupted => 'Pairing interrupted in the app.';

  @override
  String get bluetoothDisconnected => 'Bluetooth disconnected.';

  @override
  String get bluetoothUnavailable => 'Bluetooth unavailable.';

  @override
  String get enableBluetoothSettings => 'Enable Bluetooth in settings.';

  @override
  String get nearbyPermission =>
      'Allow access to nearby devices in the app settings.';

  @override
  String get bluetoothPermissionDenied =>
      'Bluetooth permission denied. Allow Nearby devices (and Location on Android 11 or earlier) in the app settings.';

  @override
  String get scanFailed => 'Could not start Bluetooth discovery.';

  @override
  String get bondBusy => 'Pairing is already in progress.';

  @override
  String get enableBluetooth => 'Enable Bluetooth.';

  @override
  String get bondStartFailed => 'Could not start pairing.';

  @override
  String get bondFailed => 'Pairing failed.';

  @override
  String get deviceNotPaired =>
      'Device not paired. Pair it in Bluetooth settings.';

  @override
  String get connectionCanceled => 'Connection canceled.';

  @override
  String get obdInterrupted => 'OBD connection interrupted.';

  @override
  String get activityClosed => 'Activity closed.';

  @override
  String get bluetoothDevice => 'Bluetooth device';

  @override
  String get invalidNumber => 'Enter a valid number.';

  @override
  String obdStatus(String status) {
    return 'OBD connection: $status';
  }

  @override
  String frameCount(String count) {
    return '$count frames';
  }

  @override
  String compareCount(String count) {
    return 'Compare ($count/2)';
  }

  @override
  String deleteTripNotice(String name) {
    return '“$name” and its data will be deleted from the device.';
  }

  @override
  String importResult(String frames, String discarded, String invalid) {
    return 'Imported $frames frames. Discarded rows: $discarded; invalid values: $invalid.';
  }

  @override
  String eventCount(String count) {
    return '$count events · thresholds from the model saved with this trip';
  }

  @override
  String coverageNotice(String speed, String fuel) {
    return 'Coverage: speed $speed% · fuel flow $fuel%. Distance and fuel refer to valid intervals.';
  }

  @override
  String excludedWeight(String coverage) {
    return 'Coverage $coverage% · weight excluded';
  }

  @override
  String effectiveWeight(String coverage, String weight, String contribution) {
    return 'Coverage $coverage% · effective weight $weight% · contribution $contribution points';
  }

  @override
  String csvPreview(String rows) {
    return '$rows rows. Confirm units: speed km/h (or specified mph), RPM, load/throttle %, temperature °C (or specified °F), fuel flow l/h.';
  }

  @override
  String mapSemantics(String cells, String duration) {
    return 'Operating map: $cells cells, $duration of valid data. Tap a cell for details.';
  }

  @override
  String mapCellRange(
    String rpmMin,
    String rpmMax,
    String loadMin,
    String loadMax,
  ) {
    return '$rpmMin–$rpmMax rpm · $loadMin–$loadMax% load';
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
    return '$duration · $frames frames\nMean speed $speed km/h · fuel $fuel l/h\nPenalty $penalty · zone score contribution −$points points';
  }

  @override
  String timelineSemantics(String parameter, String samples) {
    return '$parameter timeline. $samples samples.';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String selectedDevice(String name) {
    return 'Selected device: $name';
  }

  @override
  String ecuLabel(String ecu) {
    return 'ECU $ecu';
  }

  @override
  String testProgress(String seconds) {
    return 'Test running · $seconds / 30 s';
  }

  @override
  String testConsumptionNotice(String distance, String fuel) {
    return 'Calculated from fuel flow and speed; this is not a historical average. Distance $distance km · estimated fuel $fuel L.';
  }

  @override
  String noValidSamples(String failures) {
    return 'No valid values · $failures invalid responses';
  }

  @override
  String sampleSummary(
    String average,
    String unit,
    String minimum,
    String maximum,
    String count,
  ) {
    return 'Mean $average $unit · min $minimum · max $maximum · $count readings';
  }

  @override
  String failedSamples(String count) {
    return ' · $count without data';
  }

  @override
  String logExported(String time) {
    return 'Exported: $time';
  }

  @override
  String logDevice(String name) {
    return 'Device: $name';
  }

  @override
  String logConnection(String status) {
    return 'Connection status: $status';
  }

  @override
  String logPids(String status) {
    return 'PID status: $status';
  }

  @override
  String logEcu(String ecu) {
    return 'ECU: $ecu';
  }

  @override
  String logProtocol(String protocol) {
    return 'Protocol: $protocol';
  }

  @override
  String logPidList(String pids) {
    return 'Standard PIDs: $pids';
  }

  @override
  String logSaved(String path) {
    return 'Log saved to $path';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String reconnectingAttempt(String attempt) {
    return 'Reconnection $attempt of 3…';
  }

  @override
  String connectingDevice(String name) {
    return 'Connecting to $name…';
  }

  @override
  String pairingDevice(String name) {
    return 'Pairing with $name… Confirm the Android request.';
  }

  @override
  String connectedDevice(String name) {
    return 'Connected to $name';
  }

  @override
  String pidsQueryRange(String first, String last) {
    return 'Querying PIDs $first–$last…';
  }

  @override
  String pidsFound(String count, String ecu) {
    return '$count standard PIDs detected on ECU $ecu.';
  }

  @override
  String pidCheckFailed(String error) {
    return 'PID check incomplete: $error';
  }

  @override
  String testInterrupted(String seconds, String count) {
    return 'Test stopped after ${seconds}s · $count valid readings';
  }

  @override
  String testCompleted(String count) {
    return 'Test complete · 30 s · $count valid readings';
  }

  @override
  String testFailed(String error) {
    return 'Test stopped: $error';
  }

  @override
  String warmupReason(String load, String temperature) {
    return 'Penalty for load over $load% below $temperature °C, over observed time.';
  }

  @override
  String economyReason(String baseline) {
    return 'Ratio against the $baseline l/100 km baseline; requires ≥80% coverage and ≥100 m distance.';
  }

  @override
  String scoreIntro(String score, String components) {
    return 'Score $score/100 across $components available components. ';
  }

  @override
  String scoreMapPortion(String percent) {
    return '$percent% of mapped time in favorable zones under the configured rules. ';
  }

  @override
  String scoreEventCount(String count) {
    return '$count acceleration or braking events. ';
  }

  @override
  String scoreMapCoverage(String percent) {
    return 'Map coverage: $percent%. Heuristic model, to be calibrated on real trips.';
  }

  @override
  String unsupportedModel(String version) {
    return 'Model $version is not supported';
  }

  @override
  String initializationFailed(String command) {
    return 'Initialization failed: $command.';
  }

  @override
  String unconfirmedCommand(String command) {
    return 'The adapter did not confirm $command.';
  }

  @override
  String incompleteResponse(String command) {
    return 'Incomplete $command response';
  }

  @override
  String incompletePidResponse(String command) {
    return 'Incomplete PID $command response';
  }

  @override
  String undecodedPid(String pid) {
    return 'Standard PID not decoded: $pid';
  }

  @override
  String noResponse(String command) {
    return 'No response to $command';
  }

  @override
  String connectionError(String error) {
    return 'Connection failed: $error';
  }

  @override
  String saveRecordingFailed(String error) {
    return 'Saving failed; recording paused. Data in memory is preserved. $error';
  }

  @override
  String automaticTripName(String date) {
    return 'Trip $date';
  }
}
