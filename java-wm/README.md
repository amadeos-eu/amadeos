# amadeOS Java Window Manager prototype

This module is the first executable MVP slice: a Java 17 Gradle application with a
pure window registry/layout core and an explicitly isolated X11 adapter boundary.
`LoggingX11Adapter` is intentionally a no-op adapter that logs requested operations;
no native library or JNA binding is used yet.

## Run and test

From the repository root:

```bash
gradle test
gradle run
```

The Swing demo presents the core state and simulates managed windows. It does not
manage the host desktop.

## Deliberate limitations

- No X11 connection, event loop, ICCCM/EWMH support, focus protocol, or native binding.
- No reparenting, decorations, persistence, multi-monitor handling, or real client lifecycle.
- The floating policy is deterministic demo logic, not a production placement policy.
- A later implementation must add platform integration and integration tests before
  any native X11 implementation is considered safe.

