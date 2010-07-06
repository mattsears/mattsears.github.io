/*------------------------------------
  Global Javascripts
  Aerial
  Version /  1.0
  Author / Matt Sears
  email / matt@mattsears.com
  website / www.mattsears.com
  -------------------------------------*/


//Cufon.replace("h1:not('.nocufon')", { fontFamily: 'Rockwell Bold' });
//Cufon.replace("h2:not('.nocufon')", { fontFamily: 'Rockwell Bold' });
//Cufon.replace("h3:not('.nocufon')", { fontFamily: 'Rockwell Bold' });
//Cufon.replace("h4:not('.nocufon')", { fontFamily: 'Rockwell Bold' });
//Cufon.replace('.intro strong', { fontFamily: 'Rockwell Bold' });
Cufon.replace('.footer-navigation a', { fontFamily: 'interstateBold' });
Cufon.replace('a.more', { fontFamily: 'HoeflerTextItalic', hover: true });
Cufon.replace('a.more-black', { fontFamily: 'HoeflerTextItalic', hover: true });

$(document).ready(function(){

  $('a.more').append('<img src=\"/images/arrow.gif\" alt=\"arrow\" />');
  $('a.more-black').append('<img src=\"/images/arrow-black.gif\" alt=\"arrow\" />');
  $('#recent-articles h2').prepend('<img src=\"/images/arrow.gif\" alt=\"arrow\" />');

  $('#navigation li').hover(
    function(){
      $(this).find('.hover-state').fadeIn();
    },
    function(){
      $(this).find('.hover-state').fadeOut();
    }
  );

  $('#navigation li.articles-link').click(function(){
    console.log("Hello");
   // $(this).find('.active-state').fadeIn();
  });

  $('.flickr-box ul').jflickrfeed({
    limit: 5,
    qstrings: {
      id: '52895180@N00'
    },
    itemTemplate: '<li><a href="{{image_b}}"><img src="{{image_s}}" alt="{{title}}" /></a></li>'
  },
    function(){
      $('.flickr-box ul li').eq(4).addClass('last');
    }
  );

  // Twitter
  $(".twitter-box").tweet({
    count: 2,
    username: "mattsears",
    loading_text: "loading twitter..."
  });

  $('.post .head').hover(
    function(){
      $(this).find('a').addClass('active');
    },
    function(){
      $(this).find('a').removeClass('active');
    }
  );

  $("#slider ul").jcarousel({
    scroll: 1,
    wrap: 'both',
    auto: 7,
    initCallback: mycarousel_initCallback,
    itemVisibleInCallback: mycarousel_visibleCallback,
    buttonNextHTML: null,
    buttonPrevHTML: null
  });


});

function mycarousel_initCallback(carousel) {

  $("#slider .slider-controls a").click(function(){
    var stitle = parseInt($(this).html());
    carousel.scroll(stitle);
    return false;
  });

};

function mycarousel_visibleCallback(carousel, li, index, state) {
  $('#slider .slider-controls a').removeClass('active');
  $('#slider .slider-controls a').eq(index-1).addClass('active');
};


/* When page is loaded
   ----------------------------*/
$(document).ready(function() {
  externalLinks();
});

//
var Comment = {

  author: '',  homepage: '',   email: '',   body: '', article: '',

  // Submit a new comment to the server via ajax
  submit: function(article_id) {

    this.author   = $("input#comment_author").val();
    this.homepage = $("input#comment_homepage").val();
    this.email    = $("input#comment_email").val();
    this.body     = $("textarea#comment_body").val();
    this.article  = article_id;

    // Make sure we have the required fields
    if (!this.valid()){
      return false;
    }

    // Append a new comment if post is successful
    if (this.post()){
      this.appendNew();
    }
  },

  // Post the comment back to the server
  post: function() {

    // Data posted to server
    var data = 'author='+ this.author + '&email=' + this.email +
      '&homepage=' + this.homepage + '&body=' + this.body;
    var url = "/article/" + this.article + "/comments";
    $.ajax({
      type: "POST",
      url:  url,
      data: data
    });
    return true;
  },

  // Add a div for the new comment
  appendNew: function() {

    // Template for the new comment div
    var t = $.template(
      "<div class='comment'><h2>${author}<span>${date}</span></h2><p>${message}</p></div>"
    );

    // Append
    $("#new_comment").fadeOut('slow', function() {
      $("#comments").append( t , {
        author: Comment.author,
        homepage: Comment.homepage,
        message: Comment.body
      });
    });

  },

  // Clear the form field
  reset: function() {
    $("input#comment_author") = '';
  },

  // Ensure all required fields are filled-in
  valid: function() {

    if (this.author == "") {
      $("#author_label").addClass("error");
      return false;
    }

    if (this.email == "") {
      $("#email_label").addClass("error");
      return false;
    }

    if (this.body == "") {
      $("#comment_label").addClass("error");
      return false;
    }
    return true;
  },

}

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
