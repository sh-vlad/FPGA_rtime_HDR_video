#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    MainWindow::ip_addr_board = ui->ip_addr_board->text();
    ui->Slider_1_1->setStyleSheet("QSlider::handle{ background-color: blue;} ");
    ui->Slider_1_2->setStyleSheet("QSlider::handle{ background-color: blue;} ");
    ui->Slider_1_3->setStyleSheet("QSlider::handle{ background-color: blue;} ");
    ui->Slider_2_1->setStyleSheet("QSlider::handle{ background-color: blue;} ");
    ui->Slider_2_2->setStyleSheet("QSlider::handle{ background-color: blue;} ");
    ui->Slider_2_3->setStyleSheet("QSlider::handle{ background-color: blue;} ");
    ui->Slider_3->setStyleSheet("QSlider::handle{ background-color: blue;} ");
}

MainWindow::~MainWindow()
{
    delete ui;
}


UdpServer::UdpServer(QWidget *pwgt):QTextEdit(pwgt)
{

    setWindowTitle("UdpSERVER");
    m_pudp =new QUdpSocket(this);

    QTimer* ptimer = new QTimer(this);
    ptimer->setInterval(3000);
    ptimer->start();
    connect(ptimer, SIGNAL(timeout()), SLOT(slotSendDatagram()));
}

void UdpServer::slotSendDatagram()
{
    QByteArray baDatagram;
    QDataStream out (&baDatagram, QIODevice::WriteOnly);


   //out.setVersion(QDataStream::Qt_5_3);
}



void MainWindow::on_ip_addr_board_textChanged(const QString &arg1)
{
    ip_addr_board = arg1;
}

void MainWindow::on_radioButton_3_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);  
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 3<<16 | 0x2; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly); 
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 1<<16 | 0x2; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_2_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);  //передаем потоку указатель на QIODevice;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 2<<16 | 0x2; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_4_clicked()
{
    UdpServer a;
    QString ip_server = ui->ip_addr_board->text();
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);  //передаем потоку указатель на QIODevice;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 7<<16 | 0x2; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_on_apply_clicked()
{
    qint8 sum;
   QString _div_coef         = ui->div_coef->text();
    QString _shift_coef       = ui->shift_coef->text();
    QString _matrix_coef_00   = ui->coef_matrix_00->text();
    QString _matrix_coef_01   = ui->coef_matrix_01->text();
    QString _matrix_coef_02   = ui->coef_matrix_02->text();
    QString _matrix_coef_10   = ui->coef_matrix_10->text();
    QString _matrix_coef_11   = ui->coef_matrix_11->text();
    QString _matrix_coef_12   = ui->coef_matrix_12->text();
    QString _matrix_coef_20   = ui->coef_matrix_20->text();
    QString _matrix_coef_21   = ui->coef_matrix_21->text();
    QString _matrix_coef_22   = ui->coef_matrix_22->text();


    qint8 div_coef       =  _div_coef.toInt()      ;
    qint8 shift_coef     =  _shift_coef.toInt()    ;
    qint8 matrix_coef_00 =  _matrix_coef_00.toInt();
    qint8 matrix_coef_01 =  _matrix_coef_01.toInt();
    qint8 matrix_coef_02 =  _matrix_coef_02.toInt();
    qint8 matrix_coef_10 =  _matrix_coef_10.toInt();
    qint8 matrix_coef_11 =  _matrix_coef_11.toInt();
    qint8 matrix_coef_12 =  _matrix_coef_12.toInt();
    qint8 matrix_coef_20 =  _matrix_coef_20.toInt();
    qint8 matrix_coef_21 =  _matrix_coef_21.toInt();
    qint8 matrix_coef_22 =  _matrix_coef_22.toInt();
    sum = matrix_coef_00 + matrix_coef_01 +matrix_coef_02 +matrix_coef_10 +matrix_coef_11+matrix_coef_12+matrix_coef_20+matrix_coef_21+matrix_coef_22;
    if(sum==0)
        div_coef = 1;
    else
        div_coef =sum;
    ui->div_coef->setText( QString::number(sum));



    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);  
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = div_coef<<16 | 0x5; //
    vec.push_back(tmp);
    tmp = shift_coef<<16 | 0x6; //
    vec.push_back(tmp);


    vec.push_back(matrix_coef_00<<16 | 0x7);
    vec.push_back(matrix_coef_01<<16 | 0x8);
    vec.push_back(matrix_coef_02<<16 | 0x9);
    vec.push_back(matrix_coef_10<<16 | 0xa);
    vec.push_back(matrix_coef_11<<16 | 0xb);
    vec.push_back(matrix_coef_12<<16 | 0xc);
    vec.push_back(matrix_coef_20<<16 | 0xd);
    vec.push_back(matrix_coef_21<<16 | 0xe);
    vec.push_back(matrix_coef_22<<16 | 0xf);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);

}


