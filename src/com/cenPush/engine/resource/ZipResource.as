package com.cenPush.engine.resource
{
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipFile;
	import deng.fzip.FZipLibrary;
	
	import flash.events.Event;
	import flash.utils.ByteArray;

	[EditorData(extensions="zip")]
	
	public class ZipResource extends Resource
	{
		private var _fZip:FZip;
		private var _fZipLibrary:FZipLibrary;
		
		public function ZipResource()
		{
		}
		
		override public function initialize(data:*):void
		{
			if(data is ByteArray)
			{
				_fZip = new FZip();
				_fZip.loadBytes(data);
				_fZipLibrary = new FZipLibrary();
				_fZipLibrary.formatAsBitmapData(".gif");
				_fZipLibrary.formatAsBitmapData(".jpg");
				_fZipLibrary.formatAsBitmapData(".png");
				_fZipLibrary.formatAsDisplayObject(".swf");
				_fZipLibrary.addZip(_fZip);
				_fZipLibrary.addEventListener(Event.COMPLETE, onComplete);
			}
		}
		
		private function onComplete(event:Event):void
		{
			_fZipLibrary.removeEventListener(Event.COMPLETE, onComplete);
			onLoadComplete();
		}
		
		override protected function onContentReady(content:*):Boolean
		{
			if(_fZip.getFileCount() > 0)
				return true;
			else 
				return false;
		}
		
		/**
		 * 获取 fZip 档案。
		 */
		public function get fZip():FZip
		{
			return _fZip;
		}
		
		/**
		 * 获取格式化 fZip 的 FZipLibrary, 可以直接从中提取bitmap/swf/...
		 */
		public function get fZipLibrary():FZipLibrary
		{
			return _fZipLibrary;
		}
		
		
	}
}