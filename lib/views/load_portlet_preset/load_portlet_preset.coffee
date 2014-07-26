Template.load_portlet_preset.helpers

  selected_user: -> return Luma.Portlets.get @region, "selected_user"

  select_user: ->
    cursor = []
    cursor.push Deps.nonreactive -> Meteor.user()
    return {
      id: "select-user"
      placeholder: "Select User..."
      cursor: cursor
    }

  load_preset: ->
    return {
      id: "load-preset"
      placeholder: "Load Preset Configuration..."
    }

  load_preset_cursor: ->
    presets = Meteor.user().profile.portlets[ Luma.Router.current().route.name  ][ @region ].presets
    return _.values presets

  preset_load_validation: -> return Luma.Portlets.get @region, "load_validation"

  selected_preset: -> return Luma.Portlets.get @region, "selected_preset"

Template.load_portlet_preset.events
  "click #load-configuration": ( event, template ) -> Luma.Portlets.load_configuration template.data.region

  "change #load-preset": ( event, template ) ->
    Luma.Portlets.set template.data.region, "selected_preset", event.val

  "change #select-user": ( event, template ) ->
    console.log event.val
    Luma.Portlets.set template.data.region, "selected_user", event.val
    Luma.Portlets.set template.data.region, "selected_preset", false