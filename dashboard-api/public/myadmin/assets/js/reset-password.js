document.addEventListener("DOMContentLoaded", () => {
  // Initialize Lucide icons
  lucide.createIcons()

  // Reset password form
  const resetForm = document.getElementById("reset-form")
  const resetFormContainer = document.getElementById("reset-form-container")
  const resetSuccess = document.getElementById("reset-success")
  const sentEmail = document.getElementById("sent-email")

  if (resetForm && resetFormContainer && resetSuccess) {
    resetForm.addEventListener("submit", (e) => {
      e.preventDefault()

      const email = document.getElementById("email").value

      // Show success message
      resetFormContainer.classList.remove("active")
      resetSuccess.classList.add("active")

      // Display the email in the success message
      if (sentEmail) {
        sentEmail.textContent = email
      }
    })
  }
})

// Declare lucide
const lucide = window.lucide
