class ModInvoiceDates < ActiveRecord::Migration
  def up
    add_column :invoices, :fee_start, :datetime
    add_column :invoices, :fee_end, :datetime 
  end

  def down
    remove_column :invoices, :fee_start
    remove_column :invoices, :fee_end
  end
end
