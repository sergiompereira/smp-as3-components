package com.smp.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	
	import com.smp.common.display.SpriteId;
	import com.smp.effects.TweenSafe;
	

	internal class AccordionGridColumnHandler extends EventDispatcher{
	
		internal static const LEFT:String = "left";
		internal static const RIGHT:String = "right";
		
		internal var index:uint;
		internal var side:String;
		internal var open:Boolean = false;
		internal var background:Boolean = false;
		
		private var minWidth:Number;
		private var maxWidth:Number;
		private var minScale:Number;
		
		private var _cells:Array;
		private var _items:Array;
		private var _initCellPosX:Number;
		private var _initItemPosX:Number;
		
		private var _tweener:TweenSafe = new TweenSafe();
		private var _delay:Number;
		
		public function AccordionGridColumnHandler(tweenDelay:Number = 0.5) {
			_delay = tweenDelay;	
		}
		
		public function setWidths(min:Number, max:Number):void{
			minWidth = min;
			maxWidth = max;
			minScale = minWidth/maxWidth;
		}
		
		internal function set cells(value:Array):void{
			_cells = value;
			_initCellPosX = _cells[0].x;
			
			for(var j:uint = 0; j<_cells.length; j++){
				(_cells[j] as SpriteId).addEventListener(MouseEvent.MOUSE_OVER, onCellOver);
			}
		}
		
		private function onCellOver(evt:MouseEvent):void{
			/*for(var j:uint = 0; j<_cells.length; j++){
				(_cells[j] as SpriteId).removeEventListener(MouseEvent.MOUSE_OVER, onCellOver);
			}*/	
			dispatchEvent(new Event(Event.OPEN));
		}
			
		
		internal function set items(value:Array):void{
			_items = value;
			//assumed...
			_initItemPosX = 0;
			for(var j:uint = 0; j<_items.length; j++){
				tweenItemAlpha(_items[j], 0);
			}	
		}
		
		internal function openToLeft():void{
			open = true;
			for(var i:uint = 0; i<_cells.length; i++){
				_cells[i].removeEventListener(MouseEvent.MOUSE_OVER, onCellOver);
				_items[i].x = -maxWidth;
				_cells[i].x = _initCellPosX+maxWidth;
				tweenCellWidth(_cells[i], 1);
				tweenItemAlpha(_items[i], 1);
				if(background){
					_cells[i].getChildAt(0).x = _items[i].x
				}
			}	
		}
		internal function openToRight():void{
			open = true;
			for(var i:uint = 0; i<_cells.length; i++){
				_cells[i].removeEventListener(MouseEvent.MOUSE_OVER, onCellOver);
				_items[i].x = 0;
				_cells[i].x = _initCellPosX;
				tweenCellWidth(_cells[i], 1);
				tweenItemAlpha(_items[i], 1);
				if(background){
					_cells[i].getChildAt(0).x = _items[i].x
				}
			}	
		}
		internal function closeToLeft():void{
			open = false;
			for(var i:uint = 0; i<_cells.length; i++){
				_cells[i].addEventListener(MouseEvent.MOUSE_OVER, onCellOver);
				_items[i].x = 0;
				_cells[i].x = _initCellPosX;
				tweenCellWidth(_cells[i], minScale);
				tweenItemAlpha(_items[i], 0);
				if(background){
					_cells[i].getChildAt(0).x = _items[i].x
				}
			}	
		}
		internal function closeToRight():void{
			open = false;
			for(var i:uint = 0; i<_cells.length; i++){
				_cells[i].addEventListener(MouseEvent.MOUSE_OVER, onCellOver);
				_items[i].x = -maxWidth;
				_cells[i].x = _initCellPosX+maxWidth;
				tweenCellWidth(_cells[i], minScale);
				tweenItemAlpha(_items[i], 0);
				if(background){
					_cells[i].getChildAt(0).x = _items[i].x
				}
			}
		}
		internal function moveToLeft():void{
			for(var i:uint = 0; i<_cells.length; i++){
				_items[i].x = 0;
				_cells[i].x = _initCellPosX+maxWidth-minWidth;
				tweenCellPos(_cells[i], _initCellPosX);
				if(background){
					_cells[i].getChildAt(0).x = _items[i].x
				}
			}	
		}
		internal function moveToRight():void{
			for(var i:uint = 0; i<_cells.length; i++){
				_items[i].x = -maxWidth;
				_cells[i].x = _initCellPosX+minWidth;
				tweenCellPos(_cells[i], _initCellPosX+maxWidth);
				if(background){
					_cells[i].getChildAt(0).x = _items[i].x
				}
			}	
		}
		
		private function tweenCellWidth(cell:DisplayObject, endvalue:Number):void{
			_tweener.setTween(cell, "scaleX", TweenSafe.REG_EASEINOUT, cell.scaleX, endvalue, _delay);
		}
		private function tweenCellPos(cell:DisplayObject, endvalue:Number):void{
			_tweener.setTween(cell, "x", TweenSafe.REG_EASEINOUT, cell.x, endvalue, _delay);
		}
		private function tweenItemAlpha(item:DisplayObject, endvalue:Number):void{
			_tweener.setTween(item, "alpha", TweenSafe.REG_EASEINOUT, item.alpha, endvalue, _delay);
		}
	}	
	
}