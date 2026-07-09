import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: '../src/main/webapp',
    emptyOutDir: false,
    rollupOptions: {
      output: {
        assetFileNames: 'assets/landing-build/[name]-[hash][extname]',
        chunkFileNames: 'assets/landing-build/[name]-[hash].js',
        entryFileNames: 'assets/landing-build/[name]-[hash].js',
      }
    }
  }
})
