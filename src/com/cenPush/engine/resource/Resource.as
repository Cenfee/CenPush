package com.cenPush.engine.resource
{
    import com.cenPush.engine.debug.Logger;
    import com.cenPush.engine.resource.ResourceEvent;
    
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    
    /**
     * @eventType com.cenPush.engine.resource.ResourceEvent.LOADED_EVENT
     */
    [Event(name="LOADED_EVENT", type="com.cenPush.engine.resource.ResourceEvent")]
    
    /**
     * @eventType com.cenPush.engine.resource.ResourceEvent.FAILED_EVENT
     */
    [Event(name="FAILED_EVENT", type="com.cenPush.engine.resource.ResourceEvent")]
    
    /**
	 * 一个资源，封装了游戏中的的资源数据。不要直接使用这个资源基类，应该创建它的相应的子类。
     * 
	 * <p>这个 Resource 类和任何子类都不要直接进行实例化，使用 ResourceManager。</p>
	 * 
	 * <p>通常，Resource shi用来从文件中加载资源，但是在一定情况下，这也不是一定的。</p>
     * 
     * @see ResourceManager
     */
    public class Resource extends EventDispatcher
    {
        /**
		 * 加载资源数据的文件名。
         */
        public function get filename():String
        {
            return _filename;
        }
        
        /**
         * @private
         */
        public function set filename(value:String):void
        {
            if (_filename != null)
            {
                Logger.warn(this, "set filename", "Can't change the filename of a resource once it has been set.");
                return;
            }
            
            _filename = value;
        }
        
        /**
		 * 资源是否已经加载完。这个仅仅是标识资源是否完成加载，但不表示一定加载成功。如果返回true, DidFail可以
		 * 检查加载是否成功。
         * 
         * @see #DidFail 
         */
        public function get isLoaded():Boolean
        {
            return _isLoaded;
        }
        
        /**
		 * 资源是否加载失败。这个仅仅是资源完成加载后才有效，所以 false值仅仅是在isLoaded为true时有效。
         * 
         * @see #IsLoaded
         */
        public function get didFail():Boolean
        {
            return _didFail;
        }
        
        /**
		 * resource引用的次数。当这个数值到达0时，resource将会被卸载。
         */
        public function get referenceCount():int
        {
            return _referenceCount;
        }
        
        /**
		 * 用来加载resource的Loader对象。当 onContentReady 返回true时，这个将会设置为 null.
         */
        protected function get resourceLoader():Loader
        {
            return _loader;
        }
        
        /**
		 * 从文件中加载资源数据。
		 * 
		 * @param filename 加载数据的本地文件路径或url。当加载完成时，一个 ResourceEvent 将会被分派
		 * LOADED_EVENT表示成功加载，FAILED_EVENT表示加载失败。
         */
        public function load(filename:String):void
        {
            _filename = filename;
            
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, onDownloadComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
            
            var request:URLRequest = new URLRequest();
            request.url = filename;
            loader.load(request);
            
			// 保持 URLLoader 的引用， 不会被 GC。
            _urlLoader = loader;
        }
        
        /**
		 * 使用资源二进制数据数组来初始化 Resource.这个将会使用Loader来进行加载。如果这个方法是不需要的
		 * （XML不需要这样来进行加载），那么这个方法可以被覆盖。但是子类要以这个指定的数据，在完成资
		 * 源加载必须调用 onLoadComplete
         * 
         * @param data 需要初始化资源的数据
         */
        public function initialize(data:*):void
        {
            if(!(data is ByteArray))
                throw new Error("Default Resource can only process ByteArrays!");
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			//TO-DO 新版本需要突破安全限制
			var context:LoaderContext = new LoaderContext();
			context.allowCodeImport = true;
			
            loader.loadBytes(data, context);
            
			// 保持 Loader 的引用， 不会被 GC。
            _loader = loader;
        }
        
        /**
		 * 增加资源引用数。这个应该仅仅被ResourceManager调用。
         */
        public function incrementReferenceCount():void
        {
            _referenceCount++;
        }
        
        /**
		 * 减少资源引用数。这个应该仅仅被ResourceManager调用。
         */
        public function decrementReferenceCount():void
        {
            _referenceCount--;
        }
        
        /**
		 * 这个方法只是被 Resource 提供器来表明加载失败。
         */
        public function fail(message:String):void
        {
            onFailed(message);        	
        }
        
        /**
		 * 当资源数据在一定条件下加载完后被调用。返回true，意味着加载成功，false 意味着加载失败。子类必须实现这个方法。
         * 
         * @param content 资源的数据.
         * 
         * @return True 如果这个content包含有效的资源。
         */
        protected function onContentReady(content:*):Boolean
        {
            return false;
        }
        
        /**
		 * 当指定的资源数据加载完成了被调用。覆盖initialize方法时必须调用这个方法。
         * 
         * @param event 这个可以被子类忽略。
         */
        protected function onLoadComplete(event:Event = null):void
        {
            try
            {
                if (onContentReady(event ? event.target.content : null))
				{
                    _isLoaded = true;
                    _urlLoader = null;
                    _loader = null;
                    dispatchEvent(new ResourceEvent(ResourceEvent.LOADED_EVENT, this));
                    return;
                }
                else
                {
                    onFailed("Got false from onContentReady - the data wasn't accepted.");
                    return;
                }
            }
            catch(e:Error)
            {
                Logger.error(this, "Load", "Failed to load! " + e.toString());
            }
            
            onFailed("The resource type does not match the loaded content.");
            return;
        }
        
        private function onDownloadComplete(event:Event):void
        {
            var data:ByteArray = ((event.target) as URLLoader).data as ByteArray;
            initialize(data);
        }
        
        private function onDownloadError(event:IOErrorEvent):void
        {
            onFailed(event.text);
        }
        
        private function onDownloadSecurityError(event:SecurityErrorEvent):void
        {
            onFailed(event.text);
        }
        
        protected function onFailed(message:String):void
        {
            _isLoaded = true;
            _didFail = true;
            Logger.error(this, "Load", "Resource " + _filename + " failed to load with error: " + message);
            dispatchEvent(new ResourceEvent(ResourceEvent.FAILED_EVENT, this));
            
            _urlLoader = null;
            _loader = null;
        }
        
        protected var _filename:String = null;
        private var _isLoaded:Boolean = false;
        private var _didFail:Boolean = false;
        private var _urlLoader:URLLoader;
        private var _loader:Loader;
        private var _referenceCount:int = 0;
    }
}