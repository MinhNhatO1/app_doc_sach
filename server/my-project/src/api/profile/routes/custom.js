module.exports = {
    routes: [
        {
            method: 'GET',
            path: '/profile/me',
            handler: 'profile.getMe',
            config: {}
        },
        {
            method: 'POST',
            path: '/profile/me',
            handler: 'profile.createMe',
            config: {}
        },
        {
            method: 'GET',
            path: '/profile/id-by-email',
            handler: 'profile.findIdByEmail',
            config: {}
        },

        {
            "method": "GET",
            "path": "/profiles",
            "handler": "profile.findUser",
            "config": {
              "policies": []
            }
          },
    ]
}