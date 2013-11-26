

class ActiveSupport::TestCase

  def test_created_user(object)
    begin
      admin = users(:admin)

      object.created_user = ""
      assert !object.valid?
      assert_errors object.errors[:created_user], I18n.translate('errors.messages.blank')
      object.created_user = nil
      assert !object.valid?
      assert_errors object.errors[:created_user], I18n.translate('errors.messages.blank')

      object.created_user = admin.login_name
      assert object.valid?
    rescue
      return flunk "Check the model for validations for created_user; also check fixtures for valid input data"
    end
  end

  #
  # testing the common status module
  #
  def test_common_status(object)
    #set the initial status to :active
    object.init_record
    assert object.status?(:active)
    #check the status checks for the state
    assert object.archiveable?
    assert object.lockable?
    assert object.deleteable?
    assert !object.locked?
    # active state should allow unarchive, undelete and unlock to succeed
    object.unarchive_record
    assert object.active?
    object.undelete_record
    assert object.active?
    object.unlock_record
    assert object.active?

    #
    # lock the record
    #
    object.lock_record
    assert object.permanent?
    # locked record should be able ot be set locked
    object.lock_record
    assert object.permanent?
    assert object.status?(:permanent)
    # locked record cannot be deleted
    exception = assert_raise(StandardError) { object.delete_record }
    assert_equal("Record is locked permanent and cannot be deleted", exception.message)
    exception = assert_raise(StandardError) { object.undelete_record }
    assert_equal("Record is not deleted", exception.message)
    # locked record cannot be archived
    exception = assert_raise(StandardError) { object.archive_record }
    assert_equal("Record is either deleted or permanent and cannot be archived", exception.message)
    exception = assert_raise(StandardError) { object.unarchive_record }
    assert_equal("Record is not archived and cannot be unarchived", exception.message)

    assert !object.archiveable?
    assert !object.deleteable?
    # locked record should be lockable
    assert object.lockable?
    assert object.locked?
    # unlock the record
    object.unlock_record
    assert !object.locked?
    assert object.active?

    #
    # archive the record
    #
    object.archive_record
    assert object.archived?
    # archived record should be able to be archived
    object.archive_record
    assert object.archived?
    assert object.status?(:archived)
    assert object.archiveable?
    assert object.deleteable?
    # archive record should not be lockable
    assert !object.lockable?
    assert !object.locked?
    # lock and unlock should throw an error
    exception = assert_raise(StandardError) { object.lock_record }
    assert_equal("Record is either deleted or archived and cannot be locked permanent", exception.message)
    exception = assert_raise(StandardError) { object.unlock_record }
    assert_equal("Record is not locked permanent and cannot be unlocked", exception.message)
    # should be able to delete
    object.delete_record
    assert object.deleted?
    object.undelete_record
    #reset back to archived to test unarchive
    assert object.active?
    object.archive_record
    assert object.archived?
    assert object.status?(:archived)
    object.unarchive_record
    assert object.active?

    #
    # delete the record
    #
    object.delete_record
    assert object.status?(:deleted)
    assert object.deleted?
    assert !object.archiveable?
    assert object.deleteable?
    assert !object.lockable?
    assert !object.locked?
    # lock and unlock should throw an error
    exception = assert_raise(StandardError) { object.lock_record }
    assert_equal("Record is either deleted or archived and cannot be locked permanent", exception.message)
    exception = assert_raise(StandardError) { object.unlock_record }
    assert_equal("Record is not locked permanent and cannot be unlocked", exception.message)
    exception = assert_raise(StandardError) { object.archive_record }
    assert_equal("Record is either deleted or permanent and cannot be archived", exception.message)
    exception = assert_raise(StandardError) { object.unarchive_record }
    assert_equal("Record is not archived and cannot be unarchived", exception.message)
    # a deleted record should be able to be deleted
    object.delete_record
    assert object.deleted?
    object.undelete_record
    assert object.active?

    #
    # test the permanent accessor
    #
    object.init_record
    assert !object.set_permanent
    object.lock_record
    assert object.set_permanent
    # lockable is true and permanent is true
    assert object.can_be_permanent?
    # lockable is true and permanent is false
    object.perm = false
    assert !object.can_be_permanent?
    # lockable is false and permanent is false
    object.init_record
    object.delete_record
    assert !object.can_be_permanent?
    # lockable is false and permanent is true
    object.perm = true
    assert !object.can_be_permanent?
  end


  def test_deleted(object)
    begin
      object.deleted = true
      assert object.valid?
      object.deleted = false
      assert object.valid?

      object.deleted = ""
      assert !object.valid?
      assert_errors object.errors[:deleted], I18n.translate('errors.messages.inclusion')
      object.deleted = nil
      assert !object.valid?
      assert_errors object.errors[:deleted], I18n.translate('errors.messages.inclusion')
    rescue
      return flunk " Check the model for validations for deleted flag"
    end
  end


  # ensure the id fields linking tables are valid
  # pass in the model object and the attribute string
  def test_table_links (object, field)
    begin
      assert object.valid?

      #test for nil & blanks
      object.send(field+'=', nil)
      assert !object.valid?
      object.send(field+'=', "")
      assert !object.valid?

      #test for alpha, floats
      object.send(field+'=', "a")
      assert !object.valid?
      object.send(field+'=', 3.2)
      assert !object.valid?
      object.send(field+'=', "3.2")
      assert !object.valid?
      object.send(field+'=', "a1")
      assert !object.valid?

      #test valid integers
      object.send(field+'=', 0)
      assert object.valid?
      object.send(field+'=', 1)
      assert object.valid?
      object.send(field+'=', "1")
      assert object.valid?
      object.send(field+'=', 1000000000)
      assert object.valid?
    rescue => e
      puts e.inspect
      return flunk " Check the model. The field pointer '#{field}' to other tables may be missing presence and/or numericality validations."
    end
  end


  def test_numericality_integer (object)
    true if ( Integer(object) rescue false)
  end

  def test_numericality (object)
    true if ( Integer(object) rescue Float(object) rescue false)
  end
end