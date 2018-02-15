require_relative '../template'

class InitializeService
  README_PATH = File.expand_path('../../README.md', __FILE__)
  DOCUMENT_TEX_PATH = File.expand_path('../../README.md', __FILE__)
  ASSIGNEE_YML_PATH = File.expand_path('../../assignee.yml', __FILE__)

  # 設定を元に総会文書を初期化する
  def initialize_project(config)
    readme = ReadmeTemplate.new
    readme.date = config.project_config.date
    readme.repository = config.bitbucket_config.repository
    readme.save(README_PATH)

    document_tex = DocumentTemplate.new
    document_tex.meeting = general_config.meeting
    document_tex.save(DOCUMENT_TEX_PATH)
  end
end
