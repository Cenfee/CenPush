package com.cenPush.engine.resource
{
    import com.cenPush.engine.CPE;
    import com.cenPush.engine.CPEUtil;
    import com.cenPush.engine.debug.Logger;
    import com.cenPush.engine.resource.MP3Resource;
    import com.cenPush.engine.resource.Resource;
    import com.cenPush.engine.resource.ResourceEvent;
    import com.cenPush.engine.resource.SoundResource;
    import com.cenPush.engine.resource.provider.EmbeddedResourceProvider;
    import com.cenPush.engine.resource.provider.FallbackResourceProvider;
    import com.cenPush.engine.resource.provider.IResourceProvider;
    import com.cenPush.engine.serialization.TypeUtility;
    
    import flash.events.Event;
    import flash.utils.Dictionary;
    
	/**
	 * 这是资源管理器，负责所有与资源相关的工作（images,xml,等）。其中包含加载外部文件，管理嵌入的文件，和不使用的时候
	 * 清除所有的资源。
	 */
    public class ResourceManager
    {        
		/**
		 * 如果设置为true, 我们将不会从外部获取资源 － 仅仅是查找已经嵌入并在resoueceManager注册的资源。
		 */
        public var onlyLoadEmbeddedResources:Boolean = false;
        
        /**
		 * 如果onlyloadEmbeddedResources设置为true,并且没有寻找到合适的资源，
		 * 这个函数将会被调用。
         */
        public var onEmbeddedFail:Function;
        
        /**
         * 通过文件名获取资源。如果资源已经被加载或者已经被嵌入，就会返回该资源的一个引用。这个资源不会直接通过onLoaded
		 * 返回。即使资源已经被加载，它也会被异步地调用。
		 * 
         * <p>如果资源曾经加载失败，这个不会再尝试加载，会直接调用fail()反馈.</p>
         * 
         * @param filename 		需要加载资源的url.
         * @param resourceType 	资源的类型，这个是Resource的子类。
         * @param onLoaded 		当资源加载成功后，这个函数将会被调用。同时这个资源的类型，将会通过参数传递给函数。
         * @param onFailed 		当资源加载失败后，这个函数将会被调用。同时这个资源的类型，将会通过参数传递给函数，虽然资源内容无效，但是资源的文件名还是正确的。
         * @param forceReload   有时需要重新加载资源，即使它已经被加载进来了。  
         * 
         * @see Resource
         */
        public function load(filename:String, resourceType:Class, onLoaded:Function = null, onFailed:Function = null, forceReload:Boolean = false):Resource
        {
            // 不能为空的文件!
            if(filename == null || filename == "")
            {
                Logger.error(this, "load", "Cannot load a " + resourceType + " with empty filename.");
                return null;
            }
            
            // 从已经存在的资源中寻找.
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;
            var resource:Resource = _resources[resourceIdentifier];
            
			// 如果资源已经存在，并且我们想重新加载
            if (resource && forceReload)
            {
                _resources[resourceIdentifier] = null;
                delete _resources[resourceIdentifier];
                resource = null;
            }
            
            // 如果资源目前不存在
            if (!resource)
            {
				// 如果onlyLoadedResources设置为rue, 并且在嵌入的资源中无法寻找到时进行处理。
                if(onlyLoadEmbeddedResources && !embeddedResourceProvider.isResourceKnown(filename, resourceType))
                {
                    var tmpR:Resource = new Resource();
                    tmpR.filename = filename;
                    tmpR.fail("not embedded in the SWF with type " + resourceType + ".");
                    fail(tmpR, onFailed, "'" + filename + "' was not loaded because it was not embedded in the SWF with type " + resourceType + ".");
                    if(onEmbeddedFail != null)
                        onEmbeddedFail(filename);
                    return null;
                }
                
				// 所有音乐类型的文件类型设置为MP3Resource. TO-DO: 扩展音乐文件的格式。
                var fileExtension:String = CPEUtil.getFileExtension(filename).toLocaleLowerCase();
                if(resourceType == SoundResource && (fileExtension == "mp3" || fileExtension == "wav"))
                    resourceType = MP3Resource;
                
				// 检查所有 资源提供器（ResourceProviderBase的子类）是否存在所寻找的资源。
                for (var rp:int = 0; rp < resourceProviders.length; rp++)
                {
                    if ((resourceProviders[rp] as IResourceProvider).isResourceKnown(filename, resourceType))
                        resource  = (resourceProviders[rp] as IResourceProvider).getResource(filename, resourceType, forceReload);
                }

				// 如果没有找到合适的，则使用默认的资源提供器进行加载
                if (!resource)
                    resource = fallbackResourceProvider.getResource(filename, resourceType, forceReload);
              
				// 确保文件名已经设置了。
                if(!resource.filename)
                    resource.filename = filename;
                
				//把它存储在资源字典中。
                _resources[resourceIdentifier] = resource;
            }
            else if (!(resource is resourceType))
            {
                fail(resource, onFailed, "The resource " + filename + " is already loaded, but is of type " + TypeUtility.getObjectClassName(resource) + " rather than the specified " + resourceType + ".");
                return null;
            }
            
			// 处理 资源加载失败、加载成功、或者没加载完。
            if (resource.didFail)
            {
                fail(resource, onFailed, "The resource " + filename + " has previously failed to load");
            }
            else if (resource.isLoaded)
            {
                if (onLoaded != null)
                    CPE.processManager.callLater(onLoaded, [ resource ]);
            }
            else
            {
				// 仍然在加载中，所以加入相关事件。
                if (onLoaded != null)
                    resource.addEventListener(ResourceEvent.LOADED_EVENT, function (event:Event):void { onLoaded(resource); } );
                
                if (onFailed != null)
                    resource.addEventListener(ResourceEvent.FAILED_EVENT, function (event:Event):void { onFailed(resource); } );
            }
            
			// 增加资源引用的次数。
            resource.incrementReferenceCount();
            
            return resource;
        }
        
        /**
		 * 移出一个已经加载的资源。这并不意味着，资源会马上进行垃圾回收。资源都有一个自定义的引用数，每成功load()获取资源
		 * 一次，引用数就会增加一次。
		 * 
         * @param filename 资源的文件名.
         * @param resourceType 资源的类型.
         */
        public function unload(filename:String, resourceType:Class):void
        {
			// 我们要卸载资源，是因为我们嵌入了不合理的资源，既然它们已经被加载进内存了，
			// 就不能马上移除。
            
			// 我们还必须移除资源提供器中对资源的引用，考虑到这个，暂时不恢复这个功能。
            return;
            
            if (!_resources[filename + resourceType])
            {
                Logger.warn(this, "Unload", "The resource from file " + filename + " of type " + resourceType + " is not loaded.");
                return;
            }
            
            _resources[filename + resourceType].DecrementReferenceCount();
            if (_resources[filename + resourceType].ReferenceCount < 1)
            {
                _resources[filename + resourceType] = null;
                delete _resources[filename + resourceType];
            }
        }
        
        /**
		 * 使用资源管理器注册一个资源，封装成 resource. 这个用在处理 嵌入的资源，绑定资源类。
         * 
		 * @param filename 需要注册资源的文件名。应该匹配资源的系统文件名。
		 * @param resourceType Resource的子类。
		 * @param data 一个字节数组，包含了资源的数据。这将是 Resource 的data。
         * 
         * @see com.cenPush.engine.resource.ResourceBundle
         */
        public function registerEmbeddedResource(filename:String, resourceType:Class, data:*):void
        {
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;
            
            if (_resources[resourceIdentifier])
            {
                Logger.warn(this, "registerEmbeddedResource", "A resource from file " + filename + " has already been embedded.");
                return;
            }
            
            try
            {
                // 建立Resource,并进行初始化。
                var resource:Resource = new resourceType();
                resource.filename = filename;
                resource.initialize(data);
                
                // These can be in the try since the catch will return.
                resource.incrementReferenceCount();
                _resources[resourceIdentifier] = resource;
            }
            catch(e:Error)
            {
                Logger.error(this, "registerEmbeddedResources", "Could not instantiate resource " + filename + " due to error:\n" + e.toString());
                return;
            }
        }
        
        /**
		 * 给 ResourceManager 注册一个资源提供器。一旦加入了，这个 ResourceManager 将会使用 IResoureProvider 寻找所需的资源。
         *  
         * @param resourceProvider 加入的 Provider.
         * @see IResourceProvider
         */
        public function registerResourceProvider(resourceProvider:IResourceProvider):void
        {
			// 检查 resourceProvider 是否已经注册过了。
            if (resourceProviders.indexOf(resourceProvider) != -1)
            {
                Logger.warn(ResourceManager, "registerResourceProvider", "Tried to register ResourceProvider '" + resourceProvider + "' twice. Ignoring...");
                return;
            }
            
			// 把它加入到 资源提供器列表中。
            resourceProviders.push(resourceProvider);
        }
        
        /**
		 * 检查一个资源是否已经加载完。如果没有这个资源，直接返回false.
         * @param filename 和使用load()的filename是一样的。
         * @param type 和使用load()的resourceType是一样的。
         * @return True 如果资源已经加载完了。
         */
        public function isLoaded(filename:String, resourceType:Class):Boolean
        {
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;
            if(!_resources[resourceIdentifier])
                return false;
            
            var r:Resource = _resources[resourceIdentifier];
            return r.isLoaded;                
        }

		/**
		 * 获取一个已经注册过的资源。如果没有注册就返回null。
		 * @param filename 和使用load()的filename是一样的。
         * @param type 和使用load()的resourceType是一样的。
		 * @return resource
		 */
		public function getResource(filename:String, resourceType:Class):Resource
		{
			var resourceIdentifier:String = filename.toLowerCase() + resourceType;
			return _resources[resourceIdentifier];
		}
		
		/**
		 * 移除一个资源.@Cenfee
		 */
		public function removeResource(filename:String, resourceType:Class):void
		{
			var isResourceKnow:Boolean;
			for (var rp:int = 0; rp < resourceProviders.length; rp++)
			{
				if ((resourceProviders[rp] as IResourceProvider).isResourceKnown(filename, resourceType))
				{
					(resourceProviders[rp] as IResourceProvider).removeResource(filename, resourceType);
					isResourceKnow = true;
				}
			}
			if(_resources[filename + resourceType])
			{
				delete _resources[filename + resourceType];
				isResourceKnow = true;
			}
			if(!isResourceKnow)
				Logger.warn(this, "removeResource", "资源管理器不存在这个资源!");
		}
		
		/**
		 * 移除所有资源。@Cenfee
		 */
		public function removeAllResources():void
		{
			for (var rp:int = 0; rp < resourceProviders.length; rp++)
			{
				(resourceProviders[rp] as IResourceProvider).removeAllResources();
			}
			_resources = new Dictionary();
		}
		
        /**
		 * 反馈一个资源加载失败。
         */
        private function fail(resource:Resource, onFailed:Function, message:String):void
        {
            if(!resource)
                throw new Error("Tried to fail null resource.");
            
            Logger.error(this, "load", message);
            if (onFailed != null)
               CPE.processManager.callLater(onFailed, [resource]);
        }
        
        /**
		 * 资源字典，保存着所有已经注册的资源。
         */
        private var _resources:Dictionary = new Dictionary();
        
        /**
		 * 资源提供器的列表，使用它来获取相应类型的资源。
         */        
        private var resourceProviders:Array = new Array();
		
		private var _embeddedResourceProvider:EmbeddedResourceProvider;
		private var _fallbackResourceProvider:FallbackResourceProvider;
		internal function get embeddedResourceProvider():EmbeddedResourceProvider
		{
			if(!_embeddedResourceProvider)
				_embeddedResourceProvider = new EmbeddedResourceProvider();
			return _embeddedResourceProvider;
		}
		internal function get fallbackResourceProvider():FallbackResourceProvider
		{
			if(!_fallbackResourceProvider)
				_fallbackResourceProvider = new FallbackResourceProvider();
			return _fallbackResourceProvider;
		}
    }
}
