package sock.widget
{
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	
	import sock.Sock;
	

	/** @private */
	public class MenuBar extends MovieClip
	{
		public var communicator:Sock=Sock.getInstance();						// add the communicator
		
		public var status:String		= "";
		
		public var navBarMc:navBar = new navBar();
		
		// method
		public function MenuBar(_type:String = "client"):void
		{	
			// add soft keyboard support (Android)
			navBarMc.stringField.needsSoftKeyboard = true; 
			
			navBarMc.addEventListener(KeyboardEvent.KEY_DOWN, onEnterKey);
			navBarMc.stringField.setSelection(navBarMc.stringField.text.length,navBarMc.stringField.text.length);
			
			if (_type == "server") {
				// server app
				navBarMc.test.visible 			= false;
				navBarMc.connection.visible 	= false;
				
				// buttons
				navBarMc.clients.buttonMode 	= true;
				navBarMc.status.buttonMode 		= true;
				updateStatus();
				navBarMc.clients.addEventListener(MouseEvent.CLICK, onButtonClick);
				navBarMc.status.addEventListener(MouseEvent.CLICK, onButtonClick);
				
			} else {
				// client app
				navBarMc.clients.visible 		= false;
				navBarMc.status.visible 		= false;
				
				// buttons
				navBarMc.test.buttonMode 		= true;
				navBarMc.connection.buttonMode 	= true;
				updateConnection();
				navBarMc.test.addEventListener(MouseEvent.CLICK, onButtonClick);
				navBarMc.connection.addEventListener(MouseEvent.CLICK, onButtonClick);

			}
			
			// buttons
			navBarMc.activity.buttonMode 		= true;
			navBarMc.activity.incoming.alpha	= 0.3;
			navBarMc.activity.outgoing.alpha	= 0.3;
			navBarMc.save.buttonMode 			= true;
			navBarMc.info.buttonMode 			= true;
			navBarMc.activity.addEventListener(MouseEvent.CLICK, onButtonClick);
			navBarMc.save.addEventListener(MouseEvent.CLICK, onButtonClick);
			navBarMc.info.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			//add the navBar
			addChild(navBarMc);
			
			//setup activity interval
			setInterval(updateActivity, 125);
			
		}
		
		// send test string (chat)
		private function onEnterKey(e:KeyboardEvent):void {
			
			if (e.keyCode == 13) {
				
				var _data			:String		= navBarMc.stringField.text;
				var _divider		:String		= ': ';
				var _dataArray		:Array		= _data.split(_divider);
				
				var _case			:String		= _dataArray[0];
				
				_data = String( _data.substring(_dataArray[0].length + _divider.length));
				
				_divider = ' ';
				_dataArray = _data.split(_divider);

				communicator.send(_case, _dataArray, false, false);
				
				navBarMc.stringField.text = "varname: value(s)";
			}
		}
		
		// all button listeners
		private function onButtonClick(e:MouseEvent = null):void {
			
			if (e.currentTarget.name == "connection") {
				toggleConnection();
			} else if (e.currentTarget.name == "test") {
				test();
			} else if (e.currentTarget.name == "activity") {
				activity();
			} else if (e.currentTarget.name == "save") {
				communicator.widget.saveLog();
			} else if (e.currentTarget.name == "info") {
				info();
			} else if (e.currentTarget.name == "clients") {
				//clients();
			} else if (e.currentTarget.name == "status") {
				toggleStatus();
			} 
		}
		
		// toggle connection (client)
		private function toggleConnection():void {
			
			// toggle connection			
			if (communicator.sendSocket != null && communicator.sendSocket.connected == true || communicator.receiveSocket != null && communicator.receiveSocket.connected == true || navBarMc.connection.statusIcon.currentFrame == 2) {
				
				communicator.closeClient();
			
			} else {
				
				communicator.startClient();
			}
		}
		
		// update the connection indicator (connected, connecting, disconnected)
		public function updateConnection(_connection:String = "disconnected"):void {
			
			status = _connection;
						
			// update connection icon
			if (_connection == "connected") {
				
				// connected
				if (navBarMc.connection.statusIcon.currentFrame != 3) {
					
					navBarMc.connection.statusIcon.gotoAndStop(3);
					communicator.widget.tab.statusIcon.gotoAndStop(3);

					navBarMc.connection.title.text = "CONNECTED";
				}
				
			} else if (_connection == "connecting") {
				
				// connecting
				if (navBarMc.connection.statusIcon.currentFrame != 2) {
					
					navBarMc.connection.statusIcon.gotoAndStop(2);
					communicator.widget.tab.statusIcon.gotoAndStop(2);

					navBarMc.connection.title.text = "CONNECTING";
				}
				
			} else {
				
				// disconnected
				if (navBarMc.connection.statusIcon.currentFrame != 1) {
				
					navBarMc.connection.statusIcon.gotoAndStop(1);
					communicator.widget.tab.statusIcon.gotoAndStop(1);

					navBarMc.connection.title.text = "DISCONNECTED";
				}
			}
		}
		
		// send echo message to server
		private function test():void {
			
			// send test signal to server
			communicator.send('SOCKCLIENT', 'echo', false, false);
		}

		// update activity arrow alpha
		public function updateActivity():void {
			
			// update the activity arrows
			if (navBarMc.activity.incoming.alpha >= 0.4) {
				navBarMc.activity.incoming.alpha	-= 0.1;
			}
			if (navBarMc.activity.outgoing.alpha >= 0.4) {
				navBarMc.activity.outgoing.alpha 	-= 0.1;
			}
		}
		
		// set activity arrow alpha
		public function setActivity(type:String = 'incoming'):void {
			
			if (type == 'incoming') {
				navBarMc.activity.incoming.alpha	= 1;
			} else {
				navBarMc.activity.outgoing.alpha	= 1;
			}
		}
		
		// display activity overlay
		private function activity():void {
			
			if (communicator.widget._activityOverlay.visible == false) {
				if (communicator.widget._infoOverlay.visible == true) {
					communicator.widget._infoOverlay.visible = false;
				}
				communicator.widget._activityOverlay.visible = true;
			} else {
				communicator.widget._activityOverlay.visible = false;
			}
		}
		
		// display info overlay
		private function info():void {
		
			// display info screen
			if (communicator.widget._infoOverlay.visible == false) {
				if (communicator.widget._activityOverlay.visible == true) {
					communicator.widget._activityOverlay.visible = false;
				}
				communicator.widget._infoOverlay.visible = true;
			} else {
				communicator.widget._infoOverlay.visible = false;
			}
		}
		
		// update the client count
		public function updateClients():void {
			
			var _incomingCount:int = communicator.clientReceiveSockets.length;
			var _outgoingCount:int = communicator.clientSendSockets.length;
			
			var _totalClients:int;
			
			if (_incomingCount >= _outgoingCount) {
				_totalClients = _incomingCount;
			} else {
				_totalClients = _outgoingCount;
			}
			
			MovieClip(navBarMc).clients.clients.total.text = _totalClients;
			MovieClip(navBarMc).clients.incoming.text = _incomingCount;
			MovieClip(navBarMc).clients.outgoing.text = _outgoingCount;
			
		}
		
		// toggle status (server)
		private function toggleStatus():void {
						
			if (communicator.sendServerSocket != null && communicator.sendServerSocket.bound == true || communicator.receiveServerSocket != null && communicator.receiveServerSocket.bound == true || navBarMc.status.statusIcon.currentFrame == 2) {
				communicator.closeServer();
			} else {
				communicator.launch();
			}
		}
		
		// update the status indicator (connected, connecting, disconnected)
		public function updateStatus(_status:String = 'disconnected'):void {
		
			status = _status;
						
			if (_status == "connected") {
				// connected
				if (navBarMc.status.statusIcon.currentFrame != 3) {
					navBarMc.status.statusIcon.gotoAndStop(3);

					navBarMc.status.title.text = "CONNECTED";
				}

			} else if (_status == "connecting") {
				// connecting
				if (navBarMc.status.statusIcon.currentFrame != 2) {
					navBarMc.status.statusIcon.gotoAndStop(2);
					
					navBarMc.status.title.text = "CONNECTING";
				}
			} else {
				// disconnected
				if (navBarMc.status.statusIcon.currentFrame != 1) {
					navBarMc.status.statusIcon.gotoAndStop(1);

					navBarMc.status.title.text = "DISCONNECTED";
				}
			}
			
		}
		
	}
}