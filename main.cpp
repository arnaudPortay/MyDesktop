#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QQuickStyle>
#include "filewrapper.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("MyDesktop");
    QCoreApplication::setOrganizationName("MyDesktop.com");
    QCoreApplication::setApplicationName("MyDesktop");

    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    QSettings::setDefaultFormat(QSettings::IniFormat);

    qmlRegisterSingletonType<FileWrapper>("Apy.file.utilies", 1,0,"File", [](QQmlEngine* engine, QJSEngine* scriptEngine)->QObject*{
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);
        FileWrapper* lSingleton = new FileWrapper();

        return lSingleton;
    });

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
