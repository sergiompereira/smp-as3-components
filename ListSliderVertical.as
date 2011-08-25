
package com.smp.components {
	
	import flash.display.Sprite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import com.smp.common.display.ShapeUtils;
	import com.smp.effects.TweenSafe;
	import com.smp.common.math.MathUtils;
	import com.smp.common.display.DisplayObjectUtilities;

	
	/**
	 * Allows for the creation of a vertical list, which slides on mouse move.
	 * y position of items must be set directly to them from outside the class, as well as interactions on them.
	 * See methods available.
	 * A loading animation may be set calling addItem on a timed interval and calling start only in the end.
	 * 
	 * 
	 * 
	 * 	@example	var scroller:ListSliderVertical = new ListSliderVertical();
					addChild(scroller);
					scroller.setup(300, 200);
					
					//any external DisplayObject
					var item:MovieClip;
					for(var i:uint = 0; i<= 20; i++){
						item = new Item();
						item.y = item.height*i;
						scroller.addItem(item);
					}

					scroller.start();
	 */
	
	public class ListSliderVertical extends Sprite {
		

		protected var _ease:Number;
		protected var _gradienteMargin:Number;
		
		private var tween:TweenSafe = new TweenSafe();
		private var _timer = new Timer(10);


		private var scrollDir:String;
		private var container:Sprite = new Sprite();
		private var containerMask:Sprite = new Sprite();

		private var itemHeight:Number;
		private var visibleItems:Number;
		private var topHidenItems:Number;
		private var _areaWidth:Number;
		private var _areaHeight:Number;
		
		private var statusActive:Boolean = false;
		
		private var _over:Boolean = false;
		
		

		
		public function ListSliderVertical() 
		{
			
		}
		
		
		public function setup(areaWidth:Number, areaHeight:Number, ease:Number = 1, gradienteMargin:Number = 15):void 
		{
			_areaWidth = areaWidth;
			_areaHeight = areaHeight;
			_gradienteMargin = gradienteMargin;
			_ease = ease;
			
			//var gradProp:Number = MathUtils.Scale(_gradienteMargin, 0, (areaHeight + _gradienteMargin * 2), 0, 255);
			
			//containerMask.addChild(ShapeUtils.createGradientRectangle(areaWidth, areaHeight+_gradienteMargin*2, [0xffffff, 0xffffff, 0xffffff,0xffffff],[0,1,1,0],[0,gradProp,255-gradProp,255] ));
			containerMask.addChild(ShapeUtils.createRectangle(_areaWidth, _areaHeight, 0xffffff,1,0, _gradienteMargin));
			containerMask.addChild(ShapeUtils.createGradientRectangle(_areaWidth,_gradienteMargin, [0xffffff, 0xffffff],[0,1],[0,255],-1, 0,0));
			containerMask.addChild(ShapeUtils.createGradientRectangle(_areaWidth,_gradienteMargin, [0xffffff, 0xffffff],[1,0],[0,255],-1,0, _areaHeight+_gradienteMargin));
			
			
			containerMask.x = -5;
			containerMask.y = -_gradienteMargin;
			addChild(container);
			addChild(containerMask);
			
			container.cacheAsBitmap = true;
			containerMask.cacheAsBitmap = true;
			container.mask = containerMask;
			
		}
		
		public function addItem(obj:DisplayObject):void 
		{
			container.addChild(obj);
		}
		
		public function start():void {

			itemHeight = Math.round(container.height/container.numChildren);
			visibleItems = Math.round((containerMask.height-_gradienteMargin*2) / itemHeight);
			
			if (container.height > (containerMask.height - _gradienteMargin * 2)) {
				
				_timer.addEventListener(TimerEvent.TIMER, onMouseActivity);
				_timer.start();
				
				statusActive = true;
				this.buttonMode = true;
				
			}else {
				
				_timer.removeEventListener(TimerEvent.TIMER, onMouseActivity);
				
				statusActive = false;
				this.buttonMode = false;
			}
		}
		
		public function stop():void{
			_timer.removeEventListener(TimerEvent.TIMER, onMouseActivity);
				
			statusActive = false;
			this.buttonMode = false;
		}
				
		public function scrollActive():Boolean {
			return statusActive;
		}
		
		public function clear():void 
		{
			_timer.removeEventListener(TimerEvent.TIMER, onMouseActivity);
			DisplayObjectUtilities.removeAllChildren(container);
			
			this.scrollToItem(1);
	
		}
		
		
		private function onMouseActivity(evt:TimerEvent):void {

			if (!_over && evalMouseActivity()) {
				_over = true;
				addHandler();
				dispatchEvent(new Event(Event.ACTIVATE));
				
			} else if (_over && !evalMouseActivity()) {
				_over = false;
				removeHandler();
				dispatchEvent(new Event(Event.DEACTIVATE));
			}
			
		}
		
		private function addHandler():void {
			addEventListener(Event.ENTER_FRAME, newframe);
		}
		private function removeHandler():void {
			//removed on newframe()
			//removeEventListener(Event.ENTER_FRAME, newframe);
		}
		
		private function evalMouseActivity():Boolean {
			
			if (mouseX > 0 && mouseX < _areaWidth && mouseY > 0 && mouseY < _areaHeight) {
				if(!_over){
					_over = true;
				}
			}else {
				if(_over){
					_over = false;
				}

			}
			return _over;
		}
	
		private function newframe(evt:Event):void {
			slide();
			if (_over == false && (Math.abs(getPosition() - container.y))<1) {
				removeEventListener(Event.ENTER_FRAME, newframe);
			}
		}
					
		private function getPosition():Number 
		{
			var mouseYpos = mouseY;
			if (mouseYpos<0) {
				mouseYpos = 0;
			}else if (mouseYpos>_areaHeight) {
				mouseYpos = _areaHeight;
			}
			return (_areaHeight-container.height)/_areaHeight*mouseYpos;
		}
		
		private function slide():void {
			
			container.y += (getPosition() - container.y) / _ease;
		}


		public function resetPosition(){
			container.y = 0;
		}
	
		public function scrollToItem(i:uint):void
		{
			if(i>0 && i<container.numChildren){
			
				var dest;
				if (i > visibleItems) {
					
					var diff = i-visibleItems;
					dest = -(diff*itemHeight+_gradienteMargin);
					tween.setTween(container, "y", TweenSafe.REG_EASEOUT, container.y, dest, 0.5, true, true);

				}else{
					topHidenItems = Math.round(-container.y/itemHeight);
					
					if(topHidenItems > 0 && i <= topHidenItems){
						trace(topHidenItems)
						dest = Math.round(-(i-1)*itemHeight);
						tween.setTween(container, "y", TweenSafe.REG_EASEOUT, container.y, dest, 0.5, true, true);
					}
					
				}
			}
		}

	}
}

