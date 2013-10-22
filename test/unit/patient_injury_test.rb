require 'test_helper'
require 'unit_helper'

class PatientInjuryTest < ActiveSupport::TestCase
  
  
  def setup
    @chist1 = patient_injuries(:one)
    @admin = users(:admin)
  end
  
  
  test "validate fixtures" do
    assert @chist1.valid?
    assert @admin.valid?
  end
  
  test "createduser_deleted_fields" do    
    test_created_user @chist1
    test_deleted @chist1
  end


  test "patient_id" do
    test_table_links(@chist1, "patient_id")
  end

  
  test "description" do
    assert @chist1.valid?

    @chist1.description = ""
    50.times {@chist1.description << 'a'}  
    assert @chist1.valid?
    @chist1.description = ""
    255.times {@chist1.description << "a"}    
    assert @chist1.valid?
    @chist1.description = ""
    1000.times {@chist1.description << "a"}
    assert @chist1.valid?   
  end

  
  test "start_illness" do
    assert @chist1.valid?
    @chist1.start_illness = nil
    assert !@chist1.valid?
        
    # start illness has to be today or earlier
    @chist1.start_illness = Time.now + 1.day
    assert !@chist1.valid?
    assert_errors @chist1.errors[:start_illness], I18n.translate('errors.patient_injury.start_illness')
    
    @chist1.start_illness = Time.now
    assert !@chist1.valid?
    assert_errors @chist1.errors[:start_illness], I18n.translate('errors.patient_injury.start_illness')
    
    @chist1.start_illness = Time.now - 10.years
    assert @chist1.valid?
  end

  
  test "start_therapy" do
    assert @chist1.valid?
    @chist1.start_therapy = nil
    assert !@chist1.valid?    
    
    @chist1.start_illness = Time.now + 10.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:start_illness], I18n.translate('errors.patient_injury.start_illness')
    @chist1.start_illness = Time.now - 10.days
    @chist1.start_therapy = Time.now - 10.days
    assert @chist1.valid?    
    @chist1.start_therapy = Time.now - 11.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:start_therapy], I18n.translate('errors.patient_injury.start_therapy')
    @chist1.start_therapy = Time.now - 9.days
    assert @chist1.valid?
  end

  
  test "accident_type" do
    assert @chist1.valid?
    
    @chist1.accident_type = ""
    (PatientInjury::MAX_LENGTH).times {@chist1.accident_type << "a"}
    assert @chist1.valid?
    (PatientInjury::MAX_LENGTH+1).times {@chist1.accident_type << "a"}
    assert !@chist1.valid?
  end


  test "accident description" do
    assert @chist1.valid?
    @chist1.accident_description = nil
    assert @chist1.valid?
    @chist1.accident_description = ""
    assert @chist1.valid?
    
    @chist1.accident_type = AccidentType::ACCIDENT_TYPE_EMPLOYMENT
    @chist1.accident_description = nil
    assert @chist1.valid?
    
    @chist1.accident_type = AccidentType::ACCIDENT_TYPE_OTHER
    @chist1.accident_description = nil
    assert !@chist1.valid?
    assert_errors @chist1.errors[:accident_description], I18n.translate('errors.patient_injury.accident_description')
    
    @chist1.accident_description = "something"
    assert @chist1.valid?
  end
  
  
  test "accident state" do
    assert @chist1.valid?
    
    @chist1.accident_type = AccidentType::ACCIDENT_TYPE_NOT
    @chist1.accident_state = nil
    assert @chist1.valid?
    @chist1.accident_state = ""
    assert @chist1.valid?
    @chist1.accident_state = "NJ"
    assert @chist1.valid?
    
    @chist1.accident_type = AccidentType::ACCIDENT_TYPE_EMPLOYMENT
    @chist1.accident_state = nil
    assert !@chist1.valid?
    assert_errors @chist1.errors[:accident_state], I18n.translate('errors.patient_injury.accident_state')

    @chist1.accident_state = "NJ"
    assert @chist1.valid?
  end


  test "hospitalization dates" do
    assert @chist1.valid?
    @chist1.hospitalization_start = nil
    assert @chist1.valid?
    
    @chist1.start_illness = Time.now - 10.days
    @chist1.start_therapy = Time.now - 10.day
    @chist1.hospitalization_start = Time.now - 10.days   
    assert @chist1.valid?
    
    @chist1.hospitalization_start = Time.now - 12.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:hospitalization_start], I18n.translate('errors.patient_injury.start_date', :name => 'Hospitalization')
    
    @chist1.hospitalization_start = Time.now - 10.days
    @chist1.hospitalization_stop = Time.now - 8.days
    assert @chist1.valid?
    
    @chist1.hospitalization_stop = nil
    assert @chist1.valid?
    @chist1.hospitalization_stop = ""
    assert @chist1.valid?
    
    @chist1.hospitalization_stop = Time.now - 10.days
    assert !@chist1.valid?
    @chist1.hospitalization_stop = Time.now - 11.days
    assert !@chist1.valid?
    
    assert_errors @chist1.errors[:hospitalization_stop], I18n.translate('errors.patient_injury.stop_date', :name => 'Hospitalization')

    @chist1.hospitalization_stop = Time.now + 8.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:hospitalization_stop], I18n.translate('errors.patient_injury.stop_date', :name => 'Hospitalization')
  end


  test "disability dates" do
    assert @chist1.valid?
    @chist1.disability_start = nil
    assert @chist1.valid?
    
    @chist1.start_illness = Time.now - 10.days
    @chist1.start_therapy = Time.now - 10.days
    @chist1.disability_start = Time.now - 10.days
    assert @chist1.valid?
    
    @chist1.disability_start = Time.now - 12.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:disability_start], I18n.translate('errors.patient_injury.start_date', :name => 'Disability')
    
    @chist1.disability_start = Time.now - 10.days
    @chist1.disability_stop = Time.now - 8.days
    assert @chist1.valid?
    
    @chist1.disability_stop = nil
    assert @chist1.valid?
    @chist1.disability_stop = ""
    assert @chist1.valid?
    
    
    @chist1.disability_stop = Time.now - 10.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:disability_stop], I18n.translate('errors.patient_injury.stop_date', :name => 'Disability')

    @chist1.disability_stop = Time.now + 8.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:disability_stop], I18n.translate('errors.patient_injury.stop_date', :name => 'Disability')
  end

  
  test "unable to work dates" do
    assert @chist1.valid?
    @chist1.unable_to_work_start = nil
    assert @chist1.valid?
    
    @chist1.start_illness = Time.now - 10.days
    @chist1.start_therapy = Time.now - 10.day
    @chist1.unable_to_work_start = Time.now - 10.days
    assert @chist1.valid?
    
    @chist1.unable_to_work_start = Time.now - 12.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:unable_to_work_start], I18n.translate('errors.patient_injury.start_date', :name => 'Unable to Work')
    
    @chist1.unable_to_work_start = Time.now - 10.days
    @chist1.unable_to_work_stop = Time.now - 8.days
    assert @chist1.valid?
    
    @chist1.unable_to_work_stop = nil
    assert @chist1.valid?
    @chist1.unable_to_work_stop = ""
    assert @chist1.valid?
    
    
    @chist1.unable_to_work_stop = Time.now - 10.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:unable_to_work_stop], I18n.translate('errors.patient_injury.stop_date', :name => 'Unable to Work')

    @chist1.unable_to_work_stop = Time.now + 8.days
    assert !@chist1.valid?
    assert_errors @chist1.errors[:unable_to_work_stop], I18n.translate('errors.patient_injury.stop_date', :name => 'Unable to Work')
  end
  
end
