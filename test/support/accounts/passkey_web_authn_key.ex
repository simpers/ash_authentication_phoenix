# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule Example.Accounts.PasskeyWebAuthnKey do
  @moduledoc false

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshAuthentication.WebAuthnKey],
    domain: Example.Accounts

  web_authn_key do
    user_resource Example.Accounts.PasskeyUser
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
  end
end
