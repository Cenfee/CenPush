package com.cenPush.util.objectPool
{
	public interface IPoolableObject
	{
		function destroy():void;
		function active():void;
		function passivate():void;
	}
}