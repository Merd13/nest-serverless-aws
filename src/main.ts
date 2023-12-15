import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as serverless from 'serverless-http';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.init();
  return app;
}

let cachedServer;
export const handler = async (event, context) => {
  if (!cachedServer) {
    const app = await bootstrap();
    cachedServer = serverless(app.getHttpAdapter().getInstance());
  }
  return cachedServer(event, context);
};
