package com.cenPush.util.frameAnimation
{
	internal class DataAnimation
	{
		internal var name:String;
		internal var frame:DataAnimationFrame;
		internal var frameIndex:int = 0;
		
		protected var _frames:Vector.<DataAnimationFrame>;
		protected var _elapsed:Number = 0;
		
		protected var _onChangeFrame:Function;
		protected var _onComplete:Function;
		
		public function DataAnimation(anim:XML, onChangeFrame:Function, onComplete:Function)
		{
			name = anim.name;
			
			_frames = new Vector.<DataAnimationFrame>;
			for each(var frame:XML in anim.frame)
			{
				_frames.push(new DataAnimationFrame(frame));
			}
			
			_frames.fixed = true;
			
			_onChangeFrame = onChangeFrame;
			_onComplete = onComplete;
		}
		
		public function update(elapsed:Number):void
		{
			_elapsed += elapsed;
			
			if(_elapsed > frame.duration)
			{
				_elapsed -= frame.duration;
				
				frameIndex++;
				if(frameIndex >= _frames.length)
				{
					_onComplete.call();
					frameIndex = 0;
				}
					
				frame = _frames[frameIndex];
				
				_onChangeFrame.call();
			}
		}
		
		public function reset(newFrame:int):void
		{
			frameIndex = newFrame;
			_elapsed = 0;
			frame = _frames[frameIndex];
		}
		
		public function get nextFrame():DataAnimationFrame
		{
			if(frameIndex < _frames.length - 1)
				return _frames[frameIndex + 1];
			
			return null;
		}
	}
}