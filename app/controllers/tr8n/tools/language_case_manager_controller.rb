
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

class Tr8n::Tools::LanguageCaseManagerController < Tr8n::Tools::BaseController

  layout 'tr8n/tools/language_case_manager'

  # settings selector window
  def index
    @lcase = Tr8n::LanguageCase.find_by_id(params[:case_id]) if params[:case_id]
    @rule = Tr8n::LanguageCaseRule.find_by_id(params[:rule_id]) if params[:rule_id]
    @label = params[:case_key]
  end

  #
  ## used by a client app
  #def index
  #  @maps = Tr8n::LanguageCaseValueMap.where("language_id = ? and (reported is null or reported = ?)", tr8n_current_language.id, false)
  #  @maps = @maps.where("keyword like ?", "%#{params[:search]}%") unless params[:search].blank?
  #  @maps = @maps.order("updated_at desc").page(page).per(per_page)
  #end
  #
  #def manager
  #  @lcase = Tr8n::LanguageCase.by_id(params[:case_id]) unless params[:case_id].blank?
  #  @rule = Tr8n::LanguageCaseRule.by_id(params[:rule_id]) unless params[:rule_id].blank?
  #
  #  @map = Tr8n::LanguageCaseValueMap.by_language_and_keyword(tr8n_current_language, params[:case_key])
  #  @map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :translator => tr8n_current_translator, :keyword => params[:case_key])
  #
  #  @mode = params[:mode] || (@map.id.nil? ? 'rules_based' : (@map.gender_based? ? 'gender_based' : 'gender_neutral'))
  #
  #  if @mode == 'rules_based' and params[:reset] and @map.id
  #    @map.destroy
  #  end
  #
  #  render :layout => false
  #end
  #
  #def update_value_map
  #  map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) unless params[:map_id].blank?
  #  map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :reported => false)
  #  map.keyword = params[:case_key]
  #  map.map = params[:map][:map]
  #  map.save_with_log!(tr8n_current_translator)
  #
  #  redirect_to(:action => :manager, :mode => :done)
  #end
  #
  #def delete_value_map
  #  map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) if params[:map_id]
  #  map.destroy_with_log!(tr8n_current_translator) if map
  #
  #  redirect_to_source
  #end
  #
  #def report_value_map
  #  map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) unless params[:map_id].blank?
  #  map.report_with_log!(tr8n_current_translator) if map
  #
  #  redirect_to_source
  #end

end