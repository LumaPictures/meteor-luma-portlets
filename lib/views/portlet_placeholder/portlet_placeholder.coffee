Template.portlet_placeholder.helpers

  portlet_options: ->
    data = @
    return {
      label: "Portlet Options"
      template: "portlet_options"
      data: data
      icon: "icon-cogs"
    }