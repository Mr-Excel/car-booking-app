/**
 * Car Booking Admin JavaScript
 */
(function ($) {
  "use strict";

  // Initialize date pickers
  function initDatePickers() {
    if ($.datepicker) {
      $(".car-booking-date-picker").datepicker({
        dateFormat: "yy-mm-dd",
        changeMonth: true,
        changeYear: true,
      });
    }
  }

  // Initialize tabs
  function initTabs() {
    $(".car-booking-admin-tabs a").on("click", function (e) {
      e.preventDefault();

      // Get the tab ID
      var tabId = $(this).attr("href");

      // Remove active class from all tabs
      $(".car-booking-admin-tabs a").removeClass("nav-tab-active");
      $(".car-booking-admin-tab-content").hide();

      // Add active class to current tab
      $(this).addClass("nav-tab-active");
      $(tabId).show();

      // Save the active tab to localStorage
      if (typeof Storage !== "undefined") {
        localStorage.setItem("car_booking_active_tab", tabId);
      }
    });

    // Check if there's a saved tab in localStorage
    if (typeof Storage !== "undefined") {
      var activeTab = localStorage.getItem("car_booking_active_tab");
      if (activeTab) {
        $('.car-booking-admin-tabs a[href="' + activeTab + '"]').trigger(
          "click"
        );
      } else {
        // Show the first tab by default
        $(".car-booking-admin-tabs a:first").trigger("click");
      }
    } else {
      // Show the first tab by default
      $(".car-booking-admin-tabs a:first").trigger("click");
    }
  }

  // Initialize data tables
  function initDataTables() {
    if ($.fn.DataTable) {
      $(".car-booking-admin-table").DataTable({
        responsive: true,
        order: [[0, "desc"]],
        pageLength: 25,
        lengthMenu: [
          [10, 25, 50, 100, -1],
          [10, 25, 50, 100, "All"],
        ],
      });
    }
  }

  // Handle bulk actions
  function handleBulkActions() {
    $("#car-booking-bulk-action-apply").on("click", function (e) {
      e.preventDefault();

      var action = $("#car-booking-bulk-action").val();
      if (!action) {
        return;
      }

      var selectedItems = $(".car-booking-bulk-check:checked");
      if (selectedItems.length === 0) {
        alert("Please select at least one item.");
        return;
      }

      // Confirm the action
      if (
        !confirm("Are you sure you want to " + action + " the selected items?")
      ) {
        return;
      }

      // Get the selected IDs
      var ids = [];
      selectedItems.each(function () {
        ids.push($(this).val());
      });

      // Disable the button
      $(this).prop("disabled", true).text("Processing...");

      // Make the AJAX request
      $.ajax({
        url: ajaxurl,
        type: "POST",
        data: {
          action: "car_booking_bulk_action",
          nonce: car_booking_admin_vars.nonce,
          bulk_action: action,
          ids: ids,
        },
        success: function (response) {
          if (response.success) {
            // Reload the page
            window.location.reload();
          } else {
            alert(response.data.message || "An error occurred.");
            $("#car-booking-bulk-action-apply")
              .prop("disabled", false)
              .text("Apply");
          }
        },
        error: function () {
          alert("An error occurred. Please try again.");
          $("#car-booking-bulk-action-apply")
            .prop("disabled", false)
            .text("Apply");
        },
      });
    });

    // Toggle all checkboxes
    $("#car-booking-bulk-check-all").on("change", function () {
      $(".car-booking-bulk-check").prop("checked", $(this).prop("checked"));
    });
  }

  // Handle AJAX form submissions
  function handleAjaxForms() {
    $(".car-booking-ajax-form").on("submit", function (e) {
      e.preventDefault();

      var form = $(this);
      var submitButton = form.find('button[type="submit"]');
      var messageContainer = form.find(".car-booking-admin-message");

      // Clear previous messages
      messageContainer.removeClass("success error").hide();

      // Disable submit button
      submitButton
        .prop("disabled", true)
        .data("original-text", submitButton.text())
        .text("Processing...");

      // Make the AJAX request
      $.ajax({
        url: ajaxurl,
        type: "POST",
        data: form.serialize(),
        success: function (response) {
          // Re-enable submit button
          submitButton
            .prop("disabled", false)
            .text(submitButton.data("original-text"));

          if (response.success) {
            messageContainer
              .addClass("success")
              .html(response.data.message)
              .show();

            // Reset form if needed
            if (form.data("reset-on-success")) {
              form[0].reset();
            }

            // Redirect if needed
            if (response.data.redirect) {
              setTimeout(function () {
                window.location.href = response.data.redirect;
              }, 1000);
            }
          } else {
            messageContainer
              .addClass("error")
              .html(response.data.message)
              .show();
          }
        },
        error: function () {
          submitButton
            .prop("disabled", false)
            .text(submitButton.data("original-text"));
          messageContainer
            .addClass("error")
            .html("An error occurred. Please try again.")
            .show();
        },
      });
    });
  }

  // Initialize the admin scripts
  $(document).ready(function () {
    initDatePickers();
    initTabs();
    initDataTables();
    handleBulkActions();
    handleAjaxForms();

    // Toggle advanced settings
    $(".car-booking-toggle-advanced").on("click", function (e) {
      e.preventDefault();
      var target = $($(this).data("target"));
      target.slideToggle();

      var text = $(this).text();
      $(this).text(
        text === "Show Advanced Settings"
          ? "Hide Advanced Settings"
          : "Show Advanced Settings"
      );
    });
  });
})(jQuery);
