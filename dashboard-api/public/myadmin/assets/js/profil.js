document.addEventListener("DOMContentLoaded", () => {
  // Tab switching for mobile
  const tabBtns = document.querySelectorAll(".tab-btn")
  const tabContents = document.querySelectorAll(".tab-content")

  if (tabBtns.length > 0) {
    tabBtns.forEach((btn) => {
      btn.addEventListener("click", function () {
        const tabName = this.getAttribute("data-tab")

        // Remove active class from all buttons and tabs
        tabBtns.forEach((b) => b.classList.remove("active"))
        tabContents.forEach((t) => t.classList.remove("active"))

        // Add active class to current button and tab
        this.classList.add("active")
        document.getElementById(`${tabName}-tab`).classList.add("active")
      })
    })
  }

  // Tab switching for desktop
  const navLinks = document.querySelectorAll(".profile-nav-link")

  if (navLinks.length > 0) {
    navLinks.forEach((link) => {
      if (link.hasAttribute("data-tab")) {
        link.addEventListener("click", function () {
          const tabName = this.getAttribute("data-tab")

          // Remove active class from all links and tabs
          navLinks.forEach((l) => l.classList.remove("active"))
          tabContents.forEach((t) => t.classList.remove("active"))

          // Add active class to current link and tab
          this.classList.add("active")
          document.getElementById(`${tabName}-tab`).classList.add("active")
        })
      }
    })
  }

  // Form submissions
  const contactForm = document.getElementById("contact-form")
  const personalForm = document.getElementById("personal-form")
  const addressForm = document.getElementById("address-form")
  const passwordForm = document.getElementById("password-form")
  const preferencesForm = document.getElementById("preferences-form")
  const notificationsForm = document.getElementById("notifications-form")
  const successMessage = document.getElementById("success-message")
  const successText = document.getElementById("success-text")

  function handleFormSubmit(form, message) {
    if (form) {
      form.addEventListener("submit", (e) => {
        e.preventDefault()
        if (successMessage && successText) {
          successText.textContent = message
          successMessage.classList.remove("hidden")

          // Hide success message after 3 seconds
          setTimeout(() => {
            successMessage.classList.add("hidden")
          }, 3000)
        }
      })
    }
  }

  handleFormSubmit(contactForm, "Coordonnées mises à jour avec succès")
  handleFormSubmit(personalForm, "Données personnelles mises à jour avec succès")
  handleFormSubmit(addressForm, "Adresses mises à jour avec succès")
  handleFormSubmit(passwordForm, "Mot de passe mis à jour avec succès")
  handleFormSubmit(preferencesForm, "Préférences mises à jour avec succès")
  handleFormSubmit(notificationsForm, "Paramètres de notifications mis à jour avec succès")
})
