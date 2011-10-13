package com.smp.components{
	
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	
	import caurina.transitions.Tweener;
	
	
	public class Accordion extends MovieClip {
		
		public static const OPEN_COMPLETE:String = "OPEN_COMPLETE";
		
		private var mywidth;
		private var myheight;
		private var navW;
		private var navH;
		private var panelN;
		private var panelW;
		private var panelH;
		private var panelWithBtnWidth;
		private var panelWithBtnHeight;
		private var mk:Sprite;
		
		public var currpanel:Number = -1;
		private var vertical:Boolean;
		//public static const EVENT_ON_CHANGE = "change";
		
		
		/**
		 * @example
			
			navpanelV e contents são duas classes definidas na Biblioteca
			
			//se painel vertical (opção true), height é ignorado, porque é calculado em função da altura do content
			//vice versa se horizontal (opção false)
			
			var accordV:Accordion = new accordion(400, 300, 4, 20, 20,true);
			
			accordV.addPanel(new navpanelV, new contents);
			accordV.addPanel(new navpanelV, new contents);
			accordV.addPanel(new navpanelV, new contents);
			accordV.addPanel(new navpanelV, new contents);
			accordV.openPanel(1);
			addChild(accordV);
			accordV.y=300;
	
			
		 * @param	$width
		 * @param	$height
		 * @param	panelNumber
		 * @param	navWidth
		 * @param	navHeight
		 * @param	allignment
		 */
		public function Accordion($width:Number, $height:Number, panelNumber:Number=0, navWidth:Number=0,navHeight:Number=0,allignment:Boolean=false){
			
			vertical=allignment;
			mywidth  = $width;
			myheight = $height;
			panelN = panelNumber;
			navW = navWidth;
			navH = navHeight;
			
			if (!vertical) mywidth = panelN * navW;
			else myheight = panelN * navH;
			
			this.graphics.beginFill(0xFF0000, 0);
			this.graphics.drawRect(0,0, mywidth, myheight);
			this.graphics.endFill();
			panelW = $width-panelNumber*navWidth;
			panelH = $height-panelNumber*navHeight;
			panelWithBtnWidth=panelW+navWidth;
			panelWithBtnHeight=panelH+navHeight;
			mk = new Sprite();
			mk.graphics.beginFill(0xFF0000, 0);
			mk.graphics.drawRect(0,0, mywidth, myheight);
			mk.graphics.endFill();
			this.addChild(mk);
			this.mask = mk;
			
		}
		
		public function start():void 
		{
			var obj;
			var i;
		
			for(i=1;i<this.numChildren;i++){
				obj = this.getChildAt(i) as Sprite;
				obj.getChildByName("btn").addEventListener(MouseEvent.CLICK, handleOpenClick);
				obj.getChildByName("btn").buttonMode=true;
			}
		}
		
		public function openPanel(pNumber:Number):void{
			var obj;
			var i;
		
			for(i=1;i<this.numChildren;i++){
				obj = this.getChildAt(i) as Sprite;
				obj.getChildByName("btn").addEventListener(MouseEvent.CLICK, handleOpenClick);
				obj.getChildByName("btn").buttonMode=true;
			}
			
			
			obj = this.getChildAt(pNumber) as Sprite;
			obj.getChildByName("btn").buttonMode=false;
			obj.getChildByName("btn").removeEventListener(MouseEvent.CLICK, handleOpenClick);
			
			var contentSize:Number;
			if (!vertical) contentSize = obj.getChildByName("content").width;
			else contentSize = obj.getChildByName("content").height-2;
			
			for(i=pNumber+1; i<this.numChildren;i++){
				obj = this.getChildAt(i);
				////////////////////////
				/*
				if (!vertical)  Tweener.addTween(obj, {x:mywidth-(this.numChildren-i)*navW, time:1.0, transition:"easeOutCubic", rounded:true});
				else Tweener.addTween(obj, {y:myheight-(this.numChildren-i)*navH, time:1.0, transition:"easeOutCubic", rounded:true});
				*/
				/////////////////////////
				
				if (!vertical)  Tweener.addTween(obj, {x:contentSize+i*navW, time:1.0, transition:"easeOutCubic", rounded:true});
				else Tweener.addTween(obj, {y:contentSize+(i-1)*navH, time:1.0, transition:"easeOutCubic", rounded:true});
				
			}
			for(i=1; i<=pNumber;i++){
				obj = this.getChildAt(i);
				////////////////////////
				if (!vertical) Tweener.addTween(obj, {x:(i-1)*navW, time:1.0, transition:"easeOutCubic", rounded:true});
				else Tweener.addTween(obj, {y:(i-1)*navH, time:1.0, transition:"easeOutCubic", rounded:true});
				////////////////////////
			}
			
			if (!vertical) Tweener.addTween(mk, {width:this.numChildren*navW + contentSize, time:1.0, transition:"easeOutCubic", onComplete:onCompleteHandler, rounded:true});
			else Tweener.addTween(mk, {height:(this.numChildren-1)*navH + contentSize, time:1.0, transition:"easeOutCubic", onComplete:onCompleteHandler, rounded:true});
			
			currpanel = pNumber;
			
			dispatchEvent(new Event(Event.CHANGE));
			
			
		}
		
		private function onCompleteHandler():void {
			dispatchEvent(new Event(OPEN_COMPLETE));
		}
		
		public function addPanel(btnBackground:MovieClip,contMovie:MovieClip){
			var pnl:Sprite = new Sprite();
			//var color = Math.round( Math.random()*0xFFFFFF );
			var color = 0xFFFFFF;
			pnl.graphics.beginFill(color,0);
			/////////////////
			if (!vertical) pnl.graphics.drawRect(0,0,panelWithBtnWidth,myheight);
			else pnl.graphics.drawRect(0,0,mywidth,panelWithBtnHeight);
			/////////////////
			pnl.graphics.endFill();
			var btn:MovieClip = getBtnBase();
			var msk:MovieClip = getBtnBase();
			pnl.addChild(btnBackground);
			pnl.addChild(btn);
			btn.addChild(msk);
			btn.mask = msk;
			var localcont:MovieClip = contMovie;
			localcont.name = "content";
			pnl.addChild(localcont);
			/////////////////
			if (!vertical) localcont.x+=navW;
			else localcont.y += navH;
			/////////////////
			var contmask:MovieClip;
			if (!vertical) contmask = getContentBase(localcont.width);
			else contmask = getContentBase(localcont.height)
			localcont.addChild(contmask);
			localcont.mask = contmask;
			
			this.addChild(pnl);
			/////////////////
			if (!vertical) pnl.x= (this.numChildren-2)*navW;
			else pnl.y= (this.numChildren-2)*navH;
			/////////////////
			btn.panelNumber = this.numChildren-1;
			btn.mouseChildren=false;
			btn.buttonMode=true;
			btn.name="btn";
		}
		
		public function get currentOpenedPanelId():Number {
			return currpanel;
		}
		
		public function currentOpenedPanel():MovieClip {
			if(currpanel >= 0){
				var obj:Sprite = this.getChildAt(currpanel) as Sprite;
				return obj.getChildAt(0) as MovieClip;
			}
			return null;
		}
		
		public function getPanelAt(i):MovieClip {
			var obj:Sprite = this.getChildAt(i) as Sprite;
			return obj.getChildAt(0) as MovieClip;
		}
		
		public function getPanelContentsAt(i):MovieClip{
			var obj:Sprite = this.getChildAt(i) as Sprite;
			return obj.getChildAt(2) as MovieClip;
			//trace(this.getChildAt(i).getChildAt(0));
		}
		private function handleOpenClick(evt:Event){
			if (evt.target.panelNumber) {
				openPanel(evt.target.panelNumber);
			}
		}
		private function getBtnBase():MovieClip{
			var btn:MovieClip = new MovieClip();
			//var color = Math.round(Math.random()*0xFFFFFF);
			var color = 0xFFFFFF;
			btn.graphics.beginFill(color,0);
			/////////////////
			if (!vertical) btn.graphics.drawRect(0,0,navW,myheight);
			else btn.graphics.drawRect(0,0,mywidth,navH);
			/////////////////
			btn.graphics.endFill();
			return btn;
		} 
		private function getContentBase(contentSize:Number):MovieClip{
			var cont:MovieClip = new MovieClip();
			//var color = Math.round(Math.random()*0xFFFFFF);
			var color = 0xFFFFFF;
			cont.graphics.beginFill(color,0);
			/////////////////
			if (!vertical) cont.graphics.drawRect(0,0,contentSize,myheight);
			else cont.graphics.drawRect(0,0,mywidth,contentSize);
			/////////////////
			cont.graphics.endFill();
			return cont;
		}
		
		public function closePanels():void {
			var obj;
			var i;
		
			for(i=1;i<this.numChildren;i++){
				obj = this.getChildAt(i) as Sprite;
				obj.getChildByName("btn").addEventListener(MouseEvent.CLICK, handleOpenClick);
				obj.getChildByName("btn").buttonMode=true;
			}
	
			for(i=1; i<this.numChildren;i++){
				obj = this.getChildAt(i);
				////////////////////////
				if (!vertical) Tweener.addTween(obj, {x:(i-1)*navW, time:1.0, transition:"easeOutCubic", rounded:true});
				else Tweener.addTween(obj, {y:(i-1)*navH, time:1.0, transition:"easeOutCubic", rounded:true});
				////////////////////////
			}
			
			if (!vertical) Tweener.addTween(mk, {width:this.numChildren*navW, time:1.0, transition:"easeOutCubic", rounded:true});
			else Tweener.addTween(mk, {height:(this.numChildren-1)*navH, time:1.0, transition:"easeOutCubic", rounded:true});
			
			currpanel = -1;
			
		}
	}
}