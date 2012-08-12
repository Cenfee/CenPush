package com.cenPush.util.frameAnimation
{
	public class DataCharacter
	{
		protected var _name:String;
		
		protected var _animations:Vector.<DataAnimation>;
		protected var _frames:Vector.<DataFrame>;
		
		protected var _curAnimation:DataAnimation;
		
		public var onChangeFrame:Function;
		
		public function DataCharacter(data:XML, onChangeFrame:Function = null, onAnimationComplete:Function = null)
		{
			_name = data.name;//1
			
			_animations = new Vector.<DataAnimation>;
			
			for each(var anim:XML in data.char.anim)
			{
				_animations.push(new DataAnimation(anim, onAnimChangeFrame, onAnimationComplete));
			}
			
			_frames = new Vector.<DataFrame>();
			
			for each(var frame:XML in data.frame)
			{
				_frames.push(new DataFrame(frame));
			}
			
			_animations.fixed = true;
			_frames.fixed = true;
			
			this.onChangeFrame = onChangeFrame;
		}
		
		protected function onAnimChangeFrame():void
		{
			onChangeFrame.call();
		}
		
		protected function getFrame(name:String):DataFrame
		{
			for each(var frame:DataFrame in _frames)
			{
				if(frame.name == name)
					return frame;
			}
			
			return null;
		}
		
		protected function getAnimation(name:String):DataAnimation
		{
			for each(var anim:DataAnimation in _animations)
			{
				if (anim.name == name) return anim;
			}
			
			return null;
		}
		
		public function play(name:String, reset:Boolean = false, frame:int = 0):void
		{
			if(_curAnimation && _curAnimation.name == name)
			{
				if(reset)
					_curAnimation.reset(frame);
				return;
			}
			
			_curAnimation = getAnimation(name);
			_curAnimation.reset(frame);
			
			onChangeFrame.call();
		}
		
		public function resetFrame(frame:int = 0):void
		{
			_curAnimation.reset(frame);
			
			onChangeFrame.call();
		}
		
		public function update(elapsed:Number):void
		{
			if(_curAnimation) _curAnimation.update(elapsed);
		}
		
		public function get animation():DataAnimation
		{
			return _curAnimation;
		}
		
		public function get frame():DataFrame
		{
			if(_curAnimation)
			{
				return getFrame(_curAnimation.frame.name);
			}
			
			return null;
		}
		
		public function get nextFrame():DataFrame
		{
			if(_curAnimation)
			{
				if(_curAnimation.nextFrame)
					return getFrame(_curAnimation.nextFrame.name);
			}
			
			return null;
		}
		
	}
}