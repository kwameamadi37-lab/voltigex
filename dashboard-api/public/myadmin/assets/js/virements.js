document.addEventListener("DOMContentLoaded", () => {
  const transferForm = document.getElementById("transfer-form")
  const processingModal = document.getElementById("processing-modal")
  const closeProcessingModalBtn = document.getElementById("close-processing-modal")
  const progressCircle = document.getElementById("progress-circle")
  const progressText = document.getElementById("progress-text")

  if (transferForm && processingModal) {
    transferForm.addEventListener("submit", (e) => {
      e.preventDefault()
      processingModal.classList.add("active")

      let progress = 0
      const interval = setInterval(() => {
        if (progress >= 60) {
          clearInterval(interval)
          // Redirect to failure page after 5 seconds
          setTimeout(() => {
            window.location.href = "virements-echec.html"
          }, 5000)
          return
        }

        progress += 1
        updateProgress(progress)
      }, 50)
    })
  }

  if (closeProcessingModalBtn && processingModal) {
    closeProcessingModalBtn.addEventListener("click", () => {
      processingModal.classList.remove("active")
    })
  }

  function updateProgress(value) {
    if (progressCircle && progressText) {
      const circumference = 2 * Math.PI * 40
      const offset = circumference - (value / 100) * circumference
      progressCircle.style.strokeDasharray = `${circumference} ${circumference}`
      progressCircle.style.strokeDashoffset = offset
      progressText.textContent = `${value}%`
    }
  }
})
