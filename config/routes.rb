Rails.application.routes.draw do
  root 'application#index'
  get 'log' => 'application#transaction_log'

  scope 'recurring_transactions' do
    get '' => 'recurring_transactions#index', as: 'recurring_transactions'
    post '' => 'recurring_transactions#create', as: 'create_recurring_transaction'
    patch ':id' => 'recurring_transactions#update', as: 'update_recurring_transaction'
    get ':id' => 'recurring_transactions#destroy', as: 'destroy_recurring_transaction'
  end

  scope 'configuration' do
    get '' => 'configuration#index', as: 'configuration'
    post 'categories/create' => 'configuration#create_category', as: 'create_category'
    patch 'categories/update/:id' => 'configuration#update_category', as: 'update_category'
    get 'categories/destroy' => 'configuration#destroy_category', as: 'destroy_category'
  end
end
