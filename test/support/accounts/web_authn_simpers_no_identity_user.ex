# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule Example.Accounts.WebAuthnSimpersNoIdentityUser do
  @moduledoc false

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
      webauthn :webauthn do
        credential_resource Example.Accounts.WebAuthnSimpersNoIdentityKey
        rp_id fn _resource, _opts -> {:ok, "localhost"} end
        rp_name "Test App"
        origin fn _resource, _opts -> {:ok, DevWeb.Endpoint.url()} end
        sign_in_without_identity? true
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
    has_many :webauthn_credentials, Example.Accounts.WebAuthnSimpersNoIdentityKey do
      destination_attribute :user_id
    end
  end
end
