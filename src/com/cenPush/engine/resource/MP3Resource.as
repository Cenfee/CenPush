package com.cenPush.engine.resource
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.media.Sound;
    import flash.net.URLRequest;
    import com.cenPush.engine.resource.SoundResource;
    
    [EditorData(extensions="mp3")]
    
    /**
	 * 使用 FlashPlayer 内置的 MP3支持，加载MP3文件。
     */
    public class MP3Resource extends SoundResource
    {
        /**
		 * 被加载的声音Sound。
         */
        protected var _soundObject:Sound = null;
        
        override public function get soundObject() : Sound
        {
            return _soundObject;
        }
        
        override public function initialize(d:*):void
        {
            _soundObject = d;
            onLoadComplete();
        }
        
        /**
         * @inheritDoc
         */
        override protected function onContentReady(content:*):Boolean 
        {
            return soundObject != null;
        }
    }
}