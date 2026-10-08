document.addEventListener("DOMContentLoaded", () => {
  const transferForm = document.getElementById("transferForm")
  const progressModal = document.getElementById("progressModal")
  const progressCircle = document.getElementById("progressCircle")
  const progressText = document.getElementById("progressText")
  const progressStatus = document.getElementById("progressStatus")

  if (transferForm && progressModal) {
    transferForm.addEventListener("submit", async (e) => {
      e.preventDefault()

      const requiredFields = {
        titulaire: "Titulaire du compte",
        nombanque: "Nom de la banque",
        iban: "IBAN",
        montant: "Montant"
      }

      let isValid = true
      for (const [fieldId, fieldName] of Object.entries(requiredFields)) {
        const field = document.getElementById(fieldId)
        if (!field.value.trim()) {
          alert(`${fieldName} est obligatoire`)
          isValid = false
          break
        }
      }

      if (!isValid) return

      const formData = new FormData(transferForm)

      try {
        const response = await fetch("{{ route('virementstore') }}", {
          method: "POST",
          body: formData,
          headers: {
            "X-Requested-With": "XMLHttpRequest",
            "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']").content
          }
        })

        const data = await response.json()

        if (!response.ok) throw new Error(data.message || "Erreur lors du virement")

        // Affiche le modal et démarre l'animation seulement si tout est OK
        progressModal.classList.remove("hidden")

        const radius = 54
        const circumference = radius * 2 * Math.PI
        progressCircle.style.strokeDasharray = `${circumference} ${circumference}`
        progressCircle.style.strokeDashoffset = circumference

        let progress = 0
        const interval = setInterval(() => {
          progress += 1
          const offset = circumference - (progress / 100) * circumference
          progressCircle.style.strokeDashoffset = offset
          progressText.textContent = `${progress}%`

          if (progress >= 60) {
            clearInterval(interval)
            progressStatus.textContent = "Virement validé ! Redirection en cours..."

            setTimeout(() => {
              window.location.href = "/success-virement"
            }, 5000)
          }
        }, 50)

      } catch (error) {
        console.error("Erreur:", error)
        progressModal.classList.add("hidden")
        alert(error.message || "Une erreur est survenue")
      }
    })
  }
})
