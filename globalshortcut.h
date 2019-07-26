#ifndef GLOBALSHORTCUT_H
#define GLOBALSHORTCUT_H

#include <QObject>

#include "qxtglobalshortcut.h"

class GlobalShortcut : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString keySequence READ keySequence WRITE setKeySequence NOTIFY keySequenceChanged)
public:
    explicit GlobalShortcut(QObject *parent = nullptr);
    QString keySequence();
    void setKeySequence(const QString& pKeySequence);

signals:
    void keySequenceChanged();
    void keySequenceChangeFailed();
    void activated();

public slots:

private:
    QxtGlobalShortcut mShortcut;
    QString mKeySequence;

};

#endif // GLOBALSHORTCUT_H
