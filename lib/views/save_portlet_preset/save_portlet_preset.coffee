Template.save_portlet_preset.helpers

  current_user_has_presets: ->
    route_name = Luma.Router.current().route.name
    portlet = Meteor.user().profile.portlets[ route_name ][ @region ]
    has_presets = false
    if portlet.presets
      unless _.isEmpty portlet.presets
        has_presets = true
    return has_presets

  select_preset: ->
    route_name = Luma.Router.current().route.name
    portlet = Meteor.user().profile.portlets[ route_name ][ @region ]
    presets = if portlet.presets then _.values portlet.presets else []
    return {
      id: "select-preset"
      placeholder: "Select Preset Configuration..."
      options:
        allowClear: true
      cursor: presets
    }

  preset_save_validation: -> return Luma.Portlets.get @region, "save_validation"

Template.save_portlet_preset.events

  "click #save-configuration": ( event, template ) ->
    event.preventDefault()
    Luma.Portlets.save_configuration template.data.region