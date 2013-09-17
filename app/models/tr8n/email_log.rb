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
#-- Tr8n::ApplicationLanguage Schema Information
#
# Table name: tr8n_application_languages
#
#  id                INTEGER     not null, primary key
#  application_id    integer     not null
#  feature_id        integer     not null
#  created_at        datetime    not null
#  updated_at        datetime    not null
#
# Indexes
#
#  tr8n_app_lang_app_id    (application_id)
#
#++

class Tr8n::EmailLog < ActiveRecord::Base
  self.table_name = :tr8n_email_logs

  attr_accessible :application, :language, :translator, :email, :sent_at, :viewed_at

  belongs_to :email_template, :class_name => 'Tr8n::EmailTemplate'
  belongs_to :language, :class_name => 'Tr8n::Language'

  belongs_to :from, :class_name => Tr8n::Config.user_class_name, :foreign_key => :from_user_id
  belongs_to :to, :class_name => Tr8n::Config.user_class_name, :foreign_key => :to_user_id

  serialize :tokens


end