Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["CLIENT_ID"], ENV["CLIENT_SECRET"], {
      :scope =>  ['email',
                  'https://www.googleapis.com/auth/gmail.modify'],
      access_type: 'offline'}
end