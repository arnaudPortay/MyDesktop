#include "globalshortcut.h"

/************************************************************************************************************/

GlobalShortcut::GlobalShortcut(QObject *parent) : QObject(parent), mShortcut(parent)
{
    connect(&mShortcut, &QxtGlobalShortcut::activated, [this](){ emit activated();});
}

/************************************************************************************************************/

QString GlobalShortcut::keySequence()
{
    return mKeySequence;
}

/************************************************************************************************************/

void GlobalShortcut::setKeySequence(const QString& pKeySequence)
{
    if (pKeySequence == mKeySequence)
        return;

    //Attempt to set shortcut
    if (!mShortcut.setShortcut(QKeySequence(pKeySequence)))
    {
        emit keySequenceChangeFailed();
        return;
    }

    mKeySequence = pKeySequence;
    emit keySequenceChanged();
}

/************************************************************************************************************/
