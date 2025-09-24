import { useState } from 'react'
import viteLogo from '/vite.svg'

export default function Navbar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  return (
    <nav className="navbar">
      <div className="nav-logo">
        <a href="https://wavecoding.ai">
          <img src={viteLogo} className="logo" alt="Vite logo" style={{height: '2em'}} />
        </a>
      </div>
      <button 
        className="mobile-menu-button"
        onClick={() => setIsMenuOpen(!isMenuOpen)}
      >
        <span className="hamburger"></span>
      </button>
      <div className={`nav-links ${isMenuOpen ? 'open' : ''}`}>
        <a href="#home" className={window.location.hash === '#home' ? 'active' : ''}>Home</a>
        <a href="#about" className={window.location.hash === '#about' ? 'active' : ''}>About</a>
        <a href="#services" className={window.location.hash === '#services' ? 'active' : ''}>Services</a>
        <a href="#contact" className={window.location.hash === '#contact' ? 'active' : ''}>Contact</a>
      </div>
    </nav>
  )
}
