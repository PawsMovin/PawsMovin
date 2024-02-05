import Utility from './utility';
import { SendQueue } from './send_queue';

const Artist = {};

Artist.update = function (id, params) {
  SendQueue.add(function() {
    $.ajax({
      type: "PUT",
      url: "/artists/" + id + ".json",
      data: params,
      success: function(data) {
        Utility.notice("Artist updated.");
      },
      error: function(data) {
        Utility.error(`There was an error updating <a href="/artists/${id}">artist #${id}</a>`);
      }
    });
  });
};

function init() {
}

export default Artist;

$(function () {
  if ($("#c-artists").length) {
    init();
  }
});
