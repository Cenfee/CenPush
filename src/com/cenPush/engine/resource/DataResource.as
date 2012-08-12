package com.cenPush.engine.resource
{
   import flash.utils.ByteArray;
   import com.cenPush.engine.resource.Resource;
   
   /**
	 * 这个是一个 Resource 子类，使用在任意的数据。
    */
   public class DataResource extends Resource
   {
      /**
	   * 被加载的数据。在资源完成加载前，它为null。
       */
      public function get data():ByteArray
      {
         return _data;
      }
      
      /**
       * @inheritDoc
       */
      override public function initialize(data:*):void
      {
         if(!(data is ByteArray))
            throw new Error("DataResource can only handle ByteArrays.");
            
         _data = data;
         onLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      override protected function onContentReady(content:*):Boolean 
      {
         return _data != null;
      }
      
      private var _data:ByteArray = null;
   }
}