package com.cenPush.engine.resource 
{
    import com.cenPush.engine.CPE;
    import com.cenPush.engine.resource.Resource;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.system.ApplicationDomain;
    import flash.utils.getQualifiedClassName;

    [EditorData(extensions="swf")]

    /**
	 * 这个用于 SWF 文件的 Resource 的子类。使用它简单地加载文件，并从中获取资源。
     */
    public class SWFResource extends Resource
    {
        public function get clip():MovieClip 
        {
            return _clip;
        }

        public function get appDomain():ApplicationDomain 
        {
            return _appDomain; 
        }

        /**
		 * 获取一个包含在SWF里导出的类的实例。
		 * 在被加载的程序域中，如果根据类名没有找到导出的类则返回一个NULL的引用
         *
         * @param name 程序域中的类全称.
         */
        public function getExportedAsset(name:String):Object 
        {
            if (null == _appDomain) 
                throw new Error("not initialized");

            var assetClass:Class = getAssetClass(name);
            if (assetClass != null)
                return new assetClass();
            else
                return null;
        }

        /**
		 * 使用类名获取一个在SWF里导出的类的实例。
		 * 在被加载的程序域中，如果根据类名没有找到导出的类则返回一个NULL的引用。
         *
         * @param name 导出的类的全称类名.
         */
        public function getAssetClass(name:String):Class 
        {          
            if (null == _appDomain) 
                throw new Error("not initialized");

            if (_appDomain.hasDefinition(name))
                return _appDomain.getDefinition(name) as Class;
            else
                return null;
        }

        /**
		 * 递归寻找所有孩子影片剪辑中最大帧数的。
         */
        public function findMaxFrames(parent:MovieClip, currentMax:int):int
        {
            for (var i:int=0; i < parent.numChildren; i++)
            {
                var mc:MovieClip = parent.getChildAt(i) as MovieClip;
                if(!mc)
                    continue;

                currentMax = Math.max(currentMax, mc.totalFrames);            

                findMaxFrames(mc, currentMax);
            }

            return currentMax;
        }


        /**
		 * 递归，使所有孩子影片剪辑跳到指定的帧，如果超过孩子的总帧数，则跳到末尾。
         */
        public function advanceChildClips(parent:MovieClip, frame:int):void
        {
            for (var j:int=0; j<parent.numChildren; j++)
            {
                var mc:MovieClip = parent.getChildAt(j) as MovieClip;
                if(!mc)
                    continue;

                if (mc.totalFrames >= frame)
                    mc.gotoAndStop(frame);
                else
                    mc.gotoAndStop(mc.totalFrames);

                advanceChildClips(mc, frame);
            }
        }

        override public function initialize(data:*):void
        {
			// 如果data是一个MovieClip，则直接加载已经嵌入的资源。
            if(data is MovieClip)
            {
                onContentReady(data);
                onLoadComplete();
                return;
            }
           
			//否则使用原始的方法进行加载，并且data必须是一个ByteArray类型。
            super.initialize(data);
        }

        /**
         * @inheritDoc
         */
        override protected function onContentReady(content:*):Boolean 
        {
            if(content)
                _clip = content as MovieClip;

            // 获取程序域...
            if (resourceLoader && resourceLoader.contentLoaderInfo)
                _appDomain = resourceLoader.contentLoaderInfo.applicationDomain;
			
			//TO-DO
			else if(content && content.getChildAt(0) && content.getChildAt(0).content)
				CPE.processManager.callLater(delayGetAppDomain, [content]);
			
            else if(content && content.loaderInfo)
                _appDomain = content.loaderInfo.applicationDomain;
			
			return _clip != null;
        }
		
		//ToDO 嵌入的SWF的  中嵌了一个Loader孩子, Loader.content才是真实的内容，并且还需要延迟一帧才能拿到。
		private function delayGetAppDomain(content:*):void
		{
			_appDomain = content.getChildAt(0).content.loaderInfo.applicationDomain;
		}

        private var _clip:MovieClip;
        private var _appDomain:ApplicationDomain;
    }
}

