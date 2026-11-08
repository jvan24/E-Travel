function togglePasswordVisibility() {
  const passwordInput = document.getElementById("adminPassword");
  const toggleIcon = document.getElementById("passwordToggleIcon");

  if (passwordInput.type === "password") {
    passwordInput.type = "text";
    toggleIcon.textContent = "visibility_off";
  } else {
    passwordInput.type = "password";
    toggleIcon.textContent = "visibility";
  }
}

function handleLogin() {
  const button = document.getElementById("submitButton");
  const originalContent = button.innerHTML;

  button.innerHTML = `
      <span class="inline-block animate-spin w-4 h-4 border-2 border-on-primary border-t-transparent rounded-full"></span>
      <span>Memverifikasi Otoritas...</span>
    `;
  button.disabled = true;

  setTimeout(() => {
    button.innerHTML = `
        <span class="material-symbols-outlined">check_circle</span>
        <span>Akses Diterima</span>
      `;
    button.classList.remove("bg-primary-container");
    button.classList.add("bg-tertiary");

    setTimeout(() => {
      button.innerHTML = originalContent;
      button.classList.remove("bg-tertiary");
      button.classList.add("bg-primary-container");
      button.disabled = false;
      alert("Selamat datang di Sistem Administrasi TravelerKu.");
    }, 1000);
  }, 1200);
}
