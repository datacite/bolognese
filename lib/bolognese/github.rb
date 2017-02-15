module Bolognese
  module Github
    # def get_github_metadata(url, options = {})
    #   return {} if url.blank?

    #   github_hash = github_from_url(url)
    #   repo_url = "https://api.github.com/repos/#{github_hash[:owner]}/#{github_hash[:repo]}"
    #   response = Maremma.get(repo_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

    #   return { error: 'Resource not found.', status: 404 } if response.body.fetch("errors", nil).present?

    #   author = get_github_owner(github_hash[:owner])

    #   language = response.body.fetch("data", {}).fetch('language', nil)
    #   type = language.present? && language != "HTML" ? 'computer_program' : 'webpage'

    #   { "author" => [get_one_author(author)],
    #     "title" => response.body.fetch("data", {}).fetch('description', nil).presence || github_hash[:repo],
    #     "container-title" => "Github",
    #     "issued" => response.body.fetch("data", {}).fetch('created_at', nil).presence || "0000",
    #     "URL" => url,
    #     "type" => type }
    # end

    # def get_github_owner_metadata(url, options = {})
    #   return {} if url.blank?

    #   github_hash = github_from_url(url)
    #   owner_url = "https://api.github.com/users/#{github_hash[:owner]}"
    #   response = Maremma.get(owner_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

    #   return { error: 'Resource not found.', status: 404 } if response.body.fetch("data", {}).fetch("message", nil) == "Not Found"

    #   author = response.body.fetch("data", {}).fetch('name', nil).presence || github_hash[:owner]
    #   title = "Github profile for #{author}"

    #   { "author" => [get_one_author(author)],
    #     "title" => title,
    #     "container-title" => "Github",
    #     "issued" => response.body.fetch("data", {}).fetch('created_at', nil).presence || "0000",
    #     "URL" => url,
    #     "type" => 'entry' }
    # end

    # def get_github_release_metadata(url, options = {})
    #   return {} if url.blank?

    #   github_hash = github_from_url(url)
    #   release_url = "https://api.github.com/repos/#{github_hash[:owner]}/#{github_hash[:repo]}/releases/tags/#{github_hash[:release]}"
    #   response = Maremma.get(release_url, options.merge(bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

    #   return { error: 'Resource not found.', status: 404 } if response.body.fetch("data", {})["message"] == "Not Found"

    #   author = get_github_owner(github_hash[:owner])

    #   { "author" => [get_one_author(author)],
    #     "title" => response.body.fetch("data", {}).fetch('name', nil),
    #     "container-title" => "Github",
    #     "issued" => response.body.fetch("data", {}).fetch('created_at', nil).presence || "0000",
    #     "URL" => url,
    #     "type" => 'computer_program' }
    # end

    # def get_github_owner(owner)
    #   url = "https://api.github.com/users/#{owner}"
    #   response = Maremma.get(url, bearer: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])

    #   return nil if response.body.fetch("data", {}).fetch("message", nil) == "Not Found"

    #   response.body.fetch("data", {}).fetch('name', nil).presence || owner
    # end

    # def github_from_url(url)
    #   return {} unless /\Ahttps:\/\/github\.com\/(.+)(?:\/)?(.+)?(?:\/tree\/)?(.*)\z/.match(url)
    #   words = URI.parse(url).path[1..-1].split('/')

    #   { owner: words[0],
    #     repo: words[1],
    #     release: words[3] }.compact
    # end

    # def github_repo_from_url(url)
    #   github_from_url(url).fetch(:repo, nil)
    # end

    # def github_release_from_url(url)
    #   github_from_url(url).fetch(:release, nil)
    # end

    # def github_owner_from_url(url)
    #   github_from_url(url).fetch(:owner, nil)
    # end

    # def github_as_owner_url(github_hash)
    #   "https://github.com/#{github_hash[:owner]}" if github_hash[:owner].present?
    # end

    # def github_as_repo_url(github_hash)
    #   "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}" if github_hash[:repo].present?
    # end

    # def github_as_release_url(github_hash)
    #   "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}/tree/#{github_hash[:release]}" if github_hash[:release].present?
    # end
  end
end
