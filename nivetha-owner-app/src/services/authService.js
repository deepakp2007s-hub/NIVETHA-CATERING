const authService = {
  getToken: () => {return localStorage.getItem("ownerToken");},
  logout: () => {localStorage.removeItem("ownerToken");},}
export default authService;