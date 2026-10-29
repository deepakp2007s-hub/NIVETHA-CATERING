
const authService = {
  // No owner login page required.

  // Check whether an owner token exists.
  getToken: () => {
    return localStorage.getItem("ownerToken");
  },

  // Clear the local owner session.
  logout: () => {
    localStorage.removeItem("ownerToken");
  },
};

export default authService;
