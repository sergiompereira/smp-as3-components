package com.smp.components
{
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	
	import com.smp.common.display.SpriteId;
	import com.smp.common.text.TextUtils;
	import com.smp.components.ListScroller; 

	/**
	 * Creates a label that handles the display of a ListScroller.
	 * Handles label interaction to open and close the list, as well as item selection from the list and label update.
	 * Public methods to open and close de ListScroller are available for handling outside of the class.
	 * 
	 * Typical use:
	 * 
	 * 	var dd:DropDown = new DropDown();

		dd.y = 100;
		dd.x = 200;
		addChild(dd)
		dd.setup(200, 100, 0, 30);
		for(var i:uint = 0; i<= 20; i++){
			
			dd.addItem("item " +i);
		}

		dd.setDefaultDate("item 3");

	 */

	public class DropDown extends Sprite 
	{
		
		private var textField:TextField;
		private var list:ListScroller = new ListScroller();
		private var itemCollection:Array = new Array();
		private var timer:Timer = new Timer(50);
		private var counter:int = -1;
		
		private var _labelFormat:TextFormat = new TextFormat("Verdana", 10,0x000000, false,null, null, null,null,TextFieldAutoSize.LEFT);
		private var _itemOverFormat:TextFormat = new TextFormat("Verdana", 10,0x000000, false,null, null, null,null,TextFieldAutoSize.LEFT);
		private var _itemOutFormat:TextFormat = new TextFormat("Verdana", 10,0x000000, false,null, null, null,null,TextFieldAutoSize.LEFT);
		
		private var _selectedId:int;
		private var _open:Boolean = false;
		
		
		
		public function DropDown() {
			
		}
		
		public function setup(listWidth:Number, listHeight:Number, listx:Number, listy:Number, labelFormat:TextFormat = null, itemOverFormat:TextFormat = null, itemOutFormat:TextFormat = null):void{
			
			list.setup(listWidth, listHeight);
			list.x = listx;
			list.y = listy;
			addChild(list);
			
			if (labelFormat != null) {
				_labelFormat = labelFormat;
			}
			
			if (itemOverFormat != null) {
				_itemOverFormat = itemOverFormat;
			}
			
			if (itemOutFormat != null) {
				_itemOutFormat = itemOutFormat;
			}
			
			textField = TextUtils.createTextField("", _labelFormat);
			var label:Sprite = new Sprite();
			label.addChild(textField);
			label.buttonMode = true;
			label.addEventListener(MouseEvent.MOUSE_UP, onTextUp);
			addChild(label);

		}
		
		
		public function setDefaultDate(value:String):void {
			textField.text = value;
			
			if (itemCollection.length > 0) {
				var exists:Boolean = false;
				for (var i in itemCollection) {
					if (((itemCollection[i] as Sprite).getChildAt(0) as TextField).text == value) {
						_selectedId = i;
						exists = true;
						break;
					}
				}
				if (!exists) {
					_selectedId = -1;
				}
			}
		}
		
		public function addItem(value:String):void {
			var item:SpriteId = new SpriteId();
			item.addChild(TextUtils.createTextField(value, _itemOutFormat));
			item.y = itemCollection.length * 15;
			item.buttonMode = true;
			item.id = itemCollection.length;
			
			item.addEventListener(MouseEvent.MOUSE_OVER, onItemOver);
			item.addEventListener(MouseEvent.MOUSE_OVER, onItemOut);
			item.addEventListener(MouseEvent.MOUSE_UP, onItemUp);
			
			itemCollection.push(item);
			
		}
		
		public function get selectedValue():String {
			return textField.text;
		}
		
		public function get selectedId():int {
			return _selectedId;
		}
		
		private function onTextUp(evt:MouseEvent):void {
			this.toggle();
		}
		
		private function onItemUp(evt:MouseEvent):void {
			textField.text = ((evt.currentTarget as Sprite).getChildAt(0) as TextField).text;
			this.close();
			_selectedId = (evt.currentTarget as SpriteId).id;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onItemOver(evt:MouseEvent):void {
			((evt.currentTarget as Sprite).getChildAt(0) as TextField).setTextFormat(_itemOverFormat);
		}
		
		private function onItemOut(evt:MouseEvent):void {
			((evt.currentTarget as Sprite).getChildAt(0) as TextField).setTextFormat(_itemOutFormat);
		}
		
		
		
		private function onTimer(evt:TimerEvent):void {
			counter++;
			list.addItem(itemCollection[counter]);
			if (counter == itemCollection.length - 1) {
				timer.reset();
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				list.start();
			}
		}
		
		public function open():void {
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			counter = -1;
			_open = true;
		}
		
		public function close():void {
			list.resetPosition();
			list.clear();
			_open = false;
		}
		
		public function toggle():void {
			if (_open) {
				this.close();
			}else {
				this.open();
			}
		}
	}
	
}