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
      queries << to_not.map { |tag| "NOT ('#{tag}' = ANY(#{@record_type.table_name}.tags))" }.join(" OR ")
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