from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QLineEdit, QMainWindow, QStatusBar
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QColor

class AppWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        # Configuração da janela
        self.setWindowTitle("Remote IT Receiver")
        self.setFixedSize(1536, 864)
        self.setStyleSheet("""
            QMainWindow {
                background-color: #171a21;  /* Cor de fundo escura */
            }
            QLineEdit {
                background-color: #2a2e36;  /* Cor de fundo das caixas de texto */
                color: white;  /* Cor do texto */
                border: 2px solid #4d4d4d;  /* Borda das caixas */
                border-radius: 15px;  /* Bordas arredondadas */
                padding: 10px;
                margin: 10px 0;
            }
            QStatusBar {
                background-color: #171a21;  /* Cor da barra de status */
                color: #b2b2b2;  /* Cor do texto da barra de status */
            }
        """)

        # Layout principal
        central_widget = QWidget()
        layout = QVBoxLayout()

        # Adicionando os TextFields (caixas de texto)
        text_fields = []
        for i in range(3):
            text_field = QLineEdit(self)
            text_field.setPlaceholderText(f"Placeholder {i + 1}")
            text_fields.append(text_field)
            layout.addWidget(text_field)

        central_widget.setLayout(layout)
        self.setCentralWidget(central_widget)

        # Barra inferior (Bottom Bar)
        self.statusBar = QStatusBar(self)
        self.statusBar.showMessage("Placeholder Text", 2000)  # Texto centralizado na barra inferior
        self.setStatusBar(self.statusBar)

        # Centralizando a janela
        screen_geometry = QApplication.primaryScreen().availableGeometry()
        x = (screen_geometry.width() - self.width()) // 2
        y = (screen_geometry.height() - self.height()) // 2
        self.move(x, y)

        self.show()

