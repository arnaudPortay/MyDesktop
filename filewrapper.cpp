#include "filewrapper.h"
#include <QDir>
#include <QStandardPaths>
#include <QGuiApplication>

/************************************************************************************************************/
#include <iostream>
FileWrapper::FileWrapper():QObject (nullptr)
{
#ifdef _WIN32
   mStartupFolder.setPath(QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation).at(0) + QDir::separator() + "Startup");
#endif
}

/************************************************************************************************************/

FileWrapper::~FileWrapper()
{
}

/************************************************************************************************************/

bool FileWrapper::exists(const QString& fileName)
{
    QString lTemp = fileName;
    lTemp.remove("file:///");

    // always reset otherwise info may be out of date...
    mFileInfo.setFile(lTemp);

    return mFileInfo.exists();
}

/************************************************************************************************************/

QString FileWrapper::symLinkTarget(const QString& fileName)
{
    QString lTemp = fileName;
    lTemp.remove("file:///");

    // always reset otherwise info may be out of date...
    mFileInfo.setFile(lTemp);

    QString lTarget = mFileInfo.symLinkTarget();

    return lTarget.isEmpty() ? fileName : lTarget.prepend("file:///");
}

/************************************************************************************************************/

QString FileWrapper::getFileExtension(const QString& fileName)
{
    QString lTemp = fileName;
    lTemp.remove("file:///");

    // always reset otherwise info may be out of date...
    mFileInfo.setFile(lTemp);

    return mFileInfo.completeSuffix();
}

/************************************************************************************************************/

QString FileWrapper::getDir(const QString &fileName)
{
    QString lTemp = fileName;
    if (lTemp.startsWith("file:///"))
    {
        lTemp.remove("file:///");

        // always reset otherwise info may be out of date...
        mFileInfo.setFile(lTemp);

        lTemp = "file:///" + mFileInfo.absoluteDir().absolutePath();
    }

    return lTemp;
}

/************************************************************************************************************/

bool FileWrapper::isLaunchingAtStartup()
{
#ifdef _WIN32
    return QFile::exists(mStartupFolder.path() + "/" + qGuiApp->applicationName() + ".lnk" );
#else
    return false;
#endif
}

/************************************************************************************************************/

void FileWrapper::toggleLaunchAtStartup()
{
#ifdef _WIN32
    if (isLaunchingAtStartup())
    {
        QFile(mStartupFolder.path() + "/" + qGuiApp->applicationName() + ".lnk").remove();
    }
    else
    {
        QFile::link(qGuiApp->applicationFilePath(), mStartupFolder.path() + "/" + qGuiApp->applicationName() + ".lnk");
    }

#endif
}

/************************************************************************************************************/
