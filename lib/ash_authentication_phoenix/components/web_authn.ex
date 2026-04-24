# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule AshAuthentication.Phoenix.Components.WebAuthn do
  use AshAuthentication.Phoenix.Overrides.Overridable,
    root_class: "CSS class for the root `div` element.",
    heading_class: "CSS class for the heading element.",
    description_class: "CSS class for the description element.",
    actions_class: "CSS class for the action button container.",
    register_button_class: "CSS class for the register passkey button.",
    sign_in_button_class: "CSS class for the sign in passkey button.",
    status_class: "CSS class for the status text.",
    heading_text: "Heading text shown for the strategy.",
    description_text: "Description text shown for the strategy.",
    register_button_text: "Text for the register passkey button.",
    sign_in_button_text: "Text for the sign in passkey button.",
    unavailable_text: "Text shown when strategy phases are not available."

  @moduledoc """
  Generates a basic WebAuthn/passkey UI.

  ## Component hierarchy

  This is the top-most strategy-specific component, nested below
  `AshAuthentication.Phoenix.Components.SignIn`.

  ## Props

    * `strategy` - The strategy configuration as per
      `AshAuthentication.Info.strategy/2`. Required.
    * `auth_routes_prefix` - Optional route prefix for authentication routes.
    * `overrides` - A list of override modules.
    * `gettext_fn` - Optional text translation function.

  This first draft component intentionally only renders the UI and exposes
  strategy begin/finish paths through `data-*` attributes for host-app hooks.

  #{AshAuthentication.Phoenix.Overrides.Overridable.generate_docs()}
  """

  use AshAuthentication.Phoenix.Web, :live_component
  alias AshAuthentication.{Info, Strategy}
  alias Phoenix.LiveView.Rendered
  import AshAuthentication.Phoenix.Components.Helpers, only: [auth_path: 6]

  @type props :: %{
          required(:strategy) => AshAuthentication.Strategy.t(),
          optional(:auth_routes_prefix) => String.t(),
          optional(:overrides) => [module],
          optional(:gettext_fn) => {module, atom}
        }

  @doc false
  @impl true
  @spec render(props) :: Rendered.t() | no_return
  def render(assigns) do
    subject_name = Info.authentication_subject_name!(assigns.strategy.resource)

    auth_routes_prefix = Map.get(assigns, :auth_routes_prefix)

    assigns =
      assigns
      |> assign(:subject_name, subject_name)
      |> assign(:strategy_name, Strategy.name(assigns.strategy))
      |> assign(
        :register_begin_path,
        phase_path(assigns, subject_name, auth_routes_prefix, :register_begin)
      )
      |> assign(
        :register_finish_path,
        phase_path(assigns, subject_name, auth_routes_prefix, :register_finish)
      )
      |> assign(
        :sign_in_begin_path,
        phase_path(assigns, subject_name, auth_routes_prefix, :sign_in_begin)
      )
      |> assign(
        :sign_in_finish_path,
        phase_path(assigns, subject_name, auth_routes_prefix, :sign_in_finish)
      )
      |> assign_new(:overrides, fn -> [AshAuthentication.Phoenix.Overrides.Default] end)
      |> assign_new(:gettext_fn, fn -> nil end)
      |> assign_new(:auth_routes_prefix, fn -> nil end)

    ~H"""
    <div
      class={override_for(@overrides, :root_class)}
      data-webauthn="true"
      data-webauthn-strategy={@strategy_name}
      data-webauthn-register-begin-path={@register_begin_path}
      data-webauthn-register-finish-path={@register_finish_path}
      data-webauthn-sign-in-begin-path={@sign_in_begin_path}
      data-webauthn-sign-in-finish-path={@sign_in_finish_path}
    >
      <h2 class={override_for(@overrides, :heading_class)}>
        {_gettext(override_for(@overrides, :heading_text, "Passkeys"))}
      </h2>

      <p class={override_for(@overrides, :description_class)}>
        {_gettext(
          override_for(
            @overrides,
            :description_text,
            "Use your device passkey to register or sign in without a password."
          )
        )}
      </p>

      <div class={override_for(@overrides, :actions_class)}>
        <button
          type="button"
          class={override_for(@overrides, :register_button_class)}
          data-webauthn-action="register"
          disabled={is_nil(@register_begin_path) || is_nil(@register_finish_path)}
        >
          {_gettext(override_for(@overrides, :register_button_text, "Create passkey"))}
        </button>

        <button
          type="button"
          class={override_for(@overrides, :sign_in_button_class)}
          data-webauthn-action="sign-in"
          disabled={is_nil(@sign_in_begin_path) || is_nil(@sign_in_finish_path)}
        >
          {_gettext(override_for(@overrides, :sign_in_button_text, "Use passkey"))}
        </button>
      </div>

      <p
        :if={
          missing_required_phase?(
            @register_begin_path,
            @register_finish_path,
            @sign_in_begin_path,
            @sign_in_finish_path
          )
        }
        class={override_for(@overrides, :status_class)}
        data-webauthn-status
        aria-live="polite"
      >
        {_gettext(
          override_for(
            @overrides,
            :unavailable_text,
            "WebAuthn routes are not fully available for this strategy configuration yet."
          )
        )}
      </p>
    </div>
    """
  end

  defp phase_path(assigns, subject_name, auth_routes_prefix, phase) do
    if has_phase?(assigns.strategy, phase) do
      auth_path(
        assigns.socket,
        subject_name,
        auth_routes_prefix,
        assigns.strategy,
        phase,
        %{}
      )
    end
  end

  defp has_phase?(strategy, phase) do
    Enum.any?(Strategy.routes(strategy), fn {_path, route_phase} -> route_phase == phase end)
  end

  defp missing_required_phase?(register_begin, register_finish, sign_in_begin, sign_in_finish) do
    Enum.any?([register_begin, register_finish, sign_in_begin, sign_in_finish], &is_nil/1)
  end
end
