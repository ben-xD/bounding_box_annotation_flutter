import path from "path";
import {fileURLToPath} from "url";
import {build} from "esbuild";
import watPlugin from 'esbuild-plugin-wat';

// This build file exists to configure esbuild to use a plugin (watPlugin) so that miniflare can run the output.
// We need watPlugin https://esbuild.github.io/plugins/#webassembly-plugin to
// bundle wasm files/avoid the error: `No loader is configured for ".wasm" files: wasm/backend_bg.wasm`
// The default `wrangler dev` with works, but this file is used to add support for Miniflare.
// I tried `wrangler publish --dry-run --outdir=dist`, but the output only works for cloudflare (dev/publish),
// not miniflare. It only contains `d1-beta-facade.entry.js`, not `index.js`. Miniflare can't run
// `d1-beta-facade.entry.js`: it gets TypeError: The "path" argument must be of type string. Received an instance of Array

// Adapted from https://github.com/cloudflare/miniflare-typescript-esbuild-jest/blob/master/build.js
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

try {
    await build({
        bundle: true,
        sourcemap: true,
        format: "esm",
        target: "esnext",
        external: ["__STATIC_CONTENT_MANIFEST"],
        conditions: ["worker", "browser"],
        entryPoints: [path.join(__dirname, "src", "index.ts")],
        outdir: path.join(__dirname, "dist"),
        outExtension: {".js": ".mjs"},
        plugins: [watPlugin()],
    });
} catch {
    process.exitCode = 1;
}