# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

VAT_DEFAULT = ENV['vat_default'].to_d
