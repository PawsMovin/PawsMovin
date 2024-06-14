import Utility from "./utility";

const Notification = {};

Notification.add_to_links = function() {
  $("#notification-list tbody tr").each((_, tr) => {
    const $tr = $(tr);
    const id = $tr.attr("data-id");
    $tr.find(".notification-content a").each((_, link) => {
      const $link = $(link);
      const url = new URL($link.attr("href"), window.location.origin);
      const params = new URLSearchParams(url.search);
      params.set("n", id);
      url.search = params.toString();
      $link.attr("href", url.toString());
    });
  });
}

Notification.save_state = function() {
  // if we're viewing the notification list, clear any saved data
  if ($("#c-notifications #a-index").length) {
    sessionStorage.removeItem("notification_id");
    const params = Utility.get_query_params(window.location.href);
    // if r is present, remove it. r is used to make notifications as read when returning from them,
    // just in case the  "View" link wasn't used
    if (params.has("r")) {
      params.delete("r");
      history.replaceState(null, "", Utility.set_query_params(window.location.href, params));
    }
    return;
  }
  const params = Utility.get_query_params(window.location.href)
  // n is passed around so we know what notification we came from
  const id = params.get("n");
  if (!id) {
    return;
  }
  sessionStorage.setItem("notification_id", id);
  $("body").attr("data-notification-id", id);
  params.delete("n");
  history.replaceState(null, "", Utility.set_query_params(window.location.href, params));
}

Notification.get_current_notification_id = function() {
  const id = sessionStorage.getItem("notification_id");
  if (!id) {
    return null;
  }
  return Number(id);
}

Notification.init_return_button = function() {
  const id = Notification.get_current_notification_id();
  if (id === null) {
    return;
  }

  $("header#top").addClass("notification");
  const $link = $("menu#notification-return a");
  const params = Utility.get_query_params($link.attr("href"));
  params.set("r", id);
  $link.attr("href", Utility.set_query_params($link.attr("href"), params));
}

Notification.hide_notice = function() {
  if (Notification.get_current_notification_id() === null) {
    return;
  }
  $("div#notification-notice").hide();
}

$(function() {
  if ($("#c-notifications #a-index").length) {
    Notification.add_to_links();
  }
  Notification.save_state();
  Notification.init_return_button();
  Notification.hide_notice();
});

export default Notification;
