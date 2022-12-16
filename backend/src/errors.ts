import {Context} from "hono";
import {Environment} from "hono/dist/types";

const logError = (e: any) => {
    if (!e) {
        console.log("No error, so skipping logging error.")
        return;
    }
    console.log("Logging error:")
    if (!(e instanceof Error)) {
        console.log("Error was not Error type.")
    }
    // Logging errors, as documented in https://developers.cloudflare.com/d1/platform/client-api/#errors
    if (e.name == "D1_ERROR") {
        console.log({
            message: e.message,
            cause: e.cause.message,
        });
    } else {
        console.log(JSON.stringify(e))
    }
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