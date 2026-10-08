document.addEventListener("DOMContentLoaded", () => {
  // Initialize Lucide icons
  if (typeof lucide !== "undefined") {
    lucide.createIcons()
  }

  const chatForm = document.getElementById("chat-form")
  const messageInput = document.getElementById("message-input")
  const chatMessages = document.getElementById("chat-messages")

  if (chatForm && messageInput && chatMessages) {
    chatForm.addEventListener("submit", (e) => {
      e.preventDefault()

      const message = messageInput.value.trim()
      if (message === "") return

      // Add user message
      addMessage(message, "user")
      messageInput.value = ""

      // Scroll to bottom
      scrollToBottom()

      // Simulate agent response after 1 second
      setTimeout(() => {
        addMessage(
          "Merci pour votre message. Un conseiller va examiner votre demande et vous répondra dans les plus brefs délais.",
          "agent",
        )
        scrollToBottom()
      }, 1000)
    })

    // Also allow sending with Enter key
    messageInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter") {
        e.preventDefault()
        chatForm.dispatchEvent(new Event("submit"))
      }
    })
  }

  function addMessage(text, sender) {
    const time = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

    const messageDiv = document.createElement("div")
    messageDiv.className = `message ${sender}`

    const contentDiv = document.createElement("div")
    contentDiv.className = "message-content"

    const textP = document.createElement("p")
    textP.textContent = text

    const timeSpan = document.createElement("span")
    timeSpan.className = "message-time"
    timeSpan.textContent = time

    contentDiv.appendChild(textP)
    contentDiv.appendChild(timeSpan)
    messageDiv.appendChild(contentDiv)

    chatMessages.appendChild(messageDiv)
  }

  function scrollToBottom() {
    chatMessages.scrollTop = chatMessages.scrollHeight
  }
})
