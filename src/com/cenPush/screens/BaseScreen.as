package com.cenPush.screens
{
	import starling.display.Sprite;

    /**
	 * 对 IScreen 最基本的实现。你会可以需要使用一个子类。
     */
	public class BaseScreen extends Sprite implements IScreen
	{
		public function onShow():void
		{
		}
		
		public function onHide():void
		{
		}
		
		public function onFrame(delta:Number):void
		{
		}
		
		public function onTick(delta:Number):void
		{
		}
	}
}