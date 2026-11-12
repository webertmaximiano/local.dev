import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  // --- ADICIONE ESTA SEÇÃO ---
  server: {
    host: true, // Garante que o servidor escute em todas as interfaces de rede
    hmr: {
        host: 'localhost', // Essencial para o Hot Module Replacement funcionar com Docker
    },
    watch: {
      usePolling: true // Usa polling para detectar mudanças em arquivos, mais confiável em contêineres
    },
    // Permite que o Ingress acesse o servidor de desenvolvimento
    allowedHosts: ['agilizando.local.dev']
  }
  // --- FIM DA SEÇÃO ADICIONADA ---
})