package com.hydra1983.utils {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	
	public class SocketUtil {
		public static function findFreePort(searchFrom:int = -1, searchTo:int = -1):int {
			if(searchFrom == -1 || searchTo == -1) {
				return doFindFreePort(0);
			} else {
				return findFreePortInRange(searchFrom, searchTo);
			}
			
		}
		
		private static function findFreePortInRange(searchFrom:int = -1, searchTo:int = -1):int {
			for(var i:int = 0; i < 10; i++) {
				var port:int = getRandomPort(searchFrom, searchTo);
				return doFindFreePort(port);
			}
			return -1;
		}
		
		private static function doFindFreePort(port:int):int {
			var ss:ServerSocket = new ServerSocket();
			try {
				ss.bind(port);
				return ss.localPort;
			} catch(e:Error) {
				if(ss != null) {
					try {
						ss.close()
					} catch(e:Error) {
					}
				}
			}
			return -1;
		}
		
		public static function findUnusedLocalPort(host:String, searchFrom:int, searchTo:int, callback:Function):void {
			var socketPendings:Array = [];
			var socketPortDict:Dictionary = new Dictionary(true);
			var socket:Socket;
			var returned:Boolean = false;
			var connectFailedHandler:Function = function(event:IOErrorEvent):void{
				socket = event.currentTarget as Socket;
				socket.removeEventListener(IOErrorEvent.IO_ERROR,connectFailedHandler);
				socket.removeEventListener(Event.CONNECT,connectSuccessHandler);
				
				if(!returned){
					callback(socketPortDict[socket]);
					returned = true;
				}
			};
			var connectSuccessHandler:Function = function(event:Event):void{
				socket = event.currentTarget as Socket;
				socket.removeEventListener(IOErrorEvent.IO_ERROR,connectFailedHandler);
				socket.removeEventListener(Event.CONNECT,connectSuccessHandler);
			};
			
			for(var i:int = 0; i < 10; i++) {
				var port:int = getRandomPort(searchFrom,searchTo);
				var s:Socket = new Socket();
				socketPendings.push(s);
				socketPortDict[s] = port;
				try {
					s.connect(host,port);
					s.addEventListener(IOErrorEvent.IO_ERROR,connectFailedHandler);
					s.addEventListener(Event.CONNECT,connectSuccessHandler);
				} catch(e:Error) {
					if(s != null){
						try{
							s.close();
						}catch(e:Error){							
						}
					}
				}
			}
		}
		
		private static function getRandomPort(low:int, high:int):int {
			return Math.random() * (high - low) + low;
		}
	}
}
