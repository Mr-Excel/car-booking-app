<?php
// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}
?>

<div class="car-booking-container">
    <h2><?php _e('Book a Vehicle', 'car-booking'); ?></h2>
    
    <div id="car-booking-message" class="car-booking-message" style="display: none;"></div>
    
    <form id="car-booking-form" class="car-booking-form">
        <div class="form-row">
            <div class="form-group">
                <label for="start_date"><?php _e('Start Date', 'car-booking'); ?></label>
                <input type="date" id="start_date" name="start_date" required>
            </div>
            
            <div class="form-group">
                <label for="end_date"><?php _e('End Date', 'car-booking'); ?></label>
                <input type="date" id="end_date" name="end_date" required>
            </div>
        </div>
        
        <div class="form-group">
            <label for="vehicle_id"><?php _e('Select Vehicle', 'car-booking'); ?></label>
            <select id="vehicle_id" name="vehicle_id" required>
                <option value=""><?php _e('Loading vehicles...', 'car-booking'); ?></option>
            </select>
        </div>
        
        <div class="form-row">
            <div class="form-group">
                <label for="customer_name"><?php _e('Full Name', 'car-booking'); ?></label>
                <input type="text" id="customer_name" name="customer_name" required>
            </div>
            
            <div class="form-group">
                <label for="customer_email"><?php _e('Email Address', 'car-booking'); ?></label>
                <input type="email" id="customer_email" name="customer_email" required>
            </div>
        </div>
        
        <div class="form-group">
            <label for="customer_phone"><?php _e('Phone Number', 'car-booking'); ?></label>
            <input type="tel" id="customer_phone" name="customer_phone" required>
        </div>
        
        <div class="form-group">
            <button type="submit" class="car-booking-submit"><?php _e('Book Now', 'car-booking'); ?></button>
        </div>
        
        <input type="hidden" name="nonce" value="<?php echo wp_create_nonce('car_booking_nonce'); ?>">
        <input type="hidden" name="redirect_url" value="<?php echo esc_url($atts['redirect_url']); ?>">
    </form>
</div>

<script>
jQuery(document).ready(function($) {
    // Load vehicles
    $.ajax({
        url: car_booking_vars.ajax_url,
        type: 'GET',
        data: {
            action: 'car_booking_get_vehicles',
            nonce: car_booking_vars.nonce
        },
        success: function(response) {
            if (response.success) {
                var vehicles = response.data;
                var options = '<option value=""><?php _e("Select a vehicle", "car-booking"); ?></option>';
                
                $.each(vehicles, function(index, vehicle) {
                    options += '<option value="' + vehicle.id + '">' + vehicle.make + ' ' + vehicle.model + ' (' + vehicle.year + ')</option>';
                });
                
                $('#vehicle_id').html(options);
            } else {
                $('#vehicle_id').html('<option value=""><?php _e("Error loading vehicles", "car-booking"); ?></option>');
                console.error('Error loading vehicles:', response.error);
            }
        },
        error: function(xhr, status, error) {
            $('#vehicle_id').html('<option value=""><?php _e("Error loading vehicles", "car-booking"); ?></option>');
            console.error('AJAX error:', error);
        }
    });
    
    // Form submission
    $('#car-booking-form').on('submit', function(e) {
        e.preventDefault();
        
        var form = $(this);
        var messageContainer = $('#car-booking-message');
        
        // Clear previous messages
        messageContainer.removeClass('success error').hide();
        
        // Disable submit button
        form.find('button[type="submit"]').prop('disabled', true).text('<?php _e("Processing...", "car-booking"); ?>');
        
        $.ajax({
            url: car_booking_vars.ajax_url,
            type: 'POST',
            data: {
                action: 'car_booking_create',
                nonce: car_booking_vars.nonce,
                start_date: $('#start_date').val(),
                end_date: $('#end_date').val(),
                vehicle_id: $('#vehicle_id').val(),
                customer_name: $('#customer_name').val(),
                customer_email: $('#customer_email').val(),
                customer_phone: $('#customer_phone').val()
            },
            success: function(response) {
                // Re-enable submit button
                form.find('button[type="submit"]').prop('disabled', false).text('<?php _e("Book Now", "car-booking"); ?>');
                
                if (response.success) {
                    messageContainer.addClass('success').html('<?php _e("Booking created successfully!", "car-booking"); ?>').show();
                    
                    // Reset form
                    form[0].reset();
                    
                    // Redirect if URL provided
                    var redirectUrl = $('input[name="redirect_url"]').val();
                    if (redirectUrl) {
                        setTimeout(function() {
                            window.location.href = redirectUrl;
                        }, 2000);
                    }
                } else {
                    var errorMessage = response.data && response.data.message ? response.data.message : '<?php _e("An error occurred. Please try again.", "car-booking"); ?>';
                    messageContainer.addClass('error').html(errorMessage).show();
                }
            },
            error: function(xhr, status, error) {
                // Re-enable submit button
                form.find('button[type="submit"]').prop('disabled', false).text('<?php _e("Book Now", "car-booking"); ?>');
                
                messageContainer.addClass('error').html('<?php _e("An error occurred. Please try again.", "car-booking"); ?>').show();
                console.error('AJAX error:', error);
            }
        });
    });
});
</script> 