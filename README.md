# DriveMap · collegamento OBD

La schermata attiva del progetto Flutter collega OBDLink MX+ su Android tramite Bluetooth Classic RFCOMM/SPP e verifica la comunicazione con il comando `ATI`.

## Prova sul Samsung Galaxy S25 Ultra

1. Inserire MX+ nella porta OBD, accendere il quadro e attivare la modalità associazione dell'adattatore. Chiudere altre app connesse a MX+.
2. Avviare l'app sul telefono e toccare **Aggiungi OBD**. Concedere il permesso **Dispositivi nelle vicinanze** quando richiesto.
3. Attendere la card **OBDLink…** e toccarla. Se non compare, ripetere la ricerca e, se il nome è differente, disattivare **Mostra solo OBDLink**. Sono mostrate anche le OBDLink già associate al telefono.
4. Confermare l'associazione nell'interfaccia Android. L'app interrompe la scansione, apre il socket RFCOMM e invia `ATI`.
5. Controllare nel log `→ ATI` e la risposta `← …`. **Ripeti ATI** e **Disconnetti** permettono di verificare il collegamento.

Se l'adattatore è già associato, il tocco della card avvia direttamente la connessione. Le impostazioni Bluetooth di Android restano accessibili come alternativa. Scansione, pairing e connessione possono fallire se MX+ non è alimentato, non è rilevabile o è occupato da un'altra app.

## Implementazione

- Il bridge Kotlin usa la discovery Bluetooth Classic e invia a Flutter i dispositivi trovati, gli aggiornamenti del nome e la fine della ricerca. Deduplica per indirizzo nella UI. L'associazione usa `createBond()` e attende lo stato confermato da Android; la discovery viene fermata prima della connessione RFCOMM/SPP.
- Su Android 12+ sono richiesti a runtime `BLUETOOTH_SCAN` e `BLUETOOTH_CONNECT`. Su Android 11 e precedenti, la discovery richiede `ACCESS_FINE_LOCATION` a runtime; il progetto non usa la posizione per l'analisi dei viaggi.
- `AdapterCheck` separa scansione, associazione, socket, errori e log dalla schermata. `ElmChannel` ricompone i frammenti seriali fino al prompt `>` e consente un solo comando per volta. Il timeout invalida il canale e richiede una nuova connessione.

Il repository iniziale include moduli sperimentali per le fasi successive, non avviati dalla schermata attuale. Non sono stati aggiunti polling dei PID o registrazione dei viaggi a questo flusso.

## Controlli locali

```sh
flutter analyze
flutter build apk --debug
```

L'analisi statica non sostituisce la prova di discovery, associazione, socket e risposta ATI con telefono e adattatore reali.
