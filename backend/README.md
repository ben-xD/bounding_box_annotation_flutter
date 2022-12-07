# Backend for Banananator


## Useful commands:

### For backend
- Run backend locally: `npx wrangler dev src/index.ts`
- Deploy backend application: `npx wrangler publish src/index.ts --name banananator`
- Reset database to `schema.sql`:
    - Reset preview database: `npx wrangler d1 execute banananator_preview --file schemas/schema.sql`
    - Reset production database: `npx wrangler d1 execute banananator --file schemas/schema.sql`

### For client
- Deploy web application: 
    - `cd ../client/`
    - `flutter build web`
    - `cd -`
    - `npx wrangler pages publish ../client/build/web`
    - See https://developers.cloudflare.com/pages/platform/direct-upload/#wrangler-cli


## Overview

### Backend
- Uses Cloudflare Workers, D1 and R2
    - Useful docs:
        - [D1](https://developers.cloudflare.com/d1/get-started/)
- Web app is hosted by Cloudflare Pages

- For setting up R2, I needed to configure the CORS origin header on the bucket using the S3 API: `PutBucketCors`.