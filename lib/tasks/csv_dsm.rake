# rake task to import dsm codes in csv format.
# csv file to be column A: code, column B: long_description, column C: short_description
# dsm codes to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import DSM Codes in CSV format"
  task :dsm => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/dsm_codes.csv"
    puts "Loading CSV: #{csv_file_path}"
    
    if CodesDsm.count == 0
      puts "Cleanup & prepare to load DSM codes"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |row|
          if !(row[1] == "code" || row[1] == "Code")
            if (row[1].blank?) 
               row[1] = "0" 
            end
            row = CodesDsm.create!({:version => row[0], :code => row[1], :long_description  => row[2], 
                                    :short_description => row[3], :category => row[4], :created_user => 'admin'})
          end
      end
    else
      puts "DSM codes already seeded, codes not loaded"
    end
    puts "Completed DSM code load"
  end
end
