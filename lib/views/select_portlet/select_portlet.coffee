Template.select_portlet.helpers

  config: -> return Luma.Portlets.get @region, "config"

  portlet: -> return Luma.Portlets.get @region, "portlet"

  select_portlet: ->
    portlet = Luma.Portlets.get @region, "portlet"
    cursor = _.values Luma.Portlets._portlets
    return {
      id: "select-portlet"
      selected: portlet
      cursor: cursor
    }

Template.select_portlet.events

  "change #select-portlet": ( event, template ) ->
    Luma.Portlets.set template.data.region, "portlet", event.val