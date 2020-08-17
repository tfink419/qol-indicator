class TagQuery
  def initialize(record_type)
    @record_type = record_type
  end

  def query(tag_calc_num, raw=false)
    if tag_calc_num == 0
      if raw
        return { table_name:@record_type.table_name, name:@record_type.name, query:'none' }
      else
        return @record_type.where(id:nil)
      end
    end
    if tag_calc_num == @record_type::TAG_GROUPS_CALC_SIZE
      if raw
        return { table_name:@record_type.table_name, name:@record_type.name, query:'all' }
      else
        return @record_type
      end
    end
    and_tags = []
    or_tags = []
    others = false
    @record_type::TAG_GROUPS.each_with_index do |tag_group, tag_num|
      if ((tag_calc_num >> tag_num) & 1) == 1
        if tag_group
          tag_group[1].each do |tag|
            if tag_group[0]
              and_tags << tag
            else
              or_tags << tag
            end
          end
        else
          others = true
        end
      end
    end

    if raw
      {
        table_name:@record_type.table_name,
        name:@record_type.name,
        query:raw_query_from(and_tags, or_tags, others)
      }
    else
      query_from(and_tags, or_tags, others)
    end
  end

  def all_calcs_in_tag(tag_num)
    return [0] if @record_type::TAG_GROUPS.length == 0 
    return [] if tag_num >= @record_type::TAG_GROUPS.length
    calc_num = (1 << tag_num)
    calcs = [calc_num]
    if(@record_type::TAG_GROUPS[tag_num] && @record_type::TAG_GROUPS[tag_num][0]) # required
      calcs = [calc_num]
      if tag_num+1 < @record_type::TAG_GROUPS.length
        ((tag_num+1)...@record_type::TAG_GROUPS.length).each do |inner_tag_num|
          all_calcs_in_tag(inner_tag_num).each do |inner_calc|
            calcs << (calc_num | inner_calc)
          end
        end
      end
    end
    calcs.sort
  end

  def breakup_calc_num(calc_num)
    return [0] if @record_type::TAG_GROUPS.length == 0
    required = 0
    calcs = (0..@record_type::TAG_GROUPS.length).reduce([]) do |calcs, tag_num|
      calc = ((1 << tag_num) & calc_num)
      if calc != 0
        if @record_type::TAG_GROUPS[tag_num] && @record_type::TAG_GROUPS[tag_num][0]
          required = required | (1 << tag_num)
        else
          calcs << (required | calc)
        end
      end
      calcs
    end
    if calcs.empty? && required != 0 && calc_num != 0
      calcs << required
    end
    calcs
  end

  private

  def raw_query_from(and_tags, or_tags, others)
    queries = []

    if and_tags.length > 0
      queries << "#{@record_type.table_name}.tags @> #{str_arr_to_pg_arr(and_tags)}::varchar[]"
    end
    or_queries = []
    if or_tags.length > 0
      or_queries << "#{@record_type.table_name}.tags && #{str_arr_to_pg_arr(or_tags)}::varchar[]"
    end
    if others
      to_not = @record_type::TAG_OTHER_NOT.difference(and_tags+or_tags)
      or_queries << "NOT #{@record_type.table_name}.tags && #{str_arr_to_pg_arr(to_not)}::varchar[]"
    end
    unless or_queries.empty?
      queries << or_queries.map { |a_query| "(#{a_query})"}.join(" OR ")
    end
    queries.map { |a_query| "(#{a_query})"}.join(" AND ")
  end

  def query_from(and_tags, or_tags, others)
    query_record = nil
    unless and_tags.empty?
      query_record = @record_type.where("#{@record_type.table_name}.tags @> #{str_arr_to_pg_arr(and_tags)}::varchar[]")
    end

    or_queries = []
    unless or_tags.empty?
      or_queries << "#{@record_type.table_name}.tags && #{str_arr_to_pg_arr(or_tags)}::varchar[]"
    end
    if others
      to_not = @record_type::TAG_OTHER_NOT.difference(and_tags+or_tags)
      not_queries = to_not.map { |tag| "NOT '#{tag}' = ANY(tags)" }
      or_queries << "NOT #{@record_type.table_name}.tags && #{str_arr_to_pg_arr(to_not)}::varchar[]"
    end
    unless or_queries.empty?
      if query_record.nil?
        query_record = @record_type.where(Arel.sql(or_queries.join(" OR ")))
      else
        query_record = query_record.where(Arel.sql(or_queries.join(" OR ")))
      end
    end
    query_record
  end

  private

  def str_arr_to_pg_arr(arr)
    "ARRAY["+arr.map{ |el| "'#{el}'" }.join(',')+"]"
  end
end