# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_foobar_session',
  :secret      => '97334ed97f020d586e5ae8ae874ad821a43ad01c18324bafd9a6cdf8b0ac3cfd9e4b903b754217d7953159c8661a664004f203501e65803c30ffb87c99a52331'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
