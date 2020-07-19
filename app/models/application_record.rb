class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :clean_order, lambda { |attr, dir| 
    #ensure attr and dir are safe values to use by checking within an array of allowed values
    attr = (GroceryStore.attribute_names.include? attr) ? attr : 'created_at'
    dir.upcase!
    dir = (%w(ASC DESC).include? dir) ? dir : 'ASC'
    if ['name'].include? attr
      # case insensitive sort
      order(Arel.sql("lower(grocery_stores.#{attr}) #{dir}"))
    else
      order("#{attr} #{dir}")
    end
  }
end
