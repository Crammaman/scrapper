class TransitTime < ApplicationRecord
  belongs_to :carrier
  belongs_to :from_locality, class_name: 'Locality'
  belongs_to :to_locality, class_name: 'Locality'

  def to_s
    "From #{from_locality} To #{to_locality} Transit Days: #{days}"
  end
end
