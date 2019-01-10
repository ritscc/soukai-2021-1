# frozen_string_literal: true

require 'net/https'
require 'json'

module Bitbucket
  class Client
    module APIVersion
      V2_0 = '2.0'

      VALID_API_VERSIONS = [V2_0]

      def is_valid_version?(version)
        VALID_API_VERSIONS.any? {|e| e.equal? version }
      end

      module_function :is_valid_version?
    end

    class Requester
      def initialize(api_version, credential, open_timeout = 60, read_timeout = 60)
        unless APIVersion::is_valid_version?(api_version)
          raise ArgumentError, "#{api_version}は不正なAPIバージョンです。指定できるのは、#{APIVersion::VALID_API_VERSIONS.join(", ")}のいずれかです。"
        end

        @api_version = api_version
        @credential = credential
        @open_timeout = open_timeout
        @read_timeout = read_timeout
      end

      private
      def request(request, response_class)
        path = "/#{@api_version}" + request.path

        http_request =
          case request.method
          when :GET
            Net::HTTP::Get.new(path)
          when :POST
            Net::HTTP::Post.new(path)
          when :PUT
            Net::HTTP::Put.new(path)
          when :PATCH
            Net::HTTP::Patch.new(path)
          else
            raise ArgumentError, "#{self.method}は、許可されていないHTTPメソッドです。"
          end

        http_request["Content-Type"] = 'application/json'

        http_request.body = request.body unless request.body.nil?

        if [:username, :password].all? {|m| @credential.methods.include?(m) }
          http_request.basic_auth(@credential.username, @credential.password)
        else
          raise TypeError, "認証情報に期待するメソッドが存在しません。"
        end

        http_response = http_client.request(http_request)

        response_class.from_http_response http_response
      end

      def http_client
        if @client.nil?
          @client = Net::HTTP.new("api.bitbucket.org", Net::HTTP.https_default_port)
          @client.use_ssl = true
          @client.ssl_version = 'TLSv1_2_client'
          @client.open_timeout = @open_timeout
          @client.read_timeout = @read_timeout
        end

        @client
      end
    end

    # パスワード認証情報
    #
    # このクラスを使用する際は、ユーザ自体のパスワードではなく、
    # 用途ごとに生成できるアプリパスワードの利用を推奨します。
    class PasswordCredential
      attr_reader :username, :password

      def initialize(username, password)
        @username = username
        @password = password
      end
    end

    # 一般リクエスト
    class GenericRequest
      def method
        raise NotImplementedError
      end

      def path
        raise NotImplementedError
      end

      def body
        raise NotImplementedError
      end
    end

    # 一般レスポンス
    class GenericResponse
      def self.parse(response)
        raise NotImplementedError
      end
    end

    # 課題作成リクエスト
    class IssueCreateRequest < GenericRequest
      def initialize(repository, issue)
        @repository = repository
        @issue = issue

      end

      def method
        :POST
      end

      def path
        username = @repository.user.username
        repo_slug = @repository.repo_slug

        "/repositories/#{username}/#{repo_slug}/issues"
      end

      def body
        if @body.nil?
          @body = {}
          @body["title"]    = @issue.title
          @body["priority"] = @issue.priority.to_s
          @body["kind"]     = @issue.kind.to_s
          @body["state"]    = @issue.state.to_s
          @body["content"]  = @issue.content if @issue.content
        end

        JSON.dump @body
      end
    end

    # 課題作成応答
    class IssueCreateResponse < GenericResponse
      def self.parse(response)
        puts http_response.body
        # todo implement
      end

      def initialize()
      end
    end

    def initailize()
    end
  end
end
