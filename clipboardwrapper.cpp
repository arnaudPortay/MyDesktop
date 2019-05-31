#include "clipboardwrapper.h"
#include <QApplication>
#include <QString>
#include <QMimeData>
#include <QStandardPaths>
#include <QFileInfo>

/************************************************************************************************************/

ClipboardWrapper::ClipboardWrapper(QObject* pParent) : QObject (pParent)
{
    mClipboard = qApp->clipboard();
}

/************************************************************************************************************/

ClipboardWrapper::~ClipboardWrapper()
{
    mClipboard = nullptr;
}

/************************************************************************************************************/

QList<QUrl> ClipboardWrapper::getUrls()
{
    // The perfect case, won't happen very often but still
    if (mClipboard->mimeData()->hasUrls())
    {
        return mClipboard->mimeData()->urls();
    }

    // I tried to infer the url in a generic way but shit happens...

    // The issue comes from the localized special folders in Windows such as "Music" which translates to "Musique" in French, which f**** things
    // up when passing it to the fromUserInput function since the "Musique" directory does not exist as such...
    // Apparently, getting the localized name through the winapi is a pain in the butt soo...
    // We will take the barbaric approach...

    QList<QUrl> lList;
    QUrl lUrl;

    QString lText = mClipboard->text();

    // Try and get the weird cases out of the way for french (for now)
    if (lText == "Musique")
    {
        lUrl = QUrl::fromUserInput(QStandardPaths::standardLocations(QStandardPaths::MusicLocation).at(0));
    }
    else if (lText == "Vidéos")
    {
        lUrl = QUrl::fromUserInput(QStandardPaths::standardLocations(QStandardPaths::MoviesLocation).at(0));
    }
    else if (lText == "Téléchargements")
    {
        lUrl = QUrl::fromUserInput(QStandardPaths::standardLocations(QStandardPaths::DownloadLocation).at(0));
    }
    else if (lText == "Documents")
    {
        lUrl = QUrl::fromUserInput(QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).at(0));
    }
    else if (lText == "Images")
    {
        lUrl = QUrl::fromUserInput(QStandardPaths::standardLocations(QStandardPaths::PicturesLocation).at(0));
    }
    else if (lText == "Bureau")
    {
        lUrl = QUrl::fromUserInput(QStandardPaths::standardLocations(QStandardPaths::DesktopLocation).at(0));
    }
    // does it look like an address ?
    else if (lText.startsWith("http") || lText.startsWith("ftp") || lText.startsWith("sftp") || lText.startsWith("www."))
    {
        lUrl = QUrl::fromUserInput(lText);
    }
    // is it a local file with a complete addresse given ?
    else if (QFileInfo::exists(lText))
    {
        lUrl = QUrl("file:///" + lText.replace("\\","/"));
    }

    // Check validity and emptyness before pushing to list
    if (lUrl.isValid() && !lUrl.isEmpty())
    {
        lList.push_back(lUrl);
    }

    return lList;
}

/************************************************************************************************************/


