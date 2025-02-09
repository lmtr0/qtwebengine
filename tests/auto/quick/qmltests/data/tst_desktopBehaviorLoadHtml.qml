// Copyright (C) 2016 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick
import QtTest
import QtWebEngine

TestWebEngineView {
    id: webEngineView
    width: 200
    height: 400
    focus: true

    property string lastUrl

    SignalSpy {
        id: linkHoveredSpy
        target: webEngineView
        signalName: "linkHovered"
    }

    onLinkHovered: function(hoveredUrl) {
        webEngineView.lastUrl = hoveredUrl
    }

    TestCase {
        name: "DesktopWebEngineViewLoadHtml"

        // Delayed windowShown to workaround problems with Qt5 in debug mode.
        when: false
        Timer {
            running: parent.windowShown
            repeat: false
            interval: 1
            onTriggered: parent.when = true
        }

        function init() {
            webEngineView.lastUrl = ""
            linkHoveredSpy.clear()
        }

        function test_baseUrlAfterLoadHtml() {
            linkHoveredSpy.clear()
            compare(linkHoveredSpy.count, 0)
            mouseMove(webEngineView, 150, 300)
            webEngineView.loadHtml("<html><head><title>Test page with huge link area</title></head><body><a title=\"A title\" href=\"test1.html\"><img width=200 height=200></a></body></html>", "http://www.example.foo.com")
            verify(webEngineView.waitForLoadSucceeded())

            // We get a linkHovered signal with empty hoveredUrl after page load
            linkHoveredSpy.wait()
            compare(linkHoveredSpy.count, 1)
            compare(webEngineView.lastUrl, "")

            compare(webEngineView.url, "http://www.example.foo.com/")
            mouseMove(webEngineView, 100, 100)
            linkHoveredSpy.wait()
            compare(linkHoveredSpy.count, 2)
            compare(webEngineView.lastUrl, "http://www.example.foo.com/test1.html")
        }
    }
}
