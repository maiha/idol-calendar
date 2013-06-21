Sequel.migration do
  up do
    create_table :live_updates do
      primary_key :id
      String  :cid, :unique => true
      String  :extractor
    end
  end

  down do
    drop_table :live_updates
  end
end
