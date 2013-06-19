Sequel.migration do
  up do
    create_table :taggings do
      primary_key :id
      foreign_key :calendar_id, :table => :calendars
      foreign_key :tag_id, :table => :tags
    end
  end

  down do
    drop_table :taggings
  end
end
