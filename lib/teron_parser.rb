require "selenium-webdriver"
require "open-uri"

class TeronParser
  LOGIN_URL = "http://teron.ru/index.php?app=core&module=global&section=login".freeze
  LIST_OF_USER_BY_MESSAGES_COUNT_URL = "http://teron.ru/index.php?app=members&module=list&app=members&module=list&showall=0&sort_key=members_display_name&sort_order=asc&max_results=20&quickjump=0&sort_key=posts&sort_order=desc".freeze
  LIST_OF_USER_BY_ALPHABET_URL = "http://teron.ru/index.php?app=members&module=list&app=members&module=list&showall=0&sort_key=posts&sort_order=desc&max_results=20&quickjump=0&sort_key=members_display_name&sort_order=asc".freeze
  SEARCH_URL = "http://teron.ru/index.php?app=core&module=search&do=search&fromMainBar=1".freeze

  class << self
    def login(username = GLOBAL[:teron_username], password = GLOBAL[:teron_password])
      # TeronParser.login("tjn81331", "tjn81331@posdz.com")

      # @driver = Selenium::WebDriver.for :phantomjs
      @driver = Selenium::WebDriver.for :firefox

      @driver.navigate.to LOGIN_URL

      username_field = @driver.find_element(id: "username")
      username_field.send_keys(username)
      password_field = @driver.find_element(id: "password")
      password_field.send_keys(password)

      @driver.find_element(class: "input_submit").click
    end

    def get_unreaded_messages(username, password)
      # TeronParser.get_unreaded_messages("tjn81331", "tjn81331@posdz.com")

      login(username, password)

      @driver.navigate.to "http://teron.ru/index.php"

      other_info = @driver.find_element(id: "user_other")
      raw_count = other_info.find_element(id: "new_message")
      count = raw_count.text.gsub(/[()]/, "")

      @driver.quit
    end

    def most_active_users
      # TeronParser.most_active_users

      login

      @driver.navigate.to LIST_OF_USER_BY_MESSAGES_COUNT_URL

      first_page = true
      need_next_page = false

      while first_page || need_next_page
        first_page = false

        next_page(need_next_page)

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

      @driver.quit
    end

    def all_users(max_pages = 3)
      # TeronParser.all_users

      login

      @driver.navigate.to LIST_OF_USER_BY_ALPHABET_URL

      first_page = true
      need_next_page = false
      page_number = 1

      while first_page || need_next_page
        break if page_number > max_pages

        first_page = false

        next_page(need_next_page)

        need_next_page = false

        parse_members

        list_of_members_ids = []
        @list_of_member.each_with_index do |member, i|
          id = member.attribute("id").delete("member_id_")
          username = member.text.split[0]

          need_next_page = true if i == 19

          list_of_members_ids << [id, username]
        end

        page_number += 1
      end

      list_of_members_ids.each do |id, username|
        profile_url = "http://teron.ru/index.php?showuser=#{id}"
        @driver.navigate.to profile_url

        form = @driver.find_element(id: "userBg")
        avatar_scr = form.find_element(class: "photo").attribute("src")
        file_path = "tmp/images/image_#{id + '.' + avatar_scr.split(".")[-1]}"
        open(file_path, "wb") do |file|
          file << open(avatar_scr).read
        end

        user = ForumUser.find_or_create_by(username: username)
        user.profile_url = profile_url
        user.avatar = File.open(file_path)
        user.save

        @driver.navigate.back
      end

      @driver.quit
    end

    def search_topics(query, max_pages = 2)
      # TeronParser.search_topics("щенки мопсов")

      login

      @driver.navigate.to SEARCH_URL

      search_input = @driver.find_element(id: "query")
      search_input.send_keys(query)
      @driver.find_element(name: "submit").click

      first_page = true
      need_next_page = false
      page_number = 1
      topics_data = []

      while first_page || need_next_page
        break if page_number > max_pages

        first_page = false

        next_page(need_next_page)

        tbody = @driver.find_element(tag_name: "tbody")
        topics = tbody.find_elements(tag_name: "tr")

        need_next_page = topics[25].present? ? true : false

        topics.each do |topic|
          next if topic.attribute("id").empty?

          id = topic.attribute("id").delete("trow_")
          url = "http://teron.ru/index.php?showtopic=#{id}"
          messages_count = topic.find_elements(tag_name: "td")[4].find_elements(tag_name: "li")[0].text.gsub(/\D/, '')

          raw_subject = topic.find_elements(tag_name: "td")[1].find_elements(tag_name: "a")
          subject = if raw_subject[1].try(:text).present?
            raw_subject[1].text
          elsif raw_subject[2].try(:text).present?
            raw_subject[2].text
          else
            raw_subject[3].text
          end

          topics_data << { url: url, replies_count: messages_count, title: subject }
        end

        page_number += 1
      end

      topics_data.each do |data|
        @driver.navigate.to data[:url]
        data[:body] = @driver.find_element(class: "entry-content").text
      end

      @driver.quit

      return topics_data
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

    def next_page(need_next_page)
      if need_next_page
        next_page_button = @driver.find_element(class: "next")
        next_page_button.click
      end
    end
  end
end
