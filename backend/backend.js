// Importação de módulos nativos do Electron e Node.js
// ipcMain é o "ouvido" do backend para escutar o frontend
const { app, BrowserWindow, ipcMain } = require('electron');
const mysql = require('mysql'); // Driver para comunicar com o MySQL
const path = require('path');   // Utilitário para caminhos de ficheiros

let janela; // Variável global para armazenar a janela principal

// Configuração da ligação à base de dados Spotify
const conexao = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Esqueceensinotesp2025@', 
    database: 'spotify'
});

// Executa a tentativa de ligação ao servidor MySQL
conexao.connect(err => {
    if(err){
        console.error("Erro ao conectar: " + err.stack);
        return;
    }
    console.log('Base de dados ligada!');
});

/**
 * ESCUTADOR IPC: 'pesquisar'
 * Quando o utilizador digita no frontend, este bloco é executado.
 */
ipcMain.on('pesquisar', (event, dados) => {
    // Prepara o termo com % para permitir pesquisa parcial (ex: 'ca' encontra 'casa')
    const termo = `%${dados.termo}%`; 
    const sql = "SELECT * FROM musicas WHERE nome_musica LIKE ?";

    // Executa a Query de forma segura usando Prepared Statements (?)
    conexao.query(sql, [termo], (err, resultados) => {
        if (err) {
            console.error("Erro na query SQL:", err);
            return;
        }
        // Envia os resultados de volta para o canal específico do frontend
        event.reply('resultados-pesquisa', resultados);
    });
});

// Função para configurar e abrir a janela do programa
function createWindow () {
    const win = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            // Liga o script de "ponte" (preload) à janela
            preload: path.join(__dirname, 'preload.js')
        }
    });
    win.loadFile("src/index.html"); // Define a página inicial
}

// Inicialização da aplicação
app.whenReady().then(createWindow);