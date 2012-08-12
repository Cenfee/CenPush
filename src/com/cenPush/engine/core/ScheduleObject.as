package com.cenPush.engine.core
{
    /**
	 * 被ProcessManager包内使用的帮助类，这是由schedule()调用来实现 预期调用函数。
     */
    internal final class ScheduleObject implements IPrioritizable
    {
        public var dueTime:Number = 0.0;
        public var thisObject:Object = null;
        public var callback:Function = null;
        public var arguments:Array = null;
        
        public function get priority():int
        {
            return -dueTime;
        }
        
        public function set priority(value:int):void
        {
            throw new Error("没有实现.");
        }
    }
}