/**
 * Remoting Interface
 * Easy way to call remoting functions... it's not a big deal, but... it's still easy
 *
 * @author		keita
 * @version		0.1
 */

package br.hellokeita.net{
	import flash.net.Responder;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	
	public class RemotingInterface{
		protected var rs = new NetConnection();
		
		public function RemotingInterface(url, encoding = "AMF0"):void{
			if(ObjectEncoding[encoding] === undefined) encoding = "AMF0";
			this.rs.objectEncoding = ObjectEncoding[encoding];
			rs.connect(url);
		}
		public function call(method:String, obj:Object, ...params){
			var responder:Responder = new Responder(obj.onResult, obj.onFault);
			params.unshift(method, responder);
			rs.call.apply(this, params);
		}
	}
}