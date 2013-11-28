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
#-- Tr8n::TranslatorReport Schema Information
#
# Table name: tr8n_translator_reports
#
#  id               integer                        not null, primary key
#  translator_id    integer                        
#  state            character varying(255)         
#  model_id         integer                        
#  model_type       character varying(255)         
#  reason           character varying(255)         
#  comment          text                           
#  created_at       timestamp without time zone    not null
#  updated_at       timestamp without time zone    not null
#
# Indexes
#
#  tr8n_tr_t    (translator_id) 
#
#++

class Tr8n::TranslatorReport < ActiveRecord::Base
  self.table_name = :tr8n_translator_reports  
  attr_accessible :translator_id, :state, :model_id, :model_type, :reason, :comment
  attr_accessible :translator, :model

  belongs_to :translator, :class_name => "Tr8n::Translator"
  belongs_to :model, :polymorphic => true

  def self.find_or_create(translator, model)
    report_for(translator, model) || create(:translator => translator, :model => model)
  end

  def self.report_for(translator, model)
    self.where("translator_id = ? and model_type = ? and model_id = ?", translator.id, model.class.name, model.id).first
  end
  
  def self.title_for(model)
    model.class.name.underscore.split('_').collect{|item| item.capitalize}.join(' ')
  end
  
  def self.default_reasons_for(model)
    if model.is_a?(Tr8n::TranslationKey)
      return ['Bad Grammar', 'Bad Tokens', 'Premature Lock', 'Other:']
    end

    if model.is_a?(Tr8n::Translation)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if model.is_a?(Tr8n::Translator)
      return ['Spammer', 'Vandalist', 'Bully', 'Other:']
    end

    if model.is_a?(Tr8n::Forum::Message)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if model.is_a?(Tr8n::Forum::Topic)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if model.is_a?(Tr8n::TranslationKeyComment)
      return ['Inappropriate Language', 'Spam', 'Vandalism', 'Other:']
    end
    
    ['Inappropriate Language']
  end

  def self.submit(translator, model, reason, comment)
    report = find_or_create(translator, model)
    report.update_attributes(:reason => reason, :comment => comment)
    
    if model.is_a?(Tr8n::Translation)
      model.vote!(translator, -100)
      submit(translator, model.translator, "bad translation #{model.id}", comment)
    elsif model.is_a?(Tr8n::Forum::Message)
      submit(translator, model.translator, "bad message #{model.id}", comment)
    end
  end
  
end
