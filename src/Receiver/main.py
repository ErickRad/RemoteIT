from PyQt5.QtWidgets import QApplication
from home import AppWindow
from connection import Connection

if __name__ == "__main__":
    app = QApplication([])
    window = AppWindow()
    app.exec_()
