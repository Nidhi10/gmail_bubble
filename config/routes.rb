Rails.application.routes.draw do
  root to: 'sessions#new'
  resources :sessions ,only: [:new, :create] do
    collection do
      delete 'logout' => :destroy
    end
  end
  get "/auth/:provider/callback" => 'sessions#create'
  get 'email/index'
  get 'email/today'
  get 'email/yesterday'
  get 'email/last_week'
  get '/email/:id', to: 'email#show' , :constraints => { :id => /.+@.+\..*/ }
  get '/email/show_email/:message_id', to: 'email#show_email', as: 'show_email'

end
