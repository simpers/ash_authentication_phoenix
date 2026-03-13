# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule Example.Accounts.WebAuthnSimpersNoIdentityKey do
  @moduledoc false

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    domain: Example.Accounts

  attributes do
    uuid_primary_key :id
    attribute :credential_id, :binary, allow_nil?: false, public?: true

    attribute :public_key, AshAuthentication.Strategy.WebAuthn.CoseKey,
      allow_nil?: false,
      public?: true

    attribute :sign_count, :integer, default: 0, allow_nil?: false, public?: true
    attribute :label, :string, default: "Security Key", public?: true
    attribute :last_used_at, :utc_datetime_usec, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, Example.Accounts.WebAuthnSimpersNoIdentityUser, allow_nil?: false, public?: true
  end

  identities do
    identity :unique_credential_id, [:credential_id]
  end
end
