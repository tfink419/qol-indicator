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
    any_required = (0..@record_type::TAG_GROUPS.length).any? do |tag_num| 
      @record_type::TAG_GROUPS[tag_num] && @record_type::TAG_GROUPS[tag_num][0] && ((1 << tag_num) & calc_num )!= 0
    end
    if any_required
      [calc_num]
    else
      (0..@record_type::TAG_GROUPS.length).reduce([]) do |calcs, tag_num|
        calc = ((1 << tag_num) & calc_num)
        calcs << calc if calc != 0
        calcs
      end
    end
  end

  private

  def raw_query_from(and_tags, or_tags, others)
    queries = []

    if and_tags.length > 0
      queries << and_tags.map { |tag| "'#{tag}' = ANY(#{@record_type.table_name}.tags)" }.join(" AND ")
    end
    if or_tags.length > 0
      queries << or_tags.map { |tag| "'#{tag}' = ANY(#{@record_type.table_name}.tags)" }.join(" OR ")
    end
    if others
      to_not = @record_type::TAG_OTHER_NOT.difference(and_tags+or_tags)
      queries << to_not.map { |tag| "NOT ('#{tag}' = ANY(#{@record_type.table_name}.tags))" }.join(" AND ")
    end
    queries.map { |a_query| "(#{a_query})"}.join(" AND ")
  end

  def query_from(and_tags, or_tags, others)
    query_record = nil
    and_tags.each do |tag|
      if query_record.nil?
        query_record = @record_type.where(["? = ANY(tags)", tag])
      else
        query_record = query_record.where(["? = ANY(tags)", tag])
      end
    end
    if or_tags.length > 0
      or_queries = []
      or_tags.each do |tag|
        or_queries << "'#{tag}' = ANY(tags)"
      end
      if query_record.nil?
        query_record = @record_type.where(Arel.sql(or_queries.join(" OR ")))
      else
        query_record = query_record.where(Arel.sql(or_queries.join(" OR ")))
      end
    end
    if others
      to_not = @record_type::TAG_OTHER_NOT.difference(and_tags+or_tags)
      to_not.each do |tag|
        if query_record.nil?
          query_record = @record_type.where.not(["? = ANY(tags)", tag])
        else
          query_record = query_record.where.not(["? = ANY(tags)", tag])
        end
      end
    end
    query_record
  end
end