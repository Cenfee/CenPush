package com.cenPush.engine.resource.provider
{
    import com.cenPush.engine.CPE;
    import com.cenPush.engine.debug.Logger;
    import com.cenPush.engine.resource.Resource;
    import com.cenPush.engine.resource.ResourceManager;
    import com.cenPush.engine.resource.provider.IResourceProvider;
    
    import flash.utils.Dictionary;
    
    /**
	 * 这个 ResourceProviderBase 类可以被继承来创建 一个 ResourceProvider 资源提供器，它会自动
	 * 使用 ResourceManager 来注册资源。
     */
    public class ResourceProviderBase implements IResourceProvider
    {
        public function ResourceProviderBase(registerProvider:Boolean = true)
        {
			// 确保 CPE 已经初始化 resourceManager 
            if(!CPE.resourceManager)
            {
                throw new Error("Cannot instantiate a ResourceBundle until you have called PBE.startup(this);. Move the call to new YourResourceBundle(); to occur AFTER the call to PBE.startup().");
            }
            
			// 使用 ResourceManager 注册一个资源提供器。
            if (registerProvider)
				CPE.resourceManager.registerResourceProvider(this);
            
			// 创建一个对象字典，来保存所有的资源。
            resources = new Dictionary();
        }
        
        /**
		 * 这个方法会检查资源是否存在这个资源提供器。
         */
        public function isResourceKnown(uri:String, type:Class):Boolean
        {
            var resourceIdentifier:String = uri.toLowerCase() + type;
            return (resources[resourceIdentifier]!=null)
        }
        
        /**
		 * 这个方法会返回一个资源。
         */
        public function getResource(uri:String, type:Class, forceReload:Boolean = false):Resource
        {
            var resourceIdentifier:String = uri.toLowerCase() + type;
            return resources[resourceIdentifier];
        }
		
		/**
		 * 这个方法将会移除一个资源.@Cenfee
		 */
		public function removeResource(uri:String, type:Class):void
		{
			var resourceIdentifier:String = uri.toLowerCase() + type;
			if(resources[resourceIdentifier])
				delete resources[resourceIdentifier];
			else
				Logger.warn(this, "removeResource", "资源提供器中不存在这个资源！");
		}
		
		/**
		 * 这个方法将会移除所有的资源。@Cenfee
		 */
		public function removeAllResources():void
		{
			resources = new Dictionary();
		}
        
        /**
		 * 这个方法可以加入资源到这个资源提供器中，
         */
        protected function addResource(uri:String, type:Class, resource:Resource):void
        {
            var resourceIdentifier:String = uri.toLowerCase() + type;
            resources[resourceIdentifier] = resource;        	
        }
        
        // ------------------------------------------------------------
        // private 和 protected 变量
        // ------------------------------------------------------------
        protected var resources:Dictionary;
        
    }
}