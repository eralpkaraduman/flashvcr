package com.magiclick.video.flashVCR.skins
{
	import com.magiclick.video.flashVCR.FlashVCR;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.AsyncErrorEvent;
	import com.magiclick.utils.ui.Slider;
	
	/**
	$(CBI)* ...
	$(CBI)* @author Eralp Karaduman
	$(CBI)*/
	public class BATskin extends FlashVCR
	{
		private var $hidden:Boolean;
		private var $btn_close:MovieClip;
		private var $btn_stop:MovieClip;
		private var $video:Video;
		private var connection:NetConnection;
		private var stream:NetStream;
		private var videoURL:String = "02_doyouloveme.flv";
		private var $video_paused_view:MovieClip;
		private var $video_loading:MovieClip;
		private var playing:Boolean = false;
		private var paused:Boolean = false;
		private var stream_path:String;
		
		private var _video_progress_bar:Slider;
		private var _volume_slider:Slider;
		
		private var _scrubbing:Boolean = false;
		private var _volume_toggle:MovieClip;
		private var _last_volume_memory:Number = 1;
		
		public function BATskin(){
			
			super("video",true,false);
			stream_path = String(videoURL);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(e:Event):void {removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);init();}
		
		private function init():void {
			
			$btn_stop = this["btn_stop"] as MovieClip;
			$btn_stop.addEventListener(MouseEvent.CLICK, onStopClicked);
			$btn_stop.buttonMode = true;
			
			_volume_toggle = this["volume_toggle"] as MovieClip;
			//trace("_volume_toggle" +_volume_toggle );
			
			_volume_toggle.buttonMode = true;
			
			_volume_toggle.addEventListener(MouseEvent.CLICK, onVolumeToggleClick);
			
			
			//hide(); // don't remove this, instead change from outside after constructor
			
			this._play.visible = true;
			this._pause.visible = false;
			
			_video_progress_bar=this["video_progress_bar"] as Slider;
			_volume_slider = this["volume_slider"] as Slider;
			
			_play.addEventListener(MouseEvent.CLICK,onPlayClicked);
			_pause.addEventListener(MouseEvent.CLICK, onPauseClicked);
			_play.buttonMode = true;
			_pause.buttonMode = true;
			
			
			
			//videoURL = GlobalVariables.video_path;
			videoURL = "02_doyouloveme.flv";
			
			//$btn_close = this["btn_close"];
			//$btn_close.buttonMode = true;
			//$btn_close.addEventListener(MouseEvent.CLICK, onClose);
			
			$video = this["video"];
			$video_paused_view = this["video_paused_view"];
		  	$video_paused_view.clickMe.addEventListener(MouseEvent.CLICK, toggle_play_pause);
			$video_paused_view.buttonMode = true;
			$video_loading = this["video_loading"];
			$video_loading.visible = false;
			
			
			
			
			
			_video_progress_bar["progress_bar"].mouseEnabled = false;
			_video_progress_bar.onChanged=onProgressBarChanged;
			
			_video_progress_bar.onDragStart = startScrubbing;
			_video_progress_bar.onDragEnd = stopScrubbing;
			_video_progress_bar.onPointClick = on_point_click_seek;
			
			_volume_slider.onPointClick = volume_on_point_click;
			
			_video_progress_bar.maxV = 1;
			_video_progress_bar.minV = 0;
			_video_progress_bar.value = 0;
			
			_volume_slider.maxV = 1;
			_volume_slider.minV = 0;
			
			_volume_slider.value = 1;
			
			_volume_slider.onChanged=onVolumeSlideChanged;
			_volume_slider["progress_bar"].visible = false;
			
			_video_progress_bar["buffer_bar"].visible = streamReady;
			_video_progress_bar["progress_bar"].visible = streamReady;
			
			//connection = new NetConnection();
            //connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            //connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            //connection.connect(null);
			
			onVolumeSlideChanged();
			volume = 1;
		}
		
		
		
		
		
		/*
		private function netStatusHandler(event:NetStatusEvent):void {
			trace("netstatus "+event.info.code)
			
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
                    $video_loading.visible = true;
					connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + videoURL);
                    break;
				case "NetStream.Play.Stop":
					trace("video end")
					videoComplete();
					break;
				case "NetStream.Play.Start":
					$video_loading.visible = false;
					break;
            }
        }
		*/

		/*
        private function connectStream():void {
            stream = new NetStream(connection);
			//stream.bufferTime = 2000;
            stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
            $video.attachNetStream(stream);
            //stream.play(videoURL);
			play_video();
        }
		*/

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
        
        private function asyncErrorHandler(event:AsyncErrorEvent):void {
            // ignore AsyncErrorEvent events.
        }
		
		///////////////////////////////////////////
		
		public function get status():Boolean {return !$hidden;}
		
		public function hide():void {
			if ($hidden) return;
			$hidden = true;
			// stop video
			visible = false;
		}
		
		public function show():void {
			//trace("bom");
			//Page.pageTrack("video");
			
			if (!$hidden) return;
			$hidden = false;
			//closeOpenedPage();
			//trace("bom2")
			//play video
			visible = true;
			// begin video stuff
			//connection.connect(null);
		}
		
		public function onClose(e:MouseEvent=null):void {
			hide();
			//stream.close();
			pauseVideoStream();
			
			re_open_music();
			parent["closedVideoWindow"]();
		}
		
		private function play_video(e:Event=null):void {
			$video_paused_view.alpha = 0;
			//if (paused) stream.resume();
			//else stream.play(videoURL);
			if (stream_path) streamVideo(stream_path);
			
			playing = true;
			paused = false;
			
			//GlobalVariables.music_player_instance.stopMusic();
		}
		
		private function pause_video(e:Event=null):void {
			$video_paused_view.alpha = 1;
			pauseVideoStream();
			//stream.pause();
			paused = true;
			playing = false;
			
			//GlobalVariables.music_player_instance.playMusic();
		}
		
		private function onStopClicked(e:MouseEvent = null):void {
			onStreamStop();
			trace("yeyeyeye");
		}
		
		private function stop_video(e:Event=null):void {
			$video_paused_view.alpha = 1;
			stream.close();
			paused = false;
			playing = false;
			//GlobalVariables.music_player_instance.playMusic();
		}
		
		private function videoComplete():void {
			paused = false;
			stop_video();
		}
		
		private function re_open_music():void {
			// if user did not close music by hand, open it again
			//trace("GlobalVariables.music_player_instance.userStopedMusic " + GlobalVariables.music_player_instance.userStopedMusic);
			
			/*
			if (!GlobalVariables.music_player_instance.userStopedMusic) {
				GlobalVariables.music_player_instance.playMusic();
			}
			*/
		}
		
		private function toggle_play_pause(e:Event):void {
			if (playing) pause_video();
			else play_video();
		}
		
		// flash VCR
		private function onPauseClicked(event:MouseEvent):void {
			
			pause_video();
		}

		private function onPlayClicked(event:MouseEvent):void {
			
			play_video();
		}
		
		override protected function onPlayStart():void {
			super.onPlayStart();
			_pause.visible = _pause.mouseEnabled = true;
			_play.visible  = _play.mouseEnabled  = false;
			
		}
		
		override protected function onPaused():void {
			super.onPaused();
			_pause.visible = _pause.mouseEnabled = false;
			_play.visible  = _play.mouseEnabled  = true;
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
		
		private function startScrubbing():void {
			_scrubbing =true;
			//trace('_scrubbing: ' + (_scrubbing));
		}
		
		private function stopScrubbing():void {
			
			_scrubbing = false;
			//trace('_scrubbing: ' + (_scrubbing));
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
		
		private function onVolumeSlideChanged():void {
			volume = _volume_slider.value;
			
			if (volume > 0) {
				_volume_toggle.gotoAndStop(1);
			}else if(volume == 0){
				_volume_toggle.gotoAndStop(2);
			}
			
			var _vspb:MovieClip = _volume_slider["progress_bar"];
			var _vsm:MovieClip = _volume_slider["marker"];
			
			_vspb.visible = true;
			_vspb.alpha = 1;
			
			_vspb.width = _vsm.x;
			//trace('onVolumeSlideChanged: ' + (onVolumeSlideChanged));
		}
		
		private function onVolumeToggleClick(e:MouseEvent=null):void {
			
			if ( _volume_slider.value != 0) {
				_last_volume_memory = _volume_slider.value;
				_volume_slider.value = 0;
				
			}else {
				volume = _volume_slider.value;
			}
			
			
		}
		
		private function volume_on_point_click():void {
			onVolumeSlideChanged();
		}
		
		// overrides
		
		//override protected function onPlayStart():void {
			//super.onPlayStart();
			//_ui_pause.visible = _ui_pause.mouseEnabled = true;
			//_ui_play.visible  = _ui_play.mouseEnabled  = false;
		//}
		
		//override protected function onPaused():void {
			//super.onPaused();
			//_ui_pause.visible = _ui_pause.mouseEnabled = false;
			//_ui_play.visible  = _ui_play.mouseEnabled  = true;
		//}
		
		override protected function onPlayResume():void {
			super.onPlayResume();
			_pause.visible = _pause.mouseEnabled = true;
			_play.visible  = _play.mouseEnabled  = false;
		}
		
		override protected function onDisplayUpdate(percentTime:Number):void{
			super.onDisplayUpdate(percentTime);
			
			// progress bar
			if(!_scrubbing){
				if(streamReady){
					_video_progress_bar.value = percentTime;
				}
			}else{
				if(streamReady){
					seekTo(streamLength*_video_progress_bar.value);
				}
			}
		}
		
		override protected function onStreamDownloadProgress(prc_downloaded:Number):void{
			// buffer bar
			_video_progress_bar["buffer_bar"].width = prc_downloaded*160;
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