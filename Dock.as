package com.smp.components{
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	public class Dock extends MovieClip {

		public static const LAYOUTTYPE_BOTTOM:String = "bottom";
		public static const LAYOUTTYPE_TOP:String = "top";
		public static const LAYOUTTYPE_LEFT:String = "left";
		public static const LAYOUTTYPE_RIGHT:String = "right";
		
		private var itemColl:Array = new Array();
		private var _yOffset:Number = 100;
		
		private var _params:DockParams;
		
		private var _icon_min		: Number;
		private var _icon_max		: Number;
		private var _icon_size		: Number;
		private var _icon_spacing	: Number;
		private var _width			: Number;
		private var _span			: Number;
		private var _amplitude		: Number;
		private var _ratio			: Number;
		private var _scale			: Number = Number.NEGATIVE_INFINITY;
		private var _trend			: Number = 0;
		private var _xmouse			: Number;
		private var _ymouse			: Number;
		private var _layout			: String;
		private var _callback		: Function;
		private var _items			: Array;

		public function Dock() {
			
		}

		/**
		 * 
		 * @param	params : Use DockParams public properties
		 * For layout, use this public static vars
		 * Good defaults:
		 * - layout = "bottom";
		 * - icon_min = 32;
		 * - icon_max = 96;
		 * - icon_spacing = 2;
		 * - icon_size = 50;
		 * - items (your collection of class names as string) = ["myMc1","myMc2","myMc3"]
		 * 
		 */
		public function init(params:DockParams):void {
			
			_params = params;
			setParameters();
			setLayout();
			createIcons();
			//createTray();
			addEventListener(Event.ENTER_FRAME, monitorDock);
		}
		
		private function setParameters():void {
			this._layout = _params.layout ? _params.layout : 'bottom';
			this._icon_min = _params.icon_min ? _params.icon_min : 32;
			this._icon_max = _params.icon_max ? _params.icon_max : 96;
			this._icon_spacing = _params.icon_spacing ? _params.icon_spacing : 20;
			this._span = _params.span ? _params.span : getSpan();
			this._amplitude = _params.amplitude ? _params.amplitude : getAmplitude();
			this._ratio =  Math.PI / 2 / this._span;
			this._icon_size = _params.icon_size ? _params.icon_size : 50;
			this._items = _params.items;
		}

		private function getSpan():Number {
			return (this._icon_min - 16) * (240 - 60) / (96 - 16) + 60;
		}

		private function getAmplitude():Number {
			return 2 * (this._icon_max - this._icon_min + this._icon_spacing);
		}

		private function createIcons():void 
		{
			var item:DockItem;
			var i:Number;
			
			this._scale = 0;
			this._width = (this._items.length - 1) * this._icon_spacing + this._items.length * this._icon_min;
			
			var left:Number = (this._icon_min - this._width) / 2;
			
			for(i = 0; i < this._items.length; i++) {

				item = new DockItem();
				
				var dynclass:Class = this._items[i] as Class;
				item.addChild(new dynclass());
				item.id = i;
				addChild(item);
				itemColl.push(item);
				
				item.y = -this._icon_size / 2;
				//item.rotation = -this.rotation;
				item.x = item._x = left + i * (this._icon_min + this._icon_spacing) + this._icon_spacing / 2;
				item._y = -this._icon_spacing;
				item.addEventListener(MouseEvent.MOUSE_UP,  launchIcon);
			}
		}

		private function launchIcon(evt:MouseEvent):void {
			//this._parent.callback(this._parent.items[this._name].label);
		}

		private function setLayout():void {
			switch(this._layout) {
				case 'left':
					this.rotation = 90;
					break;
				case 'top':
					this.rotation = 180;
					break;
				case 'right':
					this.rotation = 270;
					break;
				case 'bottom':
					this.rotation = 0;
					break;
				default:
					this.rotation = Number(this._layout);
			}
		}

		private function checkBoundary():Boolean {
			var buffer:Number = 4 * this._scale;
			return (this._ymouse < _yOffset)
				&& (this._ymouse > -2 * this._icon_spacing - this._icon_min + (this._icon_min - this._icon_max) * this._scale)
				&& (this._xmouse > itemColl[0].x - itemColl[0].width / 2 - this._icon_spacing - buffer)
				&& (this._xmouse < itemColl[itemColl.length-1].x + itemColl[itemColl.length-1].width / 2 + this._icon_spacing + buffer);
		}
			
		
	
		private function monitorDock(evt:Event):Boolean 
		{
			var i:Number;
			var x:Number;
			var dx:Number;
			var dim:Number;

			// Mouse did not move and Dock is not between states. Skip rest of the block.
			if((this._xmouse == this.mouseX) && (this._ymouse == this.mouseY) && ((this._scale <= 0.01) || (this._scale >= 0.99))) { return false; }

			// Mouse moved or Dock is between states. Update Dock.
			this._xmouse = this.mouseX;
			this._ymouse = this.mouseY;

			// Ensure that inflation does not change direction.
			this._trend = (this._trend == 0 ) ? (checkBoundary() ? 0.25 : -0.25) : (this._trend);
			this._scale += this._trend;
			if( (this._scale < 0.02) || (this._scale > 0.98) ) { this._trend = 0; }

			// Actual scale is in the range of 0..1
			this._scale = Math.min(1, Math.max(0, this._scale));

			// Hard stuff. Calculating position and scale of individual icons.
			/*for( i = 0; i < this._items.length; i++) {
				dx = this.getChildByName("cont" + i.toString())._x - this._xmouse;
				dx = Math.min(Math.max(dx, -this._span), this._span);
				dim = this._icon_min + (this._icon_max - this._icon_min) * Math.cos(dx * this._ratio) * (Math.abs(dx) > this._span ? 0 : 1) * this._scale;
				this.getChildByName("cont" + i.toString()).x = this.getChildByName("cont" + i.toString())._x + this._scale * this._amplitude * Math.sin(dx * this._ratio);
				this.getChildByName("cont" + i.toString()).scaleX = this.getChildByName("cont" + i.toString()).scaleY =  1 * dim / this._icon_size;
			}*/
			
			for( i = 0; i < itemColl.length; i++) {
				dx = itemColl[i]._x - this._xmouse;
				dx = Math.min(Math.max(dx, -this._span), this._span);
				dim = this._icon_min + (this._icon_max - this._icon_min) * Math.cos(dx * this._ratio) * (Math.abs(dx) > this._span ? 0 : 1) * this._scale;
				itemColl[i].x = itemColl[i]._x + this._scale * this._amplitude * Math.sin(dx * this._ratio);
				itemColl[i].scaleX = itemColl[i].scaleY =  1 * dim / this._icon_size;
			}
						
			return true;
		}

	}
}

import srg.display.utils.MovieClipId;

class DockItem extends MovieClipId {
	
	public var _x:Number;
	public var _y:Number;
	
	public function DockItem() {
		
	}
}
