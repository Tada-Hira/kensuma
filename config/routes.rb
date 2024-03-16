# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # admin関連=========================================================
  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # =================================================================

  # user関連==========================================================
  devise_scope :user do
    root 'users/sessions#new'
  end

  devise_for :users, controllers: {
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    confirmations: 'users/confirmations',
    registrations: 'users/registrations',
    invitations:   'users/invitations'
  }

  namespace :users do
    resources :cars, param: :uuid
    resources :special_vehicles, param: :uuid do
      delete 'destroy_image'
    end
    resources :cars, except: %i[index create new show edit update destroy] do
      patch 'update_images'
    end
    resources :general_users
    resources :subcon_users, only: %i[index] do
      member do
        patch 'approval'
        delete 'destroy_invited_pending'
        delete 'destroy_invitation_pending'
        delete 'destroy_invited'
      end
    end
    resources :dash_boards, only: [:index]
    resources :articles, only: %i[index show]
    resources :news, only: %i[index show], param: :uuid
    resource :profile, except: %i[create new]
    resources :machines, param: :uuid
    resources :solvents, param: :uuid
    resource :business, except: %i[index destroy] do
      patch 'update_stamp_images'
      patch 'delete_career_up_card_copy'
      get 'occupation_select'
    end
    resources :workers, param: :uuid
    resources :workers, except: %i[index create new show edit update destroy] do
      patch 'update_workerlicense_images'
      patch 'update_worker_safety_health_education_images'
      patch 'update_workerskilltraining_images'
      patch 'update_workerspecialeducation_images'
      patch 'update_workerexam_images'
      patch 'update_health_insurance_image'
      patch 'update_career_up_images'
      patch 'delete_seal'
      patch 'update_passports'
      patch 'update_residence_cards'
      patch 'update_employment_conditions'
      patch 'update_employee_cards'
      patch 'update_driver_licenses_cards'
    end
    resources :orders, param: :site_uu_id do
      member do
        patch :system_chart_status
        patch :edit_status
      end
      resources :field_cars, except: %i[new show edit update], module: :orders, param: :uuid do
        collection do
          get 'edit_cars'
          patch 'update_cars'
        end
      end
      resources :field_fires, except: :index, module: :orders, param: :uuid
      resources :field_machines, except: %i[new show edit update], module: :orders, param: :uuid do
        collection do
          get 'edit_machines'
          patch 'update_machines'
        end
      end
      resources :field_special_vehicles, except: %i[new show edit update], module: :orders, param: :uuid do
        collection do
          get 'edit_special_vehicles'
          patch 'update_special_vehicles'
        end
      end
      resources :field_workers, except: %i[new show edit update], module: :orders, param: :uuid do
        collection do
          get 'edit_workers'
          patch 'update_workers'
          delete 'destroy_image'
        end
      end
    end
    # get 'orders/:order_site_uu_id/field_solvents/:uuid/set_solvent_name_one', to: 'users/orders/field_solvents#edit_set_solvent_name_one', as: :set_solvent_name_one_users_order_field_solvents
    resources :request_orders, only: %i[show edit update], param: :uuid do
      resources :sub_request_orders, except: %i[edit destroy show], param: :uuid do
        resources :documents, only: %i[show edit update], param: :uuid, controller: 'sub_request_orders/documents'
      end
      resources :documents, only: %i[show edit update], param: :uuid
      resources :field_cars, except: %i[new show edit update], module: :request_orders, param: :uuid do
        collection do
          get 'edit_cars'
          patch 'update_cars'
        end
      end
      resources :field_fires, except: :index, module: :request_orders, param: :uuid
      resources :field_machines, except: %i[new show edit update], module: :request_orders, param: :uuid do
        collection do
          get 'edit_machines'
          patch 'update_machines'
        end
      end
      resources :field_solvents, except: :index, module: :request_orders, param: :uuid do
        get 'set_solvent_name_one', to: 'field_solvents#set_solvent_name_one'
        get 'set_solvent_name_two', to: 'field_solvents#set_solvent_name_two'
        get 'set_solvent_name_three', to: 'field_solvents#set_solvent_name_three'
        get 'set_solvent_name_four', to: 'field_solvents#set_solvent_name_four'
        get 'set_solvent_name_five', to: 'field_solvents#set_solvent_name_five'
        patch 'update_sds_images'
        patch 'update_ventilation_control_images'
        patch 'update_working_process_images'
        collection do
          get 'set_solvent_name_one'
          get 'set_solvent_name_two'
          get 'set_solvent_name_three'
          get 'set_solvent_name_four'
          get 'set_solvent_name_five'
        end
      end
      resources :field_special_vehicles, except: %i[new show edit update], module: :request_orders, param: :uuid do
        collection do
          get 'edit_special_vehicles'
          patch 'update_special_vehicles'
          get 'dr_license_select', to: 'field_special_vehicles#dr_license_select'
        end
      end
      resources :field_workers, except: %i[new show edit update], module: :request_orders, param: :uuid do
        collection do
          get 'edit_workers'
          patch 'update_workers'
          delete 'destroy_image'
        end
      end
    end
    post 'request_orders/:uuid/submit', to: 'request_orders#submit', as: :request_order_submit
    post 'request_orders/:uuid/sub_request_orders/:sub_request_uuid/fix_request', to: 'request_orders#fix_request', as: :request_order_fix_request
    post 'request_orders/:uuid/sub_request_orders/:sub_request_uuid/approve', to: 'request_orders#approve', as: :request_order_approve
    get 'request_orders/:uuid/edit_approval_status', to: 'request_orders#edit_approval_status', as: :request_order_edit_approval_status
    post 'request_orders/:uuid/update_approval_status', to: 'request_orders#update_approval_status', as: :request_order_update_approval_status

    get '/professional_engineer_1st_skill_training_options', to: 'orders#professional_engineer_1st_skill_training_options'
    get '/professional_engineer_2nd_skill_training_options', to: 'orders#professional_engineer_2nd_skill_training_options'
    get '/supervising_engineer_skill_training_options', to: 'orders#supervising_engineer_skill_training_options'
    get '/supervising_engineer_assistant_skill_training_options', to: 'orders#supervising_engineer_assistant_skill_training_options'

    get '/professional_engineer_skill_training_options', to: 'request_orders#professional_engineer_skill_training_options'
    get '/lead_engineer_skill_training_options', to: 'request_orders#lead_engineer_skill_training_options'
    get '/registered_core_engineer_license_options', to: 'request_orders#registered_core_engineer_license_options'
  end
  # =================================================================

  # manager関連=======================================================
  # devise_for :managers, controllers: {
  #   sessions:      'managers/sessions',
  #   passwords:     'managers/passwords',
  #   confirmations: 'users/confirmations',
  #   registrations: 'managers/registrations'
  # }

  # =================================================================

  # system==============================================================
  # 利用規約
  get 'use' => 'system#use'
  # 特商法
  get 'law' => 'system#law'
  # プライバシーポリシー
  get 'privacy_policy' => 'system#privacy_policy'
  # =================================================================
end
