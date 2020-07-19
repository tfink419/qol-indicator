class IndexQuery
  def initialize(record_type)
    @record_type = record_type
  end

  def index(limit, offset, attr, dir)
    count = @record_type.count
    [clean_order(attr, dir).limit(limit).offset(offset), count]
  end

  def clean_order(attr, dir)
    #ensure attr and dir are safe values to use by checking within an array of allowed values
    attr = (@record_type.attribute_names.include? attr) ? attr : 'created_at'
    dir.upcase!
    dir = (['ASC', 'DESC'].include? dir) ? dir : 'ASC'
    if ['first_name', 'last_name', 'email', 'username', 'name'].include? attr
      # case insensitive sort
      @record_type.order(Arel.sql("lower(#{@record_type.table_name}.#{attr}) #{dir}"))
    else
      @record_type.order("#{attr} #{dir}")
    end
  end
end