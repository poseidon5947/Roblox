const BUTTONS = [
  { id: "Shop", label: "Shop", icon: "shop" },
  { id: "Gacha", label: "Gacha", icon: "gacha", badge: "FREE" },
  { id: "Map", label: "Map", icon: "map" },
  { id: "Messages", label: "Messages", icon: "messages", badge: "3" },
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
    eyebrow: "CAPSULE LAB",
    headline: "Lucky streak ready",
    subline: "Your next sparkle is waiting.",
    metrics: [["PITY", "42 / 80"], ["TOKENS", "8"]],
    section: "FEATURED CAPSULE",
    featured: "Celestial Ribbon",
    body: "Pastel halos, ribbon trails, and one limited aura.",
    reward: "150 GEMS",
    action: "Preview Pool",
    cards: [["Daily Wish", "Use one free pull", "READY", 100], ["Star Collector", "Collect 3 capsule stars", "2 / 3", 66]],
    footer: ["Pull x1", "Pull x10", "History"],
  },
  Map: {
    title: "map.exe",
    eyebrow: "FURU NAV",
    headline: "Moonlight District",
    subline: "3 nearby activities are active.",
    metrics: [["PINS", "12"], ["FOUND", "68%"]],
    section: "RECOMMENDED STOP",
    featured: "Moonlight Plaza",
    body: "Shopping, gacha kiosks, and the evening fountain show.",
    reward: "240m AWAY",
    action: "Set Route",
    cards: [["Cafe Lumi", "New seasonal menu", "OPEN", 80], ["Job Hub", "Two bonus shifts", "+20%", 55]],
    footer: ["Zoom", "Pins", "Home"],
  },
  Messages: {
    title: "messages.exe",
    eyebrow: "FURU MAIL",
    headline: "Good afternoon",
    subline: "You have 3 unread messages.",
    metrics: [["UNREAD", "3"], ["FRIENDS", "18"]],
    section: "LATEST MESSAGE",
    featured: "Welcome to Moonlight Plaza",
    body: "The fountain event begins tonight. Bring a friend for a bonus.",
    reward: "2m AGO",
    action: "Open Message",
    cards: [["Mika", "Meet me by the boutique!", "NEW", 92], ["Furu System", "Daily reward delivered", "READ", 100]],
    footer: ["Compose", "Inbox", "Clear"],
  },
  Teleport: {
    title: "teleport.exe",
    eyebrow: "QUICK TRAVEL",
    headline: "Where to next?",
    subline: "Travel points are online.",
    metrics: [["POINTS", "7"], ["COST", "FREE"]],
    section: "POPULAR DESTINATION",
    featured: "Furu Central Plaza",
    body: "The fastest route to shops, events, and daily rewards.",
    reward: "INSTANT",
    action: "Teleport",
    cards: [["Fashion Mall", "Boutiques and salon", "ONLINE", 100], ["Job Hub", "Careers and shifts", "ONLINE", 100]],
    footer: ["Plaza", "Mall", "Job Hub"],
  },
  Job: {
    title: "job.exe",
    eyebrow: "CAREER DESK",
    headline: "FuruUser",
    subline: "Intern | Level 1 | 120 / 500 XP",
    metrics: [["BONUS", "200"], ["REP", "1"]],
    section: "FEATURED CAREER",
    featured: "Office Assistant",
    body: "Organize documents, assist staff, and complete daily tasks.",
    reward: "150 GEMS",
    action: "Start Job",
    cards: [["File Documents", "Complete ten files", "6 / 10", 60], ["Morning Delivery", "Deliver three orders", "1 / 3", 33]],
    footer: ["Apply", "Shifts", "Pay"],
  },
};

