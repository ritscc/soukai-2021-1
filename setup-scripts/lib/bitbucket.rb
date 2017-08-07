require 'net/https'
require 'json'

module Bitbucket
  module Client
    module APIVersion
      V2_0 = '2.0'

      VALID_API_VERSIONS = [V2_0]

      def is_valid_version?(version)
        VALID_API_VERSIONS.include? version
      end

      module_function :is_valid_version?
    end

    # クライアント
    class ClientService

      def initialize(api_version, credential, open_timeout = 60, read_timeout = 60)
        unless APIVersion::is_valid_version?(api_version)
          throw ArgumentError, "#{api_version}は不正なAPIバージョンです。指定できるのは、#{APIVersion::VALID_API_VERSIONS.join(", ")}のいずれかです。"
        end

        @api_version = api_version
        @credential = credential
        @open_timeout = open_timeout
        @read_timeout = read_timeout
      end

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
            throw ArgumentError, "#{self.method}は、許可されていないメソッドです"
          end

        http_request["Content-Type"] = 'application/json'

        http_request.body = request.body unless request.body.nil?

        if [:username, :password].all? {|m| @credential.methods.include?(m) }
          http_request.basic_auth(@credential.username, @credential.password)
        else
          throw TypeError, "認証情報に期待するメソッドが存在しません"
        end

        http_response = http_client.request(http_request)

        response_class.from_http_response http_response
      end

      private
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

    # 一般化された要求
    class GenericRequest
      def initialize(method, path, body)
        @method = method.to_s.upcase.to_sym
        @path = path.to_s
        @body = body.to_s
      end

      attr_reader :method, :path, :body
    end

    # 一般化された応答
    class GenericResponse
    end

    # パスワード認証情報
    class PasswordCredential
      def initialize(username, password)
        @username = username
        @password = password
      end # PasswordCredential

      attr_reader :username, :password
    end

    # 課題作成要求
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
      def self.from_http_response(response)
        puts http_response.body
        # todo implement
      end
    end
  end

  # ユーザ
  class User
    def initialize(username)
      @username = username
    end

    attr_reader :username
  end

  # リポジトリ
  class Repository
    def initialize(user, repo_slug)
      @user  = user
      @repo_slug = repo_slug
    end

    attr_accessor :user, :repo_slug
  end

  # 課題
  class Issue
    # 状態
    class State
      def initialize(string: )
        @string = string
      end

      def to_s
        @string
      end

      NEW = self.new(string: 'new').freeze

      private_class_method :new
    end

    # 優先度
    class Priority
      def initialize(string: )
        @string = string
      end

      def to_s
        @string
      end

      TRIVIAL  = self.new(string: 'trivial').freeze
      MINOR    = self.new(string: 'minor').freeze
      MAJOR    = self.new(string: 'major').freeze
      CRITICAL = self.new(string: 'critical').freeze
      BLOCKER  = self.new(string: 'blocker').freeze

      private_class_method :new
    end

    # 種別
    class Kind
      def initialize(string: )
        @string = string
      end

      def to_s
        @string
      end

      BUG         = self.new(string: 'bug').freeze
      ENHANCEMENT = self.new(string: 'enchancement').freeze
      PROPOSAL    = self.new(string: 'proposal').freeze
      TASK        = self.new(string: 'task').freeze

      private_class_method :new
    end

    def initialize(title, content = nil, responsible = nil, state = State::NEW, priority = Priority::MAJOR, kind = Kind::TASK)
      @title       = title
      @content     = content
      @responsible = responsible
      @state       = state
      @priority    = priority
      @kind        = kind
    end

    attr_reader :title, :content, :responsible, :state, :priority, :kind
  end
end
