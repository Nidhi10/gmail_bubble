class EmailController < ApplicationController
  require 'json'
  require 'base64'
  layout false, only: :show_email
  def index
    email=Email.group(:email_from).count.select
    write_json(email)
  end

  def today
   email=Email.where('recieved_date > ?', Date.today).group(:email_from).count.select
    write_json(email)
   respond_to do |format|
     format.html
     format.js
   end
  end

  def yesterday
    email=Email.where('recieved_date < ? and recieved_date > ? ', Date.today,Date.yesterday).group(:email_from).count.select
    write_json(email)
  end

  def last_week
    email=Email.where('recieved_date > ? ', Date.today.beginning_of_week).group(:email_from).count.select
    write_json(email)
  end

  def show
      @messages= Email.where(email_from: params[:id]).order(recieved_date: :desc)
  end

  def show_email
     @message= Email.where(message_id: params[:message_id]).first
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
end
