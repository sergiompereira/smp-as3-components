
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
	 * Allows for the creation of an horizontal list which slides on mouse move.
	 * x position of items must be set directly to them from outside the class, as well as interactions on them.
	 * See methods available.
	 * A loading animation may be set calling addItem on a timed interval and calling start only in the end.
	 * 
	 * Typical use:
	 * 
	 * 		var scroller:ListSliderHorizontal = new ListSliderHorizontal();
			addChild(scroller);
			scroller.setup(100, 100, 7, 15);
			scroller.x = 150;
			scroller.y = 150;
			
			//any external DisplayObject
			var item:MovieClip;
			for(var i:uint = 0; i<= 20; i++){
				item = new MovieClip();
				item.addChild(TextUtils.createTextField("Item" + i));
				item.x = item.width*i;
				scroller.addItem(item);
			}

			scroller.start();
			trace(scroller.scrollActive())
	 */
	
	public class ListSliderHorizontal extends Sprite {
		

		protected var _ease:Number;
		protected var _gradienteMargin:Number;
		
		private var tween:TweenSafe = new TweenSafe();
		private var _timer = new Timer(10);


		private var scrollDir:String;
		private var container:Sprite = new Sprite();
		private var containerMask:Sprite = new Sprite();

		private var itemWidth:Number;
		private var visibleItems:Number;
		private var leftHidenItems:Number;
		private var _areaWidth:Number;
		private var _areaHeight:Number;
		
		private var statusActive:Boolean = false;
		
		private var _over:Boolean = false;
		
		

		
		public function ListSliderHorizontal() 
		{
			
		}
		
		
		public function setup(areaWidth:Number, areaHeight:Number, ease:Number = 1, gradienteMargin:Number = 15):void 
		{
			_areaWidth = areaWidth;
			_areaHeight = areaHeight;
			_gradienteMargin = gradienteMargin;
			_ease = ease;
			
			//var gradProp:Number = MathUtils.scale(_gradienteMargin, 0, (areaWidth + _gradienteMargin * 2), 0, 255);
			
			//containerMask.addChild(ShapeUtils.createGradientRectangle(areaWidth+_gradienteMargin*2, areaHeight, [0xffffff, 0xffffff, 0xffffff,0xffffff],[0,1,1,0],[0,gradProp,255-gradProp,255], 0 ));
			containerMask.addChild(ShapeUtils.createRectangle(_areaWidth, _areaHeight, 0xffffff,1, _gradienteMargin));
			containerMask.addChild(ShapeUtils.createGradientRectangle(_gradienteMargin, _areaHeight, [0xffffff, 0xffffff],[0,1],[0,255],0, 0));
			containerMask.addChild(ShapeUtils.createGradientRectangle(_gradienteMargin, _areaHeight, [0xffffff, 0xffffff],[1,0],[0,255],0, _areaWidth+_gradienteMargin));
			containerMask.x = -_gradienteMargin;
			containerMask.y = -5;
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

			itemWidth = Math.round(container.width/container.numChildren);
			visibleItems = Math.round((containerMask.width-_gradienteMargin*2) / itemWidth);
			
			if (container.width > (containerMask.width - _gradienteMargin * 2)) {
				
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
			if (_over == false && (Math.abs(getPosition() - container.x))<1) {
				removeEventListener(Event.ENTER_FRAME, newframe);
			}
		}
					
		private function getPosition():Number 
		{
			var mouseXpos = mouseX;
			if (mouseXpos<0) {
				mouseXpos = 0;
			}else if (mouseXpos>_areaWidth) {
				mouseXpos = _areaWidth;
			}
			return (_areaWidth-container.width)/_areaWidth*mouseXpos;
		}
		
		private function slide():void {
			
			container.x += (getPosition() - container.x) / _ease;
		}


		public function resetPosition(){
			container.x = 0;
		}
	
		public function scrollToItem(i:uint):void
		{
			if(i>0 && i<container.numChildren){
			
				var dest;
				if (i > visibleItems) {
					
					var diff = i-visibleItems;
					dest = -(diff*itemWidth+_gradienteMargin);
					tween.setTween(container, "x", TweenSafe.REG_EASEOUT, container.x, dest, 0.5, true, true);

				}else{
					leftHidenItems = Math.round(-container.x/itemWidth);
					
					if(leftHidenItems > 0 && i <= leftHidenItems){
						trace(leftHidenItems)
						dest = Math.round(-(i-1)*itemWidth);
						tween.setTween(container, "x", TweenSafe.REG_EASEOUT, container.x, dest, 0.5, true, true);
					}
					
				}
			}
		}

	}
}

