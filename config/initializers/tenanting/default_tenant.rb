Rails.application.configure do
  # In test environment, default tenant is set in test_helper.rb
  if Rails.env.development?
    config.active_record_tenanted.default_tenant = "175932900" # Honcho
  end
end
