# rake task to import carc codes in csv format.
# csv file to be column A: code, column B: description
# carc codes to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import RARC Codes in CSV format"
  task :rarc => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/rarc.csv"    
    puts "Loading CSV: #{csv_file_path}"
    

    if CodesRarc.count == 0 
      puts "Cleanup & prepare to load RARC codes"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |row|
          if !(row[0] == "code" || row[0] == "Code")
            row = CodesRarc.create!({:code => row[0], :description  => row[1], :created_user => 'admin'})          
          end
      end
    else
      puts "RARC codes already seeded, codes not loaded"
    end
    puts "Completed RARC code load"
  end
end
