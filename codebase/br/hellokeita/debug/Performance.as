package br.hellokeita.debug{
	
	import flash.display.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.system.System;
	import flash.events.*;
	
	public class Performance{
		
		private static var instance;
		
		private var time = 0;
		private var maxMem = 0;
		private var stage:Stage;
		
		private var outputText:TextField;
		private var performanceSprite:Sprite;
		
		public function Performance(s:Stage){
			
			if(instance) return;

			stage = s;
			
			instance = this;
			
			init();
			
		}
		
		private function init(){
			
			outputText = new TextField();
			outputText.autoSize = "left";
			outputText.blendMode = "invert";
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "verdana";
			textFormat.size = 9;
			
			outputText.defaultTextFormat = textFormat;
			
			performanceSprite = new Sprite();
			
			performanceSprite.addChild(outputText);
			
			stage.addChild(performanceSprite);
			
			stage.addEventListener(Event.ENTER_FRAME, check);
		}

		private function check(ev = null){
			var t = getTimer();
			
			var fps = Math.round(1000 / (t - time));
			time = t;
			
			var mem = System.totalMemory / (1024 * 1024);
			outputText.text = "Memory: " + mem + " / " + maxMem + "\n";
			outputText.appendText("FPS: " + fps);

			performanceSprite.graphics.clear();
			performanceSprite.graphics.beginFill(0x0000ff,.5);
			performanceSprite.graphics.drawRect(0,2,maxMem * 6, 12);
			performanceSprite.graphics.beginFill(0xff0000,.8);
			performanceSprite.graphics.drawRect(0,2,mem * 6, 12);
			performanceSprite.graphics.beginFill(0xff0000,.5);
			performanceSprite.graphics.drawRect(0,14,fps * 10, 12);
			
			if(mem > maxMem) maxMem = mem;
			mem = null;
			
			stage.setChildIndex(performanceSprite, stage.numChildren - 1);
		}
	}
}