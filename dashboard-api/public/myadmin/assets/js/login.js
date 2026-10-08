document.addEventListener("DOMContentLoaded", () => {
  // Initialize Lucide icons
  lucide.createIcons()

  // Toggle password visibility
  const togglePasswordBtn = document.getElementById("toggle-password")
  const passwordInput = document.getElementById("password")

  if (togglePasswordBtn && passwordInput) {
    togglePasswordBtn.addEventListener("click", () => {
      const icon = togglePasswordBtn.querySelector("i")

      if (passwordInput.type === "password") {
        passwordInput.type = "text"
        icon.setAttribute("data-lucide", "eye-off")
      } else {
        passwordInput.type = "password"
        icon.setAttribute("data-lucide", "eye")
      }

      lucide.createIcons()
    })
  }

  // Login form submission
  const loginForm = document.getElementById("login-form")

  if (loginForm) {
    loginForm.addEventListener("submit", (e) => {
      e.preventDefault()

      // Get form values
      const code = document.getElementById("code").value
      const password = document.getElementById("password").value
      const rememberMe = document.getElementById("remember-me").checked

      console.log("Login attempt:", { code, password, rememberMe })

      // Redirect to home page (in a real app, this would happen after successful authentication)
      window.location.href = "index.html"
    })
  }
})
