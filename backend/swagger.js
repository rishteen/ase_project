import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Express API with Swagger',
      version: '1.0.0',
      description: 'This is a web quality server',
    },
  },
  apis: ['./routes/*.js'], // Path to the API routes folder
};

const specs = swaggerJsdoc(options);

export default (app) => {
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(specs));
};
