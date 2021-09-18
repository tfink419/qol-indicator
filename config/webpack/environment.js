const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.insert(
  "Environment",
  new webpack.DefinePlugin({})
)

module.exports = environment