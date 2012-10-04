package com.smp.components 
{
	import com.smp.common.display.DisplayObjectUtilities;
	import com.smp.common.display.ShapeUtils;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	
	public class PreloaderCircular extends Sprite
	{
		protected var outerRadius:Number = 50;
		protected var innerRadius:Number = 20;
		protected var startAngle:Number = -90;
		protected var endAngle:Number = 270;
		protected var backColor:Number = 0x000000;
		protected var frontColor:Number = 0xCCCCCC;
		
		public function PreloaderCircular(x, y) {
			this.x = x;
			this.y = y;
			addChild(ShapeUtils.createWedge(0,0, outerRadius, innerRadius, startAngle, endAngle,backColor));
		}
		
		public function update(perc:Number) {
			//DisplayObjectUtilities.deleteAllChildren(this);
			if (this.numChildren > 1) {
				this.removeChildAt(1);
			}
			addChild(ShapeUtils.createWedge(0, 0, outerRadius, innerRadius, startAngle, endAngle*perc, frontColor));
		}
	}
	
}