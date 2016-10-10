# coding: utf-8

require 'readline'
require 'net/https'
require 'open-uri'
require 'io/console'
require 'json'
require 'base64'
require 'cgi'

class Bitbucket
  def initialize(repo_username, repo_slug, user, passwd)
    @repo_username = repo_username
    @repo_slug = repo_slug
    @user = user
    @passwd = passwd
  end

  def get_pullreq_list
    list = []
    page = 1
    loop do
      json = request_json('get', pullreq_path, '2.0', state: 'OPEN', pagelen: 50, page: page)
      list.concat(json[:values])
      page += 1
      break if json[:next].nil?
    end
    list
  end

  def get_pullreq_comment(pullreq_id)
    list = []
    page = 1
    loop do
      json = request_json('get', pullreq_path + "/#{pullreq_id}/comments", '2.0', pagelen: 50, page: page)
      list.concat(json[:values])
      page += 1
      break if json[:next].nil?
    end
    list
  end

  def send_pullreq_comment(pullreq_id, content, comment = nil)
    method = comment ? 'put' : 'post'
    path = pullreq_path + "/#{pullreq_id}/comments"
    path += "/#{comment[:id]}" if comment
    request_json(method, path, '1.0', content: content)
  end

  private

  def http_request(method, uri, query_hash = {})
    uri = URI.parse(uri) if uri.is_a? String
    method = method.to_s.strip.downcase
    query_string = (query_hash || {}).map{|k, v|
      CGI.escape(k.to_s) + '=' + CGI.escape(v.to_s)
    }.join('&')

    args =
      if method == 'post'
        [Net::HTTP::Post.new(uri.path), query_string]
      elsif method == 'put'
        [Net::HTTP::Put.new(uri.path), query_string]
      else
        [Net::HTTP::Get.new(uri.path + (query_string.empty? ? '' : "?#{query_string}"))]
      end
    args[0].basic_auth(@user, @passwd)

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    https.start do |http|
      http.request(*args)
    end
  end

  def base_uri(version)
    "https://api.bitbucket.org/#{version}"
  end

  def pullreq_path
    "/repositories/#{@repo_username}/#{@repo_slug}/pullrequests"
  end

  def request_json(method, path, version, params)
    res = http_request(method, base_uri(version) + path, params)
    case res
    when Net::HTTPSuccess
      JSON.parse(res.body, symbolize_names: true)
    else
      puts res.message
      puts res.body
      exit(1)
    end
  end
end

if match = `git remote -v`.match(%r{bitbucket\.org[:/]([^/]+)/([^\.]+)\.git})
  repo_username = match[1]
  repo_slug = match[2]
else
  puts 'fatal error: git repository is not found!!'
  exit(1)
end

bitbucket = Bitbucket.new(repo_username, repo_slug, ENV['BITBUCKET_USER'], Base64.decode64(ENV['BITBUCKET_PASS']).chomp)
pullreq_list = bitbucket.get_pullreq_list

branch = `git branch -a --contains`.scan(%r{.*/(.+?)$})[0][0]
pullreq = pullreq_list.find{|data| data[:source][:branch][:name] == branch}
if pullreq
  comment_list = bitbucket.get_pullreq_comment(pullreq[:id])
  comment = comment_list.find {|data| data[:user][:username] == ENV['BITBUCKET_USER']}

  errors = File.open(ARGV[0]) do |file|
    content = file.read
    content.empty? ? '' : ("\n\n```\n" + content + "\n```\n")
  end
  message =
    if ARGV[1].to_i.nonzero?
      ':x: このままではマージできません！'
    elsif errors =~ /\[ERR\]/
      ':warning: エラーが残っています。'
    else
      ':white_check_mark: マージしても問題ありません！'
    end
  bitbucket.send_pullreq_comment(pullreq[:id], message + errors, comment)
end
