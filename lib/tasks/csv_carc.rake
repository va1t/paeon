# rake task to import carc codes in csv format.
# csv file to be column A: code, column B: description
# carc codes to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import CARC Codes in CSV format"
  task :carc => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/carc.csv"    
    puts "Loading CSV: #{csv_file_path}"

    if CodesCarc.count == 0 
      puts "Cleanup & prepare to load CARC codes"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |row|
          if !(row[0] == "code" || row[0] == "Code")
            row = CodesCarc.create!({:code => row[0], :description  => row[1], :created_user => 'admin'})          
          end
      end
    else
      puts "CARC codes already seeded, codes not loaded"
    end
    puts "Completed CARC code load"
  end
end
