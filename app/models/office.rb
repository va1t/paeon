class Office < ActiveRecord::Base
    belongs_to :officeable, :polymorphic => true
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy

    has_many :insurance_sessions

    #default scope hides records marked deleted
    default_scope where(:deleted => false)

    after_save :validate_data

    attr_accessible :officeable_type, :officeable_id, :address1, :address2, :city, :office_name, :office_fax, :office_phone,
                    :priority, :second_phone, :state, :third_phone, :zip, :billing_location, :service_location,
                    :created_user, :updated_user, :deleted

    validates :address1, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    validates :address2, :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :city,  :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_MED_LENGTH }
    validates :state, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_SML_LENGTH }
    validates :zip, :format => {:with => REGEX_ZIP },
                    :length => {:minimum => ZIP_MIN_LENGTH, :maximum => ZIP_MAX_LENGTH }

    validates :office_phone, :format => {:with => REGEX_PHONE }, :allow_nil => true, :allow_blank => true,
                             :length => {:maximum => PHONE_MAX_LENGTH }
    validates :office_fax,   :format => {:with => REGEX_PHONE }, :allow_nil => true, :allow_blank => true,
                             :length => {:maximum => PHONE_MAX_LENGTH }
    validates :second_phone, :format => {:with => REGEX_PHONE }, :allow_nil => true, :allow_blank => true,
                             :length => {:maximum => PHONE_MAX_LENGTH }
    validates :third_phone,  :format => {:with => REGEX_PHONE }, :allow_nil => true, :allow_blank => true,
                             :length => {:maximum => PHONE_MAX_LENGTH }

    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true


    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do
        self.update_column(:deleted, true)
      end
    end


    def office_location
      "#{priority}, #{!office_name.blank? ? office_name + ',' : ''} #{city}, #{state}"
    end


    # check_data is a validation routine for the claim to ensure each session record is ready for submission
    # returns a message array of errors.  if no errors it returns an empty array.
    # each model checks the fields within itself for completeness.
    # insurance billing has the ties to all the various records for a claim and can check all relationships required.
    def validate_data
      @state = true
      #store the original error count, if there is a chnage to the count, then we want to update all associated insurance_billings and balance_bills
      @original_count = self.dataerrors.count
      #first remove any old errors from the table
      self.dataerrors.clear

      @s = []
      # check the necessary fields in the table
      # use the build method so the polymorphic reference is generated cleanly
      @s.push self.dataerrors.build(:message => "An Address is required", :created_user => self.created_user) if self.address1.blank?
      @s.push self.dataerrors.build(:message => "A city is required as part of the address", :created_user => self.created_user) if self.city.blank?
      @s.push self.dataerrors.build(:message => "The state is reuqired as part oof the address", :created_user => self.created_user) if self.state.blank?
      @s.push self.dataerrors.build(:message => "The zip code is required", :created_user => self.created_user) if self.zip.blank?
      @s.push self.dataerrors.build(:message => "Office phone number is required", :created_user => self.created_user) if self.office_phone.blank?

      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s)
        @state = false
      end

      #if the error counts changed, then update all insurance_bill & balance bills
      if @original_count != @s.count
        self.insurance_sessions.each { |session| session.validate_data }
      end
      return @state
    end

end
