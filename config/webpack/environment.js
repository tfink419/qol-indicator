const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.insert(
  "Environment",
  new webpack.DefinePlugin({
    'GOOGLE_KEY': JSON.stringify(process.env.GOOGLE_KEY)
  })
)

module.exports = environment
