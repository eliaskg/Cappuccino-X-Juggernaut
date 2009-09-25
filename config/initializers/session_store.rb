# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_juggernautoccino_session',
  :secret      => '6ac2dfaa1965d3012b1309433851aa7119d7468ba892c4dc9de4457c5656fc3e188b5129000ff84d116829e02202923e89b6a8c69e916ef608d4ac53b5cd7cf5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
