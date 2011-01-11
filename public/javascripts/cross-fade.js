
// wrap as a jQuery plugin and pass jQuery in to our anoymous function
(function ($) {

  $.fn.cross = function (options) {
    return this.each(function (i) {
      // cache the copy of jQuery(this) - the start image
      var $$ = $(this);

      // get the target from the backgroundImage + regexp
      var target = $$.css('backgroundImage').replace(/^url|[\(\)'"]/g, '');

      // nice long chain: wrap img element in span
      $$.wrap('<span style="position: absolute;"></span>')
      // change selector to parent - i.e. newly created span
        .parent()
      // prepend a new image inside the span
        .prepend('<img>')
      // change the selector to the newly created image
        .find(':first-child')
      // set the image to the target
        .attr('src', target);

      // the CSS styling of the start image needs to be handled
      // differently for different browsers
      if ($.browser.msie || $.browser.mozilla) {

        $$.css({
          'position' : 'absolute',
          'left' : 0,
          'background' : '',
          'top' : 0
        });

      } else if ($.browser.opera && $.browser.version < 9.5) {
        // Browser sniffing is bad - however opera < 9.5 has a render bug
        // so this is required to get around it we can't apply the 'top' : 0
        // separately because Mozilla strips the style set originally somehow...
        $$.css({
          'position' : 'absolute',
          'left' : 0,
          'background' : '',
          'top' : "0"
        });
      } else { // Safari
        $$.css({
          'position' : 'absolute',
          'left' : 0,
          'background' : ''
        });
      }

      // similar effect as single image technique, except using .animate
      // which will handle the fading up from the right opacity for us
      $$.hover(function () {
        $$.stop().animate({
          opacity: 0
        }, 300);
      }, function () {
        $$.stop().animate({
          opacity: 1
        }, 300);
      });
    });
  };

})(jQuery);

// Not only when the DOM is ready, but when the images have finished loading,
// important, but subtle difference to $(document).ready();
$(window).bind('load', function () {
  // run the cross fade plugin against selector
  $('img.fade').cross();
});