package com.cenPush.engine.resource.provider
{
	import com.cenPush.engine.debug.Logger;
	import com.cenPush.engine.resource.Resource;
	import com.cenPush.engine.resource.provider.ResourceProviderBase;
	
	import flash.utils.Dictionary;
	
    /**
	 * EmbeddedResourceProvider 向 ResourceManager 提供 嵌入的资源。这些嵌入的资源可以通过
	 * ResourceBundle 或者 资源绑定类 的方式加入。
     * 
	 * 这个类使用单例模式，所有当使用 ResourceBundle 或者 资源绑定时 就会使用
	 * EmbeddedResourceProvider.instance 的方式注册资源。
     */
	public class EmbeddedResourceProvider extends ResourceProviderBase
	{
		// ------------------------------------------------------------
		// 公共 getter/setter 属性 方法
		// ------------------------------------------------------------

      

		// ------------------------------------------------------------
		// public 方法
		// ------------------------------------------------------------

        /**
		* 构造函数
        * 
		* 调用基类 ResourceProvideBase 构造函数 - super();
		* 自动向 ResourceManager 注册这个资源提供器。 
        */
		public function EmbeddedResourceProvider()
		{
			super();
		}        
		
        /**
		* 这个方法用在 ResourceBundle 和 绑定资源 时注册嵌入资源。
        */
		public function registerResource(filename:String, resourceType:Class, data:*):void
        {
			// 创建这个资源唯一的标识。
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;

			// 检查是否这个资源已经被注册了。
            if (resources[resourceIdentifier])
            {
                Logger.warn(this, "registerEmbeddedResource", "A resource from file " + filename + " has already been embedded.");
                return;
            }
            
			// 建立 Resource.
            try
            {
                var resource:Resource = new resourceType();
                resource.filename = filename;
                resource.initialize(data);
                
				// 在资源字典中存储它。
                resources[resourceIdentifier] = resource;
            }
            catch(e:Error)
            {
                Logger.error(this, "registerEmbeddedResources", "Could not instantiate resource " + filename + " due to error:\n" + e.toString());
                return;
            }
        }
		
		// ------------------------------------------------------------
		// private 和 protected 变量
		// ------------------------------------------------------------		
		
	}
}