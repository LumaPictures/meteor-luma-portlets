Template.load_portlet_preset.helpers

  selected_user: -> return Luma.Portlets.get @region, "selected_user"

  select_user: ->
    route = Luma.Router.current().route.name
    portlet = Luma.Portlets.get @region, "portlet"
    query = {}
    query[ "profile.portlets.#{ route }.#{ @region }.portlet" ] = portlet
    options = {}
    cursor = Meteor.users.find query, options
    return {
      id: "select-user"
      options:
        width: '100%'
        placeholder: "Select User..."
        allowClear: true
      selected: []
      cursor: cursor
    }

  load_preset: ->
    userId = Luma.Portlets.get @region, "selected_user"
    presets = []
    if userId
      route = Luma.Router.current().route.name
      portlet = Luma.Portlets.get @region, "portlet"
      query = 'profile.id': userId
      query[ "profile.portlets.#{ route }.#{ @region }.portlet" ] = portlet
      options = {}
      user = Meteor.users.findOne query, options
      if user
        presets = _.values user.profile.portlets[ route ][ @region ].presets
    return {
      id: "load-preset"
      options:
        width: '100%'
        placeholder: "Load Preset Configuration..."
      selected: []
      cursor: presets
    }

  preset_load_validation: -> return Luma.Portlets.get @region, "load_validation"

  selected_preset: -> return Luma.Portlets.get @region, "selected_preset"

  selected_preset_config: ->
    userId = Luma.Portlets.get @region, "selected_user"
    preset = Luma.Portlets.get @region, "selected_preset"
    route = Luma.Router.current().route.name
    portlet = Luma.Portlets.set @region, "portlet"
    if preset and userId
      query = 'profile.id': userId
      query[ "profile.portlets.#{ route }.#{ @region }.portlet" ] = portlet
      options = {}
      user = Meteor.users.findOne query, options
      if user
        user_portlet = user.profile.portlets[ route ][ @region ]
        if preset is "CURRENT_CONFIG"
          config = user_portlet.config
        else if user_portlet.presets[ preset ]
          config = user_portlet.presets[ preset ].config
    return if config then JSON.parse config else false

Template.load_portlet_preset.events
  "click #load-configuration": ( event, template ) -> Luma.Portlets.load_configuration template.data.region

  "change #load-preset": ( event, template ) ->
    Luma.Portlets.set template.data.region, "selected_preset", event.val

  "change #select-user": ( event, template ) ->
    Luma.Portlets.set template.data.region, "selected_user", event.val
    Luma.Portlets.set template.data.region, "selected_preset", false