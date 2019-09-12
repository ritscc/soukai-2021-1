import unittest

from setup import setup_create_issues as create_issues
from setup import setup_config as config

class SetupCreateIsuuesTest(unittest.TestCase):
    def setUp(self):
        # 初期化処理
        pass

    def tearDown(self):
        # 終了処理
        pass

    def test_get_created_issue_titles(self):
        issues: list = [
            {
                'id': 24715121,
                'iid': 2,
                'project_id': 13652541,
                'title': 'test',
                'description': None,
                'state': 'opened',
                'created_at': '2019-09-12T07:00:31.010Z',
                'updated_at': '2019-09-12T07:00:31.010Z',
                'closed_at': None,
                'closed_by': None,
                'labels': [],
                'milestone': None,
                'assignees': [
                    {
                        'id': 4203099,
                        'name': 'Yukiho Yoshieda',
                        'username': 'yukiho-YOSHIEDA',
                        'state': 'active',
                        'avatar_url': 'https://assets.gitlab-static.net/uploads/-/system/user/avatar/4203099/avatar.png',
                        'web_url': 'https://gitlab.com/yukiho-YOSHIEDA'
                    }
                ],
                'author': {
                    'id': 4239957,
                    'name': 'RCC Master',
                    'username': 'ritscc_master',
                    'state': 'active',
                    'avatar_url': 'https://assets.gitlab-static.net/uploads/-/system/user/avatar/4239957/avatar.png',
                    'web_url': 'https://gitlab.com/ritscc_master'
                },
                'assignee': {
                    'id': 4203099,
                    'name': 'Yukiho Yoshieda',
                    'username': 'yukiho-YOSHIEDA',
                    'state': 'active',
                    'avatar_url': 'https://assets.gitlab-static.net/uploads/-/system/user/avatar/4203099/avatar.png',
                    'web_url': 'https://gitlab.com/yukiho-YOSHIEDA'
                },
                'user_notes_count': 0,
                'merge_requests_count': 0,
                'upvotes': 0,
                'downvotes': 0,
                'due_date': None,
                'confidential': False,
                'discussion_locked': None,
                'web_url': 'https://gitlab.com/ritscc/system_management/sokai-y-test/issues/2',
                'time_stats': {
                    'time_estimate': 0,
                    'total_time_spent': 0,
                    'human_time_estimate': None,
                    'human_total_time_spent': None
                },
                'task_completion_status': {
                    'count': 0,
                    'completed_count': 0
                },
                'has_tasks': False,
                '_links': {
                    'self': 'https://gitlab.com/api/v4/projects/13652541/issues/2',
                    'notes': 'https://gitlab.com/api/v4/projects/13652541/issues/2/notes',
                    'award_emoji': 'https://gitlab.com/api/v4/projects/13652541/issues/2/award_emoji',
                    'project': 'https://gitlab.com/api/v4/projects/13652541'
                }
            },
            {
                'id': 24710054,
                'iid': 1,
                'project_id': 13652541,
                'title': 'test2',
                'description': None,
                'state': 'opened',
                'created_at': '2019-09-12T02:14:41.437Z',
                'updated_at': '2019-09-12T02:23:11.685Z',
                'closed_at': None,
                'closed_by': None,
                'labels': [],
                'milestone': None,
                'assignees': [
                    {
                        'id': 4203099,
                        'name': 'Yukiho Yoshieda',
                        'username': 'yukiho-YOSHIEDA',
                        'state': 'active',
                        'avatar_url': 'https://assets.gitlab-static.net/uploads/-/system/user/avatar/4203099/avatar.png',
                        'web_url': 'https://gitlab.com/yukiho-YOSHIEDA'
                    }
                ],
                'author': {
                    'id': 4239957,
                    'name': 'RCC Master',
                    'username': 'ritscc_master',
                    'state': 'active',
                    'avatar_url': 'https://assets.gitlab-static.net/uploads/-/system/user/avatar/4239957/avatar.png',
                    'web_url': 'https://gitlab.com/ritscc_master'
                },
                'assignee': {
                    'id': 4203099,
                    'name': 'Yukiho Yoshieda',
                    'username': 'yukiho-YOSHIEDA',
                    'state': 'active',
                    'avatar_url': 'https://assets.gitlab-static.net/uploads/-/system/user/avatar/4203099/avatar.png',
                    'web_url': 'https://gitlab.com/yukiho-YOSHIEDA'
                },
                'user_notes_count': 0,
                'merge_requests_count': 0,
                'upvotes': 0,
                'downvotes': 0,
                'due_date': None,
                'confidential': False,
                'discussion_locked': None,
                'web_url': 'https://gitlab.com/ritscc/system_management/sokai-y-test/issues/1',
                'time_stats': {
                    'time_estimate': 0,
                    'total_time_spent': 0,
                    'human_time_estimate': None,
                    'human_total_time_spent': None
                },
                'task_completion_status': {
                    'count': 0,
                    'completed_count': 0
                },
                'has_tasks': False,
                '_links': {
                    'self': 'https://gitlab.com/api/v4/projects/13652541/issues/1',
                    'notes': 'https://gitlab.com/api/v4/projects/13652541/issues/1/notes',
                    'award_emoji': 'https://gitlab.com/api/v4/projects/13652541/issues/1/award_emoji',
                    'project': 'https://gitlab.com/api/v4/projects/13652541'
                }
            }
        ]
        issue_titles: list = ['test', 'test2']
        self.assertEqual(issue_titles, create_issues.get_created_issue_titles(issues))

    def test_get_uri_with_query(self):
        uri: str = config.GITLAB_BASE_URI + '/projects/114514/issues'
        query: dict = {
            'title': 'title',
            'description': 'description',
            'assignee_ids': 'assignee_id'
        }
        uri_with_query: str = uri + '?title=title&description=description&assignee_ids=assignee_id';
        self.assertEqual(uri_with_query, create_issues.get_uri_with_query(uri, query))

    def test_correct_is_issue_already_created(self):
        issue_titles: list = ['soukatsu/system/1_zentai.tex:全体総括', 'houshin/4kai.tex:4回生方針', 'hajimeni.tex:はじめに']
        title: str = 'soukatsu/system/1_zentai.tex:全体総括'
        self.assertTrue(create_issues.is_issue_already_created(title, issue_titles))

    def test_incorrect_is_issue_already_created(self):
        issue_titles: list = ['soukatsu/system/1_zentai.tex:全体総括', 'houshin/4kai.tex:4回生方針', 'hajimeni.tex:はじめに']
        title: str = 'houshin/system/1_zentai.tex:全体総括'
        self.assertFalse(create_issues.is_issue_already_created(title, issue_titles))

