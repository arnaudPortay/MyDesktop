#include "filewrapper.h"
#include <QDir>

/************************************************************************************************************/

FileWrapper::FileWrapper():QObject (nullptr)
{
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
