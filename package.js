Package.describe({
  summary: "Portlets and portlet configurations for Luma Meteor apps"
});

Package.on_use(function (api, where) {
  api.use([
    'coffeescript',
    'underscore',
    'luma-router',
    'luma-auth',
    'luma-ui'
  ],[ 'client', 'server' ]);

  // for helpers
  api.use([
    'jquery',
    'ui',
    'templating',
    'spacebars'
  ], [ 'client' ]);

  api.export([], ['client','server']);

  api.add_files([
    'lib/luma-portlets.coffee'
  ], [ 'client', 'server' ]);

  api.add_files([
    'lib/components/portlet/portlet.html',
    'lib/components/portlet/portlet.coffee',
    'lib/views/portlet_placeholder/portlet_placeholder.html',
    'lib/views/portlet_placeholder/portlet_placeholder.coffee',
    'lib/views/portlet_options/portlet_options.html',
    'lib/views/portlet_options/portlet_options.coffee',
    'lib/views/portlet_config/portlet_config.html',
    'lib/views/portlet_config/portlet_config.coffee'
  ], [ 'client' ]);
});

Package.on_test(function (api) {
  api.use([
    'coffeescript',
    'luma-portlets',
    'tinytest',
    'test-helpers'
  ], ['client', 'server']);

  api.add_files([
    'tests/luma-portlets.test.coffee'
  ], ['client', 'server']);
});