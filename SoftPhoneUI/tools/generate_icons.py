#!/usr/bin/env python3
"""Generate white/pink futuristic SVG + PNG icons for SoftPhoneUI."""

from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SVG_DIR = ROOT / "assets" / "icons"
PNG_DIR = ROOT / "assets" / "png"
SVG_DIR.mkdir(parents=True, exist_ok=True)
PNG_DIR.mkdir(parents=True, exist_ok=True)

ICONS = {
    "shop": ("#FF60B5", "#FFFFFF", "bag"),
    "gacha": ("#B080FF", "#FFFFFF", "star"),
    "map": ("#78CBFF", "#FFFFFF", "map"),
    "messages": ("#E52D90", "#FFFFFF", "mail"),
    "teleport": ("#B080FF", "#FFFFFF", "portal"),
    "job": ("#56E0D1", "#FFFFFF", "briefcase"),
    "gem": ("#FF4AAD", "#FFDAF4", "gem"),
}


def svg_for(name: str, bg: str, accent: str, kind: str) -> str:
    shapes = {
        "bag": f'<path d="M42 40h44v46H42z" fill="none" stroke="{accent}" stroke-width="6" stroke-linejoin="round"/><path d="M50 40c0-12 8-20 14-20s14 8 14 20" fill="none" stroke="{accent}" stroke-width="6"/>',
        "star": f'<path d="M64 27l8 20h22L76 61l8 22-20-14-20 14 8-22-18-14h22z" fill="{accent}"/>',
        "map": f'<path d="M36 36l20-8 20 8 16-6v52l-16 6-20-8-20 8z" fill="none" stroke="{accent}" stroke-width="6" stroke-linejoin="round"/><path d="M56 28v52M76 36v52" stroke="{accent}" stroke-width="4"/>',
        "mail": f'<rect x="34" y="42" width="60" height="40" rx="6" fill="none" stroke="{accent}" stroke-width="6"/><path d="M34 48l30 22 30-22" fill="none" stroke="{accent}" stroke-width="6"/>',
        "portal": f'<ellipse cx="64" cy="64" rx="28" ry="36" fill="none" stroke="{accent}" stroke-width="6"/><ellipse cx="64" cy="64" rx="12" ry="36" fill="none" stroke="{accent}" stroke-width="4"/>',
        "briefcase": f'<rect x="34" y="48" width="60" height="40" rx="6" fill="none" stroke="{accent}" stroke-width="6"/><path d="M52 48v-6h24v6M34 66h60" stroke="{accent}" stroke-width="6"/>',
        "gem": f'<path d="M64 30l26 22-26 46L38 52z" fill="{accent}" stroke="#FFFFFF" stroke-width="4"/>',
    }
    body = shapes.get(kind, "")
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="1"/>
      <stop offset="42%" stop-color="{bg}" stop-opacity="1"/>
      <stop offset="100%" stop-color="{bg}" stop-opacity="0.88"/>
    </linearGradient>
  </defs>
  <circle cx="64" cy="64" r="58" fill="url(#g)" stroke="#FFFFFF" stroke-width="4"/>
  {body}
</svg>
'''


def png_for(name: str, bg: str, accent: str, kind: str, size: int = 128):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    bg_rgb = tuple(int(bg[i : i + 2], 16) for i in (1, 3, 5)) + (255,)
    accent_rgb = tuple(int(accent[i : i + 2], 16) for i in (1, 3, 5)) + (255,)
    margin = 4
    d.ellipse([margin, margin, size - margin, size - margin], fill=bg_rgb, outline=(255, 255, 255, 255), width=4)
    d.ellipse([18, 14, 110, 42], fill=(255, 255, 255, 88))

    cx = cy = size // 2
    if kind == "bag":
        d.rounded_rectangle([cx - 22, cy - 8, cx + 22, cy + 28], radius=6, outline=accent_rgb, width=5)
        d.arc([cx - 14, cy - 28, cx + 14, cy + 2], 200, 340, fill=accent_rgb, width=5)
    elif kind == "star":
        d.polygon([(cx, cy - 28), (cx + 16, cy), (cx, cy + 28), (cx - 16, cy)], fill=accent_rgb)
    elif kind == "map":
        d.line([(cx - 24, cy - 20), (cx - 4, cy - 28), (cx + 16, cy - 18), (cx + 28, cy - 24)], fill=accent_rgb, width=5)
        d.line([(cx - 24, cy - 20), (cx - 24, cy + 24), (cx - 4, cy + 16), (cx - 4, cy - 28)], fill=accent_rgb, width=4)
        d.line([(cx + 16, cy - 18), (cx + 16, cy + 26)], fill=accent_rgb, width=4)
    elif kind == "mail":
        d.rounded_rectangle([cx - 28, cy - 16, cx + 28, cy + 20], radius=4, outline=accent_rgb, width=5)
        d.line([(cx - 28, cy - 12), (cx, cy + 8), (cx + 28, cy - 12)], fill=accent_rgb, width=5)
    elif kind == "portal":
        d.ellipse([cx - 22, cy - 30, cx + 22, cy + 30], outline=accent_rgb, width=5)
        d.ellipse([cx - 8, cy - 30, cx + 8, cy + 30], outline=accent_rgb, width=3)
    elif kind == "briefcase":
        d.rounded_rectangle([cx - 28, cy - 10, cx + 28, cy + 26], radius=4, outline=accent_rgb, width=5)
        d.rectangle([cx - 10, cy - 18, cx + 10, cy - 10], outline=accent_rgb, width=4)
        d.line([(cx - 28, cy + 6), (cx + 28, cy + 6)], fill=accent_rgb, width=4)
    elif kind == "gem":
        d.polygon([(cx, cy - 28), (cx + 22, cy - 4), (cx, cy + 32), (cx - 22, cy - 4)], fill=accent_rgb, outline=(255, 255, 255, 255))

    img.save(PNG_DIR / f"{name}.png")


def main():
    for name, (bg, accent, kind) in ICONS.items():
        (SVG_DIR / f"{name}.svg").write_text(svg_for(name, bg, accent, kind), encoding="utf-8")
        png_for(name, bg, accent, kind)
    print(f"Wrote {len(ICONS)} SVG + PNG icons to {SVG_DIR} and {PNG_DIR}")


if __name__ == "__main__":
    main()
