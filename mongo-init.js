// Autenticazione come admin
db = db.getSiblingDB('admin');
db.auth('admin', 'password');

// Creo il database per l'applicazione
db = db.getSiblingDB('mangando');

// Creo un utente dedicato per l'applicazione
db.createUser({
  user: 'mangando_user',
  pwd: 'mangando_password',
  roles: [
    { role: 'readWrite', db: 'mangando' },
    { role: 'dbAdmin', db: 'mangando' }
  ]
});

// Creo una semplice collezione di esempio con campi di embedding
db.createCollection("vector_examples");

// Inserisco documenti di esempio con vettori
db.vector_examples.insertMany([
  {
    title: "Esempio 1",
    content: "Questo è un esempio di documento con vettore incorporato",
    embedding: Array.from({length: 384}, () => Math.random()) // Vettore casuale di dimensione 384
  },
  {
    title: "Esempio 2",
    content: "Un altro documento con vettore diverso",
    embedding: Array.from({length: 384}, () => Math.random())
  },
  {
    title: "Esempio 3",
    content: "Terzo documento di esempio",
    embedding: Array.from({length: 384}, () => Math.random())
  }
]);

// Creo un indice vettoriale
db.vector_examples.createIndex(
  { embedding: "vector" },
  {
    name: "vector_index",
    vectorOptions: {
      dimensions: 384,
      similarity: "cosine"
    }
  }
);

// Stampo un messaggio di conferma
print("Inizializzazione MongoDB con supporto per ricerca vettoriale completata");
print("È stato creato il database 'mangando' con una collezione di esempio 'vector_examples'");
print("L'indice vettoriale 'vector_index' è stato creato sulla collezione");
print("È stato creato l'utente 'mangando_user' per l'applicazione"); 