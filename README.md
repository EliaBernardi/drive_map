# DriveMap · collegamento OBD

La schermata attiva collega OBDLink MX+ su Android con Bluetooth Classic RFCOMM/SPP. Dopo la connessione identifica l'adattatore e interroga automaticamente i bitmap Mode 01 per elencare i PID standard dichiarati dalla centralina.

## Prova sul Samsung Galaxy S25 Ultra

1. Inserire MX+ nella porta OBD e accendere il quadro. Attivare la modalità associazione se l'adattatore non è già associato. Chiudere altre app connesse a MX+.
2. Avviare l'app e toccare **Aggiungi OBD**. Concedere i permessi Bluetooth richiesti.
3. Attendere la card **OBDLink…** e toccarla. Il filtro “Mostra solo OBDLink” si può disattivare se l'adattatore trasmette un nome diverso. Sono elencati anche dispositivi OBDLink già associati.
4. Confermare la richiesta di associazione di Android. A connessione stabilita l'app invia `ATI`, configura l'adattatore e interroga `0100` e gli eventuali bitmap successivi (`0120`…`01E0`).
5. La scheda **PID standard disponibili** mostra i codici rilevati, la centralina che ha risposto e il protocollo. Il log mostra i comandi e le risposte complete.
6. Toccare **Esporta log in un file .txt** e scegliere dove salvare il file proposto con nome `yyyyMMdd_HHmmss.txt`.

Un PID marcato come supportato dalla bitmap potrebbe comunque non restituire sempre un valore valido quando verrà letto. La schermata attuale rileva solo il supporto dichiarato; non esegue polling dei valori.

## Implementazione

- Android usa la discovery Bluetooth Classic, l'associazione via API Android e `BluetoothSocket` con UUID SPP. Ferma la scansione prima di connettersi.
- Android 12+ richiede `BLUETOOTH_SCAN` e `BLUETOOTH_CONNECT`; Android 11 e precedenti richiedono `ACCESS_FINE_LOCATION` durante la discovery. La posizione non è usata dall'app.
- `AdapterCheck` separa scansione, associazione, connessione, interrogazione PID e log dalla UI. `ElmChannel` ricompone i frammenti fino al prompt `>` e consente un solo comando in volo.
- I log della sessione includono orari, eventi Bluetooth, comandi e risposte seriali, errori, centralina e bitmap PID. L'esportazione usa il selettore documenti Android.

Le fasi di polling PID, registrazione e analisi dei viaggi non sono avviate da questa schermata.
