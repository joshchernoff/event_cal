export default class DarkmodeToggle {
    constructor() {
      this.addEventListeners();
    }

    // Toggle the theme and update localStorage
    toggleTheme() {
      if (document.documentElement.classList.contains('dark')) {
        localStorage.theme = 'light';
        document.documentElement.classList.remove('dark');
      } else {
        localStorage.theme = 'dark';
        document.documentElement.classList.add('dark');
      }
    }
  
    // Add event listeners for custom events
    addEventListeners() {
      window.addEventListener('toggle-theme', () => this.toggleTheme());
    }
  }
  