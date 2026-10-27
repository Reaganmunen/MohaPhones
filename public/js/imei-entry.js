/**
 * IMEI entry: one neat place to scan / type / paste the IMEIs of phones coming into stock.
 * Used by the Devices page ("Add by IMEI") and by Purchases -> Receive goods.
 *
 *   const entry = HD.imeiEntry.mount(el, { expected: 5, onChange(status) {} });
 *   entry.getList()      -> ['3520...', ...] in the order they were scanned
 *   entry.problem()      -> null when it is fine to save, otherwise a sentence saying what to fix
 *   entry.setExpected(n) -> how many phones you expect (shows "3 of 5" and a progress bar). null = no target
 *   entry.setList(list)  -> load IMEIs (e.g. when re-opening a line)
 *   entry.clear() / entry.focus()
 *
 * What it does while you scan:
 *  - Enter, Tab, comma, space or a pasted list all add IMEIs. Pasting a whole column from Excel/WhatsApp works.
 *  - The same IMEI twice is refused on the spot (the existing row flashes).
 *  - Each IMEI is checked against the system a moment later (POST /devices/validate): already in stock = red.
 *  - A 15-digit IMEI whose check digit is wrong is flagged amber: it is almost always a mistyped digit.
 * Load after api.js and shell.js.
 */
