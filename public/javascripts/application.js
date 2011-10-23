/*------------------------------------
  Global Javascripts
  Aerial
  Version /  1.0
  Author / Matt Sears
  email / matt@mattsears.com
  website / www.mattsears.com
  -------------------------------------*/
Cufon.replace("h1:not('.nocufon')", { fontFamily: 'Titillium-800' });
Cufon.replace("h2:not('.nocufon')", { fontFamily: 'Titillium-800' });
Cufon.replace("h3:not('.nocufon')", { fontFamily: 'Titillium-400' });
Cufon.replace(".box h3:not('.nocufon')", { fontFamily: 'Titillium-800' });
Cufon.replace("h4:not('.nocufon')", { fontFamily: 'Titillium-400' });

$(document).ready(function(){

  $('a.more').append('<img src=\"/images/arrow.gif\" alt=\"arrow\" />');
  $('a.more-black').append('<img src=\"/images/arrow-black.gif\" alt=\"arrow\" />');

  $('.post .head').hover(
    function(){
      $(this).find('a').addClass('active');
    },
    function(){
      $(this).find('a').removeClass('active');
    }
  );

  // Tooltips
  $('#find-elsewhere ul li a').tipsy({gravity: 'n'});

  externalLinks();
});



// Make all 'external' links in a new window
function externalLinks() {
  if (!document.getElementsByTagName) return;
  var anchors = document.getElementsByTagName("a");

  for (var i = 0; i < anchors.length; i++) {
    var anchor = anchors[i];
    if (anchor.getAttribute("href") &&
        anchor.getAttribute("rel") == "external")
      anchor.target = "_blank";
  }
}
