let currentRole = "user";

function switchRole(role) {
  currentRole = role;
  const userBtn = document.getElementById("userTabBtn");
  const adminBtn = document.getElementById("adminTabBtn");
  const emailLabel = document.getElementById("emailLabel");
  const emailInput = document.getElementById("emailInput");
  const submitButtonText = document.getElementById("submitButtonText");
  const adminPinContainer = document.getElementById("adminPinContainer");

  if (role === "user") {
    userBtn.className =
      "py-3 rounded-xl font-label-lg transition-all duration-300 bg-primary text-on-primary shadow-sm flex items-center justify-center gap-2";
    adminBtn.className =
      "py-3 rounded-xl font-label-lg transition-all duration-300 text-on-surface-variant hover:text-on-surface flex items-center justify-center gap-2";
    emailLabel.textContent = "Email Pengguna";
    emailInput.placeholder = "nama@gmail.com";
    submitButtonText.textContent = "Masuk sebagai Pengguna";
    adminPinContainer.classList.add("hidden");
  } else {
    adminBtn.className =
      "py-3 rounded-xl font-label-lg transition-all duration-300 bg-primary text-on-primary shadow-sm flex items-center justify-center gap-2";
    userBtn.className =
      "py-3 rounded-xl font-label-lg transition-all duration-300 text-on-surface-variant hover:text-on-surface flex items-center justify-center gap-2";
    emailLabel.textContent = "Email Administrator";
    emailInput.placeholder = "admin.id@TravelerKu.com";
    submitButtonText.textContent = "Masuk sebagai Administrator";
    adminPinContainer.classList.remove("hidden");
  }
}

function togglePasswordVisibility() {
  const passwordInput = document.getElementById("passwordInput");
  const toggleIcon = document.getElementById("togglePasswordIcon");
  if (passwordInput.type === "password") {
    passwordInput.type = "text";
    toggleIcon.textContent = "visibility_off";
  } else {
    passwordInput.type = "password";
    toggleIcon.textContent = "visibility";
  }
}
