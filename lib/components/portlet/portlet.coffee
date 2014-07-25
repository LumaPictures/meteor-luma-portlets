Template.portlet.created = ->
  userId = Meteor.userId()
  Luma.Portlets.create @data.region, Deps.autorun => Luma.Portlets.persist_user_portlet @data.region, userId

Template.portlet.destroyed = -> Luma.Portlets.destroy @data.region

Template.portlet.helpers

  portlet: -> return Luma.Portlets.get( @region, "portlet" ) or "portlet_placeholder"

  config: -> return Luma.Portlets.get @region, "config"