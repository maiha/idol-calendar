class Calendar < Sequel::Model
  include Labeling

  one_to_many :events
  one_to_many :taggings
  many_to_many :tags, :join_table => :taggings  
end
