class ModiBalanceBill < ActiveRecord::Migration
  def up
    add_column :balance_bill_sessions, :status, :integer

    add_column :balance_bills, :adjustment_amount, :decimal, :precision => 15, :scale => 2
    add_column :balance_bills, :adjustment_description, :string
    add_column :balance_bills, :late_amount, :decimal, :precision => 15, :scale => 2
    
    @bb_session = BalanceBillSession.unscoped.all
    @bb_session.each do |sess|
      sess.update_attributes(:status => BalanceBillFlow::INCLUDE)  
      puts "updating #{sess.id}"
    end    
  end

  def down
    remove_column :balance_bill_sessions, :status
    
    remove_column :balance_bills, :adjustment_amount
    remove_column :balance_bills, :adjustment_description
    remove_column :balance_bills, :late_amount
  end
end
