import {v4 as uuidv4} from 'uuid';
import {Context, Hono} from 'hono'
import {cors} from 'hono/cors';
import {AnnotationDb, AnnotationJobDb} from './database_models';
import {clientError, serverError} from './errors';
// Loads the webassembly module https://rustwasm.github.io/docs/book/game-of-life/hello-world.html#wasm-game-of-lifepkgwasm_game_of_life_bgwasm
import wasm from "../wasm/backend_bg.wasm";
// Loads the wrapper, which is nicer to use. e.g. https://rustwasm.github.io/docs/book/game-of-life/hello-world.html#wasm-game-of-lifepkgwasm_game_of_lifejs
import init, {endianness, resize_image} from "../wasm/backend";
import {Annotation, AnnotationJob, CreateAnnotationRequest} from "./client_models";

// See https://honojs.dev/docs/examples/ for more examples.
export interface Bindings {
    DB: D1Database;
    // docs: https://developers.cloudflare.com/r2/data-access/workers-api/workers-api-reference/
    R2: R2Bucket;
    // Example binding to KV. Learn more at https://developers.cloudflare.com/workers/runtime-apis/kv/
    // MY_KV_NAMESPACE: KVNamespace;
    //
    // Example binding to Durable Object. Learn more at https://developers.cloudflare.com/workers/runtime-apis/durable-objects/
    // MY_DURABLE_OBJECT: DurableObjectNamespace;

    // Following https://honojs.dev/docs/getting-started/cloudflare-workers/#bindings
    CLOUDFLARE_IMAGE_BUCKET_URL: string;
    CLOUDFLARE_PAGES_URL: string;
}

// TODO move bindings into context.
type Env = {
    Bindings: Bindings,
    // This doesn't work:
    // Variables: {
    //     CLOUDFLARE_IMAGE_BUCKET_URL: string;
    //     CLOUDFLARE_PAGES_URL: string;
    // }
}

const app = new Hono<Env>()

const createCorsOrigin = (origin: string, corsDomain: string): string => {
    console.info(`Origin visited: ${origin}`)
    // Need to accept 'http://localhost:58159' with abtrary ports.
    const regex = /http:\/\/localhost:\d+/;
    const isLocalhost = origin.match(regex)
    if (isLocalhost) return origin;
    // Handle subdomains
    if (origin.endsWith(`.${corsDomain}`)) return origin;
    // Handle exact paths:
    const defaultCorsDomainHttps = `https://${corsDomain}`
    if (origin == defaultCorsDomainHttps) return defaultCorsDomainHttps;
    return defaultCorsDomainHttps;
}

// These custom middlewares exist to give environment variables to the
// createCorsOrigin function taken from context
app.use('/api/*', async (ctx, next) => cors({
    origin: (origin: string) => createCorsOrigin(origin, ctx.env.CLOUDFLARE_PAGES_URL)
})(ctx, next))
app.use('/images/*', async (ctx, next) => cors({
        origin: (origin: string) => createCorsOrigin(origin, ctx.env.CLOUDFLARE_PAGES_URL)
    })(ctx, next)
);
// CORS Preflight request
app.options('*', async (ctx) => ctx.body(null, 200))


app.get('/api/annotations/jobs', async (ctx) => {
    const result = await ctx.env.DB.prepare(`select * from AnnotationJobs`).all<AnnotationJobDb>()
    const entries = result.results;

    const response: AnnotationJob[] = [];
    if (!entries) {
        return ctx.text("No annotation jobs found.");
    }
    for (const entry of entries) {
        const {ImageUriOriginal: imageUriOriginal, ImageUriThumbnail: imageUriThumbnail, CreatedOn, id} = entry;
        const modified: AnnotationJob = {
            imageUriThumbnail,
            imageUriOriginal,
            id: id, createdOn: CreatedOn,
        };
        response.push(modified);
    }

    return ctx.json(response)
})

