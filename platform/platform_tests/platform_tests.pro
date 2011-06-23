TARGET = platform_tests
CONFIG += console
CONFIG -= app_bundle
TEMPLATE = app

ROOT_DIR = ../..
DEPENDENCIES = platform coding base tomcrypt jansson

include($$ROOT_DIR/common.pri)

INCLUDEPATH += $$ROOT_DIR/3party/jansson/src

QT *= core network

win32 {
  LIBS += -lShell32
}

win32-g++ {
  LIBS += -lpthread
}

macx {
  LIBS += -framework CoreLocation -framework Foundation
}


SOURCES += \
    ../../testing/testingmain.cpp \
    platform_test.cpp \
    download_test.cpp \
    jansson_test.cpp \
    concurrent_runner_test.cpp \
    language_test.cpp \
