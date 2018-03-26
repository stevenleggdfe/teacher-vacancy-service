Rails.application.routes.draw do
  root 'vacancies#index'

  get 'check' => 'application#check'

  resources :vacancies, only: %i[index show]
  resource :sessions, controller: 'hiring_staff/sessions'
  resources :schools, only: %i[index show edit update], controller: 'hiring_staff/schools' do
    get 'search', on: :collection
    resources :vacancies, only: %i[new index destroy delete show], controller: 'hiring_staff/vacancies' do
      get 'review'
      get 'summary'
      post :publish, to: 'hiring_staff/vacancies/publish#create'
    end

    resource :vacancy, only: [] do
      get :job_specification, to: 'hiring_staff/vacancies/job_specification#new'
      post :job_specification, to: 'hiring_staff/vacancies/job_specification#create'
      get :candidate_specification, to: 'hiring_staff/vacancies/candidate_specification#new'
      post :candidate_specification, to: 'hiring_staff/vacancies/candidate_specification#create'
      get :application_details, to: 'hiring_staff/vacancies/application_details#new'
      post :application_details, to: 'hiring_staff/vacancies/application_details#create'
    end
  end

  match '*path', to: 'application#not_found', via: %i[get post patch put destroy]
end
