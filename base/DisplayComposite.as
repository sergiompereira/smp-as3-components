package com.smp.components.base {
	

	import flash.errors.IOError;	
	
	
	public class DisplayComposite extends Composite {
		
		protected var view:*;
		
		public function DisplayComposite() {
			
			super();
		}
		
		/**
		*Abstract method. Override and use args as initialization parameters
		*/
		protected function setView(arg:Object = null):void {
			
		}
		
		public function getView():* {
			
			if(view!=null)
			{
				return view;
			}else{
				throw new IOError("DisplayComposite->getView: view is not yet initialized");
			}
			
			return null
		}
		
	}
}