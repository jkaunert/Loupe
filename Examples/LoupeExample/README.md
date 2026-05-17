# LoupeExample

Minimal UIKit app used to verify simulator dylib injection.

The app does not link `LoupeKit`. It only defines normal UIKit views and `accessibilityIdentifier` values. `LoupeInjector` is injected at launch time and starts the localhost observation server.

Run:

```bash
./run-injected.sh
```

Expected result:

- the app launches on a booted simulator
- `http://127.0.0.1:8765/health` returns `LoupeKit`
- `/snapshot` contains the UIKit view hierarchy
- `loupe query ... --test-id example.primaryButton` returns the primary button node
