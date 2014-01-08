Monalisa::Application.routes.draw do

  # root page for the application
  root :to => "home#index"

  # home page routes
  # routes are not rails restful and are explicitly defined
  get 'home/index'              => 'home#index'
  get 'home/initialbilling'     => 'home#initial_billing',       :as => 'initial_billing'
  get 'home/initialbalance'     => 'home#initial_balance',       :as => 'initial_balance'
  get 'home/initsess/:id'       => 'home#session_initial_state', :as => 'initial_session'
  get 'home/sessions/:status'   => 'home#session_status',        :as => 'session_status'
  get 'home/badsession/:status' => 'home#bad_session',           :as => 'bad_session'
  get 'home/system/:context'    => 'home#system_stats',          :as => 'system_stats'

  # maintenance screens
  get 'maint/index'
  get 'maint/notyet'

  # user logging in/out, resetting pasword will be under /user
  devise_for :users

  resources :users do
    member do
      get 'password'          # form to change password
      put 'update_password'   # update action to save new password
    end
  end

  get  'groups/search' => 'groups#ajax_search', :as => 'search_group'
  post 'groups/search' => 'groups#ajax_search', :as => 'search_group'
  resources :groups do
    resources :notes
    resources :offices
    resources :rates
    resources :provider_insurances
    get "dataerror/index" => 'dataerror#index', :as => 'dataerror'
    member do
      # for the group to provider relationship
      get 'associate'
      get 'patient_associate'
    end
  end

  get  'providers/search' => 'providers#ajax_search', :as => 'search_provider'
  post 'providers/search' => 'providers#ajax_search', :as => 'search_provider'
  resources :providers do
    resources :notes
    resources :offices
    resources :rates
    resources :provider_insurances
    get "dataerror/index" => 'dataerror#index', :as => 'dataerror'
    member do
      # for the provider to group relationship
      get 'associate'
      get 'patient_associate'
    end
  end

  # ajax handling requests for patients - changing the diagnosis drop down box
  get  'patients/ajax_diagnosis'            => 'patients#ajax_diagnosis',    :as => 'patients_ajax_diagnosis'
  # for handling the subscriber address box, same as patient
  get  'patients/subscribers/ajax_addr' => 'subscribers#ajax_addr', :as => 'patient_subscribers_ajax_addr'
  get  'patients/subscribers/ajax_subscriber' => 'subscribers#ajax_subscriber', :as => 'patient_subscribers_ajax_subscriber'
  get  'patients/search' => 'patients#ajax_search', :as => 'search_patient'
  post 'patients/search' => 'patients#ajax_search', :as => 'search_patient'
  get  'patients/check_duplicate' => 'patients#ajax_check_duplicate', :as => 'check_duplicate_patient'
  # route for working with cpt codes between provider and patient
  resources :patients do
      resources :notes
      resources :subscribers
      resources :managed_cares
      resources :patient_injuries
      #need the routes for iprocedures and idiagnostics to allow for deletes to function
      resources :iprocedures,  :only => :destroy
      resources :idiagnostics, :only => :destroy
      get 'patients_providers/:provider_id/ajax_redraw'    => 'patients#ajax_redraw', :as => 'patients_providers_ajax_redraw'
      get 'patients_groups/:group_id/ajax_redraw'          => 'patients#ajax_redraw', :as => 'patients_groups_ajax_redraw'
      get 'patients_providers/:provider_id/ajax_procedure' => 'patients#patients_providers_ajax_procedure',  :as => 'patients_providers_ajax_procedure'
      get 'patients_groups/:group_id/ajax_procedure'       => 'patients#patients_groups_ajax_procedure',     :as => 'patients_groups_ajax_procedure'
      get "dataerror/index"                                => 'dataerror#index',      :as => 'dataerror'
      member do
          get 'group_associate'
          get 'provider_associate'
          put 'update_associate'
      end
  end


  # for the patient to group relationhsip
  get  'patients_groups/ajax'          => 'patients_groups#ajax_next_patient', :as => "patients_groups_ajax"
  post 'patients_groups/ajax'          => 'patients_groups#ajax_next_patient', :as => "patients_groups_ajax"
  get  'patients_groups/search'        => 'patients_groups#ajax_search',       :as => 'search_patients_groups'
  post 'patients_groups/search'        => 'patients_groups#ajax_search',       :as => 'search_patients_groups'
  get  'patients_groups/:id'           => 'patients_groups#index',             :as => "patients_groups"
  get  'patients_groups/patients/:id'  => 'patients_groups#patient_index',     :as => "patients_groups_patients"
  resources :patients_groups,      :except => [:index, :new, :create, :show] do
      resources :iprocedures,      :except => [:index, :edit, :update, :show]
      resources :idiagnostics,     :except => [:index, :edit, :update, :show]
      resources :subscriber_valids, :except => [:index, :show, :new]
      get 'subscriber_valids/:subscriber_id/new' => 'subscriber_valids#new',   :as => 'new_subscriber_valid'
  end

  # for the patient to provider relationhsip
  get  'patients_providers/ajax'          => 'patients_providers#ajax_next_patient', :as => "patients_providers_ajax"
  post 'patients_providers/ajax'          => 'patients_providers#ajax_next_patient', :as => "patients_providers_ajax"
  get  'patients_providers/search'        => 'patients_providers#ajax_search',       :as => 'search_patients_providers'
  post 'patients_providers/search'        => 'patients_providers#ajax_search',       :as => 'search_patients_providers'
  get  'patients_providers/:id'           => 'patients_providers#index',             :as => 'patients_providers'
  get  'patients_providers/patients/:id'  => 'patients_providers#patient_index',     :as => 'patients_providers_patients'
  resources :patients_providers,   :except => [:index, :new, :create, :show] do
      resources :iprocedures,      :except => [:index, :edit, :update, :show]
      resources :idiagnostics,     :except => [:index, :edit, :update, :show]
      resources :subscriber_valids, :except => [:index, :show, :new]
      get 'subscriber_valids/:subscriber_id/new' => 'subscriber_valids#new',   :as => 'new_subscriber_valid'
  end

  get 'insurance_sessions/ajax_group'   => 'insurance_sessions#ajax_group',   :as => 'insurance_sessions_ajax_group'
  get 'insurance_sessions/ajax_patient' => 'insurance_sessions#ajax_patient', :as => 'insurance_sessions_ajax_patient'
  get 'insurance_sessions/ajax_reset'   => 'insurance_sessions#ajax_reset',   :as => 'insurance_sessions_ajax_reset'
  # ajax handling requests for patients - changing the diagnosis drop down box
  get    'insurance_billings/ajax_diagnosis'  => 'insurance_billings#ajax_diagnosis', :as => 'insurance_billings_ajax_diagnosis'
  # for handling the diagnositc codes adding and deleting
  post   'insurance_billings/:insurance_billing_id/diag_create'        => 'insurance_billings#diagnostic_create', :as => 'insurance_billings_diag_create'
  delete 'insurance_billings/:insurance_billing_id/diag_delete/:id'    => 'insurance_billings#diagnostic_delete', :as => 'insurance_billings_diag_delete'
  get    'insurance_billings/:insurance_billing_id/ajax_procedure'     => 'insurance_billings#ajax_procedure',    :as => 'insurance_billings_ajax_procedure'

  get    'insurance_billings/:insurance_billing_id/dataerror'          => 'dataerror#insurance_billing_index',    :as => 'insurance_billing_dataerror'
  get    'insurance_billings/:insurance_billing_id/dataerror/override' => 'dataerror#insurance_billing_override', :as => 'insurance_billing_override'

  resources :insurance_sessions do
    resources :notes
    resources :insurance_billings, :except => [:show, :create, :edit] do
      resources :iprocedures
      get 'secondary' => 'insurance_billings#secondary'                   # create a secondary / tertiary claim
      get 'waive'     => 'insurance_billings#waive',    :as => 'waive'    # waive the balance due and close session
      get 'unwaive'   => 'insurance_billings#unwaive',  :as => 'unwaive'  # waive the balance due and close session
      get 'balance'   => 'insurance_billings#balance',  :as => 'balance'  # balance billing
      get 'cob'       => 'insurance_billings#cob',      :as => 'cob'      # coordination of benefits
    end
    # routes for handling the balance bill records for each session
    resources :balance_bill_sessions, :except => [:index, :show] do
      get 'ajax_details'  => 'balance_bill_sessions#ajax_detail',    :as => 'ajax_detail'
    end
    resources :balance_bill_details, :only => :destroy
  end
  get "insurance_session_errors/index/:id" => 'insurance_session_errors#index',     :as => 'insurance_session_errors'

  # routes for handling the processing of balance bills and payments
  resources :balance_bills do
    get 'dataerror' => 'dataerror#balance_bill_index', :as => 'dataerror'
    resources :balance_bill_payments, :except => [:index, :show, :destroy]
  end
  get "balance_bill/ajax_select"  => "balance_bills#ajax_select", :as => "balance_bills_ajax_select"

  # balance bill workflow controller
  get "balance_bill_workflow/:id/show"    => 'balance_bill_workflow#show',        :as => "balance_bill_workflow_show"
  get "balance_bill_workflow/:id/print"   => 'balance_bill_workflow#print',       :as => "balance_bill_workflow_print"
  get "balance_bill_workflow/:id/waive"   => 'balance_bill_workflow#waive',       :as => "balance_bill_workflow_waive"
  get "balance_bill_workflow/:id/revert"  => 'balance_bill_workflow#revert',      :as => "balance_bill_workflow_revert"
  get "balance_bill_workflow/:id/close"   => 'balance_bill_workflow#close',       :as => "balance_bill_workflow_close"

  get "balance_bill_history"              => 'balance_bill_history#index',        :as => "balance_bill_history"
  get "balance_bill_history/:id/patient"  => 'balance_bill_history#patient',      :as => "balance_bill_history_patient"
  get "balance_bill_history/:id/provider" => 'balance_bill_history#provider',     :as => "balance_bill_history_provider"


  # system maintenance tables
  resources :insurance_companies
  resources :insured_types,   :except => :show
  resources :insurance_types, :except => :show
  resources :accident_types,  :except => :show
  resources :referred_types,  :except => :show
  resources :office_types,    :except => :show
  resources :codes_dsms
  resources :codes_icd9s
  resources :codes_cpts
  resources :codes_pos
  resources :codes_modifiers

  #processing controller is not rails restful; all routes are explicitly defined
  get  "processing/session_history"         => "processing#session_history"
  get  "processing/claim_ready"             => "processing#claim_ready"
  post "processing/claim_submit"            => "processing#claim_submit"
  get  "processing/claim_submitted"         => "processing#claim_submitted"
  get  "processing/claim_ready_session/:id" => "processing#claim_ready_session", :as => 'processing_session'
  get  "processing/claim_resubmit/:id"      => "processing#claim_resubmit",      :as => "processing_claim_resubmit"
  get  "processing/view_advice"             => "processing#view_advice"
  post "processing/print_claim"             => "processing#print_claim",         :as => "processing_print_claim"
  post "processing/print_balance"           => "processing#print_balance",       :as => "processing_print_balance"

  # eobs are not nested routes under insurance_sessions
  # most eobs arrive via edi and may or may not be associated to an insurance session
  get "eob/ajax_patient"        => "eobs#ajax_patient",    :as => "eob_patient"
  get "eob/ajax_claim"          => "eobs#ajax_claim",      :as => "eob_claim"
  get "eob/:id/ajax_detail"     => "eobs#ajax_detail",     :as => "eob_detail"
  get "eob/ajax_unassigned"     => "eobs#ajax_unassigned", :as => "eob_ajax_unassigned"
  get "eob_unassigned"          => "eobs#unassigned",      :as => "eob_unassigned"
  get "eob_unassigned/:id/edit" => "eobs#unassigned_edit", :as => "edit_unassigned_eob"
  get "eob/:id/showeob"         => "eobs#showeob",         :as => "eob_show_pdf"
  resources :eobs do
    resources :eob_details, :only => :destroy
    resources :notes
  end
  resources :eob_messages

  # invoice generation routes
  resources :invoices do
    resources :invoice_payments, :except => [:index, :show, :destroy]
  end
  get 'invoice/ajax_index' => 'invoices#ajax_index', :as => 'invoices_ajax_index'

  get "invoice_workflow/:id/show"   => "invoice_workflow#show",   :as => "invoice_workflow_show"
  get "invoice_workflow/:id/print"  => "invoice_workflow#print",  :as => "invoice_workflow_print"
  get "invoice_workflow/:id/waive"  => "invoice_workflow#waive",  :as => "invoice_workflow_waive"
  get "invoice_workflow/:id/revert" => "invoice_workflow#revert", :as => "invoice_workflow_revert"
  get "invoice_workflow/:id/close"  => "invoice_workflow#close",  :as => "invoice_workflow_close"

  get "invoice_history"              => 'invoice_history#index',        :as => "invoice_history"
  get "invoice_history/:id/group"    => 'invoice_history#group',        :as => "invoice_history_group"
  get "invoice_history/:id/provider" => 'invoice_history#provider',     :as => "invoice_history_provider"

  # invoice maintenance routes
  resources :invoice_maintenance, :only => [:index, :update]
  get 'invoice_maintenance/ajax_index' => 'invoice_maintenance#ajax_index', :as => 'invoice_maintenance_ajax_index'
  get "invoice_maintenance/show"
  get "invoice_maintenance/print"

  resources :edi_vendors, :except => [:new, :create, :destroy]
  get 'edi_vendors/test/:id' => 'edi_vendors#test_connection',  :as => 'test_edi_vendor'

  resources :edi_segment_error_codes, :except => :show
  resources :system_infos, :only => [:index, :edit, :update]

  resources :reporting, :only => :index
  namespace :reports do
    resources :open_dos_rpt, :only => :index
  end
  get 'reporting/ajax_category' => 'reporting#ajax_category', :as => 'reporting_ajax_category'
  get 'reporting/ajax_report'   => 'reporting#ajax_report',   :as => 'reporting_ajax_report'

end


