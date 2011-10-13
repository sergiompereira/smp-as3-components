package com.smp.components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import com.smp.common.display.MovieClipUtilities;
	import com.smp.common.math.MathUtils;
	


	/**
	/* @example:

			var sliderYaw:MovieClip = new MovieClip();
			addChild(sliderYaw);
			var slideYawBtn:MovieClip = new MovieClip();
			sliderYaw.addChild(slideYawBtn);
			slideYawBtn.addChild(ShapeUtils.createRectangle(20, 10));
			sliderYawHnd = new SliderHandler();
			sliderYawHnd.setInterfaceObjects(slideYawBtn);
			sliderYawHnd.init(100);
			sliderYawHnd.addEventListener(Event.CHANGE, onSliderChange);

			
		private function onSliderChange(evt:Event):void {
			
			var slider:SliderHandler = (evt.currentTarget as SliderHandler);
			var value:Number;
			
			value = MathUtils.scale(slider.value, 0, 100, 0, 360);
		}
	*/

	public class  SliderHandler extends EventDispatcher
	{
		private var _value:Number = 0;
		private var _slideBtn:MovieClip;
		
		private var _slideLength:Number;
		
		
		public function SliderHandler() {
			
		}
		
		public function setInterfaceObjects(slidebtn:MovieClip):void {

			if(slidebtn.stage != null){
				_slideBtn = slidebtn;
				_slideBtn.buttonMode = true;
			}else {
				throw new Error("SliderHandler:setInterfaceObjects->Parent object must be added to the display list.")
			}
		}
		
		public function init(slideLength:Number):void {
				
			_slideLength = slideLength;
			MovieClipUtilities.setDraggable(_slideBtn, false, 0, 0, _slideLength, 0, null, onUp, onDrag);
			
			_value = MathUtils.scale(_slideBtn.x, 0, _slideLength, 0, 100);
		}
		
		
		private function onUp(obj:MovieClip):void {
			
			_value = MathUtils.scale(_slideBtn.x, 0, _slideLength, 0, 100);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onDrag(obj:MovieClip):void {
			
			_value = MathUtils.scale(_slideBtn.x, 0, _slideLength, 0, 100);
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get value():Number {
			return _value;
		}
		
		public function set value(val:Number):void {
			
			_value = val;
			_slideBtn.x = MathUtils.scale(val, 0, 100, 0, _slideLength);
		}
	}
	
}