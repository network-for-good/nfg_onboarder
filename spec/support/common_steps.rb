def scroll_to_element(element)
  # - 50 is added b/c of the header nav
  page.execute_script("$('html, body').scrollTop($('#{element}').offset().top - 50);")
end

def select_all
  find('#select_all_checkbox').click
end

def click_radio_button_by_input_id(input_id)
  scroll_to_element "##{input_id}"
  radio_button = find("##{input_id}", visible: false)
  radio_button.find(:xpath, '..').click
end

def test_mobile_version(device = 'mobile')
  resize_window_to_xs # ensure we also pickup responsive changes
  allow_any_instance_of(Browser).to receive("#{device}?").and_return(true)
  page.driver.browser.navigate.refresh
end

def close_alert
  find(".alert button.close").click
end

def accept_alert
  page.driver.browser.switch_to.alert.accept
end

# Used on view specs to render the page so you can see what the spec is looking at
def save_and_open_view_spec_response(html = rendered)
  File.open('/tmp/test.html','w'){|file| file.write(html)}; `open '/tmp/test.html'`
end

def fill_in_date_picker(date_id, date)
  # the pledge id passed in should not include the '#'
  page.execute_script("$('##{ date_id }').datetimepicker('date', '#{date}')")
end
