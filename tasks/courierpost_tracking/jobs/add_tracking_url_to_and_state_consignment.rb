class AddTrackingUrlAndStateToConsignmentJob < Job
  def initialize consignment
    @consignment = consignment
  end

  def perform
    consignment = Myfreight.consignment_info @consignment[:id]
    
    @consignment[:state] = consignment['state']
    
    check_digit = saner_barcode_check_digit('00493514590' + consignment['items'][0]['ssccs'].split(',')[0])
    
    @consignment[:tracking_url] = 'http://trackandtrace.courierpost.co.nz/Search/0049351459' + consignment['items'][0]['ssccs'].split(',')[0] + check_digit
    
    @consignment
  end
  
  private
  
  def saner_barcode_check_digit barcode
    digits= barcode.chars.to_a.reverse.map{|c|(c =~ /[0-9]+/) ? c.to_i : (c.ord - 'A'.ord) % 10}

    multiplied_digits= digits.select.with_index{|_,i| i.even? }.map{|d| d * 3}
    other_digits= digits.select.with_index {|_,i| i.odd? }

    check_digit= 10 - (multiplied_digits + other_digits).reduce(:+) % 10
    check_digit= 0 if check_digit == 10
    return check_digit.to_s
  end
end
