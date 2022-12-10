import { v4 as uuidv4 } from 'uuid';

// See https://honojs.dev/docs/examples/ for more examples.

const publicBucketUri = new URL("https://pub-b49d48ececa047ddbb7604b6bcd00006.r2.dev");
const defaultCorsDomain = "banananator.pages.dev";
const secondaryCorsDomain = "banananator-fragile.pages.dev";
export interface Env {
	DB: D1Database;
	// docs: https://developers.cloudflare.com/r2/data-access/workers-api/workers-api-reference/
	R2: R2Bucket;
	// Example binding to KV. Learn more at https://developers.cloudflare.com/workers/runtime-apis/kv/
	// MY_KV_NAMESPACE: KVNamespace;
	//
	// Example binding to Durable Object. Learn more at https://developers.cloudflare.com/workers/runtime-apis/durable-objects/
	// MY_DURABLE_OBJECT: DurableObjectNamespace;
}

import { Hono } from 'hono'
import { cors } from 'hono/cors';
import { AnnotationDb, AnnotationJobDb } from './database_model';
import { clientError, serverError } from './errors';

const app = new Hono<{ Bindings: Env }>()

const createCorsOrigin = (origin: string): string => {
	console.info(`Origin visited: ${origin}`)
	// Need to accept 'http://localhost:58159' with abtrary ports.
	const regex = /http:\/\/localhost:\d+/;
	const isLocalhost = origin.match(regex)
	if (isLocalhost) return origin;
	// Handle subdomains
	if (origin.endsWith(`.${defaultCorsDomain}`)) return origin;
	if (origin.endsWith(`.${secondaryCorsDomain}`)) return origin;
	// Handle exact paths:
	const defaultCorsDomainHttps = `https://${defaultCorsDomain}`
	const secondaryCorsDomainHttps = `https://${secondaryCorsDomain}`
	if (origin == defaultCorsDomainHttps) return defaultCorsDomainHttps;
	if (origin == secondaryCorsDomainHttps) return secondaryCorsDomainHttps;
	return defaultCorsDomainHttps;
}
app.use('/api/*', cors({
	origin: createCorsOrigin
}));
app.use('/images/*', cors({
	origin: createCorsOrigin
}));
// CORS Preflight request
app.options('*', async (ctx) => ctx.body(null, 200))

app.get('/api/annotations/jobs', async (ctx) => {
	const result = await ctx.env.DB.prepare(`select * from AnnotationJobs`).all<AnnotationJobDb>()
	const entries = result.results;

	const response = [];
	if (!entries) {
		return ctx.text("No annotation jobs found.");
	}
	for (const entry of entries) {
		const { ImageFileName, CreatedOn, id } = entry;
		const modified = {
			ImageURL: new URL(ImageFileName, publicBucketUri),
			id, CreatedOn,
		};
		response.push(modified);
	}

	return ctx.json(response)
})

type BoundingBox = {
	topLeft: {
		dx: number,
		dy: number,
	}
	size: {
		width: number,
		height: number,
	},
}

type PostAnnotation = {
	AnnotatedOn: string
	AnnotationJobID: string
	BoundingBoxes: string
}

app.get('/api/annotations', async ctx => {
	const result = await ctx.env.DB.prepare(`select * from Annotations`).all<AnnotationDb>()
	const entries = result.results;
	return ctx.json(entries, 200);
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
	const { AnnotatedOn, AnnotationJobID, BoundingBoxes } = await ctx.req.json<PostAnnotation>();

	if (!AnnotatedOn) return clientError(ctx, "Missing annotation timestamp (annotatedOn). Can't create annotation.")
	if (!AnnotationJobID) return clientError(ctx, "Missing annotation job ID (annotationJobID). Can't create annotation.")
	const boundingBoxes = JSON.parse(BoundingBoxes);
	if (!(boundingBoxes instanceof Array)) return ctx.text("Missing bounding boxes (boundingBoxes). Can't create annotation.", 400)

	const annotationID = uuidv4().toString();
	const ServerReceivedOn = new Date().toLocaleString();
	// TODO sanitize all inputs?
	try {
		const { success } = await ctx.env.DB.prepare(`
		insert into Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) values (?, ?, ?, ?, ?)
	`).bind(annotationID, AnnotatedOn, ServerReceivedOn, AnnotationJobID, JSON.stringify(boundingBoxes)).run()
		if (success) {
			return ctx.text("Created", 201)
		} else {
			return clientError(ctx, "Failed to get annotations");
		}
	} catch (e) {
		return serverError(ctx, "Failed to get annotations");
	}
})

app.put('/images/:image_name', async ctx => {
	const imageName = ctx.req.param('image_name');
	await ctx.env.R2.put(imageName, ctx.req.body, {httpMetadata: {cacheControl: "max-age=31536000"}}); // 365 days an arbitrary choice

	const jobId = uuidv4().toString();
	const currentTime = new Date().toISOString();
	const stmt = ctx.env.DB.prepare(`insert into AnnotationJobs (id, CreatedOn, ImageFileName) VALUES (?1, ?2, ?3)`).bind(jobId, currentTime, imageName)
	const info = await stmt.run()
	console.info(info);
	return ctx.body(null, 201);
})

app.delete('/api/annotations/jobs/:job_id', async ctx => {
	const jobId = ctx.req.param("job_id");
	
	// Get image ID and delete the image from R2
	const result = await ctx.env.DB.prepare("select * from AnnotationJobs WHERE id = $1").bind(jobId).first<AnnotationJobDb>();
	const fileName = result.ImageFileName;
	await ctx.env.R2.delete(fileName);

	// Delete the database entry
	const stmt = ctx.env.DB.prepare("delete FROM AnnotationJobs WHERE id = ?1").bind(jobId)
	const info = await stmt.run()
	console.info(info)
	return ctx.body(null, 200);
})

export default app;
