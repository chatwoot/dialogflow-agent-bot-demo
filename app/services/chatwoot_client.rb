class ChatwootClient
  def self.send_message(account, conversation, message)
    post("/api/v1/accounts/#{account}/conversations/#{conversation}/messages", { content: message })
  end

  def self.send_options_message(account, conversation, message, items)
    post(
      "/api/v1/accounts/#{account}/conversations/#{conversation}/messages",
      "content": message,
      "content_type": 'input_select',
      "content_attributes": {
        "items": items
      }
    )
  end

  def self.send_form_message(account, conversation, message, items)
    post(
      "/api/v1/accounts/#{account}/conversations/#{conversation}/messages",
      "content": message,
      "content_type": 'form',
      "content_attributes": {
        "items": items
      }
    )
  end

  def self.send_cards_message(account, conversation, message, items)
    post(
      "/api/v1/accounts/#{account}/conversations/#{conversation}/messages",
      "content": message,
      "content_type": 'cards',
      "content_attributes": {
        "items": items
      }
    )
  end

  def self.handoff_conversation(account, conversation, status='open')
    post("/api/v1/accounts/#{account}/conversations/#{conversation}/toggle_status", { status: status })
  end


  def self.post(url, payload)
    RestClient.post("#{ENV.fetch('CHATWOOT_URL', 'http://localhost:3000')}/#{url}", payload.to_json, { content_type: :json, accept: :json, api_access_token: ENV.fetch('AGENT_BOT_TOKEN') })
  rescue *ExceptionList::REST_CLIENT_EXCEPTIONS, *ExceptionList::URI_EXCEPTIONS => e
    Rails.logger.info "URL Exception: #{e.message}"
  rescue StandardError => e
    Rails.logger.info "Exception: #{e.message}"
  end
end
