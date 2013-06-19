Sequel.migration do
  change do
    alter_table :calendars do
      add_column :label, String
    end
    alter_table :events do
      add_column :label, String
    end
  end
end
