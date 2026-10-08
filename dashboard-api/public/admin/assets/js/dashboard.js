document.addEventListener("DOMContentLoaded", () => {
  // Activate card modal functionality
  const activateCardBtn = document.getElementById("activateCardBtn")
  const activateCardModal = document.getElementById("activateCardModal")
  const cancelActivation = document.getElementById("cancelActivation")
  const confirmActivation = document.getElementById("confirmActivation")

  if (activateCardBtn && activateCardModal) {
    activateCardBtn.addEventListener("click", () => {
      activateCardModal.classList.remove("hidden")
    })

    // Close modal when clicking on overlay
    activateCardModal.querySelector(".modal-overlay").addEventListener("click", () => {
      activateCardModal.classList.add("hidden")
    })

    if (cancelActivation) {
      cancelActivation.addEventListener("click", () => {
        activateCardModal.classList.add("hidden")
      })
    }

    if (confirmActivation) {
      confirmActivation.addEventListener("click", () => {
        // Simulate activation process
        confirmActivation.textContent = "Activation en cours..."
        confirmActivation.disabled = true

        setTimeout(() => {
          activateCardModal.classList.add("hidden")
          alert("Votre carte a été activée avec succès !")
          confirmActivation.textContent = "Activer"
          confirmActivation.disabled = false
        }, 1500)
      })
    }
  }
})
