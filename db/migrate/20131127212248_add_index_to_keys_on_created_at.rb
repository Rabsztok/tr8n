class AddIndexToKeysOnCreatedAt < ActiveRecord::Migration
  def change
    add_index :tr8n_translation_keys, [:created_at], :name => :tr8n_tk_c
  end
end
