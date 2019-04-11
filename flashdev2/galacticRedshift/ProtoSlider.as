
package {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	import flash.events.TextEvent;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent; 
	import flash.events.Event;
	
	import flash.ui.Keyboard;
	
	 
	
	public class ProtoSlider extends Sprite {
		
		protected var _labelSP:Sprite;
		protected var _unitsSP:Sprite;
		protected var _barSP:Sprite;
		protected var _grabberSP:Sprite;
		protected var _fieldSP:Sprite;
		protected var _valueTextField:TextField;
		
		public function ProtoSlider() {
			
			_labelSP = new Sprite();
			addChild(_labelSP);
			
			_unitsSP = new Sprite();
			addChild(_unitsSP);
			
			_barSP = new Sprite();
			addChild(_barSP);
			
			_grabberSP = new Sprite();
			addChild(_grabberSP);
			
			_fieldSP = new Sprite();
			addChild(_fieldSP);
			
			_valueTextField = new TextField();
			addChild(_valueTextField);
			
			_valueTextField.restrict = "0-9.Ee+\\-";
			_valueTextField.addEventListener(Event.CHANGE, onValueTextFieldChanged);
			_valueTextField.addEventListener(FocusEvent.FOCUS_OUT, onValueTextFieldFocusOut);
			_valueTextField.addEventListener(KeyboardEvent.KEY_DOWN, onValueTextFieldKeyDown);

public function onValueTextFieldChanged(...ignored):void {
	activateField();
}

public function onValueTextFieldFocusOut(...ignored):void {
	if (active) {
		inactivateField();		
		if (_grabberSP.hitTestPoint(stage.mouseX, stage.mouseY, true) || _barSP.hitTestPoint(stage.mouseX, stage.mouseY, true)) updateSynchronization();
		else setValue(parseFloat(this.text), true);
	}
}

public function onValueTextFieldKeyDown(evt:KeyboardEvent):void {
	if (evt.keyCode==Keyboard.ENTER)) {
		inactivateField();
		setValue(parseFloat(this.text), true);
	}	
}
					
		
			_barSP.tabEnabled = false;
			_barSP.useHandCursor = false;
			//_barSP.addEventListener(MouseEvent.MOUSE_DOWN, onBarMouseDown);


protected var _barMouseDownTimeLast:Number;
protected var _barMouseDownWaitTime:Number;

public function onBarMouseDown(...ignored):void {
	var mValue:Number = _controller.getValueObjectFromValue(_controller.getValueFromParameter(parent.mouseX)).value;
	if (mValue<_controller.value) incrementValue(-1, true);
	else if (mValue>_controller.value) incrementValue(1, true);
	_barMouseDownTimeLast = getTimer();
	_barMouseDownWaitTime = _barMouseDownTimeLast + continuousChangeDelay;		
	stage.addEventListener(MouseEvent.MOUSE_UP, onBarMouseUp);
	stage.addEventListener(Event.ENTER_FRAME, onBarEnterFrame);
}

public function onBarMouseUp(...ignored):void {
	stage.removeEventListener(MouseEvent.MOUSE_UP, onBarMouseUp);
	stage.removeEventListener(Event.ENTER_FRAME, onBarEnterFrame);
}

public function onBarEnterFrame(...ignored):void {
	var timeNow:Number = getTimer();
	if (timeNow>_barMouseDownWaitTime) {
		var ticks:Number = continuousChangeRate*(timeNow-_barMouseDownTimeLast);
		var mValueObj:Object = _controller.getValueObjectFromValue(_controller.getValueFromParameter(parent.mouseX));
		var nValueObj:Object;
		if (mValueObj.value<_controller.value) {
			nValueObj = _controller.getIncrementedValueObject(null, -ticks);
			if (nValueObj.value<=mValueObj.value) setValueByValueObject(mValueObj, true);
			else setValueByValueObject(nValueObj, true);
		}
		else if (mValueObj.value>_controller.value) {
			nValueObj = _controller.getIncrementedValueObject(null, ticks);
			if (nValueObj.value>=mValueObj.value) setValueByValueObject(mValueObj, true);
			else setValueByValueObject(nValueObj, true);
		}
	}		
	_barMouseDownWaitTime = timeNow;
}

			
	_grabberSP.focusRect = false;
	_grabberSP.addEventListener(FocusEvent.FOCUS_IN, onGrabberFocusIn);
	_grabberSP.addEventListener(FocusEvent.FOCUS_OUT, onGrabberFocusOut);
	_grabberSP.addEventListener(KeyboardEvent.KEY_DOWN, onGrabberKeyDown);


protected var _normalBorderSH:Shape;
protected var _tabbedBorderSH:Shape;

public function onGrabberFocusIn(...ignored):void {
	_normalBorderSH.visible = false;
	_tabbedBorderSH.visible = true;
	
	stage.addEventListener(MouseEvent.MOUSE_DOWN, onGrabberFocusOut);
	stage.addEventListener(MouseEvent.MOUSE_MOVE, onGrabberFocusOut);
	stage.addEventListener(Keyboard
	this.onKeyDown = this.onKeyDownFunc;
}
public function onGrabberFocusOut(...ignored):void {
	this.normalBorderMC._visible = true;
	this.tabbedBorderMC._visible = false;
	delete this.onMouseDown;
	delete this.onMouseMove;
	delete this.onKeyDown;
}
public function onGrabberKeyDown(...ignored):void {
	var c = this._parent.controller;
	if (Key.isDown(Key.LEFT)) {
		var vObj = c.getIncrementedValueObject(null, -1);
		if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
	}
	else if (Key.isDown(Key.RIGHT)) {
		var vObj = c.getIncrementedValueObject(null, 1);
		if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
	}
}
	
	this.grabberMC.useHandCursor = false;
	this.grabberMC.onPressFunc = function() {
		this.xOffset = this._parent._xmouse - this._x;
		this.onMouseMove = this.onMouseMoveFunc;
	};
	this.grabberMC.onMouseMoveFunc = function() {
		var c = this._parent.controller;
		var vObj = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse-this.xOffset));
		if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
		updateAfterEvent();
	};
	this.grabberMC.onRelease = this.grabberMC.onReleaseOutside = function() {
		delete this.onMouseMove;
	};
	
	this.grabberMC.createEmptyMovieClip("tabbedBorderMC", 1);
	this.grabberMC.createEmptyMovieClip("normalBorderMC", 2);
	this.grabberMC.createEmptyMovieClip("fillMC", 3);
	this.grabberMC.tabbedBorderMC._visible = false;
	
	this.fieldMC.createEmptyMovieClip("backgroundMC", 1);
	this.fieldMC.createEmptyMovieClip("fillMC", 2);
	
	this.fieldBackgroundColorObj = new Color(this.fieldMC.fillMC);
	
	delete this.value;
	
	if (this.showField==undefined) this.showField = true;
	if (this.labelText==undefined) this.labelText = "";
	if (this.unitsText==undefined) this.unitsText = "";
	if (this.minValue==undefined) this.minValue = 1;
	if (this.maxValue==undefined) this.maxValue = 10;
	if (this.initValue==undefined) this.initValue = 5;
	if (this.scalingMode==undefined) this.scalingMode = "linear";
	if (this.precisionMode==undefined) this.precisionMode = "fixed digits";
	if (this.precision==undefined) this.precision = 2;
	if (this.userEnabled==undefined) this.userEnabled = true;
	if (this.maxChars==undefined) this.maxChars = 5;
	if (this.fieldWidth==undefined) this.fieldWidth = 60;
	if (this.barSpacing==undefined) this.barSpacing = 40;
	if (this.fontsMovieClip==undefined) this.fontsMovieClip = "Slider Fonts v6";
	if (this.labelAndUnitsTextColor==undefined) this.labelAndUnitsTextColor = 0x000000;
	if (this.fieldNormalTextColor==undefined) this.fieldNormalTextColor = 0x000000;
	if (this.fieldActiveTextColor==undefined) this.fieldActiveTextColor = 0x000000;
	if (this.fieldDisabledTextColor==undefined) this.fieldDisabledTextColor = 0x404040;
	if (this.fieldMargin==undefined) this.fieldMargin = 5;
	if (this.fieldRoundedness==undefined) this.fieldRoundedness = 0.4;
	if (this.fieldBorderThickness==undefined) this.fieldBorderThickness = 1;
	if (this.fieldBorderColor==undefined) this.fieldBorderColor = 0xc0c0c0;
	if (this.fieldNormalBackgroundColor==undefined) this.fieldNormalBackgroundColor = 0xffffff;
	if (this.fieldActiveBackgroundColor==undefined) this.fieldActiveBackgroundColor = 0xffffee;
	if (this.fieldDisabledBackgroundColor==undefined) this.fieldDisabledBackgroundColor = 0xf4f4f4;
	if (this.barMargin==undefined) this.barMargin = 7;
	if (this.barThickness==undefined) this.barThickness = 6;
	if (this.barRoundedness==undefined) this.barRoundedness = 0.7;
	if (this.barBorderThickness==undefined) this.barBorderThickness = 1;
	if (this.barBorderColor==undefined) this.barBorderColor = 0xc0c0c0;
	if (this.barTopColor==undefined) this.barTopColor = 0xfafafa;
	if (this.barBottomColor==undefined) this.barBottomColor = 0xd0d0d0;
	if (this.grabberWidth==undefined) this.grabberWidth = 9;
	if (this.grabberHeight==undefined) this.grabberHeight = 17;
	if (this.grabberRoundedness==undefined) this.grabberRoundedness = 0.8;
	if (this.grabberNormalBorderThickness==undefined) this.grabberNormalBorderThickness = 1;
	if (this.grabberNormalBorderColor==undefined) this.grabberNormalBorderColor = 0xc0c0c0;
	if (this.grabberTabbedBorderThickness==undefined) this.grabberTabbedBorderThickness = 2;
	if (this.grabberTabbedBorderColor==undefined) this.grabberTabbedBorderColor = 0xb0b0b0;
	if (this.grabberMiddleColor==undefined) this.grabberMiddleColor = 0xf4f4f4;
	if (this.grabberSideColor==undefined) this.grabberSideColor = 0xe0e0e0;
	if (this.continuousChangeDelay==undefined) this.continuousChangeDelay = 500;
	if (this.continuousChangeRate==undefined) this.continuousChangeRate = 50/1000;
	if (this.sliderRange==undefined) {
		if (this.showField) this.sliderRange = this._width - this.fieldWidth - this.barSpacing - 2*this.barMargin;
		else this.sliderRange = this._width - this.barSpacing - 2*this.barMargin;
		if (this.sliderRange<(3*this.grabberWidth)) this.sliderRange = 3*this.grabberWidth;
	}
	
	this.placeholderMC._visible = false;
	this.placeholderMC.swapDepths(121212);
	this.placeholderMC.removeMovieClip();
	this._xscale = 100;
	this._yscale = 100;
	
	// in this component changing most properties requires calling the update function
	// afterwards to reflect the changes; in fact, there are several sub-functions that may
	// or may not need to be called depending on the properties that have changed; the 
	// updateList array keeps track which functions should be called when the properties are
	// are changed (there is a watch function set on all the relevant properties); then, when
	// the update function is called it goes through the list and calls all the sub-functions
	// that have been flagged
	
	// create the updateList array for this instance of the component
	var fL = this.functionsList;
	var uL = [];
	for (var i=0; i<fL.length; i++) uL.push({name: fL[i], call: true});
	this.updateList = uL;
	
	// set the watch functions for the necessary properties; note that while the updateList array
	// identifies functions by name, the watch function flags them by index; see the functionsList 
	// and propertiesList arrays defined on the prototype below for more details
	var pL = this.propertiesList;
	for (var i=0; i<pL.length; i++) this.watch(pL[i].property, this.registerChange, pL[i].functionIndices);
	
	// to avoid redundant refreshes of the controller object, we call an update now
	// and then synchronize after creating the controller
	
	this.update();
	
	var initObj = {};
	initObj.scalingMode = this.scalingMode;
	initObj.valueFormat = this.precisionMode;
	initObj.valueDigits = this.precision;
	initObj.minValue = this.minValue;
	initObj.maxValue = this.maxValue;
	if (this.showField) initObj.minParameter = this.fieldWidth + this.barSpacing + this.barMargin;
	else initObj.minParameter = this.barSpacing + this.barMargin;
	initObj.maxParameter = initObj.minParameter + this.sliderRange;
	initObj.value = this.initValue;
	this.controller = new SliderLogicClassV6(initObj);
	
	this.updateSynchronization();
	
	this.inactivateField();		}
		
		
		public var sliderRange:Number = 150;			
		public var showField:Boolean = true;
		public var labelText:String = "";
		public var unitsText:String = "";
		public var minValue:Number = 1;
		public var maxValue:Number = 10;
		public var initValue:Number = 5;
		public var scalingMode:String = "linear";
		public var precisionMode:String = "fixed digits";
		public var precision:Number = 2;
		public var userEnabled:Boolean = true;
		public var maxChars:uint = 5;
		public var fieldWidth:Number = 60;
		public var barSpacing:Number = 40;
		public var fontsMovieClip:String = "Slider Fonts v6";
		public var labelAndUnitsTextColor:uint = 0x000000;
		public var fieldNormalTextColor:uint = 0x000000;
		public var fieldActiveTextColor:uint = 0x000000;
		public var fieldDisabledTextColor:uint = 0x404040;
		public var fieldMargin:Number = 5;
		public var fieldRoundedness:Number = 0.4;
		public var fieldBorderThickness:Number = 1;
		public var fieldBorderColor:uint = 0xc0c0c0;
		public var fieldNormalBackgroundColor:uint = 0xffffff;
		public var fieldActiveBackgroundColor:uint = 0xffffee;
		public var fieldDisabledBackgroundColor:uint = 0xf4f4f4;
		public var barMargin:Number = 7;
		public var barThickness:Number = 6;
		public var barRoundedness:Number = 0.7;
		public var barBorderThickness:Number = 1;
		public var barBorderColor:uint = 0xc0c0c0;
		public var barTopColor:uint = 0xfafafa;
		public var barBottomColor:uint = 0xd0d0d0;
		public var grabberWidth:Number = 9;
		public var grabberHeight:Number = 17;
		public var grabberRoundedness:Number = 0.8;
		public var grabberNormalBorderThickness:Number = 1;
		public var grabberNormalBorderColor:uint = 0xc0c0c0;
		public var grabberTabbedBorderThickness:Number = 2;
		public var grabberTabbedBorderColor:uint = 0xb0b0b0;
		public var grabberMiddleColor:uint = 0xf4f4f4;
		public var grabberSideColor:uint = 0xe0e0e0;
		public var continuousChangeDelay:Number = 500;
		public var continuousChangeRate:Number = 50/1000;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		public function updateBar():void {
			var y:Number = barThickness/2;
			var by:Number = y + barBorderThickness;
			var x:Number = sliderRange + 2*barMargin;
			var rnd:Number = barRoundedness;
			var mc:Graphics = barMC.graphics;
			mc.clear();
			if (rnd<=0) {
				// square ends
				var bx1:Number = -barBorderThickness;
				var bx2:Number = x + barBorderThickness;
				mc.moveTo(bx1, by);
				mc.beginFill(barBorderColor);
				mc.lineTo(bx2, by);
				mc.lineTo(bx2, -by);
				mc.lineTo(bx1, -by);
				mc.lineTo(bx1, by);
				mc.endFill();
				mc.moveTo(0, y);
				mc.beginGradientFill("linear", [barTopColor, barBottomColor], [100, 100], [0, 0xff], {matrixType: "box", x: 0, y: -y, w: 1, h: 2*y, r: Math.PI/2});
				mc.lineTo(x, y);
				mc.lineTo(x, -y);
				mc.lineTo(0, -y);
				mc.lineTo(0, y);
				mc.endFill();
			}
			else if (rnd>=1) {
				// semicircle ends
				mc.moveTo(0, by);
				mc.beginFill(barBorderColor);
				mc.lineTo(x, by);
				this.drawHalfCircle(mc, x, 0, by, 3);
				mc.lineTo(0, -by);
				this.drawHalfCircle(mc, 0, 0, by, 1);
				mc.endFill();
				mc.moveTo(0, y);
				mc.beginGradientFill("linear", [barTopColor, barBottomColor], [100, 100], [0, 0xff], {matrixType: "box", x: 0, y: -y, w: 1, h: 2*y, r: Math.PI/2});
				mc.lineTo(x, y);
				this.drawHalfCircle(mc, x, 0, y, 3);
				mc.lineTo(0, -y);
				this.drawHalfCircle(mc, 0, 0, y, 1);
				mc.endFill();
			}
			else {
				// partially rounded ends
				var r:Number = y*rnd;
				var br:Number = r + barBorderThickness;
				var dy:Number = y - r;
				mc.moveTo(0, by);
				mc.beginFill(barBorderColor);
				mc.lineTo(x, by);
				this.drawQuarterCircle(mc, x, dy, br, 3);
				mc.lineTo(x+br, -dy);
				this.drawQuarterCircle(mc, x, -dy, br, 0);
				mc.lineTo(0, -by);
				this.drawQuarterCircle(mc, 0, -dy, br, 1);
				mc.lineTo(-br, dy);
				this.drawQuarterCircle(mc, 0, dy, br, 2);
				mc.endFill();
				mc.moveTo(0, y);
				mc.beginGradientFill("linear", [barTopColor, barBottomColor], [100, 100], [0, 0xff], {matrixType: "box", x: 0, y: -y, w: 1, h: 2*y, r: Math.PI/2});
				mc.lineTo(x, y);
				this.drawQuarterCircle(mc, x, dy, r, 3);
				mc.lineTo(x+r, -dy);
				this.drawQuarterCircle(mc, x, -dy, r, 0);
				mc.lineTo(0, -y);
				this.drawQuarterCircle(mc, 0, -dy, r, 1);
				mc.lineTo(-r, dy);
				this.drawQuarterCircle(mc, 0, dy, r, 2);
				mc.endFill();
			}
		}

		public function updateGrabber():void {
			var x:Number = grabberWidth/2;
			var y:Number = grabberHeight/2;
			var rnd:Number = this.grabberRoundedness;
			var tbmc:Graphics = this.grabberMC.tabbedBorderMC;
			tbmc.clear();
			var nbmc:Graphics = this.grabberMC.normalBorderMC;
			nbmc.clear();
			var fmc:Graphics = this.grabberMC.fillMC;
			fmc.clear();
			var bx:Number, by:Number, br:Number;
			
			if (rnd<=0) {
				// square ends
				bx = x + this.grabberTabbedBorderThickness;
				by = y + this.grabberTabbedBorderThickness;
				tbmc.moveTo(bx, by);
				tbmc.beginFill(this.grabberTabbedBorderColor);
				tbmc.lineTo(bx, -by);
				tbmc.lineTo(-bx, -by);
				tbmc.lineTo(-bx, by);
				tbmc.lineTo(bx, by);
				tbmc.endFill();
				
				bx = x + this.grabberNormalBorderThickness;
				by = y + this.grabberNormalBorderThickness;
				nbmc.moveTo(bx, by);
				nbmc.beginFill(this.grabberNormalBorderColor);
				nbmc.lineTo(bx, -by);
				nbmc.lineTo(-bx, -by);
				nbmc.lineTo(-bx, by);
				nbmc.lineTo(bx, by);
				nbmc.endFill();
				
				fmc.moveTo(x, y);
				fmc.beginGradientFill("linear", [this.grabberSideColor, this.grabberMiddleColor, this.grabberSideColor], [100, 100, 100], [0, 0x80, 0xff], {matrixType: "box", x: -x, y: -y, w: 2*x, h: 1, r: 0});
				fmc.lineTo(x, -y);
				fmc.lineTo(-x, -y);
				fmc.lineTo(-x, y);
				fmc.lineTo(x, y);
				fmc.endFill();
			}
			else if (rnd>=1) {
				// semicircle ends		
				bx = x + this.grabberTabbedBorderThickness
				tbmc.moveTo(bx, y);
				tbmc.beginFill(this.grabberTabbedBorderColor);
				tbmc.lineTo(bx, -y);
				this.drawHalfCircle(tbmc, 0, -y, bx, 0);
				tbmc.lineTo(-bx, y);
				this.drawHalfCircle(tbmc, 0, y, bx, 2);
				tbmc.endFill();
				
				bx = x + this.grabberNormalBorderThickness;
				nbmc.moveTo(bx, y);
				nbmc.beginFill(this.grabberNormalBorderColor);
				nbmc.lineTo(bx, -y);
				this.drawHalfCircle(nbmc, 0, -y, bx, 0);
				nbmc.lineTo(-bx, y);
				this.drawHalfCircle(nbmc, 0, y, bx, 2);
				nbmc.endFill();
				
				fmc.moveTo(x, y);
				fmc.beginGradientFill("linear", [this.grabberSideColor, this.grabberMiddleColor, this.grabberSideColor], [100, 100, 100], [0, 0x80, 0xff], {matrixType: "box", x: -x, y: -y, w: 2*x, h: 1, r: 0});
				fmc.lineTo(x, -y);
				this.drawHalfCircle(fmc, 0, -y, x, 0);
				fmc.lineTo(-x, y);
				this.drawHalfCircle(fmc, 0, y, x, 2);
				fmc.endFill();
			}
			else {
				// partially rounded ends
				var r:Number = x*rnd;
				var dx:Number = x - r;
				bx = x + this.grabberTabbedBorderThickness;
				br = r + this.grabberTabbedBorderThickness;
				tbmc.moveTo(bx, y);
				tbmc.beginFill(this.grabberTabbedBorderColor);
				tbmc.lineTo(bx, -y);
				this.drawQuarterCircle(tbmc, dx, -y, br, 0);
				tbmc.lineTo(-dx, -y-br);
				this.drawQuarterCircle(tbmc, -dx, -y, br, 1);
				tbmc.lineTo(-bx, y);
				this.drawQuarterCircle(tbmc, -dx, y, br, 2);
				tbmc.lineTo(dx, y+br);
				this.drawQuarterCircle(tbmc, dx, y, br, 3);
				tbmc.endFill();
				
				bx = x + this.grabberNormalBorderThickness;
				br = r + this.grabberNormalBorderThickness;
				nbmc.moveTo(bx, y);
				nbmc.beginFill(this.grabberNormalBorderColor);
				nbmc.lineTo(bx, -y);
				this.drawQuarterCircle(nbmc, dx, -y, br, 0);
				nbmc.lineTo(-dx, -y-br);
				this.drawQuarterCircle(nbmc, -dx, -y, br, 1);
				nbmc.lineTo(-bx, y);
				this.drawQuarterCircle(nbmc, -dx, y, br, 2);
				nbmc.lineTo(dx, y+br);
				this.drawQuarterCircle(nbmc, dx, y, br, 3);
				nbmc.endFill();
				
				fmc.moveTo(x, y);
				fmc.beginGradientFill("linear", [this.grabberSideColor, this.grabberMiddleColor, this.grabberSideColor], [100, 100, 100], [0, 0x80, 0xff], {matrixType: "box", x: -x, y: -y, w: 2*x, h: 1, r: 0});
				fmc.lineTo(x, -y);
				this.drawQuarterCircle(fmc, dx, -y, r, 0);
				fmc.lineTo(-dx, -y-r);
				this.drawQuarterCircle(fmc, -dx, -y, r, 1);
				fmc.lineTo(-x, y);
				this.drawQuarterCircle(fmc, -dx, y, r, 2);
				fmc.lineTo(dx, y+r);
				this.drawQuarterCircle(fmc, dx, y, r, 3);
				fmc.endFill();
			}
		}
		
		
		
