class BotController < ApplicationController
  def index
    render json: { sucess: true }
  end

  def handler
    RequestHandler.new(params: params).process
    render json: { sucess: true }
  end
end
