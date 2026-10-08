document.addEventListener("DOMContentLoaded", () => {
  // Initialize Lucide icons
  if (typeof lucide !== "undefined") {
    lucide.createIcons()
  }

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

      if (typeof lucide !== "undefined") {
        lucide.createIcons()
      }
    })
  }

  // Multi-step form navigation
  const step1Content = document.getElementById("step-1-content")
  const step2Content = document.getElementById("step-2-content")
  const step3Content = document.getElementById("step-3-content")
  const backBtn = document.getElementById("back-btn")
  const backToStep1 = document.getElementById("back-to-step1")
  const backToStep2 = document.getElementById("back-to-step2")

  // Step 1 to Step 2
  const registerFormStep1 = document.getElementById("register-form-step1")
  if (registerFormStep1 && step1Content && step2Content && backBtn) {
    registerFormStep1.addEventListener("submit", (e) => {
      e.preventDefault()
      step1Content.classList.remove("active")
      step2Content.classList.add("active")
      backBtn.classList.remove("hidden")
    })
  }

  // Step 2 to Step 3
  const registerFormStep2 = document.getElementById("register-form-step2")
  if (registerFormStep2 && step2Content && step3Content) {
    registerFormStep2.addEventListener("submit", (e) => {
      e.preventDefault()
      step2Content.classList.remove("active")
      step3Content.classList.add("active")
    })
  }

  // Back to Step 1
  if (backToStep1 && step1Content && step2Content) {
    backToStep1.addEventListener("click", () => {
      step2Content.classList.remove("active")
      step1Content.classList.add("active")
      backBtn.classList.add("hidden")
    })
  }

  // Back to Step 2
  if (backToStep2 && step2Content && step3Content) {
    backToStep2.addEventListener("click", () => {
      step3Content.classList.remove("active")
      step2Content.classList.add("active")
    })
  }

  // File upload handling
  function setupFileUpload(inputId, previewId, imageId, previewContainerId, placeholderId, changeButtonId) {
    const input = document.getElementById(inputId)
    const preview = document.getElementById(previewId)
    const image = document.getElementById(imageId)
    const previewContainer = document.getElementById(previewContainerId)
    const placeholder = document.getElementById(placeholderId)
    const changeButton = document.getElementById(changeButtonId)

    if (input && preview && image && previewContainer && placeholder) {
      input.addEventListener("change", (e) => {
        const file = e.target.files[0]
        if (file) {
          const reader = new FileReader()
          reader.onload = (e) => {
            image.src = e.target.result
            placeholder.style.display = "none"
            preview.classList.remove("hidden")
          }
          reader.readAsDataURL(file)
        }
      })

      if (changeButton) {
        changeButton.addEventListener("click", () => {
          preview.classList.add("hidden")
          placeholder.style.display = "block"
          input.value = ""
        })
      }
    }
  }

  setupFileUpload(
    "id-front-input",
    "id-front-preview",
    "id-front-image",
    "id-front-dropzone",
    "id-front-placeholder",
    "change-id-front",
  )
  setupFileUpload(
    "id-back-input",
    "id-back-preview",
    "id-back-image",
    "id-back-dropzone",
    "id-back-placeholder",
    "change-id-back",
  )

  // Final form submission
  const registerFormStep3 = document.getElementById("register-form-step3")
  if (registerFormStep3) {
    registerFormStep3.addEventListener("submit", (e) => {
      e.preventDefault()

      // In a real app, you would collect all form data and submit it
      console.log("Registration completed")

      // Redirect to login page
      window.location.href = "login.html"
    })
  }
})
