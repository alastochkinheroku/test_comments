#include <QCoreApplication>
#include <QTextCodec>
#include <QDebug>
#include <QFile>
#include <QDateTime>
#include <QStringList>

void print_help()
{
    qDebug() << qPrintable("Программа для вытаскивания текстов игры из сценария и преобразования их в игровой формат.");
    qDebug() << "Параметры командной строки:";
    qDebug() << "stgs infile outfile [italic,br]";
    qDebug() << "   infile - plain text file, перед текстами должна быть метка TEXT, затем в после имени параграфа, в скобках указывается имя функции для обработки, пример ПАРАГРАФ 1 (para1)";
    qDebug() << "   outfile - выходной файл, формата TADS .t";
    qDebug() << "   italic - принудительно делать строки с курсивом";
    qDebug() << "   br - принудительно ставить перевод каретки до и после";
}

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    //Кодек для вывода qDebug
    qDebug() << "CONSOLE CODEC CP866";
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("CP866"));
    //QTextCodec::setCodecForCStrings(QTextCodec::codecForName("CP866"));
    //QTextCodec::setCodecForTr(QTextCodec::codecForName("CP866"));

    QStringList args(QCoreApplication::arguments());
    if (args.count() < 3){
        print_help();
        return 1;
    }
    bool makeItalic = false;
    bool makeNewLine = false;
    if (args.count() == 4){
        if (args.at(3).contains("italic")) {
           qDebug() << "Make italic";
           makeItalic = true;
        }
        if (args.at(3).contains("br")) {
           qDebug() << "Make new lines";
           makeNewLine = true;
        }
    }

    bool begin_para = false;
    bool process_para = false;
    int total = 0;
    QString fileName = args.at(1);
    QFile inputFile(fileName);
    QString fileNameOut = args.at(2);
    QFile outFile(fileNameOut);
    if (inputFile.open(QIODevice::ReadOnly))
    {
        if (outFile.open(QIODevice::WriteOnly))
        {
           QTextStream in(&inputFile);
           QTextStream out(&outFile);
           out.setCodec(QTextCodec::codecForName("CP1251"));
           QString prev_line;
           while (!in.atEnd())
           {
              QString line = in.readLine();
              line = line.trimmed();
              if (line=="TEXT")
              {
                 out<<QString("//Document generated automatically! Do not edit!\n");
                 out<<QString("//Source: %1\n").arg(fileName);
                 out<<QString("//Generation date: %1\n").arg(QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss"));
                 begin_para = true;
              }
              else if (begin_para)
              {
                 //Если предыдущая строка была пустая, и текущая строка со скобками, то начинаем запись параграфа
                 if (prev_line.isEmpty() && line.contains("(") && line.contains(")") )
                 {
                      QString para = line.left(line.indexOf('('));
                      para = para.trimmed();
                      QString fun = line.mid(line.indexOf('(')+1,line.indexOf(')')-line.indexOf('(')-1);
                      fun = fun.trimmed();
                      fun.replace(" ","_"); //Заменяем пробелы в названия функций
                      qDebug()<<"Paragraph: "<<para;
                      total++;
                      out<<QString("//%1\n").arg(para);

                      out<<QString("scen_%1: function\n").arg(fun); //добавляем префикс к названиям
                      out<<QString("{\n");
                      if (makeNewLine) out<<QString("   \"<br>\";\n");
                      if (makeItalic) out<<QString("   \"<i>\";\n");
                      process_para = true;
                 }
                 else  //если идет обработка параграфа, появилась пустая строка - конец параграфа и функции соответсвенно
                 if (line.isEmpty() && process_para)
                 {
                     if (makeItalic) out<<QString("   \"</i>\";\n");
                     out<<QString("}\n\n");
                     process_para = false;
                 }
                 else if (process_para)
                 {
                     if (line.at(0) == '*') line[0] = '-'; //звездочки - это тире в гугл докс
                     out<<QString("   \"%1\\n\";\n").arg(line);
                     //Возможно это пропущенный параграф
                     if ( line.contains("(") && line.contains(")") ) {
                        qDebug()<<"WARNING: may be missed paragraph "<<line;
                     }
                 }
              }
              prev_line = line;
           }

           if (!begin_para) {
               qDebug() << "WARNING: not found start of text (TEXT)";
           }
           else if (process_para) {
               if (makeItalic) out<<QString("   \"</i>\";\n");
               out<<QString("}");
               out<<QString("");
           }
           qDebug() << "Total paragraphs: "<<total;
           inputFile.close();
           outFile.close();
        }
        else
        {
            qDebug() << "Cannot open file for reading "<<fileNameOut;
            return 1;
        }
    }
    else
    {
        qDebug() << "Cannot open file for writing "<<fileName;
        return 1;
    }

    return 0;
}
