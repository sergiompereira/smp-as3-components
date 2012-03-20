package com.smp.components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import com.smp.common.display.DragHandler;
	import com.smp.common.math.MathUtils;
	


	/**
	/* @example:

		//with one button:
		
			var slider:MovieClip = new MovieClip();
			addChild(slider);
			var slideBtn:MovieClip = new MovieClip();
			slider.addChild(slideBtn);
			slideBtn.addChild(ShapeUtils.createRectangle(20, 10));
			var sliderHnd:SliderHandler = new SliderHandler();
			sliderHnd.setInterfaceObjects(slideBtn);
			sliderHnd.init(100);
			sliderHnd.addEventListener(Event.CHANGE, onSliderChange);

			
			private function onSliderChange(evt:Event):void {
				
				var slider:SliderHandler = (evt.currentTarget as SliderHandler);
				var value:Number;
				//e.g: getting the angle between 0 and 360º
				value = MathUtils.scale(slider.value, 0, 100, 0, 360);
			}
		
		//with two buttons (constrained by each other):
				
			var maxOutputValue:Number = 50;
		
			var slideBtn2:MovieClip = new MovieClip();
			slider.addChild(slideBtn2);
	
			slideBtn2.addChild(ShapeUtils.createRectangle(10, 6,0xcccccc));
			var sliderHndDouble:SliderHandler = new SliderHandler();
			sliderHndDouble.setInterfaceObjects(slideBtn,slideBtn2);
			//set the initial values, scaling from one group (0-360) to the slider group (0-100)
			sliderHndDouble.init(360,
					MathUtils.scale(45, 0, 360, 0, 100),
					MathUtils.scale(180, 0, 360, 0, 100)
			);
			sliderHnd.addEventListener(Event.CHANGE, onDoubleSliderChange);
			
			private function onDoubleSliderChange(evt:Event):void {
					
				var slider:SliderHandler = (evt.currentTarget as SliderHandler);
				var value:Number;
				var value2:Number;
				
				//e.g: getting the angle between 0 and 360º
				value = MathUtils.scale(slider.value, 0, 100, 0, 360);
				value2 = MathUtils.scale(slider.value2, 0, 100, 0, 360);
				myObject.changeRotations(value,value2);
			}
	*/

	public class  SliderHandler extends EventDispatcher
	{
		private var _value:Number = 0;
		private var _value2:Number = 0;
		private var _slideBtn:MovieClip;
		private var _slideBtn2:MovieClip;
		
		private var _slideLength:Number;
		private var _double:Boolean = false;
		private var _dragHandler:DragHandler;
		
		
		public function SliderHandler() {
			_dragHandler = new DragHandler();
		}
		
		/**
		 * If slidebtn2 is provided, it is assumed to be a double slide with two buttons
		 * constrained by each other: the minimum value of the second is constrained by the value of the first
		 * and the maximum value of the first is constrained by the value of the second.
		 * 
		 * @param	slidebtn
		 * @param	slidebtn2
		 */
		public function setInterfaceObjects(slidebtn:MovieClip, slidebtn2:MovieClip = null):void {

			if (slidebtn.stage != null) {
				if (slidebtn2 != null) {
					if (slidebtn2.stage != null) {
						_double = true;
						_slideBtn2 = slidebtn2;
						_slideBtn2.buttonMode = true;
					}else {
						throw new Error("SliderHandler:setInterfaceObjects->Parent object must be added to the display list.")
					}
					
				}else {
					_double = false;
				}
				_slideBtn = slidebtn;
				_slideBtn.buttonMode = true;
			}else {
				throw new Error("SliderHandler:setInterfaceObjects->Parent object must be added to the display list.")
			}
		}
		
		public function init(slideLength:Number, value:Number = 0, value2:Number = 0):void {
				
			_slideLength = slideLength;
		
			if (_double) {
				
				if (value > 0) {
					var tempBtnx:Number = MathUtils.scale(value, 0, 100, 0, _slideLength);
					if(tempBtnx <= _slideLength - _slideBtn.width) {
						_value = value;
						_slideBtn.x = tempBtnx;
					}else {
						_slideBtn.x = _slideLength - _slideBtn.width;
						_value = MathUtils.scale(_slideBtn.x, 0, _slideLength, 0, 100);
					}
				}else {
					_value = 0;
				}
								
				var tempBtn2x:Number = MathUtils.scale(value2, 0, 100, 0, _slideLength);
				if (tempBtn2x >= _slideBtn.x + _slideBtn.width) {
					_value2 = value2;
					_slideBtn2.x = tempBtn2x;
				}else {
					_slideBtn2.x = _slideBtn.x + _slideBtn.width;
					_value2 = MathUtils.scale(_slideBtn2.x, 0, _slideLength, 0, 100);
				}
				
				_dragHandler.setDraggable(_slideBtn, false, 0, 0, _slideBtn2.x - _slideBtn.width, 0, null, onUp, onDrag);
				_dragHandler.setDraggable(_slideBtn2, false,_slideBtn.x+_slideBtn.width, 0, _slideLength, 0, null, onUp2, onDrag2);
				
			}else {
				_value = value;
				_slideBtn.x = MathUtils.scale(_value, 0, 100, 0, _slideLength);
				_dragHandler.setDraggable(_slideBtn, false, 0, 0, _slideLength, 0, null, onUp, onDrag);
			}
			
			
		}
		
		
		private function onUp(obj:MovieClip):void {
			
			_value = MathUtils.scale(_slideBtn.x, 0, _slideLength, 0, 100);
			_dragHandler.setBounds(_slideBtn2, new Rectangle(_slideBtn.x + _slideBtn.width, 0, _slideLength -(_slideBtn.x + _slideBtn.width), 0));
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onDrag(obj:MovieClip):void {
			
			_value = MathUtils.scale(_slideBtn.x, 0, _slideLength, 0, 100);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onUp2(obj:MovieClip):void {
			
			_value2 = MathUtils.scale(_slideBtn2.x, 0, _slideLength, 0, 100);
			_dragHandler.setBounds(_slideBtn, new Rectangle(0, 0, _slideBtn2.x - _slideBtn.width, 0));
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onDrag2(obj:MovieClip):void {
			
			_value2 = MathUtils.scale(_slideBtn2.x, 0, _slideLength, 0, 100);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get value():Number {
			return _value;
		}
		public function get value2():Number {
			return _value2;
		}
		
		public function set value(val:Number):void {
			
			_value = val;
			_slideBtn.x = MathUtils.scale(val, 0, 100, 0, _slideLength);
		}
		public function set value2(val:Number):void {
			
			_value2 = val;
			_slideBtn2.x = MathUtils.scale(val, 0, 100, 0, _slideLength);
		}
	}
	
}