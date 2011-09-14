package com.smp.components
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import com.smp.common.display.ShapeUtils;
	import com.smp.common.display.SpriteId;
	
		
	public class  AccordionGrid extends Sprite
	{
		private var _grid:AccordionGridUtility;
		private var _container:Sprite;
		private var _itemCollection:Array;
		private var _columnsCollection:Array;
		
		private var _cellwidth:Number;
		private var _cellheight:Number; 
		private var _columns:Number = 0; 
		private var _rows:Number = 0; 
		private var _rowspace:Number = 0; 
		private var _colspace:Number = 0;
		private var _minwidth:Number = 0;
		private var _cellcolor:Number;
		private var _tweenDelay:Number;
		
		private var _activeColumn:uint;
		
		
		/**
		*
		*@exemple:
			
			var accgrid:AccordionGrid = new AccordionGrid();
			
			var color:Array = [0xff0000,0x00ff00,0x0000ff,0xffff00,0xff00ff,0x00ffff,0xdddddd,0x000000,0xff0000,0x00ff00,0x0000ff,0xffff00,0xff00ff,0x00ffff,0xdddddd,0x000000];
			for(var i:uint = 0; i<color.length; i++){
				var shape:Shape =  ShapeUtils.createRectangle(100, 70, color[i]);
				accgrid.addItem(shape);
					
			}
			
			accgrid.buildHorizontal(100, 70, 5, 0, 5, 5, 10, 0xffffff, 0.2);
			addChild(accgrid);
			accgrid.x = 200;
			accgrid.y = 100;
		*/
		
		public  function AccordionGrid() 
		{
			_grid = new AccordionGridUtility(this);
			_container = new Sprite();
			_itemCollection = new Array();
			
		}
		
		public function addItem(item:DisplayObject):void 
		{
			_grid.addItem(item);
		}
		
		public function getTotalItems():uint {
			return _grid.getTotalItems();
		}
		
		public function getItem(i:uint):DisplayObject {
			return _grid.getItem(i);
		}
		
		public function setItem(newitem:DisplayObject, i:uint):void {
			
			_grid.setItem(newitem, i);
		}
	
		/**
		 * Empties the container, but leaves the cell available
		 * @param	item
		 */
		public function clearItem(i:uint):void {
			_grid.clearItem(i);
		}
		
		
		
		public function getItemAt(row:uint, col:uint):DisplayObject 
		{
			return _grid.getItemAt(row,col);
		}
		
		public function setItemAt(newitem:DisplayObject, row:uint, col:uint):void 
		{
			_grid.setItemAt(newitem, row, col);
		}
		
		/**
		 * Empties the container, but leaves the cell available
		 * @param	row
		 * @param	col
		 */
		public function clearItemAt(row:uint, col:uint):void {
			
			_grid.clearItemAt(row,col);
		}
		
		/**
		 * If no arguments are passed to the method, a 4 columns grid is rendered, with as many rows as need
		 * @param	cellwidth
		 * @param	cellheight
		 * @param	columns
		 * @param	rows
		 * @param	rowspace
		 * @param	colspace
		 * @param	minwidth	: if 0, defaults to 1/10th of the cellwidth
		 * @param	cellcolor	: if defaults to -1, it will be transparent
		 * @param	tweenDelay	
		 * @param	itemCollection: will replace any collection previous filled in with addItem()
		 */
		public function buildHorizontal(cellwidth:Number, cellheight:Number, columns:Number = 0, rows:Number = 0, rowspace:Number = 0, colspace:Number = 0, minwidth:Number = 0, cellcolor:Number = -1, tweenDelay:Number = 0.5, itemCollection:Array = null):void 
		{
			if(minwidth==0){
				minwidth=cellwidth*0.1;
			}
			_minwidth = minwidth;
			_cellwidth  = cellwidth;
			_cellheight = cellheight;
			_tweenDelay = tweenDelay;
			_cellcolor = cellcolor;
			_grid.build(minwidth, cellheight, columns, rows, rowspace, colspace, itemCollection);
			
			for(var i:uint=0; i<_grid.getTotalItems(); i++){
				if(_cellcolor > 0){
					_grid.getCell(i).addChildAt(ShapeUtils.createRectangle(_cellwidth, _cellheight, _cellcolor), 0);
				}	
				_grid.getCell(i).scaleX = _minwidth/_cellwidth;
			}
			
			createColumnHandlers();
			
		}	
		
		private function createColumnHandlers():void{
			
			_columnsCollection = new Array();
			var columns:Array = _grid.getColumnsCollection();
			//private class, see at the end of file...
			var columnhandler:AccordionGridColumnHandler;
			for(var i:uint = 0; i<columns.length; i++){
				
				columnhandler = new AccordionGridColumnHandler(_tweenDelay);
				columnhandler.index = i;
				var cells:Array = new Array();
				var items:Array = new Array();
				for(var j:uint = 0; j<columns[i].length; j++){
					
					cells.push(columns[i][j][0]);
					items.push(columns[i][j][1]);
				}	
				columnhandler.cells = cells;
				columnhandler.items = items;
				columnhandler.side = AccordionGridColumnHandler.LEFT;
				if(_cellcolor > 0){
					columnhandler.background = true;
				}
				columnhandler.setWidths(_minwidth, _cellwidth);
				
				columnhandler.addEventListener(Event.OPEN, onColumnOpen);
				_columnsCollection.push(columnhandler);
				
			}
			
			openFirst();
		}
		
		private function openFirst():void{
			_activeColumn = 0;
			(_columnsCollection[0] as AccordionGridColumnHandler).openToRight();
			for(var i:uint = 1; i<_columnsCollection.length; i++){
				(_columnsCollection[i] as AccordionGridColumnHandler).moveToRight();
			}
		}
		
		private function onColumnOpen(evt:Event):void{
			openColumn((evt.currentTarget as AccordionGridColumnHandler).index);
		}
		
		private function openColumn(index:uint):void{	
			
			var selectedColumn = index;
			if(_activeColumn < selectedColumn){
				for(var i:uint = _activeColumn+1; i<selectedColumn; i++){
					(_columnsCollection[i] as AccordionGridColumnHandler).moveToLeft();
				}
				(_columnsCollection[_activeColumn] as AccordionGridColumnHandler).closeToLeft();
				(_columnsCollection[selectedColumn] as AccordionGridColumnHandler).openToLeft();
				
			}else{
				for(var i:uint = selectedColumn+1; i<_activeColumn; i++){
					(_columnsCollection[i] as AccordionGridColumnHandler).moveToRight();
				}
				(_columnsCollection[_activeColumn] as AccordionGridColumnHandler).closeToRight();
				(_columnsCollection[selectedColumn] as AccordionGridColumnHandler).openToRight();
			}
			
			
			_activeColumn = selectedColumn;
		}
		
		
	}
	
}



