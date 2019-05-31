#include "desktoptranslator.h"
#include <QGuiApplication>

/************************************************************************************************************/

DesktopTranslator::DesktopTranslator(QObject *parent) : QObject(parent)
{
    mFrenchTranslator = new QTranslator(this);
}

/************************************************************************************************************/

DesktopTranslator::~DesktopTranslator()
{
    if (mFrenchTranslator)
    {
        delete mFrenchTranslator;
        mFrenchTranslator = nullptr;
    }
}

/************************************************************************************************************/

QString DesktopTranslator::getEmptyString()
{
    return "";
}

/************************************************************************************************************/

void DesktopTranslator::selectLanguage(QString language)
{
    if(language == QString("fr")) {
       mFrenchTranslator->load("FR_fr", ":/");
       qGuiApp->installTranslator(mFrenchTranslator);
    }

    if(language == QString("en")) {
       qGuiApp->removeTranslator(mFrenchTranslator);
    }

      emit languageChanged();
}

/************************************************************************************************************/
