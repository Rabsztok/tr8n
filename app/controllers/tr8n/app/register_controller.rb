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


class Tr8n::App::RegisterController < Tr8n::App::BaseController

  skip_before_filter :validate_selected_application

  def index
    if request.post?
      default_language = Tr8n::Language.by_locale(params[:default_locale])

      app = Tr8n::Application.create(:name => params[:app][:name],
                                     :description => params[:app][:description],
                                     :url => params[:app][:url],
                                     :default_language => default_language)

      app.add_language(default_language)
      unless params[:locales].blank?
        params[:locales].split(',').each do |locale|
          app.add_language(Tr8n::Language.by_locale(locale))
        end
      end

      app_translator = app.add_translator(tr8n_current_translator)
      app_translator.make_manager!

      emails = params[:translators].strip.blank? ? [] : params[:translators].split(',')
      emails.each do |email|
        user = Tr8n::Config.user_class.find_by_email(email)
        translator = Tr8n::Translator.by_user(user) if user
        next if user == tr8n_current_user
        next if translator and Tr8n::ApplicationTranslator.by_application_and_translator(app, translator)

        req = Tr8n::Requests::InviteTranslator.where(:application_id => app.id, :email => email).first
        req ||= Tr8n::Requests::InviteTranslator.create(:application_id => app.id, :email => email)
        req.from=tr8n_current_user
        req.to=user
        req.save_and_deliver
      end

      session[:tr8n_selected_app_id] = app.id

      return redirect_to(:controller => "/tr8n/home", :action => :index, :app_id => app.id)
    end

    @app = Tr8n::Application.new
  end

end
