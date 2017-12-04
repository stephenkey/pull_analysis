class Pull
  include ActiveModel::Model
  attr_accessor :all, :list, :find

  BASE_URL = "https://#{Rails.application.secrets.github_username}:#{Rails.application.secrets.github_token}@api.github.com/"
  PER_PAGE = 100

  # Get all pulls for an org
  def self.all(*repos)
    repos.map { |repo| get_pull_request_pages("#{BASE_URL}repos/#{repo}/pulls?per_page=#{PER_PAGE}") }.flatten(1)
  end

  # Get all repo pull requests from paginated pages
  def self.get_pull_request_pages(url)
    response = get_page(url)
    result = JSON.parse(response.body)
    if response.headers.key?(:link)
      next_url = extract_next_url(response.headers[:link])
      result.push(*get_pull_request_pages(next_url)) if next_url
    end
    return result
  end

  # Extract next url from headers for paginated results
  def self.extract_next_url(headers_link)
    links = headers_link.split(',')
    links.each do |link|
      if link.include?('rel="next"')
        return link[/<(.*?)>/, 1]
      end
    end
    nil
  end

  # Get a page of pull requests
  def self.get_page(url)
    begin
      response = RestClient.get url
    rescue RestClient::ExceptionWithResponse => e
      puts "RestClient Error: #{e}"
      return []
    else
      return response
    end
  end

  # Get a single pull
  def self.find(repo, number)
    Rails.cache.fetch("#{repo}_pull_#{number}", expires_in: 2.hours) do
      begin
        response = RestClient.get "#{BASE_URL}repos/#{repo}/pulls/#{number}"
      rescue RestClient::ExceptionWithResponse => e
        puts "RestClient Error: #{e}"
        return nil
      else
        return JSON.parse(response)
      end
    end
  end

end
