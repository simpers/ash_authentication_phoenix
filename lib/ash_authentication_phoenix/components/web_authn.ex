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
    workflow_button_class: "CSS class for the button linking to the WebAuthn workflow page.",
    workflow_button_text: "Text for the button linking to the WebAuthn workflow page.",
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
  alias AshAuthentication.Phoenix.Components.WebAuthn.{RegisterForm, SignInForm}
  alias Phoenix.LiveView.Rendered
  import AshAuthentication.Phoenix.Components.Helpers, only: [auth_path: 6]

  @type props :: %{
          required(:strategy) => AshAuthentication.Strategy.t(),
          optional(:auth_routes_prefix) => String.t(),
          optional(:webauthn_path) => String.t(),
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
      |> assign_new(:webauthn_path, fn -> nil end)

    assigns = assign(assigns, :strategy_label, strategy_label(assigns.strategy_name))

    ~H"""
    <div class={override_for(@overrides, :root_class)}>
      <h2 class={override_for(@overrides, :heading_class)}>
        {_gettext(@strategy_label)}
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

      <%= if @live_action == :webauthn do %>
        <.live_component
          module={SignInForm}
          id={"#{@id}-sign-in"}
          strategy_name={@strategy_name}
          subject_name={@subject_name}
          sign_in_begin_path={@sign_in_begin_path}
          sign_in_finish_path={@sign_in_finish_path}
          require_identity?={@strategy.require_identity?}
          sign_in_button_class={override_for(@overrides, :sign_in_button_class)}
          sign_in_button_text={
            _gettext(override_for(@overrides, :sign_in_button_text, "Sign in with passkey"))
          }
          status_class={override_for(@overrides, :status_class)}
          unavailable_text={
            _gettext(
              override_for(
                @overrides,
                :unavailable_text,
                "WebAuthn routes are not fully available for this strategy configuration yet."
              )
            )
          }
        />

        <div class="my-4 flex items-center gap-3">
          <div class="h-px flex-1 bg-gray-200 dark:bg-gray-700" />
          <span class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400">
            {_gettext("or")}
          </span>
          <div class="h-px flex-1 bg-gray-200 dark:bg-gray-700" />
        </div>

        <.live_component
          module={RegisterForm}
          id={"#{@id}-register"}
          strategy_name={@strategy_name}
          subject_name={@subject_name}
          register_begin_path={@register_begin_path}
          register_finish_path={@register_finish_path}
          require_identity?={@strategy.require_identity?}
          register_button_class={override_for(@overrides, :register_button_class)}
          register_button_text={
            _gettext(override_for(@overrides, :register_button_text, "Create/register passkey"))
          }
          status_class={override_for(@overrides, :status_class)}
          unavailable_text={
            _gettext(
              override_for(
                @overrides,
                :unavailable_text,
                "WebAuthn routes are not fully available for this strategy configuration yet."
              )
            )
          }
        />
      <% else %>
        <.link
          :if={@webauthn_path}
          href={@webauthn_path}
          class={
            override_for(
              @overrides,
              :workflow_button_class,
              override_for(@overrides, :sign_in_button_class)
            )
          }
        >
          {_gettext(
            override_for(
              @overrides,
              :workflow_button_text,
              "Continue with WebAuthn"
            )
          )}
        </.link>
      <% end %>
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

  defp strategy_label(strategy_name) do
    strategy_name
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end

defmodule AshAuthentication.Phoenix.Components.WebAuthn.RegisterForm do
  use AshAuthentication.Phoenix.Web, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      data-webauthn="true"
      data-webauthn-subject-name={@subject_name}
      data-webauthn-strategy={@strategy_name}
      data-webauthn-register-begin-path={@register_begin_path}
      data-webauthn-register-finish-path={@register_finish_path}
    >
      <div :if={@require_identity?} class="mb-3">
        <label class="block text-sm font-medium mb-1" for={"webauthn-identity-#{@id}"}>
          {_gettext("Identity")}
        </label>
        <input
          id={"webauthn-identity-#{@id}"}
          type="text"
          class="w-full border rounded-md px-3 py-2"
          data-webauthn-identity
          placeholder={_gettext("email")}
        />
      </div>

      <div class="mb-3">
        <label class="block text-sm font-medium mb-1" for={"webauthn-key-name-#{@id}"}>
          {_gettext("Passkey label")}
        </label>
        <input
          id={"webauthn-key-name-#{@id}"}
          type="text"
          class="w-full border rounded-md px-3 py-2"
          data-webauthn-key-name
          placeholder={_gettext("e.g. Work laptop")}
        />
      </div>

      <button
        type="button"
        class={@register_button_class}
        data-webauthn-action="register"
        disabled={is_nil(@register_begin_path) || is_nil(@register_finish_path)}
      >
        {@register_button_text}
      </button>

      <p class={@status_class} data-webauthn-status aria-live="polite">
        <%= if is_nil(@register_begin_path) || is_nil(@register_finish_path) do %>
          {@unavailable_text}
        <% end %>
      </p>
    </div>
    """
  end
end

defmodule AshAuthentication.Phoenix.Components.WebAuthn.SignInForm do
  use AshAuthentication.Phoenix.Web, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      data-webauthn="true"
      data-webauthn-subject-name={@subject_name}
      data-webauthn-strategy={@strategy_name}
      data-webauthn-sign-in-begin-path={@sign_in_begin_path}
      data-webauthn-sign-in-finish-path={@sign_in_finish_path}
    >
      <div :if={@require_identity?} class="mb-3">
        <label class="block text-sm font-medium mb-1" for={"webauthn-identity-#{@id}"}>
          {_gettext("Identity")}
        </label>
        <input
          id={"webauthn-identity-#{@id}"}
          type="text"
          class="w-full border rounded-md px-3 py-2"
          data-webauthn-identity
          placeholder={_gettext("email")}
        />
      </div>

      <button
        type="button"
        class={@sign_in_button_class}
        data-webauthn-action="sign-in"
        disabled={is_nil(@sign_in_begin_path) || is_nil(@sign_in_finish_path)}
      >
        {@sign_in_button_text}
      </button>

      <p class={@status_class} data-webauthn-status aria-live="polite">
        <%= if is_nil(@sign_in_begin_path) || is_nil(@sign_in_finish_path) do %>
          {@unavailable_text}
        <% end %>
      </p>
    </div>
    """
  end
end
