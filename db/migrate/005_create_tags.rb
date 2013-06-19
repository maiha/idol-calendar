Sequel.migration do
  up do
    create_table :tags do
      primary_key :id
      String :name, :unique => true
    end
  end

  down do
    drop_table :tags
  end
end
