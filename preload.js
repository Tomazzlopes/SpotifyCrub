const { contextBridge, ipcRenderer } = require('electron');

// O contextBridge cria o objeto "window.api" que o teu HTML vai usar
contextBridge.exposeInMainWorld('api', {
    
    // Função para ENVIAR dados (do HTML para o Main)
    enviarAoBackend: (canal, dados) => {
        ipcRenderer.send(canal, dados);
    },

    // Função para RECEBER dados (do Main para o HTML)
    // Nota: O nome 'receberDoBackend' tem de ser igual ao que usas no HTML
    receberDoBackend: (canal, callback) => {
        // Removemos ouvintes antigos para evitar duplicados e fugas de memória
        ipcRenderer.removeAllListeners(canal); 
        ipcRenderer.on(canal, (event, res) => callback(res));
    }
});