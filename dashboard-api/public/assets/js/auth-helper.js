// Global Authentication Helper
window.AuthHelper = {
    // Get stored token
    getToken() {
        return localStorage.getItem('auth_token');
    },

    // Get stored user data
    getUserData() {
        const userData = localStorage.getItem('user_data');
        return userData ? JSON.parse(userData) : null;
    },

    // Check if user is authenticated
    isAuthenticated() {
        return !!this.getToken();
    },

    // Check if user has specific role
    hasRole(role) {
        const user = this.getUserData();
        return user && user.role === role;
    },

    // Check if user is admin
    isAdmin() {
        return this.hasRole('admin');
    },

    // Check if user is regular user
    isUser() {
        return this.hasRole('user');
    },

    // Redirect based on role (simplified - no verification checks)
    redirectBasedOnRole() {
        const user = this.getUserData();
        
        if (!user) {
            window.location.href = '/login';
            return;
        }
        
        // Redirect based on role only
        if (this.isAdmin()) {
            window.location.href = '/admin-virements';
        } else if (this.isUser()) {
            window.location.href = '/home';
        } else {
            window.location.href = '/login';
        }
    },

    // Logout user
    async logout() {
        try {
            // Call logout API to invalidate token on server
            await this.apiRequest('/api/auth/logout', {
                method: 'POST'
            });
        } catch (error) {
            console.log('Logout API call failed, continuing with client-side logout');
        }
        
        // Clear local storage
        localStorage.removeItem('auth_token');
        localStorage.removeItem('user_data');
        
        // Redirect to login
        window.location.href = '/login';
    },

    // Make authenticated API request
    async apiRequest(url, options = {}) {
        const token = this.getToken();
        
        if (!token) {
            this.logout();
            return;
        }

        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        };

        const mergedOptions = {
            ...defaultOptions,
            ...options,
            headers: {
                ...defaultOptions.headers,
                ...options.headers
            }
        };

        try {
            const response = await fetch(url, mergedOptions);
            
            // If unauthorized, logout user
            if (response.status === 401) {
                this.logout();
                return;
            }

            return response;
        } catch (error) {
            console.error('API Request Error:', error);
            throw error;
        }
    },

    // Validate token with server
    async validateToken() {
        try {
            const response = await this.apiRequest('/api/user');
            if (response && response.ok) {
                const userData = await response.json();
                localStorage.setItem('user_data', JSON.stringify(userData));
                return true;
            }
            return false;
        } catch (error) {
            return false;
        }
    }
};

// Auto-redirect authenticated users from login page - TEMPORARILY DISABLED
// if (window.location.pathname === '/login' && AuthHelper.isAuthenticated()) {
//     console.log('User is authenticated on login page - checking status...');
//     const user = AuthHelper.getUserData();
//     console.log('User data on login page:', user);
//     
//     if (!user.email_and_phone_verified) {
//         console.log('Email/phone not verified - staying on login page');
//         // Stay on login page
//     } else if (!user.fully_verified) {
//         console.log('Email/phone verified but not fully verified - redirecting to KYC finalize');
//         window.location.href = '/kyc-finalize';
//     } else {
//         console.log('Fully verified - redirecting based on role');
//         AuthHelper.redirectBasedOnRole();
//     }
// }

// Protect admin routes
if (window.location.pathname.startsWith('/admin') && !AuthHelper.isAdmin()) {
    window.location.href = '/login';
}

// Simple route protection - only check authentication
if (window.location.pathname === '/home' && !AuthHelper.isAuthenticated()) {
    window.location.href = '/login';
}

if (window.location.pathname === '/kyc-finalize' && !AuthHelper.isAuthenticated()) {
    window.location.href = '/login';
}
