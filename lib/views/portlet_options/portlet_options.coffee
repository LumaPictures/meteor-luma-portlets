Template.portlet_options.events
  "click #load-configuration": ( event, template ) -> Luma.Portlets.load_configuration template.data.region

  "change #load-preset": ( event, template ) ->
    Luma.Portlets.set template.data.region, "selected_preset", event.val

  "change #select-user": ( event, template ) ->
    Luma.Portlets.set template.data.region, "selected_user", event.val
    Luma.Portlets.set template.data.region, "selected_preset", false

  "click #save-configuration": ( event, template ) ->
    event.preventDefault()
    Luma.Portlets.save_configuration template.data.region

Template.portlet_options.rendered = -> Luma.Portlets.initialize_options @data.region

Template.portlet_options.helpers

  preset_save_validation: -> return Luma.Portlets.get @region, "save_validation"

  preset_load_validation: -> return Luma.Portlets.get @region, "load_validation"

  selected_preset: -> return Luma.Portlets.get @region, "selected_preset"

  selected_preset_config: ->
    userId = Luma.Portlets.get @region, "selected_user"
    preset = Luma.Portlets.get @region, "selected_preset"
    route = Luma.Router.current().route.name
    portlet = Luma.Portlets.get @region, "portlet"
    if preset and userId
      query = 'profile.id': userId
      query[ "profile.portlets.#{ route }.#{ @region }.portlet" ] = portlet
      options = {}
      user = Meteor.users.findOne query, options
      user_portlet = user.profile.portlets[ route ][ @region ]
      if preset is "CURRENT_CONFIG"
        config = user_portlet.config
      else
        config = user_portlet.presets[ preset ].config
      return JSON.parse config
    else return false

  current_user_has_presets: ->
    user = Meteor.user()
    portlet = user.profile.portlets[ Luma.Router.current().route.name ][ @region ]
    has_presets = false
    if portlet.presets
      unless _.isEmpty portlet.presets
        has_presets = true
    return has_presets

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
      selected: []
      cursor: cursor
    }

  select_preset: ->
    user = Meteor.user()
    route_name = Luma.Router.current().route.name
    portlet = user.profile.portlets[ route_name ][ @region ]
    presets = if portlet.presets then _.values portlet.presets else []
    return {
      id: "select-preset"
      options:
        width: '100%'
        placeholder: "Select Preset Configuration..."
      selected: []
      cursor: presets
    }

  load_preset: ->
    userId = Luma.Portlets.get @region, "selected_user"
    route = Luma.Router.current().route.name
    portlet = Luma.Portlets.get @region, "portlet"
    query = 'profile.id': userId
    query[ "profile.portlets.#{ route }.#{ @region }.portlet" ] = portlet
    options = {}
    user = Meteor.users.findOne query, options
    presets = _.values user.profile.portlets[ route ][ @region ].presets
    return {
      id: "load-preset"
      options:
        width: '100%'
        placeholder: "Load Preset Configuration..."
      selected: []
      cursor: presets
    }
     