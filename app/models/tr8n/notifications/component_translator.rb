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
#-- Tr8n::Notifications::ComponentTranslator Schema Information
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

class Tr8n::Notifications::ComponentTranslator < Tr8n::Notification

  def self.distribute(ct)
    create(:translator => ct.translator,
      :model => ct,
      :target => ct.translator, 
      :action => "got_assigned_to_component")
  end

  def title
    tr("You were assigned to translate a component.")
  end

  def excerpt
    :component_translator
  end
end
