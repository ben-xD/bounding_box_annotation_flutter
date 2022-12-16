#!/bin/bash

set -euxo pipefail

pushd rust
wasm-pack build --target=web --out-dir=../wasm
popd
# For esbuild, we can use either command line, or the node API. However,
# "To use plugins: Unlike the rest of the API, it's not available from the command line.
# You must write either JavaScript or Go code to use the plugin API."
# Can't use: esbuild --bundle --format=esm --sourcemap --outdir=dist ./src/index.ts
node build.js

echo "Finished custom build steps"
# The next steps are done by cloudflare?
# See https://developers.cloudflare.com/workers/wrangler/bundling/

