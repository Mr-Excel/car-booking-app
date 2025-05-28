<?php
// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

// Check if user is logged in
if (!is_user_logged_in()) {
    echo '<div class="car-booking-message error">';
    _e('You must be logged in to view your bookings.', 'car-booking');
    echo '</div>';
    return;
}

// Get current user
$current_user = wp_get_current_user();
$user_email = $current_user->user_email;

// Make API request to get bookings
$car_booking = $GLOBALS['car_booking_wp'];
$response = $car_booking->api_request('GET', '/bookings', array('email' => $user_email, 'limit' => $atts['limit']));

if (!$response['success']) {
    echo '<div class="car-booking-message error">';
    _e('Error loading bookings. Please try again later.', 'car-booking');
    echo '</div>';
    return;
}

$bookings = $response['data'];

if (empty($bookings)) {
    echo '<div class="car-booking-message info">';
    _e('You have no bookings yet.', 'car-booking');
    echo '</div>';
    return;
}
?>

<div class="car-booking-container">
    <h2><?php _e('Your Bookings', 'car-booking'); ?></h2>
    
    <div class="car-booking-list">
        <?php foreach ($bookings as $booking): ?>
            <div class="car-booking-item">
                <div class="car-booking-header">
                    <h3>
                        <?php 
                        if (!empty($booking['vehicle'])) {
                            echo esc_html($booking['vehicle']['make'] . ' ' . $booking['vehicle']['model'] . ' (' . $booking['vehicle']['year'] . ')');
                        } else {
                            _e('Vehicle details not available', 'car-booking');
                        }
                        ?>
                    </h3>
                    <span class="car-booking-status <?php echo esc_attr(strtolower($booking['status'])); ?>">
                        <?php echo esc_html($booking['status']); ?>
                    </span>
                </div>
                
                <div class="car-booking-details">
                    <div class="car-booking-dates">
                        <div class="car-booking-date">
                            <strong><?php _e('Start Date:', 'car-booking'); ?></strong>
                            <?php echo esc_html(date_i18n(get_option('date_format'), strtotime($booking['start_date']))); ?>
                        </div>
                        <div class="car-booking-date">
                            <strong><?php _e('End Date:', 'car-booking'); ?></strong>
                            <?php echo esc_html(date_i18n(get_option('date_format'), strtotime($booking['end_date']))); ?>
                        </div>
                    </div>
                    
                    <?php if (!empty($booking['total_price'])): ?>
                        <div class="car-booking-price">
                            <strong><?php _e('Total Price:', 'car-booking'); ?></strong>
                            <?php echo esc_html(number_format_i18n($booking['total_price'], 2)); ?>
                        </div>
                    <?php endif; ?>
                    
                    <?php if ($booking['status'] === 'CONFIRMED' || $booking['status'] === 'PENDING'): ?>
                        <div class="car-booking-actions">
                            <button class="car-booking-cancel" data-booking-id="<?php echo esc_attr($booking['id']); ?>">
                                <?php _e('Cancel Booking', 'car-booking'); ?>
                            </button>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<script>
jQuery(document).ready(function($) {
    $('.car-booking-cancel').on('click', function() {
        if (!confirm('<?php _e("Are you sure you want to cancel this booking?", "car-booking"); ?>')) {
            return;
        }
        
        var button = $(this);
        var bookingId = button.data('booking-id');
        
        button.prop('disabled', true).text('<?php _e("Cancelling...", "car-booking"); ?>');
        
        $.ajax({
            url: car_booking_vars.ajax_url,
            type: 'POST',
            data: {
                action: 'car_booking_cancel',
                nonce: car_booking_vars.nonce,
                booking_id: bookingId
            },
            success: function(response) {
                if (response.success) {
                    button.closest('.car-booking-item').fadeOut(function() {
                        $(this).remove();
                        
                        if ($('.car-booking-item').length === 0) {
                            $('.car-booking-list').html('<div class="car-booking-message info"><?php _e("You have no bookings.", "car-booking"); ?></div>');
                        }
                    });
                } else {
                    button.prop('disabled', false).text('<?php _e("Cancel Booking", "car-booking"); ?>');
                    alert(response.data && response.data.message ? response.data.message : '<?php _e("An error occurred. Please try again.", "car-booking"); ?>');
                }
            },
            error: function(xhr, status, error) {
                button.prop('disabled', false).text('<?php _e("Cancel Booking", "car-booking"); ?>');
                alert('<?php _e("An error occurred. Please try again.", "car-booking"); ?>');
                console.error('AJAX error:', error);
            }
        });
    });
});
</script> 