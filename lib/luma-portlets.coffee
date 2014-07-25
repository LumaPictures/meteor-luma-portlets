# luma-portlets
if Meteor.isClient
  Luma.Portlets =

    _computations: {}

    _dictionaries: {}

    _portlets: {
      portlet_placeholder:
        label: "None"
        template: "portlet_placeholder"
    }

    add_portlet: ( portlet ) -> @_portlets[ portlet.template ] = portlet

    _add_computation: ( region, computation ) -> @_computations[ region ] = computation

    _stop_computation: ( region ) ->
      if @_computations[ region ] and @_computations[ region ].stop
        @_computations[ region ].stop()
        delete @_computations[ region ]

    _add_dictionary: ( region ) -> @_dictionaries[ region ] = new ReactiveDict()

    _remove_dictionary: ( region ) -> delete @_dictionaries[ region ] if @_dictionaries[ region ]

    _copy_dictionary: ( region ) ->
      if @_dictionaries[ region ]
        dictionary = {}
        for key of @_dictionaries[ region ].keys
          dictionary[ key ] = @get region, key
        return dictionary

    persist_user_portlet: ( region, userId, route = null ) ->
      user = Deps.nonreactive -> Meteor.users.findOne _id: userId
      route ?= Luma.Router.current().route.name
      if user and user.profile.portlets
        selector = _id: user._id
        modifier = $set: {}
        portlet =
          region: region
          config: Luma.Portlets.get region, "config"
          portlet: Luma.Portlets.get region, "portlet"
          data: Luma.Portlets.get region, "data"
          presets: Luma.Portlets.get region, "presets"
        unless user.profile.portlets[ route ]
          modifier.$set[ "profile.portlets.#{ route }" ] = {}
          Meteor.users.update selector, modifier
        modifier.$set[ "profile.portlets.#{ route }.#{ region }" ] = portlet
        Meteor.users.update selector, modifier

    set: ( region, key, value, reactive = true ) ->
      if @_dictionaries[ region ] and @_dictionaries[ region ].set
        if reactive
          @_dictionaries[ region ].set key, value
        else Deps.nonreactive => @_dictionaries[ region ].set key, value
      else throw new Error "A ReactiveDict has not been created for region '#{ region }'"

    set_config: ( region, config = {}, reactive = true ) -> @set region, "config", JSON.stringify config, reactive

    get: ( region, key, reactive = true ) ->
      if @_dictionaries[ region ] and @_dictionaries[ region ].get
        if reactive
          @_dictionaries[ region ].get key
        else Deps.nonreactive => @_dictionaries[ region ].get key
      else throw new Error "A ReactiveDict has not been created for region '#{ region }'"

    get_config: ( region, reactive = true ) ->
      config = @get region, "config", reactive
      return JSON.parse config

    initialize: ( route, portlets ) ->
      if _.isArray portlets
        # set all the route portlets as session variables
        for portlet, key in portlets
          @initialize_portlet route, portlet

    initialize_portlet: ( route, portlet ) ->
      @_add_dictionary portlet.region
      user = Deps.nonreactive -> Meteor.user()
      if _.isObject user
        user_portlets = user.profile.portlets
        user_portlets[ route ] = {} unless user_portlets[ route ]
        unless user_portlets[ route ][ portlet.region ]
          user_portlets[ route ][ portlet.region ] = portlet
          selector = _id: user._id
          modifier = $set: {}
          unless user_portlets[ route ]
            modifier.$set[ "profile.portlets.#{ route }" ] = user_portlets[ route ]
          else modifier.$set[ "profile.portlets.#{ route }.#{ portlet.region }" ] = portlet
          Deps.nonreactive -> Meteor.users.update selector, modifier
        portlet = Deps.nonreactive -> Meteor.user().profile.portlets[ route ][ portlet.region ]
      for key, value of portlet
        Deps.nonreactive => @set portlet.region, key, value

    initialize_portlet_config: ( region, template ) ->
      if _.isFunction Luma.Portlets._portlets[ template ].config
        unless Luma.Portlets.get region, "config"
          Luma.Portlets._portlets[ template ].config region
      else Luma.Portlets.set_config region, {}


    destroy: ( region ) ->
      Luma.Portlets._stop_computation region
      Luma.Portlets._remove_dictionary region

    create: ( region, computation ) ->
      Luma.Portlets._add_computation region, computation

    load_configuration: ( region ) ->
      route = Luma.Router.current().route.name
      preset_name = Luma.Portlets.get region, "selected_preset"
      userId = Luma.Portlets.get region, "selected_user"
      template = Luma.Portlets.get region, "template"
      query = 'profile.id': userId
      query[ "profile.portlets.#{ route }.#{ region }.template" ] = template
      options = {}
      user = Meteor.users.findOne query, options
      preset = user.profile.portlets[ route ][ region ].presets[ preset_name ]
      for key, value of preset
        Luma.Portlets.set region, key, value
      validation =
        message: "Preset '#{ preset_name }' successfully loaded"
        status: "success"
      Luma.Portlets.set "options_validation", validation

    save_configuration: ( region ) ->
      new_portlet_preset = $( "#preset-name" ).val()
      existing_portlet_preset = $( "#select-preset" ).val()
      validation = false
      route_name = Luma.Router.current().route.name
      if new_portlet_preset and existing_portlet_preset
        validation =
          message: "You must either create a new preset, or select an existing preset. Not Both."
          status: "danger"
      else
        value = new_portlet_preset if new_portlet_preset
        value = existing_portlet_preset if existing_portlet_preset
        if value
          value = value.toUpperCase()
          user = Meteor.user()
          portlet = user.profile.portlets[ route_name ][ region ]
          presets = portlet.presets
          config = Deps.nonreactive => Luma.Portlets.get region, "config"
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
            if presets[ value ].config is config
              validation =
                message: "Current configuration is identical to the preset"
                status: "danger"
        else
          validation =
            message: "You must either create a new preset, or select an existing preset."
            status: "danger"
        unless validation
          selector = _id: user._id
          modifier = $set: {}
          modifier.$set[ "profile.portlets.#{ route_name }.#{ region }.presets.#{ value }" ] =
            name: value
            config: config
          result = Meteor.users.update selector, modifier
          console.log "selector", selector
          console.log "modifier", modifier
          console.log "result", result
          if result
            validation =
              message: "Portlet Config '#{ value }' successfully saved"
              status: "success"
            $( "#preset-name" ).val "" if new_portlet_preset
          else
            validation =
              message: "An error occurred while saving"
              status: "danger"
      Luma.Portlets.set region, "save_validation", validation

    initialize_options: ( region ) ->
      route = Luma.Router.current().name
      portlet = Luma.Portlets.get region, "portlet"
      query = {}
      query[ "profile.portlets.#{ route }.#{ region }.portlet" ] = portlet
      options = {}
      Meteor.subscribe "user_profiles", query, options
      Luma.Portlets.set region, "selected_preset", false
      Luma.Portlets.set region, "selected_user", false
      Luma.Portlets.set region, "save_validation", false
      Luma.Portlets.set region, "load_validation", false
