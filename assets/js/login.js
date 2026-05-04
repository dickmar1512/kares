/* Toggle password visibility */
function togglePassword() {
    const input = document.getElementById('password');
    const icon  = document.getElementById('toggleIcon');
    const show  = input.type === 'password';
    input.type  = show ? 'text' : 'password';
    icon.className = show ? 'fas fa-eye-slash' : 'fas fa-eye';
}

/* Loading state on submit */
document.getElementById('loginForm').addEventListener('submit', function () {
    const btn  = document.getElementById('submitBtn');
    const text = document.getElementById('btnText');
    btn.classList.add('loading');
    text.textContent = 'Iniciando sesión…';
});