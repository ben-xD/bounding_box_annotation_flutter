import { v4 as uuidv4 } from 'uuid';

/**
 * - Run `wrangler dev src/index.ts` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `wrangler publish src/index.ts --name my-worker` to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export interface Env {
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

const app = new Hono()

app.use('/api/*', cors());
app.get('/api/annotations/jobs', async ctx => {
  const { results } = await ctx.env.DB.prepare(`select * from AnnotationJobs`).all()
  console.log({results})
  return ctx.json(results)
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
	annotatedOn: string
	annotationJobID: string
	boundingBoxes: BoundingBox[]
}

app.post('/api/annotations', async ctx => {
	const { annotatedOn, annotationJobID, boundingBoxes } = await ctx.req.json<PostAnnotation>();

	if (!annotatedOn) return ctx.text("Missing annotation timestamp (annotatedOn). Can't create annotation.")
	if (!annotationJobID) return ctx.text("Missing annotation job ID (annotationJobID). Can't create annotation.")
	if (!boundingBoxes) return ctx.text("Missing bounding boxes (boundingBoxes). Can't create annotation.")

	const annotationID = uuidv4().toString();
	const ServerReceivedOn = new Date().toLocaleString();
	console.log({annotatedOn, annotationJobID, boundingBoxes});
	console.log(JSON.stringify(boundingBoxes));

	// TODO sanitize all inputs?
	try {
		const { success } = await ctx.env.DB.prepare(`
		insert into Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) values (?, ?, ?, ?, ?)
	`).bind(annotationID, annotatedOn, ServerReceivedOn, annotationJobID, JSON.stringify(boundingBoxes)).run()
	if (success) {
		ctx.status(201)
		return ctx.text("Created")
	} else {
		ctx.status(500)
		return ctx.text("Something went wrong")
	}
	} catch (e) {
		// TODO Log the error message. D1_ERROR?
		console.error({e})
		ctx.status(500)
		return ctx.text("Something went wrong")
	}


})

export default app;
