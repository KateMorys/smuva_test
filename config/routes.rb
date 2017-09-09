Rails.application.routes.draw do
  get "get_unreaded_messages" => 'parser#get_unreaded_messages'
end
