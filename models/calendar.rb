class Calendar < Sequel::Model
  one_to_many :events
  one_to_many :taggings
  many_to_many :tags, :join_table => :taggings
end
