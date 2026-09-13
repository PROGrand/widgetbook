import 'package:mocktail/mocktail.dart';
import 'package:platform/testing.dart';
import 'package:test/test.dart';
import 'package:widgetbook_cli/widgetbook_cli.dart';

import '../../helper/mocks.dart';

void main() {
  const userName = 'John Doe';
  const repoName = 'widgetbook';
  const sha = '832e76a9899f560a90ffd62ae2ce83bbeff58f54';

  final ciManager = MockCiManager();

  group('$ContextManager', () {
    final repository = MockRepository();

    test('Local', () async {
      ciManager.mock();
      when(() => repository.name).thenReturn(repoName);
      when(() => repository.user).thenAnswer((_) async => userName);

      final platform = TestPlatform.native(environment: {
        'BUILD_SOURCEVERSIONAUTHOR': userName,
        'BUILD_REPOSITORY_NAME': repoName,
      });
      final contextManager = ContextManager(
        ciManager: ciManager,
        platform: platform,
      );

      expectLater(
        contextManager.load(repository),
        completion(
          Context(
            name: 'Local',
            repository: repository,
            user: userName,
            project: repoName,
          ),
        ),
      );
    });

    test('Azure', () {
      ciManager.mock(isAzure: true);
      final platform = TestPlatform.native(environment: {
        'BUILD_SOURCEVERSIONAUTHOR': userName,
        'BUILD_REPOSITORY_NAME': repoName,
      });
      final contextManager = ContextManager(
        ciManager: ciManager,
        platform: platform,
      );


      expectLater(
        contextManager.load(repository),
        completion(
          Context(
            name: 'Azure',
            repository: repository,
            user: userName,
            project: repoName,
          ),
        ),
      );
    });

    test('Bitbucket', () {
      ciManager.mock(isBitbucket: true);

      final platform = TestPlatform.native(environment: {
        'BITBUCKET_STEP_TRIGGERER_UUID': userName,
        'BITBUCKET_REPO_FULL_NAME': repoName,
      });
      final contextManager = ContextManager(
        ciManager: ciManager,
        platform: platform,
      );

      expectLater(
        contextManager.load(repository),
        completion(
          Context(
            name: 'Bitbucket',
            repository: repository,
            user: userName,
            project: repoName,
          ),
        ),
      );
    });

    test('Codemagic', () {
      ciManager.mock(isCodemagic: true);

      final platform = TestPlatform.native(environment: {
        'CM_REPO_SLUG': repoName,
        'CM_COMMIT': userName,

      });
      final contextManager = ContextManager(
        ciManager: ciManager,
        platform: platform,
      );

      expectLater(
        contextManager.load(repository),
        completion(
          Context(
            name: 'Codemagic',
            repository: repository,
            user: 'Codemagic',
            project: repoName,
            providerSha: userName,
          ),
        ),
      );
    });

    test('GitHub', () {
      ciManager.mock(isGitHub: true);

      final platform = TestPlatform.native(environment: {
        'GITHUB_ACTOR': userName,
        'GITHUB_REPOSITORY': repoName,
        'GITHUB_SHA': sha,
      });
      final contextManager = ContextManager(
        ciManager: ciManager,
        platform: platform,
      );

      expectLater(
        contextManager.load(repository),
        completion(
          Context(
            name: 'GitHub',
            repository: repository,
            user: userName,
            project: repoName,
            providerSha: sha,
          ),
        ),
      );
    });

    test('GitLab', () {
      ciManager.mock(isGitLab: true);

      final platform = TestPlatform.native(environment: {
        'GITLAB_USER_LOGIN': userName,
        'CI_PROJECT_PATH': repoName,
        'CI_COMMIT_BRANCH': 'main',
        'CI_COMMIT_SHA': sha,
      });
      final contextManager = ContextManager(
        ciManager: ciManager,
        platform: platform,
      );

      expectLater(
        contextManager.load(repository),
        completion(
          Context(
            name: 'GitLab',
            repository: repository,
            user: userName,
            project: repoName,
            providerBranch: 'main',
            providerSha: sha,
          ),
        ),
      );
    });
  });
}