app.get('/api/annotations', async ctx => {
    const result = await ctx.env.DB.prepare(`select * from Annotations`).all<AnnotationDb>()
    const entries = result.results;
    if (!entries) {
        return serverError(ctx, "No annotation database was found.")
    }
    const results: Annotation[] = [];
    for (const entry of entries) {
        results.push({
            annotatedOn: entry.AnnotatedOn,
            boundingBoxes: entry.BoundingBoxes,
            annotationJobId: entry.AnnotationJobId
        })
    }

    return ctx.json(results, 200);
})

app.delete('/api/annotations', async ctx => {
    try {
        const result = await ctx.env.DB.prepare(`DELETE from Annotations`).run()
        if (result.success) {
            return ctx.body(null, 200)
        }
        return clientError(ctx, "Failed to delete annotations")
    } catch (e: any) {
        return serverError(ctx, `Failed to delete annotations`, e)
    }
})

app.post('/api/annotations', async ctx => {
    const {annotatedOn, annotationJobId, boundingBoxes} = await ctx.req.json<CreateAnnotationRequest>();

    if (!annotatedOn) return clientError(ctx, "Missing annotation timestamp (annotatedOn). Can't create annotation.")
    if (!annotationJobId) return clientError(ctx, "Missing annotation job ID (annotationJobId). Can't create annotation.")
    const boundingBoxesArray = JSON.parse(boundingBoxes);
    if (!(boundingBoxesArray instanceof Array)) return ctx.text("Missing bounding boxes (boundingBoxes). Can't create annotation.", 400)

    const annotationID = uuidv4().toString();
    const ServerReceivedOn = new Date().toLocaleString();
    // TODO sanitize all inputs?
    try {
        const result = await ctx.env.DB.prepare(`
		insert into Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobId, BoundingBoxes) values (?, ?, ?, ?, ?)
	`).bind(annotationID, annotatedOn, ServerReceivedOn, annotationJobId, boundingBoxes).run()
        console.info(JSON.stringify(result));
        const {success} = result;
        if (success) {
            return ctx.text("Created", 201)
        } else {
            return clientError(ctx, "Failed to add annotations");
        }
    } catch (e) {
        return serverError(ctx, "Failed to add annotations");
    }
})

let jsEndianness = () => {
    let uInt32 = new Uint32Array([0x11223344]);
    let uInt8 = new Uint8Array(uInt32.buffer);

    if (uInt8[0] === 0x44) {
        return 'Little Endian';
    } else if (uInt8[0] === 0x11) {
        return 'Big Endian';
    } else {
        return 'Maybe mixed-endian?';
    }
};

app.get('/', async ctx => {
    await init(wasm);
    console.log(ctx.env.CLOUDFLARE_IMAGE_BUCKET_URL)
    console.log(ctx.env.CLOUDFLARE_PAGES_URL)
    console.log(`Javascript endianness: ${jsEndianness()}`);
    console.log(`Rust endianness: ${endianness()}`);
    return ctx.body("Useful information has been logged to the server. " +
        "Run `wrangler tail` with credentials.", 200);
})

