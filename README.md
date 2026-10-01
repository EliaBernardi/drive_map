# DriveMap

Applicazione Flutter per il progetto universitario descritto in [drivemap_report.pdf](lib/drivemap_report.pdf): telemetria OBD-II, registrazione locale, mappa operativa RPM–carico e score spiegabile.

## Avvio

Richiede un SDK compatibile con **Dart 3.13.4** (sviluppato con Flutter 3.47.5), Xcode per iOS/macOS e Android SDK/JDK 17 per Android.

```sh
flutter pub get
flutter run -d macos
# oppure, con telefono collegato:
flutter run -d <device-id>
```

Da **Live → Esplora con la demo** si usa un simulatore ELM che attraversa la stessa pipeline del dispositivo reale. Attendere “Telemetria attiva”, avviare un viaggio, registrare almeno 10 secondi e terminarlo. Il risultato appare in **Viaggi**, contrassegnato come demo. Nessuna sessione o misura simulata viene inserita automaticamente nell’archivio.

## Funzioni implementate

- Stato applicativo e dipendenze con Riverpod 3 (`Notifier`, `AsyncNotifier`, `FutureProvider`).
- Android: dispositivi associati, associazione tramite impostazioni di sistema, permessi runtime, Bluetooth Classic RFCOMM/SPP.
- iOS: bridge `ExternalAccessory`, selettore accessori, stream e gestione delle disconnessioni. **Richiede la configurazione MFi del produttore prima dell’uso con MX+.**
- Inizializzazione ELM/STN, riconoscimento della centralina, bitmap PID 00/20/40, polling seriale di fino a otto parametri, timeout e tre tentativi di riconnessione.
- Dashboard con valori mancanti espliciti, frequenza effettiva delle letture, latenza, PID disponibili e modalità demo.
- Frame causali ogni 500 ms, timestamp originali delle osservazioni, scadenza per parametro e raw log delle risposte.
- Viaggi avviabili, sospendibili e terminabili; salvataggi SQLite/Drift in transazioni, recupero delle sessioni interrotte.
- Timeline interattiva per sei parametri, eventi di accelerazione/frenata, heatmap con selezione delle celle e quattro visualizzazioni.
- Score v1 con sottoscore, pesi effettivi, spiegazioni e copertura dei dati. Configurazione salvata con ciascun viaggio.
- Importazione CSV con associazione esplicita delle colonne e unità, confronto di due viaggi, esportazione CSV e pacchetti DriveMap JSON.
- Layout mobile e desktop, gestione degli errori di connessione, importazione e persistenza.

## Collegare OBDLink MX+

**MX+ usa Bluetooth Classic; non è un adattatore BLE.** Non sostituire il trasporto con `flutter_blue_plus` per questo dispositivo.

### Android

1. Inserire MX+ nella porta OBD, accendere il quadro e premere il pulsante di associazione dell’adattatore.
2. Usare **Associa dispositivo** per aprire le impostazioni Bluetooth di Android e associare MX+.
3. Chiudere l’app OBDLink e altre app connesse allo stesso adattatore.
4. In DriveMap usare **Dispositivi associati**, concedere il permesso Bluetooth e selezionare MX+.
5. Attendere la verifica dei PID e avviare il viaggio. Il primo rilevamento del protocollo può richiedere 15 secondi.

La discovery dei dispositivi nuovi è affidata alla UI Bluetooth del sistema; l’app elenca quelli associati. Non serve un permesso di localizzazione per questo flusso.

### iOS — requisito esterno ancora da soddisfare

MX+ è un accessorio MFi. La compatibilità con l’app ufficiale non abilita automaticamente un’altra app.

1. Ottenere da **OBD Solutions** l’identificativo esatto del protocollo ExternalAccessory e le condizioni di abilitazione dell’app/bundle identifier.
2. Inserire tale identificativo in `UISupportedExternalAccessoryProtocols` in [Info.plist](ios/Runner/Info.plist). L’array è volutamente vuoto: un identificativo presunto renderebbe l’integrazione ingannevole.
3. Impostare bundle identifier e firma in Xcode secondo i dati concordati con il produttore.
4. Associare MX+ al telefono, usare il selettore accessori e verificare sul dispositivo reale.

