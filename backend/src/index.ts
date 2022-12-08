import { v4 as uuidv4 } from 'uuid';

// See https://honojs.dev/docs/examples/ for more examples.

const publicBucketUri = new URL("https://pub-b49d48ececa047ddbb7604b6bcd00006.r2.dev");
const defaultCorsDomain = "banananator.pages.dev";
export interface Env {
	DB: D1Database;
	// Example binding to KV. Learn more at https://developers.cloudflare.com/workers/runtime-apis/kv/
	// MY_KV_NAMESPACE: KVNamespace;
	//
	// Example binding to Durable Object. Learn more at https://developers.cloudflare.com/workers/runtime-apis/durable-objects/
	// MY_DURABLE_OBJECT: DurableObjectNamespace;
	//
	// Example binding to R2. Learn more at https://developers.cloudflare.com/workers/runtime-apis/r2/
	// MY_BUCKET: R2Bucket;
}

import { Hono } from 'hono'
import { cors } from 'hono/cors';
import { AnnotationDb, AnnotationJobDb } from './database_model';
import { clientError, serverError } from './errors';

const app = new Hono<{ Bindings: Env }>()

const createCorsOrigin = (origin: string): string => {
	// Need to accept 'http://localhost:58159' with abtrary ports.
	const regex = /http:\/\/localhost:\d+/;
	const isLocalhost = origin.match(regex)
	if (isLocalhost) return origin;
	if (origin.endsWith(`.${defaultCorsDomain}`)) return origin;
	return `https://${defaultCorsDomain}`;
}
app.use('/api/*', cors({
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

export default app;
