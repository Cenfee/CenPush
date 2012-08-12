package com.cenPush.engine.resource.provider
{
    import com.cenPush.engine.resource.Resource;
    
    /**
	 * 资源提供器，为 resourceManager 提供资源，应该实现这个接口。
     */
    public interface IResourceProvider
    {
        /**
		 * ResourceManager 寻找相关资源时，ResourceManager 将会遍历所有的资源提供器调用这个方法
		 * 进行寻找。
         */
        function isResourceKnown(uri:String, type:Class):Boolean;

        /**
		 * ResourceManager 将会通过这个方法获得资源。
         */
        function getResource(uri:String, type:Class, forceReload:Boolean = false):Resource;
		
		/**
		 * ResourceManager 将会通过这个方法移除特定的资源。@Cenfee
		 */
		function removeResource(uri:String, type:Class):void;
		
		/**
		 * ResourceManager 将会通过这个方法移除所有的资源.@Cenfee
		 */
		function removeAllResources():void;
    }
}