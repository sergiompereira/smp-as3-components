package com.smp.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
		
	import com.smp.common.math.MathUtils;
	import com.smp.common.display.ShapeUtils;

	
	/*
		AS 3.0 carousel by Matt Bury.
		Adapted from Lee Brimelow's carousel tutorials at http://gotoandlearn.com/
		
		
		@example:
		#1
		//ojb1..n are instances on stage or created dynamicaly into memmory.
		carrousel = new Carrousel3D([obj1, obj2, obj3], 150,Math.PI/32,1.5,0,8,12000,true,0,5);
		addChild(carrousel);
		carrousel.start();
		
		#2
		Use in conjunction with DisplayObjectReflection to create a reflection:
		var refl1:DisplayObjectReflection = new DisplayObjectReflection();
		...
		refl1.create(obj1, [0.5,0], 40);
		...
		//center the reflection object...
		refl1.x = -refl1.width / 2;
		refl1.y = -refl1.height / 2;
		//if you wish...
		refl1.distance = 20;
		...
		var cont1:Sprite = new Sprite();
		cont1.addChild(refl1);
		...
		carrousel = new Carrousel3D([cont1, cont2, cont3], 150,Math.PI/32,1.5,0,8,12000,true,0,5);	
		addChild(carrousel);
		carrousel.start();
		
		*/
		
		
		public class Carrousel3D extends Sprite
	{
		
		public static const ITEM_CHANGE:String = "ItemChanged";
		public static const STARTED:String = "Started";
		public static const STOPED:String = "Stoped";
		

		protected var itemCollection:Array;
		protected var numOfItems:uint; // number of Items to put on stage
		protected var viewAngleSignal:int = 1;
		protected var radiusX:uint; // width of carousel
		protected var radiusY:uint; // height of carousel
		protected var centerX:Number;// x position of center of carousel
		protected var centerY:Number; // y position of center of carousel
		protected var zoomEff:Number;
		protected var speed:Number; // initial speed of rotation of carousel
		protected var transitionEase:Number;
		protected var mouseMoveEase:Number;
		protected var mouseUpEnabled:Boolean;
		protected var deepthBlur:Number;
		protected var moveBlur:Number;
		
		protected var itemArray:Array = new Array(); // store the Items to sort them according to their 'depth' - see sortBySize() function.
		
		protected var _selectedItemId:int = -1;
		
		/**
		 * 
		 * @param	collection		:	use a set of objects centered on their own stage.
		 * @param	radius
		 * @param	viewAngle		:	positive or negative, the viewer's position above or bellow the carrousel plane.
		 * @param	zoom			:	perspective distortion
		 * @param	rotationSpeed 	:	the initial speed of rotation. Positive is clockwise.
		 * @param	transitionEase	:	the ease at which the transition to a selected item is made(upon mouse up events, goToItem() and next()/prev() methods. Must be >=1.
		 * @param 	mouseMoveEase	:	if >=1, it will consider responsive to mouse movements on the X axis.
		 * @param 	mouseUpEnabled	:	if true, it will consider responsive to mouse up events on items and on stage.
		 * @param	deepthBlur			:	if >=0, creates a blur effect when the item is moving backwards.
		 * @param	moveBlur			:	if >=0, creates a dominant blur effect on the X axis when the items are moving.
		 */
		
		public function Carrousel3D(collection:Array, radius:Number = 250, viewAngle:Number = Math.PI / 8, zoom:Number = 2, rotationSpeed:Number = 0.05, transitionEase:Number = 8, mouseMoveEase:Number = 12000, mouseUpEnabled:Boolean = true, deepthBlur:Number = 0, moveBlur:Number = 0 ) 
		{
			itemCollection = new Array();
			for (var i:uint = 0; i < collection.length; i++) {
				itemCollection.push( { object: collection[i]} );
				
			}
			/*for (var i:int = collection.length-1; i>=0; i--) {
				itemCollection.push( { object: collection[i]} );
				
			}*/
			numOfItems = itemCollection.length;
			radiusX = radius;
			if (viewAngle < 0) {
				viewAngleSignal = -1;
			}
			radiusY = Math.sin(Math.abs(viewAngle)) * radiusX;
			zoomEff = zoom;
			//centerX = radiusX;
			centerX = 0;
			centerY = radiusY // zoomEffect;
			
			this.speed = rotationSpeed;
			this.transitionEase = transitionEase;
			if (this.transitionEase<1) {
				this.transitionEase = 1;
			}
			this.mouseMoveEase = mouseMoveEase;
			this.mouseUpEnabled = mouseUpEnabled;
			this.deepthBlur = deepthBlur;
			this.moveBlur = moveBlur;
			
			setup();
		}
		
		protected function setup():void {
		
			var hit = new Sprite();
			hit.addChild(ShapeUtils.createRectangle(radiusX*2, radiusY*4, 0xffffff, 0));
			addChild(hit);
			
			for(var i:uint = 0; i < numOfItems; i++) {
				(itemCollection[i] as Object).id = i;
				(itemCollection[i] as Object).angle = i * ((Math.PI * 2) / numOfItems);
				(itemCollection[i] as Object).depthZ = 0; 
				(itemCollection[i] as Object).destAngle = 0;
				
				var item:DisplayObject = ((itemCollection[i] as Object).object as DisplayObject);
				itemArray.push(item);
				addChild(item);
				
				if(mouseUpEnabled){
					// listen for MouseEvents only on icons, not on reflections
					item.addEventListener(MouseEvent.MOUSE_UP, upHandler);
				}
				
			}
			
			updateItems();

		}

		public function start():void 
		{
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			if(mouseMoveEase>=1){
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			
			dispatchEvent(new Event(Carrousel3D.STARTED));
		}
		
		
		public function stop(time:Number = 0):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			if(time == 0){
				speed = 0;
			}
			
			dispatchEvent(new Event(Carrousel3D.STOPED));
		}
		
		
		protected function getItemProperties(obj:DisplayObject):Object {
			for (var i:uint = 0; i < numOfItems; i++) {
				if ((itemCollection[i] as Object).object == obj) {
					return (itemCollection[i] as Object);
				}
			}
			
			return null;
		}
		
		// position Items in elipse
		protected function enterFrameHandler(event:Event):void 
		{
		
			updateItems();
		}

		protected function updateItems():void {
			
			for (var i:uint = 0; i < numOfItems; i++) {
				
				updateItemProperties(i);				
				(itemCollection[i] as Object).angle += speed; // speed is updated by mouseMoveHandler or constant
				(itemCollection[i] as Object).angle = (itemCollection[i] as Object).angle % (Math.PI * 2)
			}
			
			sortBySize();	
			
		}
		
		// set the display list index (depth) of the Items according to their
		// scaleX property so that the bigger the Item, the higher the index (depth)
		protected function sortBySize():void 
		{
			// There isn't an Array.ASCENDING property so use DESCENDING and reverse()
			itemArray.sortOn("scaleX", Array.DESCENDING | Array.NUMERIC);
			itemArray.reverse();
			for(var i:uint = 0; i < itemArray.length; i++) {
				var item:DisplayObject = itemArray[i];
				setChildIndex(item, i);
			}
		}

		protected function upHandler(event:MouseEvent):void {
			
			if (_selectedItemId >= 0) {
				(itemCollection[_selectedItemId].object as DisplayObject).addEventListener(MouseEvent.MOUSE_UP, upHandler);
			}
				
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			(event.currentTarget).removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, restartOnStage);
			
			var object:Object = getItemProperties((event.currentTarget as DisplayObject));
			_selectedItemId = object.id;
			centerOnSelected(object);
		}
		
		protected function centerOnSelected(properties:Object):void {
			
			
			var item:DisplayObject = properties.object;
			var id:uint = properties.id;
			var angle:Number = properties.angle;
			
			/*
			//what is the top most item
			var selectedItemIndex:Number = Math.round((angle / (Math.PI * 2)) * numOfItems);
			
			var absIndex:Number = selectedItemIndex - Math.floor(selectedItemIndex / numOfItems) * numOfItems;
			var destIndex:Number;
			if (absIndex>=Math.round(3/4*numOfItems) && absIndex < numOfItems) {
				destIndex = Math.ceil(selectedItemIndex / numOfItems) * numOfItems + 1/4*numOfItems;
			}else {
				destIndex = Math.floor(selectedItemIndex / numOfItems) * numOfItems + 1/4*numOfItems;
			}
						
			var indexOffset:Number = destIndex-selectedItemIndex;
			//trace(selectedItemIndex+" // "+indexOffset)
			*/
			
			//Math.PI / 2 is the angle at the front
			var angleOffset:Number = Math.PI / 2 - angle;
			/*
			trace("angle "+angle);
			trace("angleOffset "+angleOffset);
			trace("angleOffset/PI " + angleOffset / Math.PI);
			*/
			var direction:int = 0;
			if (Math.abs(angleOffset / Math.PI) > 1 && angleOffset > 0 && angle < 0) {
				angle = Math.PI * 2 + angle;
				angleOffset = Math.PI / 2 - angle;
				direction = 1; //cw
			}else if (Math.abs(angleOffset / Math.PI) > 1 && angleOffset < 0 && angle > 0) {
				angle = -(Math.PI * 2 - angle);
				angleOffset = Math.PI / 2 - angle;
				direction = -1; //ccw
			}
			
			//trace(direction)
			
			for (var i:uint = 0; i < itemArray.length; i++) {
				item = itemArray[i];
				var itemProp:Object = getItemProperties((item as DisplayObject));
				
				if (direction == 1 && itemProp.angle < 0) {
					itemProp.angle = Math.PI * 2 + itemProp.angle;
				}else if (direction == -1 && itemProp.angle > 0) {
					itemProp.angle = -(Math.PI * 2 - itemProp.angle);
				}
			
				(itemCollection[itemProp.id] as Object).destAngle = itemProp.angle + angleOffset;
				(itemCollection[itemProp.id] as Object).destAngle = (itemCollection[itemProp.id] as Object).destAngle % (Math.PI * 2);
			}
			
		
			
			addEventListener(Event.ENTER_FRAME, repositionItems);
			
			
		}
		
		protected function repositionItems(evt:Event = null):void {
			
			var destAngle:Number;
			for (var i:uint = 0; i < numOfItems; i++) 
			{
				destAngle = (itemCollection[i] as Object).destAngle;
				speed = (destAngle - (itemCollection[i] as Object).angle) / transitionEase;
				(itemCollection[i] as Object).angle += speed;
				(itemCollection[i] as Object).angle = (itemCollection[i] as Object).angle % (Math.PI * 2);
				
				updateItemProperties(i);
			}
			
			sortBySize();	
			
			if (Math.abs(destAngle-(itemCollection[i-1] as Object).angle) < 0.00001) {
				
				removeEventListener(Event.ENTER_FRAME, repositionItems);
				dispatchEvent(new Event(Carrousel3D.ITEM_CHANGE));
			}
			
					
			
			
		}
		
		protected function updateItemProperties(i:uint):void {
			
			var item:DisplayObject = (itemCollection[i] as Object).object;
			var id:uint = (itemCollection[i] as Object).id;
			var angle:Number = (itemCollection[i] as Object).angle;
			
		
			item.x = -Math.cos(angle) * radiusX + centerX; // x position of Item
			item.y = Math.sin(viewAngleSignal * angle) * radiusY + centerY; // y postion of Item
			(itemCollection[i] as Object).depthZ = Math.sin(angle) * radiusX + centerX;
			//var s:Number = MathUtils.scale(item.y, ( -radiusY + centerY), (radiusY + centerY), 1 / zoomEff, 1);
			var s:Number = MathUtils.scale((itemCollection[i] as Object).depthZ, ( -radiusX + centerX), (radiusX + centerX), 1 / zoomEff, 1);
			
			var filters:Array = new Array();
			if(deepthBlur > 0){
				var deepthFilter:BitmapFilter = new BlurFilter(deepthBlur * (1 - s), deepthBlur * (1 - s));
				filters.push(deepthFilter);
			}
			if (moveBlur > 0 && Math.abs(speed) > 0) {
				var absSpeed:Number = Math.abs(speed);
				var moveFilter:BitmapFilter = new BlurFilter(moveBlur*absSpeed*50, 0);
				filters.push(moveFilter);
			}
			item.filters = filters;
			
			item.scaleX = item.scaleY = s;
		}

		/*
		Update the speed at which the carousel rotates accoring to the distance of the mouse from the center of the stage. The speed variable only gets updated when the mouse moves over the Item Sprites.
		*/
		protected function mouseMoveHandler(event:MouseEvent):void {
			speed = (stage.mouseX - centerX) / mouseMoveEase;
		}

		protected function restartOnStage(event:MouseEvent):void {
			
			if (event.target == this.stage) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, restartOnStage);
				
				restart();
			}
		}
		
		
		public function restart():void {
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			if(mouseMoveEase>=1){
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			
			
			dispatchEvent(new Event(Carrousel3D.STARTED));
			
			if (_selectedItemId >= 0 && mouseUpEnabled) {
				(itemCollection[_selectedItemId].object as DisplayObject).addEventListener(MouseEvent.MOUSE_UP, upHandler);
			}
			
			_selectedItemId = -1;
		}
		
		public function get selectedItem():DisplayObject
		{
			if(_selectedItemId >= 0){
				return itemCollection[_selectedItemId].object;
			}
			return null;
		}
		
		public function get selectedItemId():int
		{
			return _selectedItemId;
		}
		
		public function next():void {
			
			goToItem(_selectedItemId + 1);
		}
		
		public function prev():void {
			goToItem(_selectedItemId - 1);
		}
		
		public function goToItem(id:int):void {
			
			if (id >= itemCollection.length)
			{
				id = 0;
			}else if (id < 0) {
				id = itemCollection.length - 1;
			}
			
			if (_selectedItemId >= 0 && mouseUpEnabled) 
			{
				(itemCollection[_selectedItemId].object as DisplayObject).addEventListener(MouseEvent.MOUSE_UP, upHandler);
			}
				
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			(itemCollection[id].object as DisplayObject).removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, restartOnStage);
			
			var object:Object = getItemProperties((itemCollection[id].object as DisplayObject));
			_selectedItemId = id;
			centerOnSelected(object);
			
		}
	}
	
}