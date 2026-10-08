document.addEventListener("DOMContentLoaded", () => {
  // Toggle balance visibility
  const toggleBalanceBtn = document.getElementById("toggle-balance")
  const balanceAmount = document.getElementById("balance-amount")

  if (toggleBalanceBtn && balanceAmount) {
    toggleBalanceBtn.addEventListener("click", () => {
      const icon = toggleBalanceBtn.querySelector("i")
      if (balanceAmount.textContent === "****") {
        balanceAmount.textContent = "1250,00 €"
        icon.setAttribute("data-lucide", "eye-off")
      } else {
        balanceAmount.textContent = "****"
        icon.setAttribute("data-lucide", "eye")
      }
      lucide.createIcons()
    })
  }

  // Auto-scroll carousel for mobile
  const carouselContainer = document.querySelector(".carousel-container")
  if (carouselContainer) {
    const carouselItems = carouselContainer.querySelector(".carousel-items")
    if (carouselItems) {
      let scrollAmount = 0
      const distance = 1 // pixels per frame
      const speed = 30 // milliseconds

      function autoScroll() {
        carouselContainer.scrollLeft += distance
        scrollAmount += distance

        // Reset when we've scrolled through all items
        if (scrollAmount >= carouselItems.scrollWidth / 2) {
          carouselContainer.scrollLeft = 0
          scrollAmount = 0
        }

        setTimeout(autoScroll, speed)
      }

      // Start auto-scroll after a delay
      setTimeout(autoScroll, 2000)
    }
  }
})
