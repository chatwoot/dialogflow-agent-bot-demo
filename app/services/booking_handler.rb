class BookingHandler
  pattr_initialize [:params]

  def process
    @event = params['event']
    @account = params.dig('account', 'id')
    @conversation = params.dig('conversation','id')
    if @event == "message_created"
      trigger_booking
    else
      handle_booking
    end
  end

  private
  
  def trigger_booking
    # clear redis keys
    # init  booking
    # Should send cards?
    # ChatwootClient.send_cards_message(@account, @conversation, 'cards', generate_cards)
    ChatwootClient.send_options_message(@account, @conversation, 'Select your hotel', generate_hotels)
  end

  def handle_booking
    case params["content"]
    when "Select your hotel"
      # update in redis params["content_attributes"]["submitted_values"].first["value"]
      ChatwootClient.send_options_message(@account, @conversation, 'Select your date', generate_dates)
    when "Select your date"
      ChatwootClient.send_form_message(@account, @conversation, 'Fill your details', generate_form)
    when "Fill your details"
      name = params["content_attributes"]["submitted_values"].detect {|f| f["name"] == "name" }['value']
      ChatwootClient.send_message(@account, @conversation, "Booking has been confirmed for #{name}. Let us know if there is anything else you need help with.")
    end

  end

  def generate_hotels
    # could call and fetch from api
    ['Ritz-Carlton', 'Marriott', 'Hyatt', 'Four Seasons', 'St Regis'].map { |val| { "title": val, "value": val } }
  end

  def generate_dates
    # could call and fetch from an api
    (Date.today..(Date.today + 15)).map { |val| { "title": val, "value": val } }
  end

  def generate_form
    # could call and fetch from an api
    [ { "name": "name", "placeholder": "Name", "type": "text", "label": "Name" },
      { "name": "email", "placeholder": "Email", "type": "email", "label": "Email"},
      { "name": "birthday", "placeholder": "Birthday", "type": "text", "label": "Birthday"},
      { "name": "text_area", "placeholder": "Please enter comments", "type": "text_area", "label": "Comments" },
    ]
  end

  def generate_cards
    [{
      "media_url":"https://assets.ajio.com/medias/sys_master/root/hdb/h9a/13582024212510/-1117Wx1400H-460345219-white-MODEL.jpg",
      "title":"Nike Shoes 2.0",
      "description":"Running with Nike Shoe 2.0",
      "actions":[
         {
            "type":"link",
            "text":"View More",
            "uri":"google.com"
         }
      ]
   },
   {
    "media_url":"https://assets.ajio.com/medias/sys_master/root/hdb/h9a/13582024212510/-1117Wx1400H-460345219-white-MODEL.jpg",
    "title":"Nike Shoes 2.0",
    "description":"Running with Nike Shoe 2.0",
    "actions":[
       {
          "type":"link",
          "text":"View More",
          "uri":"google.com"
       }
    ]
    }]
  end
end