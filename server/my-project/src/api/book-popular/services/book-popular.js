'use strict';

/**
 * book-popular service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::book-popular.book-popular');
