const BUTTONS = [
  { id: "Shop", label: "Shop", icon: "shop" },
  { id: "Gacha", label: "Gacha", icon: "gacha" },
  { id: "Map", label: "Map", icon: "map" },
  { id: "Messages", label: "Messages", icon: "messages" },
  { id: "Teleport", label: "Teleport", icon: "teleport" },
  { id: "Job", label: "Job", icon: "job" },
];

const ITEMS = [
  { name: "Pixel Bow Jacket", price: 120, color: "#ff60b5" },
  { name: "Starline Skirt", price: 90, color: "#b080ff" },
  { name: "Bubble Boots", price: 150, color: "#78cbff" },
  { name: "Ribbon Satchel", price: 75, color: "#e52d90" },
  { name: "Mint Sleeve Set", price: 40, color: "#56e0d1" },
  { name: "Glow Hairclip", price: 55, color: "#b080ff" },
];

const SHELLS = {
  Gacha: {
    title: "gacha.exe",
    headline: "Gacha",
    body: "Capsule pull screen. Connect rarity tables, reward animations, and inventory grants here.",
    footer: ["Pull x1", "Pull x10", "History"],
  },
  Map: {
    title: "map.exe",
    headline: "Map",
    body: "World map shell. Add landmark buttons, current-player markers, and quest pins.",
    footer: ["Zoom", "Pins", "Home"],
  },
  Messages: {
    title: "messages.exe",
    headline: "Messages",
    body: "Inbox shell for friends, mail, announcements, and system notes.",
    footer: ["Compose", "Inbox", "Clear"],
  },
  Teleport: {
    title: "teleport.exe",
    headline: "Teleport",
    body: "Quick travel shell. Hook TeleportService or local destination pads here.",
    footer: ["Plaza", "Mall", "Job Hub"],
  },
  Job: {
    title: "job.exe",
    headline: "Job",
    body: "Career board shell. List shifts, pay, outfit rules, and active tasks.",
    footer: ["Apply", "Shifts", "Pay"],
  },
};

const sidebar = document.getElementById("sidebar");
const gem = document.getElementById("gem");
const nav = document.getElementById("navButtons");
const host = document.getElementById("windowHost");
const stage = document.getElementById("stage");

let expanded = false;
let activeWindow = null;
const windows = {};

function setExpanded(next) {
  expanded = next;
  sidebar.classList.toggle("expanded", expanded);
  sidebar.classList.toggle("collapsed", !expanded);
  gem.setAttribute("aria-expanded", String(expanded));
}

gem.addEventListener("click", () => setExpanded(!expanded));

BUTTONS.forEach((def) => {
  const btn = document.createElement("button");
  btn.type = "button";
  btn.className = "nav-btn";
  btn.innerHTML = `<span class="icon icon-${def.icon}"></span><span>${def.label}</span>`;
  btn.addEventListener("click", () => {
    if (!expanded) setExpanded(true);
    openWindow(def.id);
  });
  nav.appendChild(btn);
});

function makeChrome(id, titleText, bodyEl, footerLabels) {
  const win = document.createElement("section");
  win.className = "window";
  win.dataset.id = id;
  const icon = BUTTONS.find((button) => button.id === id)?.icon || "gem";
  win.innerHTML = `
    <div class="bevel"></div>
    <span class="decor bow win-bow"></span>
    <span class="decor gem-small win-gem-top"></span>
    <span class="decor gem-small win-gem-bottom"></span>
    <div class="titlebar">
      <span class="app-badge"><span class="icon icon-${icon}"></span></span>
      <span class="window-title">${titleText}</span>
      <span class="live-pill"><span></span>ONLINE</span>
      <div class="sys">
        <button type="button" class="min" tabindex="-1">_</button>
        <button type="button" class="max" tabindex="-1">[]</button>
        <button type="button" class="close" aria-label="Close">X</button>
      </div>
    </div>
    <div class="menubar">File &nbsp;&nbsp; Edit &nbsp;&nbsp; View &nbsp;&nbsp; Help</div>
    <div class="content"></div>
    <div class="footer"></div>
  `;
  win.querySelector(".content").appendChild(bodyEl);
  const footer = win.querySelector(".footer");
  footerLabels.forEach((label) => {
    const b = document.createElement("button");
    b.type = "button";
    b.textContent = label;
    footer.appendChild(b);
  });
  win.querySelector(".close").addEventListener("click", () => closeWindow(id));
  host.appendChild(win);
  windows[id] = win;
}

