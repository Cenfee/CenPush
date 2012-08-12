package com.cenPush.engine.resource
{
   import flash.events.Event;
   import com.cenPush.engine.resource.Resource;
   
   /**
	* ResourceEvent 是一个被 Resource 分派加载情况信息的事件。一般情况下，不需要去使用。ResourceManager
	* 封装了它的功能。
    * 
    * @see ResourceManager
    * @see Resource 
    */
   public class ResourceEvent extends Event
   {
      /**
	   * 资源成功加载后，将会被分派。
       * 
       * @eventType LOADED_EVENT
       */
      public static const LOADED_EVENT:String = "LOADED_EVENT";
      
      /**
	   * 资源加载失败后，将会被分派。
       * 
       * @eventType FAILED_EVENT
       */
      public static const FAILED_EVENT:String = "FAILED_EVENT";
      
      /**
	   * 这个资源将会随着事件一起分派。
       */
      public var resourceObject:Resource = null;
      
      public function ResourceEvent(type:String, resource:Resource, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         resourceObject = resource;
         
         super(type, bubbles, cancelable);
      }
   }
}