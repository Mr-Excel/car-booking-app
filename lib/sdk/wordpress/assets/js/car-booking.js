/**
 * Car Booking Frontend JavaScript
 */
(function ($) {
  "use strict";

  // Initialize date pickers
  function initDatePickers() {
    if ($.datepicker) {
      $("#start_date, #end_date").datepicker({
        dateFormat: "yy-mm-dd",
        minDate: 0,
        changeMonth: true,
        changeYear: true,
        onSelect: function (selectedDate) {
          var option = this.id === "start_date" ? "minDate" : "maxDate";
          var instance = $(this).data("datepicker");
          var date = $.datepicker.parseDate(
            instance.settings.dateFormat || $.datepicker._defaults.dateFormat,
            selectedDate,
            instance.settings
          );

          if (this.id === "start_date") {
            $("#end_date").datepicker("option", "minDate", date);
          } else {
            $("#start_date").datepicker("option", "maxDate", date);
          }
        },
      });
    }
  }

  // Validate booking form
  function validateBookingForm() {
    var isValid = true;
    var startDate = $("#start_date").val();
    var endDate = $("#end_date").val();
    var vehicleId = $("#vehicle_id").val();
    var customerName = $("#customer_name").val();
    var customerEmail = $("#customer_email").val();
    var customerPhone = $("#customer_phone").val();

    // Clear previous errors
    $(".form-group").removeClass("has-error");

    // Validate required fields
    if (!startDate) {
      $("#start_date").closest(".form-group").addClass("has-error");
      isValid = false;
    }

    if (!endDate) {
      $("#end_date").closest(".form-group").addClass("has-error");
      isValid = false;
    }

    if (!vehicleId) {
      $("#vehicle_id").closest(".form-group").addClass("has-error");
      isValid = false;
    }

    if (!customerName) {
      $("#customer_name").closest(".form-group").addClass("has-error");
      isValid = false;
    }

    if (!customerEmail) {
      $("#customer_email").closest(".form-group").addClass("has-error");
      isValid = false;
    } else if (!isValidEmail(customerEmail)) {
      $("#customer_email").closest(".form-group").addClass("has-error");
      isValid = false;
    }

    if (!customerPhone) {
      $("#customer_phone").closest(".form-group").addClass("has-error");
      isValid = false;
    }

    return isValid;
  }

  // Validate email format
  function isValidEmail(email) {
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  // Format currency
  function formatCurrency(amount, currencySymbol) {
    currencySymbol = currencySymbol || "$";
    return currencySymbol + parseFloat(amount).toFixed(2);
  }

  // Format date
  function formatDate(dateString) {
    var date = new Date(dateString);
    return date.toLocaleDateString();
  }

  // Calculate number of days between two dates
  function calculateDays(startDate, endDate) {
    var start = new Date(startDate);
    var end = new Date(endDate);
    var timeDiff = Math.abs(end.getTime() - start.getTime());
    return Math.ceil(timeDiff / (1000 * 3600 * 24));
  }

  // Initialize the plugin
  $(document).ready(function () {
    // Initialize date pickers
    initDatePickers();

    // Custom form validation
    $("#car-booking-form").on("submit", function (e) {
      if (!validateBookingForm()) {
        e.preventDefault();
        $("#car-booking-message")
          .removeClass("success error")
          .addClass("error")
          .html("Please fill in all required fields correctly.")
          .show();
      }
    });

    // Vehicle selection change
    $("#vehicle_id").on("change", function () {
      var vehicleId = $(this).val();
      if (vehicleId) {
        // You could add additional logic here, like fetching vehicle details
        // or updating price calculations based on the selected vehicle
      }
    });

    // Date change events
    $("#start_date, #end_date").on("change", function () {
      var startDate = $("#start_date").val();
      var endDate = $("#end_date").val();

      if (startDate && endDate) {
        var days = calculateDays(startDate, endDate);
        // You could update price calculations here based on the number of days
      }
    });
  });
})(jQuery);
