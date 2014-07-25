Template.portlet_placeholder.helpers

  portlet_options: ->
    return {
      selector: "#{ @region }-portlet-options"
      label: "Portlet Options"
      template: "portlet_options"
    }