module Gitlab
  class Client
    # Defines methods related to project.
    #
    # ### Project visibility level
    #
    # Project in GitLab has be either private, internal or public. You can determine it by visibility_level field in project.
    #
    # Constants for project visibility levels are next:
    #
    # - Private. visibility_level is 0. Project access must be granted explicitly for each user.
    #
    # - Internal. visibility_level is 10. The project can be cloned by any logged in user.
    #
    # - Public. visibility_level is 20. The project can be cloned without any authentication.
    #
    # See [http://docs.gitlab.com/ce/api/projects.html](http://docs.gitlab.com/ce/api/projects.html)
    #
    module Project
      # Gets a list of projects owned by the authenticated user.
      #
      # Alias to `projects`({ "scope" => "owned" })
      #
      # ```
      # client.owned_projects
      # client.owned_projects({ "order_by" => "last_activity_at", "sort" => "desc" })
      # client.owned_projects({ "search" => "keyword" })
      # ```
      def owned_projects(params : Hash? = {} of String => String)
        projects({ "scope" => "owned" }.merge(params))
      end

      # Gets a list of projects starred by the authenticated user.
      #
      # Alias to `projects`({ "scope" => "starred" })
      #
      # ```
      # client.starred_projects
      # client.starred_projects({ "order_by" => "last_activity_at", "sort" => "desc" })
      # client.starred_projects({ "search" => "keyword" })
      # ```
      def starred_projects(params : Hash = {} of String => String)
        projects({ "scope" => "starred" }.merge(params))
      end

      # Gets a list of projects by the authenticated user (admin only).
      #
      # Alias to `projects`({ "scope" => "all" })
      #
      # ```
      # client.all_projects
      # client.all_projects({ "order_by" => "last_activity_at", "sort" => "desc" })
      # client.all_projects({ "search" => "keyword" })
      # ```
      def all_projects(params : Hash = {} of String => String)
        projects({ "scope" => "all" }.merge(params))
      end

      # Gets a list of projects by the authenticated user.
      #
      # - params  [Hash] options A customizable set of options.
      # - option params [String] :scope Scope of projects. "owned" for list of projects owned by the authenticated user, "starred" for list of projects starred by the authenticated user, "all" to get all projects (admin only)
      # - option params [String] :archived if passed, limit by archived status.
      # - option params [String] :visibility if passed, limit by visibility public, internal, private.
      # - option params [String] :order_by Return requests ordered by id, name, path, created_at, updated_at or last_activity_at fields. Default is created_at.
      # - option params [String] :sort Return requests sorted in asc or desc order. Default is desc.
      # - option params [String] :search Return list of authorized projects according to a search criteria.
      # - option params [Int32] :page The page number.
      # - option params [Int32] :per_page The number of results per page.
      # - return [Array<Hash>] List of projects of the authorized user.
      #
      # ```
      # client.projects
      # client.projects({ "order_by" => "last_activity_at", "sort" => "desc" })
      # client.projects({ "scope" => "starred", "search" => "keyword" })
      # ```
      def projects(params : Hash = {} of String => String)
        scopes = %w(owned starred all)
        uri = if params.has_key?("scope") && scopes.includes?(params["scope"])
          "/projects/#{params["scope"]}"
        else
          "/projects"
        end

        get(uri, params).body.parse_json
      end

      # Gets information about a project.
      #
      # - params  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - return [Hash] Information about project.
      #
      # ```
      # client.project("gitlab")
      # ```
      def project(project : Int32|String)
        get("/projects/#{project}").body.parse_json
      end

      # Gets a list of project events.
      #
      # - params  [Int32, String] project The ID of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - params  [Hash] options A customizable set of options.
      # - option params [Int32] :page The page number.
      # - option params [Int32] :per_page The number of results per page.
      # - return [Array<Hash>] List of events under a project.
      #
      # ```
      # client.project_events(42)
      # ```
      def project_events(project : Int32|String, params : Hash? = nil)
        get("/projects/#{project}/events", params).body.parse_json
      end

      # Creates a new project for a user.
      #
      # Alias to `create_project`(params : Hash = {} of String => String)
      #
      # ```
      # client.create_project(1, "gitlab")
      # client.create_project(1, "gitlab", { "description: => "Awesome project" })
      # ```
      def create_project(user_id : Int32, name : String, params : Hash = {} of String => String)
        create_project(name, {"user_id" => user_id.to_s }.merge(params)).body.parse_json
      end

      # Creates a new project.
      #
      # - params [String] name The name of a project.
      # - params [Hash] options A customizable set of options.
      # - option params [String] :description The description of a project.
      # - option params [String] :default_branch The default branch of a project.
      # - option params [String] :namespace_id The namespace in which to create a project.
      # - option params [String] :wiki_enabled The wiki integration for a project (0 = false, 1 = true).
      # - option params [String] :wall_enabled The wall functionality for a project (0 = false, 1 = true).
      # - option params [String] :issues_enabled The issues integration for a project (0 = false, 1 = true).
      # - option params [String] :snippets_enabled The snippets integration for a project (0 = false, 1 = true).
      # - option params [String] :merge_requests_enabled The merge requests functionality for a project (0 = false, 1 = true).
      # - option params [String] :public The setting for making a project public (0 = false, 1 = true).
      # - option params [String] :user_id The user/owner id of a project.
      # - return [Hash] Information about created project.
      #
      # ```
      # client.create_project("gitlab")
      # client.create_project("viking", { "description: => "Awesome project" })
      # client.create_project("Red", { "wall_enabled" => "false" })
      # ```
      def create_project(name, params : Hash = {} of String => String)
        uri = if params.has_key?("user_id") && params["user_id"]
          "/projects/user/#{params[:user_id]}"
        else
          "/projects"
        end

        post(uri, { "name" => name }.merge(params)).body.parse_json
      end

      # Updates an existing project.
      #
      # - params [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - params [Hash] options A customizable set of options.
      # - option params [String] :name The name of a project.
      # - option params [String] :path The name of a project.
      # - option params [String] :description The name of a project.
      # - return [Hash] Information about the edited project.
      #
      # ```
      # client.edit_project(42)
      # client.edit_project(42, { "name" => "project_name" })
      # ```
      def edit_project(project : Int32|String, prams : Hash = {} of String  => String)
        put("/projects/#{project}", prams).body.parse_json
      end

      # Forks a project into the user namespace.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] options A customizable set of options.
      # - option options [String] :sudo The username the project will be forked for.
      # - return [Hash] Information about the forked project.
      #
      # ```
      # client.create_fork(42)
      # client.create_fork(42, { "sudo" => "another_username" })
      # ```
      def fork_project(project : Int32|String, params : Hash = {} of String  => String)
        post("/projects/fork/#{project}", params).body.parse_json
      end

      # Star a project for the authentication user.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - return [Hash] Information about the starred project.
      #
      # ```
      # client.star_project(42)
      # ```
      def star_project(project : Int32|String)
        post("/projects/#{project_id}/star").body.parse_json
      end

      # Unstar a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - return [Hash] Information about the unstar project.
      #
      # ```
      # client.unstar_project(42)
      # ```
      def unstar_project(project : Int32|String)
        delete("/projects/#{project}/star").body.parse_json
      end

      # Archive a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - return [Hash] Information about the archive project.
      #
      # ```
      # client.archive_project(42)
      # ```
      def archive_project(project : Int32|String)
        delete("/projects/#{project}/archive").body.parse_json
      end

      # Unarchive a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - return [Hash] Information about the unarchive project.
      #
      # ```
      # client.unarchive_project(42)
      # ```
      def unarchive_project(project : Int32|String)
        delete("/projects/#{project}/unarchive").body.parse_json
      end

      # Share a project with a group.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] options A customizable set of options.
      # - option options [String] :sudo The username the project will be forked for.
      # - return [Hash] Information about the share project.
      #
      # ```
      # client.share_project(2, 1)
      # client.share_project(2, 1, { "group_access" => "50" })
      # ```
      def share_project(project : Int32|String, group_id : Int32, group_access = nil)
        params = { "group_id" => group_id }
        params["group_access"] = group_access if group_access

        post("/projects/#{project}/share", params).body.parse_json
      end

      # Search for project by name
      #
      # - param  [String] query A string to search for in group names and paths.
      # - param  [Hash] params A customizable set of params.
      # - option params [String] :per_page Number of projects to return per page.
      # - option params [String] :page The page to retrieve.
      # - option params [String] :order_by Return requests ordered by id, name, created_at or last_activity_at fields.
      # - option params [String] :sort Return requests sorted in asc or desc order.
      # - return [Array<Hash>] List of projects under search qyery.
      #
      # ```
      # client.project_search("gitlab")
      # client.project_search("gitlab", { "per_page" => 50 })
      # ```
      def project_search(query, params : Hash = {} of String => String)
        get("/projects/search/#{query}", params).body.parse_json
      end

      # Deletes a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - return [Hash] Information about the deleted project.
      #
      # ```
      # client.delete_project(42)
      # ```
      def delete_project(project : Int32|String)
        delete("/projects/#{project}").body.parse_json
      end

      # Get a list of a project's team members.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] options A customizable set of options.
      # - option options [String] :query The search query.
      # - option options [Int32] :page The page number.
      # - option options [Int32] :per_page The number of results per page.
      # - return [Array<Hash>] List of team members under a project.
      #
      # ```
      # client.project_members(42)
      # client.project_members('gitlab')
      # ```
      def project_members(project : Int32|String, params : Hash = {} of String => String)
        get("/projects/#{project}/members", params).body.parse_json
      end

      # Gets a project team member.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Int32] user_id The ID of a project team member.
      # - return [Hash] Information about member under a project.
      #
      # ```
      # client.project_member(1, 2)
      # ```
      def project_member(project : Int32|String, user_id : Int32)
        get("/projects/#{project}/members#{user_id}").body.parse_json
      end

      # Adds a user to project team.
      #
      # - param  [Int32, String] project_id The ID or name of a project.
      # - param  [Int32] user_id The ID of a user.
      # - param  [Int32] access_level The access level to project.
      # - param  [Hash] options A customizable set of options.
      # - return [Hash] Information about added team member.
      #
      # ```
      # client.add_project_member('gitlab', 2, 40)
      # ```
      def add_project_member(project : Int32|String, user_id, access_level)
        post("/projects/#{project}/members", {
          "user_id" => user_id,
          "access_level" => access_level
        }).body.parse_json
      end

      # Updates a team member's project access level.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Int32] user_id The ID of a user.
      # - param  [Int32] access_level The access level to project.
      # - return [Array<Hash>] Information about updated team member.
      #
      # ```
      # client.edit_project_member('gitlab', 3, 20)
      # ```
      def edit_project_member(project : Int32|String, user_id, access_level)
        put("/projects/#{project}/members/#{user_id}", {
          "access_level" => access_level
        }).body.parse_json
      end

      # Removes a user from project team.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Int32] user_id The ID of a user.
      # - return [Hash] Information about removed team member.
      #
      # ```
      # client.remove_project_member('gitlab', 2)
      # ```
      def remove_project_member(project : Int32|String, user_id : Int32)
        delete("/projects/#{project}/members/#{user_id}").body.parse_json
      end

      # Get a list of a project's web hooks.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] options A customizable set of options.
      # - option options [Int32] :page The page number.
      # - option options [Int32] :per_page The number of results per page.
      # - return [Array<Hash>] List of web hooks under a project.
      #
      # ```
      # client.project_hooks(42)
      # client.project_hooks('gitlab', { "per_page" => "4" })
      # ```
      def project_hooks(project : Int32|String, params : Hash? = nil)
        get("/projects/#{project}/hooks", params).body.parse_json
      end

      # Get a web hook of a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Int32] hook_id The ID of a web hook.
      # - return [Hash] Information about the web hook.
      #
      # ```
      # client.project_hook(42)
      # client.project_hook('gitlab', 1)
      # ```
      def project_hook(project : Int32|String, hook_id : Int32)
        get("/projects/#{project}/hooks/#{hook_id}").body.parse_json
      end

      # Create a web hook of a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [String] url The url of a web hook.
      # - param  [Hash] params A customizable set of options.
      # - option params [String] :push_events Trigger hook on push events.
      # - option params [String] :issues_events Trigger hook on issues events.
      # - option params [String] :merge_requests_events Trigger hook on merge_requests events.
      # - option params [String] :tag_push_events Trigger hook on push_tag events.
      # - option params [String] :note_events Trigger hook on note events.
      # - option params [String] :enable_ssl_verification Do SSL verification when triggering the hook.
      # - return [Hash] Information about the created web hook.
      #
      # ```
      # client.add_project_hook(42, "https://hooks.slack.com/services/xxx")
      # client.add_project_hook('gitlab', "https://hooks.slack.com/services/xxx", { "issues_events" => "true" })
      # ```
      def add_project_hook(project : Int32|String, url : String, params : Hash = {} of String => String)
        post("/projects/#{project}/hooks", { "url" => url }.merge(params)).body.parse_json
      end

      # Updates a web hook of a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Int32] hook_id The ID of a web hook.
      # - param  [Int32] url The url of a web hook.
      # - param  [Hash] params A customizable set of options.
      # - option params [String] :push_events Trigger hook on push events.
      # - option params [String] :issues_events Trigger hook on issues events.
      # - option params [String] :merge_requests_events Trigger hook on merge_requests events.
      # - option params [String] :tag_push_events Trigger hook on push_tag events.
      # - option params [String] :note_events Trigger hook on note events.
      # - option params [String] :enable_ssl_verification Do SSL verification when triggering the hook.
      # - return [Hash] Information about updated web hook.
      #
      # ```
      # client.edit_project_hook('gitlab', 3, "https://hooks.slack.com/services/xxx")
      # ```
      def edit_project_hook(project : Int32|String, hook_id : Int32, url : String, params : Hash = {} of String => String)
        put("/projects/#{project}/hooks/#{hook_id}", { "url" => url }.merge(params)).body.parse_json
      end

      # Removes a user from project team.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Int32] hook_id The ID of a web hook.
      # - return [Hash] Information about removed web hook.
      #
      # ```
      # client.remove_project_member('gitlab', 2)
      # ```
      def remove_project_hook(project : Int32|String, hook_id : Int32)
        delete("/projects/#{project}/hooks/#{hook_id}").body.parse_json
      end

      # Get a list of a project's branches.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] options A customizable set of options.
      # - option options [Int32] :page The page number.
      # - option options [Int32] :per_page The number of results per page.
      # - return [Array<Hash>] List of branches under a project.
      #
      # ```
      # client.project_branchs(42)
      # client.project_branchs('gitlab', { "per_page" => "4" })
      # ```
      def project_branchs(project : Int32|String, params : Hash = {} of String => String)
        get("/projects/#{project}/repository/branches", params).body.parse_json
      end

      # Get a branch of a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Int32] branch The name of a branch.
      # - return [Hash] Information about the branch under a project.
      #
      # ```
      # client.project_branch(42)
      # client.project_branch('gitlab', "develop")
      # ```
      def project_branch(project : Int32|String, branch : String)
        get("/projects/#{project}/repository/branches/#{branch}").body.parse_json
      end

      # Protect a branch of a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] branch The name of a branch.
      # - return [Hash] Information about the protected branch.
      #
      # ```
      # client.protect_project_branch(2, "master")
      # client.protect_project_branch("gitlab", "master")
      # ```
      def protect_project_branch(project : Int32|String, branch : String)
        put("/projects/#{project}/repository/branches/#{branch}/protect").body.parse_json
      end

      # Unprotect a branch of a project.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] branch The name of a branch.
      # - return [Hash] Information about the unprotect branch.
      #
      # ```
      # client.unprotect_project_branch(2, "master")
      # client.unprotect_project_branch("gitlab", "master")
      # ```
      def unprotect_project_branch(project : Int32|String, branch : String)
        put("/projects/#{project}/repository/branches/#{branch}/unprotect").body.parse_json
      end

      # Create a forked from/to relation between existing projects. Available only for admins.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - param  [Hash] branch The name of a branch.
      # - return [Hash] Information about the forked project.
      #
      # ```
      # client.create_fork_from(1, 21)
      # ```
      def create_fork_from(project : Int32|String, forked_from_id : Int32)
        put("/projects/#{project_id}/fork/#{forked_from_id}").body.parse_json
      end

      # Delete an existing forked from relationship. Available only for admins.
      #
      # - param  [Int32, String] project The ID or name of a project. If using namespaced projects call make sure that the NAMESPACE/PROJECT_NAME is URL-encoded.
      # - return [Hash] Information about the unforked project.
      #
      # ```
      # client.create_fork_from(1, 21)
      # ```
      def remove_fork_from(project : Int32|String)
        delete("/projects/#{project_id}/fork")
      end
    end
  end
end
