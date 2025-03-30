# MongoDB Standalone for Render.com

This repository contains a standalone MongoDB setup that can be deployed on Render.com or similar services. This setup includes SSL/TLS support for secure connections.

## Local Development

To run MongoDB locally for development:

```bash
docker-compose up -d
```

This will start MongoDB on port 27017 with the following credentials:
- Database: mangandoDB
- Admin User: adminUser
- Admin Password: adminPassword
- App User: mangandoUser
- App Password: userPassword

## Deploying to Render.com

1. Create a new service on Render.com
2. Select "Blueprint" as the service type
3. Connect your repository
4. The `render.yaml` file will be detected and will create the MongoDB service
5. Make sure to set secure passwords for `MONGO_ADMIN_PASSWORD` and `MONGO_APP_PASSWORD` in the environment variables

## Connection String

Once deployed, your MongoDB connection string will be:

```
mongodb://mangandoUser:userPassword@your-render-service-url:27017/mangandoDB?tls=true&tlsAllowInvalidCertificates=true
```

Replace `userPassword` with your actual password and `your-render-service-url` with the URL provided by Render.com.

Note the `tls=true` and `tlsAllowInvalidCertificates=true` parameters which are required for SSL/TLS connections.

## SSL/TLS Configuration

This MongoDB deployment uses self-signed certificates for SSL/TLS. If you're connecting from an application, you'll need to:

1. Use the `tls=true` parameter in your connection string
2. Use the `tlsAllowInvalidCertificates=true` parameter to accept the self-signed certificate
3. For Node.js applications using Mongoose, your connection options should include:
   ```javascript
   {
     useNewUrlParser: true,
     useUnifiedTopology: true,
     tls: true,
     tlsAllowInvalidCertificates: true
   }
   ```

## Important Notes

- The MongoDB data is stored on a persistent disk
- For production use, you should set strong passwords
- By default, MongoDB will be accessible publicly, so make sure to use strong credentials
- Consider setting up IP restrictions in Render.com for added security
- The SSL/TLS configuration uses self-signed certificates for simplicity. For production, consider using properly signed certificates 