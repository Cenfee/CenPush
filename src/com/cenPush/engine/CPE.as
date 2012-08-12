package com.cenPush.engine
{
	import br.com.stimuli.loading.BulkLoader;
	
	import com.cenPush.engine.core.ProcessManager;
	import com.cenPush.engine.resource.ResourceManager;
	import com.cenPush.screens.ScreenManager;
	import com.cenPush.sound.SoundManager;
	
	import flash.display.Stage;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class CPE
	{
		static public var processManager:ProcessManager;
		static public var screenManager:ScreenManager;
		static public var resourceManager:ResourceManager;
		static public var soundManager:SoundManager;
		
		static public var mainSprite:Sprite;
	
		public function CPE()
		{
		}
		
		static public function startup(mainSprite:Sprite):void
		{
			CPE.mainSprite = mainSprite;
			
			soundManager = new SoundManager();
			processManager = new ProcessManager();
			screenManager = new ScreenManager();
			resourceManager = new ResourceManager();
			
		}
		
		static public function destroy():void
		{
			if(processManager)
			{
				processManager.destroy();
				processManager = null;
			}
			
			if(screenManager)
			{
				screenManager = null;		
			}
			
			if(resourceManager)
			{
				resourceManager = null;
			}
			
			if(soundManager)
			{
				soundManager.stopAll();
				soundManager = null;
			}
			
			mainSprite.removeChildren(0, -1, true);
			mainSprite.dispose();
			mainSprite = null;
			BulkLoader.removeAllLoaders();
		}
		
		static public function get nativeStage():Stage
		{
			return Starling.current.nativeStage;
		}
	}
}