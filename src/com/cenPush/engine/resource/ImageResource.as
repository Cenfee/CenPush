package com.cenPush.engine.resource
{
    import com.cenPush.engine.CPE;
    import com.cenPush.engine.resource.Resource;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    [EditorData(extensions="jpg,png,gif")]
    
    /**
	 * 这个用在 图片数据 的Resource 的子类。可以使用它来加载 Flash支持的图片格式，并接受它作为一个
	 * BitmapData 或者 Bitmap.
     */
    public class ImageResource extends Resource
    {
        /**
		 * 一旦资源成功加载后，这个Bitmap代表了加载进来的图片。因为这个Bitmap不会被共享，所以每一次获取
		 * 都会创建一个新的Bitmap。
         */
        public function get image():Bitmap
        {
			// 如果BitmapData 为null， 不会再创建Bitmap.
            if (_bitmapData != null)
                return new Bitmap(_bitmapData);
            return null;
        }
        
        /**
		 * 返回已经加载的原生的BitmapData。
         */
        public function  get bitmapData():BitmapData
        {
            return _bitmapData;
        }
        
        override public function initialize(data:*):void
        {        	
            if (data is Bitmap)
            {
				//如果数据是一个Bitmap，则直接加载使用bitmapData
                onContentReady(data.bitmapData);
                onLoadComplete();
                return;
            }
            else if (data is BitmapData)
            {
				// 如果数据是一个BitmapData对象，则直接使用 BitmapData
                onContentReady(data as BitmapData);
                onLoadComplete();  
                return;          	
            }
            else if (data is DisplayObject)
            {
                var dObj:DisplayObject = data as DisplayObject;
                
				// 获取显示对象的父显示对象。
                var targetSpace:DisplayObject;
                if(dObj.parent)
                    targetSpace = dObj.parent;
                else
                    targetSpace = CPE.nativeStage;
                
				// 获取对象的rectangle
                var spriteRect:Rectangle = dObj.getBounds(targetSpace);
                
				// 创建一个 transform 矩阵 来绘制这个Sprite.
                var m:Matrix = new Matrix();
                m.translate(spriteRect.x*-1, spriteRect.y*-1);            	  
                
				// 绘制显示对象到一个完全头完全透明的BitmapData对象.
                var bmd:BitmapData = new BitmapData(spriteRect.width,spriteRect.height,true,0x000000);
                bmd.draw(dObj, m);
                
				// 可以使用这个BitmapData了。
                onContentReady(bmd);
                onLoadComplete();
                return;            	
            }
            
			// 如果不符合上面的条件，则它必须是一个ByteArray类型，使用原始的方法进行加载。
            super.initialize(data);
        }
        
        /**
         * @inheritDoc
         */
        override protected function onContentReady(content:*):Boolean 
        {
            if (content is BitmapData)
                _bitmapData = content as BitmapData;
            else if (content is Bitmap)
            {
				// 如果实例外传进来的数据是 ByteArray 类型，这个函数的参数将会从父类的方法传递进来
                _bitmapData = (content as Bitmap).bitmapData;
                content = null;
            }
            return _bitmapData != null;
        }
        
        protected var _bitmapData:BitmapData = null;
    }
}