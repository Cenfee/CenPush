package com.cenPush.sound
{
	import com.cenPush.engine.debug.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

    /**
	 * 跟踪一个活跃的声音。你应该仅仅使用 ISoundHandle, 不是直接使用它。
     * 
     * @see ISoundHandle 可以查看 ISoundHandle 的文档。
     * @inheritDocs
     */
    internal class SoundHandle implements ISoundHandle
    {
        public function SoundHandle(_manager:SoundManager, _sound:Sound, __category:String, _pan:Number, _loopCount:int, _startDelay:Number, onComplete:Function)
        {
            manager = _manager;
            sound = _sound;
            _category = __category;
            pan = _pan;
            loopCount = _loopCount;
            pausedPosition = _startDelay;
            
			_onComplete = onComplete;
            resume();
        }
        
        public function get transform():SoundTransform
        {
            if(!channel)
                return new SoundTransform();
            return channel.soundTransform;
        }

        public function set transform(value:SoundTransform):void
        {
            dirty = true;
            if(channel)
                channel.soundTransform = value;
        }

        public function get volume():Number
        {
            return _volume;
        }

        public function set volume(value:Number):void
        {
            dirty = true;
            _volume = value;
        }
        
        public function get pan():Number
        {
            return _pan;
        }
        
        public function set pan(value:Number):void
        {
            dirty = true;
            _pan = value;
        }
        
        public function get category():String
        {
            return _category;
        }

        public function pause():void
        {
            pausedPosition = channel.position;
            channel.stop();
            playing = false;
        }
        
        public function resume():void
        {
           // Profiler.enter("SoundHandle.resume");
            
            dirty = true;

			// 注意：如果pausedPosition为0， 循环次数可能有误。
            try
            {
                channel = sound.play(pausedPosition, loopCount);
                playing = true;                

                channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
            }
            catch(e:Error)
            {
                Logger.error(this, "resume", "Error starting sound playback: " + e.toString());
            }
            

           // Profiler.exit("SoundHandle.resume");
        }
        
        /**
         * 实现循环，在每次声音末尾需要监听进行处理。
         */
        private function onSoundComplete(e:Event):void
        {
			e.target.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			// 进入下次循环，循环次数减1.
            loopCount -= 1;
			
            if(loopCount > 0)
            {
                pausedPosition = 0;
                resume();
            }
            else if(manager.isInPlayingSounds(this))
            {
                // 从管理器中移除。
                manager.removeSoundHandle(this);
				
				//Cenfee
				if(_onComplete != null)
					_onComplete.call();
				_onComplete = null;
				playing = false;
            }
			
			
        }
        
        public function stop():void
        {
            pause();
            
            if(manager.isInPlayingSounds(this))
            {
				// 从管理器中移除
                manager.removeSoundHandle(this);
            }
			
			
			_onComplete = null;
			playing = false;
        }
        
        public function get isPlaying():Boolean
        {
            return playing;
        }
		
		//Cenfee
		public function get onComplete():Function
		{
			return _onComplete;
		}
		public function set onComplete(value:Function):void
		{
			_onComplete = value;
		}
        
        internal var manager:SoundManager;
        internal var dirty:Boolean = true;
        internal var _category:String;
        internal var playing:Boolean;
        
        internal var sound:Sound;
        internal var channel:SoundChannel;

        protected var pausedPosition:Number = 0;
        protected var loopCount:int = 0;
        protected var _volume:Number = 1;
        protected var _pan:Number = 0;
		
		//Cenfee
		protected var _onComplete:Function;
        
    }
}