module ApplicationHelper
  def custom_flash_messages
    html_script = '<script>'
    flash.each do |type, message|
      html_script += "toastr[\"#{toastr_class_for(type)}\"](\"#{message}\");" if message
    end
    html_script += '</script>'
    flash_present = flash.to_h.any?
    flash.clear
    flash_present ? html_script.html_safe : ''
  end

  def toastr_class_for(flash_type)
    type = {
      success: 'success',
      error: 'error',
      alert: 'warning',
      notice: 'info'
    }

    type[flash_type.to_sym]
  end
end
