const {ipcmain} = require('electron')
const mysql = require ('mysql');
const path = require('path');
const { app, BrowserWindow } = require('electron/main')
const path = require('node:path')

let janela;

const conexao = mysql.createConnection ({
    host: 'localhost',
    user: 'root',      // Teu utilizador do Workbench
    password: 'Esqueceensinotesp2025@', 
    database: 'spotify' // Nome da BD que criaste no Workbench
});

    conexao.connect(err=> {
        if(err){
            console.error("Erro ao conectar á base de dados" + err.stack);
            return;
        }
        console.log('Ligado ao MySQL com o ID ' + conexao.threadId);
    });



function createWindow () {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })

  win.loadFile("home.html")
}

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})