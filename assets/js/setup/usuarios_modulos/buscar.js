/* Scripts for buscar.jsp */
function validateSearch() {
    const loginField = document.getElementById('f_login');
    if (!loginField) return false;
    
    const login = loginField.value.trim();
    if (login === '') {
        return false;
    }
    return true;
}
