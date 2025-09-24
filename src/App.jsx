import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <nav className="navbar">
        <div className="nav-logo">
          <a href="https://wavecoding.ai">
            <img src={viteLogo} className="logo" alt="Vite logo" style={{height: '2em'}} />
          </a>
        </div>
        <div className="nav-links">
          <a href="#home" className={window.location.hash === '#home' ? 'active' : ''}>Home</a>
          <a href="#about" className={window.location.hash === '#about' ? 'active' : ''}>About</a>
          <a href="#services" className={window.location.hash === '#services' ? 'active' : ''}>Services</a>
          <a href="#contact" className={window.location.hash === '#contact' ? 'active' : ''}>Contact</a>
        </div>
      </nav>
      <div>
        <a href="https://wavecoding.ai" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://wavecoding.ai" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Your new website is initialized by WAVECODING.AI</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Chat with <code>Wavecoding.ai</code> and see the magic
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  )
}

export default App
