import { mount } from 'svelte'
import './app.css'
import App from './App.svelte'
import { db } from './lib/db'

// Register Service Worker (solo en producción)
if ('serviceWorker' in navigator && import.meta.env.PROD) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').then(
      (registration) => {
        console.log('✅ Service Worker registered:', registration)
      },
      (error) => {
        console.error('❌ Service Worker registration error:', error)
      }
    )
  })
} else if (import.meta.env.DEV) {
  console.log('🔧 Modo desarrollo: Service Worker deshabilitado')
}

// Initialize IndexedDB on app startup
db.open().then(() => {
  console.log('✅ IndexedDB initialized successfully')
  console.log('📊 Database version:', db.verno)
  console.log('📋 Tables:', db.tables.map(t => t.name).join(', '))
}).catch(err => {
  console.error('❌ Failed to initialize IndexedDB:', err)
})

const app = mount(App, {
  target: document.getElementById('app')!,
})

export default app
