;(function($) {

  $.noty.themes.speechBubble = {
    name: 'speechBubble',
    style: function() {

      this.$bar.css({
        overflow: 'hidden'
      });

    },
    callback: {
      onShow: function() { },
      onClose: function() { }
    }
  };

})(jQuery);