//	
//p.updateFonts = function() {
//	// updateTextColors (hence updateLabelText, updateUnitsText, updateFieldTextFormat and
//	// updateSynchronization), updateField (hence updateLabelAndUnitsPositions), and updateEnabled
//	// need to be called after this function
//	var mc = this.attachMovie(this.fontsMovieClip, "fontsMC", 123456, {_visible: false});
//	if (mc.value!=undefined) {
//		this.embedValueFont = mc.value.embedFonts;
//		this.valueTextFormat = mc.value.getTextFormat();
//	}
//	else {
//		this.embedValueFont = false;
//		this.valueTextFormat = new TextFormat("Verdana", 12, null, null, false);
//	}
//	this.valueTextFormat.align = "center";
//	if (mc.valueWhileEditing!=undefined) {
//		this.embedValueWhileEditingFont = mc.valueWhileEditing.embedFonts;
//		this.valueWhileEditingTextFormat = mc.valueWhileEditing.getTextFormat();			
//	}
//	else {
//		this.embedValueWhileEditingFont = false;
//		this.valueWhileEditingTextFormat = new TextFormat("Verdana", 12, null, null, true);			
//	}
//	this.valueWhileEditingTextFormat.align = "center";
//	if (mc.labelAndUnit!=undefined) {
//		this.embedLabelAndUnitFont = mc.labelAndUnit.embedFonts;
//		this.labelAndUnitTextFormat = mc.labelAndUnit.getTextFormat();			
//	}
//	else {
//		this.embedLabelAndUnitFont = false;
//		this.labelAndUnitTextFormat = new TextFormat("Verdana", 12);			
//	}
//	
//	var tf = this.labelAndUnitTextFormat;
//	
//	var outerRadius = Math.round(tf.size/4);
//	if (outerRadius<3) outerRadius = 3;
//	if (outerRadius<5) var innerRadius = 1;
//	else var innerRadius = 0.3*outerRadius;
//	this.solarSymbolOuterRadius = outerRadius;
//	this.solarSymbolInnerRadius = innerRadius;
//	this.solarSymbolYPosition = (tf.getTextExtent("8").height/2) - outerRadius;
//	this.solarSymbolSpacing = outerRadius + 2*innerRadius;
//	
//	if (tf.size<=10) this.scriptsSizeRatio = 1.25;
//	else if (tf.size<=12 || tf.size==null) this.scriptsSizeRatio = 1.3;
//	else if (tf.size<=14) this.scriptsSizeRatio = 1.4;
//	else if (tf.size<=16) this.scriptsSizeRatio = 1.5;
//	else if (tf.size<=20) this.scriptsSizeRatio = 1.7;
//	else if (tf.size>=30) this.scriptsSizeRatio = 2.0;
//};
//		
//
//		
		
		/*				
public function displayText(textString:String, options:Object=null) {
	// This function takes a string and adds its text to screen. It allows a convenient way to display
	// superscripts and subscripts in a line of text by using <sup></sup> and <sub></sub> tags.
	
	// More precisely, this function creates and positions textfields as needed in a wrapper movieclip it
	// creates. A reference to this wrapper movieclip is returned by the function. The property textWidth
	// is added to the wrapper movieclip and gives the total width of the line of text.
	
	// Arguments of the function:
	// textString contains the text to display
	// options is an optional object with any of the following properties:
	//   depth - depth to use for the wrapper movieclip containing the text; if no depth
	//     is provided a depth of 913001 or greater is used (a global variable is used to
	//     ensure that subsequent textfields don't overwrite each other)
	//   mc - a reference to the movieclip in which to add the text wrapper movieclip; if
	//     it is not provided the wrapper movieclip will be added to 'this'
	//   name - the name to give the text wrapper movieclip; if it is not provided the name
	//     will be the string "_textWrapper_" plus depth (e.g. "_textWrapper_913001")
	//   x y - if x or y are provided the wrapper movieclip will be positioned at those coordinates;
	//     otherwise the wrapper is placed at the origin
	//   vAlign - this property determines how the text is arranged vertically with respect to the
	//     wrapper movieclip's origin; it can be either "center" (default), "top", or "bottom"
	//   hAlign - this property determines how the text is arranged horizontally with respect to the
	//     wrapper movieclip's origin; it can be either "center" (default), "left", or "right"
	//   embedFonts - if this is provided all the textfields will have their embedFonts property
	//     set to this value; if this is set to true all the necessary characters of the font specified
	//     in the textFormat parameter must be exported with the movie; the default is false
	//   textFormat - the TextFormat object to use for the text; if it is not provided the default
	//     format generated with createTextField is used (12pt Times); this style applies to both
	//     the sub/superscript and normal textfields, with the exception that sub/superscripts are
	//     rendered at a smaller font size determined by sizeRatio
	//   sizeRatio - the ratio of the normal font size (which is specified in the textFormat parameter)
	//     to the sub/superscript font size; the default is 1.5
	//   subscriptPosition - this affects the positioning of the subscripts; the default is 0px;
	//     negative values bring the subscripts closer to the center of the line, while positive
	//     values push the subscripts away from the center (in pixel units)
	//   superscriptPosition - this affects the positioning of the superscripts; the default is 0px;
	//     negative values bring the superscripts closer to the center of the line, while positive
	//     values push the superscripts away from the center (in pixel units)
	//   extraSpacing - sometimes it seems that the gap between sub/superscript and normal
	//     textfields is too narrow, so extraSpacing was introduced to put a little bit of
	//     extra room between fields; the default is 0.5px
	
	textString = String(textString);
	
	if (options.depth!=undefined) var mcDepth = options.depth;
	else if (_global._displayedTextLastDepthUsed!=undefined) var mcDepth = ++_global._displayedTextLastDepthUsed;
	else var mcDepth = _global._displayedTextLastDepthUsed = 913001;
	
	if (options.name!=undefined) var mcName = options.name;
	else var mcName = "_textWrapper_" + mcDepth;
	
	if (options.mc!=undefined) var mc = options.mc.createEmptyMovieClip(mcName, mcDepth);
	else var mc = this.createEmptyMovieClip(mcName, mcDepth);
	
	if (options.x!=undefined) mc._x = options.x;
	if (options.y!=undefined) mc._y = options.y;
	
	if (options.embedFonts!=undefined) var embedFonts = options.embedFonts;
	else var embedFonts = false;
	
	if (options.textFormat!=undefined) var normalFormat = options.textFormat;
	else var normalFormat = new TextFormat(null, 12);
	
	var scriptFormat = new TextFormat();
	for (var x in normalFormat) scriptFormat[x] = normalFormat[x];
	
	if (options.sizeRatio!=undefined) scriptFormat.size = normalFormat.size/options.sizeRatio;
	else scriptFormat.size = normalFormat.size/1.5;
	
	// find the height of the normal and script textfields
	// (one would think that getTextExtent provides a simpler way of accomplishing
	// the same thing, but the results are sometimes different by a pixel or two)
	mc.createTextField("_0", 0, 0, 0, 0, 0);
	mc._0.autoSize = "left";
	mc._0.embedFonts = embedFonts;
	mc._0.setNewTextFormat(normalFormat);
	mc._0.text = "X";
	mc._0._visible = false;
	mc.createTextField("_1", 1, 0, 0, 0, 0);
	mc._1.autoSize = "left";
	mc._1.embedFonts = embedFonts;
	mc._1.setNewTextFormat(scriptFormat);
	mc._1.text = "X";
	mc._1._visible = false;
	var lineHeight = mc._0._height;
	var scriptHeight = mc._1._height;
	
	if (options.superscriptPosition!=undefined) var superscriptDelta = -options.superscriptPosition;
	else var superscriptDelta = 0;
	
	if (options.subscriptPosition!=undefined) var subscriptDelta = lineHeight - scriptHeight + options.subscriptPosition;
	else var subscriptDelta = lineHeight - scriptHeight;
	
	if (options.extraSpacing!=undefined) var extraSpacing = options.extraSpacing;
	else var extraSpacing = 0.5;

	// The process has been divided into three steps: splitting textString into separate pieces for each
	// of the different styles, adding the textfields for those pieces, and then positioning those fields.
	// (These steps could be combined, but with some loss of clarity, if the performance needs to improved.)

	// First go through textString and break it up into substrings. For each substring add an
	// object to the aL (actions list) array with .str and and .pos properties: str for the
	// substring and pos an integer specifying where to position the text. Values of pos are 1
	// for superscripts, 0 for normal text, and -1 for subscripts. 
	
	var aL = [];	
	var pos = 0;
	var iLimit = 0;
	var startInd = 0;
	do {
		var ind = textString.indexOf("<su", startInd);
		if (ind==-1) aL.push({pos: pos, str: textString});
		else {
			if (textString.charAt(ind+3)=="b" && textString.charAt(ind+4)==">") {
				// <sub> found at ind
				if (ind!=0) aL.push({pos: pos, str: textString.substring(0, ind)});
				textString = textString.slice(ind+5);
				pos = -1;
				var ind2 = textString.indexOf("</sub>");
				if (ind2!=-1) {
					// </sub> found at ind2
					if (ind2!=0) aL.push({pos: pos, str: textString.substring(0, ind2)});
					textString = textString.slice(ind2+6);
					pos = 0;
				}
				startInd = 0;
			}
			else if (textString.charAt(ind+3)=="p" && textString.charAt(ind+4)==">") {
				// <sup> found at ind
				if (ind!=0) aL.push({pos: pos, str: textString.substring(0, ind)});
				textString = textString.slice(ind+5);
				pos = 1;
				var ind2 = textString.indexOf("</sup>");
				if (ind2!=-1) {
					// </sup> found at ind2
					if (ind2!=0) aL.push({pos: pos, str: textString.substring(0, ind2)});
					textString = textString.slice(ind2+6);
					pos = 0;
				}
				startInd = 0;				
			}
			else startInd = ind + 3;
		}
		iLimit++;
	} while (ind!=-1 && textString.length>0 && iLimit<100);	
	//if (iLimit>=100) trace("WARNING: iteration limit reached");
	
	// Now add the textfields. For each entry to tL (textfields list) add an object with
	// .tf (a reference to the textfield) and .dy (delta y) properties. Also keep track of
	// the total width of the textfields, a number needed to calculate the horizontal layout.
	
	var tL = [];
	var totalWidth = 0;
	var depth = 2;
	for (var i=0; i<aL.length; i++) {
		var name = "_" + depth;
		mc.createTextField(name, depth++, 0, 0, 0, 0);
		var tf = mc[name];
		tf.autoSize = "left";
		tf.embedFonts = embedFonts;
		tf.selectable = false;
		if (aL[i].pos==0) {
			var dy = 0;
			tf.setNewTextFormat(normalFormat);
		}
		else if (aL[i].pos==1) {
			var dy = superscriptDelta;
			tf.setNewTextFormat(scriptFormat);
		}
		else {
			var dy = subscriptDelta;
			tf.setNewTextFormat(scriptFormat);
		}
		tf.text = aL[i].str;
		tL.push({tf: tf, dy: dy});
		totalWidth += tf.textWidth;
	}
	totalWidth += extraSpacing*(tL.length-1);
	
	// Now position the textfields.
	
	if (options.hAlign=="left") var x = -2;
	else if (options.hAlign=="right") var x = -2 - totalWidth;
	else var x = -2 - totalWidth/2;
	
	if (options.vAlign=="top") var y = -2;
	else if (options.vAlign=="bottom") var y = -lineHeight + 2;
	else var y = -lineHeight/2;
	
	for (var i=0; i<tL.length; i++) {
		var t = tL[i];
		t.tf._x = x;
		t.tf._y = y + t.dy;
		x += (t.tf.textWidth + extraSpacing);
	}
	
	mc.textWidth = totalWidth;
	
	return mc;
};
				*/
				
				
		public function drawCircle(mc:Graphics, x:Number, y:Number, r:Number):void {
			// note: unlike drawQuarterCircle and drawHalfCircle, this function does the initial moveTo
			// mc - reference to movieclip to draw arc in
			// x, y - center of the circlular arc
			// r - radius of the arc
			mc.moveTo(x+r, y);
			mc.curveTo(x+r, y-0.4142*r, x+0.7071*r, y-0.7071*r);
			mc.curveTo(x+0.4142*r, y-r, x, y-r);
			mc.curveTo(x-0.4142*r, y-r, x-0.7071*r, y-0.7071*r);
			mc.curveTo(x-r, y-0.4142*r, x-r, y);
			mc.curveTo(x-r, y+0.4142*r, x-0.7071*r, y+0.7071*r);
			mc.curveTo(x-0.4142*r, y+r, x, y+r);
			mc.curveTo(x+0.4142*r, y+r, x+0.7071*r, y+0.7071*r);
			mc.curveTo(x+r, y+0.4142*r, x+r, y);
		}

		public function drawQuarterCircle(mc:Graphics, x:Number, y:Number, r:Number, start:int, cw:Boolean):void {
			// note: this function assumes the pen is at the appropriate start point (it does not do a moveTo)
			// mc - reference to movieclip to draw arc in
			// x, y - center of the circlular arc
			// r - radius of the arc
			// start - one of the integers 0, 1, 2, or 3, indicating where the arc starts relative
			//		   to the the center point (0 for right, 1 for above, 2 for left, 3 for below)
			// cw - true for the arc to go clockwise and false (or left undefined) for counterclockwise
			switch (start) {
				case 0:
					if (cw) {
						mc.curveTo(x+r, y+0.4142*r, x+0.7071*r, y+0.7071*r);
						mc.curveTo(x+0.4142*r, y+r, x, y+r);
					}
					else {
						mc.curveTo(x+r, y-0.4142*r, x+0.7071*r, y-0.7071*r);
						mc.curveTo(x+0.4142*r, y-r, x, y-r);
					}
					break;
				case 1:
					if (cw) {
						mc.curveTo(x+0.4142*r, y-r, x+0.7071*r, y-0.7071*r);
						mc.curveTo(x+r, y-0.4142*r, x+r, y);
					}
					else {
						mc.curveTo(x-0.4142*r, y-r, x-0.7071*r, y-0.7071*r);
						mc.curveTo(x-r, y-0.4142*r, x-r, y);
					}
					break;
				case 2:
					if (cw) {
						mc.curveTo(x-r, y-0.4142*r, x-0.7071*r, y-0.7071*r);
						mc.curveTo(x-0.4142*r, y-r, x, y-r);
					}
					else {
						mc.curveTo(x-r, y+0.4142*r, x-0.7071*r, y+0.7071*r);
						mc.curveTo(x-0.4142*r, y+r, x, y+r);
					}
					break;
				case 3:
					if (cw) {
						mc.curveTo(x-0.4142*r, y+r, x-0.7071*r, y+0.7071*r);
						mc.curveTo(x-r, y+0.4142*r, x-r, y);
					}
					else {
						mc.curveTo(x+0.4142*r, y+r, x+0.7071*r, y+0.7071*r);
						mc.curveTo(x+r, y+0.4142*r, x+r, y);
					}
					break;
			}
		}

		public function drawHalfCircle(mc:Graphics, x:Number, y:Number, r:Number, start:int, cw:Boolean):void {
			// note: this function assumes the pen is at the appropriate start point (it does not do a moveTo)
			// mc - reference to movieclip to draw arc in
			// x, y - center of the circlular arc
			// r - radius of the arc
			// start - one of the integers 0, 1, 2, or 3, indicating where the arc starts relative
			//		   to the the center point (0 for right, 1 for above, 2 for left, 3 for below)
			// cw - true for the arc to go clockwise and false (or left undefined) for counterclockwise
			switch (start) {
				case 0:
					if (cw) {
						mc.curveTo(x+r, y+0.4142*r, x+0.7071*r, y+0.7071*r);
						mc.curveTo(x+0.4142*r, y+r, x, y+r);
						mc.curveTo(x-0.4142*r, y+r, x-0.7071*r, y+0.7071*r);
						mc.curveTo(x-r, y+0.4142*r, x-r, y);
					}
					else {
						mc.curveTo(x+r, y-0.4142*r, x+0.7071*r, y-0.7071*r);
						mc.curveTo(x+0.4142*r, y-r, x, y-r);
						mc.curveTo(x-0.4142*r, y-r, x-0.7071*r, y-0.7071*r);
						mc.curveTo(x-r, y-0.4142*r, x-r, y);
					}
					break;
				case 1:
					if (cw) {
						mc.curveTo(x+0.4142*r, y-r, x+0.7071*r, y-0.7071*r);
						mc.curveTo(x+r, y-0.4142*r, x+r, y);
						mc.curveTo(x+r, y+0.4142*r, x+0.7071*r, y+0.7071*r);
						mc.curveTo(x+0.4142*r, y+r, x, y+r);
					}
					else {
						mc.curveTo(x-0.4142*r, y-r, x-0.7071*r, y-0.7071*r);
						mc.curveTo(x-r, y-0.4142*r, x-r, y);
						mc.curveTo(x-r, y+0.4142*r, x-0.7071*r, y+0.7071*r);
						mc.curveTo(x-0.4142*r, y+r, x, y+r);
					}
					break;
				case 2:
					if (cw) {
						mc.curveTo(x-r, y-0.4142*r, x-0.7071*r, y-0.7071*r);
						mc.curveTo(x-0.4142*r, y-r, x, y-r);
						mc.curveTo(x+0.4142*r, y-r, x+0.7071*r, y-0.7071*r);
						mc.curveTo(x+r, y-0.4142*r, x+r, y);
					}
					else {
						mc.curveTo(x-r, y+0.4142*r, x-0.7071*r, y+0.7071*r);
						mc.curveTo(x-0.4142*r, y+r, x, y+r);
						mc.curveTo(x+0.4142*r, y+r, x+0.7071*r, y+0.7071*r);
						mc.curveTo(x+r, y+0.4142*r, x+r, y);
					}
					break;
				case 3:
					if (cw) {
						mc.curveTo(x-0.4142*r, y+r, x-0.7071*r, y+0.7071*r);
						mc.curveTo(x-r, y+0.4142*r, x-r, y);
						mc.curveTo(x-r, y-0.4142*r, x-0.7071*r, y-0.7071*r);
						mc.curveTo(x-0.4142*r, y-r, x, y-r);
					}
					else {
						mc.curveTo(x+0.4142*r, y+r, x+0.7071*r, y+0.7071*r);
						mc.curveTo(x+r, y+0.4142*r, x+r, y);
						mc.curveTo(x+r, y-0.4142*r, x+0.7071*r, y-0.7071*r);
						mc.curveTo(x+0.4142*r, y-r, x, y-r);
					}
					break;
			}
		}
				
		
		
		
		
		
		
		
		
		
		
		
		
		
