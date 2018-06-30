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
#include <math.h>
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
    QString  ip_addr_board;

private:
    Ui::MainWindow *ui;


private slots:
    void on_ip_addr_board_textChanged(const QString &arg1);
    void on_radioButton_3_clicked();
    void on_radioButton_clicked();
    void on_radioButton_2_clicked();
    void on_radioButton_4_clicked();
    void on_on_apply_clicked();
    void on_Slider_3_valueChanged(int value);
    void on_Slider_1_1_valueChanged(int value);
    void on_Slider_1_2_valueChanged(int value);
    void on_Slider_1_3_valueChanged(int value);
    void on_Slider_2_1_valueChanged(int value);
    void on_Slider_2_2_valueChanged(int value);
    void on_Slider_2_3_valueChanged(int value);
    void on_Button_BLUR_clicked();
    void on_Button_SHARPEN_clicked();
    void on_EMBOSS_clicked();
    void on_Button_EDGE_DETECROR_clicked();
    void on_radioButton_5_clicked();
    void on_radioButton_6_clicked();
    void on_Button_NOT_FILTER_clicked();
    void on_doubleSpinBox_gamma_1_valueChanged(double arg1);
    void on_doubleSpinBox_gamma_2_valueChanged(double arg1);
    void on_radioButton_8_clicked();
    void on_radioButton_7_clicked();
    void on_radioButton_10_clicked();
    void on_radioButton_9_clicked();
    void on_radioButton_11_clicked();
    void on_radioButton_12_clicked();
    void on_checkBox_clicked();
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
