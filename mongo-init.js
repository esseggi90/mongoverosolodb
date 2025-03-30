// Inizializzazione del database
print("Starting MongoDB initialization...");

// Autenticazione come admin
db = db.getSiblingDB('admin');

// Creo l'utente admin se non esiste
if (!db.getUser('admin')) {
  print("Creating admin user...");
  db.createUser({
    user: 'admin',
    pwd: 'password',
    roles: [{ role: 'root', db: 'admin' }]
  });
}

// Autentichiamoci come admin
db.auth('admin', 'password');

// Creo il database per l'applicazione
print("Creating application database...");
db = db.getSiblingDB('mangando');

// Creo un utente dedicato per l'applicazione se non esiste
if (!db.getUser('mangando_user')) {
  print("Creating application user...");
  db.createUser({
    user: 'mangando_user',
    pwd: 'mangando_password',
    roles: [
      { role: 'readWrite', db: 'mangando' },
      { role: 'dbAdmin', db: 'mangando' }
    ]
  });
}

// Creo una semplice collezione di esempio con campi di embedding
print("Creating example collection...");
try {
  db.createCollection("vector_examples");
} catch (e) {
  print("Collection vector_examples already exists");
}

// Inseriamo documenti di esempio solo se la collezione è vuota
const count = db.vector_examples.count();
if (count === 0) {
  print("Inserting example documents...");
  
  try {
    db.vector_examples.insertMany([
      {
        title: "Esempio 1",
        content: "Questo è un esempio di documento con vettore incorporato",
        embedding: Array.from({length: 384}, () => Math.random())
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
    print("Example documents inserted successfully");
  } catch (e) {
    print("Error inserting documents: " + e.message);
  }
}

// Creo un indice vettoriale se non esiste
print("Creating vector index...");
try {
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
  print("Vector index created successfully");
} catch (e) {
  print("Error creating vector index: " + e.message);
}

// Stampo un messaggio di conferma
print("MongoDB initialization completed");
print("Database 'mangando' is ready with collection 'vector_examples'");
print("Vector index 'vector_index' is ready");
print("Application user 'mangando_user' is ready"); 