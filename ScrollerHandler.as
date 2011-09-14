package com.smp.components{

	
	/*
	 * Accepts o movieClip (composite)
	 * Allows to manage different movieClips/scrollers with the same class (but not the same instance);
	 * 
	 */
	
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import com.smp.common.display.MovieClipUtilities;
	import com.smp.effects.TweenSafe;

	public class ScrollerHandler {

		protected var scroller:MovieClip;
		protected var scrollBtn:MovieClip;
		protected var scrollBkg:MovieClip;
		protected var stage:Stage;
		protected var scrollLength:Number;
		protected var scrollBounds:Object;
		
		private var _target:*;
		private var _property:String;
		private var _propertyLength:String;
		private var _frame:*;
		private var _elasticity:Number;
		private var _frameInitY:Number;
		private var _targetInitY:Number;
		private var _targetInitHeight:Number;
		
		private var _timer:Timer = new Timer(10);;
		private var _elasticityTimer:Timer = new Timer(10);
		
		private var _tween:TweenSafe = new TweenSafe();
		
		private var _destinationScrollPosition:Number;
		private var _scrollPositionOnUpdate:uint = 0;
		
		private var _addedToStage:Boolean = false;
		
		

		
		public function ScrollerHandler() {
			
		}
		
		/**
		* 	@param scrollBtn : parent must be of type MovieClip
		*	@param scrollBkg
		*/
		public function setObject(scrollBtn:MovieClip, scrollBkg:MovieClip, scrollLength:Number = 0):void {
			
			this.scrollBtn = scrollBtn;
			this.scrollBkg = scrollBkg;
			this.scrollLength = scrollLength;	
			
			if(scrollBtn.parent != null){
				if((scrollBtn.parent as MovieClip) != null){
					this.scroller = (scrollBtn.parent as MovieClip);
				}else{
					throw new Error("ScrollerHandler:setObject->Scroll button's parent must be of type MovieClip.")
				}
			}else {
				throw new Error("ScrollerHandler:setObject->Objects must be added to the display list.");
			}
			
			
			if(scroller.stage != null){
				stage = scroller.stage;
				_addedToStage = true;
				scrollBtn.buttonMode = true;
			}else {
				throw new Error("ScrollerHandler:setObject->Parent object must be added to the display list.")
			}
			
			//_scroller.addEventListener(Event.ADDED_TO_STAGE, onStageReady);
			//onStageReady();
		}
		
		public function init(target:*, elasticity:Number = 1, property:String = "y", onwheel:Boolean = true):void {
			_target = target;
			_elasticity = elasticity;
			_property = property;
			
			_frameInitY = scroller[_property];
			_targetInitY = _target[_property];
			_destinationScrollPosition = scrollBtn[_property];
			
			if (_property == "y") {
				_propertyLength = "height";
			}else {
				_propertyLength = "width";
			}

			if(scrollLength == 0){
				scrollLength = scrollBkg[_propertyLength];
			}
			
			var scrolldistance:Number = scrollLength - scrollBtn[_propertyLength];
			
			scrollBounds = new Object();
			
			if (_property == "y") {
				scrollBounds.x = 0;
				scrollBounds.y = 0;
				scrollBounds.width = 0;
				scrollBounds.height = scrolldistance;
			}else {
				scrollBounds.x = 0;
				scrollBounds.y = 0;
				scrollBounds.width = scrolldistance;
				scrollBounds.height = 0;
			}
			
			MovieClipUtilities.setDraggable(scrollBtn, false, scrollBounds.x, scrollBounds.y, scrollBounds.width, scrollBounds.height);

			scrollBtn.addEventListener("Drag", onDrag);

			
			if (scrollBkg != null)
			{
				scrollBkg.buttonMode = true;
				scrollBkg.addEventListener(MouseEvent.MOUSE_UP, onRepositionScrollBtn);
			}
			_targetInitHeight = _target[_propertyLength];

			_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			_timer.start();
			
			if (onwheel)
			{	
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			}
		}
		
		/*
		private function onStageReady(evt:Event = null):void 
		{	
			if (_target != undefined) 
			{		
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			}
		}
		*/
		
		private function onTimer(evt:TimerEvent):void
		{
			evalScrollable();
		}
		
		public function evalScrollable():Boolean 
		{
			_timer.removeEventListener(TimerEvent.TIMER, evalScrollable);
			_timer.reset();
			
			if (_target[_propertyLength] > scrollLength) {
				scroller.visible = true;
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
				return true;
			} else {
				scroller.visible = false;
				verifyTargetReset();
				stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
				return false;
			}
			
			return false;
		}
		
		private function verifyTargetReset():void{
			if(_target[_property] != _targetInitY){
				scrollBtn[_property] = 0;
				_tween.setTween(_target, _property, TweenSafe.REG_EASEOUT, _target[_property], 0, 0.5)
			}
		}
		
		private function onDrag(evt:Event):void 
		{
			
			scroller.addEventListener(Event.ENTER_FRAME, moveTarget, false, 0, true);
			scroller.removeEventListener(Event.ENTER_FRAME, moveScrollBtn);
		}
		
		private function moveTarget(evt:Event):void 
		{
			if(Math.abs(_target[_property] - getTargetPosition()) > 1){
				setTargetPosition();
			}else {
				
				scroller.removeEventListener(Event.ENTER_FRAME, moveTarget);
				if(Math.abs(_destinationScrollPosition - scrollBtn[_property]) < 1){
					scroller.removeEventListener(Event.ENTER_FRAME, moveScrollBtn);
				}
			}
		}
		private function setTargetPosition() {
			_target[_property] += (getTargetPosition()-_target[_property])/_elasticity;
		}
		
		private function getTargetPosition():Number{
			return Math.round(_targetInitY + ((scrollLength-_target[_propertyLength] )/(scrollLength - scrollBtn[_propertyLength]))*scrollBtn[_property] + (_frameInitY-_targetInitY));
		}
		
		private function onRepositionScrollBtn(evt:MouseEvent):void 
		{
			var bkgLoc = new Point();
			if (_property == "y") {
				bkgLoc[_property] = evt.localY;
			}else {
				bkgLoc[_property] = evt.localX;
			}
			
			if (bkgLoc[_property] < scrollBounds[_propertyLength]) {
				_destinationScrollPosition = bkgLoc[_property];
				trace("_destinationScrollPosition a "+_destinationScrollPosition)
			} else {
				_destinationScrollPosition = scrollBounds[_propertyLength];
				trace("_destinationScrollPosition b "+_destinationScrollPosition)
			}
			trace("_destinationScrollPosition "+_destinationScrollPosition)
			scroller.addEventListener(Event.ENTER_FRAME, moveScrollBtn, false, 0, true);
		}
		
		
		//updates scroller if there have been changes on the target 
		public function updateScroller(scrollPosition:uint = 0):void {
			
			if(scrollPosition < 3){
				_scrollPositionOnUpdate = scrollPosition;
			}
			
			_targetInitHeight= _target[_propertyLength];
			_timer.addEventListener(TimerEvent.TIMER, onTimerUpdate, false, 0, true);
			_timer.start();

		}
		
		//updates scroll button on regard of target position change
		public function updateScrollButton():void 
		{
			var scrollPosition:Number = (_target[_property] - _targetInitY - (_frameInitY - _targetInitY)) / ((scrollLength - _target[_propertyLength] ) / (scrollLength - scrollBtn[_propertyLength]));

			if (scrollPosition > scrollBounds[_propertyLength]) {
				scrollPosition = scrollBounds[_propertyLength];
			}else if(scrollPosition < 0) {
				scrollPosition = 0;
			}else {
				scrollPosition = scrollPosition;
				//scrollBtn[_property] = scrollPosition;
			}
			
			_tween.setTween(scrollBtn, _property, TweenSafe.REG_EASEIN, scrollBtn[_property], scrollPosition, 0.5)
		}
		
		//updates target on regard of scroll button change
		public function updateTarget():void
		{
			/*
			var bkgLoc = new Point();
			bkgLoc[_property] = scrollBtn[_property];
			if (bkgLoc[_property] < scrollBounds[_propertyLength]) {
				_destinationScrollPosition = bkgLoc[_property];
			} else {
				_destinationScrollPosition = scrollBounds[_propertyLength];
			}
			*/
			
			scroller.addEventListener(Event.ENTER_FRAME, moveTarget, false, 0, true);
		}
		
		
		private function onTimerUpdate(evt:TimerEvent) {
			_timer.removeEventListener(TimerEvent.TIMER, onTimerUpdate);
			_timer.reset();
			
			var scrollactive:Boolean = evalScrollable();
			
			switch(_scrollPositionOnUpdate){
				case 0:
					_destinationScrollPosition = 0;
					break;
				case 1:
					_destinationScrollPosition = scrollBounds[_propertyLength];
					break;
				case 2:
					_destinationScrollPosition = scrollBtn[_property];
					break;
				
			}
			
			if(!scrollactive){
				_destinationScrollPosition = 0;	
			}	
			
			//scroller.addEventListener(Event.ENTER_FRAME, moveTarget, false, 0, true);
			scroller.addEventListener(Event.ENTER_FRAME, moveScrollBtn, false, 0, true);
		}
		
		private function moveScrollBtn(evt:Event):void
		{
			moveTarget(evt);
			scrollBtn[_property] += (_destinationScrollPosition - scrollBtn[_property]) / _elasticity;
			
		}
		
		public function reset():void {
			scroller.removeEventListener(Event.ENTER_FRAME, moveTarget);
			scroller.removeEventListener(Event.ENTER_FRAME, moveScrollBtn);
			scrollBtn.removeEventListener("Drag", onDrag);
			if(scrollBkg != null){
				scrollBkg.removeEventListener(MouseEvent.MOUSE_UP, onRepositionScrollBtn);
			}

			_target[_property] = _targetInitY;
			scrollBtn[_property] = 0;
			_targetInitHeight= _target[_propertyLength];
			_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			_timer.start();

		}
		
		private function onWheel(evt:MouseEvent):void {
			
			var scrollPosition:Number = scrollBtn[_property] - evt.delta*4;
			if (scrollPosition > scrollBounds[_propertyLength]) {
				_destinationScrollPosition = scrollBounds[_propertyLength];
			}else if(scrollPosition < 0) {
				_destinationScrollPosition = 0;
			}else {
				_destinationScrollPosition = scrollPosition;
				scrollBtn[_property] = scrollPosition;
			}
			scroller.addEventListener(Event.ENTER_FRAME, moveScrollBtn, false, 0, true);
		
		}
	
	}
}