Template.portlet_placeholder.helpers

  portlet_config: ->
    return {
      selector: "#{ @region }-portlet-config"
      label: "Portlet Config"
      template: "portlet_config"
    }