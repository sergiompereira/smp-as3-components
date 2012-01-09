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
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.*;
	
	import com.smp.common.display.DisplayObjectUtilities;

	/**
	 * Show an horizontal or vertical sequence, or a cross fade, of a collection of display objects.
	 * The setup allows to set a mask and the distance between objects
	 * Methods next and previous and an event dispatcher allows to associate a navigation to external buttons.
	 * Auto slide and an incremental loading are optional.
	 * 
	 * Actions/interactions associated to the objects (items) should be managed outside the class.
	 */
	
	
	public class PagedGallery extends MovieClip{
		
		public static const HSLIDER:uint = 0;
		public static const VSLIDER:uint = 1;
		
		public static const PAGE_CHANGE:String = "PAGE_CHANGE";
		
		
		protected var _objectCollection:Array = new Array();
		protected var _positionDirectory:Object = new Object();
		protected var _activePage:Number = 0;
		
		protected var _type:uint;
		protected var _sliderProperty:String;
		protected var _viewport:Rectangle;
		protected var _gutter:Number;
		protected var _itemsPerPage:int;
		protected var _transitionTime:Number;
		protected var _introtime:Number;
		protected var _direction:int = 1;
		
		protected var _mask:Sprite;
		protected var _totalItems:Number;
		protected var _totalPages:Number;
		
		protected var _visibleItems:Number = 0;
		
		protected var _container:MovieClip = new MovieClip();
		protected var _tweener:GTween = new GTween(_container);
		protected var _timer:Timer = new Timer(0);
		
		
		/**
		 * Show an horizontal or vertical sequence of a collection of display objects.
		 * The navigation will be based on pages. Pages might be based on a fixed length (the viewport size) or on groups of items (see setup() for details)
		 * The setup allows to set a mask that will work as a viewport.
		 * Be sure the items are ready to display before calling start(), as their size will affect the pagination.
		 * Methods next and previous and an event dispatcher allows to associate a navigation to external buttons.
		 * Auto slide and an incremental loading are optional.
		 * 
		 * Actions/interactions associated to the objects (items) should be managed outside the class.
		 * A getActiveId is available, but no getActiveItem. Keep a reference to the collection outside the gallery and use the id to find the item in there.
		 */
		public function PagedGallery() {
			
		}
		
		/**
		 * 
		 * @param	type : HSLIDER horizontal (x), VSLIDER vertical (y)
		 * @param	viewport : sets the mask.
		 * @param	gutter : width of the white space between items;
		 * @param	itemsPerPage : set to 0 (default) to use the viewport size as the page size. A number greater then 0 will define pages based on a fixed number of items - groups. If the items are all the same size and they round to the viewport size, the default is fine.
		 * @param	maskCorrection : if needed...;
		 * @param	introtime : if you whish an animation where the items will be added one after another. This value (miliseconds) is the time span between each addition. A value of 0 will build all items at once;
		 * @param	transitionTime : time span for the slide animation (miliseconds). Defaults to 0.5 seconds.;
		 */
		public function setup(type:uint, viewport:Rectangle, gutter:Number = 0, itemsPerPage:int = 0, introtime:Number = 0, transitionTime:Number = 0.5) {
		
			
			_viewport = viewport;
			_type = type;
			_gutter = gutter;
			_itemsPerPage = itemsPerPage;
			
			_introtime = introtime;
			_transitionTime = transitionTime;	
			
			_mask = new Sprite();
			with(_mask.graphics){
				lineStyle();
				beginFill(0x000000);
				drawRect(0,0,_viewport.width, _viewport.height);
				endFill();
			}
			_mask.x = _viewport.x;
			_mask.y = _viewport.y;
			_container.mask = _mask;
			addChild(_mask);
			addChild(_container);
			
			
			
			switch(_type) {
				case HSLIDER:
					_sliderProperty = "x";
					break;
				case VSLIDER:
					_sliderProperty = "y";
					break;
				default:
					_type = HSLIDER;
					_sliderProperty = "x";
					break;	
				
			}
			
					
		}
		
		
	
		public function addItem(obj:DisplayObject):void {
			
			obj.x = obj.y = 0;
			_objectCollection.push({display:obj, position:0});
			_totalItems = _objectCollection.length;
		}
		
		public function clear():void{
			
			resetDisplay();
			_objectCollection.splice(0);
			_activePage = 0;
		}
		
		private function resetDisplay():void {
			_timer.reset();
			
			DisplayObjectUtilities.deleteAllChildren(_container);
			_container[_sliderProperty] = 0;
		}
		
		/**
		 * Be sure the items are ready to display before calling start(), as their size will affect the pagination.
		 */
		public function start():void{
				
			resetDisplay();
			
			_totalItems = _objectCollection.length;
			
			build();
		}
		
		private function build():void {
			
			addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			
			_activePage = 0;
			var i:int = 0;
			var tempSize:Number = 0;
			switch(_type) {
				case HSLIDER:
					for (i = 0; i < _objectCollection.length; i++) {
						tempSize += (_objectCollection[i].display as DisplayObject).width + _gutter;
						if (tempSize > _viewport.width) {
							_visibleItems = i+1;
							break;
						}
					}
					
					break;
				case VSLIDER:
					for (i = 0; i < _objectCollection.length; i++) {
						tempSize += (_objectCollection[i].display as DisplayObject).height + _gutter;
						if (tempSize > _viewport.height) {
							_visibleItems = i+1;
							break;
						}
					}
					
					break;
				
			}
			
			
			i = 0;
			tempSize = 0;
			
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
				if (i < _visibleItems && i < _objectCollection.length) {
					addObject(i);
					i++;
				}else {
					
					_timer.removeEventListener(TimerEvent.TIMER, onTimer);
					_timer.stop();
					
					if (_visibleItems < _objectCollection.length) {
						for (i = _visibleItems; i < _objectCollection.length; i++) {
							addObject(i);
						}
					}
					dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
				}
			}
			
			function addObject(j:uint):void {
				
				var obj = _objectCollection[j].display;
				
				obj[_sliderProperty] = tempSize;
				_objectCollection[j].position = tempSize;
				_positionDirectory["p_" + tempSize.toString()] = j;
				
				switch(_type) {
					case HSLIDER:
						tempSize += (_objectCollection[j].display as DisplayObject).width + _gutter; 
						break;
					case VSLIDER:
						tempSize += (_objectCollection[j].display as DisplayObject).height + _gutter;
						break;
				}
				
				if (j < _visibleItems) {
					
					if ((obj as DisplayObjectContainer)) {
						(obj as DisplayObjectContainer).mouseEnabled = true;
						(obj as DisplayObjectContainer).mouseChildren = true;
					}
					var tweener:GTween = new GTween(obj);
					obj.alpha = 0;
					tweener.setValue("alpha", 1);
					tweener.duration = 1.5;
					tweener.ease = Sine.easeOut;
					//_tweener.setTween(obj, "alpha", TweenSafe.REG_EASEOUT, 0, 1, 1.5, true, true);
				}
				
				_container.addChildAt(obj, 0);
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
			
			if (_itemsPerPage > 0) {
				_totalPages = Math.ceil(_objectCollection.length / _itemsPerPage);
			}else {
				_itemsPerPage = 0;
				switch(_type) {
					case HSLIDER:
						_totalPages = Math.ceil(_container.width / _viewport.width);
						break;
					case VSLIDER:
						_totalPages = Math.ceil(_container.height / _viewport.height);
						break;
				}
			}
			
			dispatchEvent(new Event(Event.INIT));
		
		}
		
		
		private function transit(direction:int):void {			
			slide(direction);
		}
		
		private function slide(direction:int):void{
			
			//in case an external client has changed the container position...
			
			var evalCurrentPage:int;
			if (_itemsPerPage > 0) {
		
			
				if (direction == 1) {
					var lastindex:int = _objectCollection.length - 1;
					var lastpos:Number = _objectCollection[lastindex].position;
					
					switch(_type) {
						case HSLIDER:
							if (lastpos - (-_container[_sliderProperty]) <= _viewport.width) {
								return;
							}
							break;
						case VSLIDER:
							if (lastpos - (-_container[_sliderProperty]) <= _viewport.height) {
								return;
							}
							break;
					}
				}
				evalCurrentPage = Math.round( getIndexFromPosition(_container[_sliderProperty], direction) / _itemsPerPage);
				
				
			}else {
				switch(_type) {
					case HSLIDER:
						evalCurrentPage = Math.round( - _container[_sliderProperty] / _viewport.width);
						break;
					case VSLIDER:
						evalCurrentPage = Math.round( - _container[_sliderProperty] / _viewport.height);
						break;
				}
			}
			
			if (evalCurrentPage != _activePage) 
			{
				_activePage = evalCurrentPage;
			}
			
			switch(direction) {
				
				//prev
				case 0:
					if (_activePage > 0) {
						_activePage--;
					}
					break;
					
				//next
				case 1:
					if (_activePage < _totalPages-1) {
						_activePage++;
					}
					break;
			}
			
			if (_itemsPerPage > 0) {
				
				var destIndex:int = _activePage * _itemsPerPage;
				var destPos:Number = _objectCollection[destIndex].position;
				setTweenSlide( -destPos);
				
			}else {
				switch(_type) {
					case HSLIDER:
						setTweenSlide( -_activePage * _viewport.width);
						break;
					case VSLIDER:
						setTweenSlide( -_activePage * _viewport.height);
						break;
				}
			}
			dispatchEvent(new Event(PAGE_CHANGE));
		}
		
		
		
		private function setTweenSlide(finalPos:Number):void {

			_tweener.setValue(_sliderProperty, finalPos);
			_tweener.duration = _transitionTime;
			_tweener.ease = Sine.easeOut;
			//_tweener.setTween(container, _sliderProperty, TweenSafe.REG_EASEOUT, container[_sliderProperty], finalx, _transitionTime, true, true);
		}
		
		
		public function get activePage():Number{
			return _activePage;
		}
		
		public function gotoPage(id:Number):void{
			
			if (_itemsPerPage > 0) {
				
				var destIndex:int = id * _itemsPerPage;
				var destPos:Number = _objectCollection[destIndex].position;
				setTweenSlide( -destPos);
				
			}else {
				switch(_type) {
					case HSLIDER:
						setTweenSlide(-id*_viewport.width);
						break;
					case VSLIDER:
						setTweenSlide(-id*_viewport.height);
						break;
				}
			}
			
			_activePage = id;
			dispatchEvent(new Event(PAGE_CHANGE));
		}
		
		public function next():void {
			transit(1);
		}
		
		public function previous():void {
			transit(0);
		}
		
		public function setPage(id:Number):void
		{
			_activePage = id;
			if (_itemsPerPage > 0) {
				
				var destIndex:int = id * _itemsPerPage;
				var destPos:Number = _objectCollection[destIndex].position;
				_container[_sliderProperty] = -destPos;
				
			}else {
				switch(_type) {
					case HSLIDER:
						_container[_sliderProperty] = -id*_viewport.width;
						break;
					case VSLIDER:
						_container[_sliderProperty] = -id*_viewport.height;
						break;
					
				}
			}
			
			_activePage = id;
			dispatchEvent(new Event(PAGE_CHANGE));
		}
		
		
		public function getNumPages():int {
			return _totalPages;
		}
		
		public function getContainer():MovieClip {
			return _container;
		}
		
		public function getCollection():Array {
			return _objectCollection;
		}
		
		public function getOffset():Number {
			return _container[_sliderProperty];
		}
		
		
		//helpers
		private function getIndexFromPosition(pos:Number, direction:int ):int {
			var i:int;
			if (direction == 0) {
				for (i = 0; i < _objectCollection.length; i++) {
					if (_objectCollection[i].position > -pos) {
						return i - 1;
					}
				}
				return _objectCollection.length - 1;
			
			}else if (direction == 1) {
				for (i = _objectCollection.length-1; i >= 0; i--) {
					if (_objectCollection[i].position < -pos) {
						return i + 1;
					}
				}
			}
			
			return 0;
		}
	}
	
}