Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "get_unreaded_messages" => 'parser#get_unreaded_messages'
end
