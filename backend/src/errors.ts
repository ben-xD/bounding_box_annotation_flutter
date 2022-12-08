import { Context } from "hono";

const logError = (e: any) => {
	if (!e) return;
	if (!(e instanceof Error)) {
		console.error("Error was not Error type.")
	}
	// Logging errors, as documented in https://developers.cloudflare.com/d1/platform/client-api/#errors
	console.error({
		message: e.message,
		cause: e.cause.message,
	});
}

const clientError = (ctx: Context, message: string, e?: any) => {
	logError(e);
	return ctx.text(message, 400)
}

const serverError = (ctx: Context, message: string, e?: any) => {
	logError(e);
	return ctx.text(message, 500)
}

export {clientError, serverError, logError}