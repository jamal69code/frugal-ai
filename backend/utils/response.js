/**
 * API Response utilities
 */

const successResponse = (data, message = 'Success') => ({
  success: true,
  message,
  data
});

const errorResponse = (error, statusCode = 500) => ({
  success: false,
  statusCode,
  message: error instanceof Error ? error.message : error
});

const paginatedResponse = (items, page, limit, total) => ({
  success: true,
  data: items,
  pagination: {
    page: parseInt(page) || 1,
    limit: parseInt(limit) || 10,
    total,
    pages: Math.ceil(total / (parseInt(limit) || 10))
  }
});

module.exports = {
  successResponse,
  errorResponse,
  paginatedResponse
};
