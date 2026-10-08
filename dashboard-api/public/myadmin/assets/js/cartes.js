document.addEventListener("DOMContentLoaded", () => {
  // Toggle card number visibility
  const toggleCardNumberBtn = document.getElementById("toggle-card-number")
  const cardNumber = document.getElementById("card-number")

  if (toggleCardNumberBtn && cardNumber) {
    toggleCardNumberBtn.addEventListener("click", () => {
      const icon = toggleCardNumberBtn.querySelector("i")
      if (cardNumber.textContent === "4810 00** **** 7840") {
        cardNumber.textContent = "4810 0012 3456 7840"
        icon.setAttribute("data-lucide", "eye-off")
      } else {
        cardNumber.textContent = "4810 00** **** 7840"
        icon.setAttribute("data-lucide", "eye")
      }
      lucide.createIcons()
    })
  }

  // Toggle balance visibility
  const toggleBalanceBtn = document.getElementById("toggle-balance")
  const availableBalance = document.getElementById("available-balance")
  const accountingBalance = document.getElementById("accounting-balance")

  if (toggleBalanceBtn && availableBalance && accountingBalance) {
    toggleBalanceBtn.addEventListener("click", () => {
      const icon = toggleBalanceBtn.querySelector("i")
      const text = toggleBalanceBtn.querySelector("span")

      if (availableBalance.textContent === "1250,00 €") {
        availableBalance.textContent = "****"
        accountingBalance.textContent = "****"
        icon.setAttribute("data-lucide", "eye")
        text.textContent = "Afficher solde"
      } else {
        availableBalance.textContent = "1250,00 €"
        accountingBalance.textContent = "1250,00 €"
        icon.setAttribute("data-lucide", "eye-off")
        text.textContent = "Masquer solde"
      }
      lucide.createIcons()
    })
  }

  // Activate card modal
  const activateCardBtn = document.getElementById("activate-card")
  const activateModal = document.getElementById("activate-modal")
  const closeActivateModalBtn = document.getElementById("close-activate-modal")
  const activateCardForm = document.getElementById("activate-card-form")
  const successModal = document.getElementById("success-modal")
  const closeSuccessModalBtn = document.getElementById("close-success-modal")
  const closeSuccessBtn = document.getElementById("close-success-btn")

  if (activateCardBtn && activateModal) {
    activateCardBtn.addEventListener("click", () => {
      activateModal.classList.add("active")
    })
  }

  if (closeActivateModalBtn && activateModal) {
    closeActivateModalBtn.addEventListener("click", () => {
      activateModal.classList.remove("active")
    })
  }

  if (activateCardForm && activateModal && successModal) {
    activateCardForm.addEventListener("submit", (e) => {
      e.preventDefault()
      activateModal.classList.remove("active")
      successModal.classList.add("active")
    })
  }

  if (closeSuccessModalBtn && successModal) {
    closeSuccessModalBtn.addEventListener("click", () => {
      successModal.classList.remove("active")
    })
  }

  if (closeSuccessBtn && successModal) {
    closeSuccessBtn.addEventListener("click", () => {
      successModal.classList.remove("active")
    })
  }
})
