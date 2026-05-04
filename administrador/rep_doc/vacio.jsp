<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <style>
        html, body { margin:0; padding:0; height:100%; background:#f4f6f9; }
        .empty-state {
            height: 100%;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            color: #a0aec0; gap: 10px;
            font-family: 'Source Sans Pro', 'Segoe UI', sans-serif;
        }
        .empty-icon {
            width: 54px; height: 54px;
            background: #e8edf6;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; color: #b8c8e0;
        }
        .empty-state h6 {
            margin: 0; font-size: 13px; font-weight: 700; color: #4a5568;
        }
        .empty-state p { margin: 0; font-size: 11.5px; color: #a0aec0; }
    </style>
</head>
<body>
<div class="empty-state">
    <div class="empty-icon">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
            <polyline points="10 9 9 9 8 9"></polyline>
        </svg>
    </div>
    <h6>Sin datos</h6>
    <p>Aplique los filtros y pulse <strong>Visualizar</strong> para ver el registro.</p>
</div>
</body>
</html>