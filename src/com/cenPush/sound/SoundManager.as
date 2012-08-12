package com.cenPush.sound
{
	import com.cenPush.engine.CPE;
	import com.cenPush.engine.core.ITickedObject;
	import com.cenPush.engine.debug.Logger;
	import com.cenPush.engine.resource.MP3Resource;
	import com.cenPush.engine.resource.SoundResource;
	
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
    
    /**
	 * 这个类实现了 ISoundManager 接口。看 ISoundManager 的详细文档。
     * 
     * @see ISoundManager 看 ISoundManager 的详细文档。
     */
    public class SoundManager implements ISoundManager, ITickedObject
    {
        public static const MUSIC_MIXER_CATEGORY:String = "music";
        public static const SFX_MIXER_CATEGORY:String = "sfx";
        
        public var maxConcurrentSounds:int = 5;

        protected var playingSounds:Array = [];
        protected var categories:Object = {};
        protected var rootCategory:SoundCategory = new SoundCategory();
        protected var cachedSounds:Object = {};
        
        public function SoundManager()
        {
            createCategory(MUSIC_MIXER_CATEGORY);
            createCategory(SFX_MIXER_CATEGORY);
        }
        
        public function play(sound:*, category:String="sfx", pan:Number=0.0, loopCount:int=0, startDelay:Number=0.0, onComplete:Function=null, resourceType:Class=null):SoundHandle
        {
           // Profiler.enter("SoundManager.play");
            
            // 限制游戏声音的数量
            if(playingSounds.length > maxConcurrentSounds)
            {
               // Profiler.exit("SoundManager.play");
                return null;
            }
            
			//推断 sound 的类型，并获取 Sound 对象。
            var actualSound:Sound = null;
            if(sound is Sound)
                actualSound = sound as Sound;
            else if(sound is SoundResource)
                actualSound = (sound as SoundResource).soundObject;
            else if(sound is String)
            {
				// 检查这个声音文件是否已经加载了，如果已经加载，则获取这个资源，并播放它。
                if(cachedSounds[sound])
                    actualSound = (cachedSounds[sound] as SoundResource).soundObject;
                else
                {
					// 确保有一个 ResourceType
                    if (!resourceType)
                        resourceType = MP3Resource;
                    
                    // 那么就加载它们，并开始播放。
                    CPE.resourceManager.load(sound, resourceType, function(r:*):void
                    {
                        cachedSounds[sound] = r;
                        play(r as SoundResource, category, pan, loopCount, startDelay, onComplete);
                    });
                    
                    //Profiler.exit("SoundManager.play");
                    return null;
                }
                
            }
            else
            {
                throw new Error("Parameter sound is of unexpected type. Should be Sound, SoundResource, or String.");
            }
            
			//建立 SoundHandle。
            var sh:SoundHandle = new SoundHandle(this, actualSound, category, pan, loopCount, startDelay, onComplete);            

			// 寻找它的种类。
            var categoryRef:SoundCategory = categories[category] as SoundCategory;
            
			// 应用已经存在的声音种类的transform
            if(categoryRef)
                sh.transform = SoundCategory.applyCategoriesToTransform(categoryRef.muted, sh.pan, sh.volume, categoryRef);            

			//把 sound 加入到声音列表。
            playingSounds.push(sh);

            //Profiler.exit("SoundManager.play");
            return sh;
        }

        public function stream(url:String, category:String = "sfx", pan:Number = 0.0, loopCount:int = 1, startDelay:Number = 0.0, onComplete:Function=null):SoundHandle
        {
			// 从URL中创建一个声音。
            try
            {
                var ur:URLRequest = new URLRequest(url);
                var s:Sound = new Sound();
                s.addEventListener(IOErrorEvent.IO_ERROR, _handleStreamFailure, false, 0, true);
                s.load(ur);
            }
            catch(e:Error)
            {
                Logger.error(this, "stream", "Failed to stream Sound due to:" + e.toString() + "\n" + e.getStackTrace());
                return null;
            }
            
			//建立一个 SoundHandle
            var sh:SoundHandle = new SoundHandle(this, s, category, pan, loopCount, startDelay, onComplete);            
            playingSounds.push(sh);
            return sh;
        }
        
        protected function _handleStreamFailure(e:IOErrorEvent):void
        {
            Logger.error(this, "_handleStreamFailure", "Error streaming sound: " + e.toString());
        }
        
        public function set muted(value:Boolean):void
        {
            rootCategory.muted = value;
            rootCategory.dirty = true;
        }
        
        public function get muted():Boolean
        {
            return rootCategory.muted;
        }
        
        public function set volume(value:Number):void
        {
            rootCategory.transform.volume = value;
            rootCategory.dirty = true;
        }
        
        public function get volume():Number
        {
            return rootCategory.transform.volume;
        }
        
        public function createCategory(category:String):void
        {
            categories[category] = new SoundCategory();
        }
        
        public function removeCategory(category:String):void
        {
			// TODO: 如果分类组中还包含声音 进行一些处理。
            categories[category] = null;
            delete categories[category];
        }
        
        public function setCategoryMuted(category:String, value:Boolean):void
        {
            categories[category].muted = value;
            categories[category].dirty = true;
        }
        
        public function getCategoryMuted(category:String):Boolean
        {
            return categories[category].muted;
        }
        
        public function setCategoryVolume(category:String, value:Number):void
        {
            categories[category].transform.volume = value;
            categories[category].dirty = true;
        }
        
        public function getCategoryVolume(category:String):Number
        {
            return categories[category].transform.volume;
        }
        
        public function setCategoryTransform(category:String, transform:SoundTransform):void
        {
            categories[category].transform = transform;
            categories[category].dirty = true;            
        }
        
        public function getCategoryTransform(category:String):SoundTransform
        {
            return categories[category].transform;
        }
        
        public function stopCategorySounds(category:String):void
        {
            for(var i:int=0; i<playingSounds.length; i++)
            {
                if((playingSounds[i] as SoundHandle).category != category)
                    continue;

                (playingSounds[i] as SoundHandle).stop();
                i--;
            }
        }

        public function stopAll():void
        {
            while(playingSounds.length)
                (playingSounds[playingSounds.length-1] as SoundHandle).stop();
        }
        
        public function getSoundHandlesInCategory(category:String, outArray:Array):void
        {
            for(var i:int=0; i<playingSounds.length; i++)
            {
                if((playingSounds[i] as SoundHandle).category != category)
                    continue;
                
                outArray.push(playingSounds[i]);
            }
        }
        
        internal function updateSounds():void
        {
            //Profiler.enter("SoundManager.updateSounds");

            // 根据声音状态更新.
            if(!rootCategory.dirty)
            {
                // 检测每个分类里的声音的状态。
                for(var categoryName:String in categories)
                {
                    // 已经是最新的，则跳过
                    if(categories[categoryName].dirty == false)
                        continue;
                    
					//标记每个声音需要更新
                    for(var j:int=0; j<playingSounds.length; j++)
                    {
                        var csh:SoundHandle = playingSounds[j] as SoundHandle;

                        if(csh.category != categoryName)
                            continue;
                        
                        csh.dirty = true;
                    }

                    // 分类不需要整体更新
                    categories[categoryName].dirty = false;
                }
            }
            else
            {
				//根分类 需要更新,分类不需要重复了.
                for(var categoryName2:String in categories)
                    categories[categoryName2].dirty = false;
            }
            
			// 更新所有需要更新的声音。
            for(var i:int=0; i<playingSounds.length; i++)
            {
                var curSoundHandle:SoundHandle = playingSounds[i] as SoundHandle;
                if(curSoundHandle.dirty == false && rootCategory.dirty == false)
                    continue;
                
				// 如果不是最新的，则更新tranform。
                if(curSoundHandle.channel)
                {
                    curSoundHandle.channel.soundTransform = 
                        SoundCategory.applyCategoriesToTransform(
                            false, curSoundHandle.pan, curSoundHandle.volume, 
                            rootCategory, categories[curSoundHandle.category]);                    
                }
                
                // 已经更新完
                curSoundHandle.dirty = false;
            }
            
            // 所有已经更新完
            rootCategory.dirty = false;
            
            //Profiler.exit("SoundManager.updateSounds");
        }
        
        public function onTick(elapsed:Number):void
        {
            updateSounds();
        }
        
        internal function isInPlayingSounds(sh:SoundHandle):Boolean
        {
            var idx:int = playingSounds.indexOf(sh);
            return idx != -1;
        }

        internal function removeSoundHandle(sh:SoundHandle):void
        {
            var idx:int = playingSounds.indexOf(sh);
            if(idx == -1)
                throw new Error("Could not find in list of playing sounds!");
            playingSounds.splice(idx, 1);
        }
    }
}