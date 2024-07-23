'use strict';

/**
 * reading-history service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::reading-history.reading-history');
