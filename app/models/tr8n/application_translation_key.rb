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
#-- Tr8n::ApplicationTranslationKey Schema Information
#
# Table name: tr8n_application_translation_keys
#
#  id                    integer                        not null, primary key
#  application_id        integer                        
#  translation_key_id    integer                        
#  created_at            timestamp without time zone    not null
#  updated_at            timestamp without time zone    not null
#  translator_id         integer                        
#
# Indexes
#
#  tr8n_atk_a     (application_id) 
#  tr8n_atk_tk    (translation_key_id) 
#
#++

class Tr8n::ApplicationTranslationKey < ActiveRecord::Base
  self.table_name = :tr8n_application_translation_keys
  attr_accessible :application, :translation_key, :translator

  belongs_to :application, :class_name => 'Tr8n::Application'
  belongs_to :translation_key, :class_name => 'Tr8n::TranslationKey'
  belongs_to :translator, :class_name => 'Tr8n::Translator'

  def self.by_application_and_translation_key(application, translation_key)
    where("application_id = ? and translation_key_id = ?", application.id, translation_key.id).first
  end

  def self.find_or_create(application, translation_key, translator = nil)
    by_application_and_translation_key(application, translation_key) || create(:application => application, :translation_key => translation_key, :translator => translator)
  end

end
