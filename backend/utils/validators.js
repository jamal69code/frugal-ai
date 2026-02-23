/**
 * Validation utility
 */

const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const isValidPhoneNumber = (phone) => {
  const phoneRegex = /^\d{10,}$/;
  return phoneRegex.test(phone.replace(/\D/g, ''));
};

const isValidAmount = (amount) => {
  return !isNaN(amount) && amount > 0;
};

const isValidDate = (date) => {
  return !isNaN(new Date(date).getTime());
};

const validateRequired = (object, fields) => {
  const errors = [];
  fields.forEach(field => {
    if (!object[field]) {
      errors.push(`${field} is required`);
    }
  });
  return errors;
};

module.exports = {
  isValidEmail,
  isValidPhoneNumber,
  isValidAmount,
  isValidDate,
  validateRequired
};
