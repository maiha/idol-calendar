class Event < Sequel::Model
  include Labeling

  unrestrict_primary_key
  many_to_one :calendar
end
