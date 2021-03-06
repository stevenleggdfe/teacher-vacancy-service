
if Rails.env.test?
  DFE_SIGN_IN_URL = 'https://test-url.local'.freeze
  DFE_SIGN_IN_PASSWORD = 'test-password'.freeze
  DFE_SIGN_IN_SERVICE_ID = 'test-service-id'.freeze
  DFE_SIGN_IN_SERVICE_ACCESS_ROLE_ID = 'test-role-id'.freeze
else
  DFE_SIGN_IN_URL = ENV['DFE_SIGN_IN_URL']
  DFE_SIGN_IN_PASSWORD = ENV['DFE_SIGN_IN_PASSWORD']
  DFE_SIGN_IN_SERVICE_ID = ENV['DFE_SIGN_IN_SERVICE_ID']
  DFE_SIGN_IN_SERVICE_ACCESS_ROLE_ID = ENV['DFE_SIGN_IN_SERVICE_ACCESS_ROLE_ID']
end