const sidebar = document.getElementById("sidebar");
const gem = document.getElementById("gem");
const nav = document.getElementById("navButtons");
const host = document.getElementById("windowHost");
const stage = document.getElementById("stage");
const activeApp = document.getElementById("activeApp");

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
  btn.dataset.id = def.id;
  btn.innerHTML = `<span class="icon icon-${def.icon}"></span><span class="nav-label">${def.label}</span>${def.badge ? `<span class="notice-badge">${def.badge}</span>` : ""}`;
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
    b.addEventListener("click", () => {
      b.textContent = `${label.toUpperCase()} READY`;
      window.setTimeout(() => { b.textContent = label; }, 1000);
    });
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
    <div class="preview-status" id="previewStatus">PREVIEW MODE</div>
    <div class="preview-avatar" id="previewAvatar"></div>
    <div class="tryon-caption" id="tryonCaption">Your look - pick an item</div>
  `;

  const selected = document.createElement("div");
  selected.className = "selected";
  selected.innerHTML = `
    <h3 id="selectedName">Select an item</h3>
    <p id="selectedPrice">GEMS --</p>
    <p id="selectedNote">Tap an item to preview it here. Full avatar try-on is ready for catalog asset IDs.</p>
  `;

  ITEMS.forEach((item) => {
    const el = document.createElement("button");
    el.type = "button";
    el.className = "item";
    el.innerHTML = `
      <div class="swatch" style="background:${item.color}"></div>
      <div class="name">${item.name}</div>
      <div class="price">GEMS ${item.price}</div>
      <div class="selected-badge">SELECTED</div>
    `;
    el.addEventListener("click", () => {
      grid.querySelectorAll(".item").forEach((slot) => slot.classList.remove("selected-item"));
      el.classList.add("selected-item");
      document.getElementById("tryonCaption").textContent = `Trying: ${item.name}`;
      document.getElementById("previewStatus").textContent = "ITEM PREVIEW";
      document.getElementById("previewAvatar").style.filter = `hue-rotate(${(item.price * 2) % 120}deg)`;
      document.getElementById("selectedName").textContent = item.name;
      document.getElementById("selectedPrice").textContent = `GEMS ${item.price}`;
      document.getElementById("selectedNote").textContent = "Selected for preview. Add catalog IDs to enable live avatar fitting.";
    });
    grid.appendChild(el);
  });

  body.append(grid, stageTry, selected);
  makeChrome("Shop", "shop.exe", body, ["Reset Look", "Refresh", "Apply Preview"]);

  const shopWindow = body.parentElement.parentElement;
  const footerButtons = shopWindow.querySelectorAll(".footer button");

  footerButtons[0].addEventListener("click", () => {
    grid.querySelectorAll(".item").forEach((slot) => slot.classList.remove("selected-item"));
    document.getElementById("tryonCaption").textContent = "Your look - pick an item";
    document.getElementById("previewStatus").textContent = "PREVIEW MODE";
    document.getElementById("previewAvatar").style.filter = "";
    document.getElementById("selectedName").textContent = "Select an item";
    document.getElementById("selectedPrice").textContent = "GEMS --";
    document.getElementById("selectedNote").textContent = "Tap an item to preview it here. Full avatar try-on is ready for catalog asset IDs.";
  });

  footerButtons[2].addEventListener("click", () => {
    const name = document.getElementById("selectedName").textContent;
    const hasSelection = name && name !== "Select an item";
    document.getElementById("tryonCaption").textContent = hasSelection ? `Previewing: ${name}` : "Pick an item first";
    document.getElementById("previewStatus").textContent = hasSelection ? "LOOK APPLIED" : "PICK ITEM";
  });
}

function buildShells() {
  Object.entries(SHELLS).forEach(([id, spec]) => {
    const body = document.createElement("div");
    body.className = "dashboard";
    body.innerHTML = `
      <section class="profile-strip">
        <span class="feature-icon icon icon-${BUTTONS.find((item) => item.id === id)?.icon}"></span>
        <div class="profile-copy"><small>${spec.eyebrow}</small><h2>${spec.headline}</h2><p>${spec.subline}</p></div>
        <div class="metrics">${spec.metrics.map(([name, value]) => `<div class="metric"><strong>${value}</strong><span>${name}</span></div>`).join("")}</div>
      </section>
      <h3 class="section-label">${spec.section}</h3>
      <section class="featured-card">
        <span class="featured-icon icon icon-${BUTTONS.find((item) => item.id === id)?.icon}"></span>
        <div class="featured-copy"><h2>${spec.featured}</h2><p>${spec.body}</p></div>
        <strong class="reward">${spec.reward}</strong>
        <button type="button" class="primary-action">${spec.action}</button>
      </section>
      <h3 class="section-label">ACTIVE CARDS</h3>
      <div class="task-grid">${spec.cards.map(([name, description, state, progress]) => `
        <article class="task-card"><div><h4>${name}</h4><strong>${state}</strong></div><p>${description}</p><span class="progress"><i style="width:${progress}%"></i></span></article>`).join("")}</div>
    `;
    const action = body.querySelector(".primary-action");
    action.addEventListener("click", () => {
      const original = spec.action;
      action.textContent = "SELECTED";
      window.setTimeout(() => { action.textContent = original; }, 1000);
    });
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
  document.querySelectorAll(".nav-btn").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.id === id);
  });
  activeApp.textContent = `OPEN: ${id.toUpperCase()}`;
  activeApp.classList.add("has-window");
  activeWindow = id;
}

function closeWindow(id) {
  const win = windows[id];
  if (!win) return;
  win.classList.remove("open");
  if (activeWindow === id) {
    activeWindow = null;
    document.querySelectorAll(".nav-btn").forEach((btn) => btn.classList.remove("active"));
    activeApp.textContent = "OPEN: NONE";
    activeApp.classList.remove("has-window");
  }
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