Il bridge è implementato, ma l’accesso a MX+ su iOS **non è operativo finché questo requisito non viene soddisfatto**. L’app restituisce un messaggio specifico se il protocollo non è configurato.

## Piattaforme e limiti attuali

| Piattaforma | Acquisizione | Archivio e analisi |
| --- | --- | --- |
| Android | RFCOMM/SPP implementato, da provare con MX+ reale | SQLite locale |
| iOS | ExternalAccessory implementato, configurazione MFi necessaria | SQLite locale |
| macOS | Demo; acquisizione reale non prevista nell’MVP desktop | Importazione, analisi, confronto, esportazione |
| Windows | Demo; acquisizione reale non prevista nell’MVP desktop | Codice condiviso, build da verificare su Windows |
| Web | Non supportato dall’MVP (database nativo) | Non supportato |

La registrazione è **in primo piano**: passando in background viene messa in pausa e il collegamento chiuso. Ritornare in Live, riconnettere e riprendere esplicitamente. Il telefono resta acceso durante la connessione. Un servizio Android e la gestione iOS in background sono sviluppi successivi, non promesse implicite.

Il profilo veicolo iniziale è Ford Fiesta 2021. Il framework non presume che il fuel rate dell’export OBDLink corrisponda a un PID standard supportato: viene verificato `015E` sulla centralina. Non sono implementati PID proprietari Ford, DTC, scritture ECU, GPS, accelerometro del telefono o sincronizzazione cloud.

## Dati e portabilità

Il database `drivemap.sqlite` è nella directory Application Support dell’app; non richiede server né credenziali. Drift esegue SQLite in un isolate. Lo schema SQL esplicito non richiede code generation.

- **CSV telemetria**: frame, segmenti e timestamp originali di ciascun PID. I valori mancanti restano celle vuote.
- **CSV raw**: risposta OBD originale, PID, valore, unità, qualità e latenza.
- **Pacchetto DriveMap JSON**: frame, raw, origine demo/reale, profilo e configurazione dello score. È il formato da usare per trasferire un viaggio al desktop mantenendone il modello.

L’import CSV propone le colonne note ma richiede conferma. Supporta timestamp ISO 8601 con fuso o secondi trascorsi con data iniziale esplicita; separatori comuni e decimali con virgola. mph, °F e psi sono convertiti se dichiarati nell’intestazione. Fuel rate g/s/gal/h e absolute load non vengono equiparati a l/h/calculated load. Limiti: 30 MB, 200.000 righe, 24 ore. I file CSV generici usano il modello corrente; i pacchetti DriveMap mantengono quello originale. Il CSV pilota citato nel report non è incluso nella repo: l’adattamento alle sue intestazioni esatte resta da verificare.

## Architettura e metodologia

- [Architettura, formule e correzioni al report](docs/architecture.md)
- [Piano di validazione sul veicolo](docs/validation.md)

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --debug --no-codesign
flutter build macos --debug
```

I test coprono protocollo, scadenza dei dati, unità, score, CSV, transazioni, recupero, registrazione Riverpod e layout. Non sostituiscono una prova con auto e adattatore.

## Fonti tecniche

- [OBDLink: risorse per sviluppatori](https://www.obdlink.com/developers/)
- [OBDLink: caratteristiche Bluetooth della famiglia](https://www.obdlink.com/faq/)
- [Android: connessioni RFCOMM](https://developer.android.com/develop/connectivity/bluetooth/connect-bluetooth-devices)
- [Android: permessi Bluetooth](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions)
- [Apple: ExternalAccessory e autorizzazione del produttore](https://developer.apple.com/documentation/externalaccessory/)
- [Drift: database nativo in isolate](https://drift.simonbinder.eu/platforms/vm/)
