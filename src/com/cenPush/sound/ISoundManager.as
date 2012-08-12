package com.cenPush.sound
{
    import flash.media.SoundTransform;

    /**
     * SoundManager 的接口
     */
    public interface ISoundManager
    {
        /**
		 * 播放一个嵌入的声音，返回一个ISoundHandle 接口实例，可以在声音播放时控制
		 * 声音，并保存声音的实例。
         * 
		 * @param sound			一个声音资源， Sound实例。
		 * @param loopCount		重复多少次声音? 0 表示播放1次， 1表示重复1次。
		 * @param startDelay	延迟播放时间。
         */
        function play(sound:*, category:String = "sfx", pan:Number = 0.0, loopCount:int = 1, startDelay:Number = 0.0, onComplete:Function=null, resourceType:Class=null):SoundHandle;

        /**
		 * 以URL流式播放一个MP3文件 或者其他兼容的格式。这个对于背景音乐很有用。
		 * 在加载完成前，可以进行播放。
         * 
         * @see play()
         */
        function stream(url:String, category:String = "sfx", pan:Number = 0.0, loopCount:int = 1, startDelay:Number = 0.0, onComplete:Function=null):SoundHandle;
        
        /**
		 * 当为 true 时，所有的声音为静音。
         */
        function set muted(value:Boolean):void;
        function get muted():Boolean;

        /**
		 * SoundManager  音量控制
         */
        function set volume(value:Number):void;
        function get volume():Number;
        
        /**
		 * 所有的声音分类都明确地存在Manager中。在category播放声音或设置属性，确保
		 * 已经调用这个函数创建。
		 * 
         * @param category  category的名字。
         */
        function createCategory(category:String):void;
        
        /**
		 * 如果你想移除一个已经存在的category 则使用removeCategory
		 * 
         * @param category category的名字。
         */
        function removeCategory(category:String):void;
        
        /**
		 * 设置一个category静音属性.
		 * 
         * @param category category名。
         * @param 如果为true, 则属于这个分类的声音都设为静音。
         */
        function setCategoryMuted(category:String, muted:Boolean):void;
        function getCategoryMuted(category:String):Boolean;
        
        /**
		 * 调整一个分类声音的音量。
		 * 
         * @param category category名。
         * @param volume   音量值.
         */
        function setCategoryVolume(category:String, volume:Number):void;
        function getCategoryVolume(category:String):Number;
        
        /**
		 * 调整一个分类声音的SoundTransform.
		 * 
         * @param category category名
         * @param transform 新的SoundTransform的实例。
         */
        function setCategoryTransform(category:String, transform:SoundTransform):void;
        function getCategoryTransform(category:String):SoundTransform; 
        
        /**
		 * 停止所有指定分类的声音。
         */
        function stopCategorySounds(category:String):void

        /**
		 * 停止所有的声音。
         */
        function stopAll():void

        /**
         * Fetch all the SoundHandles in the specified category and store them 
         * in the provided array.
		 * 
		 * 获取指定分类的所有SoundHandles，并把他们存储在提供的数组中。
         */
        function getSoundHandlesInCategory(category:String, outArray:Array):void        
    }
}