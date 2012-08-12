package com.cenPush.engine.resource.provider
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.cenPush.engine.resource.Resource;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import com.cenPush.engine.resource.provider.BulkLoaderResourceProvider;
	
    /**
	 * LoadedResourceProvider 是用于给 ResourceManager 提供资源，当没有其他可对应的资源提供器。
     * 
	 * 将会使用 BulkLoader 加载所需的资源。
     * 
	 * 这个类使用单例模式。
     */
	public class FallbackResourceProvider extends BulkLoaderResourceProvider
	{
        
		// ------------------------------------------------------------
		// public 方法
		// ------------------------------------------------------------
		
        /**
        * 构造函数
        */ 
		public function FallbackResourceProvider()
		{
			// 调用 父类的构造函数，标识这个 Provider 不应该与注册为 一般的提供器。
			super("PBEFallbackProvider",12,false);
		}
        
        /**
		 * 这个方法将会检查，指定的资源是否存在于这个资源提供器。
        */
		public override function isResourceKnown(uri:String, type:Class):Boolean
		{
			// 始终会返回true，因为这个资源提供器会动态地加载资源。
			return true;
		}
				
		// ------------------------------------------------------------
		// private 和 protected 变量
		// ------------------------------------------------------------		
        
	}
}