(function (global) {
  'use strict';
  const HD = global.HD;
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

  const FORMAT_RE = /^[A-Z0-9][A-Z0-9\-/]{4,39}$/;     // same rule the server uses
  const norm = (s) => String(s == null ? '' : s).replace(/\s+/g, '').toUpperCase();
  const split = (text) => String(text == null ? '' : text).split(/[\s,;]+/).map(norm).filter(Boolean);

  function luhnOk(s) {
    let sum = 0;
    for (let i = 0; i < s.length; i++) {
      let d = Number(s[s.length - 1 - i]);
      if (i % 2 === 1) { d *= 2; if (d > 9) d -= 9; }
      sum += d;
    }
    return sum % 10 === 0;
  }
  const pretty = (s) => (/^\d{15}$/.test(s) ? s.slice(0, 8) + ' ' + s.slice(8, 14) + ' ' + s.slice(14) : s);

  const STATUS_WORDS = { sold: 'sold earlier', defective: 'marked defective', lost: 'marked lost', supplier_return: 'returned to supplier' };

  /** What is wrong (or worth a look) with one scanned item. level: 'bad' blocks saving, 'warn' and 'info' do not. */
  function judge(it) {
    if (!FORMAT_RE.test(it.imei)) return { level: 'bad', tag: 'Not a valid IMEI', tip: 'Use 5 to 40 letters, numbers, - or /' };
    if (it.server && it.server.status === 'in_stock') {
      return { level: 'bad', tag: 'Already in stock', tip: it.server.product_name ? 'Registered under ' + it.server.product_name : 'This IMEI is already registered' };
    }
    if (/^\d{15}$/.test(it.imei) && !luhnOk(it.imei)) return { level: 'warn', tag: 'Check the digits', tip: 'The last digit does not match, so one digit is probably mistyped' };
    if (/^\d+$/.test(it.imei) && it.imei.length >= 10 && it.imei.length !== 15 && it.imei.length !== 16) {
      return { level: 'warn', tag: it.imei.length + ' digits', tip: 'Phone IMEIs are normally 15 digits' };
    }
    if (it.server && it.server.exists) {
      return { level: 'info', tag: 'Back in stock', tip: 'Known device (' + (STATUS_WORDS[it.server.status] || it.server.status) + ') — it will be put back in stock' };
    }
    return { level: 'ok', tag: '', tip: '' };
  }

  function mount(root, opts) {
    opts = opts || {};
    let expected = opts.expected == null ? null : Number(opts.expected);
    const items = [];            // oldest first: { imei, server: undefined | null | {..} }
    let checkTimer = null, checkRun = 0, checkFailed = false, msgTimer = null, mounted = false;

    root.classList.add('ie');
    root.innerHTML =
      '<div class="ie-top"><div class="ie-count"><b data-count>0</b><span data-of> scanned</span></div>' +
      '<button type="button" class="ie-clear" data-clear hidden><i class="ph-bold ph-trash"></i> Clear all</button></div>' +
      '<div class="ie-bar" data-bar hidden><i></i></div>' +
      '<div class="ie-input"><i class="ph-duotone ph-barcode"></i>' +
      '<input type="text" inputmode="text" autocomplete="off" autocapitalize="characters" spellcheck="false" placeholder="Scan or type an IMEI, then press Enter" aria-label="IMEI or serial number">' +
      '<button type="button" class="ie-add" data-add><i class="ph-bold ph-plus"></i><span>Add</span></button></div>' +
      '<div class="ie-msg" data-msg aria-live="polite"></div>' +
      '<ul class="ie-list" data-list></ul>' +
      '<div class="ie-hint">One IMEI per phone (use IMEI 1 on dual-SIM phones). You can paste a whole list at once.</div>';

    const $ = (sel) => root.querySelector(sel);
    const input = $('input'), list = $('[data-list]'), msg = $('[data-msg]');

    function say(text, kind) {
      clearTimeout(msgTimer);
      msg.textContent = text || ''; msg.className = 'ie-msg' + (kind ? ' ' + kind : '');
      if (text && kind !== 'bad') msgTimer = setTimeout(() => { msg.textContent = ''; msg.className = 'ie-msg'; }, 3500);
    }

    function counts() {
      let bad = 0, warn = 0;
      items.forEach((it) => { const j = judge(it); if (j.level === 'bad') bad++; else if (j.level === 'warn') warn++; });
      return { count: items.length, bad, warn };
    }

    function status() {
      const c = counts();
      return { ...c, expected, problem: problem(), list: items.map((it) => it.imei) };
    }

    function problem() {
      const c = counts();
      if (c.bad) return c.bad === 1 ? '1 IMEI needs fixing (shown in red).' : c.bad + ' IMEIs need fixing (shown in red).';
      if (expected != null && c.count !== expected) {
        const diff = c.count - expected;
        return diff < 0 ? `Scan ${-diff} more IMEI${diff === -1 ? '' : 's'} (${c.count} of ${expected}).` : `Remove ${diff} IMEI${diff === 1 ? '' : 's'} (${c.count} scanned, ${expected} expected).`;
      }
      if (expected == null && !c.count) return 'Enter at least one IMEI.';
      return null;
    }

    function draw() {
      const c = counts();
      $('[data-count]').textContent = c.count;
      const of = $('[data-of]'), bar = $('[data-bar]');
      if (expected != null) {
        of.textContent = ' of ' + expected + ' scanned';
        bar.hidden = false; bar.firstElementChild.style.width = Math.min(100, expected ? (c.count / expected) * 100 : 0) + '%';
        bar.classList.toggle('full', c.count === expected && !c.bad);
        bar.classList.toggle('over', c.count > expected);
      } else { of.textContent = c.count === 1 ? ' phone scanned' : ' phones scanned'; bar.hidden = true; }
      $('[data-clear]').hidden = !c.count;

      list.innerHTML = items.length ? items.slice().reverse().map((it, k) => {
        const j = judge(it), n = items.length - k;
        return `<li class="ie-row ${j.level}" data-imei="${esc(it.imei)}"><span class="n">${n}</span><code>${esc(pretty(it.imei))}</code>` +
          (j.tag ? `<span class="tag" title="${esc(j.tip)}">${esc(j.tag)}</span>` : '<span class="tag"><i class="ph-bold ph-check"></i></span>') +
          `<button type="button" class="x" data-ie-rm="${esc(it.imei)}" aria-label="Remove ${esc(it.imei)}"><i class="ph-bold ph-x"></i></button></li>`;
      }).join('') : '';
      root.classList.toggle('has-items', items.length > 0);
      if (mounted && opts.onChange) opts.onChange(status());
    }

    function flash(imei) {
      const li = list.querySelector(`[data-imei="${CSS.escape(imei)}"]`);
      if (!li) return;
      li.classList.remove('flash'); void li.offsetWidth; li.classList.add('flash');
      li.scrollIntoView({ block: 'nearest' });
    }

    // ---- ask the server which of these are already registered (batched, a moment after the last scan)
    function scheduleCheck() {
      clearTimeout(checkTimer);
      checkTimer = setTimeout(runCheck, 350);
    }
    async function runCheck() {
      const todo = items.filter((it) => it.server === undefined && FORMAT_RE.test(it.imei)).map((it) => it.imei);
      if (!todo.length) return;
      const run = ++checkRun;
      try {
        for (let i = 0; i < todo.length; i += 400) {
          const chunk = todo.slice(i, i + 400);
          const rows = await HD.api('/devices/validate', { method: 'POST', body: { imeis: chunk } });
          if (run !== checkRun) return;                                     // a newer check is running, let it finish the job
          const byImei = new Map(rows.map((r) => [r.imei, r]));
          items.forEach((it) => { if (chunk.includes(it.imei)) it.server = byImei.get(it.imei) || null; });
        }
        checkFailed = false;
      } catch (e) {
        items.forEach((it) => { if (todo.includes(it.imei) && it.server === undefined) it.server = null; });
        if (!checkFailed) say("Couldn't check these against the system. They will be checked again when you save.", 'warn');
        checkFailed = true;
      }
      draw();
      if (run === checkRun && todo.length > 3) {
        const taken = items.filter((it) => todo.includes(it.imei) && it.server && it.server.status === 'in_stock').length;
        if (taken) say(taken + (taken === 1 ? ' IMEI is' : ' IMEIs are') + ' already in stock (red).', 'bad');
      }
    }

    function addTokens(text) {
      const tokens = split(text);
      if (!tokens.length) return;
      let added = 0, dupes = 0, lastDupe = null;
      const have = new Set(items.map((it) => it.imei));
      tokens.forEach((t) => {
        if (have.has(t)) { dupes++; lastDupe = t; return; }
        have.add(t); items.push({ imei: t, server: undefined }); added++;
      });
      draw();
      if (lastDupe) flash(lastDupe);
      if (dupes && !added) say(dupes === 1 ? 'Already scanned: ' + pretty(lastDupe) : dupes + ' IMEIs were already scanned.', 'bad');
      else if (dupes) say(`Added ${added}. Skipped ${dupes} already scanned.`, 'warn');
      else if (added > 1) say('Added ' + added + ' IMEIs.', 'ok');
      else msg.textContent = '';
      if (expected != null && items.length > expected) say(`That is ${items.length - expected} more than the ${expected} you expected.`, 'warn');
      scheduleCheck();
    }

    // ---- events
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === 'Tab' && input.value.trim()) {
        if (input.value.trim()) { e.preventDefault(); addTokens(input.value); input.value = ''; }
        else if (e.key === 'Enter') e.preventDefault();                       // never submit the surrounding form by accident
      }
    });
    input.addEventListener('input', () => {
      if (/[\s,;]/.test(input.value) && input.value.trim()) { addTokens(input.value); input.value = ''; }   // scanners that end with a space/comma
    });
    input.addEventListener('paste', (e) => {
      const text = (e.clipboardData || global.clipboardData).getData('text');
      if (!text) return;
      e.preventDefault(); addTokens(text);
    });
    $('[data-add]').addEventListener('click', () => { addTokens(input.value); input.value = ''; input.focus(); });
    $('[data-clear]').addEventListener('click', () => {
      if (items.length > 5 && !global.confirm('Remove all ' + items.length + ' scanned IMEIs?')) return;
      items.length = 0; draw(); say(''); input.focus();
    });
    list.addEventListener('click', (e) => {
      const b = e.target.closest('[data-ie-rm]'); if (!b) return;
      const k = items.findIndex((it) => it.imei === b.dataset.ieRm);
      if (k >= 0) { items.splice(k, 1); draw(); input.focus(); }
    });

    draw();
    mounted = true;
    return {
      getList: () => items.map((it) => it.imei),
      problem,
      status,
      setExpected(n) { expected = n == null || n === '' ? null : Math.max(0, Math.floor(Number(n)) || 0); draw(); },
      setList(arr) { items.length = 0; (arr || []).forEach((t) => { const s = norm(t); if (s && !items.some((it) => it.imei === s)) items.push({ imei: s, server: undefined }); }); draw(); scheduleCheck(); },
      clear() { items.length = 0; input.value = ''; say(''); draw(); },
      focus() { input.focus(); },
      /** Re-check against the system now (call just before saving if you want the freshest answer). */
      recheck() { items.forEach((it) => { it.server = undefined; }); return runCheck(); },
    };
  }

  HD.imeiEntry = { mount, split, norm };
})(window);
