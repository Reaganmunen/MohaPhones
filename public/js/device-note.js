/** Shared by receipts and the sale view: HD.deviceNote(item) -> { imei, warranty } text (empty strings when not applicable). */
(function () {
  'use strict';
  const day = (v) => new Intl.DateTimeFormat('en-GB', { timeZone: 'Africa/Nairobi', day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(v));
  HD.deviceNote = function (i) {
    const imeis = Array.isArray(i.imeis) ? i.imeis : [];
    return {
      imei: imeis.length ? (imeis.length > 1 ? 'IMEI/SN: ' : 'IMEI/SN: ') + imeis.join(', ') : '',
      warranty: i.warranty_expires ? 'Warranty until ' + day(i.warranty_expires)
        : (Number(i.warranty_months) > 0 ? 'Warranty: ' + i.warranty_months + ' month' + (Number(i.warranty_months) === 1 ? '' : 's') : ''),
    };
  };
})();
