# Backend for Banananator

## Notes
- An app that needs internet connection was published to `banananator-fragile.pages.dev`
    - Published to a separate page/project by running `npx wrangler pages publish ../client/build/web --project-name=banananator-fragile`

## Useful commands:

### Prerequisites
- Optional: [install wrangler globally](https://developers.cloudflare.com/workers/wrangler/install-and-update/#install-wrangler-globally) by running `npm install --global wrangler`

### For backend
- Install nodeJS 18 LTS. 
  - I've found that Node installed using NVM might cause errors with applying SQL commands to D1. See [BUG: Can't execute D1 SQL](https://github.com/cloudflare/wrangler2/issues/2220#issuecomment-1355587661). So install Node from the nodeJS website instead.
- Install non-project-specific tools: 
  - run `npm install --global wrangler` 
  - run `npm install --global pnpm miniflare`
- Install dependencies: `pnpm i`
- Run backend locally: `wrangler dev`
- Deploy backend application: `wrangler publish`
    - Read logs in realtime: `wrangler tail`
    - Warning: if you use the wrong imports (unoptimised), the worker can be quite large.
    - The maximum it can be is 5MB. Currently, it is `Total Upload: 1722.06 KiB / gzip: 570.04 KiB`.
- Reset database to `schema.sql`:
    - Reset preview database: `wrangler d1 execute banananator_preview --file schemas/schema.sql`
    - Reset production database: `wrangler d1 execute banananator --file schemas/schema.sql`

## Rust worker compilation
    - Set up `.env` file containing token for accessing worker. Create one in https://dash.cloudflare.com/profile/api-tokens
    - Build image and start container: `docker-compose up -d --build`
    - Enter container: `docker exec -it backend-development-1 bash`
    - Install wasm-pack: run `curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh`
        - Ensure it is the latest version from . Check your current version by running `wasm-pack -V`. Install using another method if necessary. I found reinstalling it with the same command fixed it.
    - Install worker-build, run `cargo install -q worker-build`
    - Install wasm-bindegen: `cargo install wasm-bindgen-cli`
    - Install rust using [rust-up](https://rustup.rs/): run `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
    - Launch the backend dev server: run `wrangler dev`

### For client
- Deploy web application: 
    - `cd ../client/`
    - `flutter build web`
    - `cd -`
    - `wrangler pages publish ../client/build/web --project-name=banananator`
    - To deploy fragile version, run: `wrangler pages publish ../client/build/web --project-name=banananator-fragile`
    - See https://developers.cloudflare.com/pages/platform/direct-upload/#wrangler-cli


## Overview

### Backend
- Uses Cloudflare Workers, D1 and R2
    - Useful docs:
        - [D1](https://developers.cloudflare.com/d1/get-started/)
- Web app is hosted by Cloudflare Pages

- For setting up R2, I needed to configure the CORS origin header on the bucket using the S3 API: `PutBucketCors`.