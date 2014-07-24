Template.portlet_config.helpers

  config: -> return Luma.Portlets.get @region, "config"

  portlet: -> return Luma.Portlets.get @region, "portlet"