// Main JavaScript file for FinancePro website

document.addEventListener("DOMContentLoaded", () => {

  // Smooth scrolling for anchor links
  const anchorLinks = document.querySelectorAll('a[href^="#"]')
  anchorLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      e.preventDefault()
      const targetId = this.getAttribute("href").substring(1)
      const targetElement = document.getElementById(targetId)

      if (targetElement) {
        targetElement.scrollIntoView({
          behavior: "smooth",
          block: "start",
        })
      }
    })
  })

  // Intersection Observer for animations
  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -50px 0px",
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible")
      }
    })
  }, observerOptions)

  // Observe elements with animation classes
  const animatedElements = document.querySelectorAll(".fade-in, .slide-in-left, .slide-in-right")
  animatedElements.forEach((el) => observer.observe(el))

  // Navbar background on scroll
  const navbar = document.querySelector(".navbar")
  let lastScrollTop = 0

  window.addEventListener("scroll", () => {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop

    if (scrollTop > 100) {
      navbar.classList.add("scrolled")
    } else {
      navbar.classList.remove("scrolled")
    }

    // Hide/show navbar on scroll
    if (scrollTop > lastScrollTop && scrollTop > 200) {
      navbar.style.transform = "translateY(-100%)"
    } else {
      navbar.style.transform = "translateY(0)"
    }

    lastScrollTop = scrollTop
  })

  // Add scrolled class styles
  const style = document.createElement("style")
  style.textContent = `
    .navbar {
      transition: all 0.3s ease;
    }
    .navbar.scrolled {
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(10px);
    }
  `
  document.head.appendChild(style)

  // Counter animation for stats
  const statNumbers = document.querySelectorAll(".stat-number")
  const statsObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const target = entry.target
          const finalValue = target.textContent
          const numericValue = Number.parseInt(finalValue.replace(/\D/g, ""))
          const suffix = finalValue.replace(/[\d,]/g, "")

          if (!isNaN(numericValue)) {
            animateCounter(target, 0, numericValue, suffix, 2000)
          }
          statsObserver.unobserve(target)
        }
      })
    },
    { threshold: 0.5 },
  )

  statNumbers.forEach((stat) => statsObserver.observe(stat))

  function animateCounter(element, start, end, suffix, duration) {
    const startTime = performance.now()
    const range = end - start

    function updateCounter(currentTime) {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      const current = Math.floor(start + range * progress)

      element.textContent = formatNumber(current) + suffix

      if (progress < 1) {
        requestAnimationFrame(updateCounter)
      }
    }

    requestAnimationFrame(updateCounter)
  }

  function formatNumber(num) {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(0) + "M"
    } else if (num >= 1000) {
      return (num / 1000).toFixed(0) + "K"
    }
    return num.toString()
  }

  // Form enhancements
  const forms = document.querySelectorAll("form")
  forms.forEach((form) => {
    // Add loading state to submit buttons
    form.addEventListener("submit", (e) => {
      const submitBtn = form.querySelector('button[type="submit"], input[type="submit"]')
      if (submitBtn) {
        submitBtn.disabled = true
        submitBtn.textContent = "Envoi en cours..."

        // Re-enable after 3 seconds (for demo purposes)
        setTimeout(() => {
          submitBtn.disabled = false
          submitBtn.textContent = submitBtn.dataset.originalText || "Envoyer"
        }, 3000)
      }
    })

    // Store original button text
    const submitBtn = form.querySelector('button[type="submit"], input[type="submit"]')
    if (submitBtn) {
      submitBtn.dataset.originalText = submitBtn.textContent
    }
  })

 

  // FAQ functionality
  const faqQuestions = document.querySelectorAll(".faq-question")
  faqQuestions.forEach((question) => {
    question.addEventListener("click", function () {
      const faqItem = this.parentElement
      const answer = faqItem.querySelector(".faq-answer")
      const toggle = this.querySelector(".faq-toggle")

      // Close other FAQ items
      faqQuestions.forEach((otherQuestion) => {
        if (otherQuestion !== question) {
          const otherItem = otherQuestion.parentElement
          const otherAnswer = otherItem.querySelector(".faq-answer")
          const otherToggle = otherQuestion.querySelector(".faq-toggle")
          otherAnswer.style.maxHeight = "0"
          otherToggle.textContent = "+"
        }
      })

      // Toggle current FAQ item
      if (answer.style.maxHeight === "0px" || !answer.style.maxHeight) {
        answer.style.maxHeight = answer.scrollHeight + "px"
        toggle.textContent = "−"
      } else {
        answer.style.maxHeight = "0"
        toggle.textContent = "+"
      }
    })
  })

  // Blog filters
  const filterBtns = document.querySelectorAll(".filter-btn")
  const blogCards = document.querySelectorAll(".blog-card")

  filterBtns.forEach((btn) => {
    btn.addEventListener("click", function () {
      const filter = this.getAttribute("data-filter")

      // Update active filter button
      filterBtns.forEach((b) => b.classList.remove("active"))
      this.classList.add("active")

      // Filter blog cards
      blogCards.forEach((card) => {
        const category = card.getAttribute("data-category")
        if (filter === "all" || category === filter) {
          card.style.display = "block"
        } else {
          card.style.display = "none"
        }
      })
    })
  })

  // Search functionality
  const searchInput = document.querySelector(".search-input")
  const searchBtn = document.querySelector(".search-btn")

  if (searchInput && searchBtn) {
    function performSearch() {
      const searchTerm = searchInput.value.toLowerCase()
      blogCards.forEach((card) => {
        const title = card.querySelector("h3").textContent.toLowerCase()
        const content = card.querySelector("p").textContent.toLowerCase()
        if (title.includes(searchTerm) || content.includes(searchTerm) || searchTerm === "") {
          card.style.display = "block"
        } else {
          card.style.display = "none"
        }
      })
    }

    searchBtn.addEventListener("click", performSearch)
    searchInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter") {
        performSearch()
      }
    })
  }

  // Lazy loading for images
  const images = document.querySelectorAll("img[data-src]")
  const imageObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const img = entry.target
          img.src = img.dataset.src
          img.classList.remove("lazy")
          imageObserver.unobserve(img)
        }
      })
    },
    { rootMargin: "50px" },
  )

  images.forEach((img) => imageObserver.observe(img))

  // Newsletter form submission
  const newsletterForms = document.querySelectorAll(".newsletter-form")
  newsletterForms.forEach((form) => {
    form.addEventListener("submit", function (e) {
      e.preventDefault()
      const email = this.querySelector('input[type="email"]').value
      if (email) {
        // Simulate newsletter subscription
        alert("Merci pour votre inscription à notre newsletter !")
        this.reset()
      }
    })
  })

  // Contact form submission
  const contactForm = document.querySelector(".contact-form")
  if (contactForm) {
    contactForm.addEventListener("submit", function (e) {
      e.preventDefault()
      // Simulate form submission
      alert("Votre message a été envoyé avec succès !")
      this.reset()
    })
  }

  // Parallax effect for hero section
  const hero = document.querySelector(".hero")
  if (hero) {
    window.addEventListener("scroll", () => {
      const scrolled = window.pageYOffset
      const rate = scrolled * -0.5
      hero.style.transform = `translateY(${rate}px)`
    })
  }

  // Add loading animation
  window.addEventListener("load", () => {
    document.body.classList.add("loaded")
  })

  // Add loaded class styles
  const loadingStyle = document.createElement("style")
  loadingStyle.textContent = `
    body {
      opacity: 0;
      transition: opacity 0.5s ease;
    }
    body.loaded {
      opacity: 1;
    }
  `
  document.head.appendChild(loadingStyle)

  // Back to top button
  const backToTopBtn = document.createElement("button")
  backToTopBtn.innerHTML = "↑"
  backToTopBtn.className = "back-to-top"
  backToTopBtn.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background: #1e3a8a;
        color: white;
        border: none;
        font-size: 20px;
        cursor: pointer;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
        z-index: 1000;
    `

  document.body.appendChild(backToTopBtn)

  window.addEventListener("scroll", () => {
    if (window.scrollY > 500) {
      backToTopBtn.style.opacity = "1"
      backToTopBtn.style.visibility = "visible"
    } else {
      backToTopBtn.style.opacity = "0"
      backToTopBtn.style.visibility = "hidden"
    }
  })

  backToTopBtn.addEventListener("click", () => {
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    })
  })

  // Cookie consent (basic implementation)
  const cookieConsent = localStorage.getItem("cookieConsent")
  if (!cookieConsent) {
    const cookieBanner = document.createElement("div")
    cookieBanner.innerHTML = `
            <div style="position: fixed; bottom: 0; left: 0; right: 0; background: #1f2937; color: white; padding: 1rem; z-index: 10000; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                <p style="margin: 0; flex: 1; min-width: 200px;">Ce site utilise des cookies pour améliorer votre expérience. En continuant à naviguer, vous acceptez notre utilisation des cookies.</p>
                <div style="display: flex; gap: 1rem;">
                    <button onclick="acceptCookies()" style="background: #fbbf24; color: #1e3a8a; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">Accepter</button>
                    <button onclick="declineCookies()" style="background: transparent; color: white; border: 1px solid white; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">Refuser</button>
                </div>
            </div>
        `
    document.body.appendChild(cookieBanner)

    window.acceptCookies = () => {
      localStorage.setItem("cookieConsent", "accepted")
      cookieBanner.remove()
    }

    window.declineCookies = () => {
      localStorage.setItem("cookieConsent", "declined")
      cookieBanner.remove()
    }
  }
})

// Utility functions
function debounce(func, wait) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

function throttle(func, limit) {
  let inThrottle
  return function () {
    const args = arguments

    if (!inThrottle) {
      func.apply(this, args)
      inThrottle = true
      setTimeout(() => (inThrottle = false), limit)
    }
  }
}

// Export for use in other scripts
window.FinanceProUtils = {
  debounce,
  throttle,
}
