#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QQuickStyle>
#include <QQmlContext>
#include <QIcon>
#include "filewrapper.h"
#include "desktoptranslator.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("MyDesktop");
    QCoreApplication::setOrganizationDomain("MyDesktop.com");
    QCoreApplication::setApplicationName("MyDesktop");
    QCoreApplication::setApplicationVersion("1.0.0");

    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");
    app.setWindowIcon(QIcon(":/img/monitor.svg"));

    QSettings::setDefaultFormat(QSettings::IniFormat);

    qmlRegisterSingletonType<FileWrapper>("Apy.file.utilies", 1,0,"File", [](QQmlEngine* engine, QJSEngine* scriptEngine)->QObject*{
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);
        FileWrapper* lSingleton = new FileWrapper();

        return lSingleton;
    });

    QQmlApplicationEngine engine;
    DesktopTranslator lTranslator;
    engine.rootContext()->setContextProperty("translator", &lTranslator);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
