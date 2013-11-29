#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8nhub.com
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

class Tr8n::App::DashboardController < Tr8n::App::BaseController

  before_filter :validate_application_management

  def index
    @languages = selected_application.languages
    @language_id = params[:language_id] || tr8n_current_language.id
    @language = Tr8n::Language.find_by_id(@language_id)
    @key_count = selected_application.translation_keys.count

    @locked_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id",
                                                       :conditions => [
                                                           "atk.application_id = ? and tkl.language_id = ? and tkl.locked = ?",
                                                           selected_application.id, @language_id, true],
                                                       :joins => [
                                                           "join tr8n_application_translation_keys as atk on tr8n_translation_keys.id = atk.translation_key_id",
                                                           "join tr8n_translation_key_locks as tkl on tr8n_translation_keys.id = tkl.translation_key_id"
                                                       ]
    )

    @translated_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id",
                                                           :conditions => [
                                                               "atk.application_id = ? and t.language_id = ?",
                                                               selected_application.id, @language_id],
                                                           :joins => [
                                                               "join tr8n_application_translation_keys as atk on tr8n_translation_keys.id = atk.translation_key_id",
                                                               "join tr8n_translations as t on tr8n_translation_keys.id = t.translation_key_id"
                                                           ]
    )

    @not_translated_count = @key_count - @translated_key_count
    @pending_approval_count = @translated_key_count - @locked_key_count
  end

  def sources
    @languages = selected_application.languages
    @language_id = params[:language_id] || tr8n_current_language.id
    @language = Tr8n::Language.find_by_id(@language_id)

    @sources = selected_application.sources.order("created_at desc")
    unless params[:search].blank?
      @sources = @sources.where("lower(source) like ? or lower(name) like ? or lower(description) like ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%")
    end
    @sources = @sources.page(page).per(per_page)

  end

  def recalculate_metric
    metric = Tr8n::Metrics::TranslationSource.find_by_id(params[:id])
    unless metric
      trfe("Invalid metric id")
      return redirect_to_source
    end

    metric.update_metrics!
    trfn("The metric has been updated")
    redirect_to_source
  end

end
