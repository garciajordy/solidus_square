# Solidus Square

[![CircleCI](https://circleci.com/gh/nebulab/solidus_square.svg?style=shield)](https://circleci.com/gh/nebulab/solidus_square)
[![codecov](https://codecov.io/gh/nebulab/solidus_square/branch/main/graph/badge.svg?token=hjU5oKqYMo)](https://codecov.io/gh/nebulab/solidus_square)

`solidus_square` is an extension that adds support for using [Square](https://squareup.com) as a payment source in your [Solidus](https://solidus.io/) store.

## Installation

Add solidus_square to your Gemfile:

```ruby
gem 'solidus_square'
```

Bundle your dependencies and run the installation generator:

```shell
bin/rails generate solidus_square:install
```

## Basic Setup

### Creating a new Payment Method

Payment methods can accept preferences either directly entered in admin, or from a static source in code.
For most projects we recommend using a static source, so that sensitive account credentials are not stored in the database.

1. Set static preferences in an initializer

```ruby
# config/initializers/solidus_square.rb
SolidusSquare.configure do |config|
  config.square_access_token = ENV['SQUARE_ACCESS_TOKEN']
  config.square_environment = ENV['SQUARE_ENVIRONMENT']
  config.square_location_id = ENV['SQUARE_LOCATION_ID']
  config.square_payment_method = Spree::PaymentMethod.find(ENV['SQUARE_PAYMENT_METHOD_ID'])
end

Spree::Config.configure do |config|
  config.static_model_preferences.add(
    SolidusSquare::PaymentMethod,
    'square_credentials', {
      access_token: SolidusSquare.config.square_access_token,
      environment: SolidusSquare.config.square_environment,
      location_id: SolidusSquare.config.square_location_id,
      redirect_url: ENV['SQUARE_REDIRECT_URL']
    }
  )
end
```

2. Visit `/admin/payment_methods/new`
3. Set `provider` to SolidusSquare::PaymentMethod
4. Click "Save"
5. Choose `square_credentials` from the `Preference Source` select
6. Click `Update` to save

Alternatively, create a payment method from the Rails console with:

```ruby
SolidusSquare::PaymentMethod.new(
  name: "Square",
  preference_source: "square_credentials"
).save
```

### How to retrieve the location ID

1. Visit the [SquareDeveloper](https://developer.squareup.com/apps) website

2. Login into your account.

3. Create or open an existing app.

4. Navigate on the left side navigation bar to `Locations`.

## **Square Hosted Checkout**

### Usage

To activate the Square hosted checkout workflow, copy the endpoint in the `config/routes.rb` file,
```ruby
Spree::Core::Engine.routes.draw do
    get 'square_checkout', to: '/solidus_square/callback_actions#square_checkout'
    get 'complete_checkout', to: '/solidus_square/callback_actions#complete_checkout'
end
```

and create a button to bring the user at that page, or call the API to start the checkout Flow or add the following
deface file.

`app/overrides/spree/checkout/_payment/add_hosted_checkout.html.erb.deface`
```ruby
<!-- insert_top "fieldset[id='payment']" -->

<%= link_to 'Square Hosted Checkout', square_checkout_path %>
```

When the Square hosted checkout finish, Square will redirect you automatically to the redirect URL given in the preferences of the `Square` payment method.

Uncomment the `config.square_payment_method = Spree::PaymentMethod.find(ENV['SQUARE_PAYMENT_METHOD_ID'])` line in `config/initializers/solidus_square.rb` file,

And set the `SQUARE_PAYMENT_METHOD` in order to find the preferred square payment.
### How to set the webhooks

1. Visit the [SquareDeveloper](https://developer.squareup.com/apps) website.

2. Login into your account.

3. Create or open an existing app.

4. Navigate on the left side navigation bar to `Webhooks`.

5. Click on `Add Endpoiont`.

6. Paste `<domain>/webhooks/square` in the URL field, eg. `https://www.solidus.com/webhooks/square`.

7. Select/check `payment.created` and `payment.updated` from the Events.

8. Click on `Save`.

9. Navigate to the `routes.rb` file and paste the endpoint for the webhooks.
```ruby
Spree::Core::Engine.routes.draw do
    post "webhooks/square", to: '/solidus_square/webhooks#update'
end
```
## Development

Create a Square Developer Account

- Visit https://squareup.com/signup?v=developers
- Create your application
- Go to `view details`, expand the application details and take note of `access_token`. You'll need it later to set PaymentMethod.

<img width="771" alt="Screenshot 2021-10-19 at 14 59 11" src="https://user-images.githubusercontent.com/387690/137914206-1546215b-8b1b-40e5-b9ed-4baf6daffa81.png">

### Testing the extension

First bundle your dependencies, then run `bin/rake`. `bin/rake` will default to building the dummy
app if it does not exist, then it will run specs. The dummy app can be regenerated by using
`bin/rake extension:test_app`.

```shell
bin/rake
```

To run [Rubocop](https://github.com/bbatsov/rubocop) static code analysis run

```shell
bundle exec rubocop
```

When testing your application's integration with this extension you may use its factories.
Simply add this require statement to your `spec/spec_helper.rb`:

```ruby
require 'solidus_square/testing_support/factories'
```

Or, if you are using `FactoryBot.definition_file_paths`, you can load Solidus core
factories along with this extension's factories using this statement:

```ruby
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusSquare::Engine)
```

### Running the sandbox

To run this extension in a sandboxed Solidus application, you can run `bin/sandbox`. The path for
the sandbox app is `./sandbox` and `bin/rails` will forward any Rails commands to
`sandbox/bin/rails`.

Here's an example:

```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
* Listening on tcp://127.0.0.1:3000
Use Ctrl-C to stop
```

### Updating the changelog

Before and after releases the changelog should be updated to reflect the up-to-date status of
the project:

```shell
bin/rake changelog
git add CHANGELOG.md
git commit -m "Update the changelog"
```

### Releasing new versions

Please refer to the dedicated [page](https://github.com/solidusio/solidus/wiki/How-to-release-extensions) on Solidus wiki.

## License

Copyright (c) 2021 [name of extension author], released under the New BSD License.
