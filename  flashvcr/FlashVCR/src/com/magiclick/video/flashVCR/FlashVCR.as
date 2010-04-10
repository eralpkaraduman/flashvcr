package com.magiclick.video.flashVCR {
	import flash.display.MovieClip;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;

	/**
	 * @author eralp
	 */
	public class FlashVCR extends MovieClip {
		// Params
		private var _BUFFER_TIME:Number = 8;
		private var _DEFAULT_VOLUME:Number = 0.6;
		private var _DISPLAY_TIMER_UPDATE_DELAY:int = 10;
		private var _SMOOTHING:Boolean = true;
		private var display_update_timer:Timer;
		public var keepAspectRatio:Boolean = true;
		
		// Flags (do not modify these) 
		private var f_loaded:Boolean = false;
		private var f_volumeScrub:Boolean = false;
		private var f_progressScrub:Boolean = false;
		private var f_initilized:Boolean = false;
		private var f_streamAttached : Boolean = false;
		
		private var _lastVolume:Number = _DEFAULT_VOLUME;
		
		private var _connection:NetConnection;
		private var _stream:NetStream;
		
		private var _metaDataObject:Object;
		private var _displayTimer:Timer;
		private var _camera:Camera;
		private var _videoAspectRatio:Number;
		
		private var init_videoPlayBack_width:Number;
		private var init_videoPlayBack_height:Number;
		private var init_videoPlayback_position:Point;
		
		private var _videoPlayback:Video;
		private var _videoBoundariesRectangle:Rectangle;
		private var _init_videoAspectRatio:Number;
		private var current_time_pos_percent:Number = 0;
		private var current_time_pos:Number = 0;
		private var video_time_duration:Number = 0;
		private var verboseMode:Boolean;

		public function FlashVCR(videoInstance:String,keepAspectRatio:Boolean=true,verboseMode:Boolean=false) {
			_videoPlayback = this[videoInstance] as Video;
			
			this.verboseMode = verboseMode;
			this.keepAspectRatio = keepAspectRatio;
			
			display_update_timer = new Timer(_DISPLAY_TIMER_UPDATE_DELAY);
			display_update_timer.addEventListener(TimerEvent.TIMER, updateDisplay);
			
			init_videoPlayBack_width = _videoPlayback.width;
			init_videoPlayBack_height = _videoPlayback.height;
			init_videoPlayback_position = new Point(_videoPlayback.x, _videoPlayback.y);
		}

		private function updateDisplay(event:TimerEvent):void {
			//current_time_pos_percent=_stream.time/video_time_duration;
			
			current_position = _stream.time;
			onDisplayUpdate(current_time_pos_percent);
			onStreamDownloadProgress(_stream.bytesLoaded/_stream.bytesTotal);
		}
		
		public function get current_position():Number{
			return current_time_pos;
		}
		
		public function set current_position(time:Number):void {
			current_time_pos=time;
			current_time_pos_percent = current_time_pos/video_time_duration;
		}
		
		public function get current_position_percent():Number{
			return current_time_pos_percent;
		}
		
		public function set current_position_percent(perc:Number):void {
			trace('current_position_percent: '+perc);
			current_time_pos_percent=perc;
			current_time_pos = current_time_pos_percent*video_time_duration;
		}

		/**
		 * @param from starts streaming from a spesific time
		 */
		public function streamVideo(pathToVideo:String,paused:Boolean=false,from:Number=0):void{
			
			if(!f_initilized)init();
			if(!f_streamAttached)_videoPlayback.attachNetStream(_stream);
			
			_videoPlayback.smoothing=_SMOOTHING;
			
			if(!f_loaded) {
				_stream.play(pathToVideo);
				f_loaded = true;
				
				if(from!=0)current_position = from;
				trace('seeking to current_position: ' + (current_time_pos));
			} else {
				_stream.resume();
				onPlayResume();
			}
		}

		public function pauseVideoStream():void{
			_stream.pause();
			onPaused();
		}
		
		public function set videoBoundariesRectangle(rect:Rectangle):void{			
			_videoBoundariesRectangle = rect;
		}
		
		private function init():void {
			_camera = new Camera();
			
			//_connection["onMetaData"] = function():void{trace("meta");};
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_connection.connect(null);
			
			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			//client to deal with metadata	
			var customclient:Object= new Object();
			customclient.onMetaData=metadata;
			_stream.client=customclient;
			
			_stream.bufferTime=_BUFFER_TIME; //TODO: bunu dinamik hesaplayabilirim
			
			//_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			volume=_DEFAULT_VOLUME;
			
			f_initilized = true;
		}
		
		public function metadata(infoObject:Object){
			if(verboseMode)trace("meta");
			
			var vid_width = infoObject.width;
			var vid_height = infoObject.height;
			video_time_duration=infoObject.duration;
			
			if(keepAspectRatio)fitToAspectRatio(vid_height,vid_width);
			
			current_position = current_position_percent*streamLength;
			seekTo(current_position);
		}
		
		protected function fitToAspectRatio(vid_height:Number,vid_width:Number):void{
//			var vid_width = infoObject.width;
//			var vid_height = infoObject.height;
			
			_videoAspectRatio = vid_height / vid_width;
			_init_videoAspectRatio=init_videoPlayBack_height / init_videoPlayBack_width;
			
			if(_videoAspectRatio > _init_videoAspectRatio) {
				
				_videoPlayback.width = init_videoPlayBack_height * (1/_videoAspectRatio);
				_videoPlayback.height= init_videoPlayBack_height;
				
				_videoPlayback.y = init_videoPlayback_position.y;
				_videoPlayback.x = init_videoPlayback_position.x + init_videoPlayBack_width/2 - _videoPlayback.width/2;
				
			} else{
				_videoPlayback.width = init_videoPlayBack_width;
				_videoPlayback.height= init_videoPlayBack_width * _videoAspectRatio ;
				
				_videoPlayback.x = init_videoPlayback_position.x;
				_videoPlayback.y = init_videoPlayback_position.y + init_videoPlayBack_height/2 - _videoPlayback.height/2;
			}
			
		}
		
		// volume SET - GET
		
		/**
		 * Use this to change volume
		 * @param value : pass a number between 0 and 1
		 */
		public function set volume(value:Number):void{
			if(!_stream || value<0 || value > 1)return;
			_stream.soundTransform = new SoundTransform(value);	
		}
		/**
		 * @return current colume 0-1. or -1 if there is no stream created.
		 */
		public function get volume():Number{
			if(!_stream)return -1;
			return _stream.soundTransform.volume;
		}

		private function netStatusHandler(event:NetStatusEvent):void {
			var c:String = String(event.info.code);
			
			if(verboseMode)trace(c);
			
			if(c == "NetStream.Play.Start"){
				onPlayStart();
			}
			if(c == "NetStream.Play.Stop"){
				onStreamStop();
			}
		}


		public function seekTo(time:Number) {
			if(!_stream)return;
			_stream.seek(time);
		}
		
		public function get streamLength():Number{
			return video_time_duration;
		}
		
		public function get streamReady():Boolean{
			return Boolean(_stream);
		}

		/////////////////////////////
		/// overridable functions ///
		/////////////////////////////
		
		protected function onPlayResume():void {
			updateDisplay(null);
			display_update_timer.start();
		}

		protected function onPlayStart():void{
			updateDisplay(null);
			display_update_timer.start();
		}
		protected function onPaused():void{
			display_update_timer.stop();
		}
		
		protected function onDisplayUpdate(percentTime:Number):void{}
		
		protected function onStreamStop():void {
			
			_stream.close();
			f_initilized = true;
			f_streamAttached = true;
			f_loaded = false;
		}
		
		protected function onStreamDownloadProgress(percentageLoaded:Number):void{
		}
		
	}
}
