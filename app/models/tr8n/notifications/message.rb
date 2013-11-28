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
#-- Tr8n::Notifications::Message Schema Information
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

class Tr8n::Notifications::Message < Tr8n::Notification

  def self.distribute(message)
    # find translators for all other translations of the key in this settings
    messages = Tr8n::Forum::Message.where("topic_id = ?", message.topic.id)

    translators = []
    messages.each do |m|
      translators << m.translator
    end

    translators += followers(message.translator)
    translators += mentioned(message.mentions, message.message)

    # remove the current translator
    translators = translators.uniq - [message.translator]

    translators.each do |t|
      create(:translator => t, :model => message, :actor => message.translator, :action => "replied_to_forum_topic")
    end
  end

  def title
    if mentioned_translators.include?(translator)
      return tr("[link: {user}] mentioned you in a forum message.", nil,
                :user => actor, :link => {:href => actor.url}
      )
    end

    tr("[link: {user}] replied to a forum topic you are following.", nil,
      :user => actor, :link => {:href => actor.url}
    )
  end

  def excerpt
    :forum_message
  end

end
