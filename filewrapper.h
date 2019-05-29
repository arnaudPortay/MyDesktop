#ifndef FILEWRAPPER_H
#define FILEWRAPPER_H

#include <QObject>
#include <QFileInfo>
#include <QDir>

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
    Q_INVOKABLE bool isLaunchingAtStartup();
    Q_INVOKABLE void toggleLaunchAtStartup();

private:
    QFileInfo mFileInfo;
#ifdef _WIN32
    QDir mStartupFolder;
    QFile mAppFile;
#endif

};

#endif // FILEWRAPPER_H
