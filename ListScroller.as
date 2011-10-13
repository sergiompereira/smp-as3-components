package com.smp.components{
	
	import flash.display.Sprite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import com.smp.common.display.ShapeUtils;
	import com.smp.common.display.DisplayObjectUtilities;
	
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.*;


	
	/**
	 * Allows for the creation of a vertical list, 
	 * seting up a mask and hit areas on top and bottom that scroll the list within its limits.
	 * y position of items must be set directly to them from outside the class, as well as interactions on them.
	 * See methods available.
	 * A loading animation may be set calling addItem on a timed interval and calling start only in the end.
	 * 
	 *
	 * 
	 * @example 	var scroller:ListScroller = new ListScroller();
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
	
	public class ListScroller extends Sprite {
		

		
		public var incrementDistance:Number = 1;
		
		protected var gradienteMargin:Number = 15;
		
		private var tween:GTween;
		private var timer = new Timer(10);


		private var scrollDir:String;

		private var scroll_dw:Sprite = new Sprite();
		private var scroll_up:Sprite = new Sprite();
		private var container:Sprite = new Sprite();
		private var containerMask:Sprite = new Sprite();

		private var itemHeight:Number;
		private var visibleItems:Number;
		private var topHidenItems:Number;
		
		private var statusActive:Boolean = false;
		
		

		
		public function ListScroller(gradienteMargin:Number = 15, incrementDistance:Number = 1) 
		{
			this.gradienteMargin = gradienteMargin;
			this.incrementDistance = incrementDistance;
		}
		
		public function setup(areaWidth:Number, areaHeight:Number):void {
			containerMask.addChild(ShapeUtils.createGradientRectangle(areaWidth, areaHeight+gradienteMargin*2, [0xffffff, 0xffffff, 0xffffff,0xffffff],[0,1,1,0],[0,20,235,255] ));
			containerMask.x = -5;
			containerMask.y = -gradienteMargin;
			addChild(container);
			addChild(containerMask);
			
			container.cacheAsBitmap = true;
			containerMask.cacheAsBitmap = true;
			container.mask = containerMask;
			
			scroll_up.addChild(ShapeUtils.createRectangle(areaWidth, gradienteMargin, 0xffffff, 0));
			scroll_dw.addChild(ShapeUtils.createRectangle(areaWidth, gradienteMargin, 0xffffff, 0));
			scroll_up.y = -gradienteMargin;
			scroll_dw.y = areaHeight;
			
			addChild(scroll_up);
			addChild(scroll_dw);
			
			tween = new GTween(container);
			
		}
		
		public function addItem(obj:DisplayObject):void 
		{
			container.addChild(obj);
		}
		
		public function start():void {

			
			itemHeight = Math.round(container.height/container.numChildren);
			visibleItems = Math.round((containerMask.height-gradienteMargin*2) / itemHeight);
			
			if (container.height > (containerMask.height - gradienteMargin * 2)) {
				
				scroll_up.buttonMode = true;
				scroll_dw.buttonMode = true;
				
				scroll_dw.addEventListener(MouseEvent.MOUSE_OVER, onOverDwn);
				scroll_up.addEventListener(MouseEvent.MOUSE_OVER, onOverUp);
				scroll_dw.addEventListener(MouseEvent.MOUSE_OUT, onOut);
				scroll_up.addEventListener(MouseEvent.MOUSE_OUT, onOut);
				
				statusActive = true;
			}else {
				
				scroll_up.buttonMode = false;
				scroll_dw.buttonMode = false;
				
				scroll_dw.removeEventListener(MouseEvent.MOUSE_OVER, onOverDwn);
				scroll_up.removeEventListener(MouseEvent.MOUSE_OVER, onOverUp);
				scroll_dw.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
				scroll_up.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
				
				statusActive = false;
			}
		}
				
		
		
		public function clear():void 
		{
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			DisplayObjectUtilities.removeAllChildren(container);
			scroll_up.buttonMode = false;
			scroll_dw.buttonMode = false;
			this.scrollToItem(1);
	
		}
		
		public function scrollActive():Boolean {
			return statusActive;
		}
		
		private function onOverDwn(evt:MouseEvent):void {
			
			scrollDir = "dw";
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		private function onOverUp(evt:MouseEvent):void {
			
			scrollDir = "up";
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		private function onOut(evt:MouseEvent):void {
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.reset();
		}


		private function onTimer(evt:TimerEvent):void{
			switch (scrollDir){
				case "dw":
					if(container.y > -(container.height-containerMask.height+gradienteMargin*2)){
						scroll_up.alpha = 1;
						container.y-=incrementDistance;
					}else{
						scroll_dw.alpha = 0;
					}
					break;
				case "up":
					if(container.y<0){
						scroll_dw.alpha = 1;
						container.y+=incrementDistance;
					}else{
						scroll_up.alpha = 0;
					}
					break;
			}
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
					dest = -(diff*itemHeight+gradienteMargin);
					tween.setValue("y", dest);
					tween.duration = 0.5;
					tween.ease = Sine.easeOut;

				}else{
					topHidenItems = Math.round(-container.y/itemHeight);
					
					if(topHidenItems > 0 && i <= topHidenItems){
						
						dest = Math.round(-(i-1)*itemHeight);
						tween.setValue("y", dest);
						tween.duration = 0.5;
						tween.ease = Sine.easeOut;
					}
					
				}
			}
		}

	}
}

