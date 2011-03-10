package com.magiclick.utils.tools {
	
	/**
	* @author Hakan Karlidag
	* @company Magiclick Digital Solutions
	*/
	
	import com.magiclick.masalkitabi.MasalKitabi;
	import flash.display.LoaderInfo;
	import flash.events.DataEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class UploadManager extends EventDispatcher {
		
		public const ON_COMPLETE:String = "OnComplete";
		public const ON_ERROR:String = "OnError";
		public const ON_SELECT:String = "OnSelect";
		
		public const UPLOAD_URL:String = "MediaUploader.aspx";
		public var SESSION_ID:String = "";
		private var f:FileReference;
		public var lastFileSelect:String;
		public var lastErrorStr:String;
		private var MAX_FILE_SIZE:Number = 4; // mb
		private var _returnData;
		
		public function UploadManager(s:String = "") {
			SESSION_ID = s;
			super();			
		}
		
		public function uploadFile() {
			var fileFilter:FileFilter = new FileFilter("Images", "*.jpg;*.gif;*.png");
			f = new FileReference();
			f.addEventListener(Event.SELECT, onFileSelect);
			f.addEventListener(IOErrorEvent.IO_ERROR, onFileError);
			f.addEventListener(ProgressEvent.PROGRESS, onProgress);
			f.addEventListener(Event.COMPLETE, onComplete);
			f.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadDataComplete, false, 0, true);
			f.browse( [fileFilter] );
		}
		
		private function onFileSelect(e:Event):void {
			
			var file:FileReference = FileReference(e.target);
			
			dispatchEvent(new Event(ON_SELECT));
			
			//Get the filesize
			var fileSize:Number = Math.round( file.size/1024 );		
			
			if ( fileSize <= MAX_FILE_SIZE * 1024 ) {
				var request:URLRequest = new URLRequest();
				//request.url = UPLOAD_URL;
				request.url = MasalKitabi.serviceManager.path;
				trace("SettingsVO.path= ",request.url);
				
				var date:Date = new Date();
				var uploadID:String = "::DJ_UPLOAD_ID::2_1" + date.getFullYear() + "" + date.getMonth() + "" + date.getDate() + "" + date.getHours() + "" + date.getMinutes() + "" + date.getSeconds() + "_" + Math.round(Math.random() * 10000);
				
				var params:URLVariables = new URLVariables();
				params.cookie = SESSION_ID;
				params.uploadid = uploadID;
				request.method = URLRequestMethod.POST;
				request.data = params;
				
				try {
					file.upload(request);
				} catch (error:Error) {
					lastErrorStr = "Dosya yüklenemiyor. (Hata kodu: 54)";
					dispatchEvent(new Event(ON_ERROR));
				}
			} else {				
				lastErrorStr = "Yüklediğiniz dosya en fazla\n" + String(MAX_FILE_SIZE) + " MB olabilir.";
				dispatchEvent(new Event(ON_ERROR));
			}
		}
		private function onFileError(e:IOErrorEvent) {
			trace("Error: " + e.toString());
			lastErrorStr = "Fotoğrafın yüklenirken bir hata oluştu. Lütfen tekrar dene.";
			dispatchEvent(new Event(ON_ERROR));
		}
		private function onProgress(e:ProgressEvent):void {
            var file:FileReference = FileReference(e.target);
            trace("onProgress: name=" + file.name + " bytesLoaded=" + e.bytesLoaded + " bytesTotal=" + e.bytesTotal);
        }
		private function onComplete(e:Event) {
			lastFileSelect = f.name;
			//dispatchEvent(new Event(ON_COMPLETE));
		}
		private function uploadDataComplete(e:DataEvent):void 
		{
			_returnData = e.data;
			dispatchEvent(new Event(ON_COMPLETE));
		}
		
		public function get returnData() { return _returnData; }
	}
}