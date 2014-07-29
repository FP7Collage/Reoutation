var winston = require('winston');

var now = new Date();
module.exports = new (winston.Logger)({
	transports: [
		new (winston.transports.Console)({
			level: 'debug',
			timestamp: true
		}),
		new(winston.transports.File)({
			level: 'silly',
			filename: 'logs/' + now.getUTCFullYear() + '-' + now.getUTCMonth() + '-' + now.getUTCDay() + '.log',
			timestamp: true,
			json: false
		})
	]
});
