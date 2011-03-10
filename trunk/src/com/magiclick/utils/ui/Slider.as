package com.magiclick.utils.ui
{
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	* @author Hakan Karlidag
	* @company Magiclick Digital Solutions
	*/
	public class Slider extends MovieClip {
		
		public static var ON_CHANGE = "on_change";
		
		private var _w:Number;
		private var _maxV:Number = 100;
		private var _minV:Number = 0;
		private var _value:Number;
		
		private var _dragging:Boolean = false;
		
		private var _changeRate:Number = 0.01;
		
		private var _onChanged:Function = null;
		private var _onDragStart:Function = null;
		private var _onDragEnd:Function = null
		private var _onPointClick:Function = null;

		public function Slider() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_w = bar.width;
			init();
		}
		
		public function set w(a:Number) :void {
			_w = a;
			bar.width = _w;
		}
		public function set onChanged(a:Function) :void { _onChanged = a; }		public function set onDragStart(a:Function) :void { _onDragStart = a; }		public function set onDragEnd(a:Function) :void { _onDragEnd = a; }
		public function set onPointClick(a:Function) :void { _onPointClick = a; }
		
		public function get maxV() :Number { return _maxV; }
		public function set maxV(a:Number) :void { _maxV = a; calculate(); }
		public function get minV() :Number { return _minV; }
		public function set minV(a:Number) :void { _minV = a; calculate(); }
		public function set value(a:Number) :void {
			_value = a;
			if (_value > _maxV) _value = _maxV;
			if (_value < _minV) _value = _minV;
			marker.x = ( (_value - _minV) / (_maxV - _minV) ) * _w;
			//calculate();
			if (_onChanged != null) { _onChanged(); }
		}
		public function get value() :Number { 
			return _value;
		}

		private function init() :void {
			btn.addEventListener(MouseEvent.CLICK, btnHandler);
			marker.btn.addEventListener(MouseEvent.MOUSE_DOWN, markerPressHandler);
			marker.x = 0;
			calculate();
		}
		
		private function btnHandler(e:MouseEvent) :void {
			marker.x = this.mouseX;
			calculate_point_click();
		}
		
		private function markerPressHandler(e:MouseEvent) :void {
			_dragging = true; 
			if (_onDragStart !=null) { _onDragStart(); }
			
			marker.startDrag(false, new Rectangle(0, 0, _w, 0));
			addEventListener(Event.ENTER_FRAME, run);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, markerReleaseHandler);
		}
		
		private function markerReleaseHandler(e:MouseEvent) :void {
			_dragging = false;
			if (_onDragEnd !=null) { _onDragEnd(); }
			
			marker.stopDrag();
			
			calculate();
			stage.removeEventListener(MouseEvent.MOUSE_UP, markerReleaseHandler);
			removeEventListener(Event.ENTER_FRAME, run);
		}
		
		private function calculate() {
			_value = (_maxV - _minV) * ( marker.x / _w ) + _minV;
			if (_onChanged != null) { _onChanged(); }		
		}
		
		private function calculate_point_click() {
			_value = (_maxV - _minV) * ( marker.x / _w ) + _minV;
			if (_onPointClick != null) { _onPointClick(); }		
		}
		
		private function run(e:Event) :void {
			if (_dragging) {
				calculate();
			}
		}
		
	}
}