function buildShop() {
  const body = document.createElement("div");
  body.className = "shop-layout";

  const grid = document.createElement("div");
  grid.className = "item-grid";

  const stageTry = document.createElement("div");
  stageTry.className = "stage-tryon";
  stageTry.innerHTML = `
    <div class="preview-avatar" id="previewAvatar"></div>
    <div class="tryon-caption" id="tryonCaption">Your look - pick an item</div>
  `;

  const selected = document.createElement("div");
  selected.className = "selected";
  selected.innerHTML = `
    <h3 id="selectedName">Select an item</h3>
    <p id="selectedPrice">GEMS --</p>
    <p id="selectedNote">Tap an item to preview it on the avatar. Catalog hooks can replace this sample state.</p>
  `;

  ITEMS.forEach((item) => {
    const el = document.createElement("button");
    el.type = "button";
    el.className = "item";
    el.innerHTML = `
      <div class="swatch" style="background:${item.color}"></div>
      <div class="name">${item.name}</div>
      <div class="price">GEMS ${item.price}</div>
    `;
    el.addEventListener("click", () => {
      document.getElementById("tryonCaption").textContent = `Trying: ${item.name}`;
      document.getElementById("previewAvatar").style.filter = `hue-rotate(${(item.price * 2) % 120}deg)`;
      document.getElementById("selectedName").textContent = item.name;
      document.getElementById("selectedPrice").textContent = `GEMS ${item.price}`;
      document.getElementById("selectedNote").textContent = "Preview selected. Hook this to HumanoidDescription or owned inventory.";
    });
    grid.appendChild(el);
  });

  body.append(grid, stageTry, selected);
  makeChrome("Shop", "shop.exe", body, ["Reset Look", "Refresh", "Buy Soon"]);

  body.parentElement.parentElement.querySelector(".footer").firstChild.addEventListener("click", () => {
    document.getElementById("tryonCaption").textContent = "Your look - pick an item";
    document.getElementById("previewAvatar").style.filter = "";
    document.getElementById("selectedName").textContent = "Select an item";
    document.getElementById("selectedPrice").textContent = "GEMS --";
    document.getElementById("selectedNote").textContent = "Tap an item to preview it on the avatar. Catalog hooks can replace this sample state.";
  });
}

function buildShells() {
  Object.entries(SHELLS).forEach(([id, spec]) => {
    const body = document.createElement("div");
    body.className = "shell";
    body.innerHTML = `<h2>${spec.headline}</h2><div class="panel">${spec.body}</div>`;
    makeChrome(id, spec.title, body, spec.footer);
  });
}

function openWindow(id) {
  if (activeWindow && activeWindow !== id) closeWindow(activeWindow);
  if (activeWindow === id) {
    closeWindow(id);
    return;
  }
  const win = windows[id];
  if (!win) return;
  win.classList.add("open");
  activeWindow = id;
}

function closeWindow(id) {
  const win = windows[id];
  if (!win) return;
  win.classList.remove("open");
  if (activeWindow === id) activeWindow = null;
}

buildShop();
buildShells();

document.querySelectorAll(".device-bar button").forEach((btn) => {
  btn.addEventListener("click", () => {
    document.querySelectorAll(".device-bar button").forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    stage.classList.remove("desktop", "tablet", "phone");
    stage.classList.add(btn.dataset.device);
  });
});
