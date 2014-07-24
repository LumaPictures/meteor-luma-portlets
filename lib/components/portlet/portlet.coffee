Template.portlet.created = ->
  @portlet_autorun = Deps.autorun =>
    portlet = Session.get "portlet:#{ @data.region }"
    if portlet.config and Meteor.user()
      route = Luma.Router.current().route
      user = Meteor.user()
      portlet_dictionary = {}
      portlet_dictionary[ portlet.region ] = portlet
      _.extend user.profile.portlets[ route.name ], portlet_dictionary
      Meteor.users.update _id: user._id,
        $set:
          "profile.portlets": user.profile.portlets

Template.portlet.destroyed = -> @portlet_autorun.stop()

Template.portlet.helpers

  template: ->
    portlet = Session.get "portlet:#{ @region }"
    template = if Template[ portlet.template ] then portlet.template else "portlet_placeholder"
    return template

  config: ->
    portlet = Session.get "portlet:#{ @region }"
    return portlet.config