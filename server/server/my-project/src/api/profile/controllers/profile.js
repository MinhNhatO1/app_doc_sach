// @ts-nocheck
'use strict';

/**
 * profile controller
 */
const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::profile.profile', ({ strapi }) => ({
  async createMe(ctx) {
    try {
      const user = ctx.state.user;
      if (!user) {
        return ctx.forbidden('No authorized user found');
      }

      const result = await strapi.entityService.create('api::profile.profile', {
        data: {
          fullName: ctx.request.body.fullName,
          email: user.email,
          user: user.id
        },
      });
      return result;
    } catch (err) {
      ctx.internalServerError('Error creating profile');
    }
  },

  async getMe(ctx) {
    try {
      const user = ctx.state.user;
      if (!user) {
        return ctx.forbidden('No authorized user found');
      }

      const result = await strapi.db.query('api::profile.profile').findOne({
        where: {
          user: {
            id: user.id,
          },
        },
        populate: {
          image: true,
        },
      });

      if (!result) {
        return ctx.notFound('Profile not found');
      }

      return result;
    } catch (err) {
      ctx.internalServerError('Error retrieving profile');
    }
  },

  async findIdByEmail(ctx) {
    const { email } = ctx.query; // Lấy giá trị của tham số email từ query string
    try {
      const profile = await strapi.db.query('api::profile.profile').findOne({ email });
  
      if (!profile) {
        return ctx.notFound('Profile not found');
      }
  
      return { id: profile.id };
    } catch (error) {
      console.error("Error finding profile by email:", error);
      return ctx.badRequest('Failed to fetch profile ID by email');
    }
  },

  // New method to find user
  async findUser(ctx) {
    try {
      const profiles = await strapi.db.query('api::profile.profile').findMany({
        populate: {
          user: true,
        },
        populate: {
          image: true, // Đảm bảo rằng image là tên của mối quan hệ trong mô hình profile
        },
      });

      return profiles;
    } catch (err) {
      console.error('Error retrieving profiles:', err);
      ctx.throw(500, 'Error retrieving profiles');
    }
  }
}));