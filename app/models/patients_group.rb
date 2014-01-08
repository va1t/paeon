class PatientsGroup < ActiveRecord::Base
    belongs_to :patient
    belongs_to :group
    belongs_to :invoice

    has_many :iprocedures, :as => :iprocedureable, :dependent => :destroy
    accepts_nested_attributes_for :iprocedures, :allow_destroy => true, :reject_if => proc {|attributes| attributes["cpt_code"].blank?}

    has_many :codes_cpt, :through => :iprocedures
    has_many :idiagnostics, :as => :idiagable, :dependent => :destroy

    has_many :subscriber_valids, :as => :validable, :dependent => :destroy
    accepts_nested_attributes_for :subscriber_valids, :allow_destroy => true

    # relationship for invoicing; client setup
    has_many :invoice_details, :as => :idetailable, :dependent => :destroy

    #default scope hides records marked deleted
    default_scope where(:deleted => false)

    scope :billable, :conditions => ["patients_groups.invoice_id IS NULL"],
                     :include => [:patient, :group]

    # allows the skipping of callbacks to save on database loads
    # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
    cattr_accessor :skip_callbacks

    attr_accessible :patient_id, :group_id, :patient_account_number, :special_rate, :next_patient,
                    :invoiced, :invoice_id,
                    :created_user, :deleted, :updated_user,
                    :iprocedures_attributes,  #for saving nested attributes for procedure codes
                    :skip_callbacks  # made accessible to allow tests to work

    attr_accessor   :next_patient

    validates :patient_id, :presence => true, :numericality => {:only_integer => true}
    validates :group_id, :presence => true, :numericality => {:only_integer => true}

    validates :deleted, :inclusion => {:in => [true, false]}

    # cannot validate the created_user.  The record is created from the group or patients controller and it is blank until the account information
    # and the iprocedure / idiagnositic information id entered.
    # validates :created_user, :presence => true


    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do
        self.update_column(:deleted, true)
      end
    end

end
