#--
# Copyright (c) 2013 Michael Berkovich, tr8nhub.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class CreateTr8nTables < ActiveRecord::Migration
  def self.up

    ####################################################################################################
    ## Applications
    ####################################################################################################
    create_table :tr8n_applications do |t|
      t.string  :type
      t.string  :key
      t.string  :secret
      t.string  :name
      t.string  :url
      t.string  :description
      t.string  :version
      t.text    :definition
      t.integer :default_language_id
      t.timestamps
    end
    add_index :tr8n_applications, [:key], :name => :tr8n_apps

    create_table :tr8n_application_languages do |t|
      t.integer :application_id,        :null => false
      t.integer :language_id,           :null => false
      t.boolean :default
      t.integer :featured_index
      t.integer :position
      t.timestamps
    end
    add_index :tr8n_application_languages, [:application_id], :name => :tr8n_app_lang_app_id

    create_table :tr8n_application_translators do |t|
      t.integer :application_id
      t.integer :translator_id
      t.integer :language_id
      t.boolean :manager
      t.boolean :inline_mode
      t.timestamps
    end
    add_index :tr8n_application_translators, [:application_id], :name => :tr8n_app_trn_comp_id
    add_index :tr8n_application_translators, [:translator_id], :name => :tr8n_app_trn_trn_id
    add_index :tr8n_application_translators, [:language_id], :name => :tr8n_app_trn_lang_id

    create_table :tr8n_features do |t|
      t.string  :object_type
      t.integer :object_id
      t.string  :keyword
      t.boolean :enabled
      t.timestamps
    end
    add_index :tr8n_features, [:object_type, :object_id], :name => :tr8n_feats

    create_table :tr8n_oauth_tokens do |t|
      t.string    :type
      t.string    :token, :null => false
      t.integer   :application_id
      t.integer   :translator_id
      t.string    :scope
      t.timestamp :expires_at
      t.timestamps
    end
    add_index :tr8n_oauth_tokens, [:application_id], :name => :tr8n_oauth_tokens_app_id
    add_index :tr8n_oauth_tokens, [:translator_id], :name => :tr8n_oauth_tokens_trn_id

    create_table :tr8n_sync_logs do |t|
      t.string    :type
      t.integer   :application_id
      t.timestamp :started_at
      t.timestamp :finished_at
      t.integer   :keys_sent
      t.integer   :translations_sent
      t.integer   :keys_received
      t.integer   :translations_received
      t.text      :data
      t.timestamps
    end
    add_index   :tr8n_sync_logs, [:application_id], :name => :tr8n_sl_a_id

    create_table :tr8n_media do |t|
      t.string  :type
      t.integer :position
      t.integer :owner_id
      t.string  :owner_type
      t.string  :keyword
      t.string  :path
      t.text    :thumbnails
      t.timestamps
    end
    add_index :tr8n_media, [:owner_id, :owner_type, :keyword], :name => :tr8n_m_oid_ot_k

    create_table :tr8n_requests do |t|
      t.integer   :application_id
      t.string    :type
      t.string    :state
      t.string    :key
      t.string    :email
      t.integer   :from_id
      t.integer   :to_id
      t.text      :data
      t.timestamp :expires_at

      t.timestamps
    end
    add_index :tr8n_requests, [:type, :application_id, :email], :name => :tr8n_req_t_a_e

    ####################################################################################################
    ## Languages
    ####################################################################################################
    create_table :tr8n_languages do |t|
      t.string  :locale,        :null => false
      t.string  :english_name,  :null => false
      t.string  :native_name
      t.integer :threshold,     :default => 1
      t.boolean :enabled
      t.boolean :right_to_left
      t.integer :completeness
      t.integer :fallback_language_id
      t.text    :curse_words
      t.integer :featured_index, :default => 0
      t.string  :google_key
      t.string  :facebook_key
      t.timestamps
    end
    add_index :tr8n_languages, [:locale], :name => :tr8n_ll

    create_table :tr8n_language_users do |t|
      t.integer :language_id,   :null => false
      t.integer :user_id,       :null => false
      t.timestamps
    end
    add_index :tr8n_language_users, [:user_id], :name => :tr8n_lu_u
    add_index :tr8n_language_users, [:language_id, :user_id], :name => :tr8n_lu_lu
    add_index :tr8n_language_users, [:created_at], :name => :tr8n_lu_ca
    add_index :tr8n_language_users, [:updated_at], :name => :tr8n_lu_ua

    create_table :tr8n_language_contexts do |t|
      t.integer :language_id
      t.integer :translator_id
      t.string  :keyword
      t.string  :description
      t.text    :definition
      t.timestamps
    end
    add_index :tr8n_language_contexts, [:language_id, :keyword], :name => :tr8n_lctx_lk

    create_table :tr8n_language_context_rules do |t|
      t.integer :language_context_id
      t.integer :translator_id
      t.string  :keyword
      t.string  :description
      t.string  :examples
      t.text    :definition
      t.timestamps
    end
    add_index :tr8n_language_context_rules, [:language_context_id, :keyword], :name => :tr8n_lctxr_lci

    create_table :tr8n_language_cases do |t|
      t.integer :language_id, :null => false
      t.integer :translator_id
      t.string  :keyword
      t.string  :latin_name
      t.string  :native_name
      t.text    :description
      t.string  :application
      t.timestamps
    end
    add_index :tr8n_language_cases, [:language_id], :name => :tr8n_lc_l
    add_index :tr8n_language_cases, [:language_id, :translator_id], :name => :tr8n_lc_lt
    add_index :tr8n_language_cases, [:language_id, :keyword], :name => :tr8n_lc_lk

    create_table :tr8n_language_case_rules do |t|
      t.integer :language_case_id, :null => false
      t.integer :language_id
      t.integer :translator_id
      t.text    :definition, :null => false
      t.string  :description
      t.string  :examples
      t.integer :position
      t.timestamps
    end
    add_index :tr8n_language_case_rules, [:language_case_id], :name => :tr8n_lcr_lc
    add_index :tr8n_language_case_rules, [:language_id], :name => :tr8n_lcr_l
    add_index :tr8n_language_case_rules, [:translator_id], :name => :tr8n_lcr_t

    create_table :tr8n_language_case_value_maps do |t|
      t.string  :keyword, :null => false
      t.integer :language_id, :null => false
      t.integer :translator_id
      t.text    :map
      t.boolean :reported
      t.timestamps
    end
    add_index :tr8n_language_case_value_maps, [:keyword, :language_id], :name => :tr8n_lcvm_kl
    add_index :tr8n_language_case_value_maps, [:translator_id], :name => :tr8n_lcvm_t

    create_table :tr8n_language_metrics do |t|
      t.string  :type
      t.integer :language_id,           :null => false
      t.date    :metric_date
      t.integer :user_count,            :default => 0
      t.integer :translator_count,      :default => 0
      t.integer :translation_count,     :default => 0
      t.integer :key_count,             :default => 0
      t.integer :locked_key_count,      :default => 0
      t.integer :translated_key_count,  :default => 0

      t.timestamps
    end
    add_index :tr8n_language_metrics, [:language_id], :name => :tr8n_lm_l
    add_index :tr8n_language_metrics, [:created_at], :name => :tr8n_lm_c

    create_table :tr8n_countries do |t|
      t.string  :code
      t.string  :english_name
      t.string  :native_name
      t.string  :telephone_code
      t.string  :currency
      t.timestamps
    end
    add_index :tr8n_countries, [:code], :name => :tr8n_countries_code

    create_table :tr8n_country_languages do |t|
      t.integer :position
      t.integer :country_id
      t.integer :language_id
      t.boolean :official
      t.boolean :primary
      t.integer :population
      t.timestamps
    end
    add_index :tr8n_country_languages, [:country_id], :name => :tr8n_cl_cid
    add_index :tr8n_country_languages, [:language_id], :name => :tr8n_cl_lid

    ####################################################################################################
    ## Sources
    ####################################################################################################
    create_table :tr8n_translation_sources do |t|
      t.integer   :application_id
      t.integer   :translation_domain_id
      t.integer   :parent_id
      t.string    :source
      t.integer   :completeness
      t.string    :name
      t.string    :description
      t.string    :url
      t.integer   :key_count
      t.timestamps
    end
    add_index :tr8n_translation_sources, [:source], :name => :tr8n_ts_s
    add_index :tr8n_translation_sources, [:parent_id], :name => :tr8n_ts_pid

    create_table :tr8n_translation_source_languages do |t|
      t.integer   :language_id
      t.integer   :translation_source_id
      t.timestamps
    end
    add_index :tr8n_translation_source_languages, [:language_id, :translation_source_id], :name => :tr8n_tsl_lt

    create_table :tr8n_translation_domains do |t|
      t.string        :name
      t.string        :description
      t.integer       :application_id
      t.integer       :source_count,  :default => 0
      t.timestamps
    end
    add_index :tr8n_translation_domains, [:name], :unique => true, :name => :tr8n_td_n

    create_table :tr8n_translation_source_metrics do |t|
      t.integer :translation_source_id, :null => false
      t.integer :language_id,           :null => false
      t.integer :key_count,             :default => 0
      t.integer :locked_key_count,      :default => 0
      t.integer :translation_count,     :default => 0
      t.integer :translated_key_count,  :default => 0
      t.timestamps
    end
    add_index :tr8n_translation_source_metrics, [:translation_source_id, :language_id], :name => :tr8n_trans_source_metrs_tsili

    ####################################################################################################
    ## Components
    ####################################################################################################
    create_table :tr8n_components do |t|
      t.integer :application_id
      t.string  :key
      t.string  :state
      t.string  :name
      t.string  :description
      t.integer :position
      t.timestamps
    end
    add_index :tr8n_components, [:application_id], :name => :tr8n_comp_app_id

    create_table :tr8n_component_languages do |t|
      t.integer :component_id
      t.integer :language_id
      t.string :state
      t.timestamps
    end
    add_index :tr8n_component_languages, [:component_id], :name => :tr8n_comp_lang_comp_id
    add_index :tr8n_component_languages, [:language_id], :name => :tr8n_comp_lang_lang_id

    create_table :tr8n_component_translators do |t|
      t.integer :component_id
      t.integer :translator_id
      t.integer :language_id
      t.string :state
      t.timestamps
    end
    add_index :tr8n_component_translators, [:component_id], :name => :tr8n_comp_trn_comp_id
    add_index :tr8n_component_translators, [:translator_id], :name => :tr8n_comp_trn_trn_id
    add_index :tr8n_component_translators, [:language_id], :name => :tr8n_comp_trn_lang_id

    create_table :tr8n_component_sources do |t|
      t.integer :component_id
      t.integer :translation_source_id
      t.integer :position
      t.timestamps
    end
    add_index :tr8n_component_sources, [:component_id], :name => :tr8n_comp_comp_id
    add_index :tr8n_component_sources, [:translation_source_id], :name => :tr8n_comp_src_id

    ####################################################################################################
    ## Translators
    ####################################################################################################
    create_table :tr8n_translators do |t|
      t.integer :user_id
      t.boolean :inline_mode,   :default => false
      t.boolean :blocked,       :default => false
      t.boolean :reported,      :default => false
      t.integer :voting_power,  :default => 1
      t.integer :rank,          :default => 0
      t.integer :fallback_language_id
      t.string  :name
      t.string  :gender
      t.string  :email
      t.string  :password
      t.string  :mugshot
      t.string  :link
      t.string  :locale
      t.integer :level,       :default => 0
      t.boolean :manager
      t.string  :last_ip
      t.string  :country_code
      t.integer :remote_id
      t.string  :access_key
      t.timestamps
    end
    add_index :tr8n_translators, [:user_id], :name => :tr8n_t_u
    add_index :tr8n_translators, [:created_at], :name => :tr8n_t_c
    add_index :tr8n_translators, [:email], :name => :tr8n_t_e
    add_index :tr8n_translators, [:email, :password], :name => :tr8n_t_ep

    create_table :tr8n_translator_languages do |t|
      t.integer :translator_id
      t.integer :language_id
      t.boolean :primary
      t.integer :position
      t.boolean :manager
      t.timestamps
    end
    add_index :tr8n_translator_languages, [:translator_id, :language_id], :name => :tr8n_trn_lang

    create_table :tr8n_translator_logs do |t|
      t.integer :translator_id
      t.integer :user_id,       :limit => 8
      t.string  :action
      t.integer :action_level
      t.string  :reason
      t.string  :reference
      t.timestamps
    end
    add_index :tr8n_translator_logs, [:translator_id], :name => :tr8n_tl_t
    add_index :tr8n_translator_logs, [:user_id], :name => :tr8n_tl_u
    add_index :tr8n_translator_logs, [:created_at], :name => :tr8n_tl_c
    
    create_table :tr8n_translator_metrics do |t|
      t.integer :translator_id,         :null => false
      t.integer :language_id           
      t.integer :total_translations,    :default => 0
      t.integer :total_votes,           :default => 0
      t.integer :positive_votes,        :default => 0
      t.integer :negative_votes,        :default => 0
      t.integer :accepted_translations, :default => 0
      t.integer :rejected_translations, :default => 0
      t.timestamps
    end
    add_index :tr8n_translator_metrics, [:translator_id], :name => :tr8n_tm_t
    add_index :tr8n_translator_metrics, [:translator_id, :language_id], :name => :tr8n_tm_tl
    add_index :tr8n_translator_metrics, [:created_at], :name => :tr8n_tm_c

    create_table :tr8n_translator_following do |t|
      t.integer     :translator_id
      t.integer     :object_id
      t.string      :object_type
      t.timestamps
    end
    add_index :tr8n_translator_following, [:translator_id], :name => :tr8n_tf_t

    create_table :tr8n_translator_reports do |t|
      t.integer     :translator_id
      t.string      :state
      t.integer     :object_id
      t.string      :object_type
      t.string      :reason
      t.text        :comment
      t.timestamps
    end
    add_index :tr8n_translator_reports, [:translator_id], :name => :tr8n_tr_t

    create_table :tr8n_notifications do |t|
      t.string      :type
      t.integer     :translator_id
      t.integer     :actor_id
      t.integer     :target_id
      t.string      :action
      t.string      :object_type
      t.integer     :object_id
      t.timestamp   :viewed_at
      t.timestamps
    end
    add_index :tr8n_notifications, [:translator_id], :name => :tr8n_notifs_trn_id
    add_index :tr8n_notifications, [:object_type, :object_id], :name => :tr8n_notifs_obj

    create_table :tr8n_ip_locations do |t|
      t.integer   :low,       :limit => 8
      t.integer   :high,      :limit => 8
      t.string    :registry,  :limit => 20
      t.date      :assigned
      t.string    :ctry,      :limit => 2
      t.string    :cntry,     :limit => 3
      t.string    :country,   :limit => 80
      t.timestamps
    end
    add_index :tr8n_ip_locations, [:low], :name => :tr8n_il_l
    add_index :tr8n_ip_locations, [:high], :name => :tr8n_il_h

    ####################################################################################################
    ## Translation Keys
    ####################################################################################################
    create_table :tr8n_translation_keys do |t|
      t.string    :type
      t.string    :master_key
      t.string    :key,   :null => false
      t.text      :label, :null => false
      t.text      :description
      t.timestamp :verified_at
      t.integer   :translation_count
      t.boolean   :admin
      t.string    :locale
      t.integer   :level, :default => 0
      t.timestamp :synced_at
      t.timestamps
    end
    add_index :tr8n_translation_keys, [:key], :unique => true, :name => :tr8n_tk_k
    add_index :tr8n_translation_keys, [:master_key], :name => :tr8n_tk_mk

    create_table :tr8n_translation_key_comments do |t|
      t.integer :language_id, :null => false
      t.integer :translation_key_id, :null => false
      t.integer :translator_id, :null => false
      t.text    :message, :null => false
      t.string  :mentions
      t.timestamps
    end
    add_index :tr8n_translation_key_comments, [:language_id], :name => :tr8n_tkc_l
    add_index :tr8n_translation_key_comments, [:translator_id], :name => :tr8n_tkc_t
    add_index :tr8n_translation_key_comments, [:language_id, :translation_key_id], :name => :tr8n_tkc_lt

    create_table :tr8n_translation_key_sources do |t|
      t.integer :translation_key_id, :null => false
      t.integer :translation_source_id, :null => false
      t.text    :details
      t.timestamps
    end
    add_index :tr8n_translation_key_sources, [:translation_key_id], :name => :tr8n_tks_tk
    add_index :tr8n_translation_key_sources, [:translation_source_id], :name => :tr8n_tks_ts

    create_table :tr8n_translation_key_locks do |t|
      t.integer :translation_key_id, :null => false
      t.integer :language_id, :null => false
      t.integer :translator_id
      t.boolean :locked, :default => false
      t.timestamps
    end
    add_index :tr8n_translation_key_locks, [:translation_key_id, :language_id], :name => :tr8n_tkl_tl

    create_table :tr8n_decorators do |t|
      t.integer   :application_id
      t.text      :css
      t.timestamps
    end
    add_index :tr8n_decorators, [:application_id], :name => :tr8n_decors_app

    ####################################################################################################
    ## Translations
    ####################################################################################################
    create_table :tr8n_translations do |t|
      t.integer   :translation_key_id,  :null => false
      t.integer   :language_id,         :null => false
      t.integer   :translator_id,       :null => false
      t.text      :label,               :null => false
      t.integer   :rank,                :default => 0
      t.integer   :approved_by_id,      :limit => 8
      t.text      :context
      t.timestamp :synced_at
      t.timestamps
    end
    add_index :tr8n_translations, [:translator_id], :name => :tr8n_trn_t
    add_index :tr8n_translations, [:translation_key_id, :translator_id, :language_id], :name => :tr8n_trn_tktl
    add_index :tr8n_translations, [:created_at], :name => :tr8n_trn_c
  
    create_table :tr8n_translation_votes do |t|
      t.integer :translation_id,      :null => false
      t.integer :translator_id,       :null => false
      t.integer :vote,                :null => false
      t.timestamps
    end
    add_index :tr8n_translation_votes, [:translator_id], :name => :tr8n_tv_t
    add_index :tr8n_translation_votes, [:translation_id, :translator_id], :name => :tr8n_tv_tt

    ####################################################################################################
    ## Forums
    ####################################################################################################
    create_table :tr8n_forum_topics do |t|
      t.integer :application_id
      t.integer :translator_id, :null => false
      t.integer :language_id
      t.text    :topic, :null => false
      t.timestamps
    end
    add_index :tr8n_forum_topics, [:application_id, :language_id], :name => :tr8n_lft_a_l
    add_index :tr8n_forum_topics, [:translator_id], :name => :tr8n_lft_t

    create_table :tr8n_forum_messages do |t|
      t.integer :language_id,   :null => false
      t.integer :topic_id,      :null => false
      t.integer :translator_id, :null => false
      t.text    :message,       :null => false
      t.string  :mentions
      t.timestamps
    end
    add_index :tr8n_forum_messages, [:language_id], :name => :tr8n_lfm_l
    add_index :tr8n_forum_messages, [:translator_id], :name => :tr8n_lfm_t
    add_index :tr8n_forum_messages, [:language_id, :topic_id], :name => :tr8n_lfm_ll

    create_table :tr8n_forum_topic_languages do |t|
      t.integer :language_id
      t.integer :topic_id
      t.timestamps
    end
    add_index :tr8n_forum_topic_languages, [:language_id], :name => :tr8n_top_lang

    ####################################################################################################
    ## Emails
    ####################################################################################################
    create_table :tr8n_email_templates do |t|
      t.string  :type
      t.integer :application_id
      t.integer :language_id
      t.string  :keyword
      t.string  :name
      t.string  :description
      t.string  :subject
      t.string  :layout
      t.integer :version
      t.string  :state
      t.text    :html_body
      t.text    :text_body
      t.text    :tokens
      t.integer :parent_id
      t.timestamps
    end
    add_index :tr8n_email_templates, [:type, :application_id, :keyword], :name => :tr8n_et_t_a

    create_table :tr8n_email_logs do |t|
      t.string    :key
      t.integer   :email_template_id
      t.integer   :language_id
      t.integer   :from_id
      t.integer   :to_id
      t.string    :email
      t.text      :tokens
      t.timestamp :sent_at
      t.timestamp :viewed_at
      t.timestamps
    end
    add_index :tr8n_email_logs, [:key], :name => :tr8n_el_k
    add_index :tr8n_email_logs, [:email]

    ####################################################################################################
    ## Glossary
    ####################################################################################################
    create_table :tr8n_glossary do |t|
      t.integer :application_id
      t.integer :language_id
      t.string  :keyword
      t.text    :description
      t.timestamps
    end
    add_index :tr8n_glossary, [:application_id, :language_id, :keyword], :name => :tr8n_g_aid_key

  end

  def self.down
    drop_table :tr8n_applications
    drop_table :tr8n_application_languages
    drop_table :tr8n_application_translators
    drop_table :tr8n_features
    drop_table :tr8n_oauth_tokens
    drop_table :tr8n_sync_logs
    drop_table :tr8n_media
    drop_table :tr8n_requests

    drop_table :tr8n_languages
    drop_table :tr8n_language_users
    drop_table :tr8n_language_contexts
    drop_table :tr8n_language_context_rules
    drop_table :tr8n_language_cases
    drop_table :tr8n_language_case_rules
    drop_table :tr8n_language_case_value_maps
    drop_table :tr8n_language_metrics
    drop_table :tr8n_countries
    drop_table :tr8n_country_languages

    drop_table :tr8n_translation_sources
    drop_table :tr8n_translation_domains
    drop_table :tr8n_translation_source_metrics
    drop_table :tr8n_translation_source_languages

    drop_table :tr8n_components
    drop_table :tr8n_component_languages
    drop_table :tr8n_component_translators
    drop_table :tr8n_component_sources

    drop_table :tr8n_translators
    drop_table :tr8n_translator_languages
    drop_table :tr8n_translator_logs
    drop_table :tr8n_translator_metrics
    drop_table :tr8n_translator_following
    drop_table :tr8n_translator_reports
    drop_table :tr8n_notifications
    drop_table :tr8n_ip_locations

    drop_table :tr8n_translation_keys
    drop_table :tr8n_translation_key_sources
    drop_table :tr8n_translation_key_locks
    drop_table :tr8n_translation_key_comments
    drop_table :tr8n_decorators

    drop_table :tr8n_translations
    drop_table :tr8n_translation_votes

    drop_table :tr8n_forum_messages
    drop_table :tr8n_forum_topics
    drop_table :tr8n_forum_topic_languages

    drop_table :tr8n_email_templates
    drop_table :tr8n_email_logs

    drop_table :tr8n_glossary
  end
end
