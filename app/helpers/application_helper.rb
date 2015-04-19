module ApplicationHelper
  def user_logged_in?
    if session[:user]
      true
    else
      false
    end
  end
end