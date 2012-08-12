package com.cenPush.engine.resource
{
   import com.cenPush.engine.debug.Logger;
   
   import flash.utils.ByteArray;
   import com.cenPush.engine.resource.Resource;
   
   [EditorData(extensions="xml")]
   
   /**
    * 这是用于XML数据的Resource子类。
    */
   public class XMLResource extends Resource
   {
      /**
	   * 被加载的XML数据。在加载完成之前，它是NULL的。
       */
      public function get XMLData():XML
      {
         return _xml;
      }
      
      /**
	   * 这里只需要包含XML本身的字符串数据，来自加载外部的XML文件，所以我们不需要任何特别的加载方式。这个只要
	   * 传递一个字节数组，并标志资源已经加载完成了。
       */
      override public function initialize(data:*):void
      {
         if (data is ByteArray)
         {
         	// convert ByteArray data to a string
         	data = (data as ByteArray).readUTFBytes((data as ByteArray).length);
         }
            
         try
         {
            _xml = new XML(data);
         }
         catch (e:TypeError)
         {
            Logger.print(this, "Got type error parsing XML: " + e.toString());
            _valid = false;
         }
         
         onLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      override protected function onContentReady(content:*):Boolean 
      {
         return _valid;
      }
      
      private var _valid:Boolean = true;
      private var _xml:XML = null;
   }
}