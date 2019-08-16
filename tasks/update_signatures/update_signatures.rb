require 'csv'
require 'erb'

class UpdateSignatures < Task
  def run
    CSV.foreach('input/update_signatures/signature_details.csv', headers: :first_row) do |row|
      name,email,phone,mobile,position,address_line_1,address_line_2 = row['name'],row['email'],row['phone'],row['mobile'],row['position'],row['address_line_1'],row['address_line_2']
      signature = ERB.new(File.read('input/update_signatures/signature.html.erb')).result(binding)
      gmail = Gmail.new(user: email)
      
      puts "Setting signature for #{email}"
      gmail.set_user_signature( signature )
    end
  end
end