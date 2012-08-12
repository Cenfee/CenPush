package com.cenPush.util.frameAnimation
{
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.events.EventDispatcher;

	public class Tween extends EventDispatcher implements IAnimatable
	{
		private var _targets:Vector.<Object>;
		private var _transition:String;
		private var _startValues:Vector.<TweenValue>;
		private var _endValues:Vector.<TweenValue>;
		
		private var _onStart:Function;
		private var _onUpdate:Function;
		private var _onComplete:Function;
		
		private var _onStartArgs:Array;
		private var _onUpdateArgs:Array;
		private var _onCompleteArgs:Array;
		
		private var _totalTime:Number;
		private var _currentTime:Number;
		private var _delay:Number;
		private var _roundToInt:Boolean;
		
		public function Tween(targets:Vector.<Object>, startValues:Vector.<TweenValue>, endValues:Vector.<TweenValue>, time:Number, transition:String = "linear")
		{
			create(targets, startValues, endValues, time, transition);
		}
		
		private function create(targets:Vector.<Object>, startValues:Vector.<TweenValue>, endValues:Vector.<TweenValue>, time:Number, transition:String = "linear"):void
		{
			_targets = targets;
			_startValues = startValues;
			_endValues = endValues;
			
			_currentTime = 0;
			_totalTime = Math.max(0.0001, time);
			_delay = 0;
			_transition = transition;
			_roundToInt = false;
			
			_onStart = _onUpdate = _onComplete = null;
			_onStartArgs = _onUpdateArgs = _onCompleteArgs = null;
		}
		
		private function assignPropertyToTarget(target:Object, property:String, startValue:Number, endValue:Number, ratio:Number):void
		{
			var delta:Number = endValue - startValue;
			
			var transitionFunc:Function = Transitions.getTransition(_transition);
			var currentValue:Number = startValue + transitionFunc(ratio) * delta;
			if(_roundToInt) currentValue = Math.round(currentValue);
			target[property] = currentValue;
		}
		
		public function resetProperties():void
		{
			_currentTime = 0;
		}
		
		public function advanceTime(time:Number):void
		{
			if(time == 0) return;
			
			var previousTime:Number = _currentTime;
			_currentTime += time;
			
			if(_currentTime < 0 || previousTime >= _totalTime)
				return;
			
			if(_onStart != null && previousTime <= 0 && _currentTime >= 0)
				_onStart.apply(null, _onStartArgs);
			
			var ratio:Number = Math.min(_totalTime, _currentTime) / _totalTime;
			var numTargets:int = _targets.length;
			
			for(var i:int = 0; i < numTargets; i++)
			{
				var target:Object = _targets[i];
				
				var startValue:TweenValue = _startValues[i];
				var endValue:TweenValue = _endValues[i];
				assignPropertyToTarget(target, "x", _startValues[i].x, _endValues[i].x, ratio);
				assignPropertyToTarget(target, "y", _startValues[i].y, _endValues[i].y, ratio);
				/*assignPropertyToTarget(target, "rotation", _startValues[i].rotation, _endValues[i].rotation, ratio);
				assignPropertyToTarget(target, "scaleX", _startValues[i].scaleX, _endValues[i].scaleX, ratio);
				assignPropertyToTarget(target, "scaleY", _startValues[i].scaleY, _endValues[i].scaleY, ratio);
				assignPropertyToTarget(target, "skewX", _startValues[i].skewX, _endValues[i].skewX, ratio);
				assignPropertyToTarget(target, "skewY", _startValues[i].skewY, _endValues[i].skewY, ratio);
				assignPropertyToTarget(target, "color", _startValues[i].color, _endValues[i].color, ratio);
				assignPropertyToTarget(target, "alpha", _startValues[i].alpha, _endValues[i].alpha, ratio);*/
			}
			
			if(_onUpdate != null)
				_onUpdate.apply(null, _onUpdateArgs);
			
			if(previousTime < _totalTime && _currentTime >= _totalTime)
			{
				if (_onComplete != null) _onComplete.apply(null, _onCompleteArgs);
			}
		}

		public function get isComplete():Boolean
		{
			return _currentTime >= _totalTime;
		}
		public function get transition():String
		{
			return _transition;
		}
		public function get totalTime():Number
		{
			return _totalTime;
		}
		public function get currentTime():Number
		{
			return _currentTime;
		}
		public function get delay():Number
		{
			return _delay;
		}
		public function set delay(value:Number):void
		{
			_currentTime = _currentTime + _delay - value;
			_delay = value;
		}
		
		public function get roundToInt():Boolean
		{
			return _roundToInt;
		}
		public function set roundToInt(value:Boolean):void
		{
			_roundToInt = value;
		}
		
		public function get onStart():Function
		{
			return _onStart;
		}
		public function set onStart(value:Function):void
		{
			_onStart = value;
		}
		
		public function get onUpdate():Function
		{
			return _onUpdate;
		}
		public function set onUpdate(value:Function):void
		{
			_onUpdate = value;
		}
		
		public function get onComplete():Function
		{
			return _onComplete;
		}
		public function set onComplete(value:Function):void
		{
			_onComplete = value;
		}
		
		public function get onStartArgs():Array
		{
			return _onStartArgs;
		}
		public function set onStartArgs(value:Array):void
		{
			_onStartArgs = value;
		}
		
		public function get onUpdateArgs():Array
		{
			return _onUpdateArgs;
		}
		public function set onUpdateArgs(value:Array):void
		{
			_onUpdateArgs = value;
		}
		
		public function get onCompleteArgs():Array
		{
			return _onCompleteArgs;
		}
		public function set onCompleteArgs(value:Array):void
		{
			_onCompleteArgs = value;
		}
	}
}