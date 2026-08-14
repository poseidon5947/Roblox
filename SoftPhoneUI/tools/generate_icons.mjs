#!/usr/bin/env node
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { deflateSync } from "node:zlib";

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const SVG_DIR = join(ROOT, "assets", "icons");
const PNG_DIR = join(ROOT, "assets", "png");
mkdirSync(SVG_DIR, { recursive: true });
mkdirSync(PNG_DIR, { recursive: true });

const ICONS = {
  shop: ["#FF60B5", "#FFFFFF", "bag"],
  gacha: ["#B080FF", "#FFFFFF", "star"],
  map: ["#78CBFF", "#FFFFFF", "map"],
  messages: ["#E52D90", "#FFFFFF", "mail"],
  teleport: ["#B080FF", "#FFFFFF", "portal"],
  job: ["#56E0D1", "#FFFFFF", "briefcase"],
  gem: ["#FF4AAD", "#FFDAF4", "gem"],
};

function svgFor(bg, accent, kind) {
  const shapes = {
    bag: `<path d="M42 40h44v46H42z" fill="none" stroke="${accent}" stroke-width="6" stroke-linejoin="round"/><path d="M50 40c0-12 8-20 14-20s14 8 14 20" fill="none" stroke="${accent}" stroke-width="6"/>`,
    star: `<path d="M64 27l8 20h22L76 61l8 22-20-14-20 14 8-22-18-14h22z" fill="${accent}"/>`,
    map: `<path d="M36 36l20-8 20 8 16-6v52l-16 6-20-8-20 8z" fill="none" stroke="${accent}" stroke-width="6" stroke-linejoin="round"/><path d="M56 28v52M76 36v52" stroke="${accent}" stroke-width="4"/>`,
    mail: `<rect x="34" y="42" width="60" height="40" rx="6" fill="none" stroke="${accent}" stroke-width="6"/><path d="M34 48l30 22 30-22" fill="none" stroke="${accent}" stroke-width="6"/>`,
    portal: `<ellipse cx="64" cy="64" rx="28" ry="36" fill="none" stroke="${accent}" stroke-width="6"/><ellipse cx="64" cy="64" rx="12" ry="36" fill="none" stroke="${accent}" stroke-width="4"/>`,
    briefcase: `<rect x="34" y="48" width="60" height="40" rx="6" fill="none" stroke="${accent}" stroke-width="6"/><path d="M52 48v-6h24v6M34 66h60" stroke="${accent}" stroke-width="6"/>`,
    gem: `<path d="M64 30l26 22-26 46L38 52z" fill="${accent}" stroke="#FFFFFF" stroke-width="4"/>`,
  };
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="42%" stop-color="${bg}"/>
      <stop offset="100%" stop-color="${bg}" stop-opacity="0.88"/>
    </linearGradient>
  </defs>
  <circle cx="64" cy="64" r="58" fill="url(#g)" stroke="#FFFFFF" stroke-width="4"/>
  ${shapes[kind]}
</svg>
`;
}

function rgb(hex) {
  return [1, 3, 5].map((i) => Number.parseInt(hex.slice(i, i + 2), 16));
}

function crc32(buf) {
  let c = ~0;
  for (const b of buf) {
    c ^= b;
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
  }
  return ~c >>> 0;
}

function chunk(type, data) {
  const t = Buffer.from(type);
  const out = Buffer.alloc(12 + data.length);
  out.writeUInt32BE(data.length, 0);
  t.copy(out, 4);
  data.copy(out, 8);
  out.writeUInt32BE(crc32(Buffer.concat([t, data])), 8 + data.length);
  return out;
}

function makeCanvas(size) {
  const pix = new Uint8ClampedArray(size * size * 4);
  function set(x, y, c) {
    x = Math.round(x); y = Math.round(y);
    if (x < 0 || y < 0 || x >= size || y >= size) return;
    const i = (y * size + x) * 4;
    pix[i] = c[0]; pix[i + 1] = c[1]; pix[i + 2] = c[2]; pix[i + 3] = c[3] ?? 255;
  }
  function circle(cx, cy, r, c) {
    for (let y = cy - r; y <= cy + r; y++) {
      for (let x = cx - r; x <= cx + r; x++) {
        if ((x - cx) ** 2 + (y - cy) ** 2 <= r ** 2) set(x, y, c);
      }
    }
  }
  function ellipse(cx, cy, rx, ry, c) {
    for (let y = cy - ry; y <= cy + ry; y++) {
      for (let x = cx - rx; x <= cx + rx; x++) {
        if (((x - cx) ** 2) / (rx ** 2) + ((y - cy) ** 2) / (ry ** 2) <= 1) set(x, y, c);
      }
    }
  }
  function line(x1, y1, x2, y2, w, c) {
    const steps = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1));
    for (let i = 0; i <= steps; i++) circle(x1 + ((x2 - x1) * i) / steps, y1 + ((y2 - y1) * i) / steps, w / 2, c);
  }
  function rect(x, y, w, h, c, stroke = 0) {
    if (stroke) {
      line(x, y, x + w, y, stroke, c); line(x, y + h, x + w, y + h, stroke, c);
      line(x, y, x, y + h, stroke, c); line(x + w, y, x + w, y + h, stroke, c);
    } else {
      for (let yy = y; yy < y + h; yy++) for (let xx = x; xx < x + w; xx++) set(xx, yy, c);
    }
  }
  function poly(points, c) {
    const ys = points.map((p) => p[1]);
    for (let y = Math.min(...ys); y <= Math.max(...ys); y++) {
      const xs = [];
      for (let i = 0; i < points.length; i++) {
        const [x1, y1] = points[i], [x2, y2] = points[(i + 1) % points.length];
        if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y)) xs.push(x1 + ((y - y1) * (x2 - x1)) / (y2 - y1));
      }
      xs.sort((a, b) => a - b);
      for (let i = 0; i < xs.length; i += 2) for (let x = xs[i]; x <= xs[i + 1]; x++) set(x, y, c);
    }
  }
  return { pix, set, circle, ellipse, line, rect, poly };
}

function pngFor(bgHex, accentHex, kind) {
  const size = 128;
  const c = makeCanvas(size);
  const bg = [...rgb(bgHex), 255];
  const accent = [...rgb(accentHex), 255];
  const white = [255, 255, 255, 255];
  c.circle(64, 64, 60, white);
  c.circle(64, 64, 56, bg);
  c.ellipse(64, 28, 44, 14, [255, 255, 255, 90]);

  if (kind === "bag") {
    c.rect(42, 42, 44, 42, accent, 5); c.line(50, 42, 56, 24, 5, accent); c.line(78, 42, 72, 24, 5, accent); c.line(56, 24, 72, 24, 5, accent);
  } else if (kind === "star") {
    c.poly([[64, 28], [75, 52], [100, 52], [80, 68], [88, 92], [64, 78], [40, 92], [48, 68], [28, 52], [53, 52]], accent);
  } else if (kind === "map") {
    c.line(36, 36, 56, 28, 5, accent); c.line(56, 28, 76, 36, 5, accent); c.line(76, 36, 92, 30, 5, accent);
    c.line(36, 36, 36, 86, 5, accent); c.line(56, 28, 56, 80, 4, accent); c.line(76, 36, 76, 88, 4, accent); c.line(36, 86, 56, 80, 5, accent); c.line(56, 80, 76, 88, 5, accent); c.line(76, 88, 92, 82, 5, accent);
  } else if (kind === "mail") {
    c.rect(34, 44, 60, 38, accent, 5); c.line(34, 48, 64, 70, 5, accent); c.line(94, 48, 64, 70, 5, accent);
  } else if (kind === "portal") {
    c.ellipse(64, 64, 28, 36, accent); c.ellipse(64, 64, 22, 30, bg); c.ellipse(64, 64, 12, 34, accent); c.ellipse(64, 64, 7, 29, bg);
  } else if (kind === "briefcase") {
    c.rect(34, 50, 60, 38, accent, 5); c.rect(54, 40, 20, 10, accent, 4); c.line(34, 66, 94, 66, 5, accent);
  } else if (kind === "gem") {
    c.poly([[64, 30], [90, 52], [64, 98], [38, 52]], accent); c.line(64, 30, 90, 52, 3, white); c.line(90, 52, 64, 98, 3, white); c.line(64, 98, 38, 52, 3, white); c.line(38, 52, 64, 30, 3, white);
  }

  const raw = Buffer.alloc((size * 4 + 1) * size);
  for (let y = 0; y < size; y++) {
    raw[y * (size * 4 + 1)] = 0;
    Buffer.from(c.pix.slice(y * size * 4, (y + 1) * size * 4)).copy(raw, y * (size * 4 + 1) + 1);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0); ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8; ihdr[9] = 6; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
  return Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), chunk("IHDR", ihdr), chunk("IDAT", deflateSync(raw)), chunk("IEND", Buffer.alloc(0))]);
}

for (const [name, [bg, accent, kind]] of Object.entries(ICONS)) {
  writeFileSync(join(SVG_DIR, `${name}.svg`), svgFor(bg, accent, kind), "utf8");
  writeFileSync(join(PNG_DIR, `${name}.png`), pngFor(bg, accent, kind));
}
console.log(`Wrote ${Object.keys(ICONS).length} SVG + PNG icons`);