//function StandardSliderClassV6() {
//	
//	// depths:
//	//   5 - label (recreated)
//	//   6 - units (recreated)
//	//  15 - bar
//	//  16 - grabber
//	//  17 - value box
//	//  20 - value textfield
//	this.createEmptyMovieClip("barMC", 15);
//	this.createEmptyMovieClip("grabberMC", 16);
//	this.createEmptyMovieClip("fieldMC", 17);
//	this.createTextField("valueField", 20, 0, 0, 0, 0);
//	
//	this.valueField.restrict = "0-9.Ee+\\-";
//	
//	this.valueField.onChangedFunc = function() {
//		this._parent.activateField();
//	};
//	this.valueField.onKillFocus = function() {
//		if (this._parent.active) {
//			this._parent.inactivateField();
//			if (this._parent.grabberMC.hitTest(_root._xmouse, _root._ymouse, true)
//				|| this._parent.barMC.hitTest(_root._xmouse, _root._ymouse, true)) this._parent.updateSynchronization();
//			else this._parent.setValue(parseFloat(this.text), true);
//		}
//	};
//	this.valueField.onKeyDown = function() {
//		if (Key.isDown(Key.ENTER)) {
//			this._parent.inactivateField();
//			this._parent.setValue(parseFloat(this.text), true);
//		}
//	};
//
//	this.barMC.tabEnabled = false;
//	this.barMC.useHandCursor = false;
//	this.barMC.onPressFunc = function() {
//		var c = this._parent.controller;
//		var mValue = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse)).value;
//		if (mValue<c.value) this._parent.incrementValue(-1, true);
//		else if (mValue>c.value) this._parent.incrementValue(1, true);
//		this.timeLast = getTimer();
//		this.waitTime = this.timeLast + this._parent.continuousChangeDelay;
//		this.onEnterFrame = this.onEnterFrameFunc;		
//	};
//	this.barMC.onReleaseOutside = this.barMC.onRelease = function() {
//		delete this.onEnterFrame;		
//	};
//	this.barMC.onEnterFrameFunc = function() {
//		var timeNow = getTimer();
//		if (timeNow>this.waitTime) {
//			var ticks = this._parent.continuousChangeRate*(timeNow-this.timeLast);
//			var c = this._parent.controller;
//			var mValueObj = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse));
//			if (mValueObj.value<c.value) {
//				var nValueObj = c.getIncrementedValueObject(null, -ticks);
//				if (nValueObj.value<=mValueObj.value) this._parent.setValueByValueObject(mValueObj, true);
//				else this._parent.setValueByValueObject(nValueObj, true);
//			}
//			else if (mValueObj.value>c.value) {
//				var nValueObj = c.getIncrementedValueObject(null, ticks);
//				if (nValueObj.value>=mValueObj.value) this._parent.setValueByValueObject(mValueObj, true);
//				else this._parent.setValueByValueObject(nValueObj, true);
//			}
//		}		
//		this.timeLast = timeNow;
//	};
//	
//	this.grabberMC._focusrect = false;
//	this.grabberMC.onSetFocus = function() {
//		this.normalBorderMC._visible = false;
//		this.tabbedBorderMC._visible = true;
//		this.onMouseDown = this.onKillFocus;
//		this.onMouseMove = this.onKillFocus;
//		this.onKeyDown = this.onKeyDownFunc;
//	};
//	this.grabberMC.onKillFocus = function() {
//		this.normalBorderMC._visible = true;
//		this.tabbedBorderMC._visible = false;
//		delete this.onMouseDown;
//		delete this.onMouseMove;
//		delete this.onKeyDown;
//	};
//	this.grabberMC.onKeyDownFunc = function() {
//		var c = this._parent.controller;
//		if (Key.isDown(Key.LEFT)) {
//			var vObj = c.getIncrementedValueObject(null, -1);
//			if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
//		}
//		else if (Key.isDown(Key.RIGHT)) {
//			var vObj = c.getIncrementedValueObject(null, 1);
//			if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
//		}
//	};
//	
//	this.grabberMC.useHandCursor = false;
//	this.grabberMC.onPressFunc = function() {
//		this.xOffset = this._parent._xmouse - this._x;
//		this.onMouseMove = this.onMouseMoveFunc;
//	};
//	this.grabberMC.onMouseMoveFunc = function() {
//		var c = this._parent.controller;
//		var vObj = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse-this.xOffset));
//		if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
//		updateAfterEvent();
//	};
//	this.grabberMC.onRelease = this.grabberMC.onReleaseOutside = function() {
//		delete this.onMouseMove;
//	};
//	
//	this.grabberMC.createEmptyMovieClip("tabbedBorderMC", 1);
//	this.grabberMC.createEmptyMovieClip("normalBorderMC", 2);
//	this.grabberMC.createEmptyMovieClip("fillMC", 3);
//	this.grabberMC.tabbedBorderMC._visible = false;
//	
//	this.fieldMC.createEmptyMovieClip("backgroundMC", 1);
//	this.fieldMC.createEmptyMovieClip("fillMC", 2);
//	
//	this.fieldBackgroundColorObj = new Color(this.fieldMC.fillMC);
//	
//	delete this.value;
//	
//	if (this.showField==undefined) this.showField = true;
//	if (this.labelText==undefined) this.labelText = "";
//	if (this.unitsText==undefined) this.unitsText = "";
//	if (this.minValue==undefined) this.minValue = 1;
//	if (this.maxValue==undefined) this.maxValue = 10;
//	if (this.initValue==undefined) this.initValue = 5;
//	if (this.scalingMode==undefined) this.scalingMode = "linear";
//	if (this.precisionMode==undefined) this.precisionMode = "fixed digits";
//	if (this.precision==undefined) this.precision = 2;
//	if (this.userEnabled==undefined) this.userEnabled = true;
//	if (this.maxChars==undefined) this.maxChars = 5;
//	if (this.fieldWidth==undefined) this.fieldWidth = 60;
//	if (this.barSpacing==undefined) this.barSpacing = 40;
//	if (this.fontsMovieClip==undefined) this.fontsMovieClip = "Slider Fonts v6";
//	if (this.labelAndUnitsTextColor==undefined) this.labelAndUnitsTextColor = 0x000000;
//	if (this.fieldNormalTextColor==undefined) this.fieldNormalTextColor = 0x000000;
//	if (this.fieldActiveTextColor==undefined) this.fieldActiveTextColor = 0x000000;
//	if (this.fieldDisabledTextColor==undefined) this.fieldDisabledTextColor = 0x404040;
//	if (this.fieldMargin==undefined) this.fieldMargin = 5;
//	if (this.fieldRoundedness==undefined) this.fieldRoundedness = 0.4;
//	if (this.fieldBorderThickness==undefined) this.fieldBorderThickness = 1;
//	if (this.fieldBorderColor==undefined) this.fieldBorderColor = 0xc0c0c0;
//	if (this.fieldNormalBackgroundColor==undefined) this.fieldNormalBackgroundColor = 0xffffff;
//	if (this.fieldActiveBackgroundColor==undefined) this.fieldActiveBackgroundColor = 0xffffee;
//	if (this.fieldDisabledBackgroundColor==undefined) this.fieldDisabledBackgroundColor = 0xf4f4f4;
//	if (this.barMargin==undefined) this.barMargin = 7;
//	if (this.barThickness==undefined) this.barThickness = 6;
//	if (this.barRoundedness==undefined) this.barRoundedness = 0.7;
//	if (this.barBorderThickness==undefined) this.barBorderThickness = 1;
//	if (this.barBorderColor==undefined) this.barBorderColor = 0xc0c0c0;
//	if (this.barTopColor==undefined) this.barTopColor = 0xfafafa;
//	if (this.barBottomColor==undefined) this.barBottomColor = 0xd0d0d0;
//	if (this.grabberWidth==undefined) this.grabberWidth = 9;
//	if (this.grabberHeight==undefined) this.grabberHeight = 17;
//	if (this.grabberRoundedness==undefined) this.grabberRoundedness = 0.8;
//	if (this.grabberNormalBorderThickness==undefined) this.grabberNormalBorderThickness = 1;
//	if (this.grabberNormalBorderColor==undefined) this.grabberNormalBorderColor = 0xc0c0c0;
//	if (this.grabberTabbedBorderThickness==undefined) this.grabberTabbedBorderThickness = 2;
//	if (this.grabberTabbedBorderColor==undefined) this.grabberTabbedBorderColor = 0xb0b0b0;
//	if (this.grabberMiddleColor==undefined) this.grabberMiddleColor = 0xf4f4f4;
//	if (this.grabberSideColor==undefined) this.grabberSideColor = 0xe0e0e0;
//	if (this.continuousChangeDelay==undefined) this.continuousChangeDelay = 500;
//	if (this.continuousChangeRate==undefined) this.continuousChangeRate = 50/1000;
//	if (this.sliderRange==undefined) {
//		if (this.showField) this.sliderRange = this._width - this.fieldWidth - this.barSpacing - 2*this.barMargin;
//		else this.sliderRange = this._width - this.barSpacing - 2*this.barMargin;
//		if (this.sliderRange<(3*this.grabberWidth)) this.sliderRange = 3*this.grabberWidth;
//	}
//	
//	this.placeholderMC._visible = false;
//	this.placeholderMC.swapDepths(121212);
//	this.placeholderMC.removeMovieClip();
//	this._xscale = 100;
//	this._yscale = 100;
//	
//	// in this component changing most properties requires calling the update function
//	// afterwards to reflect the changes; in fact, there are several sub-functions that may
//	// or may not need to be called depending on the properties that have changed; the 
//	// updateList array keeps track which functions should be called when the properties are
//	// are changed (there is a watch function set on all the relevant properties); then, when
//	// the update function is called it goes through the list and calls all the sub-functions
//	// that have been flagged
//	
//	// create the updateList array for this instance of the component
//	var fL = this.functionsList;
//	var uL = [];
//	for (var i=0; i<fL.length; i++) uL.push({name: fL[i], call: true});
//	this.updateList = uL;
//	
//	// set the watch functions for the necessary properties; note that while the updateList array
//	// identifies functions by name, the watch function flags them by index; see the functionsList 
//	// and propertiesList arrays defined on the prototype below for more details
//	var pL = this.propertiesList;
//	for (var i=0; i<pL.length; i++) this.watch(pL[i].property, this.registerChange, pL[i].functionIndices);
//	
//	// to avoid redundant refreshes of the controller object, we call an update now
//	// and then synchronize after creating the controller
//	
//	this.update();
//	
//	var initObj = {};
//	initObj.scalingMode = this.scalingMode;
//	initObj.valueFormat = this.precisionMode;
//	initObj.valueDigits = this.precision;
//	initObj.minValue = this.minValue;
//	initObj.maxValue = this.maxValue;
//	if (this.showField) initObj.minParameter = this.fieldWidth + this.barSpacing + this.barMargin;
//	else initObj.minParameter = this.barSpacing + this.barMargin;
//	initObj.maxParameter = initObj.minParameter + this.sliderRange;
//	initObj.value = this.initValue;
//	this.controller = new SliderLogicClassV6(initObj);
//	
//	this.updateSynchronization();
//	
//	this.inactivateField();
//};
		
	}
	
}


