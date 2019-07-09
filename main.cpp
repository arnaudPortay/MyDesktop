#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QQuickStyle>
#include <QQmlContext>
#include <QIcon>
#include "filewrapper.h"
#include "desktoptranslator.h"
#include "clipboardwrapper.h"

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication::setOrganizationName("MyDesktop");
    QApplication::setOrganizationDomain("MyDesktop.com");
    QApplication::setApplicationName("MyDesktop");
    QApplication::setApplicationVersion("1.1.0");

    QApplication app(argc, argv);

    QQuickStyle::setStyle("Material");
    app.setWindowIcon(QIcon(":/img/monitor.svg"));

    QSettings::setDefaultFormat(QSettings::IniFormat);

    qmlRegisterSingletonType<FileWrapper>("Apy.file.utilies", 1,0,"File", [](QQmlEngine* engine, QJSEngine* scriptEngine)->QObject*{
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);
        FileWrapper* lSingleton = new FileWrapper();

        return lSingleton;
    });

    qmlRegisterSingletonType<ClipboardWrapper>("Apy.clipboard", 1, 0, "Clipboard", [](QQmlEngine* engine, QJSEngine* scriptEngine)->QObject*{
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);

        ClipboardWrapper* lSingleton = new ClipboardWrapper();

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
