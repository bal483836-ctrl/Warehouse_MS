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
    goods:           { label: '商品档案' },
    goodstype:       { label: '商品分类' },
    storage:         { label: '仓库管理' },
    location:        { label: '货位管理' },
    supplier:        { label: '供应商管理' },
    customer:        { label: '客户管理' },
    goods_batch:     { label: '批次/保质期' },
    stock_alert:     { label: '库存预警' },
    stock_check:     { label: '库存盘点' },
    stock_check_item:{ label: '盘点明细' },
    sys_user:        { label: '用户管理', hide: ['password', 'salt'] },
    sys_role:        { label: '角色管理' },
    sys_menu:        { label: '菜单管理' },
    sys_user_role:   { label: '用户角色' },
    sys_role_res:    { label: '角色资源' },
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
      ['t/sys_log', '操作日志', 'M4 4h16v16H4zM8 9h8M8 13h5'] ] }
  ];
  const LABELS = { id:'ID', name:'名称', remark:'备注', count:'数量', storage:'仓库', goodsType:'分类', goods:'货品',
    user_id:'操作人', createtime:'时间', create_time:'创建时间', update_time:'更新时间', create_by:'创建人', update_by:'更新人',
    del_flag:'删除', type:'类型', contact:'联系人', phone:'电话', email:'邮箱', address:'地址', supplier_id:'供应商',
    batch_no:'批次号', production_date:'生产日期', expiry_date:'到期日', min_count:'最低库存', max_count:'最高库存',
    enabled:'启用', goods_id:'货品', code:'库位编码', zone:'库区', row_no:'排', col_no:'列', capacity:'容量',
    check_no:'盘点单号', storage_id:'仓库', status:'状态', check_time:'盘点时间', system_count:'系统库存',
    actual_count:'实盘', diff_count:'差异', check_id:'盘点单', title:'标题', content:'内容', number:'账号',
    age:'年龄', sex:'性别', locked:'锁定', loginsign:'登录标识', parent_id:'上级', icon:'图标', url:'地址',
    sort:'排序', description:'说明', component:'组件', role_id:'角色', res_id:'资源', res_type:'资源类型',
    ip_addr:'IP地址', data:'参数', methods:'方法', result:'结果', duration:'耗时(ms)', is_hidden_menu:'隐藏', is_option_menu:'下拉' };
  const lab = k => LABELS[k] || k;

  /* 关联字典（列表展示 id -> 名称） */
  const refs = {};
  async function loadRefs() {
    const [st, gt, gs, us] = await Promise.all([get('/api/storage'), get('/api/goodstype'), get('/api/goods'), get('/api/sys_user')]);
    refs.storage = map(st.data, 'id', 'name'); refs.goodstype = map(gt.data, 'id', 'name');
    refs.goods = map(gs.data, 'id', 'name'); refs.user = map(us.data, 'id', 'name');
    refs.goodsList = gs.data || []; refs.storageList = st.data || []; refs.typeList = gt.data || [];
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
          <div><div class="card-h"><h3>仓库库位热力图</h3></div><div class="desc" style="margin-top:2px">占用率与预警由真实库存数据算出 · 颜色越深库存越满，红色为预警库位</div></div>
          <div class="hm-legend"><select id="hmStore" style="width:auto"></select><div class="hm-scale"><span>空</span><div class="hm-bar"></div><span>满</span></div><div class="hm-flag"><div class="box"></div>预警</div></div>
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
  const ramp = ['#e9f1fd', '#cde2fb', '#9ec5f4', '#6da7ec', '#3987e5', '#256abf', '#184f95', '#0d366b'];
  const rampColor = p => p <= 0 ? ramp[0] : ramp[Math.min(ramp.length - 1, 1 + Math.floor(p / 100 * (ramp.length - 1)))];
  async function loadHeatmap(storageId) {
    const res = await get('/api/heatmap?storageId=' + storageId);
    const bins = res.data.bins || [];
    const zones = {};
    bins.forEach(b => { (zones[b.zone] = zones[b.zone] || []).push(b); });
    $('#zones').innerHTML = Object.keys(zones).sort().map(z => {
      const cells = zones[z].map(b => {
        const cls = b.alert ? 'crit' : (b.stock <= 0 ? 'empty' : (b.occupancy > 50 ? 'hi' : ''));
        const bg = b.alert ? '' : `background:${rampColor(b.occupancy)}`;
        return `<div class="bin ${cls}" style="${bg}" data-code="${b.code}" data-g="${b.goods}" data-o="${b.occupancy}" data-a="${b.alert ? (b.reason || '预警') : ''}">${b.rowNo}</div>`;
      }).join('');
      return `<div class="zone"><div class="zt">${z} 区<span>${zones[z].length} 库位</span></div><div class="bins">${cells}</div></div>`;
    }).join('');
    $('#zones').querySelectorAll('.bin').forEach(b => {
      b.addEventListener('mousemove', e => showTip(`<b>库位 ${b.dataset.code}</b><div class="r"><span>货物</span><span class="v">${b.dataset.g}</span></div><div class="r"><span>占用</span><span class="v">${b.dataset.o}%</span></div>${b.dataset.a ? `<div class="r" style="color:#ff9b9b">⚠ ${b.dataset.a}</div>` : ''}`, e.clientX, e.clientY));
      b.addEventListener('mouseleave', hideTip);
    });
  }

  /* ================= 出入库操作 ================= */
  async function renderInout(view) {
    $('#pageTitle').textContent = '出入库操作';
    $('#pageSub').textContent = '选择货物执行入库 / 出库，实时更新库存与库位';
    view.innerHTML = `
      <section class="grid-2">
        <div class="card">
          <div class="card-h"><h3>登记单据</h3></div>
          <div style="display:flex;flex-direction:column;gap:14px;margin-top:12px">
            <div class="field"><label>选择货物</label><select id="ioGoods"></select></div>
            <div class="field"><label>数量</label><input id="ioCount" type="number" min="1" value="10"></div>
            <div class="field"><label>备注</label><input id="ioRemark" placeholder="选填"></div>
            <div style="display:flex;gap:12px;margin-top:4px">
              <button class="btn btn-primary" id="btnIn" style="flex:1">入库</button>
              <button class="btn" id="btnOut" style="flex:1">出库</button>
            </div>
          </div>
        </div>
        <div class="card">
          <div class="card-h"><h3>当前库存</h3></div>
          <div class="tablewrap" style="margin-top:10px"><table><thead><tr><th>货物</th><th>仓库</th><th>库存</th></tr></thead><tbody id="ioStock"></tbody></table></div>
        </div>
      </section>
      <section class="card">
        <div class="card-h"><h3>最新流水</h3></div>
        <div class="tablewrap" style="margin-top:8px"><table><thead><tr><th>货物</th><th>类型</th><th>数量</th><th>操作人</th><th>时间</th><th>备注</th></tr></thead><tbody id="ioRec"></tbody></table></div>
      </section>`;
    $('#ioGoods').innerHTML = refs.goodsList.map(g => `<option value="${g.id}">${g.name}（${refs.storage[g.storage] || ''}）</option>`).join('');
    const refreshStock = () => { $('#ioStock').innerHTML = refs.goodsList.map(g => `<tr><td>${g.name}</td><td class="muted">${refs.storage[g.storage] || '-'}</td><td class="qty tnum">${g.count}</td></tr>`).join(''); };
    const refreshRec = async () => { const rec = await get('/api/record'); const rows = (rec.data || []).sort((a, b) => b.id - a.id).slice(0, 10);
      $('#ioRec').innerHTML = rows.map(r => { const g = refs.goodsList.find(x => x.id === r.goods) || {}; const inb = r.type === 0;
        return `<tr><td>${g.name || '#' + r.goods}</td><td><span class="pill ${inb ? 'in' : 'out'}"><span class="d"></span>${inb ? '入库' : '出库'}</span></td><td class="qty ${inb ? 'pos' : 'neg'} tnum">${inb ? '+' : '-'}${r.count}</td><td class="muted">${refs.user[r.user_id] || '-'}</td><td class="muted tnum">${r.createtime || ''}</td><td class="muted">${r.remark || ''}</td></tr>`; }).join(''); };
    refreshStock(); await refreshRec();
    const move = async (dir) => {
      const goodsId = +$('#ioGoods').value, count = +$('#ioCount').value, remark = $('#ioRemark').value;
      if (!count || count <= 0) return showToast('请输入正数数量', true);
      const res = await post('/api/inout/' + dir, { goodsId, count, remark });
      if (res.code === 200) { showToast((dir === 'in' ? '入库' : '出库') + '成功'); await loadRefs(); refreshStock(); await refreshRec(); }
      else showToast(res.msg || '操作失败', true);
    };
    $('#btnIn').onclick = () => move('in'); $('#btnOut').onclick = () => move('out');
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
      <div class="form-grid">${fields.map(c => `<div class="field ${['remark', 'content', 'address', 'data', 'result', 'description'].includes(c) ? 'full' : ''}"><label>${lab(c)}</label>${fieldInput(t, c, val(c))}</div>`).join('')}</div>
      <div class="modal-actions"><button class="btn" id="mc">取消</button><button class="btn btn-primary" id="ms">保存</button></div></div>`;
    document.body.appendChild(bg);
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
