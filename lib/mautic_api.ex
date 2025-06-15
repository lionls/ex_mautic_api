defmodule MauticApi do
  @base_url Application.compile_env!(:mautic_api, :base_url)
  @username Application.compile_env!(:mautic_api, :username)
  @password Application.compile_env!(:mautic_api, :password)
  @moduledoc """
  Documentation for `MauticApi`.
  """

  defp new(options) when is_list(options) do
    Req.new(
      base_url: "#{@base_url}/api",
      auth: {:basic, "#{@username}:#{@password}"}
    )
    |> Req.Request.append_request_steps(
      post: fn req ->
        with %{method: :get, body: <<_::binary>>} <- req do
          %{req | method: :post}
        end
      end
    )
    |> Req.merge(options)
  end

  defp request(options) do
    case Req.request(new(options)) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Request failed with status #{status}, response: #{inspect(body)}"}

      {:error, response} ->
        {:error, "Request failed: #{inspect(response)}"}
    end
  end

  def get_contact(id) do
    request(
      method: :get,
      url: "/contacts/#{id}"
    )
  end

  def get_all_contacts() do
    request(
      method: :get,
      url: "/contacts"
    )
  end

  def create_contact(params) do
    request(
      method: :post,
      url: "/contacts/new",
      body: params
    )
  end

  def update_contact(id, params) do
    request(
      method: :patch,
      url: "/contacts/#{id}/edit",
      body: params
    )
  end

  def get_segments_by_contact_id(contact_id) do
    request(
      method: :get,
      url: "/contacts/#{contact_id}/segments"
    )
  end

  @allowed_search_keys ~w(
    search
    start
    limit
    orderBy
    orderByDir
    publishedOnly
    minimal
    where
    order
    select
  )a

  def search_contact(params) do
    valid_params = Enum.filter(params, fn {key, _val} -> key in @allowed_search_keys end)

    request(
      method: :get,
      url: "/contacts",
      params: valid_params
    )
  end

  def add_contact_to_stage(contact_id, stage_id) do
    request(
      method: :post,
      url: "/stages/#{stage_id}/contact/#{contact_id}/add"
    )
  end
end
