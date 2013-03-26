class Repo extends Minimongoid
  @_collection: new Meteor.Collection 'repos'

class Commit extends Minimongoid
  @_collection: new Meteor.Collection 'commits'

Meteor.methods 
  getGithubCommits: (repo) ->
    result = undefined

    lastCommit = Commit.findOne({repo_id: repo._id, sort: {date: -1}})

    @unblock()

    params = 
      client_id: _GITHUB_ID,
      client_secret: _GITHUB_SECRET

    if (lastCommit)
      params.since = lastCommit.date.toJSON

    result = Meteor.http.call("GET", "https://api.github.com/repos/dreamyourweb/#{repo.name}/commits",
      params: params
        
    )
    if result.statusCode is 200
      for i, commit of result.data
        console.log commit

        new_commit =  
          repo_id: repo._id
          sha: commit.sha
          repo_name: repo.name
          commiter: commit.commit.committer.name
          date: commit.commit.committer.date
          messge: commit.message

        if commit.committer != undefined && commit.committer != null
          new_commit.gravatar_url = commit.committer.avatar_url
          new_commit.gravatar_id = commit.committer.gravatar_id

        console.log (old_commit = Commit.findOne({sha: commit.sha}))
        if old_commit != undefined
          console.log old_commit.update new_commit
        else
          console.log Commit.create new_commit

      return result

    false

  getGithubRepos: ->
    result = undefined
    @unblock()
    result = Meteor.http.call("GET", "https://api.github.com/orgs/dreamyourweb/repos",
      params:
        client_id: _GITHUB_ID,
        client_secret: _GITHUB_SECRET
    )
    if result.statusCode is 200
      for i, repo of result.data
        repo.github_id = repo.id
        delete repo['id']
        console.log (old_repo = Repo.findOne({github_id: repo.github_id}))
        if old_repo != undefined
          console.log old_repo.update repo
        else
          console.log Repo.create repo

      return result

    false

  getAllGithubCommits: ->
    for i, repo of Repo.all()
      Meteor.call 'getGithubCommits', repo

  destroyGithubRepos: ->
    Repo.destroyAll()

  destroyGithubCommits: ->
    Commit.destroyAll()
