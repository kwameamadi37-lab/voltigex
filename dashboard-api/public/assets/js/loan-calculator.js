// Loan Calculator JavaScript

document.addEventListener("DOMContentLoaded", () => {
  const loanAmountSlider = document.getElementById("loan-amount")
  const loanDurationSlider = document.getElementById("loan-duration")
  const interestRateSlider = document.getElementById("interest-rate-slider")

  const loanAmountValue = document.getElementById("loan-amount-value")
  const loanDurationValue = document.getElementById("loan-duration-value")
  const interestRateValue = document.getElementById("interest-rate-value")

  const monthlyPaymentDisplay = document.getElementById("monthly-payment")
  const totalCostDisplay = document.getElementById("total-cost")
  const interestRateDisplay = document.getElementById("interest-rate")

  if (!loanAmountSlider || !loanDurationSlider || !interestRateSlider || !monthlyPaymentDisplay || !totalCostDisplay) {
    return // Exit if calculator elements don't exist on this page
  }

  // Initialize calculator
  updateCalculator()

  // Add event listeners
  loanAmountSlider.addEventListener("input", () => {
    updateCalculator()
  })

  loanDurationSlider.addEventListener("input", () => {
    updateCalculator()
  })

  interestRateSlider.addEventListener("input", () => {
    updateCalculator()
  })

  function updateLoanAmountDisplay() {
    const amount = Number.parseInt(loanAmountSlider.value)
    loanAmountValue.textContent = formatCurrency(amount)
  }

  function updateLoanDurationDisplay() {
    const duration = Number.parseInt(loanDurationSlider.value)
    loanDurationValue.textContent = duration + " mois"
  }

  function updateInterestRateDisplay() {
    const rate = Number.parseFloat(interestRateSlider.value) / 10
    interestRateValue.textContent = rate.toFixed(1) + "%"
  }

  // Update slider values and calculate loan
  function updateCalculator() {
    const loanAmount = Number.parseFloat(loanAmountSlider.value)
    const loanDuration = Number.parseInt(loanDurationSlider.value)
    const interestRate = Number.parseFloat(interestRateSlider.value) / 10 // Convert to percentage

    // Update display values
    loanAmountValue.textContent = formatCurrency(loanAmount)
    loanDurationValue.textContent = `${loanDuration} mois`
    interestRateValue.textContent = `${interestRate.toFixed(1)}%`

    // Calculate monthly payment using loan formula
    const monthlyRate = interestRate / 100 / 12
    const monthlyPayment =
      monthlyRate === 0
        ? loanAmount / loanDuration
        : (loanAmount * monthlyRate * Math.pow(1 + monthlyRate, loanDuration)) /
          (Math.pow(1 + monthlyRate, loanDuration) - 1)

    const totalCost = monthlyPayment * loanDuration
    const totalInterest = totalCost - loanAmount

    // Update results display
    monthlyPaymentDisplay.textContent = formatCurrency(monthlyPayment)
    totalCostDisplay.textContent = formatCurrency(totalCost)
    interestRateDisplay.textContent = `${interestRate.toFixed(1)}%`

    // Update progress bars or visual indicators if they exist
    updateLoanVisualization(loanAmount, totalInterest, monthlyPayment)
  }

  function formatCurrency(amount) {
    return new Intl.NumberFormat("fr-FR", {
      style: "currency",
      currency: "EUR",
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount)
  }

  // Update loan visualization (charts, progress bars, etc.)
  function updateLoanVisualization(principal, interest, monthlyPayment) {
    // Create or update a simple visual representation
    const visualContainer = document.querySelector(".loan-visualization")
    if (visualContainer) {
      const principalPercentage = (principal / (principal + interest)) * 100
      const interestPercentage = (interest / (principal + interest)) * 100

      visualContainer.innerHTML = `
        <div class="loan-breakdown">
          <h4>Répartition du coût total</h4>
          <div class="breakdown-bar">
            <div class="principal-bar" style="width: ${principalPercentage}%">
              <span>Capital: ${principalPercentage.toFixed(1)}%</span>
            </div>
            <div class="interest-bar" style="width: ${interestPercentage}%">
              <span>Intérêts: ${interestPercentage.toFixed(1)}%</span>
            </div>
          </div>
        </div>
      `
    }
  }

  // Advanced calculator features
  function calculateTotalInterest() {
    const principal = Number.parseFloat(loanAmountSlider.value)
    const totalCost = Number.parseFloat(totalCostDisplay.textContent.replace(/[^\d.-]/g, ""))
    return totalCost - principal
  }

  function calculateAPR() {
    // This is a simplified APR calculation
    // In reality, APR would include additional fees and costs
    const annualRate = Number.parseFloat(interestRateSlider.value) / 10
    return annualRate // Simplified - would normally include fees
  }

  // Export calculator functions for external use
  window.LoanCalculator = {
    updateCalculator,
    calculateTotalInterest,
    calculateAPR,
    formatCurrency,
  }

  // Add comparison feature
  function createComparisonTable() {
    const currentAmount = Number.parseFloat(loanAmountSlider.value)
    const currentDuration = Number.parseInt(loanDurationSlider.value)
    const currentRate = Number.parseFloat(interestRateSlider.value) / 10

    const comparisons = [
      { rate: currentRate - 0.5, label: "Taux -0.5%" },
      { rate: currentRate, label: "Taux actuel" },
      { rate: currentRate + 0.5, label: "Taux +0.5%" },
    ]

    const table = document.createElement("div")
    table.className = "comparison-table"
    table.innerHTML = "<h4>Comparaison des taux</h4>"

    comparisons.forEach((comp) => {
      const monthlyRate = comp.rate / 100 / 12
      let monthlyPayment = 0

      if (monthlyRate > 0) {
        monthlyPayment =
          (currentAmount * (monthlyRate * Math.pow(1 + monthlyRate, currentDuration))) /
          (Math.pow(1 + monthlyRate, currentDuration) - 1)
      } else {
        monthlyPayment = currentAmount / currentDuration
      }

      const row = document.createElement("div")
      row.className = "comparison-row"
      row.innerHTML = `
                <span>${comp.label}</span>
                <span>${formatCurrency(monthlyPayment)}/mois</span>
            `
      table.appendChild(row)
    })

    return table
  }

  // Add event listener for comparison toggle
  const showComparison = document.getElementById("show-comparison")
  if (showComparison) {
    showComparison.addEventListener("click", function () {
      const existingTable = document.querySelector(".comparison-table")
      if (existingTable) {
        existingTable.remove()
      } else {
        const table = createComparisonTable()
        this.parentNode.appendChild(table)
      }
    })
  }

  // Loan affordability calculator
  function calculateAffordability(monthlyIncome, existingDebts = 0) {
    const debtToIncomeRatio = 0.36 // 36% max debt-to-income ratio
    const maxMonthlyPayment = monthlyIncome * debtToIncomeRatio - existingDebts
    return Math.max(0, maxMonthlyPayment)
  }

  // Add affordability check
  const incomeInput = document.getElementById("monthly-income")
  const debtsInput = document.getElementById("existing-debts")
  const affordabilityResult = document.getElementById("affordability-result")

  if (incomeInput && affordabilityResult) {
    function updateAffordability() {
      const income = Number.parseFloat(incomeInput.value) || 0
      const debts = Number.parseFloat(debtsInput?.value) || 0
      const maxPayment = calculateAffordability(income, debts)
      const currentPayment = Number.parseFloat(monthlyPaymentDisplay.textContent.replace(/[^\d.-]/g, ""))

      if (maxPayment > 0) {
        const isAffordable = currentPayment <= maxPayment
        affordabilityResult.innerHTML = `
                    <div class="affordability-status ${isAffordable ? "affordable" : "not-affordable"}">
                        <strong>Capacité d'emprunt:</strong> ${formatCurrency(maxPayment)}/mois<br>
                        <strong>Statut:</strong> ${isAffordable ? "✅ Abordable" : "❌ Non abordable"}
                    </div>
                `
      }
    }

    incomeInput.addEventListener("input", updateAffordability)
    if (debtsInput) {
      debtsInput.addEventListener("input", updateAffordability)
    }
  }

  // Save calculation to localStorage
  function saveCalculation() {
    const calculation = {
      amount: loanAmountSlider.value,
      duration: loanDurationSlider.value,
      rate: interestRateSlider.value,
      monthlyPayment: monthlyPaymentDisplay.textContent,
      totalCost: totalCostDisplay.textContent,
      timestamp: new Date().toISOString(),
    }

    let savedCalculations = JSON.parse(localStorage.getItem("loanCalculations") || "[]")
    savedCalculations.unshift(calculation)
    savedCalculations = savedCalculations.slice(0, 5) // Keep only last 5 calculations
    localStorage.setItem("loanCalculations", JSON.stringify(savedCalculations))
  }

  // Load saved calculations
  function loadSavedCalculations() {
    const saved = JSON.parse(localStorage.getItem("loanCalculations") || "[]")
    const container = document.getElementById("saved-calculations")

    if (container && saved.length > 0) {
      container.innerHTML = "<h4>Calculs récents</h4>"
      saved.forEach((calc, index) => {
        const item = document.createElement("div")
        item.className = "saved-calculation"
        item.innerHTML = `
                    <div class="calc-summary">
                        ${formatCurrency(calc.amount)} sur ${calc.duration} mois
                        <span class="calc-payment">${calc.monthlyPayment}/mois</span>
                    </div>
                    <button onclick="loadCalculation(${index})" class="btn-small">Charger</button>
                `
        container.appendChild(item)
      })
    }
  }

  // Load specific calculation
  window.loadCalculation = (index) => {
    const saved = JSON.parse(localStorage.getItem("loanCalculations") || "[]")
    if (saved[index]) {
      const calc = saved[index]
      loanAmountSlider.value = calc.amount
      loanDurationSlider.value = calc.duration
      interestRateSlider.value = calc.rate
      updateCalculator()
    }
  }

  // Add save button functionality
  const saveButton = document.getElementById("save-calculation")
  if (saveButton) {
    saveButton.addEventListener("click", () => {
      saveCalculation()
      loadSavedCalculations()

      // Show confirmation
      const confirmation = document.createElement("div")
      confirmation.className = "save-confirmation"
      confirmation.textContent = "Calcul sauvegardé !"
      confirmation.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #22c55e;
                color: white;
                padding: 1rem;
                border-radius: 8px;
                z-index: 10000;
                animation: slideIn 0.3s ease;
            `
      document.body.appendChild(confirmation)

      setTimeout(() => {
        confirmation.remove()
      }, 3000)
    })
  }

  // Initialize saved calculations on page load
  loadSavedCalculations()

  // Print calculation functionality
  const printButton = document.getElementById("print-calculation")
  if (printButton) {
    printButton.addEventListener("click", () => {
      const printWindow = window.open("", "_blank")
      const calculation = {
        amount: loanAmountSlider.value,
        duration: loanDurationSlider.value,
        rate: (Number.parseFloat(interestRateSlider.value) / 10).toFixed(1),
        monthlyPayment: monthlyPaymentDisplay.textContent,
        totalCost: totalCostDisplay.textContent,
      }

      printWindow.document.write(`
                <html>
                <head>
                    <title>Simulation de prêt - FinancePro</title>
                    <style>
                        body { font-family: Arial, sans-serif; padding: 20px; }
                        .header { text-align: center; margin-bottom: 30px; }
                        .calculation-details { background: #f5f5f5; padding: 20px; border-radius: 8px; }
                        .detail-row { display: flex; justify-content: space-between; margin-bottom: 10px; }
                        .detail-label { font-weight: bold; }
                        .footer { margin-top: 30px; text-align: center; font-size: 12px; color: #666; }
                    </style>
                </head>
                <body>
                    <div class="header">
                        <h1>FinancePro</h1>
                        <h2>Simulation de prêt professionnel</h2>
                        <p>Date: ${new Date().toLocaleDateString("fr-FR")}</p>
                    </div>
                    <div class="calculation-details">
                        <div class="detail-row">
                            <span class="detail-label">Montant emprunté:</span>
                            <span>${formatCurrency(calculation.amount)}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Durée:</span>
                            <span>${calculation.duration} mois</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Taux d'intérêt:</span>
                            <span>${calculation.rate}%</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Mensualité:</span>
                            <span><strong>${calculation.monthlyPayment}</strong></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Coût total:</span>
                            <span><strong>${calculation.totalCost}</strong></span>
                        </div>
                    </div>
                    <div class="footer">
                        <p>Cette simulation est donnée à titre indicatif. Les conditions réelles peuvent varier selon votre profil.</p>
                        <p>FinancePro - Solutions de financement professionnel</p>
                    </div>
                </body>
                </html>
            `)
      printWindow.document.close()
      printWindow.print()
    })
  }

  // Add custom styling for the visualization
  const style = document.createElement("style")
  style.textContent = `
    .loan-visualization {
      margin-top: 2rem;
      padding: 1rem;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 12px;
    }
    
    .loan-breakdown h4 {
      color: white;
      margin-bottom: 1rem;
      font-size: 1rem;
    }
    
    .breakdown-bar {
      display: flex;
      height: 30px;
      border-radius: 15px;
      overflow: hidden;
      background: rgba(255, 255, 255, 0.1);
    }
    
    .principal-bar {
      background: #22c55e;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 12px;
      font-weight: 600;
    }
    
    .interest-bar {
      background: #ef4444;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 12px;
      font-weight: 600;
    }
  `
  document.head.appendChild(style)

  // Advanced calculator features
  const calculatorContainer = document.querySelector(".calculator-container")
  if (calculatorContainer) {
    // Add loan comparison feature
    const comparisonButton = document.createElement("button")
    comparisonButton.textContent = "Comparer les options"
    comparisonButton.className = "btn btn-primary rounded-md"
    comparisonButton.style.marginTop = "1rem"

    comparisonButton.addEventListener("click", () => {
      showLoanComparison()
    })

    const resultsSection = document.querySelector(".calculator-results")
    if (resultsSection) {
      resultsSection.appendChild(comparisonButton)
    }
  }

  // Show loan comparison modal or section
  function showLoanComparison() {
    const currentAmount = Number.parseFloat(loanAmountSlider.value)
    const currentDuration = Number.parseInt(loanDurationSlider.value)
    const currentRate = Number.parseFloat(interestRateSlider.value) / 10

    // Create comparison scenarios
    const scenarios = [
      {
        name: "Option actuelle",
        amount: currentAmount,
        duration: currentDuration,
        rate: currentRate,
      },
      {
        name: "Durée plus courte",
        amount: currentAmount,
        duration: Math.max(12, currentDuration - 12),
        rate: currentRate,
      },
      {
        name: "Durée plus longue",
        amount: currentAmount,
        duration: Math.min(120, currentDuration + 12),
        rate: currentRate,
      },
    ]

    let comparisonHTML = `
      <div class="loan-comparison-modal">
        <div class="modal-content">
          <div class="modal-header">
            <h3>Comparaison des options de financement</h3>
            <button class="close-modal">&times;</button>
          </div>
          <div class="comparison-table">
            <table>
              <thead>
                <tr>
                  <th>Option</th>
                  <th>Mensualité</th>
                  <th>Coût total</th>
                  <th>Intérêts</th>
                </tr>
              </thead>
              <tbody>
    `

    scenarios.forEach((scenario) => {
      const monthlyRate = scenario.rate / 100 / 12
      const monthlyPayment =
        monthlyRate === 0
          ? scenario.amount / scenario.duration
          : (scenario.amount * monthlyRate * Math.pow(1 + monthlyRate, scenario.duration)) /
            (Math.pow(1 + monthlyRate, scenario.duration) - 1)
      const totalCost = monthlyPayment * scenario.duration
      const totalInterest = totalCost - scenario.amount

      comparisonHTML += `
        <tr>
          <td><strong>${scenario.name}</strong><br>
              <small>${scenario.duration} mois à ${scenario.rate.toFixed(1)}%</small></td>
          <td>${formatCurrency(monthlyPayment)}</td>
          <td>${formatCurrency(totalCost)}</td>
          <td>${formatCurrency(totalInterest)}</td>
        </tr>
      `
    })

    comparisonHTML += `
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `

    // Add modal to page
    const modalContainer = document.createElement("div")
    modalContainer.innerHTML = comparisonHTML
    document.body.appendChild(modalContainer)

    // Add modal styles
    const modalStyle = document.createElement("style")
    modalStyle.textContent = `
      .loan-comparison-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
      }
      
      .modal-content {
        background: white;
        border-radius: 16px;
        max-width: 800px;
        width: 90%;
        max-height: 90%;
        overflow-y: auto;
      }
      
      .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 1.5rem;
        border-bottom: 1px solid #e5e7eb;
      }
      
      .close-modal {
        background: none;
        border: none;
        font-size: 2rem;
        cursor: pointer;
        color: #666;
      }
      
      .comparison-table {
        padding: 1.5rem;
      }
      
      .comparison-table table {
        width: 100%;
        border-collapse: collapse;
      }
      
      .comparison-table th,
      .comparison-table td {
        padding: 1rem;
        text-align: left;
        border-bottom: 1px solid #e5e7eb;
      }
      
      .comparison-table th {
        background: #f9fafb;
        font-weight: 600;
      }
    `
    document.head.appendChild(modalStyle)

    // Close modal functionality
    const closeModal = modalContainer.querySelector(".close-modal")
    closeModal.addEventListener("click", () => {
      document.body.removeChild(modalContainer)
      document.head.removeChild(modalStyle)
    })

    // Close on outside click
    modalContainer.addEventListener("click", (e) => {
      if (e.target === modalContainer) {
        document.body.removeChild(modalContainer)
        document.head.removeChild(modalStyle)
      }
    })
  }

  // Add amortization schedule feature
  function generateAmortizationSchedule() {
    const loanAmount = Number.parseFloat(loanAmountSlider.value)
    const loanDuration = Number.parseInt(loanDurationSlider.value)
    const interestRate = Number.parseFloat(interestRateSlider.value) / 10

    const monthlyRate = interestRate / 100 / 12
    const monthlyPayment =
      monthlyRate === 0
        ? loanAmount / loanDuration
        : (loanAmount * monthlyRate * Math.pow(1 + monthlyRate, loanDuration)) /
          (Math.pow(1 + monthlyRate, loanDuration) - 1)

    let balance = loanAmount
    const schedule = []

    for (let month = 1; month <= loanDuration; month++) {
      const interestPayment = balance * monthlyRate
      const principalPayment = monthlyPayment - interestPayment
      balance -= principalPayment

      schedule.push({
        month,
        payment: monthlyPayment,
        principal: principalPayment,
        interest: interestPayment,
        balance: Math.max(0, balance),
      })
    }

    return schedule
  }

  // Export calculator data
  // function exportCalculatorData() {
  //   const data = {
  //     loanAmount: Number.parseFloat(loanAmountSlider.value),
  //     loanDuration: Number.parseInt(loanDurationSlider.value),
  //     interestRate: Number.parseFloat(interestRateSlider.value) / 10,
  //     monthlyPayment: Number.parseFloat(monthlyPaymentDisplay.textContent.replace(/[^\d,.-]/g, "").replace(",", ".")),
  //     totalCost: Number.parseFloat(totalCostDisplay.textContent.replace(/[^\d,.-]/g, "").replace(",", ".")),
  //     schedule: generateAmortizationSchedule(),
  //   }

  //   const dataStr = JSON.stringify(data, null, 2)
  //   const dataBlob = new Blob([dataStr], { type: "application/json" })
  //   const url = URL.createObjectURL(dataBlob)
  //   const link = document.createElement("a")
  //   link.href = url
  //   link.download = "simulation-pret.json"
  //   link.click()
  //   URL.revokeObjectURL(url)
  // }

  // // Add export button if needed
  // const exportButton = document.createElement("button")
  // exportButton.textContent = "Exporter la simulation"
  // exportButton.className = "btn btn-outline"
  // exportButton.style.marginTop = "0.5rem"
  // exportButton.addEventListener("click", exportCalculatorData)

  // const resultsSection = document.querySelector(".calculator-results")
  // if (resultsSection) {
  //   resultsSection.appendChild(exportButton)
  // }
})
