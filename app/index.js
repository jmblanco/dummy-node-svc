const fastify = require('fastify')();
const log = require('pino')();

const config = {
    port: 3000,
    host: '0.0.0.0'
};

fastify.get('/', async (request, reply) => {
    log.info('Received request!');
    return { hello: 'world' }
})

const start = async () => {
    try {
        log.info('Starting server on with config %o', config);
        await fastify.listen(config);
    } catch (err) {
        log.error(err);
        process.exit(1)
    }
}
start()