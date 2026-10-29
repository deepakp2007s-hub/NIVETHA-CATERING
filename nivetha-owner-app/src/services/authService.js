const authService = {
  // No owner login required

  // Clear local owner session
  logout: () => {
    localStorage.removeItem("ownerToken");
  },
};

export default authService;