package com.cenPush.engine.resource.provider
{
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkProgressEvent;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    
    import com.cenPush.engine.resource.MP3Resource;
    import com.cenPush.engine.resource.Resource;
    
    import flash.display.Bitmap;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import com.cenPush.engine.resource.provider.ResourceProviderBase;
    
    /**
	 * 使用 BulkLoaderResourceProvider 向 ResourceManager 提供资源。这些资源是使用 BulkLoader
	 * 实例加载进来的。
     */
    public class BulkLoaderResourceProvider extends ResourceProviderBase
    {
        // -------------------------------------------------------------------
        // public getter/setter 属性 方法
        // -------------------------------------------------------------------
        
        /**
		 * 当前加载的进度
         */
        public function get phase():int
        {
            return _phase;
        }
        
        // -------------------------------------------------------------------
        // 公共 functions
        // -------------------------------------------------------------------
        /**
         * 构造函数
         */
        public function BulkLoaderResourceProvider(name:String, numConnections:int = 12, registerAsProvider:Boolean=true)
        {
            super(registerAsProvider);									 
			// 创建这个 provider 的 bulkLoader 对象。
            loader = new BulkLoader(name, numConnections);
        }
        
        /**
		 * 这个方法将会从 ResourceProvider 中获取一个资源。
         */
        public override function getResource(uri:String, type:Class, forceReload:Boolean = false):Resource
        {
            var resourceIdentifier:String = uri.toLowerCase() + type;
            
			// 如果资源存在，则返回它
            if (resources[resourceIdentifier]!=null && !forceReload) 
            {
                return resources[resourceIdentifier];
            }
            
            if (loader.get(resourceIdentifier)!=null)
                loader.remove(resourceIdentifier);
            
			// 这个资源被加入到 BulkLoader 中进行加载。
			// 如果是 MP3Resource 则使用标志type为 sound.
            loader.add(uri, { id : resourceIdentifier, type: type == MP3Resource ? "sound" : "binary"  } );
            if (!loader.isRunning) loader.start();	

			// 当资源加载完后，BulkLoader 提供一个消息，当资源加载完成后。
            loader.get(resourceIdentifier).addEventListener(Event.COMPLETE,resourceLoaded)
            loader.get(resourceIdentifier).addEventListener(BulkLoader.ERROR,resourceError)
            
			// 如果 forceReload = true, 则先删除原来的资源：
            if (resources[resourceIdentifier] && forceReload)
            {
                resources[resourceIdentifier] = null;
                delete resources[resourceIdentifier];
            }			
			
            if (resources[resourceIdentifier]==null)
            {
				// 创建resource，并提供给 ResourceManager
                var resource:Resource = new type();
                resource.filename = uri;
                resources[resourceIdentifier] = resource;
            }
            else
                resource = resources[resourceIdentifier];			
            
            return resource;
        }
        
        
        /**
         * 使用这个来通过 bulk loader 加载资源。
		 * 
		 * 当 BulkLoader 完成所有的资源的加载时将会调用 onLoaded(phase:int);
		 * 当 BulkLoader 正在加载时， onProgress(phase:int, progress:int):void 将会被调用（0-100）
         *		
		 * 当开始加载时，都会调用 onProvideResources(phase:int):Array，开始phase值为1.这个函数将会返回一个数组，里面的每个对象
		 * 都应该包含以下的属性。
         * 
         * id:String	子项加载的唯一id	
         * url:String	子项加载的url
         * type:Class	CPE resource 类型类
		 * 
		 * 如果 onProvideResources 方法为null， 则默认调用 provideResources 来提供资源，子类可以进行覆盖。
         * 
         * @param onLoaded 	 当一个阶段的所有资源加载完成后，这个方法将会被调用
         * @param onProgress 在加载的过程，这个方法将会被调用
         * @param onProvideResources 这个方法将会提供被加载资源对象信息的数组，将会被调用，在开始加载时。
         */
        public function load(onLoaded:Function = null, onProgress:Function = null, onProvideResources:Function = null):void
        {			
            this.onLoaded = onLoaded;
            this.onProgress = onProgress;
            
			// 如果没有提供 onProvideResources 函数，则在子类中覆盖 provideResources 函数来
			// 提供加载的对象资源
            this.onProvideResources = onProvideResources;
            
			// 开始 phase = 1
            _phase = 1;
            
			// 加入监听事件。
            if (!loader.hasEventListener(BulkProgressEvent.COMPLETE))
                loader.addEventListener(BulkProgressEvent.COMPLETE, resourcesLoaded)
            
            if (!loader.hasEventListener(BulkProgressEvent.PROGRESS))
                loader.addEventListener(BulkProgressEvent.PROGRESS, resourcesProgress)			
            
			// 从阶段1 开始加载资源
            loadResources();				 			
        }
        
        // -------------------------------------------------------------------
        // private 和 protected 方法
        // -------------------------------------------------------------------
        
        private function resourceLoaded(event:Event):void
        {
			// 如果资源存在，则开始初始化
            if (resources[(event.currentTarget as LoadingItem).id]!=null)
            {
				// 从 bulkLoader 中获取资源，并释放 bulkLoader 中的资源占用。
                var content:* = loader.getContent( (event.currentTarget as LoadingItem).id , true);			   
                
				// 使用 bulkLoader 加载的数据初始化资源
                if (content is Bitmap)
                {
					// 使用原生的 BitmapData 初始化 ImageResource 
                    (resources[(event.currentTarget as LoadingItem).id] as Resource).initialize((content as Bitmap).bitmapData);
					// 设置Bitmap变量为null, 则将会被 GC
                    content = null;
                }
                else
                    (resources[(event.currentTarget as LoadingItem).id] as Resource).initialize(content);
            }
        }		
        
        private function resourceError(event:ErrorEvent):void
        {
			// 如果当前加载的资源存在，则标识该资源加载失败了。
            if (resources[(event.currentTarget as LoadingItem).id]!=null)
            {
                (resources[(event.currentTarget as LoadingItem).id] as Resource).fail(event.text);
            }
        }		
        
        /**
		 * 覆盖这个方法提供每个加载阶段的资源信息对象。
         * 
		 * 每个对象都应该有下面的属性
         * 
         * id:String	加载 item 唯一的标识	
         * url:String	item 被加载的 url
         * type:Class	CBE 中 resource 的类型
         * 
         * @return Array 包含了资源加载信息对象。
         */
        protected function provideResources():Array
        {	
            return new Array();				
        }
        
        
        /**
		 * 一个特定阶段的资源加载完成后，这个方法将会被调用。
         */         
        private function resourcesLoaded(event:BulkProgressEvent):void
        {
            // 创建 Resource 对象，并把它们存储在 ResourceManager 中，可以从中获取它们。
            saveResources();
            
            // 如果提供了 onLoaded 函数则调用。
            if (onLoaded!=null) onLoaded(phase);
            
            // 增加当前加载的阶段。
            _phase++;
            
            // 加载下一个阶段的资源
            loadResources();			  
        } 
        
        /**
		 * 当一个特定阶段正在加载时，这个方法将会被调用。
         */         
        private function resourcesProgress(event:BulkProgressEvent):void
        {
            // 如果提供了 onProgress 函数则调用
            if (onProgress!=null) onProgress(phase,Math.round(event.percentLoaded*100));
        }
        
        /**
		 * 这个方法将会获取当前加载阶段的 bulkResource 的加载对象信息，并启动 BulkLoader 开始加载。
         */         
        private function loadResources():void
        {			
            // 获取当前加载阶段 bulk 的加载对象信息数组
            if (onProvideResources!=null)
                bulkResources = onProvideResources(phase);
            else
                bulkResources = provideResources();
            
            // 把提供资源信息加入到 BulkLoader 中
            if (bulkResources && bulkResources.length>0)
            {	
                for (var r:int=0; r<bulkResources.length; r++)
                {
                    var resourceIdentifier:String = bulkResources[r].url.toLowerCase() + bulkResources[r].type;
					if (bulkResources[r].id!=null) resourceIdentifier = bulkResources[r].id;					
                    if (bulkResources[r].url != "" && bulkResources[r].url != null &&
                        bulkResources[r].type )
                    {
						// 对象是有效的，则加入到 BulkLoader中。
                        loader.add(bulkResources[r].url, { id : resourceIdentifier } );				
                    }
                }
                
                // 启动 BulkLoader 开始加载
                if (!loader.isRunning)
                    loader.start();
            }
        }
        
        /**
		 * 这个方法将会为加载的资源创建 CPE Resource 对象，并保存它们，使得可以在ResourceManager中
		 * 取得。
         */         
        private function saveResources():void
        {
            // 注册加载的资源，嵌入到CPE ResourceManager 中
            for (var r:int=0; r<bulkResources.length; r++)
            {
                if (bulkResources[r].url != "" && bulkResources[r].url != null &&
                    bulkResources[r].type != null )
                {
                    var resourceIdentifier:String = bulkResources[r].url.toLowerCase() + bulkResources[r].type;
                    // 如果有效，则尝试从 BulkLoader 中获取数据。
                    if (loader.getContent( resourceIdentifier )!=null)
                    {
                        // 创建一个新的 resource 类型。
                        var resource:Resource = new bulkResources[r].type();
                        
                        // 从 bulkLoader 中获取数据，并释放 bulkLoader 中的内存占用。
                        var content:* = loader.getContent( resourceIdentifier , true);
                        resource.filename = bulkResources[r].url;
                        
                        // 使用 bulkLoader 的数据初始化 resource.						
                        if (content is Bitmap)
                        {
                            // 使用原生的 BitmapData 初始化 ImageResource.
                            resource.initialize((content as Bitmap).bitmapData);
                            // 设置 Bitmap 变量为null, 所以它就会被 GC.
                            content = null;
                        }
                        else
                            resource.initialize(content);
                        
                        // 把资源加入到资源字典。				
                        resources[resourceIdentifier] = resource
                    }
                }				
            }			
        }		
        
        
        // -------------------------------------------------------------------
        // private / protected 变量
        // -------------------------------------------------------------------
        protected var loader:BulkLoader = null;
        
        private var _phase:int = 1;
        private var bulkResources:Array = new Array();
        
        private var onLoaded:Function = null;
        private var onProgress:Function = null;
        private var onProvideResources:Function = null;
        
        
    }
}