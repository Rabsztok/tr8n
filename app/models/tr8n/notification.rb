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
#
#-- Tr8n::Notification Schema Information
#
# Table name: tr8n_notifications
#
#  id               integer                        not null, primary key
#  type             character varying(255)         
#  translator_id    integer                        
#  actor_id         integer                        
#  target_id        integer                        
#  action           character varying(255)         
#  model_type       character varying(255)         
#  model_id         integer                        
#  viewed_at        timestamp without time zone    
#  created_at       timestamp without time zone    not null
#  updated_at       timestamp without time zone    not null
#
# Indexes
#
#  tr8n_notifs_model     (model_type, model_id) 
#  tr8n_notifs_trn_id    (translator_id) 
#
#++

class Tr8n::Notification < ActiveRecord::Base
  self.table_name = :tr8n_notifications
  attr_accessible :translator, :actor, :target, :model, :action, :viewed_at

  belongs_to :translator, :class_name => "Tr8n::Translator"

  belongs_to :actor, :class_name => "Tr8n::Translator", :foreign_key => :actor_id
  belongs_to :target, :class_name => "Tr8n::Translator", :foreign_key => :target_id
  belongs_to :model, :polymorphic => true

  def self.distribute(model)
    Tr8n::OfflineTask.schedule(self.name, :distribute_offline, {
                               :model_type => model.class.name,
                               :model_id => model.id
    })
  end

  def self.distribute_offline(opts)
    model = opts[:model_type].constantize.find_by_id(opts[:model_id])
    return unless model

    class_name = model.class.name.split("::").last
    "Tr8n::Notifications::#{class_name}".constantize.distribute(model)
  end

  def self.key(model)
    model.class.name.underscore.split("/").last
  end

  def self.commenters(tkey, language)
    Tr8n::TranslationKeyComment.where("translation_key_id = ? and language_id = ?", 
                                       tkey.id, language.id).all.collect{|f| f.translator}
  end

  def self.followers(obj)
    Tr8n::TranslatorFollowing.where("model_type = ? and model_id = ?",
                          obj.class.name, obj.id).all.collect{|f| f.translator}
  end

  def self.mentioned(mentioned_ids, message)
    return [] if mentioned_ids.blank?
    translators = []
    mentioned_ids.split(",").each do |tid|
      t = Tr8n::Translator.find_by_id(tid)
      next unless t
      next unless message.index("@#{t.name}")
      translators << t
    end
    translators
  end

  def self.translators_for_translation(translation)
    tkey = translation.translation_key

    # find translators for all other translations of the key in this settings
    tanslations = Tr8n::Translation.where("translation_key_id = ? and language_id = ?", 
                                           tkey.id, translation.language.id).all
    translators = []
    tanslations.each do |t|
      translators << t.translator
    end
    translators
  end

  def mentioned_translators
    @mentioned_translators ||= self.class.mentioned(model.mentions, model.message)
  end

  def key
    self.class.key(model)
  end

  def valid_notification?
    return false unless model
    true
  end

  def excerpt
    nil
  end

  def has_excerpt?
    not excerpt.nil?
  end

  def translation
    nil
  end

  def translation_key
    nil
  end

  def language
    nil
  end

  def mark_as_viewed!
    return unless viewed_at.nil?
    self.viewed_at = Time.now
    save
  end

  def tr(label, description = nil, tokens = {}, options = {})
    label.translate(description, tokens, options.merge(:source => "tr8n/notifications/#{key}"))
  end

  def title
    raise "#{self.class.name} must implement title method"
  end

end
