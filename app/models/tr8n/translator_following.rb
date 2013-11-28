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
#-- Tr8n::TranslatorFollowing Schema Information
#
# Table name: tr8n_translator_following
#
#  id               integer                        not null, primary key
#  translator_id    integer                        
#  model_id         integer                        
#  model_type       character varying(255)         
#  created_at       timestamp without time zone    not null
#  updated_at       timestamp without time zone    not null
#
# Indexes
#
#  tr8n_tf_t    (translator_id) 
#
#++

class Tr8n::TranslatorFollowing < ActiveRecord::Base
  self.table_name = :tr8n_translator_following
  attr_accessible :translator_id, :model_id, :model_type
  attr_accessible :translator, :model

  belongs_to :translator, :class_name => "Tr8n::Translator"
  belongs_to :model, :polymorphic => true

  after_create :distribute_notification
  
  def self.find_or_create(translator, model)
    following_for(translator, model) || create(:translator => translator, :model => model)
  end

  def self.following_for(translator, model)
    where("translator_id = ? and model_type = ? and model_id = ?", translator.id, model.class.name, model.id).first
  end
  
  def distribute_notification
    Tr8n::Notification.distribute(self)    
  end

end
