/**
 * Error Handler Middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Firebase errors
  if (err.code?.startsWith('auth/')) {
    const statusCode = 401;
    const message = err.message || 'Authentication error';
    return res.status(statusCode).json({ error: message });
  }

  // Validation errors
  if (err.status === 400) {
    return res.status(400).json({ error: err.message });
  }

  // Not found errors
  if (err.status === 404) {
    return res.status(404).json({ error: err.message });
  }

  // Default error
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

module.exports = errorHandler;
