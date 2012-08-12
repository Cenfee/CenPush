package com.cenPush.screens
{
    /**
	 * 一个Starling屏幕接口，由Starling的ScreenManager进行管理。
     * 
     * <p>它的子类应该是 Sprite 类型并且继承自IScreen接口，
	 * 同时这也Starling的ScreenManager所规定的。</p>
     */ 
    public interface IScreen
    {
        /**
		 * 当screen为可见时，被调用。
         * 
		 * <p>ScreenManager是负责从 Displaylist 中加入/移除screen，但是你可能
		 * 这个过程进行处理</p>
         */ 
        function onShow():void;

        /**
		 * 当屏幕不再可见时，被调用。
         * 
         * <p>ScreenManager是负责从 Displaylist 中加入/移除screen，但是你可能
		 * 这个过程进行处理</p>
         */ 
        function onHide():void;
        
        /**
		 * 当屏幕是可见时，这个会被每帧调用，更新它本身的东西。
         */
        function onFrame(delta:Number):void;
        
        /**
		 * 当屏幕是可见时，这个会被每个时间触发点调用，更新它本身的东西。
         */
        function onTick(delta:Number):void;
    }
}