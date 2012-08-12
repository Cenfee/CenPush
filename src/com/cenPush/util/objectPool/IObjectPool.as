package com.cenPush.util.objectPool
{
	public interface IObjectPool
	{
		function borrowObject():IPoolableObject;
		function returnObject(obj:IPoolableObject):void;
		function invalidateObject(obj:IPoolableObject):void;
		function addObject(obj:IPoolableObject):void;
		function getNumIdle():int;
		function getNumActive():int;
		function clear():void;
		function close():void;
		function setFactory(factory:IPoolableObjectFactory):void;
	}
}