//
//
//
//#initclip
//
//function StandardSliderClassV6() {
//	
//	// depths:
//	//   5 - label (recreated)
//	//   6 - units (recreated)
//	//  15 - bar
//	//  16 - grabber
//	//  17 - value box
//	//  20 - value textfield
//	this.createEmptyMovieClip("barMC", 15);
//	this.createEmptyMovieClip("grabberMC", 16);
//	this.createEmptyMovieClip("fieldMC", 17);
//	this.createTextField("valueField", 20, 0, 0, 0, 0);
//	
//	this.valueField.restrict = "0-9.Ee+\\-";
//	
//	this.valueField.onChangedFunc = function() {
//		this._parent.activateField();
//	};
//	this.valueField.onKillFocus = function() {
//		if (this._parent.active) {
//			this._parent.inactivateField();
//			if (this._parent.grabberMC.hitTest(_root._xmouse, _root._ymouse, true)
//				|| this._parent.barMC.hitTest(_root._xmouse, _root._ymouse, true)) this._parent.updateSynchronization();
//			else this._parent.setValue(parseFloat(this.text), true);
//		}
//	};
//	this.valueField.onKeyDown = function() {
//		if (Key.isDown(Key.ENTER)) {
//			this._parent.inactivateField();
//			this._parent.setValue(parseFloat(this.text), true);
//		}
//	};
//
//	this.barMC.tabEnabled = false;
//	this.barMC.useHandCursor = false;
//	this.barMC.onPressFunc = function() {
//		var c = this._parent.controller;
//		var mValue = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse)).value;
//		if (mValue<c.value) this._parent.incrementValue(-1, true);
//		else if (mValue>c.value) this._parent.incrementValue(1, true);
//		this.timeLast = getTimer();
//		this.waitTime = this.timeLast + this._parent.continuousChangeDelay;
//		this.onEnterFrame = this.onEnterFrameFunc;		
//	};
//	this.barMC.onReleaseOutside = this.barMC.onRelease = function() {
//		delete this.onEnterFrame;		
//	};
//	this.barMC.onEnterFrameFunc = function() {
//		var timeNow = getTimer();
//		if (timeNow>this.waitTime) {
//			var ticks = this._parent.continuousChangeRate*(timeNow-this.timeLast);
//			var c = this._parent.controller;
//			var mValueObj = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse));
//			if (mValueObj.value<c.value) {
//				var nValueObj = c.getIncrementedValueObject(null, -ticks);
//				if (nValueObj.value<=mValueObj.value) this._parent.setValueByValueObject(mValueObj, true);
//				else this._parent.setValueByValueObject(nValueObj, true);
//			}
//			else if (mValueObj.value>c.value) {
//				var nValueObj = c.getIncrementedValueObject(null, ticks);
//				if (nValueObj.value>=mValueObj.value) this._parent.setValueByValueObject(mValueObj, true);
//				else this._parent.setValueByValueObject(nValueObj, true);
//			}
//		}		
//		this.timeLast = timeNow;
//	};
//	
//	this.grabberMC._focusrect = false;
//	this.grabberMC.onSetFocus = function() {
//		this.normalBorderMC._visible = false;
//		this.tabbedBorderMC._visible = true;
//		this.onMouseDown = this.onKillFocus;
//		this.onMouseMove = this.onKillFocus;
//		this.onKeyDown = this.onKeyDownFunc;
//	};
//	this.grabberMC.onKillFocus = function() {
//		this.normalBorderMC._visible = true;
//		this.tabbedBorderMC._visible = false;
//		delete this.onMouseDown;
//		delete this.onMouseMove;
//		delete this.onKeyDown;
//	};
//	this.grabberMC.onKeyDownFunc = function() {
//		var c = this._parent.controller;
//		if (Key.isDown(Key.LEFT)) {
//			var vObj = c.getIncrementedValueObject(null, -1);
//			if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
//		}
//		else if (Key.isDown(Key.RIGHT)) {
//			var vObj = c.getIncrementedValueObject(null, 1);
//			if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
//		}
//	};
//	
//	this.grabberMC.useHandCursor = false;
//	this.grabberMC.onPressFunc = function() {
//		this.xOffset = this._parent._xmouse - this._x;
//		this.onMouseMove = this.onMouseMoveFunc;
//	};
//	this.grabberMC.onMouseMoveFunc = function() {
//		var c = this._parent.controller;
//		var vObj = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse-this.xOffset));
//		if (vObj.value!=c.value) this._parent.setValueByValueObject(vObj, true);
//		updateAfterEvent();
//	};
//	this.grabberMC.onRelease = this.grabberMC.onReleaseOutside = function() {
//		delete this.onMouseMove;
//	};
//	
//	this.grabberMC.createEmptyMovieClip("tabbedBorderMC", 1);
//	this.grabberMC.createEmptyMovieClip("normalBorderMC", 2);
//	this.grabberMC.createEmptyMovieClip("fillMC", 3);
//	this.grabberMC.tabbedBorderMC._visible = false;
//	
//	this.fieldMC.createEmptyMovieClip("backgroundMC", 1);
//	this.fieldMC.createEmptyMovieClip("fillMC", 2);
//	
//	this.fieldBackgroundColorObj = new Color(this.fieldMC.fillMC);
//	
//	delete this.value;
//	
//	if (this.showField==undefined) this.showField = true;
//	if (this.labelText==undefined) this.labelText = "";
//	if (this.unitsText==undefined) this.unitsText = "";
//	if (this.minValue==undefined) this.minValue = 1;
//	if (this.maxValue==undefined) this.maxValue = 10;
//	if (this.initValue==undefined) this.initValue = 5;
//	if (this.scalingMode==undefined) this.scalingMode = "linear";
//	if (this.precisionMode==undefined) this.precisionMode = "fixed digits";
//	if (this.precision==undefined) this.precision = 2;
//	if (this.userEnabled==undefined) this.userEnabled = true;
//	if (this.maxChars==undefined) this.maxChars = 5;
//	if (this.fieldWidth==undefined) this.fieldWidth = 60;
//	if (this.barSpacing==undefined) this.barSpacing = 40;
//	if (this.fontsMovieClip==undefined) this.fontsMovieClip = "Slider Fonts v6";
//	if (this.labelAndUnitsTextColor==undefined) this.labelAndUnitsTextColor = 0x000000;
//	if (this.fieldNormalTextColor==undefined) this.fieldNormalTextColor = 0x000000;
//	if (this.fieldActiveTextColor==undefined) this.fieldActiveTextColor = 0x000000;
//	if (this.fieldDisabledTextColor==undefined) this.fieldDisabledTextColor = 0x404040;
//	if (this.fieldMargin==undefined) this.fieldMargin = 5;
//	if (this.fieldRoundedness==undefined) this.fieldRoundedness = 0.4;
//	if (this.fieldBorderThickness==undefined) this.fieldBorderThickness = 1;
//	if (this.fieldBorderColor==undefined) this.fieldBorderColor = 0xc0c0c0;
//	if (this.fieldNormalBackgroundColor==undefined) this.fieldNormalBackgroundColor = 0xffffff;
//	if (this.fieldActiveBackgroundColor==undefined) this.fieldActiveBackgroundColor = 0xffffee;
//	if (this.fieldDisabledBackgroundColor==undefined) this.fieldDisabledBackgroundColor = 0xf4f4f4;
//	if (this.barMargin==undefined) this.barMargin = 7;
//	if (this.barThickness==undefined) this.barThickness = 6;
//	if (this.barRoundedness==undefined) this.barRoundedness = 0.7;
//	if (this.barBorderThickness==undefined) this.barBorderThickness = 1;
//	if (this.barBorderColor==undefined) this.barBorderColor = 0xc0c0c0;
//	if (this.barTopColor==undefined) this.barTopColor = 0xfafafa;
//	if (this.barBottomColor==undefined) this.barBottomColor = 0xd0d0d0;
//	if (this.grabberWidth==undefined) this.grabberWidth = 9;
//	if (this.grabberHeight==undefined) this.grabberHeight = 17;
//	if (this.grabberRoundedness==undefined) this.grabberRoundedness = 0.8;
//	if (this.grabberNormalBorderThickness==undefined) this.grabberNormalBorderThickness = 1;
//	if (this.grabberNormalBorderColor==undefined) this.grabberNormalBorderColor = 0xc0c0c0;
//	if (this.grabberTabbedBorderThickness==undefined) this.grabberTabbedBorderThickness = 2;
//	if (this.grabberTabbedBorderColor==undefined) this.grabberTabbedBorderColor = 0xb0b0b0;
//	if (this.grabberMiddleColor==undefined) this.grabberMiddleColor = 0xf4f4f4;
//	if (this.grabberSideColor==undefined) this.grabberSideColor = 0xe0e0e0;
//	if (this.continuousChangeDelay==undefined) this.continuousChangeDelay = 500;
//	if (this.continuousChangeRate==undefined) this.continuousChangeRate = 50/1000;
//	if (this.sliderRange==undefined) {
//		if (this.showField) this.sliderRange = this._width - this.fieldWidth - this.barSpacing - 2*this.barMargin;
//		else this.sliderRange = this._width - this.barSpacing - 2*this.barMargin;
//		if (this.sliderRange<(3*this.grabberWidth)) this.sliderRange = 3*this.grabberWidth;
//	}
//	
//	this.placeholderMC._visible = false;
//	this.placeholderMC.swapDepths(121212);
//	this.placeholderMC.removeMovieClip();
//	this._xscale = 100;
//	this._yscale = 100;
//	
//	// in this component changing most properties requires calling the update function
//	// afterwards to reflect the changes; in fact, there are several sub-functions that may
//	// or may not need to be called depending on the properties that have changed; the 
//	// updateList array keeps track which functions should be called when the properties are
//	// are changed (there is a watch function set on all the relevant properties); then, when
//	// the update function is called it goes through the list and calls all the sub-functions
//	// that have been flagged
//	
//	// create the updateList array for this instance of the component
//	var fL = this.functionsList;
//	var uL = [];
//	for (var i=0; i<fL.length; i++) uL.push({name: fL[i], call: true});
//	this.updateList = uL;
//	
//	// set the watch functions for the necessary properties; note that while the updateList array
//	// identifies functions by name, the watch function flags them by index; see the functionsList 
//	// and propertiesList arrays defined on the prototype below for more details
//	var pL = this.propertiesList;
//	for (var i=0; i<pL.length; i++) this.watch(pL[i].property, this.registerChange, pL[i].functionIndices);
//	
//	// to avoid redundant refreshes of the controller object, we call an update now
//	// and then synchronize after creating the controller
//	
//	this.update();
//	
//	var initObj = {};
//	initObj.scalingMode = this.scalingMode;
//	initObj.valueFormat = this.precisionMode;
//	initObj.valueDigits = this.precision;
//	initObj.minValue = this.minValue;
//	initObj.maxValue = this.maxValue;
//	if (this.showField) initObj.minParameter = this.fieldWidth + this.barSpacing + this.barMargin;
//	else initObj.minParameter = this.barSpacing + this.barMargin;
//	initObj.maxParameter = initObj.minParameter + this.sliderRange;
//	initObj.value = this.initValue;
//	this.controller = new SliderLogicClassV6(initObj);
//	
//	this.updateSynchronization();
//	
//	this.inactivateField();
//};
//
//var p = StandardSliderClassV6.prototype = new MovieClip();
//Object.registerClass("Standard Slider v6", StandardSliderClassV6);
//
//p.getValue = function() {
//	return this.controller.value;	
//};
//p.setValue = function(arg, callChangeHandler) {
//	if ((typeof arg == "number") && !isNaN(arg) && isFinite(arg)) this.controller.value = arg;
//	this.updateSynchronization();
//	if (callChangeHandler) this._parent[this.changeHandler](this.controller.value);
//};
//p.addProperty("value", p.getValue, p.setValue);
//
//p.getValueString = function() {
//	return this.controller.valueString;	
//};
//p.addProperty("valueString", p.getValueString, null);
//
//p.incrementValue = function(ticks, callChangeHandler) {
//	if ((typeof ticks == "number") && !isNaN(ticks) && isFinite(ticks)) this.controller.incrementValue(ticks);
//	this.updateSynchronization();
//	if (callChangeHandler) this._parent[this.changeHandler](this.controller.value);
//};
//
//p.setValueByValueObject = function(vObj, callChangeHandler) {
//	// this function is intended for internal use only
//	this.controller.setValueByValueObject(vObj);
//	this.updateSynchronization();
//	if (callChangeHandler) this._parent[this.changeHandler](this.controller.value);
//};
//
//p.activateField = function() {
//	// this function is intended for internal use only
//	this.active = true;
//	this.updateFieldBackground();
//	this.updateFieldTextFormat();
//	this.updateActiveState();
//};
//
//p.inactivateField = function() {
//	// this function is intended for internal use only
//	this.active = false;
//	this.updateFieldBackground();
//	this.updateFieldTextFormat();
//	this.updateActiveState();
//};
//
///********
//*********
//****
//****	the update functions and bookkeeping follow to about line 825
//****
//********
//********/
//
//// functionsList is a list of all the functions that may need to be called when doing
//// an update, in the relative order that they should be called
//p.functionsList = ["updateFonts",
//				   "updateTextColors",
//				   "updateEnabled",
//				   "updateField",
//				   "updateFieldTextFormat",
//				   "updatePrecision",
//				   "updateScalingMode",
//				   "updateSliderRange",
//				   "updateParameterRange",
//				   "updateLabelText",
//				   "updateUnitsText",
//				   "updateActiveState",
//				   "updateFieldBackground",
//				   "updateMaxCharsProperty",
//				   "updateGrabber",
//				   "updateBar",
//				   "updateLabelAndUnitsPositions",
//				   "updateBarPosition",
//				   "updateSynchronization",
//				   "updateFieldVisibility"];
//
//iL = [];
//for (i=0; i<p.functionsList.length; i++) iL[p.functionsList[i]] = i;
//
//// propertiesList lists all the properties we want to expose to the update routine, and identifies
//// which update functions need to be called for each property (the functions are identified by
//// their index in the functionsList array, hence the intermediate iL array for convenience)
//p.propertiesList = [{property: "grabberWidth", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberHeight", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberRoundedness", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberNormalBorderThickness", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberNormalBorderColor", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberTabbedBorderThickness", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberTabbedBorderColor", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberMiddleColor", functionIndices: [iL["updateGrabber"]]},
//					{property: "grabberSideColor", functionIndices: [iL["updateGrabber"]]},
//					{property: "sliderRange", functionIndices: [iL["updateParameterRange"], iL["updateBar"], iL["updateSynchronization"]]},
//					{property: "labelText", functionIndices: [iL["updateLabelText"], iL["updateLabelAndUnitsPositions"]]},
//					{property: "unitsText", functionIndices: [iL["updateUnitsText"], iL["updateLabelAndUnitsPositions"]]},
//					{property: "minValue", functionIndices: [iL["updateSliderRange"], iL["updateSynchronization"]]},
//					{property: "maxValue", functionIndices: [iL["updateSliderRange"], iL["updateSynchronization"]]},
//					{property: "scalingMode", functionIndices: [iL["updateScalingMode"], iL["updateSynchronization"]]},
//					{property: "precisionMode", functionIndices: [iL["updatePrecision"], iL["updateSynchronization"]]},
//					{property: "precision", functionIndices: [iL["updatePrecision"], iL["updateSynchronization"]]},
//					{property: "userEnabled", functionIndices: [iL["updateEnabled"], iL["updateFieldTextFormat"], iL["updateFieldBackground"], iL["updateSynchronization"]]},
//					{property: "maxChars", functionIndices: [iL["updateMaxCharsProperty"]]},
//					{property: "fieldWidth", functionIndices: [iL["updateField"], iL["updateParameterRange"], iL["updateBarPosition"], iL["updateLabelAndUnitsPositions"], iL["updateSynchronization"]]},
//					{property: "showField", functionIndices: [iL["updateParameterRange"], iL["updateBarPosition"], iL["updateLabelAndUnitsPositions"], iL["updateSynchronization"], iL["updateFieldVisibility"]]},
//					{property: "barSpacing", functionIndices: [iL["updateParameterRange"], iL["updateBarPosition"], iL["updateSynchronization"]]},
//					{property: "labelAndUnitsTextColor", functionIndices: [iL["updateTextColors"], iL["updateLabelText"], iL["updateUnitsText"], iL["updateLabelAndUnitsPositions"]]},
//					{property: "fieldNormalTextColor", functionIndices: [iL["updateEnabled"], iL["updateFieldTextFormat"]]},
//					{property: "fieldActiveTextColor", functionIndices: [iL["updateTextColors"], iL["updateFieldTextFormat"]]},
//					{property: "fieldDisabledTextColor", functionIndices: [iL["updateEnabled"], iL["updateFieldTextFormat"]]},
//					{property: "fieldMargin", functionIndices: [iL["updateLabelAndUnitsPositions"]]},
//					{property: "fieldRoundedness", functionIndices: [iL["updateField"], iL["updateLabelAndUnitsPositions"]]},
//					{property: "fieldBorderThickness", functionIndices: [iL["updateField"], iL["updateLabelAndUnitsPositions"]]},
//					{property: "fieldBorderColor", functionIndices: [iL["updateField"]]},
//					{property: "fieldNormalBackgroundColor", functionIndices: [iL["updateFieldBackground"]]},
//					{property: "fieldActiveBackgroundColor", functionIndices: [iL["updateFieldBackground"]]},
//					{property: "fieldDisabledBackgroundColor", functionIndices: [iL["updateFieldBackground"]]},
//					{property: "barMargin", functionIndices: [iL["updateParameterRange"], iL["updateBar"], iL["updateSynchronization"]]},
//					{property: "barThickness", functionIndices: [iL["updateBar"]]},
//					{property: "barRoundedness", functionIndices: [iL["updateBar"]]},
//					{property: "barBorderThickness", functionIndices: [iL["updateBar"]]},
//					{property: "barBorderColor", functionIndices: [iL["updateBar"]]},
//					{property: "barTopColor", functionIndices: [iL["updateBar"]]},
//					{property: "barBottomColor", functionIndices: [iL["updateBar"]]},
//					{property: "fontsMovieClip", functionIndices: [iL["updateFonts"], iL["updateTextColors"], iL["updateLabelText"], iL["updateUnitsText"], iL["updateField"], iL["updateLabelAndUnitsPositions"], iL["updateEnabled"],  iL["updateFieldTextFormat"], iL["updateSynchronization"]]}];
//		
//p.registerChange = function(prop, oldVal, newVal, iL) {
//	// this is the watcher function that tags which sub-functions should be called at the next update
//	for (var i=0; i<iL.length; i++) this.updateList[iL[i]].call = true;
//	return newVal;
//};
//
//p.update = function() {
//	var uL = this.updateList;
//	for (var i=0; i<uL.length; i++) {
//		if (uL[i].call) {
//			this[uL[i].name]();
//			uL[i].call = false;
//		}
//	}
//};
//
//p.updateSynchronization = function() {
//	this.grabberMC._x = this.controller.parameter;
//	this.valueField.text = this.controller.valueString;
//};
//
//p.updateParameterRange = function() {
//	// updateSynchronization needs to be called after this function
//	if (this.showField) var minP = this.fieldWidth + this.barSpacing + this.barMargin;
//	else var minP = this.barSpacing + this.barMargin;
//	var maxP = minP + this.sliderRange;
//	this.controller.setValueAndParameterRanges(null, null, minP, maxP);
//};
//
//p.updateSliderRange = function() {
//	// updateSynchronization needs to be called after this function
//	this.controller.setValueAndParameterRanges(this.minValue, this.maxValue, null, null);
//};
//
//p.updateScalingMode = function() {
//	// updateSynchronization needs to be called after this function
//	this.controller.setScalingMode(this.scalingMode);
//};
//
//p.updatePrecision = function() {
//	// updateSynchronization needs to be called after this function
//	this.controller.setValueFormat(this.precisionMode, this.precision);
//};
//
//p.updateBarPosition = function() {
//	if (this.showField) this.barMC._x = this.fieldWidth + this.barSpacing;
//	else this.barMC._x = this.barSpacing;
//};
//
//p.updateLabelAndUnitsPositions = function() {
//	if (this.showField) {
//		this.labelTextMC._x = -this.fieldMargin - this.labelOffset - this.labelTextMC.totalWidth;
//		this.unitsTextMC._x = this.fieldMargin + this.fieldWidth + this.labelOffset;
//	}
//	else {
//		this.labelTextMC._x = -this.labelTextMC.totalWidth;
//		this.unitsTextMC._x = 0;
//	}
//};
//
//p.updateFieldVisibility = function() {
//	this.fieldMC._visible = this.showField;
//	this.valueField._visible = this.showField;
//};
//
//p.updateBar = function() {
//	var y = this.barThickness/2;
//	var by = y + this.barBorderThickness;
//	var x = this.sliderRange + 2*this.barMargin;
//	var rnd = this.barRoundedness;
//	var mc = this.barMC;
//	mc.clear();
//	if (rnd<=0) {
//		// square ends
//		var bx1 = -this.barBorderThickness;
//		var bx2 = x + this.barBorderThickness;
//		mc.moveTo(bx1, by);
//		mc.beginFill(this.barBorderColor);
//		mc.lineTo(bx2, by);
//		mc.lineTo(bx2, -by);
//		mc.lineTo(bx1, -by);
//		mc.lineTo(bx1, by);
//		mc.endFill();
//		mc.moveTo(0, y);
//		mc.beginGradientFill("linear", [this.barTopColor, this.barBottomColor], [100, 100], [0, 0xff], {matrixType: "box", x: 0, y: -y, w: 1, h: 2*y, r: Math.PI/2});
//		mc.lineTo(x, y);
//		mc.lineTo(x, -y);
//		mc.lineTo(0, -y);
//		mc.lineTo(0, y);
//		mc.endFill();
//	}
//	else if (rnd>=1) {
//		// semicircle ends
//		mc.moveTo(0, by);
//		mc.beginFill(this.barBorderColor);
//		mc.lineTo(x, by);
//		this.drawHalfCircle(mc, x, 0, by, 3);
//		mc.lineTo(0, -by);
//		this.drawHalfCircle(mc, 0, 0, by, 1);
//		mc.endFill();
//		mc.moveTo(0, y);
//		mc.beginGradientFill("linear", [this.barTopColor, this.barBottomColor], [100, 100], [0, 0xff], {matrixType: "box", x: 0, y: -y, w: 1, h: 2*y, r: Math.PI/2});
//		mc.lineTo(x, y);
//		this.drawHalfCircle(mc, x, 0, y, 3);
//		mc.lineTo(0, -y);
//		this.drawHalfCircle(mc, 0, 0, y, 1);
//		mc.endFill();
//	}
//	else {
//		// partially rounded ends
//		var r = y*rnd;
//		var br = r + this.barBorderThickness;
//		var dy = y - r;
//		mc.moveTo(0, by);
//		mc.beginFill(this.barBorderColor);
//		mc.lineTo(x, by);
//		this.drawQuarterCircle(mc, x, dy, br, 3);
//		mc.lineTo(x+br, -dy);
//		this.drawQuarterCircle(mc, x, -dy, br, 0);
//		mc.lineTo(0, -by);
//		this.drawQuarterCircle(mc, 0, -dy, br, 1);
//		mc.lineTo(-br, dy);
//		this.drawQuarterCircle(mc, 0, dy, br, 2);
//		mc.endFill();
//		mc.moveTo(0, y);
//		mc.beginGradientFill("linear", [this.barTopColor, this.barBottomColor], [100, 100], [0, 0xff], {matrixType: "box", x: 0, y: -y, w: 1, h: 2*y, r: Math.PI/2});
//		mc.lineTo(x, y);
//		this.drawQuarterCircle(mc, x, dy, r, 3);
//		mc.lineTo(x+r, -dy);
//		this.drawQuarterCircle(mc, x, -dy, r, 0);
//		mc.lineTo(0, -y);
//		this.drawQuarterCircle(mc, 0, -dy, r, 1);
//		mc.lineTo(-r, dy);
//		this.drawQuarterCircle(mc, 0, dy, r, 2);
//		mc.endFill();
//	}
//};
//
//p.updateGrabber = function() {
//	var x = this.grabberWidth/2;
//	var y = this.grabberHeight/2;
//	var rnd = this.grabberRoundedness;
//	var tbmc = this.grabberMC.tabbedBorderMC;
//	tbmc.clear();
//	var nbmc = this.grabberMC.normalBorderMC;
//	nbmc.clear();
//	var fmc = this.grabberMC.fillMC;
//	fmc.clear();
//	if (rnd<=0) {
//		// square ends
//		var bx = x + this.grabberTabbedBorderThickness;
//		var by = y + this.grabberTabbedBorderThickness;
//		tbmc.moveTo(bx, by);
//		tbmc.beginFill(this.grabberTabbedBorderColor);
//		tbmc.lineTo(bx, -by);
//		tbmc.lineTo(-bx, -by);
//		tbmc.lineTo(-bx, by);
//		tbmc.lineTo(bx, by);
//		tbmc.endFill();
//		
//		var bx = x + this.grabberNormalBorderThickness;
//		var by = y + this.grabberNormalBorderThickness;
//		nbmc.moveTo(bx, by);
//		nbmc.beginFill(this.grabberNormalBorderColor);
//		nbmc.lineTo(bx, -by);
//		nbmc.lineTo(-bx, -by);
//		nbmc.lineTo(-bx, by);
//		nbmc.lineTo(bx, by);
//		nbmc.endFill();
//		
//		fmc.moveTo(x, y);
//		fmc.beginGradientFill("linear", [this.grabberSideColor, this.grabberMiddleColor, this.grabberSideColor], [100, 100, 100], [0, 0x80, 0xff], {matrixType: "box", x: -x, y: -y, w: 2*x, h: 1, r: 0});
//		fmc.lineTo(x, -y);
//		fmc.lineTo(-x, -y);
//		fmc.lineTo(-x, y);
//		fmc.lineTo(x, y);
//		fmc.endFill();
//	}
//	else if (rnd>=1) {
//		// semicircle ends		
//		var bx = x + this.grabberTabbedBorderThickness
//		tbmc.moveTo(bx, y);
//		tbmc.beginFill(this.grabberTabbedBorderColor);
//		tbmc.lineTo(bx, -y);
//		this.drawHalfCircle(tbmc, 0, -y, bx, 0);
//		tbmc.lineTo(-bx, y);
//		this.drawHalfCircle(tbmc, 0, y, bx, 2);
//		tbmc.endFill();
//		
//		var bx = x + this.grabberNormalBorderThickness;
//		nbmc.moveTo(bx, y);
//		nbmc.beginFill(this.grabberNormalBorderColor);
//		nbmc.lineTo(bx, -y);
//		this.drawHalfCircle(nbmc, 0, -y, bx, 0);
//		nbmc.lineTo(-bx, y);
//		this.drawHalfCircle(nbmc, 0, y, bx, 2);
//		nbmc.endFill();
//		
//		fmc.moveTo(x, y);
//		fmc.beginGradientFill("linear", [this.grabberSideColor, this.grabberMiddleColor, this.grabberSideColor], [100, 100, 100], [0, 0x80, 0xff], {matrixType: "box", x: -x, y: -y, w: 2*x, h: 1, r: 0});
//		fmc.lineTo(x, -y);
//		this.drawHalfCircle(fmc, 0, -y, x, 0);
//		fmc.lineTo(-x, y);
//		this.drawHalfCircle(fmc, 0, y, x, 2);
//		fmc.endFill();
//	}
//	else {
//		// partially rounded ends
//		var r = x*rnd;
//		var dx = x - r;
//		var bx = x + this.grabberTabbedBorderThickness;
//		var br = r + this.grabberTabbedBorderThickness;
//		tbmc.moveTo(bx, y);
//		tbmc.beginFill(this.grabberTabbedBorderColor);
//		tbmc.lineTo(bx, -y);
//		this.drawQuarterCircle(tbmc, dx, -y, br, 0);
//		tbmc.lineTo(-dx, -y-br);
//		this.drawQuarterCircle(tbmc, -dx, -y, br, 1);
//		tbmc.lineTo(-bx, y);
//		this.drawQuarterCircle(tbmc, -dx, y, br, 2);
//		tbmc.lineTo(dx, y+br);
//		this.drawQuarterCircle(tbmc, dx, y, br, 3);
//		tbmc.endFill();
//		
//		var bx = x + this.grabberNormalBorderThickness;
//		var br = r + this.grabberNormalBorderThickness;
//		nbmc.moveTo(bx, y);
//		nbmc.beginFill(this.grabberNormalBorderColor);
//		nbmc.lineTo(bx, -y);
//		this.drawQuarterCircle(nbmc, dx, -y, br, 0);
//		nbmc.lineTo(-dx, -y-br);
//		this.drawQuarterCircle(nbmc, -dx, -y, br, 1);
//		nbmc.lineTo(-bx, y);
//		this.drawQuarterCircle(nbmc, -dx, y, br, 2);
//		nbmc.lineTo(dx, y+br);
//		this.drawQuarterCircle(nbmc, dx, y, br, 3);
//		nbmc.endFill();
//		
//		fmc.moveTo(x, y);
//		fmc.beginGradientFill("linear", [this.grabberSideColor, this.grabberMiddleColor, this.grabberSideColor], [100, 100, 100], [0, 0x80, 0xff], {matrixType: "box", x: -x, y: -y, w: 2*x, h: 1, r: 0});
//		fmc.lineTo(x, -y);
//		this.drawQuarterCircle(fmc, dx, -y, r, 0);
//		fmc.lineTo(-dx, -y-r);
//		this.drawQuarterCircle(fmc, -dx, -y, r, 1);
//		fmc.lineTo(-x, y);
//		this.drawQuarterCircle(fmc, -dx, y, r, 2);
//		fmc.lineTo(dx, y+r);
//		this.drawQuarterCircle(fmc, dx, y, r, 3);
//		fmc.endFill();
//	}
//};
//
//p.updateField = function() { 
//	// updateLabelAndUnitsPositions and updateSynchronization need to be called after this function
//	var oldText = this.valueField.text;
//	this.valueField.autoSize = "left";
//	this.valueField.setTextFormat(this.valueTextFormat);
//	this.valueField.embedFonts = this.embedValueFont;
//	this.valueField.setNewTextFormat(this.valueTextFormat);
//	this.valueField.text = "8";
//	var h = Math.round(this.valueField._height);
//	var x = this.fieldWidth;
//	var y = h/2;
//	this.valueField.autoSize = "none";
//	this.valueField._y = -y;
//	this.valueField._width = x;
//	this.valueField.text = oldText;
//	var t = this.fieldBorderThickness;
//	var bx = x + t;
//	var by = y + t;
//	var bmc = this.fieldMC.backgroundMC;
//	bmc.clear();
//	var fmc = this.fieldMC.fillMC;
//	fmc.clear();
//	var rnd = this.fieldRoundedness;
//	if (rnd<=0) {
//		// square ends
//		bmc.moveTo(-t, by);
//		bmc.beginFill(this.fieldBorderColor);
//		bmc.lineTo(bx, by);
//		bmc.lineTo(bx, -by);
//		bmc.lineTo(-t, -by);
//		bmc.lineTo(-t, by);
//		bmc.endFill();
//		fmc.moveTo(0, y);
//		fmc.beginFill(0xff0000);
//		fmc.lineTo(x, y);
//		fmc.lineTo(x, -y);
//		fmc.lineTo(0, -y);
//		fmc.lineTo(0, y);
//		fmc.endFill();
//	}
//	else if (rnd>=1) {
//		// semicircle ends
//		bmc.moveTo(0, by);
//		bmc.beginFill(this.fieldBorderColor);
//		bmc.lineTo(x, by);
//		this.drawHalfCircle(bmc, x, 0, by, 3);
//		bmc.lineTo(0, -by);
//		this.drawHalfCircle(bmc, 0, 0, by, 1);
//		bmc.endFill();
//		fmc.moveTo(0, y);
//		fmc.beginFill(0xff0000);
//		fmc.lineTo(x, y);
//		this.drawHalfCircle(fmc, x, 0, y, 3);
//		fmc.lineTo(0, -y);
//		this.drawHalfCircle(fmc, 0, 0, y, 1);
//		fmc.endFill();
//	}
//	else {
//		var r = rnd*y;
//		var br = r + t;
//		var dy = y - r;
//		bmc.moveTo(0, by);
//		bmc.beginFill(this.fieldBorderColor);
//		bmc.lineTo(x, by);
//		this.drawQuarterCircle(bmc, x, dy, br, 3);
//		bmc.lineTo(x+br, -dy);
//		this.drawQuarterCircle(bmc, x, -dy, br, 0);
//		bmc.lineTo(0, -by);
//		this.drawQuarterCircle(bmc, 0, -dy, br, 1);
//		bmc.lineTo(-br, dy);
//		this.drawQuarterCircle(bmc, 0, dy, br, 2);
//		bmc.endFill();
//		fmc.moveTo(0, y);
//		fmc.beginFill(0xff0000);
//		fmc.lineTo(x, y);
//		this.drawQuarterCircle(fmc, x, dy, r, 3);
//		fmc.lineTo(x+r, -dy);
//		this.drawQuarterCircle(fmc, x, -dy, r, 0);
//		fmc.lineTo(0, -y);
//		this.drawQuarterCircle(fmc, 0, -dy, r, 1);
//		fmc.lineTo(-r, dy);
//		this.drawQuarterCircle(fmc, 0, dy, r, 2);
//		fmc.endFill();
//	}
//	this.labelOffset = t + rnd*y;
//};
//
//p.updateEnabled = function() {
//	// updateFieldTextFormat (hence updateSynchronization) needs to be called after this function
//	if (this.userEnabled) {
//		this.grabberMC.tabEnabled = true;
//		this.grabberMC.onPress = this.grabberMC.onPressFunc;
//		this.barMC.onPress = this.barMC.onPressFunc;
//		this.valueField.type = "input";
//		this.valueField.selectable = true;
//		this.valueTextFormat.color = this.fieldNormalTextColor;
//	}
//	else {
//		this.grabberMC.tabEnabled = false;
//		this.grabberMC.onKillFocus();
//		delete this.grabberMC.onPress;
//		delete this.barMC.onPress;
//		this.valueField.type = "dynamic";
//		this.valueField.selectable = false;
//		this.valueTextFormat.color = this.fieldDisabledTextColor;
//	}
//};
//
//p.updateMaxCharsProperty = function() {
//	this.valueField.maxChars = this.maxChars;
//};
//
//p.updateTextColors = function() {
//	// updateLabelText, updateUnitsText, and updateFieldTextFormat (hence updateSynchronization) need
//	// to be called after this function
//	// - note that the color for the valueTextFormat object is set in the updateEnabled function
//	this.valueWhileEditingTextFormat.color = this.fieldActiveTextColor;
//	this.labelAndUnitTextFormat.color = this.labelAndUnitsTextColor;
//};
//
//p.updateFieldBackground = function() {
//	if (!this.userEnabled) this.fieldBackgroundColorObj.setRGB(this.fieldDisabledBackgroundColor);
//	else if (this.active) this.fieldBackgroundColorObj.setRGB(this.fieldActiveBackgroundColor);
//	else this.fieldBackgroundColorObj.setRGB(this.fieldNormalBackgroundColor);
//};
//
//p.updateFieldTextFormat = function() {
//	// updateSynchronization needs to be called after this function
//	if (this.active) {
//		this.valueField.setTextFormat(this.valueWhileEditingTextFormat);
//		this.valueField.embedFonts = this.embedValueWhileEditingFont;
//		this.valueField.setNewTextFormat(this.valueWhileEditingTextFormat);
//	}
//	else {
//		this.valueField.setTextFormat(this.valueTextFormat);
//		this.valueField.embedFonts = this.embedValueFont;
//		this.valueField.setNewTextFormat(this.valueTextFormat);
//	}
//};
//
//p.updateActiveState = function() {
//	if (this.active) {
//		Key.addListener(this.valueField);
//		delete this.valueField.onChanged;
//	}
//	else {
//		Key.removeListener(this.valueField);
//		this.valueField.onChanged = this.valueField.onChangedFunc;
//	}
//};
//
//p.updateLabelText = function() {
//	var wmc = this.createEmptyMovieClip("labelTextMC", 5);		
//	this.updateTextMC(wmc, this.labelText);
//};
//
//p.updateUnitsText = function() {
//	var wmc = this.createEmptyMovieClip("unitsTextMC", 6);
//	this.updateTextMC(wmc, this.unitsText);
//};
//
//p.updateTextMC = function(wmc, textString) {
//	var oRad = this.solarSymbolOuterRadius;
//	var iRad = this.solarSymbolInnerRadius;
//	var yPos = this.solarSymbolYPosition;
//	var sp = this.solarSymbolSpacing;
//	var tf = this.labelAndUnitTextFormat;
//	var ef = this.embedLabelAndUnitFont;
//	var sr = this.scriptsSizeRatio;
//	var sL = textString.split("<sol>");
//	var xCursor = 0;
//	if (sL[0].length!=0) {
//		var mc = this.displayText(sL[0], {mc: wmc, textFormat: tf, embedFonts: ef, hAlign: "left", vAlign: "center", sizeRatio: sr});
//		xCursor += mc.textWidth;
//	}
//	for (var i=1; i<sL.length; i++) {
//		xCursor += sp;
//		wmc.lineStyle(1, tf.color);
//		this.drawCircle(wmc, xCursor, yPos, oRad);
//		wmc.lineStyle(undefined);
//		wmc.beginFill(tf.color);
//		this.drawCircle(wmc, xCursor, yPos, iRad);
//		wmc.endFill();
//		xCursor += sp;
//		if (sL[i].length==0) continue;
//		var mc = this.displayText(sL[i], {mc: wmc, textFormat: tf, embedFonts: ef, hAlign: "left", vAlign: "center", sizeRatio: sr, x: xCursor});
//		xCursor += mc.textWidth;
//	}
//	wmc.totalWidth = xCursor;
//};
//

//
