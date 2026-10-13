# DriveMap · registrazione OBD e analisi viaggi

La schermata principale collega OBDLink MX+ su Android con Bluetooth Classic RFCOMM/SPP, mostra la telemetria live e registra i viaggi localmente. Il verificatore OBD con ATI, PID supportati e log resta accessibile da **Diagnostica e log OBD**.

## Navigazione e aspetto

La barra inferiore compatta contiene quattro pagine: **Home** per connessione e registrazione, **Telemetria** per i valori live, **Viaggi** per archivio ed esportazione e **Profilo** per il veicolo e i parametri di analisi. Cambiare pagina conserva la sessione OBD e lo stato della registrazione.

`AppTheme` centralizza il tema verde e grigio chiaro. `MainScaffold` contiene intestazione e navigazione; il piccolo logo isometrico è disegnato in Flutter, senza asset o librerie aggiuntive.

In **Profilo → Lingua** si può scegliere **Italiano** o **English**. La scelta aggiorna subito tutte le schermate, conserva la sessione OBD e il viaggio in corso e viene salvata sul telefono per gli avvii successivi. La lingua iniziale è l’italiano.

Le traduzioni sono in `lib/l10n/app_it.arb` e `lib/l10n/app_en.arb`. Flutter genera le classi tipizzate in `lib/src/localization/generated` usando `l10n.yaml`; dopo una modifica ai file ARB eseguire `flutter gen-l10n`. `localeProvider` gestisce la preferenza indipendentemente dalla telemetria. La UI traduce anche gli stati diagnostici e le descrizioni dell’analisi; le risposte seriali, i dati salvati e lo schema dei CSV/JSON conservano il formato originale. Gli eventuali messaggi tecnici sconosciuti del sistema o dell’adattatore restano visibili integralmente.

## Prova sul Samsung Galaxy S25 Ultra

1. Inserire MX+ nella porta OBD e accendere il quadro. Chiudere altre app connesse all'adattatore.
2. Se MX+ non è già associato, toccare **Associa dispositivo** e completare l'associazione nelle impostazioni Bluetooth Android.
3. Tornare a DriveMap, toccare **Dispositivi associati** e selezionare OBDLink MX+. Concedere i permessi Bluetooth richiesti.
4. Attendere **Telemetria attiva** e controllare che i PID utili risultino disponibili. Toccare **Inizia viaggio** prima di partire.
5. Durante la registrazione lasciare DriveMap in primo piano. Quando la connessione RFCOMM è attiva Android tiene acceso lo schermo; se l'app va in background, la raccolta viene messa in pausa e il collegamento chiuso.
6. Al termine del percorso toccare **Termina e salva**, poi **Viaggi** e aprire il viaggio. Dal pulsante di esportazione in alto scegliere **CSV · telemetria e orari PID**. Il CSV contiene sia il timestamp dei frame sia quello della lettura di ogni PID; è disponibile anche un CSV con le risposte OBD raw.
7. Se la connessione cade, l'app tenta alcune riconnessioni. Se non riesce, mette in pausa il viaggio: riconnettere l'adattatore e toccare **Riprendi** per continuare nello stesso viaggio.

La raccolta è locale e in primo piano: non è progettata per proseguire con lo schermo spento o con l'app in background. Per un viaggio lungo collegare il telefono all'alimentazione e avviare la registrazione prima di partire; non interagire con l'app durante la guida.

Un PID marcato come supportato dalla bitmap potrebbe comunque non restituire un valore valido quando viene letto. Il livello carburante è espresso in percentuale; il totale in litri non viene stimato. I consumi dei viaggi sono integrati dai PID portata carburante e velocità sugli intervalli con dati validi: sono stime OBD e la schermata mostra la copertura osservata.

## Implementazione

- Android usa la discovery Bluetooth Classic, l'associazione via API Android e `BluetoothSocket` con UUID SPP. Ferma la scansione prima di connettersi.
- Android 12+ richiede `BLUETOOTH_SCAN` e `BLUETOOTH_CONNECT`; Android 11 e precedenti richiedono `ACCESS_FINE_LOCATION` durante la discovery. La posizione non è usata dall'app.
- `AdapterCheck` separa scansione, associazione, connessione, interrogazione PID e log dalla UI. `ElmChannel` ricompone i frammenti fino al prompt `>` e consente un solo comando in volo. Il test diagnostico interroga i parametri principali per 30 secondi.
- I log della sessione includono orari, eventi Bluetooth, comandi e risposte seriali, errori, centralina e bitmap PID. L'esportazione usa il selettore documenti Android.
- `ObdSession` mantiene un unico collegamento RFCOMM, interroga i PID supportati in sequenza e tenta la riconnessione dopo una perdita del collegamento. Frame e campioni raw vengono salvati nel database SQLite locale ogni secondo.
- L'app mette in pausa la registrazione e disconnette il trasporto quando passa in background. I CSV esportati contengono timestamp UTC individuali per i PID, così è possibile controllare la frequenza effettiva delle letture.
