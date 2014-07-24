Template.portlet_options.events
  "click #load-configuration": ( event, template ) ->
    route = Luma.Router.current().route.name
    preset_name = Session.get "portlet_options:selected_preset"
    userId = Session.get "portlet_options:selected_user"
    portlet = Session.get "portlet:#{ @region }"
    query = 'profile.id': userId
    query[ "profile.portlets.#{ route }.#{ @region }.template" ] = portlet.template
    options = {}
    user = Meteor.users.findOne query, options
    preset = user.profile.portlets[ route ][ @region ].presets[ preset_name ]
    portlet.config = preset.config
    Session.set "portlet:#{ @region }", portlet
    Session.set "portlet_options:selected_preset", false
    validation =
      message: "Preset '#{ preset_name }' successfully loaded"
      status: "success"
    Session.set "portlet_options:load:validation", validation

  "change #load-preset": ( event, template ) ->
    Session.set "portlet_options:selected_preset", event.val

  "change #select-user": ( event, template ) ->
    Session.set "portlet_options:selected_user", event.val
    Session.set "portlet_options:selected_preset", false

  "click #save-configuration": ( event, template ) ->
    event.preventDefault()
    new_portlet_preset = $( "#preset-name" ).val()
    existing_portlet_preset = $( "#select-preset" ).val()
    validation = false
    if new_portlet_preset and existing_portlet_preset
      validation =
        message: "You must either create a new preset, or select an existing preset. Not Both."
        status: "danger"
    else
      value = new_portlet_preset if new_portlet_preset
      value = existing_portlet_preset if existing_portlet_preset
      value = value.toUpperCase()
      Session.set "portlet_options:save:validation", validation
      user = Meteor.user()
      portlet = user.profile.portlets[ Luma.Router.current().route.name ][ @region ]
      presets = portlet.presets
      config = Deps.nonreactive => Session.get( "portlet:#{ @region }" ).config
      if new_portlet_preset
        unless value.length
          validation =
            message: "All presets must have a name"
            status: "danger"
        if presets[ value ]
          validation =
            message: "All presets must have a unique name"
            status: "danger"
        else
          presets[ value ] =
            name: value
            config: config
      if existing_portlet_preset
        unless presets[ value ]
          validation =
            message: "Selected preset does not exist"
            status: "danger"
        if presets[ value ] is config
          validation =
            message: "Current configuration is identical to the preset"
            status: "danger"
      unless validation
        modifier = $set: {}
        modifier.$set[ "profile.portlets.#{ Luma.Router.current().route.name }.#{ @region }.presets" ] = presets
        result = Meteor.users.update _id: user._id, modifier
        if result
          validation =
            message: "Portlet Config '#{ value }' successfully saved"
            status: "success"
          if new_portlet_preset
            $( "#preset-name" ).val ""
        else
          validation =
            message: "An error occurred while saving"
            status: "danger"
    Session.set "portlet_options:save:validation", validation

Template.portlet_options.rendered = ->
  query =
    'profile.portlets.shot_elements.main.template':'shot_elements_portlet'
  options = {}
  Meteor.subscribe "user_profiles", query, options
  Session.set "portlet_options:selected_user", false
  Session.set "portlet_options:save:validation", false
  Session.set "portlet_options:load:validation", false
  Session.set "portlet_options:load:validation", false
  Session.set "portlet_options:selected_preset", false

Template.portlet_options.helpers

  preset_save_validation: -> return Session.get "portlet_options:save:validation"

  preset_load_validation: -> return Session.get "portlet_options:load:validation"

  selected_preset: -> return Session.get "portlet_options:selected_preset"

  selected_preset_config: ->
    userId = Session.get "portlet_options:selected_user"
    preset = Session.get "portlet_options:selected_preset"
    route = Luma.Router.current().route.name
    template = Session.get( "portlet:#{ @region }" ).template
    if preset and userId
      query = 'profile.id': userId
      query[ "profile.portlets.#{ route }.#{ @region }.template" ] = template
      options = {}
      user = Meteor.users.findOne query, options
      portlet = user.profile.portlets[ route ][ @region ]
      if preset is "CURRENT_CONFIG"
        config = portlet.config
      else
        config = portlet.presets[ preset ].config
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

  selected_user: -> return Session.get "portlet_options:selected_user"

  select_user: ->
    userId = Session.get "portlet_options:selected_user"
    route = Luma.Router.current().route.name
    template = Session.get( "portlet:#{ @region }" ).template
    query = {}
    query[ "profile.portlets.#{ route }.#{ @region }.template" ] = template
    options = {}
    cursor = Meteor.users.find query, options
    return {
      id: "select-user"
      options:
        width: '100%'
        placeholder: "Select User..."
      selected: [ userId ]
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
    userId = Session.get "portlet_options:selected_user"
    route = Luma.Router.current().route.name
    template = Session.get( "portlet:#{ @region }" ).template
    query = 'profile.id': userId
    query[ "profile.portlets.#{ route }.#{ @region }.template" ] = template
    options = {}
    user = Meteor.users.findOne query, options
    presets = _.values user.profile.portlets[ Luma.Router.current().route.name ][ @region ].presets
    return {
      id: "load-preset"
      options:
        width: '100%'
        placeholder: "Load Preset Configuration..."
      selected: []
      cursor: presets
    }

  selected_portlet: ->
    selected_portlet_region = Session.get "portlet_options:selected_region"
    if selected_portlet_region
      return Session.get "portlet:#{ selected_portlet_region }"
    else return false
     