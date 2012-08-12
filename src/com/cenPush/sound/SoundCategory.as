package com.cenPush.sound
{
    import flash.media.SoundTransform;

    /**
	 * 保存一类的声音。 看看ISoundManager更详细的描述，因为这个类只要是内部使用的。
     */
    final public class SoundCategory
    {
        public var dirty:Boolean = false;
        public var muted:Boolean = false;
        public var transform:SoundTransform = new SoundTransform();
        
        /**
		 * 聚合多个 SoundCategories 应用到 一个 SoundTransform 中。
         *  
         * @param targetTransform 结果Transform
         * @param muted 		  静音
         * @param pan 			  pan
         * @param volume 		  音量
         * @param categories      聚合的多个categories
         */
        static public function applyCategoriesToTransform(muted:Boolean, pan:Number, volume:Number, ...categories):SoundTransform
        {
			// 应用到 categories
            for(var i:int=0; i<categories.length; i++)
            {
                var c:SoundCategory = categories[i] as SoundCategory;
                
                if(!c)
                    continue;
                
                if(c.muted)
                    muted = true;
                
                volume *= c.transform.volume;
                pan += c.transform.pan;
            }
            
			// 吧聚合结果应用到目标transform中
            var targetTransform:SoundTransform = new SoundTransform();
            targetTransform.volume = muted ? 0 : volume;
            targetTransform.pan = pan;
            return targetTransform;
        }
    }
}