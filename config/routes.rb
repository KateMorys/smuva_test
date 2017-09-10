Rails.application.routes.draw do
  get "get_unreaded_messages" => 'parser#get_unreaded_messages'
  get "search_topics" => 'parser#search_topics'
end
