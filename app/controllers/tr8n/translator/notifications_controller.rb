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

class Tr8n::Translator::NotificationsController < Tr8n::Translator::BaseController

  before_filter :validate_guest_user, :except => [:lb_notifications]
  before_filter :validate_current_translator, :except => [:lb_notifications]
  before_filter :validate_selected_application, :except => [:lb_notifications]

  def index
    @translator = Tr8n::RequestContext.current_translator
    @stories = Tr8n::Notification.where("translator_id = ?", Tr8n::RequestContext.current_translator.id).order("created_at desc").page(page).per(per_page)
  end

  def lb_notifications
    if tr8n_current_translator
      @stories = Tr8n::Notification.where("translator_id = ?", Tr8n::RequestContext.current_translator.id).order("created_at desc").limit(10).page(page).per(per_page)
    end
    render_lightbox
  end

  def delete_notification
    n = Tr8n::Notification.find_by_id(params[:id])
    if n.nil? or n.translator != tr8n_current_translator
      return redirect_to_source
    end
    n.destroy
    redirect_to_source
  end

end