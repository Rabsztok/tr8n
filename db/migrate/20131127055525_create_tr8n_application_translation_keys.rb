class CreateTr8nApplicationTranslationKeys < ActiveRecord::Migration
  def up
    create_table :tr8n_application_translation_keys do |t|
      t.integer :application_id
      t.integer :translation_key_id
      t.timestamps
    end

    add_index :tr8n_application_translation_keys, [:application_id], :name => :tr8n_atk_a
    add_index :tr8n_application_translation_keys, [:translation_key_id], :name => :tr8n_atk_tk
  end

  def down
    drop_table :tr8n_application_translation_keys
  end
end
