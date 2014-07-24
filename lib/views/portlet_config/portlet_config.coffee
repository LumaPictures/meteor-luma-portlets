Template.portlet_config.helpers

  config: -> return Luma.Portlets.get @region, "config"

  template: -> return Luma.Portlets.get @region, "template"