package com.smp.components.base
{
	import flash.events.Event;
	
	
	
	//Abstract class
	public class  Composite extends Component
	{
		protected var aChildren:Array;
		
		public function Composite() {
			this.aChildren  = new Array();
		}
		
		override public function add(c:Component):void {
			aChildren.push(c);
			c.setParent(this);
		}
		
		override public function update(evt:Event = null):void {
			for each (var c:Component in aChildren) {
				c.update(evt);
			}
		}
		
		override public function getChild(n:int):Component {
			if (n > 0 && n <= aChildren.length) {
				return aChildren[n - 1];
			}else {
				return null;
			}
		}
		
		override internal function getComposite():Composite {
			return this;
		}
		
		override public function remove(c:Component):void {
			if (c === this) {
				for (var i:int = 0; i < aChildren.length; i++) {
					safeRemove(aChildren[i]);
				}
				this.aChildren = [];
				this.removeParentRef();
			}else {
				for (var j:int = 0; j < aChildren.length; j++) {
					if (aChildren[j] == c) {
						safeRemove(aChildren[j]);
						aChildren.splice(j, 1);
					}
				}
			}
		}
		
		protected function safeRemove(c:Component):void {
			if (c.getComposite()) {
				c.remove(c);
			}else {
				c.removeParentRef();
			}
		}
	}
	
}