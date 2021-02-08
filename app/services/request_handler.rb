class RequestHandler
  pattr_initialize [:params!]

  def process
    @event = params['event']
    @account = params.dig('account', 'id')
    @conversation = params.dig('conversation','id')
    handle_event
  end

  private


  def handle_event
    case @event
    when 'message_created'
      handle_message_created if params['message_type'] == 'incoming' && params.dig('conversation','status') == 'bot'
    when 'message_updated'
      handle_message_updated
    else 
      print 'Event not handled'
    end
  end

  def handle_message_created
    source_id = params['conversation']['contact_inbox']['source_id']

    auth_status = RedisClient.client.hget(source_id, 'auth_status')
    if auth_status != 'authenticated'
      AuthHandler.new( params: @params, auth_status: auth_status, source_id: source_id).process
      return
    end

    send_response_for_content(source_id, params[:content])
  end

  def send_response_for_content(source_id, content)
    response = DialogflowClient.get_response(source_id, content)

    case response
    when '__handoff__'
      ChatwootClient.send_message(@account, @conversation, 'Transfering the conversation to an agent. You will get a response shortly.')
      ChatwootClient.handoff_conversation(@account, @conversation)
    when '__booking__'
      ChatwootClient.send_message(@account, @conversation, 'Initiating a booking')
      BookingHandler.new(params: @params).process
    else
      ChatwootClient.send_message(@account, @conversation, response)
    end
  end

  def handle_message_updated
    BookingHandler.new(params: @params).process
  end
end
