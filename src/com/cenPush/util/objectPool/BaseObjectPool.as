package com.cenPush.util.objectPool
{

	public class BaseObjectPool implements IObjectPool
	{
		protected var ObjectClass:Class;
		protected var _max:int;
		protected var _initSize:int;
		
		protected var _poolableObjectFactory:BasePoolableObjectFactory;
		protected var _objectList:Vector.<IPoolableObject>;
		
		public function BaseObjectPool(ObjectClass:Class, max:int, initSize:int=0)
		{
			this.ObjectClass = ObjectClass;
			_max = max;
			_initSize = initSize;

			if(_initSize > _max) 
				_initSize = _max;
			
			setFactory(new BasePoolableObjectFactory(ObjectClass));
			
			_objectList = new Vector.<IPoolableObject>();
			for(var i:int = 0; i < _initSize; i++)
			{
				_objectList.push(_poolableObjectFactory.makeObject());
			}
		}
		
		public function borrowObject():IPoolableObject
		{
			var object:IPoolableObject = _objectList.shift();
			if(!object)
				_poolableObjectFactory.makeObject();
			
			_poolableObjectFactory.activeObject(object);
			return object;
		}
		
		public function returnObject(obj:IPoolableObject):void
		{
			_poolableObjectFactory.passivateObject(obj);
			if(_objectList.length < _max)
			{
				
				_objectList.push(obj);
			}
			else
			{
				_poolableObjectFactory.destroyObject(obj);
			}
		}
		
		public function invalidateObject(obj:IPoolableObject):void
		{
			_poolableObjectFactory.passivateObject(obj);
		}
		
		public function addObject(obj:IPoolableObject):void
		{
			throw new Error("使用borrowOject代替");
		}
		
		public function getNumIdle():int
		{
			return _objectList.length;
		}
		
		public function getNumActive():int
		{
			return 0;
		}
		
		public function clear():void
		{
			_objectList.length = 0;
		}
		
		public function close():void
		{
			clear();
			
			_objectList = null;
			_poolableObjectFactory = null;
		}
		
		public function setFactory(factory:IPoolableObjectFactory):void
		{
			_poolableObjectFactory = BasePoolableObjectFactory(factory);
		}
	}
}