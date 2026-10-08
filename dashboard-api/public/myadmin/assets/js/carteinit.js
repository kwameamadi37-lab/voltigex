document.addEventListener("DOMContentLoaded", () => {
  // Initialize Lucide icons
  lucide.createIcons()

  // Refresh button functionality
  const refreshBtn = document.getElementById("refresh-btn")

  if (refreshBtn) {
    refreshBtn.addEventListener("click", function () {
      // Add loading state
      this.classList.add("loading")
      const icon = this.querySelector("i")
      const text = this.querySelector("span")

      if (icon) {
        icon.classList.add("animate-spin")
      }

      if (text) {
        text.textContent = "Aggiornamento..."
      }

      // Simulate loading
      setTimeout(() => {
        // Reset button state
        this.classList.remove("loading")
        if (icon) {
          icon.classList.remove("animate-spin")
        }
        if (text) {
          text.textContent = "Aggiorna pagina"
        }

        // Reload page or simulate refresh
        // window.location.reload();
        // For demo, just show a message
        alert("Page refreshed!")
      }, 2000)
    })
  }

  // Toggle balance visibility
  const toggleBalanceBtn = document.querySelector(".toggle-balance-btn")
  const balanceAmounts = document.querySelectorAll(".balance-amount")

  if (toggleBalanceBtn && balanceAmounts.length) {
    toggleBalanceBtn.addEventListener("click", () => {
      const icon = toggleBalanceBtn.querySelector("i")
      const text = toggleBalanceBtn.querySelector("span")

      // Check if balance is hidden
      const isHidden = balanceAmounts[0].textContent === "**** €"

      balanceAmounts.forEach((amount) => {
        amount.textContent = isHidden ? "0.00 €" : "**** €"
      })

      if (icon) {
        icon.setAttribute("data-lucide", isHidden ? "eye-off" : "eye")
      }

      if (text) {
        text.textContent = isHidden ? "Nascondi saldo" : "Mostra saldo"
      }

      lucide.createIcons()
    })
  }
})
