const StaffNote = {};

StaffNote.initialize_all = function() {
  $(".edit_staff_note_link").on("click", StaffNote.show_edit_form);
}

StaffNote.show_edit_form = function(e) {
  e.preventDefault();
  $(this).closest(".staff-note").find(".edit_staff_note").show();
}

$(document).ready(function () {
  StaffNote.initialize_all();
});

export default StaffNote;
