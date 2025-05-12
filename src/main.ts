import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import pino from "pino";

const logger = pino();

export const handler = (_event: APIGatewayProxyEvent): APIGatewayProxyResult => {
  logger.info("Incoming request received");
  return {
    statusCode: 200,
    body: "Hello World",
  };
};
