import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import pino from "pino";

const logger = pino();

// eslint-disable-next-line @typescript-eslint/require-await
export const handler = async (_event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  logger.info("Incoming request received");
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello World",
    }),
  };
};
