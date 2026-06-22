# WebAuthn Phoenix Roadmap (AshAuthenticationPhoenix)

> Goal: deliver an MVP Phoenix + LiveView WebAuthn/passkeys experience in small,
> reviewable PRs, while `ash_authentication` finalizes strategy internals.

This roadmap intentionally focuses on actionable work only.

## MVP Definition

- [ ] A developer can enable WebAuthn on the sign-in page without implementing the browser flow from scratch
- [ ] A built-in component supports registration and sign-in via begin/finish phases
- [ ] The flow works with both route helpers and `auth_routes_prefix`
- [ ] Success/error states are clear in LiveView UI
- [ ] One real-project setup path is documented end-to-end

Non-MVP (defer):

- full passkey management UX (rename/remove/list)
- advanced attestation policy UX
- non-LiveView frontend adapters

---

## Work We Can Start Now

### Phoenix component and rendering

- [ ] Add `AshAuthentication.Phoenix.Components.WebAuthn`
- [ ] Add override keys for labels/buttons/classes/status text
- [ ] Ensure compatibility with `Components.SignIn` strategy auto-discovery
- [ ] Add component docs matching existing strategy docs style

### Browser helper layer

- [ ] Add JS helpers for base64url <-> ArrayBuffer conversion
- [ ] Add helpers to map JSON options to browser credential options
- [ ] Add helpers to serialize browser credentials for finish endpoints
- [ ] Add capability checks (`window.PublicKeyCredential`, secure context)
- [ ] Add deterministic client error mapping (cancelled, unsupported, malformed response, network failure)

### LiveView integration

- [ ] Implement a hook boundary for `navigator.credentials.create/get`
- [ ] Wire begin -> browser op -> finish event flow
- [ ] Ensure CSRF-safe request behavior in LiveView context
- [ ] Ensure multi-resource/multi-component isolation on one sign-in page

### Test coverage

- [ ] Add component rendering/assign/override tests
- [ ] Add tests for route/path generation assumptions where applicable
- [ ] Add JS tests for encoding/decoding + payload transform helpers

### Real-project usability

- [ ] Add localhost secure-context testing recipe
- [ ] Document host app hook wiring and asset setup
- [ ] Add fallback UX guidance for unsupported browsers/environments

---

## Upstream-Dependent Work (`ash_authentication`)

- [ ] Confirm final begin/finish payload and error contract
- [ ] Confirm state token claim shape/naming
- [ ] Confirm identity-required vs discoverable behavior/options
- [ ] Align UI and errors to finalized upstream behavior
- [ ] Add final end-to-end and negative-path tests once contract is stable

---

## PR Plan

### PR 1 - Component skeleton

- [x] Add roadmap document
- [ ] Add WebAuthn component skeleton + overrides
- [ ] Add initial rendering/discovery tests

Exit criteria:

- `mix test` passes and non-WebAuthn behavior is unchanged

### PR 2 - JS + hook contract

- [ ] Add browser conversion helpers
- [ ] Add hook event contract and error mapping
- [ ] Add JS unit tests

Exit criteria:

- hook can execute local begin/finish payload roundtrip with expected transformations

### PR 3 - End-to-end flow

- [ ] Wire register begin/create/finish
- [ ] Wire sign-in begin/get/finish
- [ ] Surface success/error states in component

Exit criteria:

- manual passkey register/sign-in works in a real local Phoenix app

### PR 4 - Docs and install guidance

- [ ] Add WebAuthn docs/tutorial
- [ ] Document asset/hook integration and troubleshooting
- [ ] Update install/upgrade guidance if mandatory setup is introduced

Exit criteria:

- fresh app can follow docs to a working passkey flow

### PR 5 - Stabilization on upstream release

- [ ] Align to released upstream contracts/options
- [ ] Refine tests for final semantics
- [ ] Remove temporary compatibility shims

Exit criteria:

- feature works against released upstream dependency with stable test coverage

---

## Real-Project Validation Matrix

- [ ] Localhost LiveView app with `auth_routes_prefix`
- [ ] Localhost LiveView app using route helpers
- [ ] Identity-required flow (if enabled upstream)
- [ ] Discoverable flow (if enabled upstream)
- [ ] Browser sanity checks (latest Chrome, Safari, Firefox where available)

---

## Open Questions

- [ ] Should WebAuthn render as form-style or link-style in `Components.SignIn`?
- [ ] Should this library vendor browser helpers or document host-app helpers?
- [ ] How much passkey management UX belongs in this dependency vs app-level customization?
- [ ] Should this dependency ship a first-party LiveView hook module?
