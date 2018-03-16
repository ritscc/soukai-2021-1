# frozen_string_literal: true

class IssueService

  def initialize(issue_tracker)
    @issue_tracker = issue_tracker
  end

  def add_issue(issue)
    @issue_tracker.add_issue(issue)
  end

end
