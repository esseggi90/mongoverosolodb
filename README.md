# Server MongoDB per Render.com

Questa configurazione permette di eseguire MongoDB con supporto per la ricerca vettoriale su Render.com.

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
   - Non è necessario modificare altre impostazioni, Render rileverà automaticamente il Dockerfile

3. Configura il servizio:
   - Assicurati che sia selezionato un piano con almeno 1GB di RAM (Piano "Starter" o superiore)
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

## Note sulla sicurezza

Per un ambiente di produzione, dovresti:
1. Cambiare tutte le password in `.env` e `render.yaml`
2. Limitare l'accesso al database solo dall'IP della tua applicazione
3. Considerare l'utilizzo di MongoDB Atlas per un database gestito più robusto 