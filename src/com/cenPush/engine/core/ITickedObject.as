package com.cenPush.engine.core
{
   /**
	* 实现这个接口，可以在每个时间触发点进行动作，比如移动，或者碰撞。但是不同于帧，
	* 具有不稳定性，使用这个将会有比较一致的输出结果。但是关于动画和渲染的东西，使
	* 用帧会有比较平滑的效果。
    * 
	* <p>实现这个接口，对象需要通过 addTickedObject 方法加入到ProcessManager中。</p>
    * 
    * @see ProcessManager
    * @see IAnimatedObject
    */
   public interface ITickedObject
   {
      /**
       * This method is called every tick by the ProcessManager on any objects
       * that have been added to it with the AddTickedObject method.
	   * 
	   * 如果对象已经通过 addTickedObject() 加入到ProcessManager。
	   * 这个方法会在 每个时间触发点被 ProcessManager 调用。
       * 
       * @param deltaTime 每个触发点间所经历的 时间数量。
       * 
       * @see ProcessManager#AddTickedObject()
       */
      function onTick(deltaTime:Number):void;
   }
}