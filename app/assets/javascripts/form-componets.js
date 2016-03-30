(function () {
  var applyDatetimePicker = function ($root) {
    $root.find('input[data-datetimepicker]:visible, input[type=hidden][data-datetimepicker]').each(function() {
      var $this = $(this);
      var isInline = !!$this.data('datetimepicker-inline');

      if (!$this.data('datetimepicker-instance')) {
        if(isInline) {
          $this.hide();
        }

        $this.datetimepicker({
          format: 'D-MMM-YYYY hh:mma ([UTC]Z)',
          sideBySide: true,
          showClear: !isInline,
          inline: isInline
        });

        $this.data('datetimepicker-instance', true);
      }
    });
  };

  $(document).on('page:change', function () {
    var $root = $('body');

    applyDatetimePicker($root);
  });
})();