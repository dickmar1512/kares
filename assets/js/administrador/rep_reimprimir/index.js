/* Scripts for Reimpresión Index */
let currentPdfUrl = '';
let basePrintUrl = '';

$(function() {
    // Initial results count
    const rows = $('table.table-kares tbody tr:not(.no-results-row)').length;
    if(rows > 0) {
        $('#totalResultados').text(rows + ' registro' + (rows !== 1 ? 's' : ''));
    }
});

function openPDFModal(idMovVnt, printUrl) {
    if (printUrl) basePrintUrl = printUrl;
    currentPdfUrl = basePrintUrl + '?f_id_mov_vnt=' + idMovVnt;
    const viewer = document.getElementById('pdfViewer');
    if (viewer) viewer.src = currentPdfUrl;
    $('#pdfModal').modal('show');
}

function downloadPDF() {
    if (!currentPdfUrl) return;
    const link = document.createElement('a');
    link.href = currentPdfUrl;
    link.download = 'comprobante.pdf';
    link.click();
}

function printPDF() {
    if (!currentPdfUrl) return;
    const iframe = document.getElementById('pdfViewer');
    try {
        if (iframe && iframe.contentWindow) {
            iframe.contentWindow.print();
        } else {
            window.open(currentPdfUrl, '_blank');
        }
    } catch(e) {
        window.open(currentPdfUrl, '_blank');
    }
}
