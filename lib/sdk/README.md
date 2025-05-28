# Car Booking SDK

This SDK allows you to integrate the Car Booking application into your own applications, including WordPress websites.

## Contents

- `car_booking_sdk.rb`: Ruby SDK for interacting with the Car Booking API
- `wordpress/`: WordPress plugin for embedding the Car Booking application in WordPress sites

## Ruby SDK Usage

### Installation

Add this to your Gemfile:

```ruby
gem 'car_booking_sdk', path: 'path/to/sdk'
```

Then run:

```bash
bundle install
```

### Basic Usage

```ruby
require 'car_booking_sdk'

# Initialize the SDK with your API credentials
sdk = CarBooking::SDK.new(
  'https://your-car-booking-app.com/api',
  'your_api_key',
  'your_tenant_id'
)

# Authentication
login_response = sdk.login('user@example.com', 'password')
# => { "success" => true, "data" => { "user" => {...}, "token" => "..." } }

# Get bookings
bookings = sdk.get_bookings
# => { "success" => true, "data" => [{ "id" => 1, "start_date" => "2023-07-01", ... }] }

# Create a booking
new_booking = sdk.create_booking({
  start_date: '2023-07-01',
  end_date: '2023-07-05',
  vehicle_id: 1,
  customer_name: 'John Doe',
  customer_email: 'john@example.com',
  customer_phone: '555-123-4567'
})
# => { "success" => true, "data" => { "id" => 2, "start_date" => "2023-07-01", ... } }
```

## WordPress Plugin

### Installation

1. Copy the `wordpress` directory to your WordPress plugins directory (`wp-content/plugins/car-booking`)
2. Activate the plugin from the WordPress admin dashboard
3. Go to "Car Booking" in the admin menu to configure the plugin

### Configuration

1. Enter your Car Booking API URL
2. Enter your API Key
3. Enter your Tenant ID
4. Save changes

### Usage

Use the following shortcodes to embed the Car Booking functionality in your WordPress pages:

#### Booking Form

```
[car_booking_form redirect_url="https://your-site.com/thank-you"]
```

This will display a booking form where users can select a vehicle and dates to make a booking.

Parameters:

- `redirect_url`: (Optional) URL to redirect to after successful booking

#### Booking List

```
[car_booking_list limit="10"]
```

This will display a list of the current user's bookings.

Parameters:

- `limit`: (Optional) Maximum number of bookings to display (default: 10)

### Customization

You can customize the appearance of the booking form and list by overriding the CSS styles in your theme's stylesheet.

## API Documentation

For full API documentation, please refer to the Car Booking API documentation.

## Support

For support, please contact support@example.com.
