class ParserController < ApplicationController
  def get_unreaded_messages
    if parser_params[:username].present? && parser_params[:password].present?
      count = TeronParser.get_unreaded_messages(parser_params[:username], parser_params[:password])
      render json: { unread_messages_count: count }
    else
      render json: { error: "Something wrong" }
    end
  end

  def search_topics
    if parser_params[:query].present?
      topics = TeronParser.search_topics(parser_params[:query])
      render json: { success: true, data: topics }
    else
      render json: { error: "Something wrong" }
    end
  end

  private

  def parser_params
    params.permit(:username, :password, :query)
  end
end
