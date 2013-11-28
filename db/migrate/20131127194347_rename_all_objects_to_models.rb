class RenameAllObjectsToModels < ActiveRecord::Migration
  def up
    rename_column :tr8n_translator_following, :object_id, :model_id
    rename_column :tr8n_translator_following, :object_type, :model_type

    rename_column :tr8n_translator_reports, :object_id, :model_id
    rename_column :tr8n_translator_reports, :object_type, :model_type

    remove_index :tr8n_notifications, :name => :tr8n_notifs_obj
    rename_column :tr8n_notifications, :object_id, :model_id
    rename_column :tr8n_notifications, :object_type, :model_type
    add_index :tr8n_notifications, [:model_type, :model_id], :name => :tr8n_notifs_model

    remove_index :tr8n_features, :name => :tr8n_feats
    rename_column :tr8n_features, :object_id, :model_id
    rename_column :tr8n_features, :object_type, :model_type
    add_index :tr8n_features, [:model_type, :model_id], :name => :tr8n_feats_model
  end

  def down
    rename_column :tr8n_translator_following, :model_id, :object_id
    rename_column :tr8n_translator_following, :model_type, :object_type

    rename_column :tr8n_translator_reports, :model_id, :object_id
    rename_column :tr8n_translator_reports, :model_type, :object_type

    rename_column :tr8n_notifications, :model_id, :object_id
    rename_column :tr8n_notifications, :model_type, :object_type

    rename_column :tr8n_features, :model_id, :object_id
    rename_column :tr8n_features, :model_type, :object_type
  end

end
