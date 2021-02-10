# Chatwoot Agent Bot Implementation using DialogFlow

This repo contains a sample rails api which acts an agent bot and showcases an example use case of hotel booking via bot
It relies on google dialogflow to for its NLP processing and makes use of bot messages in chatwoot to deliver a rich experiance. 

[Learn more about agent bots](https://github.com/chatwoot/chatwoot/wiki/Building-on-Top-of-Chatwoot:-Agent-Bots)


## Getting Started on Local

### Set up Dialogflow

1) Create a google cloud Project [ Unless you already have one]
2) Create a Dialogflow ES Bot under the project
3) Go to small talk and enable the small talk
4) Go to Intents and import the given intenets in `dialogflow_intents` folder in this repo. 
   
### Setup Chatwoot installation
1) Create an AgentBot by running the following in your chatwoot rails console
```
bot = AgentBot.create!(name: "Booking Bot", outgoing_url: "http://localhost:4000")
AgentBotInbox.create!(inbox: Inbox.first, agent_bot: bot)
# returns the token
bot.access_token.token

# if you want to update the image of the bot
avatar_resource = LocalResource.new("your image url")
AgentBot.first.avatar.attach(io: avatar_resource.file, filename: avatar_resource.tmp_filename, content_type: avatar_resource.encoding)
```   
### Setting Up the Repo 
1) Clone the repo to your local
2) Copy `.env.example` to `.env` and update the values as mentions
3) run `rails s -p 4000`


You should be able to connect to the agent Bot from 'localchatwooturl/widget_tests` and test the bot out

## Deploying for production


### Deploying to Google Cloud run
#### Setup Chatwoot Production instance
run following on your production Chatwoot Instance to set up the agent bot

```
  bot = AgentBot.create!(name: "Booking Bot", outgoing_url: "http://localhost:4000")
  # choose your inbox instead of Inbox.first
  AgentBotInbox.create!(inbox: Inbox.first, agent_bot: bot)
  # returns the token
  bot.access_token.token

  # if you want to update the image of the bot
  avatar_resource = LocalResource.new("your image url")
  AgentBot.first.avatar.attach(io: avatar_resource.file, filename: avatar_resource.tmp_filename, content_type: avatar_resource.encoding)
```


#### Create a new cloud run 

1) Run the following and generate an image for google cloud
```
# replace project_id with your id
gcloud config set project $PROJECT_ID
gcloud builds submit --tag gcr.io/$PROJECT_ID/agent_bot
```
2) Go to cloud run and click create new service
3) Choose the region and service name
![1](https://user-images.githubusercontent.com/73185/107521780-f7d56f00-6bd8-11eb-95f6-ca82b2e909f4.png)

4) Choose the agent_bot image upload now, and toggle advanced settings 

![3](https://user-images.githubusercontent.com/73185/107521914-1cc9e200-6bd9-11eb-8564-e623688a3f24.png)

5) Add the environment variables as required by `.env.example`

![2 copy](https://user-images.githubusercontent.com/73185/107522304-94980c80-6bd9-11eb-98a0-66712accf66e.png)

6) Allow all traffic and unauthenticated requests

![4](https://user-images.githubusercontent.com/73185/107522039-42ef8200-6bd9-11eb-838e-47a3cc1b5752.png)

7) Click Deploy 

#### Update your chatwoot Agent Bot with the cloud run url
run the following in your console 
```
# chose agent bot
bot = AgentBot.first
bot.outgoing_url = "your cloud run url"
bot.save!
```

### Other Providers

Build a docker image using the provided docker file.  Deploy with the required environment variables provided
