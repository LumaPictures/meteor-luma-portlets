Template.portlet_options.rendered = -> Luma.Portlets.initialize_options @data.region

Template.portlet_options.helpers

  is_portlet: ->
    portlet = Luma.Portlets.get @region, "portlet"
    if portlet is "portlet_placeholder" or portlet is undefined
      return false
    else return true