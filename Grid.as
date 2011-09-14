package com.smp.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import com.smp.common.display.SpriteId;
	
	
	public class  Grid 
	{
		protected var _container:DisplayObjectContainer;
		protected var _itemCollection:Array;
		
		protected var _cellwidth:Number;
		protected var _cellheight:Number; 
		protected var _columns:Number = 0; 
		protected var _rows:Number = 0; 
		protected var _rowspace:Number = 0; 
		protected var _colspace:Number = 0;
		
		
		public  function Grid(container:DisplayObjectContainer) 
		{
			_container = container;
			_itemCollection = new Array();
			
		}
		
		
		/**
		 * @version : to implement -> create a flag on build and add item to table if flag is true
		 * @param	item
		 */
		public function addItem(item:DisplayObject):void 
		{
			var cell:SpriteId = new SpriteId();
			cell.addChild(item);
			cell.data = [0,0];
			_itemCollection.push([cell, item]);
		}
		
		public function getTotalItems():uint {
			return _itemCollection.length;
		}
		
		public function getItem(i:uint):DisplayObject {
			if(_itemCollection[i] != null){
				return _itemCollection[i][1];
			}
			return null;
		}
		
		public function setItem(newitem:DisplayObject, i:uint):void {
			
			if((_itemCollection[i][0] as SpriteId).numChildren > 0){
				(_itemCollection[i][0] as SpriteId).removeChildAt(0);
			}
			_itemCollection[i][1] = newitem;
			(_itemCollection[i][0] as SpriteId).addChild(newitem);
		}
	
		/**
		 * Empties the container, but leaves the cell available
		 * @param	item
		 */
		public function clearItem(i:uint):void {
			if((_itemCollection[i][0] as SpriteId).numChildren > 0){
				(_itemCollection[i][0] as SpriteId).removeChildAt(0);
			}
		}
		
		/**
		 * @version : to be implemented -> remove item and put others one position before
		 * @param	i
		 */
		public function removeItem(i:uint):void {
			throw new Error("To be implemented!");
		}
		
		public function getItemAt(row:uint, col:uint):DisplayObject 
		{
			for (var j:uint = 0; j < _itemCollection.length; j++) {
				if (_itemCollection[j][0].data[0] == row && _itemCollection[j][0].data[1] == col) {
					return _itemCollection[j][1];
					break;
				}
			}
			return null;
		}
		
		public function setItemAt(newitem:DisplayObject, row:uint, col:uint):void 
		{
			for (var j:uint = 0; j < _itemCollection.length; j++) {
				if (_itemCollection[j][0].data[0] == row && _itemCollection[j][0].data[1] == col) {
					if((_itemCollection[j][0] as SpriteId).numChildren > 0){
						(_itemCollection[j][0] as SpriteId).removeChildAt(0);
					}
					_itemCollection[j][1] = newitem;
					(_itemCollection[j][0] as SpriteId).addChild(newitem);
					break;
				}
			}
		}
		
		/**
		 * Empties the container, but leaves the cell available
		 * @param	row
		 * @param	col
		 */
		public function clearItemAt(row:uint, col:uint):void {
			
			for (var j:uint = 0; j < _itemCollection.length; j++) {
				if (_itemCollection[j][0].data[0] == row && _itemCollection[j][0].data[1] == col) {
					if((_itemCollection[j][0] as SpriteId).numChildren > 0){
						(_itemCollection[j][0] as SpriteId).removeChildAt(0);
					}
				}
			}
		}
		
		/**
		 * If no arguments are passed to columns and rows, a 4 columns grid is rendered, with as many rows as need
		 * @param	cellwidth
		 * @param	cellheight
		 * @param	columns
		 * @param	rows
		 * @param	rowspace
		 * @param	colspace
		 * @param	itemCollection: will replace any collection previous filled in with addItem()
		 */
		public function build(cellwidth:Number, cellheight:Number, columns:Number = 0, rows:Number = 0, rowspace:Number = 0, colspace:Number = 0, itemCollection:Array = null):void 
		{
			
			if (rows == 0 && columns != 0) {
				if (itemCollection != null) {
					rows = Math.ceil(itemCollection.length / columns);
				}else {
					rows = Math.ceil(_itemCollection.length / columns);
				}
				
			}else if (columns == 0 && rows != 0) {
				
				if (itemCollection != null) {
					columns = Math.ceil(itemCollection.length / rows);
				}else {
					columns = Math.ceil(_itemCollection.length / rows);
				}
			}
			
			if (rows == 0 && columns == 0) {
				
				columns = 4;
				if (itemCollection != null) {
					rows = Math.ceil(itemCollection.length / columns);
				}else {
					rows = Math.ceil(_itemCollection.length / columns);
				}
			}
			
			var a:uint
		
			if (itemCollection != null && _itemCollection.length > 1) {
				
				_itemCollection.splice(0, _itemCollection.length - 1);
				
				
				for (a = 0; a < itemCollection.length; a++) {
					this.addItem(itemCollection[a] as DisplayObject);
				}
				
			}
			
			
			_cellwidth  = cellwidth;
			_cellheight = cellheight;
			_columns = columns;
			_rows = rows;
			_rowspace = rowspace;
			_colspace = colspace;
			
			var row:Number = 0;
			var col:Number = 0;
			
			for (a = 0; a < _itemCollection.length; a++) 
			{
				
				(_itemCollection[a][0] as SpriteId).x = (cellwidth + colspace) * col;
				(_itemCollection[a][0] as SpriteId).y = (cellheight + rowspace) * row;
				
				(_itemCollection[a][0] as SpriteId).data[0] = row;
				(_itemCollection[a][0] as SpriteId).data[1] = col;
				
				col++;
				if (col == columns) {
					row++;
					col = 0;
				}
				
				_container.addChild((_itemCollection[a][0] as SpriteId));
			}
		}
	}
	
}