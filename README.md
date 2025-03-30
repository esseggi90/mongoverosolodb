# Server MongoDB per Render.com

Questa configurazione permette di eseguire MongoDB con supporto per la ricerca vettoriale su Render.com.

## Risoluzione problemi

La configurazione è stata migliorata per risolvere i problemi di avvio di mongo-express:
- Aggiunto script di attesa per MongoDB prima di avviare mongo-express
- Migliorata la configurazione di supervisord con log dettagliati
- Configurata l'autenticazione in modo corretto
- Aggiunti controlli di sicurezza nel mongo-init.js

## Contenuto della cartella

- `Dockerfile`: Configura un container Docker con MongoDB e Mongo Express
- `.env`: Contiene tutte le variabili d'ambiente necessarie
- `mongo-init.js`: Script di inizializzazione per il database
- `render.yaml`: Configurazione per il deployment su Render.com

## Deployment su Render.com

1. Carica questi file su un repository Git (GitHub, GitLab, ecc.)

2. Collegati a Render.com e crea un nuovo Web Service:
   - Seleziona il repository contenente questi file
   - Seleziona "Docker" come ambiente
   - Assicurati di selezionare il piano "Starter" (o superiore) con almeno 1GB di RAM

3. Configura il servizio:
   - Nella sezione "Disks", aggiungi un disco:
     - Mount path: `/data/db`
     - Size: 10GB (o più, in base alle tue esigenze)

4. Clicca su "Create Web Service"

## Connessione all'istanza MongoDB

Una volta che il servizio è in esecuzione, puoi connetterti al tuo database MongoDB:

- **URL di connessione**: `mongodb://mangando_user:mangando_password@NOME-SERVIZIO.onrender.com:27017/mangando`
  (Sostituisci NOME-SERVIZIO con il nome del tuo servizio Render)

- **Interfaccia Mongo Express**: `https://NOME-SERVIZIO.onrender.com:8081`
  - Username: `admin`
  - Password: `password`

## Configurazione dell'applicazione principale

Modifica il file `.env` nella tua applicazione principale:

```
MONGODB_URI=mongodb://mangando_user:mangando_password@NOME-SERVIZIO.onrender.com:27017/mangando
```

## Ricerca vettoriale

Per utilizzare la ricerca vettoriale, puoi eseguire query come questa:

```javascript
db.vector_examples.aggregate([
  {
    $vectorSearch: {
      index: "vector_index",
      path: "embedding",
      queryVector: Array.from({length: 384}, () => Math.random()),
      numCandidates: 100,
      limit: 2
    }
  },
  {
    $project: {
      title: 1,
      content: 1,
      score: { $meta: "vectorSearchScore" }
    }
  }
]);
```

## Note sulla sicurezza

Per un ambiente di produzione, dovresti:
1. Cambiare tutte le password nei file di configurazione
2. Abilitare TLS/SSL per le connessioni
3. Limitare l'accesso al database solo agli IP delle tue applicazioni 