process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

environment.config.output.path = environment.config.output.path.replace(/packs-dev/, 'packs')
environment.config.output.publicPath = environment.config.output.publicPath.replace(/packs-dev/, 'packs')

module.exports = environment.toWebpackConfig()
