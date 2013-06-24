class Calendar < Sequel::Model
  include Labeling

  one_to_many :events
  one_to_many :taggings
  many_to_many :tags, :join_table => :taggings  

  ######################################################################
  ### Logics

  def self.register(cid, label)
    labels = label.to_s.split('|').map(&:strip).reject(&:blank?)
    raise "no tags found" if labels.blank?

    cal = find_or_create(:cid => cid)
    cal.remove_all_tags

    tags = labels.map{|name| Tag.find_or_create(:name => name)}
    tags.each{|tag| cal.add_tag(tag) }

    return cal
  end

  def live_update
    LiveUpdate.filter(:cid => cid).first
  end

  def source_url
    case source.to_s
    when '' ; nil
    when cid; 'https://www.google.com/calendar/embed?src=' + CGI.escape(cid)
    else    ; source
    end      
  end
end
