(function () {
  'use strict';
  const { api, fmt, shell } = HD;
  const { esc } = fmt;
  const $ = (id) => document.getElementById(id);
  const PAGE_SIZE = 25;
  let page = 1, pages = 1, modal, busy = false, loadId = 0;
  const debounce = (fn, ms) => { let t; return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); }; };
  const dash = '<span class="muted">—</span>';
  const day = (v) => fmt.dayLabel(fmt.dateKey(v), { day: 'numeric', month: 'short', year: 'numeric' });
  const STATUS = { in_stock: ['ok', 'In stock'], sold: ['soon', 'Sold'], defective: ['gone', 'Defective'], lost: ['gone', 'Lost'], supplier_return: ['draft', 'Returned to supplier'] };

  function warranty(r) {
    if (r.status !== 'sold' && r.under_warranty === null) return dash;
    if (r.under_warranty === null || r.under_warranty === undefined) return dash;
    return `<span class="pill ${r.under_warranty ? 'ok' : 'gone'}">${r.under_warranty ? 'Until ' : 'Expired '}${esc(day(r.warranty_expires))}</span>`;
  }

  async function load() {
    const body = $('d-body'), id = ++loadId;
    try {
      const q = $('d-q').value.trim(), st = $('d-status').value;
      const r = await api('/devices?limit=' + PAGE_SIZE + '&page=' + page + (q ? '&q=' + encodeURIComponent(q) : '') + (st ? '&status=' + st : ''), { full: true });
      if (id !== loadId) return;
      pages = r.meta.pages;
      $('d-count').textContent = r.meta.total + (r.meta.total === 1 ? ' device' : ' devices');
      $('d-pager').hidden = pages <= 1;
      $('d-page').textContent = 'Page ' + page + ' of ' + pages;
      $('d-prev').disabled = page <= 1; $('d-next').disabled = page >= pages;
      if (!r.data.length) { body.innerHTML = '<tr><td colspan="6"><div class="state-box"><i class="ph-duotone ph-device-mobile"></i><div>No devices found</div></div></td></tr>'; return; }
      body.innerHTML = r.data.map((d) => {
        const [cls, label] = STATUS[d.status] || ['draft', d.status];
        const buyer = d.customer_name ? `<b>${esc(d.customer_name)}</b><small class="d-block text-muted">${esc(d.customer_phone || '')}</small>` : (d.sale_number ? 'Walk-in' : dash);
        return `<tr><td class="nm"><b>${esc(d.product_name)}</b><small>${esc(d.sku || '')}</small></td>` +
          `<td class="imei-cell">${esc(d.imei)}</td><td><span class="pill ${cls}">${esc(label)}</span></td>` +
          `<td class="d-none d-md-table-cell">${esc(d.location || '') || dash}</td>` +
          `<td>${buyer}${d.sale_number ? `<small class="d-block text-muted">${esc(d.sale_number)}${d.sold_at ? ' · ' + esc(day(d.sold_at)) : ''}</small>` : ''}</td>` +
          `<td>${warranty(d)}</td></tr>`;
      }).join('');
    } catch (e) {
      body.innerHTML = '<tr><td colspan="6"><div class="state-box"><i class="ph-duotone ph-warning-circle"></i><div>' + esc(e.message) + '</div></div></td></tr>';
    }
  }
  $('d-q').addEventListener('input', debounce(() => { page = 1; load(); }, 300));
  $('d-status').addEventListener('change', () => { page = 1; load(); });
  $('d-prev').addEventListener('click', () => { if (page > 1) { page--; load(); } });
  $('d-next').addEventListener('click', () => { if (page < pages) { page++; load(); } });

  // ------------------------------------------------------------ add devices by IMEI
  const count = () => $('a-imeis').value.split(/[\s,;]+/).filter(Boolean).length;
  $('a-imeis').addEventListener('input', () => { $('a-n').textContent = '(' + count() + ')'; });

  async function openAdd() {
    modal = modal || new bootstrap.Modal($('devModal'));
    $('a-err').hidden = true; $('a-imeis').value = ''; $('a-n').textContent = '(0)';
    try {
      const prods = (await api('/products?limit=200&active=true')).filter((p) => p.requires_imei);
      $('a-product').innerHTML = prods.length ? prods.map((p) => `<option value="${p.id}">${esc(p.name)} · ${esc(p.sku)}</option>`).join('')
        : '<option value="">No IMEI-tracked products yet. Tick "Track each unit by IMEI" on a product first.</option>';
      const locs = await api('/locations');
      $('a-loc').innerHTML = '<option value="">Default shop</option>' + locs.map((l) => `<option value="${l.id}">${esc(l.name)}</option>`).join('');
    } catch (e) { /* the selects just stay as they are */ }
    modal.show();
  }
  $('add-devices').addEventListener('click', openAdd);

  $('a-save').addEventListener('click', async () => {
    if (busy) return;
    const err = $('a-err'), fail = (m) => { err.querySelector('span').textContent = m; err.hidden = false; };
    err.hidden = true;
    if (!$('a-product').value) return fail('Choose a product.');
    if (!count()) return fail('Enter at least one IMEI / serial number.');
    busy = true; const btn = $('a-save'); btn.disabled = true; btn.querySelector('.label').textContent = 'Saving…';
    try {
      await api('/devices/intake', { method: 'POST', body: { product_id: Number($('a-product').value), imeis: $('a-imeis').value, location_id: $('a-loc').value ? Number($('a-loc').value) : undefined } });
      modal.hide(); page = 1; load();
    } catch (e) { fail(e.message); }
    finally { busy = false; btn.disabled = false; btn.querySelector('.label').textContent = 'Add to stock'; }
  });

  load();
})();
