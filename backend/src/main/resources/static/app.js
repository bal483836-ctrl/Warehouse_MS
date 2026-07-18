/* ================= 小明智库 · 前端应用 ================= */
(function () {
  const $ = (s, r = document) => r.querySelector(s);
  const tip = $('#tip'), toast = $('#toast');
  const TOKEN = localStorage.getItem('wms_token');
  if (!TOKEN) { location.href = 'login.html'; return; }
  const USER = JSON.parse(localStorage.getItem('wms_user') || '{}');

  /* ---------- API ---------- */
  async function api(path, opts = {}) {
    const r = await fetch(path, { ...opts, headers: { 'Content-Type': 'application/json', token: TOKEN, ...(opts.headers || {}) } });
    if (r.status === 401) { localStorage.clear(); location.href = 'login.html'; throw new Error('401'); }
    return r.json().catch(() => ({ code: 500, msg: '响应解析失败' }));
  }
  const get = p => api(p);
  const del = p => api(p, { method: 'DELETE' });
  const post = (p, b) => api(p, { method: 'POST', body: JSON.stringify(b) });
  const put = (p, b) => api(p, { method: 'PUT', body: JSON.stringify(b) });

  function showToast(msg, err) { toast.textContent = msg; toast.className = 'toast show' + (err ? ' err' : ''); setTimeout(() => toast.className = 'toast', 2200); }
  function showTip(html, x, y) { tip.innerHTML = html; tip.classList.add('show'); const w = tip.offsetWidth, h = tip.offsetHeight; tip.style.left = Math.min(x + 14, innerWidth - w - 8) + 'px'; tip.style.top = Math.max(8, y - h - 12) + 'px'; }
  const hideTip = () => tip.classList.remove('show');
  const esc = s => String(s == null ? '' : s).replace(/[&<>"]/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[m]));
  const fmt = n => (n == null ? 0 : Number(n)).toLocaleString();
  const money = n => '¥' + (Number(n || 0)).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const dt = s => (String(s || '').replace('T', ' ').slice(0, 16));

  /* ---------- 配置 ---------- */
  const ZONES = ['冷冻', '冰鲜', '普通'];
  const ORDER_STATUS = ['待处理', '已完成', '已取消'];
  const PERIODS = [['day', '天'], ['week', '周'], ['month', '月'], ['quarter', '季']];
  const statusPill = s => { const c = ['#e0920a', '#0ca30c', '#8a99b5'][s] || '#8a99b5'; return `<span class="pill" style="color:${c};background:color-mix(in srgb,${c} 14%,transparent)"><span class="d"></span>${ORDER_STATUS[s] || '—'}</span>`; };
  function zoneTag(z) { z = z || '普通'; const c = { 冷冻: '#2a78d6', 冰鲜: '#1baf7a', 普通: '#8a99b5' }[z] || '#8a99b5'; return `<span class="pill" style="color:${c};background:color-mix(in srgb,${c} 14%,transparent)"><span class="d"></span>${z}</span>`; }

  const NAV = [
    { group: '概览', items: [
      ['dashboard', '运营总览', 'M3 12 12 4l9 8M5 10v10h14V10'],
      ['alerts', '预警看板', 'M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Zm3 10a3 3 0 0 0 6 0'] ] },
    { group: '进销存', items: [
      ['inout', '出入库操作', 'M3 7l9-4 9 4-9 4-9-4Zm0 5 9 4 9-4M3 17l9 4 9-4'],
      ['t/record', '出入库记录', 'M4 5h16v14H4zM4 9h16'],
      ['t/goods', '商品档案', 'M20 7 12 3 4 7v10l8 4 8-4V7Z'],
      ['t/goodstype', '商品分类', 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z'] ] },
    { group: '订单', items: [
      ['orders/0', '采购订单', 'M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4ZM3 6h18M16 10a4 4 0 0 1-8 0'],
      ['orders/1', '销售订单', 'M9 2h6l1 4H8ZM4 6h16l-1 14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2ZM9 11v6m6-6v6'] ] },
    { group: '仓储', items: [
      ['t/location', '货位管理', 'M12 21s7-6 7-11a7 7 0 1 0-14 0c0 5 7 11 7 11ZM12 8v4'],
      ['t/stock_alert', '预警阈值', 'M12 3 2 20h20L12 3Zm0 7v4m0 3h.01'] ] },
    { group: '供应链', items: [
      ['t/supplier', '供应商', 'M3 7h18v13H3zM3 7l3-4h12l3 4'] ] },
    { group: '系统', items: [
      ['t/sys_log', '操作日志', 'M4 4h16v16H4zM8 9h8M8 13h5'],
      ['profile', '个人资料', 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM4 21a8 8 0 0 1 16 0'] ] }
  ];
  const LABELS = { id: 'ID', name: '名称', remark: '备注', count: '数量', storage: '仓库', goodsType: '分类', goods: '货品', zone: '分区',
    userId: '操作人', createtime: '时间', createTime: '时间', minCount: '安全下限', maxCount: '库存上限', enabled: '状态',
    goodsId: '商品', storageId: '所属仓库', code: '库位编码', capacity: '容量', title: '标题', content: '操作内容',
    ipAddr: 'IP地址', methods: '接口', result: '结果', duration: '耗时(ms)' };
  const lab = k => LABELS[k] || k;

  /* ---------- 关联字典 ---------- */
  const refs = {};
  async function loadRefs() {
    const [st, gt, gs, sp] = await Promise.all([get('/api/storage'), get('/api/goodstype'), get('/api/goods'), get('/api/supplier')]);
    refs.storage = map(st.data, 'id', 'name'); refs.goodstype = map(gt.data, 'id', 'name');
    refs.goods = map(gs.data, 'id', 'name'); refs.supplier = map(sp.data, 'id', 'name');
    refs.goodsList = gs.data || []; refs.storageList = st.data || []; refs.typeList = gt.data || []; refs.supplierList = sp.data || [];
  }
  const map = (arr, k, v) => (arr || []).reduce((o, x) => (o[x[k]] = x[v], o), {});

  /* ---------- 角色权限 ---------- */
  const isAdmin = () => (USER.role || 'admin') !== 'operator';
  // 操作员仅可见：出入库操作、销售订单、个人资料
  const OP_ROUTES = ['inout', 'orders/1', 'profile'];
  const opAllowed = h => OP_ROUTES.includes(h) || h.startsWith('goods/') || h.startsWith('order/');
  // 就地表单/删除保存后返回：hash 未变时直接重渲染，避免卡在原界面
  const goTo = h => { if ((location.hash.slice(2) || 'dashboard') === h) route(); else location.hash = '#/' + h; };

  /* ---------- 导航 / 顶栏 ---------- */
  function buildNav() {
    const admin = isAdmin();
    $('#nav').innerHTML = NAV.map(g => {
      const items = g.items.filter(([route]) => admin || OP_ROUTES.includes(route));
      if (!items.length) return '';
      return `<div class="nav-group">${g.group}</div>` +
        items.map(([route, label, icon]) => `<a href="#/${route}" data-route="${route}"><svg viewBox="0 0 24 24" fill="none"><path d="${icon}" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>${label}</a>`).join('');
    }).join('');
    $('#uname').textContent = USER.name || '用户';
    $('#unum').textContent = (USER.number || '') + ' · 在线';
    $('#avatar').textContent = (USER.name || 'U').charAt(0);
    $('#today').textContent = new Date().toLocaleDateString('zh-CN');
    $('#logout').onclick = async () => { await post('/api/auth/logout', {}); localStorage.clear(); location.href = 'login.html'; };
    const app = document.querySelector('.app'), mb = $('#menuBtn'), bd = $('#navBackdrop');
    if (mb) mb.onclick = () => app.classList.toggle('nav-open');
    if (bd) bd.onclick = () => app.classList.remove('nav-open');
    $('#nav').addEventListener('click', e => { if (e.target.closest('a')) app.classList.remove('nav-open'); });
    setupBell();
  }
  function setActive(route) { document.querySelectorAll('#nav a').forEach(a => a.classList.toggle('active', a.dataset.route === route)); }
  const greet = () => { const h = new Date().getHours(); return h < 6 ? '凌晨好' : h < 12 ? '上午好' : h < 14 ? '中午好' : h < 18 ? '下午好' : '晚上好'; };
  const crumbs = items => `<nav class="crumbs">${items.map((it, i) => it[1] ? `<a href="#/${it[1]}">${esc(it[0])}</a><span class="sep">/</span>` : `<span class="cur">${esc(it[0])}</span>`).join('')}</nav>`;

  /* ---------- 系统提示铃铛 ---------- */
  async function setupBell() {
    const btn = $('#bellBtn'), panel = $('#bellPanel'), badge = $('#bellBadge');
    if (!btn) return;
    btn.onclick = e => { e.stopPropagation(); panel.hidden = !panel.hidden; };
    document.addEventListener('click', e => { if (!e.target.closest('#bellWrap')) panel.hidden = true; });
    await refreshBell();
  }
  async function refreshBell() {
    const panel = $('#bellPanel'), badge = $('#bellBadge');
    if (!panel) return;
    const res = await get('/api/notices'); const list = res.data || [];
    badge.textContent = list.length; badge.hidden = list.length === 0;
    panel.innerHTML = `<div class="bell-h">系统提示 <span>${list.length}</span></div>` + (list.length === 0
      ? '<div class="bell-empty">✓ 暂无提示，一切正常</div>'
      : list.map(n => `<div class="bell-item ${n.level}" ${n.goodsId ? `data-g="${n.goodsId}"` : ''}>
          <div class="bi-dot ${n.type}"></div><div><div class="bi-t">${esc(n.title)}</div><div class="bi-x">${esc(n.text)}</div></div></div>`).join(''));
    panel.querySelectorAll('[data-g]').forEach(el => el.onclick = () => { panel.hidden = true; location.hash = '#/goods/' + el.dataset.g; });
  }

  /* ---------- 路由 ---------- */
  async function route() {
    let hash = location.hash.slice(2) || 'dashboard';
    // 操作员越权访问 → 重定向到出入库操作
    if (!isAdmin() && !opAllowed(hash)) { location.hash = '#/inout'; return; }
    const view = $('#view');
    view.innerHTML = '<div class="loading"><div class="spin"></div></div>';
    try {
      if (hash === 'dashboard') { setActive('dashboard'); await renderDashboard(view); }
      else if (hash === 'alerts') { setActive('alerts'); await renderAlerts(view); }
      else if (hash === 'inout') { setActive('inout'); await renderInout(view); }
      else if (hash === 'profile') { setActive('profile'); await renderProfile(view); }
      else if (hash.startsWith('orders/')) { const ty = +hash.slice(7); setActive('orders/' + ty); await renderOrders(view, ty); }
      else if (hash.startsWith('order/')) { setActive('orders/0'); await renderOrderDetail(view, +hash.slice(6)); }
      else if (hash === 't/goods') { setActive('t/goods'); await renderGoods(view); }
      else if (hash.startsWith('goods/')) { setActive('t/goods'); await renderGoodsDetail(view, +hash.slice(6)); }
      else if (hash === 't/supplier') { setActive('t/supplier'); await renderSuppliers(view); }
      else if (hash.startsWith('supplier/')) { setActive('t/supplier'); await renderSupplierDetail(view, +hash.slice(9)); }
      else if (hash === 't/location') { setActive('t/location'); await renderLocationBoard(view); }
      else if (hash.startsWith('t/')) { const t = hash.slice(2); setActive(hash); await renderTable(view, t); }
      else view.innerHTML = '<div class="card">页面不存在</div>';
    } catch (e) { if (e.message !== '401') view.innerHTML = `<div class="card">加载失败：${esc(e.message)}</div>`; }
  }

  /* ================= 运营总览 ================= */
  async function renderDashboard(view) {
    $('#pageTitle').textContent = '运营总览';
    $('#pageSub').textContent = `${greet()}，${USER.name || ''} · 实时库存与出入库概览`;
    const [kpi, cat, capRes] = await Promise.all([get('/api/stats/kpi'), get('/api/stats/category'), get('/api/stats/capacity')]);
    const k = kpi.data;
    view.innerHTML = `
      <section class="kpis kpis-6">
        ${kpiTile('blue', '总库存量', fmt(k.totalStock), '件', 'M3 7l9-4 9 4-9 4-9-4Zm0 5 9 4 9-4M3 17l9 4 9-4', 't/goods')}
        ${kpiTile('red', '库存预警', k.alertCount, '项', 'M12 3 2 20h20L12 3Zm0 7v4m0 3h.01', 'alerts')}
        ${kpiTile('crit', '过保质期', k.expired == null ? 0 : k.expired, '项', 'M12 8v5m0 3h.01M12 3 2 20h20L12 3Z', 'alerts')}
        ${kpiTile('amber', '临期预警', k.expiring == null ? 0 : k.expiring, '项', 'M12 8v5l3 2M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z', 'alerts')}
        ${kpiTile('green', '待入库', k.pendingIn == null ? 0 : k.pendingIn, '单', 'M12 20V6m0 0-6 6m6-6 6 6', 'orders/0')}
        ${kpiTile('slate', '待出库', k.pendingOut == null ? 0 : k.pendingOut, '单', 'M12 4v14m0 0 6-6m-6 6-6-6', 'orders/1')}
      </section>
      <section class="grid-2">
        <div class="card">
          <div class="card-h"><div><h3>库存容量图</h3><div class="desc">各仓库已用容量 / 总容量（按商品容量占比折算）· 点击进入货位管理</div></div><div class="right"><span class="pill" style="color:var(--ink-2);background:var(--surface-2)">总使用率 ${k.usage}%</span></div></div>
          <div id="capChart" style="margin-top:10px"></div>
        </div>
        <div class="card">
          <div class="card-h"><div><h3>库存分类占比</h3><div class="desc">总库存 ${fmt(k.totalStock)} 件</div></div></div>
          <div class="donut-wrap" style="margin-top:8px"><div id="donut"></div><div class="donut-legend" id="donutLegend"></div></div>
        </div>
      </section>
      <section class="card">
        <div class="card-h"><div><h3>近期出入库记录</h3></div><div class="right"><a class="btn btn-sm" href="#/inout">去操作</a></div></div>
        <div class="tablewrap" style="margin-top:6px"><table><thead><tr><th>货物</th><th>分区</th><th>类型</th><th>数量</th><th>操作人</th><th>时间</th></tr></thead><tbody id="recRows"></tbody></table></div>
      </section>`;
    drawCapacity($('#capChart'), capRes.data || []); drawDonut(cat.data);
    const rec = await get('/api/record');
    const rows = (rec.data || []).sort((a, b) => b.id - a.id).slice(0, 8);
    $('#recRows').innerHTML = rows.map(r => { const g = refs.goodsList.find(x => x.id === r.goods) || {}; const inb = r.type === 0;
      return `<tr><td>${esc(g.name || ('#' + r.goods))}</td><td>${zoneTag(g.zone)}</td><td><span class="pill ${inb ? 'in' : 'out'}"><span class="d"></span>${inb ? '入库' : '出库'}</span></td><td class="qty ${inb ? 'pos' : 'neg'} tnum">${inb ? '+' : '-'}${r.count}</td><td class="muted">${esc(refs.userName(r.userId))}</td><td class="muted tnum">${r.createtime || ''}</td></tr>`; }).join('') || '<tr><td colspan="6" class="muted">暂无记录</td></tr>';
  }
  refsUserNameInit();
  function refsUserNameInit() { refs.userName = id => id == null ? '-' : (id === USER.id ? USER.name : ('#' + id)); }
  function kpiTile(ic, lbl, val, unit, icon, route) {
    const inner = `<div class="top"><div class="ic ${ic}"><svg viewBox="0 0 24 24" fill="none"><path d="${icon}" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg></div><div class="lbl">${lbl}</div></div><div class="val tnum">${val}<small>${unit}</small></div>`;
    return route ? `<a class="kpi kpi-link" href="#/${route}">${inner}<span class="kpi-go">查看 ›</span></a>` : `<div class="kpi">${inner}</div>`;
  }
  /* 库存容量图：各仓库已用/总容量水平条 */
  function drawCapacity(host, list) {
    if (!host) return;
    if (!list.length) { host.innerHTML = '<div class="muted" style="padding:36px 0;text-align:center">暂无仓库容量数据</div>'; return; }
    host.innerHTML = list.map(w => {
      const cap = Number(w.capacity) || 0, used = Math.round(Number(w.used) || 0), pct = cap > 0 ? Math.min(100, Math.round(used * 100 / cap)) : 0;
      const full = pct >= 90;
      return `<a class="cap-row" href="#/t/location">
        <div class="cap-name">${esc(w.name)}</div>
        <div class="cap-bar"><div class="cap-fill ${full ? 'full' : ''}" style="width:${pct}%"></div></div>
        <div class="cap-num tnum">${fmt(used)}/${fmt(cap)}<span class="muted"> · ${pct}%</span></div>
      </a>`;
    }).join('');
  }

  const css = n => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
  function smooth(pts) { if (pts.length === 0) return 'M0 0'; if (pts.length === 1) return 'M' + pts[0][0] + ' ' + pts[0][1]; let d = 'M' + pts[0][0] + ' ' + pts[0][1];
    for (let i = 0; i < pts.length - 1; i++) { const p0 = pts[i - 1] || pts[i], p1 = pts[i], p2 = pts[i + 1], p3 = pts[i + 2] || p2;
      d += ` C${(p1[0] + (p2[0] - p0[0]) / 6).toFixed(1)} ${(p1[1] + (p2[1] - p0[1]) / 6).toFixed(1)} ${(p2[0] - (p3[0] - p1[0]) / 6).toFixed(1)} ${(p2[1] - (p3[1] - p1[1]) / 6).toFixed(1)} ${p2[0].toFixed(1)} ${p2[1].toFixed(1)}`; } return d; }
  function drawTrend(d) {
    const host = $('#trend'); if (!host) return; const labels = d.labels || [], inb = (d.inbound || []).map(Number), out = (d.outbound || []).map(Number);
    if (!labels.length) { host.innerHTML = '<div class="muted" style="padding:40px 0;text-align:center">暂无出入库数据</div>'; return; }
    const W = host.clientWidth || 640, H = 250, pl = 44, pr = 14, pt = 14, pb = 26, iw = W - pl - pr, ih = H - pt - pb;
    const mx = Math.max(...inb.concat(out, [10])) * 1.1 || 10;
    const n = labels.length, X = i => pl + (n === 1 ? iw / 2 : i / (n - 1) * iw), Y = v => pt + ih - v / mx * ih;
    const inP = inb.map((v, i) => [X(i), Y(v)]), outP = out.map((v, i) => [X(i), Y(v)]);
    const cIn = css('--s-in'), cOut = css('--s-out'); let grid = '', axis = '';
    for (let g = 0; g <= 4; g++) { const y = pt + ih - g / 4 * ih, val = Math.round(mx * g / 4); grid += `<line x1="${pl}" y1="${y.toFixed(1)}" x2="${W - pr}" y2="${y.toFixed(1)}"/>`; axis += `<text x="${pl - 8}" y="${y + 4}" text-anchor="end">${val >= 1000 ? (val / 1000).toFixed(1) + 'k' : val}</text>`; }
    const xa = labels.map((m, i) => `<text x="${X(i)}" y="${H - 8}" text-anchor="middle">${m}</text>`).join('');
    const areaIn = smooth(inP) + ` L${X(n - 1)} ${pt + ih} L${pl} ${pt + ih} Z`;
    host.innerHTML = `<svg viewBox="0 0 ${W} ${H}" width="100%" height="${H}" style="display:block"><defs>
      <linearGradient id="gin" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${cIn}" stop-opacity=".28"/><stop offset="1" stop-color="${cIn}" stop-opacity="0"/></linearGradient></defs>
      <g class="grid">${grid}</g><path d="${areaIn}" fill="url(#gin)"/>
      <path d="${smooth(outP)}" fill="none" stroke="${cOut}" stroke-width="2.2"/><path d="${smooth(inP)}" fill="none" stroke="${cIn}" stroke-width="2.6"/>
      <g class="axis">${axis}${xa}</g>
      ${inP.map((p, i) => `<circle cx="${p[0]}" cy="${p[1]}" r="3.4" fill="${cIn}" stroke="var(--surface)" stroke-width="2" data-t="${labels[i]}" data-i="${inb[i]}" data-o="${out[i]}" class="pt"/>`).join('')}</svg>`;
    host.querySelectorAll('.pt').forEach(c => { c.addEventListener('mousemove', e => showTip(`<b>${c.dataset.t}</b><div class="r"><span>入库</span><span class="v">${(+c.dataset.i).toLocaleString()}</span></div><div class="r"><span>出库</span><span class="v">${(+c.dataset.o).toLocaleString()}</span></div>`, e.clientX, e.clientY)); c.addEventListener('mouseleave', hideTip); });
  }
  const DCOLORS = ['#2a78d6', '#008300', '#e87ba4', '#eda100', '#1baf7a', '#eb6834', '#8a99b5'];
  function drawDonut(cats) {
    cats = (cats || []).map((c, i) => ({ nm: c.name, v: Number(c.value), c: DCOLORS[i % DCOLORS.length] }));
    const tot = cats.reduce((a, b) => a + b.v, 0) || 1, R = 68, r = 44, cx = 80, cy = 80, gap = 0.03; let a = -Math.PI / 2, seg = '';
    cats.forEach(c => { const a2 = a + (c.v / tot) * Math.PI * 2, s = a + gap / 2, e = a2 - gap / 2;
      const x1 = cx + R * Math.cos(s), y1 = cy + R * Math.sin(s), x2 = cx + R * Math.cos(e), y2 = cy + R * Math.sin(e);
      const x3 = cx + r * Math.cos(e), y3 = cy + r * Math.sin(e), x4 = cx + r * Math.cos(s), y4 = cy + r * Math.sin(s), big = (e - s) > Math.PI ? 1 : 0;
      seg += `<path d="M${x1} ${y1} A${R} ${R} 0 ${big} 1 ${x2} ${y2} L${x3} ${y3} A${r} ${r} 0 ${big} 0 ${x4} ${y4} Z" fill="${c.c}"/>`; a = a2; });
    $('#donut').innerHTML = `<svg viewBox="0 0 160 160" width="160" height="160">${seg}<text x="80" y="74" text-anchor="middle" style="fill:var(--muted)" font-size="11">总库存</text><text x="80" y="95" text-anchor="middle" style="fill:var(--ink)" font-size="22" font-weight="700">${fmt(tot)}</text></svg>`;
    $('#donutLegend').innerHTML = cats.map(c => `<div class="row"><span class="sw" style="background:${c.c}"></span><span class="nm">${esc(c.nm)}</span><span class="vv tnum">${fmt(c.v)}</span><span class="pc tnum">${(c.v / tot * 100).toFixed(0)}%</span></div>`).join('');
  }

  /* ================= 预警看板（补货 + 清理） ================= */
  async function renderAlerts(view) {
    $('#pageTitle').textContent = '预警看板';
    $('#pageSub').textContent = '需补货进货与需清理临期商品的实时汇总';
    const res = await get('/api/notices'); const list = res.data || [];
    const restock = list.filter(n => n.type === 'restock'), cleanup = list.filter(n => n.type === 'cleanup');
    view.innerHTML = `
      <section class="card">
        <div class="card-h"><div><h3>补货预警</h3><div class="desc">库存低于安全下限，需及时进货（${restock.length}）</div></div></div>
        ${restock.length === 0 ? '<div class="muted" style="padding:22px 0;text-align:center">✓ 库存充足</div>' :
          `<div class="notice-list">${restock.map(n => `<div class="notice-row warn" data-g="${n.goodsId}"><div class="nr-dot restock"></div><div>${esc(n.text)}</div><span class="nr-go">查看 ›</span></div>`).join('')}</div>`}
      </section>
      <section class="card">
        <div class="card-h"><div><h3>清理预警</h3><div class="desc">临近或超过保质期的货位批次，需清理（${cleanup.length}）</div></div></div>
        ${cleanup.length === 0 ? '<div class="muted" style="padding:22px 0;text-align:center">✓ 暂无临期商品</div>' :
          `<div class="notice-list">${cleanup.map(n => `<div class="notice-row ${n.level}" data-g="${n.goodsId}"><div class="nr-dot cleanup"></div><div>${esc(n.text)}</div><span class="nr-go">查看 ›</span></div>`).join('')}</div>`}
      </section>`;
    view.querySelectorAll('[data-g]').forEach(el => el.onclick = () => location.hash = '#/goods/' + el.dataset.g);
  }

  /* ================= 出入库操作（入库/出库分开，必须关联订单） ================= */
  async function renderInout(view, dir) {
    dir = dir || 'in';
    $('#pageTitle').textContent = '出入库操作';
    $('#pageSub').textContent = '入库关联采购订单、出库关联销售订单；选择订单后自动带出商品与数量；已完成订单不再显示';
    const [ordRes, locRes] = await Promise.all([get('/api/orders'), get('/api/location')]);
    const locations = locRes.data || [];
    const allOrders = ordRes.data || [];
    // 待处理订单：入库=未完成采购单，出库=未完成销售单
    const orders = allOrders.filter(o => (dir === 'in' ? o.type === 0 : o.type === 1) && o.status !== 1 && o.status !== 2);
    const locName = {}; locations.forEach(l => locName[l.id] = l.code);
    const ordNo = {}; allOrders.forEach(o => ordNo[o.id] = o.orderNo);
    const isIn = dir === 'in';
    const orderOpt = orders.map(o => `<option value="${o.id}">${esc(o.orderNo)}（${esc(isIn ? (refs.supplier[o.supplierId] || '供应商') : (o.buyer || '买家'))}）</option>`).join('');
    view.innerHTML = `
      <div class="io-tabs"><button data-d="in" class="${isIn ? 'on' : ''}">入库（采购）</button><button data-d="out" class="${isIn ? '' : 'on'}">出库（销售）</button></div>
      <section class="grid-2">
        <div class="card"><div class="card-h"><h3>${isIn ? '采购入库登记' : '销售出库登记'}</h3></div>
          <div style="display:flex;flex-direction:column;gap:13px;margin-top:12px">
            <div class="field"><label>关联${isIn ? '采购' : '销售'}订单（必选）</label>
              <select id="ioOrder"><option value="">${orders.length ? '— 请选择订单 —' : '（暂无待' + (isIn ? '入库' : '出库') + '订单）'}</option>${orderOpt}</select>
              <div id="ioOrderItems"></div></div>
            <div class="field"><label>商品</label><div class="io-goods-row"><select id="ioGoods" disabled></select><a class="btn btn-sm" id="ioGoodsView">查看详情</a></div></div>
            <div class="field"><label>数量</label><input id="ioCount" type="number" min="1" value="1"></div>
            ${isIn ? `<div class="field"><label>落位库位（分区须匹配）</label><select id="ioLoc"></select><div class="hint-sm" id="ioLocHint"></div></div>
            <div class="field"><label>收货凭证图片（可选）</label><input id="ioImg" type="file" accept="image/*"><div id="ioImgPrev"></div></div>` : ''}
            <div class="field"><label>备注</label><input id="ioRemark" placeholder="选填"></div>
            <button class="btn btn-primary" id="btnGo">${isIn ? '确认入库' : '确认出库'}</button>
          </div>
        </div>
        <div class="card"><div class="card-h"><h3>当前库存</h3></div>
          <div class="tablewrap" style="margin-top:10px"><table><thead><tr><th>货物</th><th>分区</th><th>仓库</th><th>保质期</th><th>库存</th></tr></thead><tbody id="ioStock"></tbody></table></div>
        </div>
      </section>
      <section class="card"><div class="card-h"><h3>最新流水</h3></div>
        <div class="tablewrap" style="margin-top:8px"><table><thead><tr><th>货物</th><th>类型</th><th>数量</th><th>落位</th><th>关联订单</th><th>时间</th></tr></thead><tbody id="ioRec"></tbody></table></div>
      </section>`;
    view.querySelectorAll('.io-tabs button').forEach(b => b.onclick = () => renderInout(view, b.dataset.d));
    const goodsOf = id => refs.goodsList.find(x => x.id === id) || {};
    const refreshLoc = () => {
      if (!isIn) return;
      const g = goodsOf(+$('#ioGoods').value); const zone = g.zone || '普通';
      const opts = locations.filter(l => l.storageId === g.storage && (l.zone || '').trim() === zone);
      $('#ioLoc').innerHTML = opts.length ? opts.map(l => `<option value="${l.id}">${esc(l.code)}（${esc(l.name || '')}）</option>`).join('') : '';
      $('#ioLocHint').textContent = opts.length ? `分区：${zone} · 共 ${opts.length} 个可选库位` : `⚠ ${refs.storage[g.storage] || ''} 的「${zone}」分区暂无库位，请先在货位管理添加`;
    };
    let imgData = '';
    if (isIn && $('#ioImg')) $('#ioImg').onchange = e => { const f = e.target.files[0]; if (!f) { imgData = ''; $('#ioImgPrev').innerHTML = ''; return; } readImageScaled(f, url => { imgData = url; $('#ioImgPrev').innerHTML = `<img src="${url}" style="margin-top:8px;max-height:88px;border-radius:8px;border:1px solid var(--border)">`; }); };
    const refreshStock = () => { $('#ioStock').innerHTML = refs.goodsList.map(g => `<tr><td>${esc(g.name)}</td><td>${zoneTag(g.zone)}</td><td class="muted">${esc(refs.storage[g.storage] || '-')}</td><td class="muted tnum">${g.shelfLifeDays ? g.shelfLifeDays + '天' : '—'}</td><td class="qty tnum">${g.count == null ? 0 : g.count}</td></tr>`).join(''); };
    const refreshRec = async () => { const rec = await get('/api/record'); const rows = (rec.data || []).sort((a, b) => b.id - a.id).slice(0, 10);
      $('#ioRec').innerHTML = rows.map(r => { const g = goodsOf(r.goods); const inb = r.type === 0;
        return `<tr><td>${esc(g.name || '#' + r.goods)}</td><td><span class="pill ${inb ? 'in' : 'out'}"><span class="d"></span>${inb ? '入库' : '出库'}</span></td><td class="qty ${inb ? 'pos' : 'neg'} tnum">${inb ? '+' : '-'}${r.count}</td><td class="muted">${r.locationId ? esc(locName[r.locationId] || '') : '-'}</td><td class="muted">${r.orderId ? esc(ordNo[r.orderId] || '#' + r.orderId) : '-'}</td><td class="muted tnum">${r.createtime || ''}</td></tr>`; }).join(''); };
    // 选订单 → 明细芯片 → 自动填写；点「查看详情」看商品信息
    const fillFromOrder = () => {
      const box = $('#ioOrderItems'), o = orders.find(x => x.id === +($('#ioOrder').value || 0));
      const gsel = $('#ioGoods');
      if (!o || !(o.items || []).length) { box.innerHTML = ''; gsel.innerHTML = '<option value="">—</option>'; return; }
      box.innerHTML = `<div class="hint-sm" style="margin-top:6px">点击商品自动填写数量：</div>
        <div class="oi-chips">${o.items.map((it, i) => `<button type="button" class="btn btn-sm oi-chip" data-i="${i}">${esc((goodsOf(it.goodsId).name) || ('#' + it.goodsId))} ×${it.count}</button>`).join('')}</div>`;
      gsel.innerHTML = o.items.map(it => `<option value="${it.goodsId}">${esc(goodsOf(it.goodsId).name || ('#' + it.goodsId))}</option>`).join('');
      const apply = (it) => {
        gsel.value = String(it.goodsId); refreshLoc();
        $('#ioCount').value = it.count;
        $('#ioRemark').value = (isIn ? '采购入库' : '销售出库') + '（单号' + o.orderNo + '）';
        box.querySelectorAll('.oi-chip').forEach(b => b.classList.toggle('on', o.items[+b.dataset.i] === it));
      };
      box.querySelectorAll('.oi-chip').forEach(b => b.onclick = () => apply(o.items[+b.dataset.i]));
      apply(o.items[0]);
    };
    $('#ioOrder').onchange = fillFromOrder;
    $('#ioGoods').onchange = refreshLoc;
    $('#ioGoodsView').onclick = () => { const id = +$('#ioGoods').value; if (id) location.hash = '#/goods/' + id; else showToast('请先选择订单与商品', true); };
    refreshStock(); await refreshRec();
    $('#btnGo').onclick = async () => {
      const orderId = $('#ioOrder').value ? +$('#ioOrder').value : null;
      const goodsId = +$('#ioGoods').value, count = +$('#ioCount').value, remark = $('#ioRemark').value;
      if (!orderId) return showToast(`请先选择${isIn ? '采购' : '销售'}订单`, true);
      if (!goodsId) return showToast('请选择商品', true);
      if (!count || count <= 0) return showToast('请输入正数数量', true);
      const body = { goodsId, count, remark, orderId };
      if (isIn) { body.locationId = $('#ioLoc') && $('#ioLoc').value ? +$('#ioLoc').value : null; if (imgData) body.image = imgData; }
      const res = await post('/api/inout/' + dir, body);
      if (res.code === 200) { showToast((isIn ? '入库' : '出库') + '成功'); await loadRefs(); refreshBell(); renderInout(view, dir); }
      else showToast(res.msg || '操作失败', true);
    };
  }

  /* ================= 订单 ================= */
  async function renderOrders(view, type) {
    return type === 1 ? renderSalesOrders(view) : renderPurchaseOrders(view);
  }

  async function renderPurchaseOrders(view) {
    $('#pageTitle').textContent = '采购订单';
    $('#pageSub').textContent = '面向供应商的采购入库订单，关联供应商与入库流水';
    const res = await get('/api/orders?type=0'); let rows = res.data || [];
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索订单号…">
        <button class="btn btn-primary btn-sm" id="add">＋ 新建采购订单</button><span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="tablewrap"><table><thead><tr><th>订单号</th><th>供应商</th><th>商品项</th><th>总量</th><th>金额</th><th>状态</th><th>下单时间</th><th>操作</th></tr></thead><tbody id="tb"></tbody></table></div></section>`;
    const render = list => {
      $('#cnt').textContent = `共 ${list.length} 单`;
      $('#tb').innerHTML = list.map(o => `<tr>
        <td><a class="lk" href="#/order/${o.id}"><b>${esc(o.orderNo)}</b></a></td><td>${esc(refs.supplier[o.supplierId] || '-')}</td>
        <td class="tnum">${o.itemCount} 项</td><td class="qty tnum">${o.totalQty}</td><td class="tnum">${money(o.totalAmount)}</td>
        <td>${statusPill(o.status)}</td><td class="muted tnum">${dt(o.orderTime)}</td>
        <td><div class="rowbtns"><a class="btn btn-sm" href="#/order/${o.id}">详情</a><button class="btn btn-sm" data-edit="${o.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${o.id}">删除</button></div></td></tr>`).join('') || '<tr><td colspan="8" class="muted">暂无订单</td></tr>';
      $('#tb').querySelectorAll('[data-edit]').forEach(b => b.onclick = () => renderOrderForm(view, 0, rows.find(r => r.id == b.dataset.edit)));
      $('#tb').querySelectorAll('[data-del]').forEach(b => b.onclick = async () => { if (!await confirmDialog('确认删除该采购订单？')) return; const r = await del('/api/orders/' + b.dataset.del); if (r.code === 200) { showToast('已删除'); route(); } else showToast(r.msg || '删除失败', true); });
    };
    render(rows);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? rows : rows.filter(o => (o.orderNo || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => renderOrderForm(view, 0, null);
  }

  async function renderSalesOrders(view) {
    $('#pageTitle').textContent = '销售订单';
    $('#pageSub').textContent = '门店零售订单：买家、经手账号、商品明细、时间；不可删除，只能取消';
    const res = await get('/api/orders?type=1'); let rows = res.data || [];
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索订单号 / 买家…">
        <button class="btn btn-primary btn-sm" id="add">＋ 新建销售订单</button><span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="order-feed" id="feed"></div></section>`;
    const render = list => {
      $('#cnt').textContent = `共 ${list.length} 单`;
      $('#feed').innerHTML = list.map(o => {
        const items = o.items || [];
        return `<div class="oc ${o.status === 2 ? 'canceled' : ''}">
          <div class="oc-top"><div class="oc-no">${esc(o.orderNo)}</div>${statusPill(o.status)}<div class="oc-time">${dt(o.orderTime)}</div></div>
          <div class="oc-meta"><span>买家：<b>${esc(o.buyer || refs.customerNameFallback(o) || '散客')}</b></span><span>经手账号：<b>${esc(o.operatorName || '-')}</b></span><span>金额：<b>${money(o.totalAmount)}</b></span></div>
          <div class="oc-items">${items.map(it => { const g = refs.goodsList.find(x => x.id === it.goodsId) || {}; return `<div class="oc-item"><span>${esc(g.name || ('#' + it.goodsId))}</span><span class="tnum">×${it.count}</span><span class="muted tnum">${money(it.price)}</span></div>`; }).join('') || '<div class="muted">无明细</div>'}</div>
          ${o.status === 2 ? `<div class="oc-cancel">已取消：${esc(o.cancelReason || '')} · ${dt(o.cancelTime)}</div>`
            : `<div class="oc-actions"><button class="btn btn-sm" data-edit="${o.id}">编辑</button><button class="btn btn-sm btn-danger" data-cancel="${o.id}">取消订单</button></div>`}
        </div>`; }).join('') || '<div class="muted" style="padding:20px">暂无销售订单</div>';
      $('#feed').querySelectorAll('[data-edit]').forEach(b => b.onclick = () => renderOrderForm(view, 1, rows.find(r => r.id == b.dataset.edit)));
      $('#feed').querySelectorAll('[data-cancel]').forEach(b => b.onclick = () => cancelOrder(b.dataset.cancel));
    };
    render(rows);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? rows : rows.filter(o => (o.orderNo || '').toLowerCase().includes(q) || (o.buyer || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => renderOrderForm(view, 1, null);
  }
  refs.customerNameFallback = () => null;

  async function cancelOrder(id) {
    const reason = await promptDialog('取消订单', '请填写取消原因', '例如：买家临时退单 / 商品缺货');
    if (reason == null) return;
    if (!reason.trim()) return showToast('取消原因不能为空', true);
    const r = await post(`/api/orders/${id}/cancel`, { reason: reason.trim() });
    if (r.code === 200) { showToast('订单已取消'); route(); } else showToast(r.msg || '取消失败', true);
  }

  async function renderOrderDetail(view, id) {
    const res = await get('/api/orders/' + id);
    if (res.code !== 200) { view.innerHTML = `<div class="card">${res.msg || '订单不存在'}</div>`; return; }
    const o = res.data, items = o.items || [], isSale = o.type === 1;
    $('#pageTitle').textContent = (isSale ? '销售订单' : '采购订单') + ' · ' + o.orderNo;
    $('#pageSub').textContent = '';
    view.innerHTML = `${crumbs([[isSale ? '销售订单' : '采购订单', 'orders/' + o.type], ['订单详情', null]])}
      <section class="card">
        <div class="detail-meta">
          <div><span>${isSale ? '买家' : '供应商'}</span><b>${esc(isSale ? (o.buyer || '散客') : (refs.supplier[o.supplierId] || '-'))}</b></div>
          <div><span>状态</span>${statusPill(o.status)}</div>
          <div><span>金额</span><b>${money(o.totalAmount)}</b></div>
          <div><span>下单时间</span><b>${dt(o.orderTime)}</b></div>
          ${isSale ? `<div><span>经手账号</span><b>${esc(o.operatorName || '-')}</b></div>` : ''}
          ${o.status === 2 ? `<div><span>取消原因</span><b class="txt-crit">${esc(o.cancelReason || '')}</b></div>` : ''}
        </div>
        <div class="tablewrap" style="margin-top:14px"><table><thead><tr><th>商品</th><th>分区</th><th>数量</th><th>单价</th><th>小计</th></tr></thead>
          <tbody>${items.map(it => { const g = refs.goodsList.find(x => x.id === it.goodsId) || {}; return `<tr><td><a class="lk" href="#/goods/${it.goodsId}">${esc(g.name || ('#' + it.goodsId))}</a></td><td>${zoneTag(g.zone)}</td><td class="qty tnum">${it.count}</td><td class="tnum">${money(it.price)}</td><td class="tnum">${money((it.price || 0) * (it.count || 0))}</td></tr>`; }).join('') || '<tr><td colspan="5" class="muted">无明细</td></tr>'}</tbody></table></div>
        ${o.remark ? `<div class="muted" style="margin-top:12px">备注：${esc(o.remark)}</div>` : ''}
      </section>`;
  }

  async function renderOrderForm(view, type, order) {
    const isSale = type === 1, editing = !!order;
    let full = order;
    if (editing) { const r = await get('/api/orders/' + order.id); if (r.code === 200) full = r.data; }
    const items = (full && full.items) ? full.items.slice() : [];
    const backHash = 'orders/' + type;
    $('#pageTitle').textContent = (editing ? '编辑' : '新建') + (isSale ? '销售订单' : '采购订单');
    $('#pageSub').textContent = '';
    const goodsOpt = cur => refs.goodsList.map(g => `<option value="${g.id}" ${g.id == cur ? 'selected' : ''}>${esc(g.name)}</option>`).join('');
    view.innerHTML = `${crumbs([[isSale ? '销售订单' : '采购订单', backHash], [editing ? '编辑' : '新建', null]])}
      <section class="card" style="max-width:720px">
        <div class="form-grid">
          ${isSale
            ? `<div class="field"><label>买家</label><input id="oBuyer" value="${esc(full ? (full.buyer || '') : '')}" placeholder="散客 / 客户名"></div>`
            : `<div class="field"><label>供应商</label><select id="oParty">${refs.supplierList.map(p => `<option value="${p.id}" ${full && p.id == full.supplierId ? 'selected' : ''}>${esc(p.name)}</option>`).join('')}</select></div>`}
          <div class="field"><label>状态</label><select id="oStatus">${ORDER_STATUS.map((s, i) => `<option value="${i}" ${full && full.status == i ? 'selected' : ''} ${i === 2 ? 'disabled' : ''}>${s}</option>`).join('')}</select></div>
          <div class="field full"><label>备注</label><input id="oRemark" value="${esc(full ? (full.remark || '') : '')}" placeholder="选填"></div>
        </div>
        <div class="card-h" style="margin-top:16px"><h3 style="font-size:14px">订单明细</h3><div class="right"><button class="btn btn-sm" id="addItem">＋ 添加商品</button></div></div>
        <div class="tablewrap"><table><thead><tr><th>商品</th><th>数量</th><th>单价</th><th></th></tr></thead><tbody id="itemRows"></tbody></table></div>
        <div class="modal-actions"><a class="btn" href="#/${backHash}">取消</a><button class="btn btn-primary" id="ms">保存</button></div>
      </section>`;
    const tb = $('#itemRows');
    const addRow = it => { const tr = document.createElement('tr');
      tr.innerHTML = `<td><select class="i-goods">${goodsOpt(it ? it.goodsId : '')}</select></td>
        <td style="width:96px"><input class="i-count" type="number" min="1" value="${it ? it.count : 1}"></td>
        <td style="width:120px"><input class="i-price" type="number" min="0" step="0.01" value="${it ? (it.price || 0) : 0}"></td>
        <td style="width:44px"><button class="btn btn-sm btn-danger i-del">×</button></td>`;
      tb.appendChild(tr); tr.querySelector('.i-del').onclick = () => tr.remove(); };
    if (items.length) items.forEach(addRow); else addRow(null);
    $('#addItem').onclick = () => addRow(null);
    $('#ms').onclick = async () => {
      const lineItems = [...tb.querySelectorAll('tr')].map(tr => ({ goodsId: +tr.querySelector('.i-goods').value, count: +tr.querySelector('.i-count').value, price: +tr.querySelector('.i-price').value })).filter(x => x.goodsId && x.count > 0);
      if (!lineItems.length) return showToast('请至少添加一条商品明细', true);
      const payload = { type, status: +$('#oStatus').value, remark: $('#oRemark').value, items: lineItems };
      if (isSale) { payload.buyer = $('#oBuyer').value.trim() || '散客'; } else { payload.supplierId = $('#oParty').value ? +$('#oParty').value : null; }
      const r = editing ? await put('/api/orders/' + full.id, payload) : await post('/api/orders', payload);
      if (r.code === 200) { showToast('保存成功'); goTo(backHash); } else showToast(r.msg || '保存失败', true);
    };
  }

  /* ================= 商品档案 ================= */
  const GOODS_FIELDS = [
    { k: 'name', label: '商品名称', type: 'text' },
    { k: 'goodsType', label: '分类', type: 'ref', list: () => refs.typeList },
    { k: 'storage', label: '仓库', type: 'ref', list: () => refs.storageList },
    { k: 'zone', label: '存储分区', type: 'select', options: ZONES },
    { k: 'shelfLifeDays', label: '保质期(天，留空=不易过期)', type: 'number' },
    { k: 'cleanupWarnDays', label: '到期前预警清理(天)', type: 'number' },
    { k: 'piecesPerCap', label: '多少件占1个库位容量', type: 'number' },
    { k: 'image', label: '商品图片', type: 'image', full: true },
    { k: 'remark', label: '备注', type: 'textarea', full: true }
  ];
  async function renderGoods(view) {
    $('#pageTitle').textContent = '商品档案';
    $('#pageSub').textContent = '商品图片 + 实时库存（偏低标红），点击查看详情与出入库/库存历史';
    const al = await get('/api/stock_alert'); const minMap = {}; (al.data || []).forEach(a => { if (a.enabled) minMap[a.goodsId] = a.minCount; });
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索商品…"><button class="btn btn-primary btn-sm" id="add">＋ 新增商品</button><span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="pgrid" id="grid"></div></section>`;
    const render = list => {
      $('#cnt').textContent = `共 ${list.length} 项`;
      $('#grid').innerHTML = list.map(g => productCard(g, minMap[g.id], true)).join('') || '<div class="muted">暂无商品</div>';
      $('#grid').querySelectorAll('[data-detail]').forEach(b => b.onclick = ev => { ev.stopPropagation(); location.hash = '#/goods/' + b.dataset.detail; });
      $('#grid').querySelectorAll('[data-edit]').forEach(b => b.onclick = ev => { ev.stopPropagation(); renderGoodsForm(view, refs.goodsList.find(x => x.id == b.dataset.edit)); });
      $('#grid').querySelectorAll('[data-del]').forEach(b => b.onclick = ev => { ev.stopPropagation(); doDelete('goods', b.dataset.del); });
      $('#grid').querySelectorAll('.pcard').forEach(c => c.onclick = () => location.hash = '#/goods/' + c.dataset.id);
    };
    render(refs.goodsList);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? refs.goodsList : refs.goodsList.filter(g => (g.name || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => renderGoodsForm(view, null);
  }
  function renderGoodsForm(view, row) {
    const editing = !!row;
    // 编辑时不可改库存（count 由出入库管理），表单不含库存字段
    renderForm(view, {
      title: (editing ? '编辑' : '新增') + '商品', backHash: 't/goods', crumbs: [['商品档案', 't/goods'], [editing ? '编辑' : '新增', null]],
      fields: GOODS_FIELDS, model: row || { zone: '普通', cleanupWarnDays: 7 },
      note: editing ? '库存由「出入库操作」管理，此处不可修改' : '新增后库存为 0，请通过「出入库操作」入库',
      onSubmit: async obj => {
        if (editing) { obj = { ...row, ...obj }; return put('/api/goods/' + row.id, obj); }
        return post('/api/goods', obj);
      }
    });
  }
  async function renderGoodsDetail(view, id) {
    const [d, rec] = await Promise.all([get('/api/profile/goods/' + id), get('/api/record')]);
    if (d.code !== 200) { view.innerHTML = `<div class="card">${d.msg || '商品不存在'}</div>`; return; }
    const g = d.data, min = g.minCount || 0, low = min > 0 && (g.count == null ? 0 : g.count) < min;
    $('#pageTitle').textContent = '商品详情 · ' + g.name; $('#pageSub').textContent = '';
    const recs = (rec.data || []).filter(r => r.goods === id).sort((a, b) => b.id - a.id).slice(0, 12);
    view.innerHTML = `${crumbs([['商品档案', 't/goods'], [g.name, null]])}
      <section class="card">
        <div class="pd-head">
          <div class="pd-img">${imgTag(g.image)}</div>
          <div class="pd-info">
            <div class="pd-row"><span>分类</span><b>${esc(refs.goodstype[g.goodsType] || '-')}</b></div>
            <div class="pd-row"><span>分区</span>${zoneTag(g.zone)}</div>
            <div class="pd-row"><span>仓库</span><b>${esc(refs.storage[g.storage] || '-')}</b></div>
            <div class="pd-row"><span>当前库存</span><b class="${low ? 'txt-crit' : ''}">${g.count == null ? 0 : g.count}${low ? ' ⚠ 偏低' : ''}</b></div>
            <div class="pd-row"><span>安全下限</span><b>${min || '—'}</b></div>
            <div class="pd-row"><span>保质期</span><b>${g.shelfLifeDays ? g.shelfLifeDays + ' 天' : '不易过期'}</b></div>
            <div class="pd-row"><span>清理预警</span><b>${g.cleanupWarnDays ? '到期前 ' + g.cleanupWarnDays + ' 天' : '—'}</b></div>
            <div class="pd-row"><span>供应商</span><b>${(g.suppliers && g.suppliers.length) ? g.suppliers.map(esc).join('、') : '—'}</b></div>
          </div>
        </div>
        <div class="card-h" style="margin-top:18px"><div><h3 style="font-size:14px">出入库 / 库存历史</h3></div><div class="right"><div class="seg" id="pSeg">${PERIODS.map(([k, l]) => `<button data-p="${k}" class="${k === 'month' ? 'on' : ''}">${l}</button>`).join('')}</div></div></div>
        <div class="legend" style="margin:6px 0 2px"><div class="it"><span class="sw" style="background:#2a78d6"></span>入库</div><div class="it"><span class="sw" style="background:#e0603a"></span>出库</div><div class="it"><span class="sw" style="background:#1f8043"></span>库存</div></div>
        <div id="pChart"></div>
        <div class="card-h" style="margin-top:12px"><h3 style="font-size:14px">近期出入库记录</h3></div>
        <div class="tablewrap"><table><thead><tr><th>类型</th><th>数量</th><th>操作人</th><th>时间</th><th>备注</th></tr></thead>
          <tbody>${recs.map(r => { const inb = r.type === 0; return `<tr><td><span class="pill ${inb ? 'in' : 'out'}"><span class="d"></span>${inb ? '入库' : '出库'}</span></td><td class="qty ${inb ? 'pos' : 'neg'} tnum">${inb ? '+' : '-'}${r.count}</td><td class="muted">${esc(refs.userName(r.userId))}</td><td class="muted tnum">${r.createtime || ''}</td><td class="muted">${esc(r.remark || '')}</td></tr>`; }).join('') || '<tr><td colspan="5" class="muted">暂无记录</td></tr>'}</tbody></table></div>
      </section>`;
    const loadChart = async period => { const h = await get(`/api/profile/goods/${id}/history?period=${period}`); const hd = h.data || {};
      drawLineChart($('#pChart'), hd.labels || [], [{ name: '入库', color: '#2a78d6', data: hd.inbound || [] }, { name: '出库', color: '#e0603a', data: hd.outbound || [] }, { name: '库存', color: '#1f8043', data: hd.stock || [] }]); };
    $('#pSeg').querySelectorAll('button').forEach(b => b.onclick = () => { $('#pSeg').querySelectorAll('button').forEach(x => x.classList.remove('on')); b.classList.add('on'); loadChart(b.dataset.p); });
    await loadChart('month');
  }

  function drawLineChart(host, labels, series) {
    if (!labels.length) { host.innerHTML = '<div class="muted" style="padding:40px 0;text-align:center">暂无历史数据</div>'; return; }
    const W = host.clientWidth || 620, H = 240, pl = 46, pr = 14, pt = 14, pb = 26, iw = W - pl - pr, ih = H - pt - pb;
    const mx = Math.max(...series.flatMap(s => s.data.map(Number)).concat([10])) * 1.12 || 10;
    const n = labels.length, X = i => pl + (n === 1 ? iw / 2 : i / (n - 1) * iw), Y = v => pt + ih - v / mx * ih;
    let grid = '', axis = '';
    for (let gg = 0; gg <= 4; gg++) { const y = pt + ih - gg / 4 * ih, val = Math.round(mx * gg / 4); grid += `<line x1="${pl}" y1="${y.toFixed(1)}" x2="${W - pr}" y2="${y.toFixed(1)}"/>`; axis += `<text x="${pl - 8}" y="${y + 4}" text-anchor="end">${val >= 1000 ? (val / 1000).toFixed(1) + 'k' : val}</text>`; }
    const xa = labels.map((m, i) => `<text x="${X(i)}" y="${H - 8}" text-anchor="middle">${esc(m)}</text>`).join('');
    const paths = series.map(s => `<path d="${smooth(s.data.map((v, i) => [X(i), Y(Number(v))]))}" fill="none" stroke="${s.color}" stroke-width="2.4"/>`).join('');
    let dots = ''; for (let i = 0; i < n; i++) series.forEach(s => { dots += `<circle cx="${X(i)}" cy="${Y(Number(s.data[i]))}" r="3.2" fill="${s.color}" stroke="var(--surface)" stroke-width="1.6" class="pt" data-i="${i}"/>`; });
    host.innerHTML = `<svg viewBox="0 0 ${W} ${H}" width="100%" height="${H}" style="display:block"><g class="grid">${grid}</g>${paths}<g class="axis">${axis}${xa}</g>${dots}</svg>`;
    const tipFor = i => `<b>${esc(labels[i])}</b>` + series.map(s => `<div class="r"><span>${s.name}</span><span class="v">${(+s.data[i]).toLocaleString()}</span></div>`).join('');
    host.querySelectorAll('.pt').forEach(c => { c.addEventListener('mousemove', e => showTip(tipFor(+c.dataset.i), e.clientX, e.clientY)); c.addEventListener('mouseleave', hideTip); });
  }

  /* ================= 供应商 ================= */
  const SUPPLIER_FIELDS = [
    { k: 'name', label: '供应商名称', type: 'text' }, { k: 'contact', label: '联系人', type: 'text' },
    { k: 'phone', label: '电话', type: 'text' }, { k: 'email', label: '邮箱', type: 'text' },
    { k: 'address', label: '地址', type: 'text', full: true }, { k: 'image', label: '供应商图片', type: 'image', full: true },
    { k: 'remark', label: '备注', type: 'textarea', full: true }
  ];
  async function renderSuppliers(view) {
    $('#pageTitle').textContent = '供应商'; $('#pageSub').textContent = '供应商图片与所供商品，点击查看详情，可下钻到商品档案';
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索供应商…"><button class="btn btn-primary btn-sm" id="add">＋ 新增供应商</button><span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="pgrid" id="grid"></div></section>`;
    const render = list => {
      $('#cnt').textContent = `共 ${list.length} 家`;
      $('#grid').innerHTML = list.map(s => `<div class="pcard scard" data-id="${s.id}"><div class="pcard-img">${imgTag(s.image)}</div>
        <div class="pcard-body"><div class="pcard-name" title="${esc(s.name)}">${esc(s.name)}</div><div class="pcard-sub muted">${esc(s.contact || '')} ${esc(s.phone || '')}</div>
        <div class="pcard-foot"><button class="btn btn-sm" data-detail="${s.id}">详情</button><button class="btn btn-sm" data-edit="${s.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${s.id}">删除</button></div></div></div>`).join('') || '<div class="muted">暂无供应商</div>';
      $('#grid').querySelectorAll('[data-detail]').forEach(b => b.onclick = ev => { ev.stopPropagation(); location.hash = '#/supplier/' + b.dataset.detail; });
      $('#grid').querySelectorAll('[data-edit]').forEach(b => b.onclick = ev => { ev.stopPropagation(); renderSupplierForm(view, refs.supplierList.find(x => x.id == b.dataset.edit)); });
      $('#grid').querySelectorAll('[data-del]').forEach(b => b.onclick = ev => { ev.stopPropagation(); doDelete('supplier', b.dataset.del); });
      $('#grid').querySelectorAll('.scard').forEach(c => c.onclick = () => location.hash = '#/supplier/' + c.dataset.id);
    };
    render(refs.supplierList);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? refs.supplierList : refs.supplierList.filter(s => (s.name || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => renderSupplierForm(view, null);
  }
  function renderSupplierForm(view, row) {
    const editing = !!row;
    renderForm(view, { title: (editing ? '编辑' : '新增') + '供应商', backHash: 't/supplier', crumbs: [['供应商', 't/supplier'], [editing ? '编辑' : '新增', null]], fields: SUPPLIER_FIELDS, model: row || {},
      onSubmit: async obj => editing ? put('/api/supplier/' + row.id, { ...row, ...obj }) : post('/api/supplier', obj) });
  }
  async function renderSupplierDetail(view, id) {
    const s = refs.supplierList.find(x => x.id === id) || {};
    const res = await get('/api/profile/supplier/' + id + '/goods'); const goods = res.data || [];
    $('#pageTitle').textContent = '供应商详情 · ' + (s.name || ''); $('#pageSub').textContent = '';
    view.innerHTML = `${crumbs([['供应商', 't/supplier'], [s.name || '', null]])}
      <section class="card">
        <div class="pd-head"><div class="pd-img">${imgTag(s.image)}</div>
          <div class="pd-info">
            <div class="pd-row"><span>联系人</span><b>${esc(s.contact || '-')}</b></div>
            <div class="pd-row"><span>电话</span><b>${esc(s.phone || '-')}</b></div>
            <div class="pd-row"><span>邮箱</span><b>${esc(s.email || '-')}</b></div>
            <div class="pd-row"><span>地址</span><b>${esc(s.address || '-')}</b></div>
          </div></div>
        <div class="card-h" style="margin-top:18px"><h3 style="font-size:14px">所供商品（${goods.length}）</h3></div>
        <div class="pgrid">${goods.map(g => productCard(g, g.minCount, false)).join('') || '<div class="muted">暂无关联商品</div>'}</div>
      </section>`;
    view.querySelectorAll('.pcard').forEach(c => c.onclick = () => location.hash = '#/goods/' + c.dataset.id);
  }

  /* ================= 货位管理（看板：内容 + 剩余容量） ================= */
  async function renderLocationBoard(view) {
    $('#pageTitle').textContent = '货位管理'; $('#pageSub').textContent = '每个库位的容量、已存商品与数量、剩余容量；按分区管理';
    const res = await get('/api/location/board');
    if (res.code !== 200 || !Array.isArray(res.data)) {
      view.innerHTML = `<section class="card"><h3 style="margin:0 0 10px">货位数据加载失败</h3>
        <div class="muted" style="line-height:1.8">${esc(res.msg || res.message || res.error || '服务器错误')}<br>
        若后台日志出现 <b>Unknown column</b>（如 ls.expiry_date），说明数据库结构是旧版本，请执行升级脚本（不会丢数据）：<br>
        <code>mysql -uroot -p ahut_base &lt; db/repair_schema.sql</code>　然后重启后端刷新本页。</div></section>`;
      return;
    }
    const rows = res.data || [];
    const zones = {}; rows.forEach(l => { const z = (l.zone || '未分区').trim(); (zones[z] = zones[z] || []).push(l); });
    const order = z => { const i = ZONES.indexOf(z); return i < 0 ? 99 : i; };
    view.innerHTML = `<section class="card">
      <div class="toolbar"><span class="muted">共 ${rows.length} 个库位</span><button class="btn btn-primary btn-sm" id="add" style="margin-left:auto">＋ 新增库位</button></div>
      ${Object.keys(zones).sort((a, b) => order(a) - order(b)).map(z => `
        <div class="loc-zone"><div class="loc-zt">${zoneTag(z)} <span class="muted">${zones[z].length} 个库位</span></div>
        <div class="loc-grid">${zones[z].map(l => {
          const usage = l.usage || 0, full = usage >= 95;
          return `<div class="loc-card" data-id="${l.id}">
            <div class="loc-top"><b>${esc(l.code)}</b><span class="muted">${esc(l.storageName || '')}</span></div>
            <div class="loc-bar"><div class="loc-fill ${full ? 'full' : ''}" style="width:${Math.min(100, usage)}%"></div></div>
            <div class="loc-cap"><span>已用 ${l.used}/${l.capacity}</span><span class="muted">剩余 ${l.remain}</span></div>
            <div class="loc-items">${(l.items || []).length ? l.items.map(it => `<div class="loc-it"><span>${esc(it.name)}</span><span class="tnum">×${it.qty}</span></div>`).join('') : '<div class="muted" style="font-size:12px">空置</div>'}</div>
            <div class="loc-act"><button class="btn btn-sm" data-edit="${l.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${l.id}">删除</button></div>
          </div>`; }).join('')}</div></div>`).join('') || '<div class="muted">暂无库位</div>'}
    </section>`;
    view.querySelectorAll('[data-edit]').forEach(b => b.onclick = async () => { const r = await get('/api/location/' + b.dataset.edit); renderLocationForm(view, r.data); });
    view.querySelectorAll('[data-del]').forEach(b => b.onclick = () => doDelete('location', b.dataset.del));
    $('#add').onclick = () => renderLocationForm(view, null);
  }
  const LOCATION_FIELDS = [
    { k: 'code', label: '库位编码', type: 'text' }, { k: 'name', label: '库位名称', type: 'text' },
    { k: 'storageId', label: '所属仓库', type: 'ref', list: () => refs.storageList },
    { k: 'zone', label: '分区', type: 'select', options: ZONES },
    { k: 'rowNo', label: '排', type: 'number' }, { k: 'colNo', label: '列', type: 'number' },
    { k: 'capacity', label: '容量', type: 'number' }
  ];
  function renderLocationForm(view, row) {
    const editing = !!row;
    renderForm(view, { title: (editing ? '编辑' : '新增') + '库位', backHash: 't/location', crumbs: [['货位管理', 't/location'], [editing ? '编辑' : '新增', null]], fields: LOCATION_FIELDS, model: row || { zone: '普通', capacity: 500 },
      onSubmit: async obj => editing ? put('/api/location/' + row.id, { ...row, ...obj }) : post('/api/location', obj) });
  }

  /* ================= 个人资料 ================= */
  async function renderProfile(view) {
    $('#pageTitle').textContent = '个人资料'; $('#pageSub').textContent = '查看个人信息与修改登录密码';
    const me = await get('/api/auth/me'); const u = me.data || USER;
    view.innerHTML = `
      <section class="grid-2">
        <div class="card"><div class="card-h"><h3>个人信息</h3></div>
          <div class="prof">
            <div class="prof-av">${esc((u.name || 'U').charAt(0))}</div>
            <div class="pd-info" style="flex:1">
              <div class="pd-row"><span>姓名</span><b>${esc(u.name || '-')}</b></div>
              <div class="pd-row"><span>ID</span><b>${esc(String(u.id ?? '-'))}</b></div>
              <div class="pd-row"><span>登录账号</span><b>${esc(u.number || '-')}</b></div>
              <div class="pd-row"><span>电话</span><b>${esc(u.phone || '-')}</b></div>
            </div>
          </div>
        </div>
        <div class="card"><div class="card-h"><h3>修改密码</h3></div>
          <div style="display:flex;flex-direction:column;gap:13px;margin-top:12px;max-width:340px">
            <div class="field"><label>原密码</label><input id="oldPwd" type="password" placeholder="请输入原密码"></div>
            <div class="field"><label>新密码</label><input id="newPwd" type="password" placeholder="至少 6 位"></div>
            <div class="field"><label>确认新密码</label><input id="newPwd2" type="password" placeholder="再次输入新密码"></div>
            <button class="btn btn-primary" id="chg" style="align-self:flex-start">保存新密码</button>
          </div>
        </div>
      </section>`;
    $('#chg').onclick = async () => {
      const o = $('#oldPwd').value, n = $('#newPwd').value, n2 = $('#newPwd2').value;
      if (!o || !n) return showToast('请填写完整', true);
      if (n.length < 6) return showToast('新密码至少 6 位', true);
      if (n !== n2) return showToast('两次新密码不一致', true);
      const r = await post('/api/auth/changePassword', { oldPassword: o, newPassword: n });
      if (r.code === 200) { showToast('密码已修改，请重新登录'); setTimeout(async () => { await post('/api/auth/logout', {}); localStorage.clear(); location.href = 'login.html'; }, 1200); }
      else showToast(r.msg || '修改失败', true);
    };
  }

  /* ================= 通用表格（记录/分类/预警阈值/日志） ================= */
  const TABLES = {
    record: { label: '出入库记录', cols: ['id', 'goods', 'userId', 'count', 'type', 'createtime', 'remark'], readonly: true },
    goodstype: { label: '商品分类', cols: ['id', 'name', 'storageId', 'remark'], fields: [{ k: 'name', label: '分类名', type: 'text' }, { k: 'storageId', label: '所属仓库', type: 'ref', list: () => refs.storageList }, { k: 'remark', label: '备注', type: 'textarea', full: true }] },
    stock_alert: { label: '预警阈值', cols: ['id', 'goodsId', 'minCount', 'maxCount', 'enabled', 'remark'],
      fields: [{ k: 'goodsId', label: '商品', type: 'ref', list: () => refs.goodsList }, { k: 'minCount', label: '安全下限', type: 'number' }, { k: 'maxCount', label: '库存上限', type: 'number' }, { k: 'enabled', label: '状态', type: 'select', options: [['1', '启用'], ['0', '停用']] }, { k: 'remark', label: '备注', type: 'textarea', full: true }] },
    sys_log: { label: '操作日志', cols: ['id', 'content', 'userId', 'ipAddr', 'methods', 'result', 'duration', 'createTime'], readonly: true }
  };
  async function renderTable(view, t) {
    const cfg = TABLES[t] || { label: t };
    $('#pageTitle').textContent = cfg.label; $('#pageSub').textContent = '';
    const res = await get('/api/' + t); let rows = (res.data || []);
    if (t === 'sys_log') rows = rows.sort((a, b) => b.id - a.id).slice(0, 200);
    const cols = cfg.cols || (rows[0] ? Object.keys(rows[0]) : ['id']);
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索…">${cfg.readonly ? '' : '<button class="btn btn-primary btn-sm" id="add">＋ 新增</button>'}<span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="tablewrap"><table><thead><tr>${cols.map(c => `<th>${lab(c)}</th>`).join('')}${cfg.readonly ? '' : '<th>操作</th>'}</tr></thead><tbody id="tb"></tbody></table></div></section>`;
    const render = list => {
      $('#cnt').textContent = `共 ${list.length} 条`;
      $('#tb').innerHTML = list.map(row => `<tr>${cols.map(c => `<td>${cell(t, c, row[c])}</td>`).join('')}${cfg.readonly ? '' : `<td><div class="rowbtns"><button class="btn btn-sm" data-edit="${row.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${row.id}">删除</button></div></td>`}</tr>`).join('') || `<tr><td colspan="${cols.length + 1}" class="muted">暂无数据</td></tr>`;
      $('#tb').querySelectorAll('[data-edit]').forEach(b => b.onclick = () => renderForm(view, { title: '编辑' + cfg.label, backHash: 't/' + t, crumbs: [[cfg.label, 't/' + t], ['编辑', null]], fields: cfg.fields, model: rows.find(r => r.id == b.dataset.edit), onSubmit: obj => put(`/api/${t}/${b.dataset.edit}`, { ...rows.find(r => r.id == b.dataset.edit), ...obj }) }));
      $('#tb').querySelectorAll('[data-del]').forEach(b => b.onclick = () => doDelete(t, b.dataset.del));
    };
    render(rows);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? rows : rows.filter(r => cols.some(c => String(cellText(t, c, r[c]) ?? '').toLowerCase().includes(q)))); };
    if ($('#add')) $('#add').onclick = () => renderForm(view, { title: '新增' + cfg.label, backHash: 't/' + t, crumbs: [[cfg.label, 't/' + t], ['新增', null]], fields: cfg.fields, model: {}, onSubmit: obj => post('/api/' + t, obj) });
  }
  function cellText(t, c, v) {
    if (v == null) return '';
    if (t === 'record' && c === 'goods') return refs.goods[v] || ('#' + v);
    if (t === 'sys_log' && c === 'userId') return v;            // 日志里存的是登录账号
    if (c === 'userId') return refs.userName(v);
    if (c === 'goodsId') return refs.goods[v] || v;
    if (c === 'storageId') return refs.storage[v] || v;
    if (c === 'type' && t === 'record') return v === 0 ? '入库' : '出库';
    if (c === 'enabled') return v ? '启用' : '停用';
    return v;
  }
  function cell(t, c, v) {
    if (c === 'type' && t === 'record') return `<span class="pill ${v === 0 ? 'in' : 'out'}"><span class="d"></span>${v === 0 ? '入库' : '出库'}</span>`;
    if (c === 'enabled') return v ? '<span class="pill" style="color:var(--good-ink);background:var(--good-wash)"><span class="d"></span>启用</span>' : '<span class="pill" style="color:var(--muted);background:var(--surface-2)"><span class="d"></span>停用</span>';
    let s = String(cellText(t, c, v) ?? ''); if (s.length > 48) s = s.slice(0, 48) + '…'; return esc(s);
  }

  /* ================= 通用「就地」表单（无弹窗，面包屑返回） ================= */
  function renderForm(view, opts) {
    const model = opts.model || {};
    const val = k => model[k] == null ? '' : model[k];
    const inputHtml = f => {
      const v = val(f.k);
      if (f.type === 'ref') return `<select data-f="${f.k}">${(f.list() || []).map(x => `<option value="${x.id}" ${x.id == v ? 'selected' : ''}>${esc(x.name)}</option>`).join('')}</select>`;
      if (f.type === 'select') return `<select data-f="${f.k}">${f.options.map(o => { const [ov, ol] = Array.isArray(o) ? o : [o, o]; return `<option value="${ov}" ${String(v) === String(ov) ? 'selected' : ''}>${ol}</option>`; }).join('')}</select>`;
      if (f.type === 'textarea') return `<textarea data-f="${f.k}" rows="2">${esc(v)}</textarea>`;
      if (f.type === 'image') return `<div class="imgfield"><input type="hidden" data-f="${f.k}" value="${esc(v)}"><input type="file" class="img-file" accept="image/*"><div class="img-prev">${v ? `<img src="${esc(v)}">` : '<span class="muted">未设置图片，可选择本地图片上传</span>'}</div></div>`;
      return `<input data-f="${f.k}" ${f.type === 'number' ? 'type="number"' : ''} value="${esc(v)}">`;
    };
    $('#pageTitle').textContent = opts.title; $('#pageSub').textContent = '';
    view.innerHTML = `${crumbs(opts.crumbs || [[opts.title, null]])}
      <section class="card" style="max-width:640px">
        ${opts.note ? `<div class="form-note">${esc(opts.note)}</div>` : ''}
        <div class="form-grid">${opts.fields.map(f => `<div class="field ${f.full ? 'full' : ''}"><label>${f.label}</label>${inputHtml(f)}</div>`).join('')}</div>
        <div class="modal-actions"><a class="btn" href="#/${opts.backHash}">取消</a><button class="btn btn-primary" id="save">保存</button></div>
      </section>`;
    view.querySelectorAll('.img-file').forEach(fi => { const wrap = fi.closest('.imgfield'), hidden = wrap.querySelector('[data-f]'), prev = wrap.querySelector('.img-prev');
      fi.onchange = e => { const f = e.target.files[0]; if (!f) return; readImageScaled(f, url => { hidden.value = url; prev.innerHTML = `<img src="${url}">`; }); }; });
    $('#save').onclick = async () => {
      const obj = {};
      view.querySelectorAll('[data-f]').forEach(el => { let v = el.value; if (el.type === 'number') v = v === '' ? null : Number(v); obj[el.dataset.f] = v; });
      const r = await opts.onSubmit(obj);
      if (r && r.code === 200) { showToast('保存成功'); await loadRefs(); goTo(opts.backHash); }
      else showToast((r && r.msg) || '保存失败', true);
    };
  }

  async function doDelete(t, id) {
    if (!await confirmDialog('确认删除该记录？')) return;
    const r = await del(`/api/${t}/${id}`);
    if (r.code === 200) { showToast('已删除'); await loadRefs(); route(); } else showToast(r.msg || '删除失败', true);
  }

  /* ---------- 小对话框（确认 / 输入原因） ---------- */
  function confirmDialog(msg) {
    return new Promise(res => {
      const bg = document.createElement('div'); bg.className = 'modal-bg';
      bg.innerHTML = `<div class="modal" style="width:min(380px,92vw)"><h3>请确认</h3><div style="margin:6px 0 4px">${esc(msg)}</div><div class="modal-actions"><button class="btn" id="c">取消</button><button class="btn btn-danger" id="k">确定</button></div></div>`;
      document.body.appendChild(bg);
      const done = v => { bg.remove(); res(v); };
      bg.querySelector('#c').onclick = () => done(false); bg.querySelector('#k').onclick = () => done(true);
      bg.onclick = e => { if (e.target === bg) done(false); };
    });
  }
  function promptDialog(title, label, ph) {
    return new Promise(res => {
      const bg = document.createElement('div'); bg.className = 'modal-bg';
      bg.innerHTML = `<div class="modal" style="width:min(440px,92vw)"><h3>${esc(title)}</h3><div class="field" style="margin-top:6px"><label>${esc(label)}</label><textarea id="rz" rows="3" placeholder="${esc(ph || '')}"></textarea></div><div class="modal-actions"><button class="btn" id="c">返回</button><button class="btn btn-primary" id="k">确定</button></div></div>`;
      document.body.appendChild(bg);
      const done = v => { bg.remove(); res(v); };
      bg.querySelector('#c').onclick = () => done(null); bg.querySelector('#k').onclick = () => done(bg.querySelector('#rz').value);
      bg.onclick = e => { if (e.target === bg) done(null); };
      bg.querySelector('#rz').focus();
    });
  }

  /* ---------- 图片：卡片 / 占位 / 压缩上传 ---------- */
  function imgTag(src, cls) {
    if (src) { const fb = /^\/img\/.+\.(jpe?g|png|webp)$/i.test(src) ? src.replace(/\.(jpe?g|png|webp)$/i, '.svg') : '';
      return `<img class="${cls || ''}" src="${esc(src)}"${fb ? ` onerror="this.onerror=null;this.src='${fb}'"` : ''} alt="">`; }
    return `<div class="img-ph ${cls || ''}"><svg viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.5"/><circle cx="8.5" cy="9" r="1.6" fill="currentColor"/><path d="M4 17l5-4 4 3 3-2 4 3" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg></div>`;
  }
  function productCard(g, min, manage) {
    const low = min > 0 && (g.count == null ? 0 : g.count) < min;
    return `<div class="pcard" data-id="${g.id}"><div class="pcard-img">${imgTag(g.image)}</div>
      <div class="pcard-body"><div class="pcard-name" title="${esc(g.name)}">${esc(g.name)}</div>
        <div class="pcard-meta">${zoneTag(g.zone)}<span class="stock-badge ${low ? 'low' : ''}">库存 ${g.count == null ? 0 : g.count}</span></div>
        ${manage ? `<div class="pcard-foot"><button class="btn btn-sm" data-detail="${g.id}">详情</button><button class="btn btn-sm" data-edit="${g.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${g.id}">删除</button></div>` : ''}</div></div>`;
  }
  function readImageScaled(file, cb, maxDim, quality) {
    maxDim = maxDim || 900; quality = quality || 0.85;
    if (!file.type || !file.type.startsWith('image/')) { showToast('请选择图片文件', true); return; }
    const rd = new FileReader();
    rd.onload = () => { const img = new Image();
      img.onload = () => { let w = img.width, h = img.height; const scale = Math.min(1, maxDim / Math.max(w, h)); w = Math.round(w * scale); h = Math.round(h * scale);
        try { const cv = document.createElement('canvas'); cv.width = w; cv.height = h; const ctx = cv.getContext('2d'); ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, w, h); ctx.drawImage(img, 0, 0, w, h); cb(cv.toDataURL('image/jpeg', quality)); } catch (e) { cb(rd.result); } };
      img.onerror = () => cb(rd.result); img.src = rd.result; };
    rd.readAsDataURL(file);
  }

  /* ---------- 启动 ---------- */
  (async function init() {
    buildNav();
    await loadRefs();
    window.addEventListener('hashchange', route);
    document.addEventListener('keydown', e => { if (e.key === 'Escape') { const m = document.querySelectorAll('.modal-bg'); if (m.length) m[m.length - 1].remove(); } });
    if (!location.hash) location.hash = '#/dashboard';
    route();
    let rt; addEventListener('resize', () => { clearTimeout(rt); rt = setTimeout(() => { const h = location.hash.slice(2) || 'dashboard'; if (h === 'dashboard' || h.startsWith('goods/')) route(); }, 200); });
  })();
})();
