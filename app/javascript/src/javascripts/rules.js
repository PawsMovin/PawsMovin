import Utility from "./utility";

const Rules = { mode: null };

Rules.initialize_listeners = function() {
  const $editOrderLink = $(".edit-order-link");
  const $editCategoryOrderLink = $(".edit-category-order-link");
  const $saveOrderLink = $(".save-order-link");
  const $sortableRules = $("#sortable-rules");

  $editOrderLink.on("click.pawsmovin.sorting", function(event) {
    event.preventDefault();
    $saveOrderLink.show();
    $editOrderLink.hide();
    $editCategoryOrderLink.hide();
    $sortableRules.sortable({
      items: "tbody.rules tr"
    });
    Rules.mode = "rules";
    Danbooru.notice("Drag and drop to reorder.");
  });

  $editCategoryOrderLink.on("click.pawsmovin.sorting", function(event) {
    event.preventDefault();
    $saveOrderLink.show();
    $editOrderLink.hide();
    $editCategoryOrderLink.hide();
    $sortableRules.sortable({
      items: "tbody"
    });
    Rules.mode = "categories";
    Danbooru.notice("Drag and drop to reorder.");
  });

  $saveOrderLink.on("click.pawsmovin.sorting", function(event) {
    event.preventDefault();
    $saveOrderLink.hide();
    $sortableRules.sortable("disable");
    $.ajax({
      url: `/rules${Rules.mode === "categories" ? "/categories" : ""}/reorder.js`,
      type: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      data: Rules.reorder_data(Rules.mode),
      dataType: "json",
      success(data) {
        $("#sortable-rules-container").html(data.html);
        Danbooru.notice("Order updated.");
        $editOrderLink.show();
        $editCategoryOrderLink.show();
        Rules.reinitialize_listeners();
      },
      error(data) {
        if(data.responseJSON.message) {
          Danbooru.error(`Failed to update order: ${data.responseJSON.message}`);
        } else if(data.responseJSON.errors) {
          Danbooru.error(`Failed to update order:<br>${data.responseJSON.errors.map(e => `${e.name}: ${e.message}`).join("<br>")}`);
        } else {
          Danbooru.error("Failed to update order.");
        }
        $saveOrderLink.show();
        if (Rules.mode === "rules") {
          $sortableRules.sortable({
            items: "tbody.rules tr"
          });
        } else {
          $sortableRules.sortable({
            items: "tbody"
          });
        }
      }
    });
  });
}

Rules.reinitialize_listeners = function() {
  $(".edit-order-link").off("click.pawsmovin.sorting");
  $(".edit-category-order-link").off("click.pawsmovin.sorting");
  $(".save-order-link").off("click.pawsmovin.sorting");
  Rules.initialize_listeners();
}

Rules.reorder_data = function(mode) {
  if(mode === "rules") {
    const data = [];
    Utility.chunk(Array.from($("table#sortable-rules tbody")), 2).forEach(([category, rulesContainer], index) => {
      const rules = Array.from(rulesContainer.querySelectorAll("tr"));
      const category_id = Number(category.dataset.categoryId);
      data.push(...rules.map((r, index) => ({
        id: Number(r.dataset.id),
        order: index + 1,
        category_id
      })));
    });
    return JSON.stringify(data);
  } else {
    const data = []
    Array.from($("table#sortable-rules tbody")).forEach((category, index) => {
      data.push({
        id: Number(category.dataset.categoryId),
        order: index + 1
      });
    });
    return JSON.stringify(data);
  }
}

$(document).ready(function() {
  if ($("#c-rules #a-order, #c-rules-categories #a-order").length) {
    Rules.initialize_listeners();
  }
});

export default Rules;
