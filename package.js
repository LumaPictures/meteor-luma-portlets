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
    'spacebars',
    'reactive-dict'
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
    'lib/views/select_portlet/select_portlet.html',
    'lib/views/select_portlet/select_portlet.coffee',
    'lib/views/save_portlet_preset/save_portlet_preset.html',
    'lib/views/save_portlet_preset/save_portlet_preset.coffee',
    'lib/views/load_portlet_preset/load_portlet_preset.html',
    'lib/views/load_portlet_preset/load_portlet_preset.coffee'
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