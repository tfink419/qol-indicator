const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.insert(
  "Environment",
  new webpack.DefinePlugin({
    'GOOGLE_WEB_KEY': process.env.NODE_ENV == 'production' ? 
      JSON.stringify(process.env.GOOGLE_PROD_WEB_KEY)
      : JSON.stringify(process.env.GOOGLE_WEB_KEY)
  })
)

module.exports = environment
