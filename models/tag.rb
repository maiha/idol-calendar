class Tag < Sequel::Model
  one_to_many :taggings
  many_to_many :calendars, :join_table => :taggings

  def all?() name == "ALL"; end
end
