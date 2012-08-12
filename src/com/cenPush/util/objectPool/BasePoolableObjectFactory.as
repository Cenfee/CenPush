package com.cenPush.util.objectPool
{
	public class BasePoolableObjectFactory implements IPoolableObjectFactory
	{
		protected var ObjectClass:Class;
		
		public function BasePoolableObjectFactory(ObjectClass:Class)
		{
			this.ObjectClass = ObjectClass;
		}
		
		public function makeObject():IPoolableObject
		{
			var object:IPoolableObject = new ObjectClass();
			return object;
		}
		public function destroyObject(obj:IPoolableObject):void
		{
			obj.destroy();
		}
		public function validateObject(obj:IPoolableObject):Boolean
		{
			return true;
		}
		
		public function activeObject(obj:IPoolableObject):void
		{
			obj.active();
		}
		
		public function passivateObject(obj:IPoolableObject):void
		{
			obj.passivate();
		}
			
		
	}
}