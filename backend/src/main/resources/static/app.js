/* ================= 库智 WMS 前端应用 ================= */
(function () {
  const $ = (s, r = document) => r.querySelector(s);
  const tip = $('#tip'), toast = $('#toast');
  const TOKEN = localStorage.getItem('wms_token');
  if (!TOKEN) { location.href = 'login.html'; return; }
  const USER = JSON.parse(localStorage.getItem('wms_user') || '{}');

  /* ---------- API ---------- */
  async function api(path, opts = {}) {
    const r = await fetch(path, {
      ...opts,
      headers: { 'Content-Type': 'application/json', token: TOKEN, ...(opts.headers || {}) }
    });
    if (r.status === 401) { localStorage.clear(); location.href = 'login.html'; throw new Error('401'); }
    const j = await r.json().catch(() => ({ code: 500, msg: '响应解析失败' }));
    return j;
  }
  const get = p => api(p);
  const del = p => api(p, { method: 'DELETE' });
  const post = (p, b) => api(p, { method: 'POST', body: JSON.stringify(b) });
  const put = (p, b) => api(p, { method: 'PUT', body: JSON.stringify(b) });

  function showToast(msg, err) { toast.textContent = msg; toast.className = 'toast show' + (err ? ' err' : ''); setTimeout(() => toast.className = 'toast', 2200); }
  function showTip(html, x, y) { tip.innerHTML = html; tip.classList.add('show'); const w = tip.offsetWidth, h = tip.offsetHeight; tip.style.left = Math.min(x + 14, innerWidth - w - 8) + 'px'; tip.style.top = Math.max(8, y - h - 12) + 'px'; }
  const hideTip = () => tip.classList.remove('show');

  /* ---------- 配置：导航 + 表 ---------- */
  const TABLES = {
    record:          { label: '出入库记录', cols: ['id', 'goods', 'user_id', 'count', 'type', 'createtime', 'remark'], readonly: true },
    goods:           { label: '商品档案', hide: ['image'] },
    goodstype:       { label: '商品分类' },
    storage:         { label: '仓库管理' },
    location:        { label: '货位管理' },
    supplier:        { label: '供应商管理' },
    customer:        { label: '客户管理' },
    goods_batch:     { label: '批次/保质期' },
    stock_alert:     { label: '库存预警' },
    sys_user:        { label: '用户管理', hide: ['password', 'salt'] },
    sys_role:        { label: '角色管理' },
    sys_notice:      { label: '系统公告' },
    sys_log:         { label: '操作日志', cols: ['id', 'content', 'ip_addr', 'user_id', 'create_time', 'duration'], readonly: true }
  };
  const NAV = [
    { group: '概览', items: [
      ['dashboard', '运营总览', 'M3 12 12 4l9 8M5 10v10h14V10'],
      ['alerts', '预警看板', 'M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Zm3 10a3 3 0 0 0 6 0'] ] },
    { group: '进销存', items: [
      ['inout', '出入库操作', 'M3 7l9-4 9 4-9 4-9-4Zm0 5 9 4 9-4M3 17l9 4 9-4'],
      ['t/record', '出入库记录', 'M4 5h16v14H4zM4 9h16'],
      ['t/goods', '商品档案', 'M20 7 12 3 4 7v10l8 4 8-4V7Z'],
      ['t/goodstype', '商品分类', 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z'] ] },
    { group: '订单链路', items: [
      ['orders/0', '采购订单', 'M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4ZM3 6h18M16 10a4 4 0 0 1-8 0'],
      ['orders/1', '销售订单', 'M9 2h6l1 4H8ZM4 6h16l-1 14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2ZM9 11v6m6-6v6'] ] },
    { group: '仓储', items: [
      ['t/storage', '仓库管理', 'M4 21V8l8-5 8 5v13'],
      ['t/location', '货位管理', 'M12 21s7-6 7-11a7 7 0 1 0-14 0c0 5 7 11 7 11Z'],
      ['t/stock_alert', '预警阈值', 'M12 3 2 20h20L12 3Zm0 7v4m0 3h.01'] ] },
    { group: '供应链', items: [
      ['t/supplier', '供应商', 'M3 7h18v13H3zM3 7l3-4h12l3 4'],
      ['t/customer', '客户', 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM4 21a8 8 0 0 1 16 0'],
      ['t/goods_batch', '批次/保质期', 'M12 8v5l3 2M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z'] ] },
    { group: '系统', items: [
      ['t/sys_user', '用户管理', 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM4 21a8 8 0 0 1 16 0'],
      ['t/sys_role', '角色管理', 'M12 2 4 5v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V5l-8-3Z'],
      ['t/sys_notice', '系统公告', 'M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0'],
      ['t/sys_log', '操作日志', 'M4 4h16v16H4zM8 9h8M8 13h5'] ] }
  ];
  const LABELS = { id:'ID', name:'名称', remark:'备注', count:'数量', storage:'仓库', goodsType:'分类', goods:'货品', zone:'分区', image:'图片',
    user_id:'操作人', createtime:'时间', create_time:'创建时间', update_time:'更新时间', create_by:'创建人', update_by:'更新人',
    del_flag:'删除', type:'类型', contact:'联系人', phone:'电话', email:'邮箱', address:'地址', supplier_id:'供应商', customer_id:'客户',
    batch_no:'批次号', production_date:'生产日期', expiry_date:'到期日', min_count:'最低库存', max_count:'最高库存',
    enabled:'启用', goods_id:'货品', code:'库位编码', row_no:'排', col_no:'列', capacity:'容量',
    order_no:'订单号', order_time:'下单时间', total_amount:'金额', price:'单价', order_id:'订单',
    status:'状态', storage_id:'仓库', title:'标题', content:'内容', number:'账号',
    age:'年龄', sex:'性别', locked:'锁定', loginsign:'登录标识', parent_id:'上级', icon:'图标', url:'地址',
    sort:'排序', description:'说明', component:'组件', role_id:'角色', res_id:'资源', res_type:'资源类型',
    ip_addr:'IP地址', data:'参数', methods:'方法', result:'结果', duration:'耗时(ms)', is_hidden_menu:'隐藏', is_option_menu:'下拉' };
  const ZONES = ['冷冻', '冰鲜', '普通'];
  const lab = k => LABELS[k] || k;

  /* 关联字典（列表展示 id -> 名称） */
  const refs = {};
  async function loadRefs() {
    const [st, gt, gs, us, sp, cu] = await Promise.all([
      get('/api/storage'), get('/api/goodstype'), get('/api/goods'), get('/api/sys_user'),
      get('/api/supplier'), get('/api/customer')]);
    refs.storage = map(st.data, 'id', 'name'); refs.goodstype = map(gt.data, 'id', 'name');
    refs.goods = map(gs.data, 'id', 'name'); refs.user = map(us.data, 'id', 'name');
    refs.supplier = map(sp.data, 'id', 'name'); refs.customer = map(cu.data, 'id', 'name');
    refs.goodsList = gs.data || []; refs.storageList = st.data || []; refs.typeList = gt.data || [];
    refs.supplierList = sp.data || []; refs.customerList = cu.data || [];
  }
  const map = (arr, k, v) => (arr || []).reduce((o, x) => (o[x[k]] = x[v], o), {});

  /* ---------- 导航渲染 ---------- */
  function buildNav() {
    $('#nav').innerHTML = NAV.map(g =>
      `<div class="nav-group">${g.group}</div>` +
      g.items.map(([route, label, icon]) =>
        `<a href="#/${route}" data-route="${route}"><svg viewBox="0 0 24 24" fill="none"><path d="${icon}" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>${label}</a>`
      ).join('')).join('');
    $('#uname').textContent = USER.name || '用户';
    $('#unum').textContent = (USER.number || '') + ' · 在线';
    $('#avatar').textContent = (USER.name || 'U').charAt(0);
    $('#today').textContent = new Date().toLocaleDateString('zh-CN');
    $('#logout').onclick = async () => { await post('/api/auth/logout', {}); localStorage.clear(); location.href = 'login.html'; };
  }
  function setActive(route) {
    document.querySelectorAll('#nav a').forEach(a => a.classList.toggle('active', a.dataset.route === route));
  }

  /* ---------- 路由 ---------- */
  async function route() {
    const hash = location.hash.slice(2) || 'dashboard';
    const view = $('#view');
    try {
      if (hash === 'dashboard') { setActive('dashboard'); await renderDashboard(view); }
      else if (hash === 'alerts') { setActive('alerts'); await renderAlerts(view); }
      else if (hash === 'inout') { setActive('inout'); await renderInout(view); }
      else if (hash.startsWith('orders/')) { const ty = +hash.slice(7); setActive('orders/' + ty); await renderOrders(view, ty); }
      else if (hash === 't/goods') { setActive(hash); await renderGoods(view); }
      else if (hash === 't/supplier') { setActive(hash); await renderSuppliers(view); }
      else if (hash === 't/customer') { setActive(hash); await renderCustomers(view); }
      else if (hash.startsWith('t/')) { const t = hash.slice(2); setActive(hash); await renderTable(view, t); }
      else { view.innerHTML = '<div class="card">页面不存在</div>'; }
    } catch (e) { if (e.message !== '401') view.innerHTML = `<div class="card">加载失败：${e.message}</div>`; }
  }

  /* ================= 预警看板（低库存商品公告） ================= */
  async function renderAlerts(view) {
    $('#pageTitle').textContent = '预警看板';
    $('#pageSub').textContent = '库存低于安全下限的商品，请及时补货';
    const res = await get('/api/stats/lowstock');
    const list = res.data || [];
    view.innerHTML = `
      <section class="card">
        <div class="card-h"><div><h3>库存预警公告</h3><div class="desc">共 ${list.length} 项商品需要补货</div></div></div>
        ${list.length === 0 ? '<div class="muted" style="padding:30px 0;text-align:center">✓ 暂无预警，库存充足</div>' : `
        <div class="tablewrap" style="margin-top:8px"><table>
          <thead><tr><th>商品</th><th>仓库</th><th>当前库存</th><th>安全下限</th><th>缺口</th><th>状态</th></tr></thead>
          <tbody>${list.map(r => `<tr>
            <td>${r.name}</td>
            <td class="muted">${r.storageName || '-'}</td>
            <td class="qty neg tnum">${r.count}</td>
            <td class="tnum">${r.minCount}</td>
            <td class="qty neg tnum">-${Math.max(0, r.minCount - r.count)}</td>
            <td><span class="pill" style="color:var(--crit);background:var(--crit-wash)"><span class="d"></span>需补货</span></td>
          </tr>`).join('')}</tbody>
        </table></div>`}
      </section>`;
  }

  /* ================= 仪表盘 ================= */
  async function renderDashboard(view) {
    $('#pageTitle').textContent = '运营总览';
    $('#pageSub').textContent = `下午好，${USER.name || ''} · 实时库存与出入库概览`;
    const [kpi, cat, trend, hmStores] = await Promise.all([
      get('/api/stats/kpi'), get('/api/stats/category'), get('/api/stats/trend'), get('/api/heatmap/storages')
    ]);
    const k = kpi.data;
    view.innerHTML = `
      <section class="kpis">
        ${kpiTile('blue','总库存量',fmt(k.totalStock),'件','M3 7l9-4 9 4-9 4-9-4Zm0 5 9 4 9-4M3 17l9 4 9-4')}
        ${kpiTile('green','今日入库',fmt(k.todayIn),'件','M12 20V6m0 0-6 6m6-6 6 6')}
        ${kpiTile('amber','今日出库',fmt(k.todayOut),'件','M12 4v14m0 0 6-6m-6 6-6-6')}
        ${kpiTile('red','库存预警',k.alertCount,'项','M12 3 2 20h20L12 3Zm0 7v4m0 3h.01')}
        ${kpiTile('slate','仓位使用率',k.usage,'%','M4 21V8l8-5 8 5v13M9 21v-6h6v6')}
      </section>
      <section class="grid-2">
        <div class="card">
          <div class="card-h"><div><h3>出入库趋势</h3><div class="desc">按月统计入库 / 出库总量（件）</div></div></div>
          <div class="legend" style="margin:10px 0 2px"><div class="it"><span class="sw" style="background:var(--s-in)"></span>入库</div><div class="it"><span class="sw" style="background:var(--s-out)"></span>出库</div></div>
          <div id="trend"></div>
        </div>
        <div class="card">
          <div class="card-h"><div><h3>库存分类占比</h3><div class="desc">总库存 ${fmt(k.totalStock)} 件</div></div></div>
          <div class="donut-wrap" style="margin-top:8px"><div id="donut"></div><div class="donut-legend" id="donutLegend"></div></div>
        </div>
      </section>
      <section class="card">
        <div class="hm-head">
          <div><div class="card-h"><h3>仓库库位热力图</h3></div><div class="desc" style="margin-top:2px">按 冷冻 / 冰鲜 / 普通 分区展示 · 绿色越深库存越满；<b style="color:var(--crit)">红色代表库存偏低，越少越红需及时补货</b></div></div>
          <div class="hm-legend"><select id="hmStore" style="width:auto"></select><div class="hm-scale"><span>空</span><div class="hm-bar"></div><span>满</span></div><div class="hm-flag"><div class="box"></div>库存偏低</div></div>
        </div>
        <div class="zones" id="zones"></div>
      </section>
      <section class="card">
        <div class="card-h"><div><h3>近期出入库记录</h3></div><div class="right"><a class="btn btn-sm" href="#/inout">去操作</a></div></div>
        <div class="tablewrap" style="margin-top:6px"><table><thead><tr><th>货物</th><th>仓库</th><th>类型</th><th>数量</th><th>操作人</th><th>时间</th></tr></thead><tbody id="recRows"></tbody></table></div>
      </section>`;

    drawTrend(trend.data);
    drawDonut(cat.data);
    // heatmap store selector
    const sel = $('#hmStore');
    sel.innerHTML = hmStores.data.map(s => `<option value="${s.id}">${s.name}</option>`).join('');
    sel.onchange = () => loadHeatmap(sel.value);
    await loadHeatmap(hmStores.data[0] ? hmStores.data[0].id : 2);
    // records
    const rec = await get('/api/record');
    const rows = (rec.data || []).sort((a, b) => b.id - a.id).slice(0, 8);
    $('#recRows').innerHTML = rows.map(r => {
      const g = refs.goodsList.find(x => x.id === r.goods) || {};
      const inb = r.type === 0;
      return `<tr><td>${g.name || ('#' + r.goods)}</td><td class="muted">${refs.storage[g.storage] || '-'}</td>
        <td><span class="pill ${inb ? 'in' : 'out'}"><span class="d"></span>${inb ? '入库' : '出库'}</span></td>
        <td class="qty ${inb ? 'pos' : 'neg'} tnum">${inb ? '+' : '-'}${r.count}</td>
        <td class="muted">${refs.user[r.user_id] || '-'}</td><td class="muted tnum">${r.createtime || ''}</td></tr>`;
    }).join('') || '<tr><td colspan="6" class="muted">暂无记录</td></tr>';
  }

  function kpiTile(ic, lbl, val, unit, icon) {
    return `<div class="kpi"><div class="top"><div class="ic ${ic}"><svg viewBox="0 0 24 24" fill="none"><path d="${icon}" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg></div><div class="lbl">${lbl}</div></div>
      <div class="val tnum">${val}<small>${unit}</small></div></div>`;
  }
  const fmt = n => (n == null ? 0 : Number(n)).toLocaleString();

  /* ---- trend chart ---- */
  const css = n => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
  function smooth(pts) { if (pts.length === 0) return 'M0 0'; if (pts.length === 1) return 'M' + pts[0][0] + ' ' + pts[0][1]; let d = 'M' + pts[0][0] + ' ' + pts[0][1];
    for (let i = 0; i < pts.length - 1; i++) { const p0 = pts[i - 1] || pts[i], p1 = pts[i], p2 = pts[i + 1], p3 = pts[i + 2] || p2;
      d += ` C${(p1[0] + (p2[0] - p0[0]) / 6).toFixed(1)} ${(p1[1] + (p2[1] - p0[1]) / 6).toFixed(1)} ${(p2[0] - (p3[0] - p1[0]) / 6).toFixed(1)} ${(p2[1] - (p3[1] - p1[1]) / 6).toFixed(1)} ${p2[0].toFixed(1)} ${p2[1].toFixed(1)}`; } return d; }
  function drawTrend(d) {
    const host = $('#trend'); const labels = d.labels || [], inb = (d.inbound || []).map(Number), out = (d.outbound || []).map(Number);
    if (!labels.length) { host.innerHTML = '<div class="muted" style="padding:40px 0;text-align:center">暂无出入库数据</div>'; return; }
    const W = host.clientWidth || 640, H = 250, pl = 44, pr = 14, pt = 14, pb = 26, iw = W - pl - pr, ih = H - pt - pb;
    const all = inb.concat(out, [10]); const mx = Math.max(...all) * 1.1 || 10;
    const n = labels.length, X = i => pl + (n === 1 ? iw / 2 : i / (n - 1) * iw), Y = v => pt + ih - v / mx * ih;
    const inP = inb.map((v, i) => [X(i), Y(v)]), outP = out.map((v, i) => [X(i), Y(v)]);
    const cIn = css('--s-in'), cOut = css('--s-out'); let grid = '', axis = '';
    for (let g = 0; g <= 4; g++) { const y = pt + ih - g / 4 * ih, val = Math.round(mx * g / 4); grid += `<line x1="${pl}" y1="${y.toFixed(1)}" x2="${W - pr}" y2="${y.toFixed(1)}"/>`; axis += `<text x="${pl - 8}" y="${y + 4}" text-anchor="end">${val >= 1000 ? (val / 1000).toFixed(1) + 'k' : val}</text>`; }
    const xa = labels.map((m, i) => `<text x="${X(i)}" y="${H - 8}" text-anchor="middle">${m}</text>`).join('');
    const areaIn = smooth(inP) + ` L${X(n - 1)} ${pt + ih} L${pl} ${pt + ih} Z`, areaOut = smooth(outP) + ` L${X(n - 1)} ${pt + ih} L${pl} ${pt + ih} Z`;
    host.innerHTML = `<svg viewBox="0 0 ${W} ${H}" width="100%" height="${H}" style="display:block"><defs>
      <linearGradient id="gin" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${cIn}" stop-opacity=".28"/><stop offset="1" stop-color="${cIn}" stop-opacity="0"/></linearGradient>
      <linearGradient id="gout" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${cOut}" stop-opacity=".2"/><stop offset="1" stop-color="${cOut}" stop-opacity="0"/></linearGradient></defs>
      <g class="grid">${grid}</g><path d="${areaIn}" fill="url(#gin)"/><path d="${areaOut}" fill="url(#gout)"/>
      <path d="${smooth(outP)}" fill="none" stroke="${cOut}" stroke-width="2.2"/><path d="${smooth(inP)}" fill="none" stroke="${cIn}" stroke-width="2.6"/>
      <g class="axis">${axis}${xa}</g>
      ${inP.map((p, i) => `<circle cx="${p[0]}" cy="${p[1]}" r="3.4" fill="${cIn}" stroke="var(--surface)" stroke-width="2" data-t="${labels[i]}" data-i="${inb[i]}" data-o="${out[i]}" class="pt"/>`).join('')}
    </svg>`;
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
    $('#donutLegend').innerHTML = cats.map(c => `<div class="row"><span class="sw" style="background:${c.c}"></span><span class="nm">${c.nm}</span><span class="vv tnum">${fmt(c.v)}</span><span class="pc tnum">${(c.v / tot * 100).toFixed(0)}%</span></div>`).join('');
  }
  // 绿色占用梯度（越满越深）
  const ramp = ['#e8f5ec', '#cdeacf', '#a8dcae', '#7fca8b', '#54b56b', '#2f9d54', '#1f8043', '#136432'];
  const rampColor = p => p <= 0 ? ramp[0] : ramp[Math.min(ramp.length - 1, 1 + Math.floor(p / 100 * (ramp.length - 1)))];
  // 红色预警梯度（越少越红，severity 0~100）
  const redRamp = ['#fecdd3', '#fca5a5', '#f87171', '#ef4444', '#dc2626', '#b91c1c'];
  const redColor = s => redRamp[Math.min(redRamp.length - 1, Math.floor(s / 100 * redRamp.length))];
  const ZONE_ICON = { 冷冻: '❄', 冰鲜: '🐟', 普通: '📦' };
  async function loadHeatmap(storageId) {
    const res = await get('/api/heatmap?storageId=' + storageId);
    const bins = res.data.bins || [];
    const zones = {};
    bins.forEach(b => { (zones[b.zone] = zones[b.zone] || []).push(b); });
    const order = z => { const i = ZONES.indexOf(z); return i < 0 ? 99 : i; };
    $('#zones').innerHTML = Object.keys(zones).sort((a, b) => order(a) - order(b)).map(z => {
      const cells = zones[z].map(b => {
        const low = b.alert;
        const cls = low ? 'low' : (b.stock <= 0 ? 'empty' : (b.occupancy > 55 ? 'hi' : ''));
        const bg = low ? redColor(b.severity || 60) : rampColor(b.occupancy);
        return `<div class="bin ${cls}" style="background:${bg}" data-code="${b.code}" data-g="${b.goods}" data-o="${b.occupancy}" data-s="${b.stock}" data-a="${low ? (b.reason || '库存偏低') : ''}">${b.rowNo}</div>`;
      }).join('');
      return `<div class="zone"><div class="zt">${ZONE_ICON[z] || ''} ${z || '未分区'}<span>${zones[z].length} 库位</span></div><div class="bins">${cells}</div></div>`;
    }).join('');
    $('#zones').querySelectorAll('.bin').forEach(b => {
      b.addEventListener('mousemove', e => showTip(`<b>库位 ${b.dataset.code}</b><div class="r"><span>货物</span><span class="v">${b.dataset.g}</span></div><div class="r"><span>存量</span><span class="v">${b.dataset.s}</span></div><div class="r"><span>占用</span><span class="v">${b.dataset.o}%</span></div>${b.dataset.a ? `<div class="r" style="color:#ff9b9b">⚠ ${b.dataset.a}</div>` : ''}`, e.clientX, e.clientY));
      b.addEventListener('mouseleave', hideTip);
    });
  }

  /* ================= 出入库操作 ================= */
  async function renderInout(view) {
    $('#pageTitle').textContent = '出入库操作';
    $('#pageSub').textContent = '选择货物执行入库 / 出库，实时更新库存与库位';
    const ordRes = await get('/api/orders');
    const orders = ordRes.data || [];
    const orderOpt = orders.map(o => {
      const who = o.type === 1 ? (refs.customer[o.customerId] || '客户') : (refs.supplier[o.supplierId] || '供应商');
      return `<option value="${o.id}" data-type="${o.type}">${o.type === 1 ? '销' : '采'}｜${o.orderNo}（${who}）</option>`;
    }).join('');
    view.innerHTML = `
      <section class="grid-2">
        <div class="card">
          <div class="card-h"><h3>登记单据</h3></div>
          <div style="display:flex;flex-direction:column;gap:14px;margin-top:12px">
            <div class="field"><label>选择货物</label><select id="ioGoods"></select></div>
            <div class="field"><label>数量</label><input id="ioCount" type="number" min="1" value="10"></div>
            <div class="field"><label>关联订单（可选）</label><select id="ioOrder"><option value="">— 不关联订单 —</option>${orderOpt}</select></div>
            <div class="field"><label>收货凭证图片（入库可选）</label><input id="ioImg" type="file" accept="image/*"><div id="ioImgPrev"></div></div>
            <div class="field"><label>备注</label><input id="ioRemark" placeholder="选填"></div>
            <div style="display:flex;gap:12px;margin-top:4px">
              <button class="btn btn-primary" id="btnIn" style="flex:1">入库</button>
              <button class="btn" id="btnOut" style="flex:1">出库</button>
            </div>
          </div>
        </div>
        <div class="card">
          <div class="card-h"><h3>当前库存</h3></div>
          <div class="tablewrap" style="margin-top:10px"><table><thead><tr><th>货物</th><th>分区</th><th>仓库</th><th>库存</th></tr></thead><tbody id="ioStock"></tbody></table></div>
        </div>
      </section>
      <section class="card">
        <div class="card-h"><h3>最新流水</h3></div>
        <div class="tablewrap" style="margin-top:8px"><table><thead><tr><th>货物</th><th>类型</th><th>数量</th><th>关联订单</th><th>操作人</th><th>时间</th><th>备注</th></tr></thead><tbody id="ioRec"></tbody></table></div>
      </section>`;
    $('#ioGoods').innerHTML = refs.goodsList.map(g => `<option value="${g.id}">${g.name}（${zoneTag(g.zone)}·${refs.storage[g.storage] || ''}）</option>`).join('');
    const ordNo = {}; orders.forEach(o => ordNo[o.id] = o.orderNo);
    let imgData = '';
    $('#ioImg').onchange = e => { const f = e.target.files[0]; if (!f) { imgData = ''; $('#ioImgPrev').innerHTML = ''; return; }
      const rd = new FileReader(); rd.onload = () => { imgData = rd.result; $('#ioImgPrev').innerHTML = `<img src="${imgData}" style="margin-top:8px;max-height:88px;border-radius:8px;border:1px solid var(--border)">`; }; rd.readAsDataURL(f); };
    const refreshStock = () => { $('#ioStock').innerHTML = refs.goodsList.map(g => `<tr><td>${g.name}</td><td>${zoneTag(g.zone)}</td><td class="muted">${refs.storage[g.storage] || '-'}</td><td class="qty tnum">${g.count}</td></tr>`).join(''); };
    const refreshRec = async () => { const rec = await get('/api/record'); const rows = (rec.data || []).sort((a, b) => b.id - a.id).slice(0, 10);
      $('#ioRec').innerHTML = rows.map(r => { const g = refs.goodsList.find(x => x.id === r.goods) || {}; const inb = r.type === 0;
        return `<tr><td>${g.name || '#' + r.goods}</td><td><span class="pill ${inb ? 'in' : 'out'}"><span class="d"></span>${inb ? '入库' : '出库'}</span></td><td class="qty ${inb ? 'pos' : 'neg'} tnum">${inb ? '+' : '-'}${r.count}</td><td class="muted">${r.orderId ? (ordNo[r.orderId] || ('#' + r.orderId)) : '-'}</td><td class="muted">${refs.user[r.user_id] || '-'}</td><td class="muted tnum">${r.createtime || ''}</td><td class="muted">${r.remark || ''}</td></tr>`; }).join(''); };
    refreshStock(); await refreshRec();
    const move = async (dir) => {
      const goodsId = +$('#ioGoods').value, count = +$('#ioCount').value, remark = $('#ioRemark').value;
      const orderId = $('#ioOrder').value ? +$('#ioOrder').value : null;
      if (!count || count <= 0) return showToast('请输入正数数量', true);
      const body = { goodsId, count, remark, orderId };
      if (dir === 'in' && imgData) body.image = imgData;
      const res = await post('/api/inout/' + dir, body);
      if (res.code === 200) { showToast((dir === 'in' ? '入库' : '出库') + '成功'); imgData = ''; $('#ioImg').value = ''; $('#ioImgPrev').innerHTML = ''; await loadRefs(); refreshStock(); await refreshRec(); }
      else showToast(res.msg || '操作失败', true);
    };
    $('#btnIn').onclick = () => move('in'); $('#btnOut').onclick = () => move('out');
  }
  /* 分区标签（冷冻/冰鲜/普通） */
  function zoneTag(z) {
    z = z || '普通';
    const c = { 冷冻: '#2a78d6', 冰鲜: '#1baf7a', 普通: '#8a99b5' }[z] || '#8a99b5';
    return `<span class="pill" style="color:${c};background:color-mix(in srgb,${c} 14%,transparent)"><span class="d"></span>${z}</span>`;
  }

  /* ================= 订单链路（采购 / 销售） ================= */
  const ORDER_STATUS = ['待处理', '已完成', '已取消'];
  const statusPill = s => { const c = ['#e0920a', '#0ca30c', '#8a99b5'][s] || '#8a99b5'; return `<span class="pill" style="color:${c};background:color-mix(in srgb,${c} 14%,transparent)"><span class="d"></span>${ORDER_STATUS[s] || '—'}</span>`; };
  const money = n => '¥' + (Number(n || 0)).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

  async function renderOrders(view, type) {
    const isSale = type === 1;
    $('#pageTitle').textContent = isSale ? '销售订单' : '采购订单';
    $('#pageSub').textContent = isSale ? '面向门店/客户的销售出库订单，关联客户与出库流水' : '面向供应商的采购入库订单，关联供应商与入库流水';
    const res = await get('/api/orders?type=' + type);
    let rows = res.data || [];
    view.innerHTML = `<section class="card">
      <div class="toolbar">
        <input class="search" id="q" placeholder="搜索订单号…">
        <button class="btn btn-primary btn-sm" id="add"><svg viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg>新建${isSale ? '销售' : '采购'}订单</button>
        <span class="muted" id="cnt" style="margin-left:auto"></span>
      </div>
      <div class="tablewrap"><table><thead><tr>
        <th>订单号</th><th>${isSale ? '客户' : '供应商'}</th><th>商品项</th><th>总数量</th><th>金额</th><th>状态</th><th>下单时间</th><th>操作</th>
      </tr></thead><tbody id="tb"></tbody></table></div>
    </section>`;
    const render = (list) => {
      $('#cnt').textContent = `共 ${list.length} 单`;
      $('#tb').innerHTML = list.map(o => {
        const who = isSale ? (refs.customer[o.customerId] || '-') : (refs.supplier[o.supplierId] || '-');
        return `<tr>
          <td><b>${esc(o.orderNo)}</b></td><td>${esc(who)}</td>
          <td class="tnum">${o.itemCount} 项</td><td class="qty tnum">${o.totalQty}</td>
          <td class="tnum">${money(o.totalAmount)}</td><td>${statusPill(o.status)}</td>
          <td class="muted tnum">${(o.orderTime || '').replace('T', ' ').slice(0, 16)}</td>
          <td><div class="rowbtns"><button class="btn btn-sm" data-view="${o.id}">查看</button><button class="btn btn-sm" data-edit="${o.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${o.id}">删除</button></div></td>
        </tr>`;
      }).join('') || `<tr><td colspan="8" class="muted">暂无订单</td></tr>`;
      $('#tb').querySelectorAll('[data-view]').forEach(b => b.onclick = () => openOrderDetail(b.dataset.view, isSale));
      $('#tb').querySelectorAll('[data-edit]').forEach(b => b.onclick = () => openOrderForm(type, rows.find(r => r.id == b.dataset.edit)));
      $('#tb').querySelectorAll('[data-del]').forEach(b => b.onclick = async () => { if (!confirm('确认删除该订单？')) return; const r = await del('/api/orders/' + b.dataset.del); if (r.code === 200) { showToast('已删除'); route(); } else showToast(r.msg || '删除失败', true); });
    };
    render(rows);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? rows : rows.filter(o => (o.orderNo || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => openOrderForm(type, null);
  }

  async function openOrderDetail(id, isSale) {
    const res = await get('/api/orders/' + id);
    if (res.code !== 200) return showToast(res.msg || '加载失败', true);
    const o = res.data, items = o.items || [];
    const who = o.type === 1 ? (refs.customer[o.customerId] || '-') : (refs.supplier[o.supplierId] || '-');
    const bg = document.createElement('div'); bg.className = 'modal-bg';
    bg.innerHTML = `<div class="modal"><h3>${o.type === 1 ? '销售' : '采购'}订单 · ${esc(o.orderNo)}</h3>
      <div class="detail-meta">
        <div><span>${o.type === 1 ? '客户' : '供应商'}</span><b>${esc(who)}</b></div>
        <div><span>状态</span>${statusPill(o.status)}</div>
        <div><span>金额</span><b>${money(o.totalAmount)}</b></div>
        <div><span>下单时间</span><b>${(o.orderTime || '').replace('T', ' ').slice(0, 16)}</b></div>
      </div>
      <div class="tablewrap" style="margin-top:14px"><table><thead><tr><th>商品</th><th>分区</th><th>数量</th><th>单价</th><th>小计</th></tr></thead>
        <tbody>${items.map(it => { const g = refs.goodsList.find(x => x.id === it.goodsId) || {}; return `<tr><td>${esc(g.name || ('#' + it.goodsId))}</td><td>${zoneTag(g.zone)}</td><td class="qty tnum">${it.count}</td><td class="tnum">${money(it.price)}</td><td class="tnum">${money((it.price || 0) * (it.count || 0))}</td></tr>`; }).join('') || '<tr><td colspan="5" class="muted">无明细</td></tr>'}</tbody></table></div>
      ${o.remark ? `<div class="muted" style="margin-top:12px">备注：${esc(o.remark)}</div>` : ''}
      <div class="modal-actions"><button class="btn btn-primary" id="mc">关闭</button></div></div>`;
    document.body.appendChild(bg);
    bg.querySelector('#mc').onclick = () => bg.remove();
    bg.onclick = e => { if (e.target === bg) bg.remove(); };
  }

  async function openOrderForm(type, order) {
    const isSale = type === 1, editing = !!order;
    let full = order;
    if (editing) { const r = await get('/api/orders/' + order.id); if (r.code === 200) full = r.data; }
    const items = (full && full.items) ? full.items.slice() : [];
    const partyList = isSale ? refs.customerList : refs.supplierList;
    const partyVal = full ? (isSale ? full.customerId : full.supplierId) : '';
    const goodsOpt = cur => refs.goodsList.map(g => `<option value="${g.id}" ${g.id == cur ? 'selected' : ''}>${esc(g.name)}</option>`).join('');
    const bg = document.createElement('div'); bg.className = 'modal-bg';
    bg.innerHTML = `<div class="modal"><h3>${editing ? '编辑' : '新建'}${isSale ? '销售' : '采购'}订单</h3>
      <div class="form-grid">
        <div class="field"><label>${isSale ? '客户' : '供应商'}</label><select id="oParty">${partyList.map(p => `<option value="${p.id}" ${p.id == partyVal ? 'selected' : ''}>${esc(p.name)}</option>`).join('')}</select></div>
        <div class="field"><label>状态</label><select id="oStatus">${ORDER_STATUS.map((s, i) => `<option value="${i}" ${full && full.status == i ? 'selected' : ''}>${s}</option>`).join('')}</select></div>
        <div class="field full"><label>备注</label><input id="oRemark" value="${esc(full ? (full.remark || '') : '')}" placeholder="选填"></div>
      </div>
      <div class="card-h" style="margin-top:16px"><h3 style="font-size:14px">订单明细</h3><div class="right"><button class="btn btn-sm" id="addItem">+ 添加商品</button></div></div>
      <div class="tablewrap"><table><thead><tr><th>商品</th><th>数量</th><th>单价</th><th></th></tr></thead><tbody id="itemRows"></tbody></table></div>
      <div class="modal-actions"><button class="btn" id="mc">取消</button><button class="btn btn-primary" id="ms">保存</button></div></div>`;
    document.body.appendChild(bg);
    const tb = bg.querySelector('#itemRows');
    const addRow = (it) => { const tr = document.createElement('tr');
      tr.innerHTML = `<td><select class="i-goods">${goodsOpt(it ? it.goodsId : '')}</select></td>
        <td style="width:96px"><input class="i-count" type="number" min="1" value="${it ? it.count : 1}"></td>
        <td style="width:110px"><input class="i-price" type="number" min="0" step="0.01" value="${it ? (it.price || 0) : 0}"></td>
        <td style="width:44px"><button class="btn btn-sm btn-danger i-del">×</button></td>`;
      tb.appendChild(tr); tr.querySelector('.i-del').onclick = () => tr.remove();
    };
    if (items.length) items.forEach(addRow); else addRow(null);
    bg.querySelector('#addItem').onclick = () => addRow(null);
    bg.querySelector('#mc').onclick = () => bg.remove();
    bg.onclick = e => { if (e.target === bg) bg.remove(); };
    bg.querySelector('#ms').onclick = async () => {
      const lineItems = [...tb.querySelectorAll('tr')].map(tr => ({
        goodsId: +tr.querySelector('.i-goods').value,
        count: +tr.querySelector('.i-count').value,
        price: +tr.querySelector('.i-price').value
      })).filter(x => x.goodsId && x.count > 0);
      if (!lineItems.length) return showToast('请至少添加一条商品明细', true);
      const partyId = bg.querySelector('#oParty').value ? +bg.querySelector('#oParty').value : null;
      const payload = { type, status: +bg.querySelector('#oStatus').value, remark: bg.querySelector('#oRemark').value,
        supplierId: isSale ? null : partyId, customerId: isSale ? partyId : null, items: lineItems };
      const r = editing ? await put('/api/orders/' + full.id, payload) : await post('/api/orders', payload);
      if (r.code === 200) { showToast('保存成功'); bg.remove(); route(); } else showToast(r.msg || '保存失败', true);
    };
  }

  /* ================= 详情/档案（商品·供应商·客户） ================= */
  const PERIODS = [['week', '周'], ['month', '月'], ['quarter', '季'], ['year', '年']];
  function imgTag(src, cls) {
    if (src) return `<img class="${cls || ''}" src="${esc(src)}" alt="">`;
    return `<div class="img-ph ${cls || ''}"><svg viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.5"/><circle cx="8.5" cy="9" r="1.6" fill="currentColor"/><path d="M4 17l5-4 4 3 3-2 4 3" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg></div>`;
  }
  function productCard(g, min, manage) {
    const low = min > 0 && (g.count == null ? 0 : g.count) < min;
    return `<div class="pcard" data-id="${g.id}">
      <div class="pcard-img">${imgTag(g.image)}</div>
      <div class="pcard-body">
        <div class="pcard-name" title="${esc(g.name)}">${esc(g.name)}</div>
        <div class="pcard-meta">${zoneTag(g.zone)}<span class="stock-badge ${low ? 'low' : ''}">库存 ${g.count == null ? 0 : g.count}</span></div>
        ${manage ? `<div class="pcard-foot"><button class="btn btn-sm" data-detail="${g.id}">详情</button><button class="btn btn-sm" data-edit="${g.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${g.id}">删除</button></div>` : ''}
      </div></div>`;
  }

  /* 通用折线图：series=[{name,color,data}] */
  function drawLineChart(host, labels, series) {
    if (!labels.length) { host.innerHTML = '<div class="muted" style="padding:40px 0;text-align:center">暂无历史数据</div>'; return; }
    const W = host.clientWidth || 620, H = 240, pl = 46, pr = 14, pt = 14, pb = 26, iw = W - pl - pr, ih = H - pt - pb;
    const all = series.flatMap(s => s.data.map(Number)).concat([10]); const mx = Math.max(...all) * 1.12 || 10;
    const n = labels.length, X = i => pl + (n === 1 ? iw / 2 : i / (n - 1) * iw), Y = v => pt + ih - v / mx * ih;
    let grid = '', axis = '';
    for (let gg = 0; gg <= 4; gg++) { const y = pt + ih - gg / 4 * ih, val = Math.round(mx * gg / 4); grid += `<line x1="${pl}" y1="${y.toFixed(1)}" x2="${W - pr}" y2="${y.toFixed(1)}"/>`; axis += `<text x="${pl - 8}" y="${y + 4}" text-anchor="end">${val >= 1000 ? (val / 1000).toFixed(1) + 'k' : val}</text>`; }
    const xa = labels.map((m, i) => `<text x="${X(i)}" y="${H - 8}" text-anchor="middle">${esc(m)}</text>`).join('');
    let paths = series.map(s => { const pts = s.data.map((v, i) => [X(i), Y(Number(v))]); return `<path d="${smooth(pts)}" fill="none" stroke="${s.color}" stroke-width="2.4"/>`; }).join('');
    let dots = ''; for (let i = 0; i < n; i++) series.forEach(s => { dots += `<circle cx="${X(i)}" cy="${Y(Number(s.data[i]))}" r="3.2" fill="${s.color}" stroke="var(--surface)" stroke-width="1.6" class="pt" data-i="${i}"/>`; });
    host.innerHTML = `<svg viewBox="0 0 ${W} ${H}" width="100%" height="${H}" style="display:block"><g class="grid">${grid}</g>${paths}<g class="axis">${axis}${xa}</g>${dots}</svg>`;
    const tipFor = i => `<b>${esc(labels[i])}</b>` + series.map(s => `<div class="r"><span>${s.name}</span><span class="v">${(+s.data[i]).toLocaleString()}</span></div>`).join('');
    host.querySelectorAll('.pt').forEach(c => { c.addEventListener('mousemove', e => showTip(tipFor(+c.dataset.i), e.clientX, e.clientY)); c.addEventListener('mouseleave', hideTip); });
  }

  /* ---- 商品档案：卡片网格 ---- */
  async function renderGoods(view) {
    $('#pageTitle').textContent = '商品档案';
    $('#pageSub').textContent = '商品图片 + 实时库存（偏低标红），点击查看详情与出入库/库存历史';
    const al = await get('/api/stock_alert');
    const minMap = {}; (al.data || []).forEach(a => { if (a.enabled) minMap[a.goods_id] = a.min_count; });
    const cols = ['id', 'name', 'storage', 'goodsType', 'count', 'zone', 'image', 'remark'];
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索商品…">
        <button class="btn btn-primary btn-sm" id="add"><svg viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg>新增商品</button>
        <span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="pgrid" id="grid"></div></section>`;
    const render = (list) => {
      $('#cnt').textContent = `共 ${list.length} 项`;
      $('#grid').innerHTML = list.map(g => productCard(g, minMap[g.id], true)).join('') || '<div class="muted">暂无商品</div>';
      $('#grid').querySelectorAll('[data-detail]').forEach(b => b.onclick = ev => { ev.stopPropagation(); openGoodsDetail(+b.dataset.detail); });
      $('#grid').querySelectorAll('[data-edit]').forEach(b => b.onclick = ev => { ev.stopPropagation(); openForm('goods', TABLES.goods, cols, refs.goodsList.find(x => x.id == b.dataset.edit)); });
      $('#grid').querySelectorAll('[data-del]').forEach(b => b.onclick = ev => { ev.stopPropagation(); doDelete('goods', b.dataset.del); });
      $('#grid').querySelectorAll('.pcard').forEach(c => c.onclick = () => openGoodsDetail(+c.dataset.id));
    };
    render(refs.goodsList);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? refs.goodsList : refs.goodsList.filter(g => (g.name || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => openForm('goods', TABLES.goods, cols, null);
  }

  async function openGoodsDetail(id) {
    const [d, rec] = await Promise.all([get('/api/profile/goods/' + id), get('/api/record')]);
    if (d.code !== 200) return showToast(d.msg || '加载失败', true);
    const g = d.data, min = g.minCount || 0, low = min > 0 && (g.count == null ? 0 : g.count) < min;
    const recs = (rec.data || []).filter(r => r.goods === id).sort((a, b) => b.id - a.id).slice(0, 12);
    const bg = document.createElement('div'); bg.className = 'modal-bg';
    bg.innerHTML = `<div class="modal modal-lg"><h3>商品详情 · ${esc(g.name)}</h3>
      <div class="pd-head">
        <div class="pd-img">${imgTag(g.image)}</div>
        <div class="pd-info">
          <div class="pd-row"><span>分类</span><b>${esc(refs.goodstype[g.goodsType] || '-')}</b></div>
          <div class="pd-row"><span>分区</span>${zoneTag(g.zone)}</div>
          <div class="pd-row"><span>仓库</span><b>${esc(refs.storage[g.storage] || '-')}</b></div>
          <div class="pd-row"><span>当前库存</span><b class="${low ? 'txt-crit' : ''}">${g.count == null ? 0 : g.count}${low ? ' ⚠ 偏低' : ''}</b></div>
          <div class="pd-row"><span>安全下限</span><b>${min || '—'}</b></div>
          <div class="pd-row"><span>供应商</span><b>${(g.suppliers && g.suppliers.length) ? g.suppliers.map(esc).join('、') : '—'}</b></div>
        </div>
      </div>
      <div class="card-h" style="margin-top:18px"><div><h3 style="font-size:14px">出入库 / 库存历史</h3></div>
        <div class="right"><div class="seg" id="pSeg">${PERIODS.map(([k, l], i) => `<button data-p="${k}" class="${i === 1 ? 'on' : ''}">${l}</button>`).join('')}</div></div></div>
      <div class="legend" style="margin:6px 0 2px"><div class="it"><span class="sw" style="background:#2a78d6"></span>入库</div><div class="it"><span class="sw" style="background:#e0603a"></span>出库</div><div class="it"><span class="sw" style="background:#1f8043"></span>库存</div></div>
      <div id="pChart"></div>
      <div class="card-h" style="margin-top:12px"><h3 style="font-size:14px">近期出入库记录</h3></div>
      <div class="tablewrap"><table><thead><tr><th>类型</th><th>数量</th><th>操作人</th><th>时间</th><th>备注</th></tr></thead>
        <tbody>${recs.map(r => { const inb = r.type === 0; return `<tr><td><span class="pill ${inb ? 'in' : 'out'}"><span class="d"></span>${inb ? '入库' : '出库'}</span></td><td class="qty ${inb ? 'pos' : 'neg'} tnum">${inb ? '+' : '-'}${r.count}</td><td class="muted">${refs.user[r.user_id] || '-'}</td><td class="muted tnum">${r.createtime || ''}</td><td class="muted">${esc(r.remark || '')}</td></tr>`; }).join('') || '<tr><td colspan="5" class="muted">暂无记录</td></tr>'}</tbody></table></div>
      <div class="modal-actions"><button class="btn btn-primary" id="mc">关闭</button></div></div>`;
    document.body.appendChild(bg);
    bg.querySelector('#mc').onclick = () => bg.remove();
    bg.onclick = e => { if (e.target === bg) bg.remove(); };
    const loadChart = async (period) => {
      const h = await get(`/api/profile/goods/${id}/history?period=${period}`);
      const hd = h.data || {};
      drawLineChart(bg.querySelector('#pChart'), hd.labels || [], [
        { name: '入库', color: '#2a78d6', data: hd.inbound || [] },
        { name: '出库', color: '#e0603a', data: hd.outbound || [] },
        { name: '库存', color: '#1f8043', data: hd.stock || [] }
      ]);
    };
    bg.querySelectorAll('#pSeg button').forEach(b => b.onclick = () => { bg.querySelectorAll('#pSeg button').forEach(x => x.classList.remove('on')); b.classList.add('on'); loadChart(b.dataset.p); });
    await loadChart('month');
  }

  /* ---- 供应商：卡片网格 + 详情（所供商品） ---- */
  async function renderSuppliers(view) {
    $('#pageTitle').textContent = '供应商';
    $('#pageSub').textContent = '供应商图片与所供商品，点击查看详情，可下钻到商品档案';
    const cols = ['id', 'name', 'contact', 'phone', 'email', 'address', 'image', 'remark'];
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索供应商…">
        <button class="btn btn-primary btn-sm" id="add"><svg viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg>新增供应商</button>
        <span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="pgrid" id="grid"></div></section>`;
    const render = (list) => {
      $('#cnt').textContent = `共 ${list.length} 家`;
      $('#grid').innerHTML = list.map(s => `<div class="pcard scard" data-id="${s.id}">
        <div class="pcard-img">${imgTag(s.image)}</div>
        <div class="pcard-body"><div class="pcard-name" title="${esc(s.name)}">${esc(s.name)}</div>
          <div class="pcard-sub muted">${esc(s.contact || '')} ${esc(s.phone || '')}</div>
          <div class="pcard-foot"><button class="btn btn-sm" data-detail="${s.id}">详情</button><button class="btn btn-sm" data-edit="${s.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${s.id}">删除</button></div>
        </div></div>`).join('') || '<div class="muted">暂无供应商</div>';
      $('#grid').querySelectorAll('[data-detail]').forEach(b => b.onclick = ev => { ev.stopPropagation(); openSupplierDetail(+b.dataset.detail); });
      $('#grid').querySelectorAll('[data-edit]').forEach(b => b.onclick = ev => { ev.stopPropagation(); openForm('supplier', TABLES.supplier, cols, refs.supplierList.find(x => x.id == b.dataset.edit)); });
      $('#grid').querySelectorAll('[data-del]').forEach(b => b.onclick = ev => { ev.stopPropagation(); doDelete('supplier', b.dataset.del); });
      $('#grid').querySelectorAll('.scard').forEach(c => c.onclick = () => openSupplierDetail(+c.dataset.id));
    };
    render(refs.supplierList);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? refs.supplierList : refs.supplierList.filter(s => (s.name || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => openForm('supplier', TABLES.supplier, cols, null);
  }

  async function openSupplierDetail(id) {
    const s = refs.supplierList.find(x => x.id === id) || {};
    const res = await get('/api/profile/supplier/' + id + '/goods');
    const goods = res.data || [];
    const bg = document.createElement('div'); bg.className = 'modal-bg';
    bg.innerHTML = `<div class="modal modal-lg"><h3>供应商详情 · ${esc(s.name || '')}</h3>
      <div class="pd-head">
        <div class="pd-img">${imgTag(s.image)}</div>
        <div class="pd-info">
          <div class="pd-row"><span>联系人</span><b>${esc(s.contact || '-')}</b></div>
          <div class="pd-row"><span>电话</span><b>${esc(s.phone || '-')}</b></div>
          <div class="pd-row"><span>邮箱</span><b>${esc(s.email || '-')}</b></div>
          <div class="pd-row"><span>地址</span><b>${esc(s.address || '-')}</b></div>
        </div>
      </div>
      <div class="card-h" style="margin-top:18px"><h3 style="font-size:14px">所供商品（${goods.length}）</h3></div>
      <div class="pgrid">${goods.map(g => productCard(g, g.minCount, false)).join('') || '<div class="muted">暂无关联商品</div>'}</div>
      <div class="modal-actions"><button class="btn btn-primary" id="mc">关闭</button></div></div>`;
    document.body.appendChild(bg);
    bg.querySelector('#mc').onclick = () => bg.remove();
    bg.onclick = e => { if (e.target === bg) bg.remove(); };
    bg.querySelectorAll('.pcard').forEach(c => c.onclick = () => { bg.remove(); openGoodsDetail(+c.dataset.id); });
  }

  /* ---- 客户：列表 + 销售订单下钻 ---- */
  async function renderCustomers(view) {
    $('#pageTitle').textContent = '客户';
    $('#pageSub').textContent = '查看每个客户的销售订单及每单商品明细';
    const cols = ['id', 'name', 'contact', 'phone', 'email', 'address', 'remark'];
    view.innerHTML = `<section class="card">
      <div class="toolbar"><input class="search" id="q" placeholder="搜索客户…">
        <button class="btn btn-primary btn-sm" id="add"><svg viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg>新增客户</button>
        <span class="muted" id="cnt" style="margin-left:auto"></span></div>
      <div class="tablewrap"><table><thead><tr><th>客户</th><th>联系人</th><th>电话</th><th>地址</th><th>操作</th></tr></thead><tbody id="tb"></tbody></table></div></section>`;
    const render = (list) => {
      $('#cnt').textContent = `共 ${list.length} 位`;
      $('#tb').innerHTML = list.map(c => `<tr><td><b>${esc(c.name)}</b></td><td>${esc(c.contact || '-')}</td><td class="muted">${esc(c.phone || '-')}</td><td class="muted">${esc(c.address || '-')}</td>
        <td><div class="rowbtns"><button class="btn btn-sm" data-orders="${c.id}">销售订单</button><button class="btn btn-sm" data-edit="${c.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${c.id}">删除</button></div></td></tr>`).join('') || '<tr><td colspan="5" class="muted">暂无客户</td></tr>';
      $('#tb').querySelectorAll('[data-orders]').forEach(b => b.onclick = () => openCustomerOrders(+b.dataset.orders));
      $('#tb').querySelectorAll('[data-edit]').forEach(b => b.onclick = () => openForm('customer', TABLES.customer, cols, refs.customerList.find(x => x.id == b.dataset.edit)));
      $('#tb').querySelectorAll('[data-del]').forEach(b => b.onclick = () => doDelete('customer', b.dataset.del));
    };
    render(refs.customerList);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? refs.customerList : refs.customerList.filter(c => (c.name || '').toLowerCase().includes(q))); };
    $('#add').onclick = () => openForm('customer', TABLES.customer, cols, null);
  }

  async function openCustomerOrders(id) {
    const c = refs.customerList.find(x => x.id === id) || {};
    const res = await get('/api/profile/customer/' + id + '/orders');
    const orders = res.data || [];
    const bg = document.createElement('div'); bg.className = 'modal-bg';
    bg.innerHTML = `<div class="modal modal-lg"><h3>销售订单 · ${esc(c.name || '')}</h3>
      <div class="desc muted" style="margin-bottom:10px">共 ${orders.length} 张销售订单</div>
      ${orders.map(o => `<div class="ord-block">
        <div class="ord-head"><b>${esc(o.orderNo)}</b>${statusPill(o.status)}<span class="muted">${(String(o.orderTime || '')).replace('T', ' ').slice(0, 16)}</span><span class="tnum" style="margin-left:auto">${money(o.totalAmount)}</span></div>
        <div class="tablewrap"><table><thead><tr><th>商品</th><th>数量</th><th>单价</th><th>小计</th></tr></thead>
          <tbody>${(o.items || []).map(it => `<tr><td>${esc(it.goodsName || ('#' + it.goodsId))}</td><td class="qty tnum">${it.count}</td><td class="tnum">${money(it.price)}</td><td class="tnum">${money((it.price || 0) * (it.count || 0))}</td></tr>`).join('') || '<tr><td colspan="4" class="muted">无明细</td></tr>'}</tbody></table></div>
      </div>`).join('') || '<div class="muted">该客户暂无销售订单</div>'}
      <div class="modal-actions"><button class="btn btn-primary" id="mc">关闭</button></div></div>`;
    document.body.appendChild(bg);
    bg.querySelector('#mc').onclick = () => bg.remove();
    bg.onclick = e => { if (e.target === bg) bg.remove(); };
  }

  /* ================= 通用 CRUD ================= */
  async function renderTable(view, t) {
    const cfg = TABLES[t] || { label: t };
    $('#pageTitle').textContent = cfg.label;
    $('#pageSub').textContent = `数据表 ${t} · 增删改查`;
    const res = await get('/api/' + t);
    let rows = res.data || [];
    const cols = cfg.cols || (rows[0] ? Object.keys(rows[0]) : ['id']);
    const shown = cols.filter(c => !(cfg.hide || []).includes(c));
    view.innerHTML = `<section class="card">
      <div class="toolbar">
        <input class="search" id="q" placeholder="搜索…">
        ${cfg.readonly ? '' : `<button class="btn btn-primary btn-sm" id="add"><svg viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg>新增</button>`}
        <span class="muted" id="cnt" style="margin-left:auto"></span>
      </div>
      <div class="tablewrap"><table><thead><tr>${shown.map(c => `<th>${lab(c)}</th>`).join('')}${cfg.readonly ? '' : '<th>操作</th>'}</tr></thead><tbody id="tb"></tbody></table></div>
    </section>`;
    const render = (list) => {
      $('#cnt').textContent = `共 ${list.length} 条`;
      $('#tb').innerHTML = list.map(row => `<tr>${shown.map(c => `<td title="${esc(disp(t, c, row[c]))}">${cell(t, c, row[c])}</td>`).join('')}
        ${cfg.readonly ? '' : `<td><div class="rowbtns"><button class="btn btn-sm" data-edit="${row.id}">编辑</button><button class="btn btn-sm btn-danger" data-del="${row.id}">删除</button></div></td>`}</tr>`).join('')
        || `<tr><td colspan="${shown.length + 1}" class="muted">暂无数据</td></tr>`;
      $('#tb').querySelectorAll('[data-edit]').forEach(b => b.onclick = () => openForm(t, cfg, cols, rows.find(r => r.id == b.dataset.edit)));
      $('#tb').querySelectorAll('[data-del]').forEach(b => b.onclick = () => doDelete(t, b.dataset.del));
    };
    render(rows);
    $('#q').oninput = e => { const q = e.target.value.toLowerCase(); render(!q ? rows : rows.filter(r => shown.some(c => String(disp(t, c, r[c]) ?? '').toLowerCase().includes(q)))); };
    if ($('#add')) $('#add').onclick = () => openForm(t, cfg, cols, null);
  }
  // 展示值（解析关联/类型）
  function disp(t, c, v) {
    if (v == null) return '';
    if (t === 'goods' && c === 'storage') return refs.storage[v] || v;
    if (t === 'goods' && c === 'goodsType') return refs.goodstype[v] || v;
    if (c === 'type' && (t === 'record')) return v === 0 ? '入库' : '出库';
    if (c === 'user_id') return refs.user[v] || v;
    return v;
  }
  function cell(t, c, v) {
    if (c === 'type' && t === 'record') return `<span class="pill ${v === 0 ? 'in' : 'out'}"><span class="d"></span>${v === 0 ? '入库' : '出库'}</span>`;
    if (t === 'goods' && c === 'zone') return zoneTag(v);
    let s = String(disp(t, c, v) ?? ''); if (s.length > 42) s = s.slice(0, 42) + '…'; return esc(s);
  }
  const esc = s => String(s == null ? '' : s).replace(/[&<>"]/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[m]));

  /* 新增/编辑弹窗 */
  function openForm(t, cfg, cols, row) {
    const editing = !!row;
    const fields = cols.filter(c => c !== 'id');
    const val = k => row ? (row[k] ?? '') : '';
    // build modal
    const bg = document.createElement('div'); bg.className = 'modal-bg';
    bg.innerHTML = `<div class="modal"><h3>${editing ? '编辑' : '新增'} · ${cfg.label}</h3>
      <div class="form-grid">${fields.map(c => `<div class="field ${['remark', 'content', 'address', 'data', 'result', 'description', 'image'].includes(c) ? 'full' : ''}"><label>${lab(c)}</label>${fieldInput(t, c, val(c))}</div>`).join('')}</div>
      <div class="modal-actions"><button class="btn" id="mc">取消</button><button class="btn btn-primary" id="ms">保存</button></div></div>`;
    document.body.appendChild(bg);
    // 图片字段：本地文件 → dataURL，写入隐藏 data-f 输入
    bg.querySelectorAll('.img-file').forEach(fi => {
      const wrap = fi.closest('.imgfield'), hidden = wrap.querySelector('[data-f]'), prev = wrap.querySelector('.img-prev');
      fi.onchange = e => { const f = e.target.files[0]; if (!f) return; const rd = new FileReader(); rd.onload = () => { hidden.value = rd.result; prev.innerHTML = `<img src="${rd.result}">`; }; rd.readAsDataURL(f); };
    });
    bg.querySelector('#mc').onclick = () => bg.remove();
    bg.onclick = e => { if (e.target === bg) bg.remove(); };
    bg.querySelector('#ms').onclick = async () => {
      const obj = editing ? { ...row } : {};
      bg.querySelectorAll('[data-f]').forEach(el => { const f = el.dataset.f; let v = el.value; if (el.type === 'number') v = v === '' ? null : Number(v); obj[f] = v; });
      const r = editing ? await put(`/api/${t}/${row.id}`, obj) : await post('/api/' + t, obj);
      if (r.code === 200) { showToast('保存成功'); bg.remove(); await loadRefs(); route(); }
      else showToast(r.msg || '保存失败', true);
    };
  }
  function fieldInput(t, c, v) {
    if (t === 'goods' && c === 'storage') return selectHtml(c, refs.storageList, v);
    if (t === 'goods' && c === 'goodsType') return selectHtml(c, refs.typeList, v);
    if (t === 'goods' && c === 'zone') return `<select data-f="${c}">` + ZONES.map(z => `<option value="${z}" ${z === (v || '普通') ? 'selected' : ''}>${z}</option>`).join('') + `</select>`;
    if (c === 'image') return `<div class="imgfield">
      <input type="hidden" data-f="${c}" value="${esc(v)}">
      <input type="file" class="img-file" accept="image/*">
      <div class="img-prev">${v ? `<img src="${esc(v)}">` : '<span class="muted">未设置图片，可选择本地图片上传</span>'}</div></div>`;
    if (['remark', 'content', 'address', 'data', 'result', 'description'].includes(c)) return `<textarea data-f="${c}" rows="2">${esc(v)}</textarea>`;
    const num = ['count', 'min_count', 'max_count', 'capacity', 'sort', 'age', 'parent_id', 'goods_id', 'supplier_id', 'storage_id', 'role_id', 'res_id', 'res_type', 'user_id', 'system_count', 'actual_count', 'diff_count', 'duration', 'type', 'status', 'row_no', 'col_no', 'enabled', 'locked', 'del_flag', 'loginsign'].includes(c);
    return `<input data-f="${c}" ${num ? 'type="number"' : ''} value="${esc(v)}">`;
  }
  const selectHtml = (col, list, cur) => `<select data-f="${col}">` + (list || []).map(x => `<option value="${x.id}" ${x.id == cur ? 'selected' : ''}>${x.name}</option>`).join('') + `</select>`;

  async function doDelete(t, id) {
    if (!confirm('确认删除该记录？')) return;
    const r = await del(`/api/${t}/${id}`);
    if (r.code === 200) { showToast('已删除'); route(); } else showToast(r.msg || '删除失败', true);
  }

  /* ---------- 启动 ---------- */
  (async function init() {
    buildNav();
    await loadRefs();
    window.addEventListener('hashchange', route);
    if (!location.hash) location.hash = '#/dashboard';
    route();
    let rt; addEventListener('resize', () => { clearTimeout(rt); rt = setTimeout(() => { if ((location.hash.slice(2) || 'dashboard') === 'dashboard') route(); }, 200); });
  })();
})();
