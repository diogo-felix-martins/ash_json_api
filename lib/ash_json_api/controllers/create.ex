defmodule AshJsonApi.Controllers.Create do
  def init(options) do
    # initialize options
    options
  end

  def call(conn, options) do
    resource = options[:resource]
    action = options[:action]

    with {:ok, request} <- AshJsonApi.Request.from(conn, resource, :create),
         {:record, {:ok, record}} when not is_nil(record) <-
           {:record,
            Ash.run_create_action(
              resource,
              action,
              request.attributes,
              request.relationships,
              request.query_params
            )},
         {:ok, record, includes} <-
           AshJsonApi.Includes.Includer.get_includes(record, request) do
      serialized = AshJsonApi.Serializer.serialize_one(request, record, includes)

      conn
      |> Plug.Conn.put_resp_content_type("application/vnd.api+json")
      |> Plug.Conn.send_resp(200, serialized)
    else
      {:id, :error} ->
        raise "whups, no id"

      {:error, error} ->
        raise "whups: #{inspect(error)}"

      {:record, {:error, error}} ->
        raise "whups: #{inspect(error)}"

      {:record, {:ok, nil}} ->
        conn
        # |> put_resp_content_type("text/plain")
        |> Plug.Conn.send_resp(404, "uh oh")
    end
    |> Plug.Conn.halt()
  end
end
