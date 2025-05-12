import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import pino from "pino";

const logger = pino();

const handler = (_event: APIGatewayProxyEvent): APIGatewayProxyResult => {
  logger.info('Incoming request received');
  return {
    statusCode: 200,
    body: "Hello World",
  };
};

module.exports = { handler };
