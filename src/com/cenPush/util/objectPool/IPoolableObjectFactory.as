package com.cenPush.util.objectPool
{
	public interface IPoolableObjectFactory
	{
		function makeObject():IPoolableObject;
		function destroyObject(obj:IPoolableObject):void;
		function validateObject(obj:IPoolableObject):Boolean;
		function activeObject(obj:IPoolableObject):void;
		function passivateObject(obj:IPoolableObject):void;
	}
}