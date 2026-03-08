# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule AshAuthentication.Phoenix.WebAuthnLive do
  @moduledoc """
  Dedicated WebAuthn workflow page.

  This renders the WebAuthn component in full workflow mode, keeping the main
  sign-in page as a simple entry point.
  """

  use AshAuthentication.Phoenix.Web, :live_view

  alias AshAuthentication.Info
  alias AshAuthentication.Phoenix.Components

  @impl true
  def mount(_params, session, socket) do
    resource = session["resource"]
    strategy_name = session["strategy"]

    strategy = Info.strategy!(resource, strategy_name)

    socket =
      socket
      |> assign(:strategy, strategy)
      |> assign(:path, session["path"])
      |> assign(:context, session["context"] || %{})
      |> assign(:overrides, session["overrides"] || [AshAuthentication.Phoenix.Overrides.Default])
      |> assign(:auth_routes_prefix, session["auth_routes_prefix"])
      |> assign(:gettext_fn, session["gettext_fn"])
      |> assign(:current_tenant, session["tenant"])
      |> assign(:live_action, :webauthn)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="auth-main max-w-md mx-auto px-2">
      <.live_component
        module={Components.WebAuthn}
        id={"webauthn-workflow-#{AshAuthentication.Strategy.name(@strategy)}"}
        strategy={@strategy}
        path={@path}
        auth_routes_prefix={@auth_routes_prefix}
        current_tenant={@current_tenant}
        context={@context}
        live_action={@live_action}
        overrides={@overrides}
        gettext_fn={@gettext_fn}
      />
    </div>
    """
  end
end
