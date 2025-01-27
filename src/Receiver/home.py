import sys
import screeninfo as si
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QPushButton
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from connection import Connection
from properties import Sizes

class UpdateLabelsThread(QThread):
    connection_status_signal = pyqtSignal(str)
    passcode_signal = pyqtSignal(str)

    def run(self):
        Connection.connectToReceiver()
        self.connection_status_signal.emit("Connected" if Connection.connected else "Disconnected")
        self.passcode_signal.emit(Connection.passcode)

class ConnectionThread(QThread):
    
    def run(self):
        if(Connection.connected):
            Connection.receiveCommands()

class HomeWindow(QWidget):
    def __init__(self):
        super().__init__()

        # Resolução da tela
        Connection.screenWidth, Connection.screenHeigth = si.get_monitors()[0].width, si.get_monitors()[0].height
        self.setWindowTitle("Remote IT Receiver")
        self.setGeometry(int(Connection.screenWidth/3), int(Connection.screenHeigth/5), 600, 250)

        # Estilo para o modo escuro com cantos arredondados e cores personalizadas
        self.setStyleSheet("""
            QWidget {
                background-color: #1b1b24;
                color: white;
                border-radius: 20px;
                padding: 15px;
            }
            QLabel {
                color: white;
                font-size: 18px;
            }
            QLineEdit {
                background-color: #313140;
                border-radius: 15px;
                padding: 10px;
                color: white;
                border: 1px solid #444;
                margin-bottom: 15px;
                font-size: 16px;
            }
            QLineEdit:focus {
                border-color: #6C8BC9;  # Mudando a cor da borda quando o campo estiver em foco
            }
            QPushButton {
                background-color: #444;
                color: white;
                border: none;
                border-radius: 15px;
                padding: 10px 15px;
                font-size: 16px;
                text-align: center;
                cursor: pointer;
            }
            QPushButton:hover {
                background-color: #555;
            }
            QPushButton:pressed {
                background-color: #333;
                border-radius: 15px;
            }
            QHBoxLayout {
                spacing: 10px;
            }
            QVBoxLayout {
                spacing: 20px;
            }
        """)

        # Layout principal
        main_layout = QVBoxLayout()

        # Layout do topo
        top_layout = QHBoxLayout()

        # Label de status
        self.status_label = QLabel("Disconnected")
        self.status_label.setStyleSheet(f"font-size: {Sizes.SECONDARY_TEXT}px; font-weight: bold;")

        # Botão de configurações
        settings_button = QPushButton("⚙️")
        settings_button.setStyleSheet("font-size: 20px; padding: 5px 10px; border-radius: 10px;")
        settings_button.setCursor(Qt.PointingHandCursor)

        # Organizando o layout superior
        top_layout.addStretch()
        top_layout.addWidget(self.status_label)
        top_layout.addWidget(settings_button)

        # Campos para IP, Hostname e Passcode
        ip_field = QLineEdit(self)
        ip_field.setText(f"{Connection.local_ip}")
        ip_field.setReadOnly(True)

        hostname_field = QLineEdit(self)
        hostname_field.setText(f"{Connection.hostname}")
        hostname_field.setReadOnly(True)

        self.passcode_field = QLineEdit(self)
        self.passcode_field.setText(f"{Connection.passcode}")
        self.passcode_field.setReadOnly(True)

        # Adicionando os layouts e campos
        main_layout.addLayout(top_layout)
        main_layout.addWidget(ip_field)
        main_layout.addWidget(hostname_field)
        main_layout.addWidget(self.passcode_field)

        # Ajustando o layout
        self.setLayout(main_layout)

        self.update_labels = UpdateLabelsThread()
        self.connection = ConnectionThread()

        self.update_labels.connection_status_signal.connect(self.update_connection_status)
        self.update_labels.passcode_signal.connect(self.update_passcode)
        
        self.update_labels.start()
        self.connection.start()

    def update_connection_status(self, status):
        self.status_label.setText(status)

    def update_passcode(self, passcode):
        self.passcode_field.setText(passcode)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = HomeWindow()
    window.show()
    sys.exit(app.exec_())
