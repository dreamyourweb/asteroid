if Meteor.isClient
  Meteor.startup ->
    Template.WBSO.rendered = ->
      $('.mathquill-embedded-latex').mathquill()

    Template.DealRatio.rendered = ->
      $('.mathquill-embedded-latex').mathquill()