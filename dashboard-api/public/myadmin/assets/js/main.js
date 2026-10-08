document.addEventListener("DOMContentLoaded", () => {
  // Initialize Lucide icons
  const lucide = window.lucide
  lucide.createIcons()

  // Sidebar toggle
  const sidebarToggle = document.getElementById("sidebar-toggle")
  const sidebar = document.getElementById("sidebar")
  const mainContent = document.querySelector(".main-content")

  if (sidebarToggle && sidebar) {
    sidebarToggle.addEventListener("click", () => {
      sidebar.classList.toggle("collapsed")
      if (mainContent) {
        if (sidebar.classList.contains("collapsed")) {
          mainContent.style.marginLeft = "5rem"
        } else {
          mainContent.style.marginLeft = "16rem"
        }
      }
    })
  }

  // Notification dropdown
  const notificationBtn = document.getElementById("notification-btn")
  const notificationDropdown = document.getElementById("notification-dropdown")

  if (notificationBtn && notificationDropdown) {
    notificationBtn.addEventListener("click", (e) => {
      e.stopPropagation()
      notificationDropdown.classList.toggle("active")
    })

    document.addEventListener("click", (e) => {
      if (!notificationDropdown.contains(e.target) && e.target !== notificationBtn) {
        notificationDropdown.classList.remove("active")
      }
    })
  }

  // Check if we're on desktop
  function isDesktop() {
    return window.innerWidth >= 768
  }

  // Initialize sidebar based on screen size
  function initSidebar() {
    if (sidebar) {
      if (isDesktop()) {
        sidebar.style.display = "block"
        if (sidebar.classList.contains("collapsed")) {
          mainContent.style.marginLeft = "5rem"
        } else {
          mainContent.style.marginLeft = "16rem"
        }
      } else {
        sidebar.style.display = "none"
        mainContent.style.marginLeft = "0"
      }
    }
  }

  // Call on load
  initSidebar()

  // Call on resize
  window.addEventListener("resize", initSidebar)
})
