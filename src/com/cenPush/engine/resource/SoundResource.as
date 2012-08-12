package com.cenPush.engine.resource
{
    import flash.media.Sound;
    import com.cenPush.engine.resource.Resource;

    /**
	 * 提供声音对象资源的父类。
     */
    public class SoundResource extends Resource
    {
        /**
		 * @return 这个资源包含的 Sound
         */
        public function get soundObject():Sound
        {
            throw new Error("You should only use subclasses of SoundResource.");
        }
    }
}