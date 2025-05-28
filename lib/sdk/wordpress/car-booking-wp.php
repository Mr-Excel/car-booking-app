<?php
/**
 * Plugin Name: Car Booking Integration
 * Plugin URI: https://example.com/car-booking
 * Description: Integrates your WordPress site with the Car Booking application
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://example.com
 * Text Domain: car-booking
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('CAR_BOOKING_VERSION', '1.0.0');
define('CAR_BOOKING_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('CAR_BOOKING_PLUGIN_URL', plugin_dir_url(__FILE__));

class CarBookingWP {
    private $api_url;
    private $api_key;
    private $tenant_id;
    
    public function __construct() {
        // Initialize plugin
        add_action('init', array($this, 'init'));
        
        // Register shortcodes
        add_shortcode('car_booking_form', array($this, 'render_booking_form'));
        add_shortcode('car_booking_list', array($this, 'render_booking_list'));
        
        // Register admin menu
        add_action('admin_menu', array($this, 'register_admin_menu'));
        
        // Register settings
        add_action('admin_init', array($this, 'register_settings'));
        
        // Enqueue scripts and styles
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
        add_action('admin_enqueue_scripts', array($this, 'admin_enqueue_scripts'));
        
        // AJAX handlers
        add_action('wp_ajax_car_booking_create', array($this, 'ajax_create_booking'));
        add_action('wp_ajax_nopriv_car_booking_create', array($this, 'ajax_create_booking'));
        add_action('wp_ajax_car_booking_get_vehicles', array($this, 'ajax_get_vehicles'));
        add_action('wp_ajax_nopriv_car_booking_get_vehicles', array($this, 'ajax_get_vehicles'));
    }
    
    public function init() {
        // Load plugin options
        $this->api_url = get_option('car_booking_api_url');
        $this->api_key = get_option('car_booking_api_key');
        $this->tenant_id = get_option('car_booking_tenant_id');
    }
    
    public function register_admin_menu() {
        add_menu_page(
            'Car Booking Settings',
            'Car Booking',
            'manage_options',
            'car-booking-settings',
            array($this, 'render_settings_page'),
            'dashicons-calendar-alt',
            30
        );
    }
    
    public function register_settings() {
        register_setting('car_booking_settings', 'car_booking_api_url');
        register_setting('car_booking_settings', 'car_booking_api_key');
        register_setting('car_booking_settings', 'car_booking_tenant_id');
    }
    
    public function render_settings_page() {
        ?>
        <div class="wrap">
            <h1>Car Booking Settings</h1>
            <form method="post" action="options.php">
                <?php settings_fields('car_booking_settings'); ?>
                <?php do_settings_sections('car_booking_settings'); ?>
                <table class="form-table">
                    <tr valign="top">
                        <th scope="row">API URL</th>
                        <td><input type="text" name="car_booking_api_url" value="<?php echo esc_attr(get_option('car_booking_api_url')); ?>" class="regular-text" /></td>
                    </tr>
                    <tr valign="top">
                        <th scope="row">API Key</th>
                        <td><input type="text" name="car_booking_api_key" value="<?php echo esc_attr(get_option('car_booking_api_key')); ?>" class="regular-text" /></td>
                    </tr>
                    <tr valign="top">
                        <th scope="row">Tenant ID</th>
                        <td><input type="text" name="car_booking_tenant_id" value="<?php echo esc_attr(get_option('car_booking_tenant_id')); ?>" class="regular-text" /></td>
                    </tr>
                </table>
                <?php submit_button(); ?>
            </form>
        </div>
        <?php
    }
    
    public function enqueue_scripts() {
        wp_enqueue_style('car-booking-style', CAR_BOOKING_PLUGIN_URL . 'assets/css/car-booking.css', array(), CAR_BOOKING_VERSION);
        wp_enqueue_script('car-booking-script', CAR_BOOKING_PLUGIN_URL . 'assets/js/car-booking.js', array('jquery'), CAR_BOOKING_VERSION, true);
        
        wp_localize_script('car-booking-script', 'car_booking_vars', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('car_booking_nonce')
        ));
    }
    
    public function admin_enqueue_scripts() {
        wp_enqueue_style('car-booking-admin-style', CAR_BOOKING_PLUGIN_URL . 'assets/css/car-booking-admin.css', array(), CAR_BOOKING_VERSION);
        wp_enqueue_script('car-booking-admin-script', CAR_BOOKING_PLUGIN_URL . 'assets/js/car-booking-admin.js', array('jquery'), CAR_BOOKING_VERSION, true);
    }
    
    public function render_booking_form($atts) {
        $atts = shortcode_atts(array(
            'redirect_url' => '',
        ), $atts, 'car_booking_form');
        
        ob_start();
        include CAR_BOOKING_PLUGIN_DIR . 'templates/booking-form.php';
        return ob_get_clean();
    }
    
    public function render_booking_list($atts) {
        $atts = shortcode_atts(array(
            'limit' => 10,
        ), $atts, 'car_booking_list');
        
        ob_start();
        include CAR_BOOKING_PLUGIN_DIR . 'templates/booking-list.php';
        return ob_get_clean();
    }
    
    public function ajax_create_booking() {
        // Verify nonce
        if (!isset($_POST['nonce']) || !wp_verify_nonce($_POST['nonce'], 'car_booking_nonce')) {
            wp_send_json_error('Security check failed');
        }
        
        // Get form data
        $booking_data = array(
            'start_date' => sanitize_text_field($_POST['start_date']),
            'end_date' => sanitize_text_field($_POST['end_date']),
            'vehicle_id' => intval($_POST['vehicle_id']),
            'customer_name' => sanitize_text_field($_POST['customer_name']),
            'customer_email' => sanitize_email($_POST['customer_email']),
            'customer_phone' => sanitize_text_field($_POST['customer_phone']),
        );
        
        // Make API request
        $response = $this->api_request('POST', '/bookings', array('booking' => $booking_data));
        
        if ($response['success']) {
            wp_send_json_success($response);
        } else {
            wp_send_json_error($response['error']);
        }
    }
    
    public function ajax_get_vehicles() {
        // Verify nonce
        if (!isset($_GET['nonce']) || !wp_verify_nonce($_GET['nonce'], 'car_booking_nonce')) {
            wp_send_json_error('Security check failed');
        }
        
        // Make API request
        $response = $this->api_request('GET', '/vehicles');
        
        if ($response['success']) {
            wp_send_json_success($response);
        } else {
            wp_send_json_error($response['error']);
        }
    }
    
    private function api_request($method, $endpoint, $data = array()) {
        $url = trailingslashit($this->api_url) . ltrim($endpoint, '/');
        
        $args = array(
            'method' => $method,
            'headers' => array(
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'X-API-Key' => $this->api_key,
                'X-Tenant-ID' => $this->tenant_id,
            ),
            'timeout' => 30,
        );
        
        if (!empty($data) && in_array($method, array('POST', 'PUT'))) {
            $args['body'] = json_encode($data);
        }
        
        $response = wp_remote_request($url, $args);
        
        if (is_wp_error($response)) {
            return array(
                'success' => false,
                'error' => $response->get_error_message(),
            );
        }
        
        $response_code = wp_remote_retrieve_response_code($response);
        $response_body = wp_remote_retrieve_body($response);
        
        $response_data = json_decode($response_body, true);
        
        if ($response_code >= 200 && $response_code < 300) {
            return array(
                'success' => true,
                'data' => $response_data,
            );
        } else {
            return array(
                'success' => false,
                'status' => $response_code,
                'error' => $response_data,
            );
        }
    }
}

// Initialize the plugin
$car_booking_wp = new CarBookingWP(); 