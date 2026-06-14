# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule Example.Accounts.WebAuthnKey do
  @moduledoc false

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshAuthentication.WebAuthnKey],
    domain: Example.Accounts

  web_authn_key do
    user_resource Example.Accounts.User
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
  end

  identities do
    identity :unique_credential_id, [:credential_id], pre_check_with: Example.Accounts
  end
end
