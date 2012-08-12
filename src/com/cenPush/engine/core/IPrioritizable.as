package com.cenPush.engine.core
{
    /**
	 * SimplePriorityQueue需要的接口
     * 
	 * <p>子项优先级，高优先级首先被返回。</p>
     * 
     * @see SimplePriorityQueue
     */
    public interface IPrioritizable
    {
        function get priority():int;

        /**
		 * 改变优先级。如果你需要SimpalePriority.reprioritize()工作，就实现这个。
		 * 否则它会抛出一个错误。
         */
        function set priority(value:int):void;
    }
}