class FetchEmails

  include Sidekiq::Worker

  def perform(token,user)
    client = Google::APIClient.new
    client.authorization.access_token = token
    service = client.discovered_api('gmail')
    result = client.execute(
        :api_method => service.users.messages.list,
        :parameters => {'userId' => 'me', 'labelIds' => 'INBOX',},
        :headers => {'Content-Type' => 'application/json'})

    messages = JSON.parse(result.body)['messages'] || []
    messages.each do |msg|
      details=get_details(msg['id'],client,service)
      save_details(details,user)
    end
    message = {:channel => "/messages/new", :data => ["messages" => messages.count].to_json}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)

  end

  private


  def get_details(id,client,service)
  result = client.execute(
      :api_method => service.users.messages.get,
      :parameters => {'userId' => 'me', 'id' => id, 'format' => 'full'},
      :headers => {'Content-Type' => 'application/json'})
  data = JSON.parse(result.body)
  { id: id,
    subject: get_gmail_attribute(data, 'Subject'),
    from: get_gmail_attribute(data, 'From'),
    threadId: get_gmail_attribute(data, 'threadId'),
    historyId: get_gmail_attribute(data,'historyId'),
    snippet: get_gmail_attribute(data,'snippet'),
    message: get_gmail_attribute(data,'data'),
    filename: get_gmail_attribute(data,'filename'),
    Date: get_gmail_attribute(data,'Date')
  }
end

  def get_gmail_attribute(gmail_data, attribute,client=nil,service=nil,id=nil)
    if ['From','Subject','Date'].include?(attribute)
      headers = gmail_data['payload']['headers']
      array = headers.reject { |hash| hash['name'] != attribute }
      array.first['value']
    elsif attribute.eql?('historyId')
      gmail_data['historyId']
    elsif attribute.eql?('snippet')
      gmail_data['snippet']
    elsif attribute.eql?('threadId')
      gmail_data['threadId']
    elsif attribute.eql?('data')
      if gmail_data['payload']['mimeType']=~ /multipart(.*)/
        gmail_data['payload']['parts'].each do |part|
          if part['mimeType'].eql?('text/html')
            @mes=part['body']['data']
            break
          else
            next
          end
        end
        @mes
      else
        gmail_data['payload']['body']['data']
      end
    elsif attribute.eql?('filename')
      gmail_data['payload']['filename']
    end
  end

  def save_details(details,user)
    Email.create(message_id: details[:id],subject:details[:subject]  ,email_from:details[:from],thread_id:details[:threadId],
                 history_id:details[:historyId],snippet:details[:snippet],message:details[:message],filename:details[:filename],
                 recieved_date:details[:Date],user:user)
  end
end