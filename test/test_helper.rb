# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir[Rails.root.join('test', 'support', '**', '*.rb')].each { |f| require f }

class ActiveSupport::TestCase
  include Chewy::Minitest::Helpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Wrap every test in Chewy :bypass strategy
  def self.test(test_name, &block)
    return super if block.nil?

    super(test_name) do
      Chewy.strategy(:bypass) do
        instance_eval(&block)
      end
    end
  end

  # Monkey patch the `before_setup` DSL to enable VCR and configure a cassette named
  # based on the test method and grab anything in the setup block. This means that a test written like this:
  #
  # class OrderTest < ActiveSupport::TestCase
  #   test 'user can place an order' do
  #     ...
  #   end
  # end
  #
  # will automatically use VCR to intercept and record/play back any external
  # HTTP requests using `fixtures/cassettes/order_test/test_user_can_place_order.json`.
  def before_setup
    base_path = self.class.name.underscore
    VCR.insert_cassette(base_path + '/' + name)

    Chewy.strategy(:bypass) do
      super
    end
  end

  def after_teardown
    Chewy.strategy(:bypass) do
      super
    end

    VCR.eject_cassette
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
