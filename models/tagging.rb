class Tagging < Sequel::Model
  many_to_one :calendars
  many_to_one :tags
end
