class AddIndexToTranslationsOnLanguage < ActiveRecord::Migration
  def change
    add_index :tr8n_translations, [:language_id], :name => :tr8n_trn_l
  end
end
