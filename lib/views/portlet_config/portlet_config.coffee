Template.portlet_config.helpers

  config: -> return Luma.Portlets.get @region, "config"

  portlet: -> return Luma.Portlets.get @region, "portlet"

  select_portlet: ->
    portlet = Luma.Portlets.get @region, "portlet"
    cursor = _.values Luma.Portlets._portlets
    return {
      id: "select-portlet"
      options:
        width: '100%'
        placeholder: "Select Portlet..."
      selected: [ portlet ]
      cursor: cursor
    }

Template.portlet_config.events

  "change #select-portlet": ( event, template ) ->
    Luma.Portlets.set template.data.region, "portlet", event.val
    close_modal = ->
      $('.modal').modal 'hide'
      $('.modal-backdrop').remove()
    Meteor.setTimeout close_modal, 333