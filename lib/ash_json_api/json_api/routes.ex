defmodule AshJsonApi.JsonApi.Routes do
  defmacro routes(do: body) do
    quote do
      import AshJsonApi.JsonApi.Routes
      unquote(body)
      import AshJsonApi.JsonApi.Routes, only: []
    end
  end

  defmacro get(action, opts \\ []) do
    quote bind_quoted: [action: action, opts: opts] do
      route = opts[:route] || "/:id"

      unless Enum.find(Path.split(route), fn part -> part == ":id" end) do
        raise "Route for get action *must* contain an `:id` path parameter"
      end

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :get,
                         controller: AshJsonApi.Controllers.Get,
                         action: action || :get,
                         primary?: opts[:primary?] || false
                       )
    end
  end

  defmacro index(action, opts \\ []) do
    quote bind_quoted: [action: action, opts: opts] do
      route = opts[:route] || "/"

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :get,
                         controller: AshJsonApi.Controllers.Index,
                         action: action,
                         primary?: opts[:primary?] || false
                       )
    end
  end

  defmacro create(action, opts \\ []) do
    quote bind_quoted: [action: action, opts: opts] do
      route = opts[:route] || "/"

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :post,
                         controller: AshJsonApi.Controllers.Create,
                         action: action || :create,
                         primary?: opts[:primary?] || false
                       )
    end
  end

  defmacro update(action, opts \\ []) do
    quote bind_quoted: [action: action, opts: opts] do
      route = opts[:route] || "/:id"

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :patch,
                         controller: AshJsonApi.Controllers.Update,
                         action: action || :update,
                         primary?: opts[:primary?] || false
                       )
    end
  end

  defmacro delete(action, opts \\ []) do
    quote bind_quoted: [action: action, opts: opts] do
      route = opts[:route] || "/:id"

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :delete,
                         controller: AshJsonApi.Controllers.Delete,
                         action: action || :delete,
                         primary?: opts[:primary?] || false
                       )
    end
  end

  # TODO: Related resource route ought to use a get action on the destination resource
  # but with some kind of hook and/or w/ a "special" filter applied.
  # TODO: clean up error messaging around id path param

  defmacro relationship_routes(relationship, opts \\ []) do
    quote bind_quoted: [relationship: relationship, opts: opts] do
      related(relationship, opts)
      relationship(relationship, opts)
      post_to_relationship(relationship, opts)
      delete_from_relationship(relationship, opts)
      patch_relationship(relationship, opts)
    end
  end

  defmacro post_to_relationship(relationship, opts \\ []) do
    quote bind_quoted: [relationship: relationship, opts: opts] do
      route = opts[:route] || ":id/relationships/#{relationship}"

      unless Enum.find(Path.split(route), fn part -> part == ":id" end) do
        raise "Route for post to relationship action *must* contain an `:id` path parameter"
      end

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :post,
                         controller: AshJsonApi.Controllers.PostToRelationship,
                         primary?: opts[:primary?] || true,
                         action: :post_to_relationship,
                         prune: {:require_relationship_cardinality, :many},
                         relationship: relationship
                       )
    end
  end

  defmacro patch_relationship(relationship, opts \\ []) do
    quote bind_quoted: [relationship: relationship, opts: opts] do
      route = opts[:route] || ":id/relationships/#{relationship}"

      unless Enum.find(Path.split(route), fn part -> part == ":id" end) do
        raise "Route for patch to relationship action *must* contain an `:id` path parameter"
      end

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :patch,
                         controller: AshJsonApi.Controllers.PatchRelationship,
                         primary?: opts[:primary?] || true,
                         action: :patch_relationship,
                         relationship: relationship
                       )
    end
  end

  defmacro delete_from_relationship(relationship, opts \\ []) do
    quote bind_quoted: [relationship: relationship, opts: opts] do
      route = opts[:route] || ":id/relationships/#{relationship}"

      unless Enum.find(Path.split(route), fn part -> part == ":id" end) do
        raise "Route for delete to relationship action *must* contain an `:id` path parameter"
      end

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :delete,
                         controller: AshJsonApi.Controllers.DeleteFromRelationship,
                         primary?: opts[:primary?] || true,
                         action: :delete_from_relationship,
                         prune: {:require_relationship_cardinality, :many},
                         relationship: relationship
                       )
    end
  end

  defmacro related(relationship, opts \\ []) do
    quote bind_quoted: [relationship: relationship, opts: opts] do
      route = opts[:route] || ":id/#{relationship}"

      unless Enum.find(Path.split(route), fn part -> part == ":id" end) do
        raise "Route for get action *must* contain an `:id` path parameter"
      end

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :get,
                         controller: AshJsonApi.Controllers.GetRelated,
                         primary?: opts[:primary?] || true,
                         action: :get_related,
                         relationship: relationship
                       )
    end
  end

  defmacro relationship(relationship, opts \\ []) do
    quote bind_quoted: [relationship: relationship, opts: opts] do
      route = opts[:route] || ":id/relationships/#{relationship}"

      unless Enum.find(Path.split(route), fn part -> part == ":id" end) do
        raise "Route for get action *must* contain an `:id` path parameter"
      end

      @json_api_routes AshJsonApi.JsonApi.Route.new(
                         route:
                           AshJsonApi.JsonApi.Routes.prefix(
                             route,
                             @name,
                             Keyword.get(opts, :prefix?, true)
                           ),
                         method: :get,
                         controller: AshJsonApi.Controllers.GetRelationship,
                         primary?: opts[:primary?] || true,
                         fields: opts[:fields],
                         action: :get_relationship,
                         relationship: relationship
                       )
    end
  end

  def prefix(route, name, true) do
    full_route = "/" <> name <> "/" <> String.trim_leading(route, "/")

    String.trim_trailing(full_route, "/")
  end

  def prefix(route, _name, _) do
    route
  end
end
