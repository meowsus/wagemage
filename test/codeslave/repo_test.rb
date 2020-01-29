require 'test_helper'

module Codeslave
  class RepoTest < Test
    setup do
      @info = {
        full_name: 'codeslave',
        ssh_url: 'git@github.com:tubbo/codeslave.git'
      }
      @path = Dir.mktmpdir
      @repo = Repo.new(@info, @path, @branches)
    end

    test 'info attributes' do
      assert_equal 'codeslave', @repo.name
      assert_equal 'git@github.com:tubbo/codeslave.git', @repo.url
    end

    test 'clone' do
      VCR.use_cassette :git_clone do
        assert @repo.clone!
        assert File.exist?(@repo.clone_dir)
      end
    end

    test 'branches' do
      Codeslave
        .expects(:command)
        .with('git branch -a', chdir: @repo.clone_dir)
        .returns(
          status: mock(success?: true),
          stdout: <<~STDOUT
            credentials
            first-branch
            master
            print-stderr-when-running-scripts
            rugged
          * tests
            remotes/origin/HEAD -> origin/master
            remotes/origin/develop
            remotes/origin/master
            remotes/tubbo/develop
            remotes/tubbo/master
            remotes/tubbo/print-stderr-when-running-scripts
          STDOUT
        )

      assert_equal %w(develop master), @repo.branches
    end

    test 'checkout' do
      Codeslave
        .expects(:command)
        .with('git checkout refs/heads/develop', chdir: @repo.clone_dir)
        .returns(true)

      assert @repo.checkout!('refs/heads/develop')
    end

    test 'add all' do
      Codeslave.expects(:command)
               .with('git add .', chdir: @repo.clone_dir)
               .returns(true)

      assert @repo.add_all!
    end

    test 'commit' do
      Codeslave.expects(:command)
               .with('git commit -m "Test Commit"', chdir: @repo.clone_dir)
               .returns(true)

      assert @repo.commit!('Test Commit')
    end

    test 'push' do
      Codeslave.expects(:command)
               .with('git push origin HEAD', chdir: @repo.clone_dir)
               .returns(true)

      assert @repo.push!
    end

    test 'pull request' do
      url = 'https://github.com/foo/bar/baz/pulls/1'

      Codeslave
        .expects(:command)
        .with(
          'hub pull-request --no-edit -b master -r bclams',
          chdir: @repo.clone_dir
        )
        .returns(url)

      assert_equal url, @repo.pull_request!('master', %w(bclams))
    end

    test 'has changed' do
      Codeslave
        .expects(:command)
        .with('git status -s', chdir: @repo.clone_dir)
        .returns(stdout: 'A foo/bar/baz.rb', stderr: '')

      assert @repo.has_changed?

      Codeslave
        .expects(:command)
        .with('git status -s', chdir: @repo.clone_dir)
        .returns(stdout: '', stderr: '')

      refute @repo.has_changed?
    end
  end
end
