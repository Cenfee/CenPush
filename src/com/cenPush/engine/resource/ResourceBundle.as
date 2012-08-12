package com.cenPush.engine.resource
{
    import com.cenPush.engine.CPE;
    import com.cenPush.engine.debug.Logger;
    import com.cenPush.engine.resource.provider.EmbeddedResourceProvider;
    
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import com.cenPush.engine.resource.DataResource;
    import com.cenPush.engine.resource.ImageResource;
    import com.cenPush.engine.resource.MP3Resource;
    import com.cenPush.engine.resource.Resource;
    import com.cenPush.engine.resource.XMLResource;
    
    /**
     * 这个资源包 解决了自动加载并注册嵌入的资源。使用的时候，创建它的子类，并且以公共的变量嵌入资源，然后，
	 * 实例化你的类通过 CPE.addResources(new MyResourceBundleSubclass());传递给CPE。ResourceBundle
	 * 将会加载所有这些资源到ResourceManager中。 
	 * 
     * @see CPE.addResources CPE.addResources
     */
    public class ResourceBundle
    {
        
        /**
		 * ExtensionTypes 集合了文件扩展名对应它们加载进来的 resource 类型。每个登记都已经是这样的格式
		 * 'xml:"com.cenPush.engine.resource.XMLResource"' xml是文件扩展名，
		 * "com.cenPush.engine.resource.XMLResource" 是resource子类的全称类名。
         *
		 * 这个集合也可以运行时扩展：
         *  ResourceBundle.ExtensionTypes.mycustomext = "com.mydomain.customresource"
         */
        
        public static var ExtensionTypes:Object = {
            png:"com.cenPush.engine.resource.ImageResource",
            jpg:"com.cenPush.engine.resource.ImageResource",
            gif:"com.cenPush.engine.resource.ImageResource",
            bmp:"com.cenPush.engine.resource.ImageResource",
            xml:"com.cenPush.engine.resource.XMLResource",
            pbelevel:"com.cenPush.engine.resource.XMLResource",
            swf:"com.cenPush.engine.resource.SWFResource",
            mp3:"com.cenPush.engine.resource.MP3Resource"
        };
        
        /**
		 * 这个构造函数创建了所有的逻辑。
		 * ResourceBundle 在这里循环所有它的公共属性，并使用ResourceManager注册所有的嵌入资源。
         */
        public function ResourceBundle()
        {
			// 确保 CPE 已经初始化 ResourceManager 了。
            if(!CPE.resourceManager)
            {
                throw new Error("Cannot instantiate a ResourceBundle until you have called PBE.startup(this);. Move the call to new YourResourceBundle(); to occur AFTER the call to PBE.startup().");
            }
            
			// 获取所有嵌入成员的信息。
            var desc:XML = describeType(this);
            var res:Class;
            var resIsEmbedded:Boolean;
            var resSource:String;
            var resMimeType:String;
            var resTypeName:String;
           
			// 强制导入类。
            new DataResource();
            new ImageResource();
            new XMLResource();
            new MP3Resource();

			// 循环遍历这个类的每个公共变量。
            for each (var v:XML in desc.variable)
            {
				// 存储对象的一个引用(变量名)
                res = this[v.@name];
                
				// 分析是否没有正确嵌入，需要时，这里会抛出一个错误。
                resIsEmbedded = false;
                resSource = "";
                resMimeType = "";
                resTypeName="";
                
				
				// 遍历每一个孩子变量的元标签
                for each (var meta:XML in v.children())
                {
					// 如果获取到一个 Embeded 的元标签
                    if (meta.@name == "Embed") 
                    {
                        // 如果我们得到一个有效的嵌入标签，那么资源嵌入正确
						resIsEmbedded = true;
                       
						// 从嵌入的标签中提取出 source 和 MIME 信息
                        for each (var arg:XML in meta.children())
                        {
                            if (arg.@key == "source") 
                            {
                                resSource = arg.@value;
                            } 
                            else if (arg.@key == "mimeType") 
                            {
                                resMimeType = arg.@value;
                            }
                        }
                    }
                    else if (meta.@name == "ResourceType")
                    {
                        for each (arg in meta.children())
                        {
                            if (arg.@key == "className") 
                            {
                                resTypeName = arg.@value;
                            } 
                        }                  
                    }
                }
                
				// 现在开始分析所有的元标签，判断是否合理地嵌入了。
                
				// 检查提取出的信息：
                if ( !resIsEmbedded || resSource == "" || res == null ) 
                { 
                    Logger.error(this, "ResourceBundle", "A resource in the resource bundle with the name '" + v.@name + "' has failed to embed properly.  Please ensure that you have the command line option \"--keep-as3-metadata+=TypeHint,EditorData,Embed\" set properly.  Additionally, please check that the [Embed] metadata syntax is correct.");
                    continue;
                }
               
				// 如果元标签没有明确指定资源类型的名称。
                if (resTypeName == "")
                {
					// 进一步扩展寻找类名
                    
					// 获取源文件名的扩展名
                    var extArray:Array = resSource.split(".");
                    var ext:String = (extArray[extArray.length-1] as String).toLowerCase();
                    
					// 如果扩展类型 type 可以被识别 或 不可以。。
                    if ( !ExtensionTypes.hasOwnProperty(ext) )
                    {
                        Logger.warn(this, "ResourceBundle", "No resource type specified for extension '." + ext + "'.  In the ExtensionTypes parameter, expected to see something like: ResourceBundle.ExtensionTypes.mycustomext = \"com.mydomain.customresource\" where mycustomext is the (lower-case) extension, and \"com.mydomain.customresource\" is a string of the fully qualified resource class name.  Defaulting to generic DataResource.");
                        
						// 如果寻找不到可识别的类型，则使用默认的资源类。
                        resTypeName = "com.pblabs.engine.resource.DataResource";
                    }
                    else
                    {
                        // 如果这个文件类型可以识别，那么就从数组中获取 资源类的类名。
						resTypeName = ExtensionTypes[ext] as String;
                    }
                }
               
				// 现在我们有一个资源类的类名，就开始尝试实例化它。
                var resType:Class;
                try 
                {
					// 寻找这个资源类！
                    resType = getDefinitionByName( resTypeName ) as Class;
                } 
                catch ( err:Error ) 
                {
					// 失败了，确保它是NULL的。
                    resType = null;
                }
                
                if (!resType)
                {
                    Logger.error(this, "ResourceBundle", "The resource type '" + resTypeName + "' specified for the embedded asset '" + resSource + "' could not be found.  Please ensure that the path name is correct, and that the class is explicity referenced somewhere in the project, so that it is available at runtime.  Do you call PBE.registerType(" + resTypeName + "); somewhere?");
                    continue;
                }
                
				// 这个资源 类型是一个类 -- 现在确保它是一个 Resource。
                var testResource:* = new resType();
                if (!(testResource is Resource))
                {
                    Logger.error(this, "ResourceBundle", "The resource type '" + resTypeName + "' specified for the embedded asset '" + resSource + "' is not a subclass of Resource.  Please ensure that the resource class descends properly from com.pblabs.engine.resource.Resource, and is defined correctly.");
                    continue;
                }
				
				// 一切都没问题了，就开始注册嵌入资源了。
                CPE.resourceManager.embeddedResourceProvider.registerResource( resSource, resType, new res() );
            }
        }                  
    }
}
