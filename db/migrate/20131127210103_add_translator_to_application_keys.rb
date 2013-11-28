class AddTranslatorToApplicationKeys < ActiveRecord::Migration
  def change
    add_column :tr8n_application_translation_keys, :translator_id, :integer
  end
end
