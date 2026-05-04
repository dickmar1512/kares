/**
 * Dashboard Main JS
 * Manages Chart.js initialization and interactivity
 */

document.addEventListener('DOMContentLoaded', function() {
    initOccupancyChart();
    initSalesChart();
});

function initOccupancyChart() {
    const ctx = document.getElementById('occupancyChart');
    if (!ctx) return;

    // Data provided by JSP via data attributes or global variables
    const occupied = parseInt(ctx.dataset.occupied) || 0;
    const available = parseInt(ctx.dataset.available) || 0;
    const reserved = parseInt(ctx.dataset.reserved) || 0;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Ocupadas', 'Disponibles', 'Reservadas'],
            datasets: [{
                data: [occupied, available, reserved],
                backgroundColor: [
                    '#ff0844', // Danger gradient start
                    '#2af598', // Success gradient start
                    '#f6d365'  // Warning gradient start
                ],
                borderWidth: 0,
                hoverOffset: 10
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        usePointStyle: true,
                        padding: 20
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0,0,0,0.7)',
                    padding: 10,
                    cornerRadius: 8
                }
            },
            cutout: '70%'
        }
    });
}

function initSalesChart() {
    const ctx = document.getElementById('salesChart');
    if (!ctx) return;

    // Real data provided by JSP
    const labels = JSON.parse(ctx.dataset.labels.replace(/'/g, '"')) || [];
    const data = JSON.parse(ctx.dataset.values) || [];

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Ventas (S/)',
                data: data,
                fill: true,
                backgroundColor: 'rgba(118, 75, 162, 0.1)',
                borderColor: '#764ba2',
                borderWidth: 3,
                tension: 0.4,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#764ba2',
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        display: false
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
}
