class LocationValidator < ActiveModel::Validator
  def validate(record)
    unless STATE_CODES.include? record.state.upcase
      record.errors[:state] << ' is not a valid state code.'
    end
    if valid_location?(record.city, record.state, record.zip)
      record.errors[:city] << 'and State, or Zip must exist.'
      record.errors[:state] << 'and City, or Zip must exist.'
      record.errors[:zip] << 'or City and State must exist.'
    end
  end

  def valid_location?(city, state, zip)
    (nil_or_empty?(city) or nil_or_empty?(state)) and nil_or_empty?(zip)
  end

  STATE_CODES = [ nil, 'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FM', 'FL', 'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MH', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'MP', 'OH', 'OK', 'OR', 'PW', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VI', 'VA', 'WA', 'WV', 'WI', 'WY' ]

  private
  
  def nil_or_empty?(val)
    val.nil? or (val.is_a?(String) and val.strip.empty?)
  end
end
