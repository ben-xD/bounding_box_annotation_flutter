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
        const {ImageLargeUri: imageLargeUri, ImageThumbnailUri: imageThumbnailUri, CreatedOn, id} = entry;
        const modified: AnnotationJob = {
            images: {
                thumbnail: new URL(imageThumbnailUri),
                large: new URL(imageLargeUri),
            },
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
    const {annotatedOn, annotationJobID, boundingBoxes} = await ctx.req.json<CreateAnnotationRequest>();

    if (!annotatedOn) return clientError(ctx, "Missing annotation timestamp (annotatedOn). Can't create annotation.")
    if (!annotationJobID) return clientError(ctx, "Missing annotation job ID (annotationJobID). Can't create annotation.")
    const boundingBoxesArray = JSON.parse(boundingBoxes);
    if (!(boundingBoxesArray instanceof Array)) return ctx.text("Missing bounding boxes (boundingBoxes). Can't create annotation.", 400)

    const annotationID = uuidv4().toString();
    const ServerReceivedOn = new Date().toLocaleString();
    // TODO sanitize all inputs?
    try {
        const {success} = await ctx.env.DB.prepare(`
		insert into Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) values (?, ?, ?, ?, ?)
	`).bind(annotationID, annotatedOn, ServerReceivedOn, annotationJobID, JSON.stringify(boundingBoxes)).run()
        if (success) {
            return ctx.text("Created", 201)
        } else {
            return clientError(ctx, "Failed to get annotations");
        }
    } catch (e) {
        return serverError(ctx, "Failed to get annotations");
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

// TODO use queues so we can return a response sooner
// TODO stream process into wasm and back.
// If i do stream processing instead of using buffers, as soon as the first byte reaches R2,
function getImageCount(resultsBuffer: Uint8Array): number {
    const length = resultsBuffer.length;
    const imageCountArrayU8 = resultsBuffer.slice(length - 8, length);
    const imageCountU64 = new BigUint64Array(imageCountArrayU8.buffer);
    if (imageCountU64.length != 1) {
        throw Error(`imageCountU64 was not 1-number long. It was ${imageCountU64.length}`);
    }
    const count = Number(imageCountU64[0]);
    console.info(`Image count: ${imageCountU64}`);
    return count;
}

function getOffsetBuffer(resultsBuffer: Uint8Array, imageCount: number): BigUint64Array {
    const length = resultsBuffer.length;
    const offsetArray = resultsBuffer.slice(length - (imageCount * 8) - 8, length - 8);
    if (offsetArray.length != 16) {
        throw Error(`offsetArray was not 16-bytes long. It was ${offsetArray.length}`);
    }
    const offsetBuffer = new BigUint64Array(offsetArray.buffer);
    console.log(`offsetArray length: ${offsetArray.length}`)
    console.log(`offsetBuffer length: ${offsetBuffer.length}`)
    return offsetBuffer;
}

// I don't pay for this worker execution.
app.put('/images/:image_name', async ctx => {
    console.log("HELLO")
    await init(wasm);
    const originalImageName = ctx.req.param('image_name');
    const extension = originalImageName.split(".").pop()?.toLowerCase();
    if (!extension || (extension != "png" && extension != "jpg" && extension != "jpeg")) {
        return clientError(ctx, "Unsupported image format. Only PNG or JPEGs are currently supported.")
    }
    console.info(`Received image: ${originalImageName}`)
    const id = uuidv4();
    const largeImageName = `${id}_large.jpeg`;
    const thumbnailImageName = `${id}_thumbnail.jpeg`;
    const imageBuffer = await ctx.req.arrayBuffer();

    // Resizing in separate steps consumes more memory. Wasm doesn't deallocate.
    // https://stackoverflow.com/a/51544868/7365866
    // const thumbnailImageArray = resize_image(new Uint8Array(imageBuffer), [ImageSize.Thumbnail]);
    // const largeImageArray = resize_image(new Uint8Array(imageBuffer), ImageSize.Large);

    // Approach 2: Doesn't work because we can't send `Struct{Vec<u8>}`
    // const resizedImages = resize_2(new Uint8Array(imageBuffer));

    // Approach 3: create all images in 1 wasm call
    console.log("Received buffer");
    const resultsBuffer = resize_image(new Uint8Array(imageBuffer))
    console.log("Resized image");
    const imageCount = getImageCount(resultsBuffer);
    const offsetBuffer = getOffsetBuffer(resultsBuffer, imageCount);
    const length = resultsBuffer.length;

    // Read the rust code to find the ordering. Large, then Thumbnail
    console.info(`Offset buffer: ${offsetBuffer[0]}, ${offsetBuffer[1]}`)
    let largeImageArray: Uint8Array = resultsBuffer.slice(Number(offsetBuffer[0]), Number(offsetBuffer[1]));
    let thumbnailImageArray: Uint8Array = resultsBuffer.slice(Number(offsetBuffer[1]), length - 8);

    if (!thumbnailImageArray || thumbnailImageArray.length == 0) {
        return serverError(ctx, `Resizing: Thumbnail image was undefined or empty: ${thumbnailImageArray}`)
    }
    if (!largeImageArray || largeImageArray.length == 0) {
        return serverError(ctx, `Resizing: Large image was undefined or empty: ${largeImageArray}`)
    }

    await ctx.env.R2.put(thumbnailImageName, thumbnailImageArray!.buffer, {httpMetadata: {cacheControl: "max-age=31536000"}}); // 365 days an arbitrary choice
    await ctx.env.R2.put(largeImageName, largeImageArray!.buffer, {httpMetadata: {cacheControl: "max-age=31536000"}}); // 365 days an arbitrary choice

    console.info("Image saved");

    const jobId = uuidv4().toString();
    const currentTime = new Date().toISOString();
    const stmt = ctx.env.DB.prepare(`insert into AnnotationJobs (id, CreatedOn, ImageLargeUri, ImageThumbnailUri) VALUES (?1, ?2, ?3, ?4)`)
        .bind(jobId, currentTime, `${ctx.env.CLOUDFLARE_IMAGE_BUCKET_URL}/${thumbnailImageName}`, `${ctx.env.CLOUDFLARE_IMAGE_BUCKET_URL}/${largeImageName}`);
    const info = await stmt.run()
    console.info(info);
    // This data is sent to the app (Flutter) and is saved into an image correctly, and can be opened on the laptop.
    return ctx.body(thumbnailImageArray, 201);
    // return ctx.body(null, 201);
})

async function deleteImages<P extends string, E extends { Bindings: Bindings }, S>(result: AnnotationJobDb, ctx: Context<P, E, S>) {
    const largeImage = result.ImageLargeUri;
    const thumbnailImage = result.ImageThumbnailUri;
    await ctx.env.R2.delete([largeImage, thumbnailImage]);
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
