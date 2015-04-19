class EmailController < ApplicationController
  require 'json'
  require 'base64'
  layout false, only: :show_email
  before_filter :authenticate!, :current_user
  def index
    email=Email.where(user: @current_user).group(:email_from).count.select
    write_json(email)
  end

  def today
   email=Email.where(user: @current_user).where('recieved_date > ?', Date.today).group(:email_from).count.select
    write_json(email)
   respond_to do |format|
     format.html
     format.js
   end
  end

  def yesterday
    email=Email.where(user: @current_user).where('recieved_date < ? and recieved_date > ? ', Date.today,Date.yesterday).group(:email_from).count.select
    write_json(email)
  end

  def last_week
    email=Email.where(user: @current_user).where('recieved_date > ? ', Date.today.beginning_of_week).group(:email_from).count.select
    write_json(email)
  end

  def show
      @messages= Email.where(user: @current_user ,email_from: params[:id]).order(recieved_date: :desc)
  end

  def show_email
     @message= Email.where(user: @current_user, message_id: params[:message_id]).first
  end

  private
  def write_json(email)
    File.open("public/temp.json","w") do |f|
      f.write('{"children": [')
      email.each do |k,v|
        f.write("{\"name\": #{k.to_json},")
        f.write('"children": [')
        f.write("{\"name\": #{k.to_json},")
        f.write("\"size\": #{v.to_json}}")
        f.write(']}')
        f.write(',') unless email.to_a.last.first.eql? k
      end
      f.write(']}')
      end
  end
  def authenticate!
    unless session[:user]
      flash[:notice]="Please login to continue."
      redirect_to root_path
    end
  end

  def current_user
    @current_user = session[:user]
  end


end


