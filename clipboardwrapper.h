#ifndef CLIPBOARDWRAPPER_H
#define CLIPBOARDWRAPPER_H

#include <QObject>
#include <QClipboard>
#include <QUrl>

class ClipboardWrapper : public QObject
{
    Q_OBJECT
public:
    ClipboardWrapper(QObject* pParent=nullptr);
    ~ClipboardWrapper();

    Q_INVOKABLE QList<QUrl> getUrls();
    Q_INVOKABLE void copyPath(const QString& pPath);

private:
    QClipboard* mClipboard;
};

#endif // CLIPBOARDWRAPPER_H
