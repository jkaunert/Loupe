# Figma Comparison

Loupe does not call the Figma API directly yet. The near-term design comparison
contract is a small exported JSON file that can be produced by a Figma plugin,
script, or manual fixture.

## Minimal Design JSON

```json
{
  "frame": {
    "name": "BookmarkDetail",
    "width": 402,
    "height": 874
  },
  "nodes": [
    {
      "id": "bookmark.detail.favorite",
      "name": "Favorite switch",
      "role": "switch",
      "frame": { "x": 325, "y": 282, "width": 63, "height": 28 },
      "style": {
        "backgroundColor": "#34C759",
        "cornerRadius": 14
      }
    }
  ]
}
```

## Matching Policy

Compare a Loupe snapshot to design nodes in this order:

1. `testID` / accessibility identifier exact match.
2. Role plus exact visible text.
3. Role plus nearest center point.
4. Visual fallback by frame and size similarity.

## Command

```bash
loupe capture-report --bundle-id com.example.App --output loupe-report
loupe screen-map snapshot.json --limit 120
loupe paint-stack snapshot.json --point 201,319
loupe compare-design snapshot.json figma-export.json
loupe compare-design snapshot.json figma-export.json --json
```

Use `capture-report` when a design loop needs both screenshot judgment and
runtime structure. Use `screen-map` before a formal comparison when an agent
needs a DOM-like runtime summary. Use `paint-stack` when a visual target is
covered by an overlay, content view, blur view, or same-frame child. These
outputs are intentionally not Figma-specific: the same artifacts can be compared
with a Figma export, a hand-written fixture, or another runtime snapshot.

The command reports:

- missing design nodes
- unexpected app nodes
- frame deltas
- color, corner radius, font name, and font size deltas

This should stay separate from screenshot baseline diffing. Figma comparison is
for structural and property drift; screenshot diffing is for pixel-level visual
regressions.

Spacing deltas between matched siblings are still a planned follow-up.
