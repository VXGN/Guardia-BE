# Guardia Backend

### Environment

1. Copy `.env.example` to `.env` and fill in values:
   ```bash
   cp .env.example .env
   ```

### Jalanin MySQL via Docker

```bash
docker-compose up -d
```

### Install & Generate Prisma Client

```bash
npm install
npx prisma generate
```

### Run in Development

```bash
npm run dev
```

Build for production:

```bash
npm run build
npm start
```

## Packages

- `express` – web framework
- `axios` – HTTP client for Python service
- `zod` – schema validation
- `firebase-admin` – Firebase authentication
- `@prisma/client` & `prisma` – ORM for MySQL
- `cors`, `helmet`, `dotenv` – middleware/config
- TypeScript toolchain (`typescript`, `ts-node-dev`, type definitions)

## Struktur proyek

- `src/` – main source code
  - `config/` – configuration (env, firebase, database, axios)
  - `routes/` – Express route definitions
  - `controllers/` – request handlers
  - `services/` – business logic & external API bridges
  - `validators/` – Zod schemas for request validation
  - `middlewares/` – auth, validation, error handling
  - `utils/` – helper functions (responses, errors, async handler)
  - `index.ts` – application entry point
- `prisma/schema.prisma` – database schema for Prisma
- `.env.example` – sample environment variables
- `docker-compose.yml` – MySQL container