void MainWindow::on_Slider_3_valueChanged(int value)
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);  
    QVector<qint32> vec;
    vec.push_back(1);
    qint8 parallax_corr = !(value % 2 ) ? (value & 0xff) : (value+1) & 0xff;
    tmp = parallax_corr<<16 | 0x3; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}



void MainWindow::on_Slider_1_1_valueChanged(int value)
{
    quint32 tmp;
    quint8 byte0;
    byte0 = value & 0xff;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (1<<16) | 0x4; // addr =4, выбираем камеру 1
    vec.push_back(tmp);
    tmp = byte0<<16 | 0x3502;
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_Slider_1_2_valueChanged(int value)
{
    quint32 tmp;
    quint8 byte0;
    byte0 = value & 0xff;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (1<<16) | 0x4; // addr =4, выбираем камеру 1
    vec.push_back(tmp);
    tmp = byte0<<16 | 0x3501;
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_Slider_1_3_valueChanged(int value)
{
    quint32 tmp;
    quint8 byte0;
    byte0 = value & 0xf;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (1<<16) | 0x4; // addr =4, выбираем камеру 1
    vec.push_back(tmp);
    tmp = byte0<<16 | 0x3500;
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_Slider_2_1_valueChanged(int value)
{
    quint32 tmp;
    quint8 byte0;
    byte0 = value & 0xff;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (2<<16) | 0x4; // addr =4, выбираем камеру 2
    vec.push_back(tmp);
    tmp = byte0<<16 | 0x3502;
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_Slider_2_2_valueChanged(int value)
{
    quint32 tmp;
    quint8 byte0;
    byte0 = value & 0xff;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (2<<16) | 0x4; // addr =4, выбираем камеру 2
    vec.push_back(tmp);
    tmp = byte0<<16 | 0x3501;
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_Slider_2_3_valueChanged(int value)
{
    quint32 tmp;
    quint8 byte0;
    byte0 = value & 0xf;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (2<<16) | 0x4; // addr =4, выбираем камеру 2
    vec.push_back(tmp);
    tmp = byte0<<16 | 0x3500;
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}


void MainWindow::on_Button_BLUR_clicked()
{
     ui->coef_matrix_00->setText("1");
     ui->coef_matrix_01->setText("1");
     ui->coef_matrix_02->setText("1");
     ui->coef_matrix_10->setText("1");
     ui->coef_matrix_11->setText("1");
     ui->coef_matrix_12->setText("1");
     ui->coef_matrix_20->setText("1");
     ui->coef_matrix_21->setText("1");
     ui->coef_matrix_22->setText("1");
     ui->div_coef->setText("9");
}

void MainWindow::on_Button_SHARPEN_clicked()
{
    ui->coef_matrix_00->setText("0");
    ui->coef_matrix_01->setText("-1");
    ui->coef_matrix_02->setText("0");
    ui->coef_matrix_10->setText("-1");
    ui->coef_matrix_11->setText("5");
    ui->coef_matrix_12->setText("-1");
    ui->coef_matrix_20->setText("0");
    ui->coef_matrix_21->setText("-1");
    ui->coef_matrix_22->setText("0");
    ui->div_coef->setText("1");
}

void MainWindow::on_EMBOSS_clicked()
{
    ui->coef_matrix_00->setText("-2");
    ui->coef_matrix_01->setText("-1");
    ui->coef_matrix_02->setText("0");
    ui->coef_matrix_10->setText("-1");
    ui->coef_matrix_11->setText("1");
    ui->coef_matrix_12->setText("1");
    ui->coef_matrix_20->setText("0");
    ui->coef_matrix_21->setText("1");
    ui->coef_matrix_22->setText("2");
    ui->div_coef->setText("1");
}

void MainWindow::on_Button_EDGE_DETECROR_clicked()
{
    ui->coef_matrix_00->setText("0");
    ui->coef_matrix_01->setText("1");
    ui->coef_matrix_02->setText("0");
    ui->coef_matrix_10->setText("1");
    ui->coef_matrix_11->setText("-4");
    ui->coef_matrix_12->setText("1");
    ui->coef_matrix_20->setText("0");
    ui->coef_matrix_21->setText("1");
    ui->coef_matrix_22->setText("0");
    ui->div_coef->setText("1");
}

void MainWindow::on_radioButton_5_clicked()
{
    quint32 tmp;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (0<<16) | 0x4; // addr =4, select camera 1,2
    vec.push_back(tmp);
    tmp = (1<<16) | 0x3503; //manual -1
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}


void MainWindow::on_radioButton_6_clicked()
{
    quint32 tmp;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (0<<16) | 0x4; // addr =4, select camera 1,2
    vec.push_back(tmp);
    tmp = (0<<16) | 0x3503; //auto
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_Button_NOT_FILTER_clicked()
{
    ui->coef_matrix_00->setText("0");
    ui->coef_matrix_01->setText("0");
    ui->coef_matrix_02->setText("0");
    ui->coef_matrix_10->setText("0");
    ui->coef_matrix_11->setText("1");
    ui->coef_matrix_12->setText("0");
    ui->coef_matrix_20->setText("0");
    ui->coef_matrix_21->setText("0");
    ui->coef_matrix_22->setText("0");
    ui->div_coef->setText("1");
}

void MainWindow::on_doubleSpinBox_gamma_1_valueChanged(double arg1)
{
    float n;
    quint32 tmp;
    quint8 data;
    QVector<qint32> vec;
    vec.push_back(2);
    n =(float)(255./pow(255.,arg1));
    for(int i=0;i<256;i++)
    {
        data = n*(pow(i,arg1));
        tmp = (data<<16) | i; // addr =4, select camera 1,2
        vec.push_back(tmp);
    }
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);

}

void MainWindow::on_doubleSpinBox_gamma_2_valueChanged(double arg1)
{
    float n;
    quint32 tmp;
    quint8 data;
    QVector<qint32> vec;
    vec.push_back(2);
    n =(float)(255./pow(255.,arg1));
    for(int i=0;i<256;i++)
    {
        data = n*(pow((double)i,arg1));
        tmp = (data<<16) | (256+i);
        vec.push_back(tmp);
    }
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_8_clicked()
{
    quint32 tmp;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (0<<16) | 0x4; // addr =4, select camera 1,2
    vec.push_back(tmp);
    tmp = (0xa7<<16) | 0x5000; //auto
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_7_clicked()
{

    quint32 tmp;
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = (0<<16) | 0x4; // addr =4, select camera 1,2
    vec.push_back(tmp);
    tmp = (0x87<<16) | 0x5000; //auto
    vec.push_back(tmp);
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    UdpServer a;
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_10_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 1<<16 | 0x11; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_9_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 2<<16 | 0x11; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_11_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 4<<16 | 0x11; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_radioButton_12_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    QVector<qint32> vec;
    vec.push_back(1);
    tmp = 8<<16 | 0x11; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}

void MainWindow::on_checkBox_clicked()
{
    UdpServer a;
    quint32 tmp;
    QByteArray Datagram;
    QDataStream out(&Datagram, QIODevice::WriteOnly);
    QVector<qint32> vec;
    vec.push_back(1);
    if( ui->checkBox->checkState() == 2 )
        tmp = 1<<16 | 0x12; //
    else
        tmp = 0<<16 | 0x12; //
    vec.push_back(tmp);
    out << vec;
    a.m_pudp->writeDatagram(Datagram, QHostAddress(ip_addr_board),3333);
}
