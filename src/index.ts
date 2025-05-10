import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import pino from "pino";

const logger = pino();

const handler = (event: APIGatewayProxyEvent): APIGatewayProxyResult => {
  logger.info(event);
  return {
    statusCode: 200,
    body: "Hello World",
  };
};

module.exports = { handler };
