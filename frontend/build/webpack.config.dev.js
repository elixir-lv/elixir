'use strict';

const {VueLoaderPlugin} = require('vue-loader');
module.exports = {mode: 'development', entry: ['./src/app.js'], 
	output: {path: __dirname + '/../public/ui/js/dist', publicPath: '/ui/js/dist/', filename: 'main.js', chunkFilename: '[name]-chunk.js'},
	module: {rules: [{test: /\.vue$/, use: 'vue-loader'}]}, plugins: [new VueLoaderPlugin()]};
