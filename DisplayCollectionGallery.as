package com.smp.components{
	
/*
******************
@ Sérgio Pereira
******************

*/
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.errors.IllegalOperationError;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	import com.smp.effects.TweenSafe;
	import com.smp.common.display.DisplayObjectUtilities;

	/**
	 * Allows to show an horizontal or vertical sequence, or a cross fade, of a collection of display objects.
	 * The setup allows to set a mask and the distance between objects
	 * Methods next and previous and an event dispatcher allows to associate a navigation to external buttons.
	 * Autoslide is possible and also an incremental loading is optional.
	 * 
	 * Actions/interactions associated to the objects (items) should be managed outside the class.
	 * A getActiveId is available, but no getActiveItem.
	 */
	
	
	
	public class DisplayCollectionGallery extends MovieClip{
		
		public static const HSLIDER:uint = 0;
		public static const VSLIDER:uint = 1;
		public static const FADER:uint = 2;
		
		public static const ITEM_CHANGE:String = "itemChange";
		
		
		protected var _objectCollection:Array = new Array();
		
		protected var _activeId:Number = -1;
		
		protected var _tipo:uint;
		protected var _sliderProperty:String;
		protected var _largura:Number;
		protected var _altura:Number;
		protected var _span:Number;
		protected var _maskCorrection:Number;
		protected var _loop:Boolean;
		protected var _autoslideTime:Number;
		protected var _transitionTime:Number;
		protected var _introtime:Number;
		protected var _direction:int;
		
		protected var _mascara:Sprite;
		protected var _totalImgs:Number;
		
		protected var _visibleImages:Number;
		
		protected var container:MovieClip = new MovieClip();
		
		protected var _tweener:TweenSafe = new TweenSafe();
		protected var _timer:Timer = new Timer(0);
		
		
		public function DisplayCollectionGallery() {
			
		}
		
		/**
		 * 
		 * @param	type : HSLIDER horizontal (x), VSLIDER vertical (y), FADER (alpha)
		 * @param	width : sets the mask size. If FADER selected, choose a value equal to the item width
		 * @param	height : sets the mask size. If FADER selected, choose a value equal to the item height
		 * @param	span : distance between items. Set to 0 if FADER type selected;
		 * @param	loop : activates the loop function, BUT DOES NOT DUPLICATE ITEMS IN CASE TYPE SLIDER HAS BEEN CHOOSEN. CALL ADDITEM TWICE TO CREATE A DOUBLE SET;
		 * @param	direction : default direction in case you which to activate auto slide. Possible values 0 and 1. If not, set to -1;
		 * @param	maskCorrection : if needed...;
		 * @param	introtime : if you whish an animation where the items will be added one after another. This value (miliseconds) is the time span between each addition. A value of 0 will build all items at once;
		 * @param	autoslideTime : time span for the auto slide (miliseconds). Defaults to 10 seconds. If not desired, set direction to -1;
		 * @param	transitionTime : time span for the slide animation (miliseconds). Defaults to 0.5 seconds.;
		 */
		public function setup(type:uint, width:Number, height:Number, span:Number = 0, loop:Boolean = false, direction:int=1, maskCorrection:Number = 0, introtime:Number = 0, autoslideTime:Number = 10000, transitionTime:Number = 0.5) {
		
			
			_largura = width;
			_altura = height;
			_tipo = type;
			if (_tipo != FADER) {
				_span = span;
			}else {
				_span = 0;
			}
			
			_loop = loop;
			_maskCorrection = maskCorrection;
			
			_introtime = introtime;
			_transitionTime = transitionTime;
			
			if (autoslideTime <= 0) {
				_autoslideTime = 10000;
			}else {
				_autoslideTime = autoslideTime;
			}
			_direction = direction;
			
			
			_mascara = new Sprite();
			with(_mascara.graphics){
				lineStyle();
				beginFill(0x000000);
				drawRect(0,0,_largura, _altura);
				endFill();
			}
			_mascara.x = _maskCorrection;
			container.mask = _mascara;
			addChild(_mascara);
			addChild(container);
			
			
			
			switch(_tipo) {
				case HSLIDER:
					_sliderProperty = "x";
					_visibleImages = Math.ceil(_largura / _span);
					break;
				case VSLIDER:
					_sliderProperty = "y";
					_visibleImages = Math.ceil(_altura / _span);
					break;
				case FADER:
					_sliderProperty = "alpha";
					_visibleImages = 1;
					break;
			}
			
			if (_tipo != FADER && _span == 0) {
				throw new IllegalOperationError("Propriedade span não definida.");
			}
			
					
		}
		
		
	
		public function addItem(obj:DisplayObject):void {
			
			obj.x = obj.y = 0;
			_objectCollection.push(obj);
			_totalImgs = _objectCollection.length;
		}
		
		public function clear():void{
			
			resetDisplay();
			_objectCollection.splice(0);
			_activeId = 0;
		}
		
		private function resetDisplay():void {
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, autoSlide);
			
			DisplayObjectUtilities.deleteAllChildren(this.container);
			if(_tipo != FADER){
				this.container[_sliderProperty] = 0;
			}
		}
		
		public function build():void{
				
			resetDisplay();
			
			_totalImgs = _objectCollection.length;
			
			
			switch(_tipo) {
				case HSLIDER:
					buildSlider();
					break;
				case VSLIDER:
					buildSlider();
					break;
				case FADER:
					buildSlider();
					break;
			}
		}
		
		private function buildSlider():void {
			
			addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			
			_activeId = 0;
			
			
			var i:uint = 0;
			if (_introtime > 0) {
				_timer.delay = _introtime;
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
				_timer.start();
			}else {
				for (i = 0; i < _objectCollection.length; i++) {
					addObject(i);
				}
				dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
			
			
			function onTimer(evt:TimerEvent) {
				if (i < _visibleImages && i < _objectCollection.length) {
					
					addObject(i);
					i++;
				}else {
					
					_timer.removeEventListener(TimerEvent.TIMER, onTimer);
					_timer.stop();
					dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
					if (_visibleImages < _objectCollection.length) {
					
						for (i = _visibleImages; i < _objectCollection.length; i++) {
							
							addObject(i);
						}
					}
				}
			}
			
			function addObject(j:uint):void {
				
				var obj = _objectCollection[j];
				
				if(_tipo != FADER){
					obj[_sliderProperty] = j * _span;
				}else {
					obj.alpha = 0;
					if ((obj as DisplayObjectContainer)) {
						(obj as DisplayObjectContainer).mouseEnabled = false;
						(obj as DisplayObjectContainer).mouseChildren = false;
					}
				}

				if (j < _visibleImages) {
					
					if ((obj as DisplayObjectContainer)) {
						(obj as DisplayObjectContainer).mouseEnabled = true;
						(obj as DisplayObjectContainer).mouseChildren = true;
					}
					_tweener.setTween(obj, "alpha", TweenSafe.REG_EASEOUT, 0, 1, 1.5, true, true);
				}
				
				container.addChildAt(obj, 0);
			}
		
			dispatchEvent(new Event(Event.CHANGE));

		}
		
		private function onTimerComplete(evt:TimerEvent):void {
			
			/* Debug
			trace("timer comp "+_objectCollection.length)
			trace("numChildren " + container.numChildren);
			trace("position " + container[_sliderProperty]);
			*/
			
			removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			
			dispatchEvent(new Event("START"));
			
			
			if((_direction == 0 || _direction == 1) && _visibleImages < _objectCollection.length){
				_timer.delay = _autoslideTime;
				_timer.addEventListener(TimerEvent.TIMER, autoSlide);
				_timer.start();
			}
		}
		
		private function autoSlide(evt:TimerEvent):void {
			//trace("slide position " + container[_sliderProperty]);
			transit(_direction);
		}
		
		private function transit(direction:int):void {
			//trace("slide " + direction)
			
			switch(_tipo) {
				case HSLIDER:
					slide(direction);
					break;
				case VSLIDER:
					slide(direction);
					break;
				case FADER:
					fade(direction);
					break;
			}
		}
		
		private function slide(direction:int):void{
			
			//in case an external client has changed the container position...
			var evalCurrentId:int = Math.round( - container[_sliderProperty]/_span);
			if (evalCurrentId != _activeId) 
			{
				_activeId = evalCurrentId;
			}
			
			switch(direction) {
				
				//prev
				case 0:
					if(_loop) {
						if (_activeId <= 0) {
							_activeId = _totalImgs / 2 - 1;
							container[_sliderProperty] = -(_activeId + 1) * _span;
						}else{
							_activeId--;
						}
					}else if (_activeId <= 0) {
						//if autoslide
						if(_direction == 0 || _direction == 1){
							_direction = 1;
							slide(_direction);
							return;
						}//else ignore
					}else{
						_activeId--;
					}
					break;
					
				//next
				case 1:
					if (_loop) {
						if (_activeId >= (_totalImgs - _visibleImages -1)) {
							_activeId = _totalImgs / 2 - _visibleImages;
							container[_sliderProperty] = -(_activeId - 1) * _span;
						}else{
							_activeId++;
						}
					}else if (_activeId >= (_totalImgs - _visibleImages)) {
						//if autoslide
						if (_direction == 0 || _direction == 1) {
							_direction = 0;
							slide(_direction);
							return;
						}//else ignore
					}else{
						_activeId++;
					}
					break;
			}
			
			dispatchEvent(new Event(ITEM_CHANGE));
			setTweenSlide(-_activeId*_span);
		}
		
		private function fade(direction:int):void{
			
			setTweenFade(_objectCollection[_activeId],0);
			
			switch(direction) {
				
				//prev
				case 0:
					if(_loop) {
						if (_activeId <= 0) {
							_activeId = _totalImgs - 1;
							
						}else{
							_activeId--;
						}
					}else if (_activeId <= 0) {
						//if autoslide
						if(_direction == 0 || _direction == 1){
							_direction = 1;
							fade(_direction);
							return;
						}//else ignore
					}else{
						_activeId--;
					}
					break;
					
				//next
				case 1:
					if (_loop) {
						if (_activeId >= (_totalImgs - 1)) {
							_activeId = 0;
						
						}else{
							_activeId++;
						}
					}else if (_activeId >= (_totalImgs - 1)) {
						//if autoslide
						if (_direction == 0 || _direction == 1) {
							_direction = 0;
							fade(_direction);
							return;
						}//else ignore
						
					}else{
						_activeId++;
					}
					break;
			}
			
			dispatchEvent(new Event(ITEM_CHANGE));
			
			container.addChild(_objectCollection[_activeId]);
			setTweenFade(_objectCollection[_activeId],1);
		}
		
		private function setTweenSlide(finalx):void{
			_tweener.setTween(container, _sliderProperty, TweenSafe.REG_EASEOUT, container[_sliderProperty], finalx, _transitionTime, true, true);
		}
		
		private function setTweenFade(obj:DisplayObject, destValue:Number):void {
			
			if(destValue == 1 && (obj as DisplayObjectContainer )) {
				(obj as DisplayObjectContainer ).mouseEnabled = true;
				(obj as DisplayObjectContainer ).mouseChildren = true;
			}else if(obj as DisplayObjectContainer ){
				(obj as DisplayObjectContainer ).mouseEnabled = false;
				(obj as DisplayObjectContainer ).mouseChildren = false;
			}
			
			_tweener.setTween(obj, "alpha", TweenSafe.REG_EASEOUT, obj.alpha, destValue, _transitionTime, true, true);
		}
		
		public function get activeId():Number{
			return _activeId;
		}
		
		public function gotoItem(id:Number):void{
			
			
			switch(_tipo) {
				case HSLIDER:
					setTweenSlide(-id*_span);
					break;
				case VSLIDER:
					setTweenSlide(-id*_span);
					break;
				case FADER:
					setTweenFade(_objectCollection[_activeId], 0);
					container.addChild(_objectCollection[id]);
					setTweenFade(_objectCollection[id], 1);
					break;
			}
			
			_activeId = id;
			dispatchEvent(new Event(ITEM_CHANGE));
		}
		
		public function next():void {
			transit(1);
		}
		
		public function previous():void {
			transit(0);
		}
		
		public function setItem(id:Number):void
		{
			container.x = -id*_span;
			_activeId = id;
			
			switch(_tipo) {
				case HSLIDER:
					container[_sliderProperty] = -id*_span;
					break;
				case VSLIDER:
					container[_sliderProperty] = -id*_span;
					break;
				case FADER:
					_objectCollection[_activeId].alpha = 0;
					container.addChild(_objectCollection[id]);
					_objectCollection[id].alpha = 1;
					break;
			}
			
			_activeId = id;
			dispatchEvent(new Event(ITEM_CHANGE));
		}
		
		public function getContainer():MovieClip {
			return container;
		}
		
		public function getCollection():Array {
			return _objectCollection;
		}
	}
	
}