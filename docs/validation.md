# Validazione

## Verifiche automatiche

Eseguire `flutter analyze` e `flutter test` prima delle build native. La suite comprende:

- framing ELM, echo, risposte frammentate, header CAN/ISO, più ECU, dati incompleti;
- esclusione dei comandi non consentiti, richieste concorrenti e timeout che invalidano il canale;
- bitmap PID, formule di decodifica, unità e scadenza delle osservazioni;
- inizializzazione/polling reali del simulatore attraverso il protocollo condiviso;
- integrali noti di velocità/carburante, somma tempi celle, soglie, dati mancanti, duplicati, ordinamento e gap;
- timestamp originali per la smoothness, serializzazione del modello, import/export CSV;
- transazioni SQLite, raw log, recupero dei viaggi aperti e cancellazione con foreign key;
- ciclo Riverpod di avvio/pausa/ripresa/stop con persistenza;
- layout e navigazione su dimensioni mobile e desktop.

Queste prove validano il software contro input controllati. Non certificano il collegamento reale, la compatibilità di ogni centralina o l’accuratezza scientifica delle soglie.

## Prima prova sul veicolo

Da svolgere inizialmente da fermi, con il telefono a disposizione e il quadro acceso.

1. Registrare modello telefono, versione OS, firmware MX+, identificativo motore della Fiesta e PID disponibili nell’app ufficiale. Chiudere l’app ufficiale prima di connettere DriveMap.
2. Su Android verificare negazione/concessione dei permessi, Bluetooth spento, lista associati, associazione e connessione. Su iOS completare prima il prerequisito MFi descritto nel README.
3. Annotare tempo di connessione, protocollo rilevato, ECU scelta, bitmap 0100/0120/0140. Confermare che risposte di altre ECU non entrino nello stesso set di campioni.
4. Confrontare velocità (zero da fermi), RPM, coolant e tensione con la strumentazione/app ufficiale in sessioni separate. Verificare `015E` senza supporre che il fuel rate del CSV ufficiale sia un PID standard.
5. Registrare 2–5 minuti; annotare letture/s, latenza e campioni mancanti. Esportare pacchetto DriveMap e CSV raw.
6. Spegnere Bluetooth durante la registrazione: devono sparire i valori live, apparire la riconnessione e interrompersi i segmenti. Riattivare e verificare il recupero o il pulsante per riprovare dopo tre tentativi.
7. Provare pausa/ripresa/stop, passaggio in background e ritorno. Il background deve sospendere il viaggio e richiedere una riconnessione/ripresa esplicita.
8. Terminare forzatamente l’app: alla riapertura il viaggio deve comparire come interrotto, con tutti i dati committati e nessun riempimento artificiale dell’intervallo mancante.
9. Trasferire il pacchetto DriveMap al desktop: dati, origine e configurazione devono essere preservati; lo score deve coincidere.

## Dataset e calibrazione

Raccogliere più viaggi urbani, extraurbani e misti, con partenza a caldo/freddo e durate confrontabili. Tenere un registro di condizioni note (traffico, meteo, pendenza, carico vettura). Non creare intenzionalmente manovre rischiose per superare una soglia: per i casi limite usare dati sintetici.

Misurare almeno: copertura per PID, frequenza effettiva per PID, latenze, tentativi di riconnessione, percentuale di frame con RPM/carico validi, distanza e carburante osservati, differenze rispetto all’export OBDLink e stabilità del punteggio su percorsi ripetuti. L’export OBDLink è un riferimento esplorativo, non ground truth.

Ripetere il calcolo variando una soglia/peso alla volta (ad esempio ±10/20%), conservando la versione del modello. Presentare effetti su score, sottoscore e tempo per zona. Stabilire una baseline economy solo dopo avere abbastanza viaggi comparabili. Riportare esplicitamente le componenti omesse e la copertura di ogni confronto.

## Criteri di completamento del progetto

- Connessione MX+ reale verificata sul telefono scelto e sulla Fiesta.
- Dataset pilota e nuovi viaggi acquisiti/importati senza confusione di unità o centraline.
- Nessuna integrazione attraverso pause/disconnessioni; recupero dopo arresto verificato su dispositivo.
- Mappa, score, spiegazioni ed esportazioni coerenti per input e modello fissati.
- Soglie e baseline motivate sperimentalmente; limiti e differenze rispetto all’app ufficiale documentati.
- Build e prove specifiche su ogni piattaforma dichiarata per la consegna.

L’implementazione del software da sola non chiude questi criteri sperimentali.
