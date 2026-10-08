// Common functionality for all pages
document.addEventListener("DOMContentLoaded", () => {
  // Mobile menu toggle
  const menuToggle = document.getElementById("menuToggle")
  const mobileMenu = document.getElementById("mobileMenu")
  const closeMenu = document.getElementById("closeMenu")

  if (menuToggle && mobileMenu && closeMenu) {
    menuToggle.addEventListener("click", () => {
      mobileMenu.classList.remove("hidden")
    })

    closeMenu.addEventListener("click", () => {
      mobileMenu.classList.add("hidden")
    })

    // Close mobile menu when clicking outside
    mobileMenu.addEventListener("click", (e) => {
      if (e.target === mobileMenu) {
        mobileMenu.classList.add("hidden")
      }
    })
  }

  // Profile dropdown
  const profileDropdown = document.getElementById("profileDropdown")
  const profileMenu = document.getElementById("profileMenu")

  if (profileDropdown && profileMenu) {
    profileDropdown.addEventListener("click", () => {
      profileMenu.classList.toggle("hidden")
    })

    // Close dropdown when clicking outside
    document.addEventListener("click", (e) => {
      if (!profileDropdown.contains(e.target) && !profileMenu.contains(e.target)) {
        profileMenu.classList.add("hidden")
      }
    })
  }

  // Tab functionality
  const tabTriggers = document.querySelectorAll(".tab-trigger")
  const tabContents = document.querySelectorAll(".tab-content")

  if (tabTriggers.length && tabContents.length) {
    tabTriggers.forEach((trigger) => {
      trigger.addEventListener("click", () => {
        // Remove active class from all triggers and contents
        tabTriggers.forEach((t) => t.classList.remove("active"))
        tabContents.forEach((c) => c.classList.remove("active"))

        // Add active class to clicked trigger and corresponding content
        trigger.classList.add("active")
        const tabId = trigger.getAttribute("data-tab")
        document.getElementById(tabId).classList.add("active")
      })
    })
  }

  // Password toggle functionality
  const togglePasswordButtons = document.querySelectorAll(".toggle-password")

  if (togglePasswordButtons.length) {
    togglePasswordButtons.forEach((button) => {
      button.addEventListener("click", function () {
        const input = this.parentElement.querySelector("input")
        const icon = this.querySelector("i")

        if (input.type === "password") {
          input.type = "text"
          icon.classList.remove("fa-eye")
          icon.classList.add("fa-eye-slash")
        } else {
          input.type = "password"
          icon.classList.remove("fa-eye-slash")
          icon.classList.add("fa-eye")
        }
      })
    })
  }
})
