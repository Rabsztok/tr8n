class AddApplicationIdToForumTopic < ActiveRecord::Migration
  def change
    add_column :tr8n_forum_topics, :application_id, :integer
    add_index :tr8n_forum_topics, [:application_id], :name => :tr8n_fortop_app_id
  end
end
