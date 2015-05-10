unless Rails.env.production?
  ENV['CLIENT_ID'] = ''
  ENV['CLIENT_SECRET'] = ''
end
