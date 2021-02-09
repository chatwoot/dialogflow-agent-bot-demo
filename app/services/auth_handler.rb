class AuthHandler
  pattr_initialize [:params, :source_id, :auth_status]

  def process
    @account = params.dig('account', 'id')
    @conversation = params.dig('conversation','id')

    case auth_status
    when nil
      prompt_auth_via_phone
    when 'pending'
      set_up_and_send_otp
    when 'otp_generated'
      validate_otp
    end
  end

  private
  
  def prompt_auth_via_phone
    RedisClient.client.hset(@source_id, 'auth_status', 'pending')
    ChatwootClient.send_message(@account, @conversation, 'Please enter your mobile number to start the conversation')
  end

  def set_up_and_send_otp
    ChatwootClient.send_message(@account, @conversation, "Please enter the OTP sent to #{params["content"]}")
    RedisClient.client.hset(@source_id, 'auth_status', 'otp_generated')
    # TODO: dynamic otp generation and send it actually via twilio
    RedisClient.client.hset(@source_id, 'auth_code', '0000')
  end

  def validate_otp
    auth_code = RedisClient.client.hget(source_id, 'auth_code')
    if auth_code == params['content']
      ChatwootClient.send_message(@account, @conversation, 'You have been verified. How can I help?')
      RedisClient.client.hset(@source_id, 'auth_status' ,'authenticated')
    else
      ChatwootClient.send_message(@account, @conversation, 'Invalid OTP. Please Enter the correct One')
    end
  end
end
