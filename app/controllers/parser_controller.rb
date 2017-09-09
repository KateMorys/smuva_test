class ParserController < ApplicationController
  def get_unreaded_messages
    if params[:username].present? && params[:password].present?
      count = TeronParser.get_unreaded_messages(params[:username], params[:password])
      render json: { unread_messages_count: count }
    else
      render json: { error: "Something wrong" }
    end
  end
end
