task :check_inbox => :environment do
  client = Google::APIClient.new
  client.authorization.access_token = Token.last.fresh_token
  service = client.discovered_api('gmail')
  result = client.execute(
      :api_method => service.users.messages.list,
      :parameters => {'userId' => 'me', 'labelIds' => 'INBOX',},
      :headers => {'Content-Type' => 'application/json'})

  messages = JSON.parse(result.body)['messages'] || []
  messages.each do |msg|
    details=get_details(msg['id'])
    save_details(details)
  end
end

def get_details(id)
  client = Google::APIClient.new
  client.authorization.access_token = Token.last.fresh_token
  service = client.discovered_api('gmail')
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
    attachment: get_gmail_attribute(data,'body'),
    Date: get_gmail_attribute(data,'Date')
   }
end

def get_gmail_attribute(gmail_data, attribute)
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
    if gmail_data['payload']['parts'].present?
      gmail_data['payload']['parts'].each do |part|
        if part['mimeType'].eql?('text/html')
          @mes=part['body']['data']
          break
        else
          next
        end
      end
    end
    @mes
  elsif attribute.eql?('body')
    gmail_data['payload']['body']
  elsif attribute.eql?('filename')
    gmail_data['payload']['filename']
  end
end

def save_details(details)
    attachment_id=''
   attachment_data=''
    attachment_size=''
   attachment_id =  details[:attachment]["attachmentId"] if details[:attachment].has_key?("attachmentId")
   attachment_data = details[:attachment]["data"] if details[:attachment].has_key?("data")
    attachment_size = details[:attachment]["size"] if details[:attachment].has_key?("size")
   Email.create(message_id: details[:id],subject:details[:subject]  ,email_from:details[:from],thread_id:details[:threadId],
                history_id:details[:historyId],snippet:details[:snippet],message:details[:message],filename:details[:filename],
                attachment_id:attachment_id,attachment_size:attachment_size,
                attachment_data:attachment_data,recieved_date:details[:Date])
end