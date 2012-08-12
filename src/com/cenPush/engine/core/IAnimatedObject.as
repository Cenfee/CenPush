package com.cenPush.engine.core
{
   /**
    * 继承该接口，对象可以实现每帧的动画。这是与渲染最直接的东西，比如精灵
	* 的动画，AI，自然事物的动作等。
	* 
	* <p>实现了这个接口，还需要把它通过 AddAnimatedObject 加入到
	* ProcessManager.</p>
	* 
    * 
    * @see ProcessManager
    * @see ITickedObject
    */
   public interface IAnimatedObject
   {
      /**
	   * 这个方法将会被ProcessManager 每帧调用。前提是已经通过AaddAnimatedObject
	   * 加入到ProcessManager中。
       * 
       * @param deltaTime The amount of time (in seconds) that has elapsed since
       * the last frame.
	   * 
	   * @param deltaTime 从上帧开始，切换时间。
       * 
       * @see ProcessManager#AddAnimatedObject()
       */
      function onFrame(deltaTime:Number):void;
   }
}