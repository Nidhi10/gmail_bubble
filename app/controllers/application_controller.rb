class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :user_logged_in?, :current_user

  def authenticate!
    unless user_logged_in?
      flash[:notice]="Please login to continue."
      redirect_to root_path
    end
  end

  def user_logged_in?
    if session[:user]
      true
    else
      false
    end
  end

  def current_user
    session[:user]
  end
end
