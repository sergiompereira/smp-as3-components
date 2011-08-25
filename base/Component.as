package com.smp.components.base
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	
	 //Abstract class
	public class  Component
	{
		
		protected var parentNode:Composite = null;
		
		public function Component() {
			
		}
		
		public function add(c:Component):void {
			throw new IllegalOperationError("Abstract Class: must be subclassed");
		}
		
		public function remove(c:Component):void {
			throw new IllegalOperationError("Abstract Class: must be subclassed");
		}
		
		public function getChild(n:int):Component {
			throw new IllegalOperationError("Abstract Class: must be subclassed");
			return null;
		}
		
		public function update(evt:Event = null):void {
			throw new IllegalOperationError("Abstract Class: must be subclassed");
		}
		
		internal function setParent(c:Composite):void {
			this.parentNode = c;
		}
		
		public function getParent():Composite {
			return this.parentNode;
		}
		
		internal function getComposite():Composite {
			return null;
		}
		
		internal function removeParentRef():void {
			this.parentNode = null;
		}
		
		
	}
	
}