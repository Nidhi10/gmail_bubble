class SessionsController < ApplicationController
  layout 'login'
  def new
  end

  def create
    @auth = request.env['omniauth.auth']['credentials']
=begin
    Token.create(
        access_token: @auth['token'],
        refresh_token: @auth['refresh_token'],
        expires_at: Time.at(@auth['expires_at']).to_datetime)
        FetchEmails.perform_async( @auth['token'])
=end
    #session[:auth_token]=@auth['token']
    client = Google::APIClient.new
    client.authorization.access_token = @auth['token']
    service = client.discovered_api('gmail')
    session[:user]=(JSON.parse((client.execute(
        :api_method => service.users.get_profile,
        :parameters => {'userId' => 'me'})).body))['emailAddress']

    FetchEmails.perform_async( @auth['token'],session[:user])
    redirect_to :email_index
  end

  def destroy
    if session[:user]
      reset_session
      redirect_to root_path, notice: 'Successfully Signed out!'
    end
  end
 end