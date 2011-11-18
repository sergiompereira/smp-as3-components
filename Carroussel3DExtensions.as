package com.smp.components
{
	
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import com.smp.components.Carrousel3D;

	public class Carroussel3DExtensions
	{
		private var _carroussel:Carrousel3D;
		private var _itemsList:Array;
		
		private var _perspectiveCorrection:int = 0;
		
		/**
		 * @example
		 * 
			
			import flash.events.MouseEvent;
			import com.smp.components.Carrousel3D;
			import com.smp.components.Carroussel3DExtensions;

			var panelList = [panel3, panel1, panel2];
			var carroussel = new Carrousel3D(panelList, 200,Math.PI / 32, 2, 0, 5, 0, true, 0, 3);
			
			carroussel_cont.addChild(carroussel);
			carroussel.start();
			carroussel.goToItem(0);
			nextbt.addEventListener(MouseEvent.CLICK, function() { carroussel.next() } );
			prevbt.addEventListener(MouseEvent.CLICK, function() { carroussel.prev() } );
			
			var csP:Carroussel3DExtensions = new Carroussel3DExtensions();
			csP.applyPerspective(panelList, carroussel, 3);
		 */

		public function Carroussel3DExtensions() 
		{
			
			
		}
		
		
		public function applyPerspective(itemsCollection:Array, carroussel:Carrousel3D, perspectiveCorrection:int = 0):void {
			_itemsList = itemsCollection;
			_carroussel = carroussel;
			_perspectiveCorrection = perspectiveCorrection;
			
			_carroussel.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		function onEnterFrameHandler(evt:Event):void
		{
			
			var elementAngle;
			for (var i = 0; i < _itemsList.length; i++) {
				elementAngle = Math.round(_carroussel.getItemProperties(_itemsList[i]).angle * (180 / Math.PI) % 360);
				if (elementAngle < 0) {
					elementAngle = 360-Math.abs(elementAngle);
				}
				
				//handle simmetry
				if (elementAngle <= 270 && elementAngle >= 90) {
					(_itemsList[i] as MovieClip).rotationY = 360 - elementAngle-180+90;
				}else {
					(_itemsList[i] as MovieClip).rotationY = 180 - elementAngle +90;
				}
				
				//handle reverse rotation at the front
				if (elementAngle <= 180 && elementAngle >= 0) {
					(_itemsList[i] as MovieClip).rotationY = elementAngle-180+90;
				}
				
				
				/*reduce perspective distortion*/
				if(_perspectiveCorrection != 0){
					if (elementAngle < 360 && elementAngle >= 180) {
						(_itemsList[i] as MovieClip).rotationY += (elementAngle - 270)/_perspectiveCorrection;
					}else {
						(_itemsList[i] as MovieClip).rotationY -= (elementAngle - 90)/_perspectiveCorrection;
					}
				}
				
			}
		}
		
	}

}