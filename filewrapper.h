#ifndef FILEWRAPPER_H
#define FILEWRAPPER_H

#include <QObject>
#include <QFileInfo>

class FileWrapper : public QObject
{
    Q_OBJECT
public:
    FileWrapper();
    virtual ~FileWrapper();

    Q_INVOKABLE bool exists(const QString& fileName);
    Q_INVOKABLE QString symLinkTarget(const QString& fileName);
    Q_INVOKABLE QString getFileExtension(const QString& fileName);
    Q_INVOKABLE QString getDir(const QString& fileName);

private:
    QFileInfo mFileInfo;

};

#endif // FILEWRAPPER_H
