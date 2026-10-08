        // Mobile menu toggle
        document.addEventListener('DOMContentLoaded', function() {
            const mobileMenuButton = document.getElementById('mobile-menu-button');
            const mobileMenu = document.getElementById('mobile-menu');

            if (mobileMenuButton && mobileMenu) {
                mobileMenuButton.addEventListener('click', function() {
                    mobileMenu.classList.toggle('hidden');
                    // Toggle hamburger animation
                    const spans = mobileMenuButton.querySelectorAll('span');
                    spans.forEach((span, index) => {
                        if (mobileMenu.classList.contains('hidden')) {
                            span.style.transform = 'rotate(0deg)';
                            span.style.marginBottom = index < 2 ? '4px' : '0';
                        } else {
                            if (index === 0) span.style.transform = 'rotate(45deg) translate(5px, 5px)';
                            if (index === 1) span.style.opacity = '0';
                            if (index === 2) span.style.transform = 'rotate(-45deg) translate(7px, -6px)';
                            span.style.marginBottom = '0';
                        }
                    });
                });

                // Close mobile menu when clicking on a link
                const mobileLinks = mobileMenu.querySelectorAll('a');
                mobileLinks.forEach(link => {
                    link.addEventListener('click', () => {
                        mobileMenu.classList.add('hidden');
                        const spans = mobileMenuButton.querySelectorAll('span');
                        spans.forEach((span, index) => {
                            span.style.transform = 'rotate(0deg)';
                            span.style.opacity = '1';
                            span.style.marginBottom = index < 2 ? '4px' : '0';
                        });
                    });
                });
            }

            // Rest of the existing JavaScript code...
            // (keep all the existing code for tabs, FAQ, testimonials, calculator, etc.)

                    // Tabs functionality
                    const tabBtns = document.querySelectorAll('.tab-btn');
                    const tabContents = document.querySelectorAll('.tab-content');

                    tabBtns.forEach(btn => {
                        btn.addEventListener('click', () => {
                            const targetTab = btn.getAttribute('data-tab');
                            
                            // Remove active class from all buttons and contents
                            tabBtns.forEach(b => b.classList.remove('active', 'bg-primary', 'text-white'));
                            tabContents.forEach(c => c.classList.add('hidden'));
                            
                            // Add active class to clicked button and show corresponding content
                            btn.classList.add('active', 'bg-primary', 'text-white');
                            document.getElementById(targetTab).classList.remove('hidden');
                        });
                    });

                    // FAQ functionality
                    const faqQuestions = document.querySelectorAll('.faq-question');
                    
                    question.addEventListener('click', () => {
                        const faqItem = question.parentElement;
                        const answer = faqItem.querySelector('.faq-answer');
                        const toggle = question.querySelector('.faq-toggle');
                
                        const isOpen = answer.style.maxHeight && answer.style.maxHeight !== '0px';
                
                        // Ferme toutes les réponses
                        document.querySelectorAll('.faq-answer').forEach(a => {
                            a.style.maxHeight = '0px';
                        });
                        document.querySelectorAll('.faq-toggle').forEach(t => {
                            t.textContent = '+';
                        });
                
                        // Ouvre si ce n'était pas déjà ouvert
                        if (!isOpen) {
                            answer.style.maxHeight = answer.scrollHeight + 'px';
                            toggle.textContent = '−';
                        }
                    });

                    const testimonials = document.querySelectorAll('.testimonial');
                    const testimonialDots = document.querySelectorAll('.testimonial-dot');
                    let currentTestimonial = 0;

                    // Fonction pour afficher le témoignage selon l’index
                    function showTestimonial(index) {
                        testimonials.forEach((t, i) => {
                            if(i === index) {
                                t.classList.remove('hidden');
                            } else {
                                t.classList.add('hidden');
                            }
                        });

                        testimonialDots.forEach((d, i) => {
                            if(i === index) {
                                d.classList.add('bg-primary', 'w-6');
                                d.classList.remove('bg-gray-300');
                            } else {
                                d.classList.remove('bg-primary', 'w-6');
                                d.classList.add('bg-gray-300');
                            }
                        });
                    }

                    // Ajout des écouteurs sur les points (dots)
                    testimonialDots.forEach((dot, index) => {
                        dot.addEventListener('click', () => {
                            currentTestimonial = index;
                            showTestimonial(index);
                            resetAutoRotate();  // On reset l’auto-rotation au clic utilisateur
                        });
                    });

                    // Auto-rotation avec gestion du timer pour reset si besoin
                    let autoRotate = setInterval(() => {
                        currentTestimonial = (currentTestimonial + 1) % testimonials.length;
                        showTestimonial(currentTestimonial);
                    }, 5000);

                    function resetAutoRotate() {
                        clearInterval(autoRotate);
                        autoRotate = setInterval(() => {
                            currentTestimonial = (currentTestimonial + 1) % testimonials.length;
                            showTestimonial(currentTestimonial);
                        }, 5000);
                    }

                    // Initialisation au chargement
                    showTestimonial(currentTestimonial);

                    // Loan calculator
                    const loanAmountSlider = document.getElementById('loan-amount');
                    const loanDurationSlider = document.getElementById('loan-duration');
                    const interestRateSlider = document.getElementById('interest-rate-slider');
                    
                    const loanAmountDisplay = document.getElementById('loan-amount-display');
                    const loanDurationDisplay = document.getElementById('loan-duration-display');
                    const interestRateDisplay = document.getElementById('interest-rate-display');
                    
                    const monthlyPaymentDisplay = document.getElementById('monthly-payment');
                    const totalCostDisplay = document.getElementById('total-cost');

                    function updateCalculator() {
                        const amount = parseInt(loanAmountSlider.value);
                        const duration = parseInt(loanDurationSlider.value);
                        const rate = parseFloat(interestRateSlider.value) / 10;

                        loanAmountDisplay.textContent = amount.toLocaleString() + ' €';
                        loanDurationDisplay.textContent = duration + ' mois';
                        interestRateDisplay.textContent = rate + '%';

                        // Calculate monthly payment
                        const monthlyRate = rate / 100 / 12;
                        const monthlyPayment = (amount * monthlyRate * Math.pow(1 + monthlyRate, duration)) / (Math.pow(1 + monthlyRate, duration) - 1);
                        const totalCost = monthlyPayment * duration;

                        monthlyPaymentDisplay.textContent = (isNaN(monthlyPayment) ? 0 : monthlyPayment).toFixed(2) + ' €';
                        totalCostDisplay.textContent = (isNaN(totalCost) ? 0 : totalCost).toFixed(2) + ' €';
                    }

                    loanAmountSlider.addEventListener('input', updateCalculator);
                    loanDurationSlider.addEventListener('input', updateCalculator);
                    interestRateSlider.addEventListener('input', updateCalculator);

                    // Initialize calculator
                    updateCalculator();
                });
