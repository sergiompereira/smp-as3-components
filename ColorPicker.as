package com.smp.components
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	
	import com.smp.common.display.ShapeUtils;
	import com.smp.common.math.ColorUtils;
	
	import com.smp.common.events.CustomEvent;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.*;
	
	/**
	 * @see http://www.boostworthy.com/blog/?p=200
	 */
	
	 
	public class ColorPicker extends Sprite 
	{
		public static const SPECTRUM:Array = ColorPicker.spectrum();
		
		public static const BLACK:Object = {colors: [0x000000, 0x000000], alphas:[1, 0], ratios:[0, 255] };
		public static const WHITE:Object = {colors: [0xffffff, 0xffffff], alphas:[1, 0], ratios:[0, 255] };;
		public static const BLACK_TO_WHITE:Object = {colors: [0x000000, 0x000000, 0xffffff, 0xffffff], alphas:[1, 0, 0, 1], ratios: [0, 127, 127, 255]};
		public static const DARK_TO_BRIGHT:Object = {colors: [0x000000, 0x000000, 0xffffff, 0xffffff], alphas:[0.7, 0, 0, 0.7], ratios: [0, 100, 155, 255]};
		public static const NONE:Object = null;
		
		
		private var spectrum:Sprite;
		private var bmd:BitmapData;
		private var _colors:Array;
		private var selectedColor:int;
		
		private var _eyedroperIcon:MovieClip;
		private var _positionIcon:Shape;
		private var _tween:GTween;
		
		public function ColorPicker(eyedroperIcon:MovieClip = null) 
		{
			
			if (eyedroperIcon != null) {
				_eyedroperIcon = eyedroperIcon;
				_eyedroperIcon.mouseEnabled = false;
			}
			
			_positionIcon = ShapeUtils.createCircle(5, 0xffffff, 0, 0, 0, 1, 0xffffff);
			_tween = new GTween(_positionIcon);
			
			spectrum = new Sprite();
			addChild(spectrum);
		}
		
		/**
		 * @example	_picker.buildLinear([0x00ff00, 0xff0000, 0x0000ff, 0xffff00, 0x00ffff], new Point(200,100), ColorPicker.BLACK_TO_WHITE, false);
		 * 			_picker.buildLinear(ColorPicker.spectrum(), new Point(200, 100), ColorPicker.DARK_TO_BRIGHT, true);
		 * @param	colors				: if you use ColorPicker.spectrum(), leave discrete as true
		 * @param	size
		 * @param	crossOverlayType	: specify one of the ColorPicker constants or an object with the following properties as arrays: colors, alphas,ratios.
		 */
		public function buildLinear(colors:Array, size:Point, crossOverlayType:Object = null, discrete:Boolean = true):void {
			_colors = colors;
			selectedColor = colors[0];
			drawGradientLinear(colors, size, crossOverlayType, 0, discrete);
		}
		
		/**
		 * @example	_picker.buildGrid([0x000000, 0x00ff00, 0xff0000, 0x0000ff, 0xffff00, 0x00ffff, 0xffffff], new Point(200, 100), 4,0,5);
		 * @param	colors
		 * @param	size
		 * @param	columns
		 * @param	rows
		 * @param	gutter
		 */
		public function buildGrid(colors:Array, size:Point, columns:uint=0, rows:uint = 0, gutter:uint = 1):void {
			_colors = colors;
			selectedColor = colors[0];
			drawGradientGrid(colors, size, columns, rows, gutter);
		}
		
		/**
		 * 
		 * @param	radius
		 * @param	colors
		 * @param	crossOverlayType	: specify one of the ColorPicker constants or an object with the following properties as arrays: colors, alphas,ratios
		 * @param	discrete			: if there should not be used gradients between the colors
		 */
		public function buildRadial(colors:Array, radius:uint, innerRadius:uint = 0, crossOverlayType:Object = null, discrete:Boolean = true):void {
			_colors = colors;
			selectedColor = colors[0];
			drawGradientRadial(colors, radius, innerRadius, crossOverlayType, discrete);
		}
		
		private function drawGradientLinear(xcolors:Array, size:Point, crossOverlayType:Object = null, matrixRotation:Number = 0, discrete:Boolean = true):void 
		{
			
			var fill:String = GradientType.LINEAR;
			
			if (discrete) {
				
				var xinc:Number = size.x / xcolors.length;
				for (var i:uint = 0; i < xcolors.length; i++) {
					
					/*
					spectrum.graphics.lineStyle(xinc, xcolors[i], 1, false, LineScaleMode.NONE, CapsStyle.NONE);
					spectrum.graphics.moveTo(i*xinc, 0);
					spectrum.graphics.lineTo(i * xinc, size.y);
					*/
					
					spectrum.graphics.beginFill(xcolors[i]);
					spectrum.graphics.drawRect(i*xinc, 0, xinc, size.y);
					
				}
				
			}else{
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(size.x, size.y, matrixRotation, 0, 0);
				
				var alphas:Array = new Array();
				var ratios:Array = new Array();
				var ratInc:Number = Math.floor(255 / (xcolors.length-1));
				var xinc:Number = size.x / xcolors.length;
				for (var i:uint = 0; i < xcolors.length; i++) {
					
					alphas.push(1);
					ratios.push(i * ratInc);
				
				}
				
				spectrum.graphics.beginGradientFill(fill, xcolors, alphas, ratios, matrix);
				spectrum.graphics.drawRect(0, 0, size.x, size.y);
			}
			
			if (crossOverlayType != null) {
				
				var matOverlay:Matrix = new Matrix();
				matOverlay.createGradientBox(size.x, size.y, Math.PI/2, 0, 0);
				var overlay:Sprite = new Sprite();
				overlay.graphics.beginGradientFill(fill, crossOverlayType.colors, crossOverlayType.alphas, crossOverlayType.ratios, matOverlay);
				overlay.graphics.drawRect(0, 0, size.x, size.y);
				spectrum.addChild(overlay);
			}
			
			
			handleColorSelection();
			
		}
		
		
		private function drawGradientGrid(colors:Array, size:Point, columns:uint = 0, rows:uint = 0, gutter:uint = 1):void {
			
			if (columns == 0 && rows == 0) {
				columns = Math.ceil(Math.sqrt(colors.length));
				rows = columns;
			}else if(columns == 0){
				columns = Math.ceil(colors.length / rows);
			}else if(rows == 0){
				rows = Math.ceil(colors.length / columns);
			}
			
			var cellw:Number = (size.x- gutter*(columns-1))/columns;
			var cellh:Number = (size.y- gutter*(rows-1))/rows ;
			
			var i:uint;
			var j:uint;
			var colorIndex:uint = 0;
			for (i = 0; i < rows; i++) {
				
				for (j = 0; j < columns; j++) {
					if(colorIndex < colors.length){
						spectrum.graphics.beginFill(colors[colorIndex]);
						spectrum.graphics.drawRect(j * (cellw + gutter), i * (cellh + gutter), cellw, cellh);
					}
					
					colorIndex++;
				}
			}
		
		
			handleColorSelection();
			
		}
		
		private function drawGradientRadial(colors:Array, size:uint, innerSize:uint = 0, crossOverlayType:Object = null, discrete:Boolean = true):void 
		{
			
			var nRadians:Number;
			var nX:Number;
			var nY:Number;
			var sX:Number;
			var sY:Number;
	
			spectrum.x = size;
			spectrum.y = size;
			
			var angleCounter:Number = 0;
			var angleInc:Number = 360 / colors.length;
			var colorIndexCounter:uint = 0;
			var colorIndexSubCounter:uint = 0;
			
			var gradientCollection:Array;

			if (!discrete) {
				colors.push(colors[0]);
				var temp:Array = new Array();
				for (var j:uint = 0; j < colors.length; j++) {
					temp.push(colors[j]);
					temp.push(Math.round(angleInc-1));
				}
				temp.pop();
				gradientCollection = ColorUtils.getGradient(temp);
			}
			
			
			var lineThickness:Number = Math.ceil(2 * Math.PI * size / 360);
			
			for (var i:uint = 0; i <= 360; i++)
			{
				  
				nRadians = i * (Math.PI / 180);
				
				nX = size * Math.cos(nRadians);
				nY = size * Math.sin(nRadians);
				sX = innerSize * Math.cos(nRadians);
				sY = innerSize * Math.sin(nRadians);

				/*	
				objMatrix = new Matrix();
				objMatrix.createGradientBox(size * 2, size * 2, nRadians, -size, -size);
				*/
				
				if (gradientCollection != null) {
					spectrum.graphics.lineStyle(lineThickness, gradientCollection[colorIndexCounter*Math.round(angleInc) + colorIndexSubCounter], 1, false, LineScaleMode.NONE, CapsStyle.NONE);
					colorIndexSubCounter++;
					
				}else{
					spectrum.graphics.lineStyle(lineThickness, colors[colorIndexCounter], 1, false, LineScaleMode.NONE, CapsStyle.NONE);
				}
				
				spectrum.graphics.moveTo(sX, sY);
				spectrum.graphics.lineTo(nX, nY);
				
				angleCounter++;
				if (angleCounter >= angleInc) {
					colorIndexCounter++;
					angleCounter = 0;
					colorIndexSubCounter = 0;
				}
				
			}
			
			
			//overlay
			
			var overlay:Sprite;
			var matOv:Matrix;
			var fill:String;
			
			
			if (crossOverlayType != null) {				
					
				overlay = new Sprite();
				matOv = new Matrix();
				fill = GradientType.RADIAL;
				matOv.createGradientBox(size * 2, size * 2, 0, -size, -size);
					
				overlay.graphics.beginGradientFill(fill, crossOverlayType.colors, crossOverlayType.alphas, crossOverlayType.ratios, matOv);
				overlay.graphics.drawCircle(0, 0, size);
				
				spectrum.addChild(overlay);
			}
					
					
			handleColorSelection();

		}
		
		private function handleColorSelection():void 
		{
			bmd = new BitmapData(width, height, false, 0xffffffff);
			bmd.draw(this);
			
			addEventListener(MouseEvent.CLICK, onClick);
			
			if(_eyedroperIcon != null){
				addEventListener(MouseEvent.MOUSE_OVER, onOver);
				addEventListener(MouseEvent.MOUSE_OUT, onOut);
			}
		}
		
		private function onClick(evt:MouseEvent):void 
		{
			selectedColor = bmd.getPixel(mouseX, mouseY);
		
			
			if(!this.contains(_positionIcon)){
				addChild(_positionIcon);
				_positionIcon.x = mouseX;
				_positionIcon.y = mouseY;
			}else {
				_tween.setValue("x", mouseX);
				_tween.setValue("y", mouseY);
				_tween.duration = 0.2;
				_tween.ease = Sine.easeOut;
			}
		
			
			dispatchEvent(new Event(Event.SELECT));
			
		}
		
		private function onOver(evt:MouseEvent):void 
		{
			Mouse.hide();
			addChild(_eyedroperIcon) ;
			addEventListener(Event.ENTER_FRAME, onNewFrame );
				
		}
	
		
		private function onOut(evt:MouseEvent):void 
		{
			
			Mouse.show();
			removeChild(_eyedroperIcon) ;
			removeEventListener(Event.ENTER_FRAME, onNewFrame );
		}
		
		private function onNewFrame(evt:Event) {
			_eyedroperIcon.x = mouseX; 
			_eyedroperIcon.y = mouseY
		}
		
		
		public function getColor():int 
		{
			return selectedColor;
			
		}
		
		public function setDefaultColor(color:Number):Boolean {
			for (var i:uint = 0; i < _colors.length; i++) {
				if (color == _colors[i]) {
					selectedColor = _colors[i];
					//calcular a posição no spectrum de acordo com o tipo de color picker
					//addChild(_positionIcon);
			
					dispatchEvent(new Event(Event.SELECT));
					return true;
					break;
				}
			}
			
			return false;
		}
		
		public static function spectrum():Array 
		{
			
			var nRadians:Number;
			var nR:Number;
			var nG:Number;
			var nB:Number;
			var nColor:Number;
			var spectrumColors:Array = new Array();
			
			for (var i:uint = 0; i <= 360; i++)
			{
	
				/*
				 * A little maths (bitwise operation):
				 * 00010111 LEFT-SHIFT =  00101110
				 * 00010111 RIGHT-SHIFT =  00001011
				 * 
				 * A left arithmetic shift by n is equivalent to multiplying by Math.pow(2,n), 
				 * while a right arithmetic shift by n is equivalent to dividing by Math.pow(2,n).
				 * 
				 * In C-inspired languages, the left and right shift operators are "<<" and ">>", respectively. 
				 * The number of places to shift is given as the second argument to the shift operators.
				 * x = y << 2;
				 */
				
				nRadians = i * (Math.PI / 180);
				nR = Math.cos(nRadians)                   * 127 + 128 << 16;
				nG = Math.cos(nRadians + 2 * Math.PI / 3) * 127 + 128 << 8;
				nB = Math.cos(nRadians + 4 * Math.PI / 3) * 127 + 128;
				   
				
				/*
				 * Some more maths (bitwise operation continued):
				 * The | (vertical bar) operator performs a bitwise OR on two integers. 
				 * Each bit in the result is 1 if either of the corresponding bits in the two input operands is 1. 
				 * For example, 0x56 | 0x32 is 0x76, because:

					  0 1 0 1 0 1 1 0
					| 0 0 1 1 0 0 1 0
					  ---------------
					  0 1 1 1 0 1 1 0

				 */

				 
				nColor  = nR | nG | nB;
				
				spectrumColors.push(nColor);
			}
			
			return spectrumColors;
			
		}
	}
	
}