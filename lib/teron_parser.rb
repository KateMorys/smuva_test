require "selenium-webdriver"

class TeronParser
  def self.login(username, password)
    # TeronParser.login("tjn81331", "tjn81331@posdz.com")

    # @driver = Selenium::WebDriver.for :phantomjs
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to "http://teron.ru/index.php?app=core&module=global&section=login"
    username_field = @driver.find_element(id: "username")
    username_field.send_keys(username)
    password_field = @driver.find_element(id: "password")
    password_field.send_keys(password)

    @driver.find_element(class: "input_submit").click
  end

  def self.get_unreaded_messages(username, password)
    # TeronParser.get_unreaded_messages("tjn81331", "tjn81331@posdz.com")

    login(username, password)

    @driver.navigate.to "http://teron.ru/index.php"
    other_info = @driver.find_element(id: "user_other")
    raw_count = other_info.find_element(id: "new_message")
    count = raw_count.text.gsub(/[()]/, "")
  end
end
