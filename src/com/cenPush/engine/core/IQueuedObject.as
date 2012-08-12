package com.cenPush.engine.core
{
    /**
	 * 一个将会在某个特定时间调用的对象接口。这个接口表示了所有ProcessManager存储的队列,
	 * 所以这个队列会提前分配时间。
     * 
     */
    public interface IQueuedObject extends IPrioritizable
    {
        /**
		 * 到达这个对象过程的时间。
         */
        function get nextThinkTime():Number;
        
        /**
		 * 到达这个对象过程的调用函数。
         */
        function get nextThinkCallback():Function;
    }
}