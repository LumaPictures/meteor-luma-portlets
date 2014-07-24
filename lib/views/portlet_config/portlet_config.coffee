Template.portlet_config.helpers

  portlet: -> return Session.get "portlet:#{ @region }"