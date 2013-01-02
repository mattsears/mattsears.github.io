#= require foundation/jquery
#= require_tree .


# Make all 'external' links in a new window
externalLinks = ->
  return  unless document.getElementsByTagName
  anchors = document.getElementsByTagName("a")
  i = 0

  while i < anchors.length
    anchor = anchors[i]
    anchor.target = "_blank"  if anchor.getAttribute("href") and anchor.getAttribute("rel") is "external"
    i++

(($, window, undefined_) ->
  "use strict"
  $doc = $(document)
  Modernizr = window.Modernizr

  # Hide address bar on mobile devices (except if #hash present, so we don't mess up deep linking).
  if Modernizr.touch and not window.location.hash
    $(window).load ->
      setTimeout (->
        window.scrollTo 0, 1
      ), 0

  externalLinks()

) jQuery, this


