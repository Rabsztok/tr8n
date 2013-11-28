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
#-- Tr8n::Notifications::TranslationVote Schema Information
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

class Tr8n::Notifications::TranslationVote < Tr8n::Notification

  def self.distribute(vote)
    return if vote.translation.translator == vote.translator

    last_notification = find(:first,
        :conditions => ["model_type = ? and model_id = ?", vote.class.name, vote.id],
        :order => "updated_at desc")

    return if last_notification and last_notification.updated_at > Time.now - 5.minutes

    tkey = vote.translation.translation_key
    translators = translators_for_translation(vote.translation)

    # find all translators who follow the key
    translators += followers(tkey)
    translators += followers(vote.translator)

    # remove the current dashboard
    translators = translators.uniq - [vote.translator]

    translators.each do |t|
     create(:translator => t, :model => vote, :actor => vote.translator, :action => "voted_on_translation")
    end
  end

  def verb(vote)
    return "likes" if vote.vote > 0
    "does not like"
  end

  def title
    if model.translation.translation_key.followed?
      return tr("[link: {user}] #{verb(model)} a translation to a phrase you are following.", nil,
          :user => actor, :link => {:href => actor.url}
      )
    end

    if model.translation.translator == Tr8n::RequestContext.current_translator
      return tr("[link: {user}] #{verb(model)} your translation.", nil,
        :user => actor, :link => {:href => actor.url}
      )
    end

    if self.class.translators_for_translation(model.translation).include?(translator)
      return tr("[link: {user}] #{verb(model)} an alternative translation to a phrase you've translated.", nil,
        :user => actor, :link => {:href => actor.url}
      )
    end

    tr("[link: {user}] #{verb(model)} a translation.", nil,
      :user => actor, :link => {:href => actor.url}
    )
  end

  def excerpt
    :translation
  end

  def translation
    model.translation
  end

  def language
    translation.language
  end
end
