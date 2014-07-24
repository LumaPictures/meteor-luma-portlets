# luma-portlets
if Meteor.isClient
  Luma.Portlets =

    _computations: {}

    _dictionaries: {}

    _add_computation: ( region, computation ) -> @_computations[ region ] = computation

    _stop_computation: ( region ) -> @_computations[ region ].stop() if @_computations[ region ] and @_computations[ region ].stop

    _add_dictionary: ( region ) -> @_dictionaries[ region ] = new ReactiveDict()

    _remove_dictionary: ( region ) -> delete @_dictionaries[ region ] if @_dictionaries[ region ]

    _copy_dictionary: ( region ) ->
      if @_dictionaries[ region ]
        dictionary = {}
        for key of @_dictionaries[ region ].keys
          dictionary[ key ] = @get region, key
        return dictionary

    persist_user_portlet: ( region, userId, route = null ) ->
      user = Meteor.users.findOne _id: userId
      route ?= Luma.Router.current().route.name
      if user and user.profile.portlets
        portlet = Luma.Portlets._copy_dictionary region
        user.profile.portlets[ route ][ region ] ?= {}
        _.extend user.profile.portlets[ route ][ region ], portlet
        Meteor.users.update _id: user._id,
          $set:
            "profile.portlets": user.profile.portlets

    set: ( region, key, value ) ->
      if @_dictionaries[ region ] and @_dictionaries[ region ].set
        @_dictionaries[ region ].set key, value
      else throw new Error "A ReactiveDict has not been created for region '#{ region }'"

    get: ( region, key ) ->
      if @_dictionaries[ region ] and @_dictionaries[ region ].get
        @_dictionaries[ region ].get key
      else throw new Error "A ReactiveDict has not been created for region '#{ region }'"

    initialize: ( route, portlets ) ->
      if portlets
        # set all the route portlets as session variables
        for portlet, key in portlets
          @_add_dictionary portlet.region
          if portlet.config
            user = Deps.nonreactive -> Meteor.user()
            if user
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
        Luma.Portlet.set region, key, value
      validation =
        message: "Preset '#{ preset_name }' successfully loaded"
        status: "success"
      Luma.Portlet.set "options_validation", validation

    save_configuration: ( region ) ->
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
        user = Meteor.user()
        portlet = user.profile.portlets[ Luma.Router.current().route.name ][ region ]
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
          if presets[ value ] is config
            validation =
              message: "Current configuration is identical to the preset"
              status: "danger"
        unless validation
          modifier = $set: {}
          modifier.$set[ "profile.portlets.#{ Luma.Router.current().route.name }.#{ region }.presets" ] = presets
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
      Luma.Portlets.set region, "save_validation", validation

    initialize_options: ( region ) ->
      route = Luma.Router.current().name
      template = Luma.Portlets.get region, "template"
      query = {}
      query[ "profile.portlets.#{ route }.#{ region }.template" ] = template
      options = {}
      Meteor.subscribe "user_profiles", query, options
      Luma.Portlets.set region, "selected_preset", false
      Luma.Portlets.set region, "selected_user", false
      Luma.Portlets.set region, "save_validation", false
      Luma.Portlets.set region, "load_validation", false
