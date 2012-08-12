package com.cenPush.screens
{
	import com.cenPush.engine.CPE;
	import com.cenPush.engine.core.*;
	import com.cenPush.engine.debug.Logger;
	
	import flash.utils.*;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.*;

    /**
	 * 一个简单的系统管理游戏的界面(可考虑UI)。
     * 
	 * <p>这个 ScreenManager 控制被定义好的 screens 。通过goto(), push(), pop()
	 * 方法让你从一个 screen 移动到 另一个 screen. 每个screen 仅仅是一个 DisplayObject
	 * 并且实现了 IScreen 的子类；这些类都是AS，但是如果你完全是使用Flex，你也可以使用
	 * .mxml.</p>
     * 
	 * <p>使用之前，首先调用 registerScreen 来注册 screen 实例。</p>
     * 
     * <p>这个系统仅仅是使用在最底层的，如状态切换，仅仅像是弹出窗口，不适合使用。</p>
	 * 
	 * 这个 ScreenManager 
     */
    public class ScreenManager implements IAnimatedObject, ITickedObject
    {
        
        public function ScreenManager()
        {
            CPE.processManager.addTickedObject(this);
            CPE.processManager.addAnimatedObject(this);
            
            screenParent = CPE.mainSprite;
        }
        
		/**
		 * 注册屏幕类,动态创建和删除。
		 */
		public function registerScreenClass(name:String, ScreenClass:Class):void
		{
			_screenDictionary[name] = ScreenClass;
		}
		
		/**
		 * 切换屏幕类，会卸载上一个屏幕类。
		 */
		public function gotoClass(name:String):void
		{
			if(_currentScreen)
			{
				_currentScreen.onHide();
				screenParent.removeChild(_currentScreen as DisplayObject, true);
			}
			
			var ScreenClass:Class = _screenDictionary[name];
			
			_currentScreen = new ScreenClass();
			_currentScreen.onShow();
			screenParent.addChild(_currentScreen as DisplayObject);
		}
        
        /**
         * @private
         */  
        public function onFrame(elapsed:Number):void
        {
            if(_currentScreen)
                _currentScreen.onFrame(elapsed);
        }
        
        /**
         * @private
         */  
        public function onTick(tickRate:Number):void
        {
            if(_currentScreen)
                _currentScreen.onTick(tickRate);
        }
		
		public function get currentScreen():IScreen
		{
			return _currentScreen;
		}
        
        /**
		 * 这是 screens 被加入和移除的容器。通常它被加入到 Global.mainClass中，
		 * 但某些情况你可能想去覆盖它。
         */ 
        public var screenParent:DisplayObjectContainer = null;

        private var _currentScreen:IScreen = null;
        private var _screenDictionary:Dictionary = new Dictionary();
    }
}