app.put('/images/:image_name', async ctx => {

    await init(wasm);
    const originalImageName = ctx.req.param('image_name');
    const extension = originalImageName.split(".").pop()?.toLowerCase();
    if (!extension || (extension != "png" && extension != "jpg" && extension != "jpeg")) {
        return clientError(ctx, "Unsupported image format. Only PNG or JPEGs are currently supported.")
    }
    const jobId = uuidv4().toString();
    console.info(`Received image: ${originalImageName}, known as ${jobId}`)
    const imageBuffer = await ctx.req.arrayBuffer();

    const MAX_IMAGE_SIZE = 1.5 * 1024 * 1024;
    if (imageBuffer.byteLength > MAX_IMAGE_SIZE) {
        return clientError(ctx, `Image was ${imageBuffer.byteLength} bytes, which is too big. The maximum image size is ${MAX_IMAGE_SIZE} bytes.`);
    }

    console.log("Received buffer");
    const thumbnailImageArray = resize_image(new Uint8Array(imageBuffer))
    console.log("Resized image");

    if (!thumbnailImageArray || thumbnailImageArray.length == 0) {
        return serverError(ctx, `Resizing: Thumbnail image was undefined or empty: ${thumbnailImageArray}`)
    }
    try {
        const originalSizeImageName = `${jobId}.jpeg`;
        const thumbnailImageName = `${jobId}_thumbnail.jpeg`;

        // Save images
        await ctx.env.R2.put(thumbnailImageName, thumbnailImageArray!.buffer, {httpMetadata: {cacheControl: "max-age=31536000"}}); // 365 days an arbitrary choice
        await ctx.env.R2.put(originalSizeImageName, imageBuffer, {httpMetadata: {cacheControl: "max-age=31536000"}}); // 365 days an arbitrary choice
        console.info("Images saved");

        // Save job details, including urls.
        const currentTime = new Date().toISOString();
        const thumbnailImageUrl = `${ctx.env.CLOUDFLARE_IMAGE_BUCKET_URL}/${thumbnailImageName}`
        const originalImageUrl = `${ctx.env.CLOUDFLARE_IMAGE_BUCKET_URL}/${originalSizeImageName}`
        const stmt = ctx.env.DB.prepare(`insert into AnnotationJobs (id, CreatedOn, ImageUriOriginal, ImageUriThumbnail) VALUES (?1, ?2, ?3, ?4)`)
            .bind(jobId, currentTime, originalImageUrl, thumbnailImageUrl);
        const info = await stmt.run()
        console.log(`Saving annotation job details at ${currentTime}.`)
        console.info(info);
        // This data is sent to the app (Flutter) and is saved into an image correctly, and can be opened on the laptop.
        return ctx.body(thumbnailImageArray, 201);
        // return ctx.body(null, 201);
    } catch (e) {
        return ctx.body(JSON.stringify(e), 400)
    }
})

async function deleteImages<P extends string, E extends { Bindings: Bindings }, S>(result: AnnotationJobDb, ctx: Context<P, E, S>) {
    const originalImage = result.ImageUriOriginal;
    const thumbnailImage = result.ImageUriThumbnail;
    await ctx.env.R2.delete([originalImage, thumbnailImage]);
}

app.delete('/api/annotations/jobs/:job_id', async ctx => {
    const jobId = ctx.req.param("job_id");

    // Get image ID and delete the image from R2
    const result = await ctx.env.DB.prepare("select * from AnnotationJobs WHERE id = $1").bind(jobId).first<AnnotationJobDb>();
    await deleteImages(result, ctx);

    // Delete the database entry
    const stmt = ctx.env.DB.prepare("delete FROM AnnotationJobs WHERE id = ?1").bind(jobId)
    const info = await stmt.run()
    if (info.success) {
        return ctx.body(null, 200);
    } else {
        console.error(`Error when trying to run SQL command to delete annotation jobs: ${info.error}`);
        return serverError(ctx, "Server error");
    }
})

app.delete('/api/annotations/jobs', async ctx => {
    // Get image ID and delete the image from R2
    const result = await ctx.env.DB.prepare("select * from AnnotationJobs").all<AnnotationJobDb>();
    const entries: AnnotationJobDb[] | undefined = result.results
    if (!entries) {
        return serverError(ctx, "Entries was undefined when getting annotation jobs from the database.")
    }
    await Promise.all(entries.map((e) => deleteImages(e, ctx)));

    // Delete the database entries
    const stmt = ctx.env.DB.prepare("delete FROM AnnotationJobs");
    const info = await stmt.run()

    console.info(info)
    return ctx.body(null, 200);
})

// WORKING
// import wasm from "./wasm/backend_bg.wasm";
// import init, {numwords} from "./wasm/backend"

// app.get('/', async ctx => {
// 	await init(wasm);
// 	const result = numwords(BigInt(5));
// 	return ctx.body(result, 200);
// })

// Older attempts
// app.get('/', async ctx => {
// 	// import {numwords} from "../rust/pkg/backend";
// 	// const result = numwords(BigInt(5))
// 	// return ctx.body(result, 200);

// 	const module = await import("../rust/pkg/backend")
// 	const result = module.numwords(BigInt(5));
// 	return ctx.body(result, 200);

// 	// await import("../rust/pkg/backend").then((m) => {
// 	// 	const result = m.numwords(BigInt(5));
// 	// 	return ctx.body(result, 200);
// 	// })
// })

export default app;
