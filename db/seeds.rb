[Event, Tagging, Tag, Calendar].each do |klass|
  klass.truncate(:cascade => true, :only=>true, :restart=>true)
end

Tag.create(:name=>"ALL")

tsv = Pathname(Padrino.root("db", "cals.tsv"))
tsv.readlines.each_with_index do |line, i|
  lineno = i+1
  begin
    case line.chomp
    when /^#/    ; # Skip comments
    when /^\s*$/ ; # Skip blank lines
    when /(\S+)\s+(\S.*)/
      cid    = $1
      labels = $2.sub(/#.*$/, '').split('|').map(&:strip)
      raise "no tags found" if labels.blank?

      cal = Calendar.find_or_create(:cid => cid)
      cal.remove_all_tags

      labels.map{|name| Tag.find_or_create(:name => name)}.each do |tag|
        cal.add_tag(tag)
      end
    else
      raise "invalid data"
    end
  rescue => err
    STDERR.puts "line %d: %s [%s]" % [lineno, err.to_s, line]
    exit 1
  end
end
