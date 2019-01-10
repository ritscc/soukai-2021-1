class BitbucketIssueTracker

  def self.for(repository)
    new(repository)
  end

  def initialize(repository)
    @repository = repository
  end

  def create(issue)
  end

  private
  def client
    @client ||= Bitbutkect::Client.new()
  end

  private_class_method :new

end
