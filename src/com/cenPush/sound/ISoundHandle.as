package com.cenPush.sound
{
    import flash.media.SoundTransform;

    /**
	 * 一个sound的引用、包装。使用ISoundManager.play()创建。你可以 pause/resume/stop
	 * 这些声音，也可以调整它们的 volume 和pan.
     */
    public interface ISoundHandle
    {
        /**
		 * 暂停声音;可以使用resume()继续播放。
         */
        function pause():void;
        /**
		 * 继续播放被暂停的声音。
         */
        function resume():void;
        
        /**
		 * 无法还原的停止播放.这个声音将会被SoundManager移除，并且相关的资源也会被释放。
         * and related resources are released.
         */
        function stop():void;

        /**
		 * sound 的 SoundTransform 的获取。
         */
        function set transform(value:SoundTransform):void;
        function get transform():SoundTransform;

        /**
		 * 调整 sound 的音量。
         */
        function set volume(value:Number):void;
        function get volume():Number;
        
        /**
		 * 调整 pan(-1 左， 1 右)。
         */
        function set pan(value:Number):void;
        function get pan():Number;
        
        /**
		 * 这个 sound 在SoundManager 中的所属分类。
         */
        function get category():String;
        
        /**
		 * 是否正在播放。
         */
        function get isPlaying():Boolean;
		
		/**
		 * @Cenfee。
		 */
		function get onComplete():Function;
		function set onComplete(value:Function):void;
    }
}