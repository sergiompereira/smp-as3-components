package com.smp.components{

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	/**
	 * Allows for sliding in all directions a display object larger than a visible area, set as mask
	 * Possible interactions to reveal the hiden areas of the object are free mouse movement slide response, 
	 * and snaping the object to framed positions within a grid of four or nine slices of the whole object
	 * in accordance to the mouse position.
	 */

	public class DisplayObjectSlider extends EventDispatcher{

		public const SLIDER:uint = 0;
		public const SCROLLER:uint = 1;
		public const SNAPER_FOUR:uint = 2;
		public const SNAPER_NINE:uint = 3;

		private var _type:uint;
		private var _obj:*;
		private var _objHolder:*;
		private var _dimVisibleArea:Array;
		private var _posVisibleArea:Array;
		private var _ease:uint;

		private var _posObjOriginal:Array;
		private var _guides:Array;

		private var _mouseOver:Boolean = false;
		private var _resetPhase:Boolean = false;
		private var _timer:Timer;
		


		public function DisplayObjectSlider() {
			_timer = new Timer(10);
		}

		public function setMouseSlider(obj:*, objHolder:*, posVisibleArea:Array, dimVisibleArea:Array, ease:uint = 1) {

			_type = this.SLIDER;

			_obj = obj;
			_objHolder = objHolder;
			_dimVisibleArea = dimVisibleArea;
			_posVisibleArea = posVisibleArea;
			_ease = ease;

			_posObjOriginal = new Array(_obj.x, _obj.y);

			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, onMouseActivity);
		}
		public function setMouseSnaper(obj:*, objHolder:*, posVisibleArea:Array, dimVisibleArea:Array, ease:uint = 1, NINEareas:Boolean = false):void {

			_obj = obj;
			_objHolder = objHolder;
			_dimVisibleArea = dimVisibleArea;
			_posVisibleArea = posVisibleArea;
			_ease = ease;

			if (!NINEareas) {
				_type = SNAPER_FOUR;
				_guides = new Array(_posVisibleArea[0]+_dimVisibleArea[0]/2, _posVisibleArea[1]+_dimVisibleArea[1]/2);
			} else {
				_type = SNAPER_NINE;
				_guides = new Array(_posVisibleArea[0]+_dimVisibleArea[0]/3, _posVisibleArea[0]+2*_dimVisibleArea[0]/3, _posVisibleArea[1]+_dimVisibleArea[1]/3, _posVisibleArea[1]+2*_dimVisibleArea[1]/3);
			}

			_posObjOriginal = new Array(_obj.x, _obj.y);

			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, onMouseActivity);
		}
		private function onMouseActivity(evt:TimerEvent):void {

			if (!_mouseOver && evalMouseActivity()) {
				_mouseOver = true;
				start();
			} else if (_mouseOver && !evalMouseActivity()) {
				_mouseOver = false;
				reset();

			}
		}
		private function evalMouseActivity():Boolean {
			var limiteInfX:Number = _posVisibleArea[0];
			var limiteInfY:Number = _posVisibleArea[1];
			var limiteSupX:Number = _posVisibleArea[0]+_dimVisibleArea[0];
			var limiteSupY:Number = _posVisibleArea[1]+_dimVisibleArea[1];
			var activo:Boolean;

			if (_objHolder.mouseX > limiteInfX && _objHolder.mouseX < limiteSupX && _objHolder.mouseY > limiteInfY && _objHolder.mouseY < limiteSupY) {
				activo = true;
			} else {
				activo = false;
			}
			return activo;
		}
		private function init(evt:Event):void {
			switch (_type) {
				case SLIDER :
					slide();
					break;
				case SNAPER_FOUR :
					snapFOUR();
					break;
				case SNAPER_NINE :
					snapNINE();
					break;

			}
		}
		private function slide():void {

			var xFinal:Number = _posObjOriginal[0] +(_dimVisibleArea[0]-_obj.width)/_dimVisibleArea[0]*(_objHolder.mouseX-_posVisibleArea[0])+(_posVisibleArea[0]-_posObjOriginal[0]);
			_obj.x += (xFinal-_obj.x)/_ease;
			var yFinal:Number = _posObjOriginal[1] +(_dimVisibleArea[1]-_obj.height)/_dimVisibleArea[1]*(_objHolder.mouseY-_posVisibleArea[1])+(_posVisibleArea[1]-_posObjOriginal[1]);
			_obj.y += (yFinal-_obj.y)/_ease;
		}
		private function snapFOUR():void {

			var xFinal:Number;
			var yFinal:Number;

			if (_objHolder.mouseX > _guides[0] ) {
				xFinal = _posVisibleArea[0] - (_obj.width - _dimVisibleArea[0]);
				_obj.x += (xFinal-_obj.x)/_ease;
			} else {
				xFinal = _posVisibleArea[0];
				_obj.x += (xFinal-_obj.x)/_ease;
			}
			if (_objHolder.mouseY > _guides[1] ) {
				yFinal = _posVisibleArea[1] - (_obj.height - _dimVisibleArea[1]);
				_obj.y += (yFinal-_obj.y)/_ease;
			} else {
				yFinal = _posVisibleArea[1];
				_obj.y += (yFinal-_obj.y)/_ease;
			}

		}
		private function snapNINE():void {
			var xFinal:Number;
			var yFinal:Number;

			if (_objHolder.mouseX > _guides[1] ) {
				xFinal = _posVisibleArea[0] - (_obj.width - _dimVisibleArea[0]);
				_obj.x += (xFinal-_obj.x)/_ease;
			} else if (_objHolder.mouseX < _guides[0] ) {
				xFinal = _posVisibleArea[0];
				_obj.x += (xFinal-_obj.x)/_ease;
			} else {
				xFinal = _posVisibleArea[0] - (_obj.width - _dimVisibleArea[0])/2;
				_obj.x += (xFinal-_obj.x)/_ease;
			}
			if (_objHolder.mouseY > _guides[3] ) {
				yFinal = _posVisibleArea[1] - (_obj.height - _dimVisibleArea[1]);
				_obj.y += (yFinal-_obj.y)/_ease;
			} else if (_objHolder.mouseY < _guides[2] ) {
				yFinal = _posVisibleArea[1];
				_obj.y += (yFinal-_obj.y)/_ease;
			} else {
				yFinal = _posVisibleArea[1] - (_obj.height - _dimVisibleArea[1])/2;
				_obj.y += (yFinal-_obj.y)/_ease;
			}

		}
		private function start():void {
			if (_resetPhase) {
				//_obj.removeEventListener(Event.ENTER_FRAME, centre);
				//_resetPhase = false;
			}
			_obj.addEventListener(Event.ENTER_FRAME, init);
		}
		public function reset():void {
			
			//_resetPhase = true;
			_obj.removeEventListener(Event.ENTER_FRAME, init);
			//_obj.addEventListener(Event.ENTER_FRAME, centre);
		}
		private function centre(evt:Event):void {
			var xFinal:Number;
			var yFinal:Number;
			xFinal = _posVisibleArea[0] - (_obj.width - _dimVisibleArea[0])/2;
			yFinal = _posVisibleArea[1] - (_obj.height - _dimVisibleArea[1])/2;

			if (Math.abs(xFinal-_obj.x) > 0.5 || Math.abs(yFinal-_obj.y) > 0.5) {
				_obj.x += (xFinal-_obj.x)/_ease;
				_obj.y += (yFinal-_obj.y)/_ease;
			} else {
				_obj.removeEventListener(Event.ENTER_FRAME, centre);
				_resetPhase = false;
			}
		}
		public function clear():void {

			if (_obj != null) {
				//_obj.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseActivity);
				_timer.removeEventListener(TimerEvent.TIMER, onMouseActivity);
				_timer.reset();
			}
			if (_mouseOver) {
				_obj.removeEventListener(Event.ENTER_FRAME, init);
				_mouseOver = false;
			}
			if (_resetPhase) {
				_obj.removeEventListener(Event.ENTER_FRAME, centre);
				_resetPhase = false;
			}
		}
	}
}