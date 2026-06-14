# SPDX-FileCopyrightText: 2022 Alembic Pty Ltd
#
# SPDX-License-Identifier: MIT

defmodule DevWeb.AuthController do
  @moduledoc false

  use DevWeb, :controller
  use AshAuthentication.Phoenix.Controller

  @doc false
  @impl true
  def success(conn, {_, phase}, result, _token)
      when phase in [
             :register_begin,
             :register_begin_with_web_authn,
             :sign_in_begin,
             :sign_in_begin_with_web_authn
           ] do
    conn
    |> put_status(200)
    |> json(%{webauthn: result})
  end

  def success(conn, {_, phase}, user, _token)
      when phase in [
             :register_finish,
             :register_finish_with_web_authn,
             :sign_in_finish,
             :sign_in_finish_with_web_authn
           ] do
    conn
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> put_status(200)
    |> json(%{status: "ok", redirect_to: "/"})
  end

  def success(conn, _activity, user, _token) do
    conn
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> redirect(to: "/")
  end

  @doc false
  @impl true
  def failure(conn, {_, phase}, reason)
      when phase in [
             :register_begin,
             :register_begin_with_web_authn,
             :register_finish,
             :register_finish_with_web_authn,
             :sign_in_begin,
             :sign_in_begin_with_web_authn,
             :sign_in_finish,
             :sign_in_finish_with_web_authn
           ] do
    conn
    |> put_status(400)
    |> json(%{status: "error", reason: inspect(reason)})
  end

  def failure(conn, _activity, reason) do
    conn
    |> assign(:failure_reason, reason)
    |> redirect(to: "/sign-in")
  end

  @doc false
  @impl true
  def sign_out(conn, _params) do
    conn
    |> clear_session(:ash_authentication_phoenix)
    |> redirect(to: "/")
  end
end
