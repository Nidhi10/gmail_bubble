class SessionsController < ApplicationController
  layout 'login'
  def new
  end

  def create
    @auth = request.env['omniauth.auth']
    session[:user]=@auth[:info][:email]
    FetchEmails.perform_async(@auth['credentials']['token'],session[:user])
    redirect_to :email_index
  end

  def destroy
    if user_logged_in?
      reset_session
      redirect_to root_path, notice: 'Successfully Signed out!'
    end
  end
 end