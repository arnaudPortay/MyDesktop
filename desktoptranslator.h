#ifndef DESKTOPTRANSLATOR_H
#define DESKTOPTRANSLATOR_H

#include <QObject>
#include <QTranslator>

class DesktopTranslator : public QObject
{
    Q_OBJECT
    // Hack to get the qml engine to re-evaluate the strings
    Q_PROPERTY(QString emptyString READ getEmptyString NOTIFY languageChanged)

public:
    explicit DesktopTranslator(QObject *parent = nullptr);
    virtual ~DesktopTranslator();

    QString getEmptyString();
    Q_INVOKABLE void selectLanguage(QString language);

signals:
    void languageChanged();

private:
    QTranslator* mFrenchTranslator;
};

#endif // DESKTOPTRANSLATOR_H
