# Architettura e decisioni metodologiche

Il riferimento è `lib/drivemap_report.pdf`, versione 1.0 del 30 settembre 2026. Questa implementazione copre il percorso MVP dalla lettura all’analisi. La validazione scientifica sul veicolo e la calibrazione delle soglie richiedono nuovi dataset reali.

## Struttura

```text
src/domain/                   PID, campioni, frame, viaggi
src/features/obd/             trasporto astratto, ELM, decoder, sessione, simulatore
src/features/trips/           parsing e resampling CSV
src/features/analytics/       aggregazione, eventi, score e spiegazioni
src/infrastructure/           SQLite e repository tramite Drift
src/providers.dart            controller Riverpod e coordinamento dei casi d’uso
src/presentation/             live, archivio, analisi, grafici, confronto, impostazioni
android/.../MainActivity.kt   bridge RFCOMM nativo
rios/Runner/AppDelegate.swift bridge ExternalAccessory nativo
```

Il percorso iOS effettivo è `ios/Runner/AppDelegate.swift`.

Il domain e l’analizzatore non dipendono da Flutter/Riverpod. I provider gestiscono stato della connessione, frame corrente, registrazione, database, archivio, dettagli e configurazione. Il simulatore implementa lo stesso `ObdTransport`: non alimenta direttamente la UI con valori inventati.

## Trasporto e protocollo

1. Android espone dispositivi già associati e apre SPP UUID `00001101-0000-1000-8000-00805F9B34FB` su un worker thread. L’associazione di nuovi dispositivi è delegata al sistema. iOS usa `EAAccessoryManager` ed `EASession`, subordinati ai protocolli MFi autorizzati.
2. Un solo comando ELM può essere in volo. Il canale accumula frammenti fino al prompt `>`; impone un limite di 32 KiB. Il timeout invalida il canale: una risposta arrivata tardi non può essere attribuita al PID successivo.
3. Inizializzazione: `ATZ`, `ATE0`, `ATL0`, `ATS1`, `ATH1`, `ATSP0`, `ATAT1`, `ATST64`. Le risposte devono confermare i comandi. Sono configurazioni dell’adattatore, non scritture ECU.
4. `0100` sceglie il primo risponditore, preferendo `7E8` o `18DAF110`; la stessa centralina viene usata per tutte le letture e pagine successive. Non si uniscono bitmap di centraline diverse. Intestazioni CAN 11/29 bit e ISO a tre byte sono gestite per le risposte a singolo frame richieste dall’MVP.
5. Le bitmap `0120` e `0140` vengono richieste solo se la pagina precedente ne dichiara l’esistenza. PID supportati non significa dato sempre disponibile: `NO DATA` resta una qualità distinta e causa backoff.
6. Polling a scadenze, senza timer concorrenti: RPM/speed/load 250 ms, throttle/fuel 500 ms, MAP 1 s, coolant 2 s, voltage 5 s. Sono intervalli minimi fra letture; il throughput effettivo viene misurato e può essere inferiore. Dopo errori persistenti si chiude il socket e si ripete l’inizializzazione, con massimo tre retry (1/2/4 s). Dopo 30 s di collegamento stabile il budget di retry può ripartire.
7. L’app espone una allowlist di comandi di lettura/configurazione e nessuna console raw.

## Tempo, qualità e persistenza

La sessione usa un’origine UTC e uno `Stopwatch` monotono: le variazioni dell’orologio civile durante il viaggio non cambiano la progressione dei timestamp. Il timestamp del campione rappresenta la ricezione completa, non un timestamp interno ECU. La latenza è misurata separatamente.

Ogni 500 ms si crea uno snapshot causale con le ultime letture valide. Scadenza: 1,5 s per i PID rapidi, due volte l’intervallo per i lenti. I dati non vengono riportati indietro nel tempo. Una lettura `NO DATA`/invalida invalida il valore precedente; campioni fuori ordine non lo sostituiscono. I timestamp dei valori sono persistiti insieme al frame.

SQLite conserva viaggi, configurazione, PID supportati, frame, raw, eventi e celle aggregate. Scritture parametrizzate, foreign key, WAL e transazioni. I dati grezzi sono salvati ogni secondo e allo stop/pausa; un arresto forzato può perdere l’ultimo buffer non ancora confermato. La riapertura marca i viaggi ancora aperti come interrotti, conservando quanto già committato. Non riprende automaticamente una sessione vecchia. Se un salvataggio fallisce, il recorder si mette in pausa e mantiene il buffer; ripresa/stop ritentano il salvataggio.

Pause e disconnessioni creano segmenti distinti. Le analisi non integrano attraverso i loro confini. Un gap >1,5 s nello stesso segmento diminuisce la copertura ma non aggiunge distanza, carburante o tempo alle celle. Non si inventa un intervallo dopo l’ultimo campione. Tempo osservato, tempo mappato e durata civile possono quindi differire.

## Analisi deterministica `rules-1.0.0`

I frame vengono ordinati per timestamp, deduplicati e validati per range e freschezza. La stessa configurazione e gli stessi frame producono gli stessi risultati. I risultati vengono ricalcolati dai frame usando la configurazione del viaggio; gli aggregati SQLite sono una cache.

### Celle operative

