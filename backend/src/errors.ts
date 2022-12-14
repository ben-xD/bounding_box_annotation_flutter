import {Context} from "hono";
import {Environment} from "hono/dist/types";

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

const clientError = <P extends string, E extends Partial<Environment>, S>(ctx: Context<P, E, S>, message: string, e?: any) => {
    logError(e);
    return ctx.text(message, 400)
}

const serverError = <P extends string, E extends Partial<Environment>, S>(ctx: Context<P, E, S>, message: string, e?: any) => {
    logError(e);
    return ctx.text(message, 500)
}

export {clientError, serverError, logError}