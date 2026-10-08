// Form Validation JavaScript

document.addEventListener("DOMContentLoaded", () => {
  // Initialize form validation for all forms
  const forms = document.querySelectorAll("form")
  forms.forEach((form) => {
    initializeFormValidation(form)
  })

  function initializeFormValidation(form) {
    const inputs = form.querySelectorAll("input, select, textarea")
    const submitButton = form.querySelector('button[type="submit"], input[type="submit"]')

    // Add real-time validation
    inputs.forEach((input) => {
      input.addEventListener("blur", () => validateField(input))
      input.addEventListener("input", () => clearFieldError(input))
    })

    // Handle form submission
    form.addEventListener("submit", (e) => {
      e.preventDefault()

      if (validateForm(form)) {
        handleFormSubmission(form)
      }
    })
  }

  function validateField(field) {
    const value = field.value.trim()
    const fieldType = field.type
    const fieldName = field.name
    let isValid = true
    let errorMessage = ""

    // Remove existing error
    clearFieldError(field)

    // Required field validation
    if (field.hasAttribute("required") && !value) {
      isValid = false
      errorMessage = "Ce champ est obligatoire."
    }

    // Email validation
    else if (fieldType === "email" && value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(value)) {
        isValid = false
        errorMessage = "Veuillez entrer une adresse email valide."
      }
    }

    // Phone validation
    else if (fieldName === "phone" && value) {
      const phoneRegex = /^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/
      if (!phoneRegex.test(value)) {
        isValid = false
        errorMessage = "Veuillez entrer un numéro de téléphone valide."
      }
    }

    // SIRET validation
    else if (fieldName === "siret" && value) {
      const siretRegex = /^\d{14}$/
      if (!siretRegex.test(value)) {
        isValid = false
        errorMessage = "Le numéro SIRET doit contenir exactement 14 chiffres."
      }
    }

    // Name validation
    else if ((fieldName === "firstName" || fieldName === "lastName") && value) {
      if (value.length < 2) {
        isValid = false
        errorMessage = "Ce champ doit contenir au moins 2 caractères."
      }
    }

    // Company name validation
    else if (fieldName === "companyName" && value) {
      if (value.length < 2) {
        isValid = false
        errorMessage = "Le nom de l'entreprise doit contenir au moins 2 caractères."
      }
    }

    // Message validation
    else if (fieldName === "message" && value) {
      if (value.length < 10) {
        isValid = false
        errorMessage = "Le message doit contenir au moins 10 caractères."
      }
    }

    // Loan amount validation
    else if (fieldName === "loanAmount" && value) {
      const amount = Number.parseFloat(value)
      if (isNaN(amount) || amount < 1000) {
        isValid = false
        errorMessage = "Le montant doit être d'au moins 1 000 €."
      }
    }

    if (!isValid) {
      showFieldError(field, errorMessage)
    }

    return isValid
  }

  function validateForm(form) {
    const inputs = form.querySelectorAll("input[required], select[required], textarea[required]")
    let isFormValid = true

    inputs.forEach((input) => {
      if (!validateField(input)) {
        isFormValid = false
      }
    })

    // Special validations for specific forms
    const formId = form.id

    if (formId === "loan-application-form") {
      isFormValid = validateLoanApplicationForm(form) && isFormValid
    } else if (formId === "contact-form") {
      isFormValid = validateContactForm(form) && isFormValid
    }

    return isFormValid
  }

  function validateLoanApplicationForm(form) {
    let isValid = true

    // Validate terms acceptance
    const termsCheckbox = form.querySelector('input[name="terms"]')
    if (termsCheckbox && !termsCheckbox.checked) {
      showFieldError(termsCheckbox, "Vous devez accepter les conditions générales.")
      isValid = false
    }

    // Validate loan type selection
    const loanTypeInputs = form.querySelectorAll('input[name="loanType"]')
    const isLoanTypeSelected = Array.from(loanTypeInputs).some((input) => input.checked)
    if (loanTypeInputs.length > 0 && !isLoanTypeSelected) {
      const firstLoanTypeInput = loanTypeInputs[0]
      showFieldError(firstLoanTypeInput, "Veuillez sélectionner un type de financement.")
      isValid = false
    }

    return isValid
  }

  function validateContactForm(form) {
    const isValid = true

    // Additional contact form validations can be added here

    return isValid
  }

  function showFieldError(field, message) {
    // Remove existing error
    clearFieldError(field)

    // Add error class to field
    field.classList.add("error")

    // Create error message element
    const errorElement = document.createElement("div")
    errorElement.className = "error-message"
    errorElement.textContent = message

    // Insert error message after the field
    field.parentNode.insertBefore(errorElement, field.nextSibling)
  }

  function clearFieldError(field) {
    field.classList.remove("error")
    const errorElement = field.parentNode.querySelector(".error-message")
    if (errorElement) {
      errorElement.remove()
    }
  }

  function handleFormSubmission(form) {
    const submitButton = form.querySelector('button[type="submit"], input[type="submit"]')
    const originalText = submitButton.textContent

    // Show loading state
    submitButton.disabled = true
    submitButton.textContent = "Envoi en cours..."

    // Simulate form submission (replace with actual submission logic)
    setTimeout(() => {
      // Show success message
      showSuccessMessage(form)

      // Reset form
      form.reset()

      // Reset button
      submitButton.disabled = false
      submitButton.textContent = originalText
    }, 2000)
  }

  function showSuccessMessage(form) {
    const successMessage = document.createElement("div")
    successMessage.className = "success-message"
    successMessage.innerHTML = `
            <strong>✅ Message envoyé avec succès !</strong><br>
            Nous vous répondrons dans les plus brefs délais.
        `

    // Insert success message at the top of the form
    form.insertBefore(successMessage, form.firstChild)

    // Remove success message after 5 seconds
    setTimeout(() => {
      successMessage.remove()
    }, 5000)

    // Scroll to success message
    successMessage.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  // Multi-step form handling
  const multiStepForms = document.querySelectorAll(".multi-step-form")
  multiStepForms.forEach((form) => {
    initializeMultiStepForm(form)
  })

  function initializeMultiStepForm(form) {
    const steps = form.querySelectorAll(".form-step")
    const nextButtons = form.querySelectorAll(".btn-next")
    const prevButtons = form.querySelectorAll(".btn-prev")
    const progressSteps = form.querySelectorAll(".progress-step")
    const progressBar = form.querySelector(".form-progress::after")

    let currentStep = 0

    // Show initial step
    showStep(currentStep)

    // Next button handlers
    nextButtons.forEach((button) => {
      button.addEventListener("click", (e) => {
        e.preventDefault()

        // Validate current step
        const currentStepElement = steps[currentStep]
        const stepInputs = currentStepElement.querySelectorAll("input[required], select[required], textarea[required]")
        let isStepValid = true

        stepInputs.forEach((input) => {
          if (!validateField(input)) {
            isStepValid = false
          }
        })

        if (isStepValid && currentStep < steps.length - 1) {
          currentStep++
          showStep(currentStep)
        }
      })
    })

    // Previous button handlers
    prevButtons.forEach((button) => {
      button.addEventListener("click", (e) => {
        e.preventDefault()
        if (currentStep > 0) {
          currentStep--
          showStep(currentStep)
        }
      })
    })

    function showStep(stepIndex) {
      // Hide all steps
      steps.forEach((step, index) => {
        step.style.display = index === stepIndex ? "block" : "none"
      })

      // Update progress indicators
      progressSteps.forEach((step, index) => {
        step.classList.remove("active", "completed")
        if (index < stepIndex) {
          step.classList.add("completed")
        } else if (index === stepIndex) {
          step.classList.add("active")
        }
      })

      // Update progress bar
      if (progressBar) {
        const progressPercentage = (stepIndex / (steps.length - 1)) * 100
        progressBar.style.width = progressPercentage + "%"
      }
    }
  }

  // Real-time character counter for textareas
  const textareas = document.querySelectorAll("textarea[maxlength]")
  textareas.forEach((textarea) => {
    const maxLength = textarea.getAttribute("maxlength")
    const counter = document.createElement("div")
    counter.className = "character-counter"
    counter.style.cssText = "text-align: right; font-size: 12px; color: #666; margin-top: 5px;"

    function updateCounter() {
      const remaining = maxLength - textarea.value.length
      counter.textContent = `${textarea.value.length}/${maxLength} caractères`
      counter.style.color = remaining < 50 ? "#ef4444" : "#666"
    }

    textarea.addEventListener("input", updateCounter)
    textarea.parentNode.appendChild(counter)
    updateCounter()
  })

  // Auto-save form data to localStorage
  const autoSaveForms = document.querySelectorAll(".auto-save")
  autoSaveForms.forEach((form) => {
    const formId = form.id || "unnamed-form"
    const inputs = form.querySelectorAll("input, select, textarea")

    // Load saved data
    const savedData = localStorage.getItem(`form-data-${formId}`)
    if (savedData) {
      const data = JSON.parse(savedData)
      inputs.forEach((input) => {
        if (data[input.name]) {
          if (input.type === "checkbox" || input.type === "radio") {
            input.checked = data[input.name]
          } else {
            input.value = data[input.name]
          }
        }
      })
    }

    // Save data on input
    inputs.forEach((input) => {
      input.addEventListener("input", () => {
        const formData = {}
        inputs.forEach((inp) => {
          if (inp.type === "checkbox" || inp.type === "radio") {
            formData[inp.name] = inp.checked
          } else {
            formData[inp.name] = inp.value
          }
        })
        localStorage.setItem(`form-data-${formId}`, JSON.stringify(formData))
      })
    })

    // Clear saved data on successful submission
    form.addEventListener("submit", () => {
      localStorage.removeItem(`form-data-${formId}`)
    })
  })
})

// Export validation functions for external use
window.FormValidation = {
  validateField: validateField,
  showFieldError: showFieldError,
  clearFieldError: clearFieldError,
}
