import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window
import "matrix.js" as Matrix

Rectangle {
	id: root
	width: Screen.width
	height: Screen.height
	color: "#020807"

	// SDDM
	property int sessionIndex: sessionSelector.currentIndex
	property alias userName: usernameField.text
	property alias password: passwordField.text
	
	// Global error state
	property bool loginError: false

	// Background
	Image {
		id: background
		source: "assets/background.png"
		anchors.fill: parent
		opacity: 0.25
		fillMode: Image.PreserveAspectCrop
	}

	// Matrix
	Canvas {
		id: matrixCanvas
		anchors.fill: parent
		opacity: 0.85

		renderTarget: Canvas.FramebufferObject
		renderStrategy: Canvas.Cooperative

		onPaint: {
			var ctx = getContext("2d");
			Matrix.matrix.setColor(root.loginError ? "#ff3b3b" : "#00ff9c");
			Matrix.matrix.drawMatrix(ctx, width, height);
		}

		Timer {
			interval: 40
			running: true
			repeat: true
			onTriggered: matrixCanvas.requestPaint()
		}
	}

	// LOGIN
	ColumnLayout {
		anchors.centerIn: parent
		spacing: 20

		Column {
			Layout.alignment: Qt.AlignHCenter
			spacing: 10
			width: implicitWidth
			
			Text {
				id: welcomeText
				text: root.loginError ? "ACCESS DENIED" : ""
				color: root.loginError ? "#ff3b3b" : "#00ff9c"
				font.pixelSize: 36
				font.bold: root.loginError ? true : false
				style: Text.Outline
				styleColor: root.loginError ? "#660000" : "#003322"
				horizontalAlignment: Text.AlignHCenter
				anchors.horizontalCenter: parent.horizontalCenter
			}
			
			Text {
				id: errorSubtitle
				visible: root.loginError
				text: ""  // Começa vazio
				color: "#ff6b6b"
				font.pixelSize: 16
				font.italic: true
				style: Text.Outline
				styleColor: "#660000"
				horizontalAlignment: Text.AlignHCenter
				anchors.horizontalCenter: parent.horizontalCenter
				
				// Função que escolhe mensagem aleatória
				function updateMessage() {
					var messages = [
						">>> ERROR 0x00FF9C <<<",
						"▸▸▸ ACCESS DENIED ◂◂◂",
						"║ INVALID CREDENTIALS ║",
						"»»» CONNECTION REJECTED BY SYSTEM «««",
						"SYSTEM: ACCESS DENIED",
						"NETWORK: INVALID CREDENTIALS",
						">> DISCONNECTED <<",
						"MAINFRAME ACCESS DENIED",
						"UNAUTHORIZED ACCESS",
						"VERIFICATION FAILED",
						"ACCESS BLOCKED BY SYSTEM",
						"YOU SHALL NOT PASS",
					]
					text = messages[Math.floor(Math.random() * messages.length)]
				}
			}
		}

		// USER
		TextField {
			id: usernameField
			placeholderText: "Username"
			placeholderTextColor: root.loginError ? "#ff8888" : "#007a5a"
			color: root.loginError ? "#ff8888" : "#00ff9c"
			selectionColor: root.loginError ? "#ff4444" : "#00cc88"   
			background: Rectangle {
				color: root.loginError ? "#1a0505" : "#03110f"
				border.color: {
					if (root.loginError) return "#ff3b3b"
					if (usernameField.activeFocus) return "#00ff9c"
					return "#004d3a"
				}
				border.width: usernameField.activeFocus ? 2 : 1
				radius: 5
			}

			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 300
			KeyNavigation.tab: passwordField
			
			onTextChanged: {
				if (root.loginError) root.loginError = false
			}
		}

		// PASSWORD
		TextField {
			id: passwordField
			placeholderText: "Password"
			placeholderTextColor: root.loginError ? "#ff8888" : "#007a5a"
			echoMode: TextInput.Password
			color: root.loginError ? "#ff8888" : "#00ff9c"
			selectionColor: root.loginError ? "#ff4444" : "#00cc88" 

			background: Rectangle {
				color: root.loginError ? "#1a0505" : "#03110f"
				border.color: {
					if (root.loginError) return "#ff3b3b"
					if (passwordField.activeFocus) return "#00ff9c"
					return "#004d3a"
				}
				border.width: passwordField.activeFocus ? 2 : 1
				radius: 5
			}

			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 300
			KeyNavigation.tab: loginButton

			Keys.onPressed: (event) => {
				if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					loginButton.clicked()
				}
			}
			
			onTextChanged: {
				if (root.loginError) root.loginError = false
			}
		}

		// BUTTON
		Button {
			id: loginButton
			text: "Connect"

			background: Rectangle {
				color: parent.pressed ? (root.loginError ? "#8b0000" : "#003322") : (root.loginError ? "#1a0505" : "#03110f")
				border.color: root.loginError ? "#ff3b3b" : "#00ff9c"
				border.width: 1
				radius: 5
			}

			contentItem: Text {
				text: "Connect"
				color: root.loginError ? "#ff6b6b" : "#00ff9c"
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}

			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 150

			onClicked: {
				root.loginError = false
				sddm.login(usernameField.text, passwordField.text, sessionIndex)
			}
		}
	}

	// SESSION SELECTOR
	ComboBox {
		id: sessionSelector
		model: sessionModel
		textRole: "name"
		font.family: "JetBrainsMono Nerd Font Propo"
		font.pixelSize: 14
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		anchors.margins: 20
		width: 225

		background: Rectangle {
			color: root.loginError ? "#1a0505" : "#020807"
			border.color: root.loginError ? "#ff3b3b" : "#00ff9c"
			border.width: 1
			radius: 5
		}

		indicator: Rectangle {
			width: 5
			height: 5
			color: root.loginError ? "#ff6b6b" : "#00ff9c"
			rotation: 45
			anchors.verticalCenter: parent.verticalCenter
			anchors.right: parent.right
			border.color: root.loginError ? "#ff3b3b" : "#00ff9c"
			border.width: 1
			anchors.rightMargin: 8
		}

		contentItem: Text {
			anchors.fill: parent
			anchors.margins: 0
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			text: sessionSelector.displayText
			color: root.loginError ? "#ff6b6b" : "#00ff9c"
			font.family: "JetBrainsMono Nerd Font Propo"
			font.pixelSize: 14
		}

		popup: Popup {
			y: sessionSelector.height
			width: sessionSelector.width
			implicitHeight: contentItem.implicitHeight
			padding: 1

			background: Rectangle {
				color: root.loginError ? "#1a0505" : "#020807"
				border.color: root.loginError ? "#ff3b3b" : "#00ff9c"
				border.width: 1
				radius: 5
			}

			contentItem: ListView {
				clip: true
				implicitHeight: contentHeight
				model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
				currentIndex: sessionSelector.highlightedIndex

				delegate: ItemDelegate {
					width: sessionSelector.width
					height: 24

					contentItem: Text {
						text: model.name
						color: root.loginError ? "#ff8888" : "#00ff9c"
						font.family: "JetBrainsMono Nerd Font Propo"
						font.pixelSize: 14
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignHCenter
						Layout.fillWidth: true
						elide: Text.ElideRight
					}

					background: Rectangle {
						color: highlighted ? (root.loginError ? "#8b0000" : "#003322") : (root.loginError ? "#1a0505" : "#020807")
					}
				}
			}
		}
	}
	
	// POWER
	Row {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: 20
		spacing: 10

		Button {
			width: 40
			height: 40
			background: Rectangle {
				color: parent.pressed ? (root.loginError ? "#8b0000" : "#003322") : (root.loginError ? "#1a0505" : "#03110f")
				border.color: root.loginError ? "#ff3b3b" : "#00ff9c"
				border.width: 1
				radius: 5
			}
			contentItem: Text {
				text: "⏻"
				color: root.loginError ? "#ff6b6b" : "#00ff9c"
				font.pixelSize: 20
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
			onClicked: sddm.powerOff()
		}

		Button {
			width: 40
			height: 40
			background: Rectangle {
				color: parent.pressed ? (root.loginError ? "#8b0000" : "#003322") : (root.loginError ? "#1a0505" : "#03110f")
				border.color: root.loginError ? "#ff3b3b" : "#00ff9c"
				border.width: 1
				radius: 5      
			}
			contentItem: Text {
				text: "↻"
				color: root.loginError ? "#ff6b6b" : "#00ff9c"
				font.pixelSize: 20
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
			onClicked: sddm.reboot()
		}
	}

	// ERROR MESSAGE
	Text {
		id: errorMessage
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.topMargin: 50
		color: "#ff3b3b"
		font.pixelSize: 16
	}

	// AUTO USER
	Instantiator {
		id: userChecker
		model: userModel

		delegate: QtObject {
			property string userName: model.name
			property bool isRoot: model.name === "root"
		}

		property var nonRootUsers: []

		onObjectAdded: function(index, object) {
			if (!object.isRoot) {
				nonRootUsers.push(object.userName)
			}
		}
	}

	Component.onCompleted: {
		Qt.callLater(function() {
			if (userChecker.nonRootUsers.length === 1) {
				usernameField.text = userChecker.nonRootUsers[0]
				passwordField.forceActiveFocus()
			} else {
				usernameField.forceActiveFocus()
			}
		})
	}
	
	QtObject {
		id: textConstants
		property string loginSuccess: "CONNECTION ESTABLISHED"
		property string loginFailed: "ACCESS DENIED - ERROR 404"
		property string noUsername: "⚠ IDENTIFICATION NOT PROVIDED ⚠"
		property string fontFamily: "JetBrainsMono Nerd Font Propo"
		property int fontSize: 32
		property string fontWeight: "bold"
		property string fontStyle: "italic"
		property bool isErrorVisible: false
	}

	// TIMER TO CLEAR ERROR MESSAGE
	Timer {
		id: errorResetTimer
		interval: 3000
		onTriggered: {
			if (errorMessage.text !== "" && errorMessage.text !== textConstants.loginSuccess) {
				errorMessage.text = ""
			}
		}
	}

	// SDDM CONNECTIONS
	Connections {
		target: sddm

		function onLoginSucceeded() {
			root.loginError = false
			errorMessage.color = "#00cc88"
			errorMessage.text = textConstants.loginSuccess
		}

		function onLoginFailed() {
			root.loginError = true
			
			// Atualiza a mensagem secundária com uma frase aleatória
			errorSubtitle.updateMessage()
			
			// Special case: empty username field
			if (usernameField.text.trim() === "") {
				errorMessage.text = textConstants.noUsername
				usernameField.forceActiveFocus()
			} else {
				errorMessage.text = ""
				passwordField.text = ""
				passwordField.forceActiveFocus()
			}
			
			errorResetTimer.start()
		}

		function onInformationMessage(message) {
			root.loginError = true
			errorMessage.color = "#ff3b3b"
			errorMessage.text = message
		}
	}
}
