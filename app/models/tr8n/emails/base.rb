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
#-- Tr8n::Emails::Base Schema Information
#
# Table name: tr8n_email_templates
#
#  id                INTEGER         not null, primary key
#  application_id    integer         
#  language_id       integer         
#  keyword           varchar(255)    
#  name              varchar(255)    
#  description       varchar(255)    
#  subject           varchar(255)    
#  html_body         text            
#  tokens            text            
#  created_at        datetime        not null
#  updated_at        datetime        not null
#  text_body         text            
#  type              varchar(255)    
#  parent_id         integer         
#
# Indexes
#
#  tr8n_et_t_a    (type, application_id, keyword) 
#
#++

class Tr8n::Emails::Base < ActiveRecord::Base
  self.table_name = :tr8n_email_templates

  attr_accessible :application, :language, :keyword, :subject, :html_body, :text_body, :tokens, :name, :description

  belongs_to :application, :class_name => 'Tr8n::Application'
  belongs_to :language, :class_name => 'Tr8n::Language'

  serialize :tokens

  def title
    "Template: #{keyword}"
  end

  def source
    "/emails/#{keyword}"
  end

  def content(mode)
    return self.text_body.to_s if mode.to_sym == :text
    self.html_body.to_s
  end

  def render_body(mode = :html, tokens = self.tokens, options = {})
    options[:language] ||= Tr8n::RequestContext.current_language

    Tr8n::RequestContext.render_email_with_options(options.merge(:mode => mode, :tokens => tokens, :source => source)) do
      @result = ::Liquid::Template.parse(content(mode)).render(tokens)
    end
    @result.html_safe
  end

  def render_subject(tokens = self.tokens, options = {})
    options[:language] ||= Tr8n::RequestContext.current_language

    Tr8n::RequestContext.render_email_with_options(options.merge(:tokens => tokens, :source => source)) do
      @result = ::Liquid::Template.parse(self.subject).render(tokens)
    end
    @result.html_safe
  end

  def to_api_hash(opts = {})
    {
      :keyword => keyword,
      :name => name,
      :description => description
    }
  end

end
