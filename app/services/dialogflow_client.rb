class DialogflowClient
  def self.get_response(session_id, message)
    session_client = Google::Cloud::Dialogflow.sessions
    session = session_client.session_path project: ENV.fetch('DIALOGFLOW_PROJECT_ID'), session: session_id
    query_input = { text: { text: message, language_code: 'en-US' } }
    response = session_client.detect_intent session: session, query_input: query_input
    response.query_result['fulfillment_text']
  end
end
