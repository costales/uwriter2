/*
* uWriter http://launchpad.net/uwriter
* Copyright (C) 2015 Marcos Alvarez Costales https://launchpad.net/~costales
*
* uWriter is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 3 of the License, or
* (at your option) any later version.
*
* uWriter is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*/

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtWebEngine 1.6
import Qt.labs.settings 1.0
import "js/utils.js" as QmlJs

MainView {
    id: uwpApp

    objectName: "uwpApp"
    applicationName: "uwp.costales"

    width: units.gu(100)
    height: units.gu(70)
    anchorToKeyboard: true

	property string mapUrl: "../uwp/index.html"

    AdaptivePageLayout {
        id: mainPageStack
        property bool childPageOpened: false
        anchors.fill: parent
        primaryPageSource: pageMain
        layouts: PageColumnsLayout {
            when: width > height && mainPageStack.childPageOpened
            // column #0
            PageColumn {
                fillWidth: true
            }
            // column #1
            PageColumn {
                maximumWidth: units.gu(42)
                preferredWidth: (width / 2) - units.gu(8) // -8 hack for bq E4.5
            }
        }

		property string usContext: "messaging://"
		function executeJavaScript(code) {
			_webview.runJavaScript(code);
		}


        Page {
            id: pageMain

            property bool btnsEnabled: false

            header: PageHeader {
                id: pageHeader
                title: "Writer"
                StyleHints {
                    foregroundColor: '#ffffff'
                    backgroundColor: '#ffb84f'
                    dividerColor: UbuntuColors.slate
                }
            }

			WebEngineProfile {
				id: webcontext
			}

			WebEngineView {
				id: _webview
				anchors.fill: parent
				profile: webcontext
				url: uwpApp.mapUrl
				settings.localContentCanAccessFileUrls: true
				settings.localContentCanAccessRemoteUrls: true
				settings.javascriptEnabled: true
				settings.accelerated2dCanvasEnabled: true
				settings.focusOnNavigationEnabled: true
				settings.webGLEnabled: true
				settings.allowWindowActivationFromJavaScript: true

				onNavigationRequested: {
					var url = request.url.toString().toLowerCase().split("/");
					switch (url[2]) {
						case "settopmargin":
							mainPageStack.executeJavaScript("top_margin(" + pageHeader.height + ")");
                            break;
                    }
					if (typeof url[0] != "undefined" && url[0].includes("http"))
						request.action = WebEngineNavigationRequest.IgnoreRequest;
                }

				onJavaScriptConsoleMessage: {
					var msg = "[JS] (%1:%2) %3".arg(sourceID).arg(lineNumber).arg(message)
				    console.log(msg)
				}
				
				Connections {
					onLoadingChanged: {
						if (loadRequest.status === WebEngineView.LoadSucceededStatus && !mainPageStack.onLoadingExecuted) {
                            pageMain.btnsEnabled = true;
                            mainPageStack.executeJavaScript("top_margin(" + pageHeader.height + ")");
                        }
                    }
					onFeaturePermissionRequested: {
						console.log("grantFeaturePermission", feature)
						_webview.grantFeaturePermission(securityOrigin, feature, true);
					}
                }
            }
        }
    }
}
