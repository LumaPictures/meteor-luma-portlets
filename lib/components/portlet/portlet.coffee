Template.portlet.created = ->
  Luma.Portlets.create @data.region, Deps.autorun =>
    if Luma.Portlets.get( @data.region, "config" ) and Meteor.user()
      Luma.Portlets.persist_user_portlet @data.region, Meteor.userId()

Template.portlet.destroyed = -> Luma.Portlets.destroy @data.region

Template.portlet.helpers

  portlet: -> return Luma.Portlets.get( @region, "portlet" ) or "portlet_placeholder"

  config: -> return Luma.Portlets.get @region, "config"