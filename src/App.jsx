import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import Navbar from './components/Navbar'

function App() {
  const [count, setCount] = useState(0)
  const [messages, setMessages] = useState([
    { id: 1, text: "Welcome to your new website!", type: "info" },
    { id: 2, text: "Built with React and Vite", type: "success" }
  ])

  return (
    <>
      <Navbar />
      <div>
        <a href="https://wavecoding.ai" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://wavecoding.ai" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Your new website is initialized by WAVECODING.AI</h1>
      <div className="messages">
        {messages.map(message => (
          <div key={message.id} className={`message ${message.type}`}>
            {message.text}
          </div>
        ))}
      </div>
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