- Bin di 500 RPM e 10 punti di calculated load.
- Carico 100% incluso nella cella 90–100%.
- Escluso il motore spento (RPM = 0) dalla mappa e dal sottoscore warm-up.
- Per ogni cella: conteggio, tempo, velocità media, fuel rate medio, throttle medio, penalità media.
- Medie ponderate per durata e per disponibilità del singolo parametro.
- Quattro colorazioni: permanenza, fuel rate, indice di favorevolezza relativo, penalità.
- La selezione della cella mostra il contributo negativo al sottoscore zone; mappa e score usano lo stesso costo.

### Zone

Default: regime favorevole `[1200,3500)`, carico favorevole `[20,75)`.

- Costo 1: RPM ≥3500, oppure RPM <1200 e carico ≥75%.
- Costo 0: zona favorevole.
- Costo 0,5: altre condizioni valide.
- `S_zone = 100 × (1 − Σ costo × dt / tempo_mappato)`.

Questa versione penalizza l’alto regime anche a carico basso. È una scelta euristica esplicita, modificabile attraverso le soglie, da verificare sul motore concreto. L’indice relativo della cella è `100 × (1 − costo_medio)`; non è un rapporto fra lavoro e carburante e non viene presentato come rendimento termico.

### Regolarità

`a = Δspeed / 3,6 / Δt` calcolata solo quando cambia il timestamp originale della velocità. Questo evita i falsi picchi causati dal riuso della stessa lettura in più frame. Intervalli di derivazione >2 s, pause e gap interrompono la serie.

Soglie iniziali: accelerazione >2,5 m/s²; frenata <−3 m/s². Evento al superamento della soglia, senza contare ogni frame della stessa manovra. `S_smooth = clamp(100 − 5 × eventi/minuto_osservato, 0, 100)`. La frequenza e la quantizzazione della velocità OBD limitano la precisione; non è un accelerometro calibrato. Throttle jerk e sensori smartphone sono estensioni.

### Riscaldamento

Sotto 70 °C, `g = max(load − 50, 0) / 50`. `S_warmup = 100 × (1 − Σ g × dt / tempo_con_coolant_load_rpm_validi)`. Le condizioni a motore già caldo contribuiscono con penalità nulla. Il valore segue la normalizzazione per il tempo del viaggio indicata dal report; confronti di durata molto diversa richiedono cautela.

### Consumo

Integrazione trapezoidale: litri = media dei fuel rate agli estremi × dt/3600; chilometri = media velocità × dt/3600. Entrambi gli estremi devono essere validi. Le quantità totali parziali mostrano la copertura.

`l/100 km` usa soltanto intervalli in cui velocità e fuel rate sono disponibili insieme, richiede almeno 100 m e copertura comune ≥80%. Non divide il carburante di una porzione di viaggio per la distanza di un’altra.

La baseline è inizialmente disattivata (0). Quando l’utente la configura, `S_economy = clamp(100 × baseline / consumo, 0, 100)`. Va scelta da percorsi e condizioni comparabili; non esiste ancora una classificazione automatica del percorso.

### Score totale

Pesi iniziali: zone 0,40; regolarità 0,25; riscaldamento 0,20; economy 0,15. Zone/smooth/warm-up richiedono almeno 5 s di dati per componente. Una componente non disponibile resta `null`, con peso escluso. Il totale rinormalizza i pesi rimanenti e mostra copertura e contributi effettivi. Un peso configurato a zero disabilita la componente. Non attribuiamo 100 punti a un sensore mancante.

## Correzioni/proposte rispetto al PDF

1. **Bluetooth**: specificare Classic/RFCOMM per Android e MFi/ExternalAccessory per iOS, includendo l’abilitazione del produttore tra i prerequisiti. Il supporto di iOS dichiarato da MX+ non basta da solo per un’app nuova.
2. **Fuel rate**: il CSV OBDLink può contenere dati calcolati o proprietari. L’MVP interroga PID standard `015E`; se manca, economy viene omessa. Non stimare automaticamente carburante da MAF senza ipotesi sul combustibile.
3. **Coppia**: l’eventuale conversione della coppia percentuale deve usare la semantica SAE del PID e la reference torque disponibile, non una generica coppia massima presa da una scheda tecnica. Non è implementata nell’MVP.
4. **Accelerazione**: i tre assi del telefono richiedono sensori, orientamento, rimozione della gravità e calibrazione. L’MVP usa la derivata temporale della velocità OBD e lo dichiara.
5. **Score confrontabile**: normalizzare gli eventi per il tempo, versionare configurazione e formule, mostrare copertura, escludere componenti mancanti e confrontare viaggi con modelli/condizioni simili.
6. **Efficienza**: denominare il valore iniziale “indice relativo secondo le regole”; non dedurre efficienza energetica dal solo fuel rate. Baseline data-driven e analisi di sensibilità restano parte della validazione scientifica.
7. **Frequenza**: 500 ms è una griglia di output, non una garanzia che ogni PID venga letto a 2 Hz. Conservare età e timestamp di ciascuna misura.
8. **Background**: rendere esplicito il comportamento operativo. L’MVP registra solo in primo piano; un servizio persistente richiede lavoro e validazione distinti.

## Sviluppi successivi

Autorizzazione MFi e prove MX+, PID proprietari solo dove necessari, adattamento all’export OBDLink reale, profili multipli/percorsi, filtri di accelerazione calibrati, asse throttle alternativo, sensibilità dei pesi, baseline data-driven e acquisizione in background. GPS, cloud e 3D restano opzionali come nel report.
