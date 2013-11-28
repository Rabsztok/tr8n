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
#-- Tr8n::Notifications::TranslationKeyComment Schema Information
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

class Tr8n::Notifications::TranslationKeyComment < Tr8n::Notification

  def self.distribute(comment)
    tkey = comment.translation_key

    # find translators for all other translations of the key in this settings
    translations = Tr8n::Translation.where("translation_key_id = ? and language_id = ?", tkey.id, comment.language.id)

    translators = []
    translations.each do |t|
      translators << t.translator
    end

    translators += commenters(tkey, comment.language)
    translators += followers(tkey)
    translators += followers(comment.translator)
    translators += mentioned(comment.mentions, comment.message)

    # remove the current translator
    translators = translators.uniq - [comment.translator]

    translators.each do |t|
      create(:translator => t, :model => comment, :actor => comment.translator, :action => "commented_on_translation_key")
    end
  end

  def title
    if mentioned_translators.include?(translator)
      return tr("[link: {user}] mentioned you in a comment to a phrase.", nil,
                :user => actor, :link => {:href => actor.url}
      )
    end

    if model.translation_key.followed?
      return tr("[link: {user}] commented on a translation to a phrase you are following.", nil, 
          :user => actor, :link => {:href => actor.url}
      )
    end

    if model.translation_key.commented?(model.language)
      return tr("[link: {user}] replied to your comment.", nil, 
          :user => actor, :link => {:href => actor.url}
      )
    end

    tr("[link: {user}] commented on a phrase you've translated.", nil, 
      :user => actor, :link => {:href => actor.url}
    )
  end

  def excerpt
    :translation_key_comment
  end

  def language
    model.language
  end

end
