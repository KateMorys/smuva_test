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

  def self.most_active_users
    # TeronParser.most_active_users

    login(GLOBAL[:teron_username], GLOBAL[:teron_password])

    @driver.navigate.to "http://teron.ru/index.php?app=members&module=list&app=members&module=list&showall=0&sort_key=members_display_name&sort_order=asc&max_results=20&quickjump=0&sort_key=posts&sort_order=desc"

    first_page = true
    need_next_page = false

    while first_page || need_next_page
      first_page = false

      next_page_button = @driver.find_element(class: "next")
      next_page_button.click if need_next_page

      need_next_page = false

      parse_members

      @list_of_member.each_with_index do |member, i|
        username = member.text.split[0]
        messages_count = member.text.gsub(/\s+/, "").split(":")[3].delete("Просмотров").to_i

        break if messages_count < GLOBAL[:teron_min_messages_count]

        need_next_page = true if i == 19 && messages_count > GLOBAL[:teron_min_messages_count]

        ForumUser.create(username: username, messages_count: messages_count)
      end
    end
  end

  private

  def parse_members
    members_wrap = @driver.find_element(id: "member_wrap")
    raw_members = members_wrap.find_element(tag_name: "ul", class: "members")

    @list_of_member = []
    raw_members.find_elements(tag_name: "li").each do |raw_member|
      @list_of_member << raw_member if raw_member.text.present?
    end
  end
end
