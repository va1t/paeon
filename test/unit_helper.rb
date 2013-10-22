

class ActiveSupport::TestCase
  


  def test_created_user (object)
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
      return flunk " Check the model for validations for created_user"
    end
  end
  
  
  def test_deleted (object)
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