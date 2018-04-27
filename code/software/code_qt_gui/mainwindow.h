#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QFile>
#include <QTextStream>
#include <QTextEdit>
#include <QTcpSocket>
#include <QUdpSocket>
#include <QDateTime>
#include <QHostAddress>
#include <QNetworkAddressEntry>
#include <fstream>
#include <QDateTime>
#include <QTimer>
namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    unsigned int new_exposure_cam_1;
    unsigned int new_exposure_cam_2;
    QString  ip_addr_board;
private:
    Ui::MainWindow *ui;


private slots:
    void on_Slider_1_valueChanged(int value);
    void on_Slider_2_valueChanged(int value);
    void on_ip_addr_board_textChanged(const QString &arg1);
    void on_radioButton_3_clicked();
    void on_radioButton_clicked();
    void on_radioButton_2_clicked();
    void on_radioButton_4_clicked();
    void on_on_apply_clicked();
    void on_Slider_3_valueChanged(int value);
};

class UdpServer :public QTextEdit {
    Q_OBJECT
private:

public:
    UdpServer(QWidget* pwgt = 0);
    QUdpSocket* m_pudp;
public slots:
    void slotSendDatagram();
};





#endif // MAINWINDOW_H
