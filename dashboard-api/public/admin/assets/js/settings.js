document.addEventListener("DOMContentLoaded", () => {
  // Settings forms functionality
  const accountForm = document.getElementById("accountForm")
  const securityForm = document.getElementById("securityForm")
  const notificationsForm = document.getElementById("notificationsForm")

  // Handle account form submission
  if (accountForm) {
    accountForm.addEventListener("submit", (e) => {
      e.preventDefault()

      // Simple validation
      const email = document.getElementById("email").value
      const phone = document.getElementById("phone").value
      const address = document.getElementById("address").value
      const city = document.getElementById("city").value
      const postalCode = document.getElementById("postalCode").value

      if (!email || !phone || !address || !city || !postalCode) {
        alert("Veuillez remplir tous les champs")
        return
      }

      // Simulate saving process
      const submitBtn = accountForm.querySelector('button[type="submit"]')
      submitBtn.textContent = "Enregistrement..."
      submitBtn.disabled = true

      setTimeout(() => {
        alert("Vos informations ont été mises à jour avec succès !")
        submitBtn.textContent = "Enregistrer les modifications"
        submitBtn.disabled = false
      }, 1500)
    })
  }

  // Handle security form submission
  if (securityForm) {
    securityForm.addEventListener("submit", (e) => {
      e.preventDefault()

      // Simple validation
      const currentPassword = document.getElementById("currentPassword").value
      const newPassword = document.getElementById("newPassword").value
      const confirmPassword = document.getElementById("confirmPassword").value

      if (!currentPassword || !newPassword || !confirmPassword) {
        alert("Veuillez remplir tous les champs")
        return
      }

      if (newPassword !== confirmPassword) {
        alert("Les mots de passe ne correspondent pas")
        return
      }

      // Simulate saving process
      const submitBtn = securityForm.querySelector('button[type="submit"]')
      submitBtn.textContent = "Enregistrement..."
      submitBtn.disabled = true

      setTimeout(() => {
        alert("Vos paramètres de sécurité ont été mis à jour avec succès !")
        submitBtn.textContent = "Mettre à jour la sécurité"
        submitBtn.disabled = false

        // Reset password fields
        document.getElementById("currentPassword").value = ""
        document.getElementById("newPassword").value = ""
        document.getElementById("confirmPassword").value = ""
      }, 1500)
    })
  }

  // Handle notifications form submission
  if (notificationsForm) {
    notificationsForm.addEventListener("submit", (e) => {
      e.preventDefault()

      // Simulate saving process
      const submitBtn = notificationsForm.querySelector('button[type="submit"]')
      submitBtn.textContent = "Enregistrement..."
      submitBtn.disabled = true

      setTimeout(() => {
        alert("Vos préférences de notifications ont été mises à jour avec succès !")
        submitBtn.textContent = "Enregistrer les préférences"
        submitBtn.disabled = false
      }, 1500)
    })
  }
})
