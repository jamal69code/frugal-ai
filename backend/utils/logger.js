/**
 * Logger utility
 */

const log = (level, message, data = null) => {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] [${level.toUpperCase()}] ${message}`;
  
  if (data) {
    console.log(logMessage, data);
  } else {
    console.log(logMessage);
  }
};

const logger = {
  info: (msg, data) => log('info', msg, data),
  error: (msg, data) => log('error', msg, data),
  warn: (msg, data) => log('warn', msg, data),
  debug: (msg, data) => {
    if (process.env.NODE_ENV === 'development') {
      log('debug', msg, data);
    }
  }
};

module.exports = logger;
