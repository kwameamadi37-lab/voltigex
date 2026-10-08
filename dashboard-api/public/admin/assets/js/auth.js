document.addEventListener("DOMContentLoaded", () => {
  // Login form functionality
  const loginForm = document.getElementById("loginForm");
  if (loginForm) {
    loginForm.addEventListener("submit", async (e) => {
      const code = document.getElementById("code").value;
      const password = document.getElementById("password").value;
      const submitBtn = loginForm.querySelector('button[type="submit"]');

      // Validation
      if (!code || !password) {
        e.preventDefault();
        alert("Veuillez remplir tous les champs");
        return;
      }

      // Désactiver le bouton pendant le traitement
      submitBtn.textContent = "Connexion en cours...";
      submitBtn.disabled = true;

      // Si vous voulez gérer la réponse du serveur
      try {
        const response = await fetch(loginForm.action, {
          method: 'POST',
          body: new FormData(loginForm),
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
          }
        });

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.message || 'Erreur de connexion');
        }

        // Si succès, le serveur redirigera automatiquement
      } catch (error) {
        e.preventDefault();
        alert(error.message);
        submitBtn.textContent = "Se connecter";
        submitBtn.disabled = false;
      }
    });
  }

  // Register form functionality
  const registerForm = document.getElementById("registerForm")
  if (registerForm) {
    registerForm.addEventListener("submit", (e) => {
      e.preventDefault()

      // Simple validation
      const requiredFields = ["firstName", "lastName", "birthdate", "email", "phone", "password"]
      let isValid = true

      requiredFields.forEach((field) => {
        const input = document.getElementById(field)
        if (!input.value) {
          isValid = false
        }
      })

      if (!isValid) {
        alert("Veuillez remplir tous les champs obligatoires")
        return
      }

      // Check if ID files are uploaded
      const idFront = document.getElementById("idFront")
      const idBack = document.getElementById("idBack")

      if (!idFront.files.length || !idBack.files.length) {
        alert("Veuillez télécharger les deux côtés de votre carte d'identité")
        return
      }

      // Simulate registration process
      registerForm.querySelector('button[type="submit"]').textContent = "Inscription en cours..."
      registerForm.querySelector('button[type="submit"]').disabled = true

      setTimeout(() => {
        window.location.href = "dashboard.html"
      }, 1500)
    })

    // File upload preview
    const idFront = document.getElementById("idFront")
    const idBack = document.getElementById("idBack")
    const idFrontLabel = document.getElementById("idFrontLabel")
    const idBackLabel = document.getElementById("idBackLabel")

    idFront.addEventListener("change", function () {
      if (this.files.length) {
        idFrontLabel.textContent = this.files[0].name
      } else {
        idFrontLabel.textContent = "Télécharger"
      }
    })

    idBack.addEventListener("change", function () {
      if (this.files.length) {
        idBackLabel.textContent = this.files[0].name
      } else {
        idBackLabel.textContent = "Télécharger"
      }
    })
  }

  // Password toggle functionality
  const togglePassword = document.getElementById("togglePassword")
  if (togglePassword) {
    togglePassword.addEventListener("click", function () {
      const password = document.getElementById("password")
      const icon = this.querySelector("i")

      if (password.type === "password") {
        password.type = "text"
        icon.classList.remove("fa-eye")
        icon.classList.add("fa-eye-slash")
      } else {
        password.type = "password"
        icon.classList.remove("fa-eye-slash")
        icon.classList.add("fa-eye")
      }
    })
  }
})
