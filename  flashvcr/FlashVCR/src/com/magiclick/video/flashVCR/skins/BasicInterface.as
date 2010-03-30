package com.magiclick.video.flashVCR.skins {
	import com.gs.OverwriteManager;
	import com.magiclick.utils.ui.Slider;
	import com.magiclick.video.flashVCR.FlashVCR;

	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	/**
	 * @author godstroke
	 */
	public class BasicInterface extends FlashVCR {
		private var _ui_play:SimpleButton;		private var _ui_pause:SimpleButton;
		
		private var _video_progress_bar:Slider;
		private var _volume_slider:Slider;
		
		private var _scrubbing:Boolean = false;
		
		public var stream_path:String;

		public function BasicInterface() {
			super("videoPlayback",true,true);

			_ui_play=this["ui_play"];			_ui_pause=this["ui_pause"];
			
			_ui_pause.visible=false;
			_ui_play.visible=true;
			
			_ui_play.addEventListener(MouseEvent.CLICK, onPlayClicked);			_ui_pause.addEventListener(MouseEvent.CLICK, onPauseClicked);
			
			_video_progress_bar=this["video_progress_bar"] as Slider;
			_volume_slider = this["volume_slider"] as Slider;
			
			_video_progress_bar["progress_bar"].mouseEnabled = false;
			_video_progress_bar.onChanged=onProgressBarChanged;
						_video_progress_bar.onDragStart = startScrubbing;
			_video_progress_bar.onDragEnd = stopScrubbing;
			_video_progress_bar.onPointClick = on_point_click_seek;
			
			_video_progress_bar.maxV = 1;			_video_progress_bar.minV = 0;
			_video_progress_bar.value = 0;
			
			_volume_slider.maxV = 1;
			_volume_slider.minV = 0;
			_volume_slider.value = 1;
			_volume_slider.onChanged=onVolumeSlideChanged;
			_volume_slider["progress_bar"].visible = false;
			
			_video_progress_bar["buffer_bar"].visible = streamReady;
			_video_progress_bar["progress_bar"].visible = streamReady;
		}

		private function onVolumeSlideChanged():void {
			volume = _volume_slider.value;
			//trace('onVolumeSlideChanged: ' + (onVolumeSlideChanged));
		}

		private function stopScrubbing():void {
			
			_scrubbing = false;
			trace('_scrubbing: ' + (_scrubbing));
		}
		
		private function on_point_click_seek():void{
			//_video_progress_bar.value
			if(streamReady){
				seekTo(streamLength*_video_progress_bar.value);
				onProgressBarChanged();
			}else{
				current_position_percent = _video_progress_bar.value;
			}
		}

		private function startScrubbing():void {
			_scrubbing =true;
			trace('_scrubbing: ' + (_scrubbing));
		}

		private function onProgressBarChanged():void {
			_video_progress_bar["progress_bar"].visible = streamReady;
			
			if(streamReady){
				draw_time_bar();
			}
		}
		private function draw_time_bar():void{
			_video_progress_bar["progress_bar"].width = _video_progress_bar["marker"].x - _video_progress_bar["progress_bar"].x*2;
		}

		private function onPauseClicked(event:MouseEvent):void {
			pauseVideoStream();
		}

		private function onPlayClicked(event:MouseEvent):void {
			if(stream_path)streamVideo(stream_path);
		}

		// events
		override protected function onPlayStart():void {
			super.onPlayStart();
			_ui_pause.visible = _ui_pause.mouseEnabled = true;
			_ui_play.visible  = _ui_play.mouseEnabled  = false;
		}
		
		override protected function onPaused():void {
			super.onPaused();
			_ui_pause.visible = _ui_pause.mouseEnabled = false;
			_ui_play.visible  = _ui_play.mouseEnabled  = true;
		}
		
		override protected function onPlayResume():void {
			super.onPlayResume();
			_ui_pause.visible = _ui_pause.mouseEnabled = true;
			_ui_play.visible  = _ui_play.mouseEnabled  = false;
		}
		
		override protected function onDisplayUpdate(percentTime:Number):void{
			super.onDisplayUpdate(percentTime);
			
			// progress bar
			if(!_scrubbing){
				if(streamReady){
					_video_progress_bar.value = percentTime;
				}
			}else{				if(streamReady){
					seekTo(streamLength*_video_progress_bar.value);
				}
			}
			
		}
		
		override protected function onStreamDownloadProgress(prc_downloaded:Number):void{
			// buffer bar
			_video_progress_bar["buffer_bar"].width = prc_downloaded*412;
			_video_progress_bar["buffer_bar"].visible= (prc_downloaded > 0);
		}

		override protected function onStreamStop():void{
			super.onStreamStop();
			
			pauseVideoStream();
			seekTo(0);
			
			_video_progress_bar.value = 0;
			onDisplayUpdate(0);
			onProgressBarChanged();
			
			_video_progress_bar["progress_bar"].width = 0;
		}
		
	}
}
