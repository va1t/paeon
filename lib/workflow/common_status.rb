#
#
# common state module for handling state machine for all models, include this file in the model for use.
# All models share the four states :active, :deleted, :archived and :permanent
# not all models utilize the :permanent state
#
# All models including the common_state must have a :string, :state, :limit => 25
# do not add :state to attr_accessible. :state field can only be updated through this module
#
# module should not be included into other workflow modules.  Rules governing if other workflows allow
# records to be deleteable? or archiveable? will be different
#
#
module CommonStatus

  attr_accessor :perm

  def self.included(base)
    base.state_machine :status, :initial => :active do
      #
      # define all states with intrinsic value
      #
      state :active,    :value => 'Active'
      state :deleted,   :value => 'Deleted'
      state :archived,  :value => 'Archived'
      state :permanent, :value => 'Permanent'
      state :nil_field, :value => nil       # for adding status to existing records, allow a null status so rake task can set it to default

      #
      # define events and transitions
      #

      # initializes record to the begining state.
      # used primarliy for setting existing records to the initial state
      event :init_record do
        transition all => :active
      end

      # active, archived and deleted states can be deleted.
      # permanent states cannot be deleted
      event :delete_record do
        transition [:active, :archived, :deleted] => :deleted
      end

      # deleted, :active states can be undeleted
      event :undelete_record do
        transition [:deleted, :active] => :active
      end

      # active, archived states can be archived.
      event :archive_record do
        transition [:active, :archived] => :archived
      end

      # archived, active states can be unarchived
      event :unarchive_record do
        transition [:archived, :active] => :active
      end

      # active, permanent states can be locked permanent
      # archived or deleted state must first be unarchived or undeleted
      event :lock_record do
        transition [:active, :permanent] => :permanent
      end

      # permanent, active states can be unlocked
      event :unlock_record do
        transition [:permanent, :active] => :active
      end

      #
      # define after_failure callbacks
      #

      after_failure :on => :delete_record do |cs, transition|
        Rails.logger.info "CommonStatus: Record is locked permanent and cannot be deleted; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is locked permanent and cannot be deleted"
      end

      after_failure :on => :undelete_record do |cs, transition|
        Rails.logger.info "CommonStatus: Record is not deleted; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not deleted"
      end

      after_failure :on => :archive_record do |cs, transition|
        Rails.logger.info "CommonStatus: Record is either deleted or permanent and cannot be archived; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is either deleted or permanent and cannot be archived"
      end

      after_failure :on => :unarchive_record do |cs, transition|
        Rails.logger.info "CommonStatus: Record is not archived and cannot be unarchived; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not archived and cannot be unarchived"
      end

      after_failure :on => :lock_record do |cs, transition|
        Rails.logger.info "CommonStatus: Record is either deleted or archived and cannot be locked permanent; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is either deleted or archived and cannot be locked permanent"
      end

      after_failure :on => :unlock_record do |cs, transition|
        Rails.logger.info "CommonStatus: Record is not locked permanent and cannot be unlocked; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not locked permanent and cannot be unlocked"
      end

    end
  end

  #
  # common methods available to models
  #

  # override the destroy method to set the state
  # do not want to destroy records. Only set the state
  def destroy
    run_callbacks :destroy do
      self.delete_record
    end
  end


  # if the record is :active, :archived or :deleted then it can be deleted, returns true
  def deleteable?
    self.status?(:active) || self.status?(:deleted) || self.status?(:archived)
  end


  # if the record is active or archived, returns true
  def archiveable?
    self.status?(:active) || self.status?(:archived)
  end


  # if the record is active or permanent, returns true
  def lockable?
    self.status?(:active) || self.status?(:permanent)
  end


  # if the record is permanent, returns true
  def locked?
    self.status?(:permanent)
  end

  #
  # initialize the permanent accessor when creating the object
  # this accessor is utilized in views for the permanent checkbox
  def set_permanent
    self.perm ||= self.status?(:permanent)
  end

  #
  # determines if the current record should be marked permanent
  # the record needs to be lockalbe and the permanent accessor needs to be set to '1'
  def can_be_permanent?
    # convert perm to boolean; perm can be string, integer, boolean or blank
    self.perm = true if self.perm == true || self.perm =~ (/(true|t|yes|y|1)$/i)
    self.perm = false if self.perm == false || self.perm.blank? || self.perm =~ (/(false|f|no|n|0)$/i)
    return self.lockable? && self.perm
  end

end