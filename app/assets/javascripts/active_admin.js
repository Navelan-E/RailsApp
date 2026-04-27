//= require active_admin/base
//= require activeadmin_addons/all
$(document).ready(function() {
  const initSelect2 = function() {
    $('.select2:not(.select2-hidden-accessible)').select2({
      width: '100%',
      allowClear: true,
      placeholder: "Select an option"
    });
  };

  // 1. Run on initial page load
  initSelect2();

  // 2. Run after Active Admin's "Has Many" blocks are added (Dynamic inputs)
  $(document).on('has_many_add:after', function() {
    initSelect2();
  });

  $('.select2').select2({
  width: '100%',
  dropdownParent: $('.active_admin') // Or $(this).parent()
});
});