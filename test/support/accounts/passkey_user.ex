# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule Example.Accounts.PasskeyUser do
  @moduledoc false

  defmodule WebAuthnSecret do
    @moduledoc false

    use AshAuthentication.Secret

    @origin_path [:authentication, :strategies, :web_authn, :origin]
    @relying_party_path [:authentication, :strategies, :web_authn, :relying_party]

    @impl AshAuthentication.Secret
    def secret_for(@origin_path, _resource, _opts, %{
          http_request: %{host: host, port: port, scheme: scheme}
        }) do
      {:ok, "#{scheme}://#{host}:#{port}"}
    end

    def secret_for(@origin_path, _resource, _opts, %{
          ash_authentication_request: %{host: host, port: port, scheme: scheme}
        }) do
      {:ok, "#{scheme}://#{host}:#{port}"}
    end

    def secret_for(@origin_path, _resource, _opts, _context) do
      {:ok, DevWeb.Endpoint.url()}
    end

    def secret_for(@relying_party_path, _resource, _opts, %{http_request: %{host: host}}) do
      {:ok, host}
    end

    def secret_for(@relying_party_path, _resource, _opts, %{
          ash_authentication_request: %{host: host}
        }) do
      {:ok, host}
    end

    def secret_for(@relying_party_path, _resource, _opts, _context) do
      {:ok, get_env([DevWeb.Endpoint, :url, :host], "localhost")}
    end

    defp get_env([key | path], default) do
      get_env(key, nil)
      |> case do
        nil -> default
        value -> get_in(value, path) || default
      end
    end

    defp get_env(key, default) do
      Application.get_env(:ash_authentication_phoenix, key) || default
    end
  end

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshAuthentication],
    domain: Example.Accounts

  actions do
    defaults([:read, :create, :update])
  end

  attributes do
    uuid_primary_key :id

    attribute :display_name, :string, allow_nil?: true, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  authentication do
    session_identifier(:jti)

    strategies do
      web_authn do
        key_resource Example.Accounts.PasskeyWebAuthnKey
        relying_party WebAuthnSecret
        require_identity? false
      end
    end

    tokens do
      enabled?(true)
      token_resource(Example.Accounts.Token)
      store_all_tokens? true
      require_token_presence_for_authentication? false

      signing_secret("fake_secret")
    end
  end

  relationships do
    has_many :web_authn_keys, Example.Accounts.PasskeyWebAuthnKey do
      destination_attribute :user_id
    end
  end
end
