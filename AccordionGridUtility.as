package com.smp.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import com.smp.common.display.SpriteId;
	import com.smp.components.Grid; 
	
	internal class  AccordionGridUtility extends Grid
	{
		
		
		//declaring it internal, this utility is used only in the AccordionGrid context
		public  function AccordionGridUtility(container:DisplayObjectContainer) 
		{
			super(container);
		}
		
		internal function getCell(i:uint):SpriteId
		{
			return _itemCollection[i][0];
		}
		
		
		
		internal function getColumnsCollection():Array{
			
			var columns:Array = new Array();
			for(var i:uint = 0; i<_columns; i++){
				columns.push(new Array());
			}	
			
			for(i = 0; i<_itemCollection.length; i++){
				//data[1] keeps cell column index (see superclass)
				columns[_itemCollection[i][0].data[1]].push(_itemCollection[i]);
			}
			
			return columns;
		}
		
		
	}
}		