class AuthHandler
  pattr_initialize [:params, :source_id, :auth_status]

  def process
    @account = params.dig("account", "id")
    @conversation = params.dig("conversation","id")

    # TODO break down to methods increase readability
    if auth_status == nil
      RedisClient.client.hset(@source_id, 'auth_status', 'pending')
      ChatwootClient.send_message(@account, @conversation, "Please enter your mobile number to start the conversation")
    elsif auth_status == 'pending'
      ChatwootClient.send_message(@account, @conversation, "Please enter the OTP sent to #{params["content"]}")
      RedisClient.client.hset(@source_id, 'auth_status' ,'otp_generated')
      # TODO dynamic otp and send it via twilio
      RedisClient.client.hset(@source_id, 'auth_code', '0000')
    elsif auth_status == 'otp_generated'
      auth_code = RedisClient.client.hget(source_id, 'auth_code')
      if auth_code == params['content']
        ChatwootClient.send_message(@account, @conversation, 'You have been verified. How can I help?')
        RedisClient.client.hset(@source_id, 'auth_status' ,'authenticated')
      else
        ChatwootClient.send_message(@account, @conversation, 'Invalid OTP. Please Enter the correct One')
      end
    end
  end
end
