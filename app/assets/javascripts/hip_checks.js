// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function () {
  var applyDatetimePicker = function ($root) {
    $root.find('input[data-datetimepicker]:visible, input[type=hidden][data-datetimepicker]').each(function() {
      var $this = $(this);
      var isInline = !!$this.data('datetimepicker-inline');

      if (!$this.data('datetimepicker-instance')) {
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