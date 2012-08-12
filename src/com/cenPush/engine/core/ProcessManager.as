package com.cenPush.engine.core
{
    import com.cenPush.engine.CPE;
    import com.cenPush.engine.CPEUtil;
    import com.cenPush.engine.debug.Logger;
    
    import flash.utils.getTimer;
    
    import starling.events.Event;
    
    
    /**
	 * 程序运行管理器，关联引擎的所以时间。
	 * 提供了每帧、每点动画机制，或者寻找将来的特定时间
     * 
     * <p>每点将会以一定的间隔调用，间隔由TICKS_PER_SECOND常量来定义，
	 * 基于点来实现会有更加一致的输出，基于帧实现动画，可以有更加平滑的效果。</p>
	 * 
     * @see ITickedObject
     * @see IAnimatedObject
     */
    public class ProcessManager
    {
        /**
		 * 如果设置为true，丢失点时就不会有警告。
         */
        public static var disableSlowWarning:Boolean = true;
        
        /**
		 * 每秒 点的数量。
         */
        public static const TICKS_PER_SECOND:int = 30;
        
        /**
		 * 点触发的帧数。
         */
        public static const TICK_RATE:Number = 1.0 / Number(TICKS_PER_SECOND);
        
        /**
		 * 使用毫秒表示的点触发的帧数
         */
        public static const TICK_RATE_MS:Number = TICK_RATE * 1000;
        
        /**
		 * 每帧最多可以触发 的点数。
         * 
         * <p>有时候，帧调用的时间会很长。触发的点过多，会使得相互间进入一个
		 * 不可控的漩涡。</p>
         * 
         * <p>防止这个，可以设置一个安全限制，使得这个可控，如果你的游戏很慢，
		 * 那么你可以看看ProcessManager是否提示没帧调用的ticks过多了的警告。
		 * disableSlowWarning 需设置为false.</p>
         */
        public static const MAX_TICKS_PER_FRAME:int = 5;
        
        /**
		 * 时间的缩放。如果设置为2，则游戏速度会增加两倍。
         */
        public function get timeScale():Number
        {
            return _timeScale;
        }
        
        /**
         * @private
         */
        public function set timeScale(value:Number):void
        {
            _timeScale = value;
        }
        
        /**
		 * 指示在 触发点 之间的位置，0表示在开始，1表示在末尾。
		 * 这样可以实现平滑地插入动画元素。
         */
        public function get interpolationFactor():Number
        {
            return _interpolationFactor;
        }
        
        /**
		 * 进程管理器所经历的时间，这个会计算 timeScale 属性。毫秒表示。
         */
        public function get virtualTime():Number
        {
            return _virtualTime;
        }
        
        /**
		 * 当前的时间(getTimer())，每帧更新。使用这个防止频繁地调用getTimer(),或者如果你
		 * 想使用一个特定的数字表示当前的帧。
         */
        public function get platformTime():Number
        {
            return _platformTime;
        }
        
        /**
		 * 启动这个进程管理器。当第一个对象被加入进程管理器时，它就会自动被调用。
		 * 如果这个管理器手动停止了，那么可以调用这个函数来重新启动。
         */
        public function start():void
        {
            if (started)
            {
                Logger.warn(this, "start", "The ProcessManager is already started.");
                return;
            }
            
            lastTime = -1.0;
            elapsed = 0.0;
			CPE.mainSprite.addEventListener(Event.ENTER_FRAME, onFrame);
            started = true;
        }
        
        /**
		 * 停止进程管理器。如果最后一个对象被移动时，这个函数将会被自动调用，但是也可以
		 * 手动去调用，举个例子，暂停这个游戏。
         */
        public function stop():void
        {
            if (!started)
            {
                Logger.warn(this, "stop", "The ProcessManager isn't started.");
                return;
            }
            
            started = false;
            CPE.mainSprite.removeEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        /**
		 * 如果进程管理器正在运行，则返回正确。
         */ 
        public function get isTicking():Boolean
        {
            return started;
        }
        
        /**
		 * 在将来某个特定的时间调用一个函数。
         * 
		 * @param delay 延迟调用的毫秒数。
		 * @param thisObject 调用函数的this指向。
		 * @param callback 调用的函数。
		 * @param ...arguments 传递给被调用函数的参数列表。
         */
        public function schedule(delay:Number, thisObject:Object, callback:Function, ...arguments):void
        {
            if (!started)
                start();
            
            var schedule:ScheduleObject = new ScheduleObject();
            schedule.dueTime = _virtualTime + delay;
            schedule.thisObject = thisObject;
            schedule.callback = callback;
            schedule.arguments = arguments;

            thinkHeap.enqueue(schedule);
        }
        
        /**
		 * 加入一个对象，接受帧的回调。
         * 
		 * @param object   被加入的对象。
		 * @param priority 对象的优先级。对象以更高优先级加入，将会被加入到低优先级的前面。
		 * 最高的优先级可达Number.MAX_VALUE。最低优先级可达-Number.MAX_VALUE.
         */
        public function addAnimatedObject(object:IAnimatedObject, priority:Number = 0.0):void
        {
            addObject(object, priority, animatedObjects);
        }
        
        /**
		 * 加入一个对象，接受触发点的回调。
         * 
		 * @param object 被加入的对象。
		 * @param priority 对象的优先级。对象以更高优先级加入，将会被加入到低优先级的前面。
		 * 最高的优先级可达Number.MAX_VALUE。最低优先级可达-Number.MAX_VALUE.
         */
        public function addTickedObject(object:ITickedObject, priority:Number = 0.0):void
        {
            addObject(object, priority, tickedObjects);
        }
        
        /**
		 * 使一个 IQueuedObject 进入队列，等待回调。这是一个非常方便廉价的方法去回调一个函
		 * 数。如果对象已经在队列中，就会被移除，重新再加入。
		 * 
         */
        public function queueObject(object:IQueuedObject):void
        {
            // Assert if this is in the past.
            if(object.nextThinkTime < _virtualTime)
                throw new Error("Tried to queue something into the past, but no flux capacitor is present!");
            
            //Profiler.enter("queueObject");
            
            if(object.nextThinkTime >= _virtualTime && thinkHeap.contains(object))
                thinkHeap.remove(object);
            
            thinkHeap.enqueue(object);
            
            //Profiler.exit("queueObject");
        }
        
        /**
		 * 移除一个帧回调对象。
         * 
         * @param object 将会被移除的对象。
         */
        public function removeAnimatedObject(object:IAnimatedObject):void
        {
            removeObject(object, animatedObjects);
        }
        
        /**
		 * 移除一个触发点回调对象。
         * 
         * @param object 被移除的对象。
         */
        public function removeTickedObject(object:ITickedObject):void
        {
            removeObject(object, tickedObjects);
        }
        
        /**
         * 强迫进程管理器 提前指定的时间数量。这个应该被使用在单元测试。
         * 
         * @param amount 提前的时间数量。
         */
        public function testAdvance(amount:Number):void
        {
            advance(amount * _timeScale, true);
        }
        
        /**
		 * 直接给进程管理器的virtualTime加上指定的时间。
		 * 这个不会调用advance()。
		 * 警告：如果你不知道调用它的后果，请不要使用。
         */
        public function seek(amount:Number):void
        {
            _virtualTime += amount;
        }
        
        /**
		 * 延迟函数的调用 - 在下一帧再调用。这是一个廉价的方法，有时可以代替setTimeout(someFunc, 1);
		 * 
         * @param method 调用的方法。
         * @param args 任何参数。
         */
        public function callLater(method:Function, args:Array = null):void
        {
            var dm:DeferredMethod = new DeferredMethod();
            dm.method = method;
            dm.args = args;
            deferredMethodQueue.push(dm);
        }
        
        /**
		 * @return 现在有多少对象是依赖 ProcessManager。
         */
        private function get listenerCount():int
        {
            return tickedObjects.length + animatedObjects.length;
        }
        
        /**
		 * 包内函数，一指定的优先级加入一个对象到一个list中。
		 * 
         * @param object 被加入的对象。
         * @param priority 优先级，这个用来被list进行优先排序.
         * @param list 被加入的list.
         */
        private function addObject(object:*, priority:Number, list:Array):void
        {
			// 如果正在进行 触发点事件的处理,那么延迟加入.
            if(duringAdvance)
            {
                callLater(addObject, [ object, priority, list]);
                return;
            }
           
            if (!started)
                start();
            
            var position:int = -1;
            for (var i:int = 0; i < list.length; i++)
            {
                if(!list[i])
                    continue;
                
                if (list[i].listener == object)
                {
                    Logger.warn(object, "AddProcessObject", "This object has already been added to the process manager.");
					return;
                }
                
                if (list[i].priority < priority)
                {
                    position = i;
                    break;
                }
            }
            
            var processObject:ProcessObject = new ProcessObject();
            processObject.listener = object;
            processObject.priority = priority;
            //processObject.profilerKey = TypeUtility.getObjectClassName(object);
            
            if (position < 0 || position >= list.length)
                list.push(processObject);
            else
                list.splice(position, 0, processObject);
        }
        
        /**
		 * 从list 中移除一个对象。
		 * 
         * @param object 被移除的对象。
         * @param list  需要被移除对象的list.
         */
        private function removeObject(object:*, list:Array):void
        {
            if (listenerCount == 1 && thinkHeap.size == 0)
                stop();
            
            for (var i:int = 0; i < list.length; i++)
            {
                if(!list[i])
                    continue;
                
                if (list[i].listener == object)
                {
                    if(duringAdvance)
                    {
                        list[i] = null;
                        needPurgeEmpty = true;
                    }
                    else
                    {
                        list.splice(i, 1);                        
                    }
                    
                    return;
                }
            }
            
            Logger.warn(object, "RemoveProcessObject", "This object has not been added to the process manager.");
        }
        
        /**
		 * 主要的回调函数;这个会被每帧调用并且允许游戏逻辑去运行.
         */
        private function onFrame(event:Event):void
        {
            // This is called from a system event, so it had better be at the 
            // root of the profiler stack!
            //Profiler.ensureAtRoot();
            
            // 当前时间.
            var currentTime:Number = getTimer();
            if (lastTime < 0)
            {
                lastTime = currentTime;
                return;
            }
            
			//计算从上帧的时间,并把进程推进这个时间.
            var deltaTime:Number = Number(currentTime - lastTime) * _timeScale;
            advance(deltaTime);
            
			//记录新的lastTime;
            lastTime = currentTime;
        }
        
        private function advance(deltaTime:Number, suppressSafety:Boolean = false):void
        {
			//更新platformTime, 防止大量的getTimer操作。
            _platformTime = getTimer();
            
			//记录virtulTime, 我们advance的开始。
            var startTime:Number = _virtualTime;
            
			//把时间加入到累加器中。
            elapsed += deltaTime;
            
			//执行 触发点的 处理。
            var tickCount:int = 0;
            while (elapsed >= TICK_RATE_MS && (suppressSafety || tickCount < MAX_TICKS_PER_FRAME))
            {
				//重置Tick开始点。
                _interpolationFactor = 0.0;
                
				//调用已安排预期调用的对象。
				//这个将会循环地调用，确保正确的事件顺序。
                processScheduledObjects();
                
                // Do the onTick callbacks, noting time in profiler appropriately.
                //Profiler.enter("Tick");
                
                duringAdvance = true;
                for(var j:int=0; j<tickedObjects.length; j++)
                {
                    var object:ProcessObject = tickedObjects[j] as ProcessObject;
                    if(!object)
                        continue;
                    
                    //Profiler.enter(object.profilerKey);
                    (object.listener as ITickedObject).onTick(TICK_RATE);
                    //Profiler.exit(object.profilerKey);
                }
                duringAdvance = false;
                
                //Profiler.exit("Tick");
                
				//更新现实的时间，通过在累加器中相减。
                _virtualTime += TICK_RATE_MS;
                elapsed -= TICK_RATE_MS;
                tickCount++;
            }
            
			//安全控制 - 每帧不要调用超过一定量的ticks，防止死循环。
            if (tickCount >= MAX_TICKS_PER_FRAME && !suppressSafety && !disableSlowWarning)
            {
				//默认，仅仅概要分析时展示
				Logger.warn(this, "advance", "Exceeded maximum number of ticks for frame (" + elapsed.toFixed() + "ms dropped) .");
                elapsed = 0;
            }
            
			// 确保我们不会落后都太远了。确保短期的帧速率下降，也不会影响太大。
            elapsed = CPEUtil.clamp(elapsed, 0, 300);            
            
            // Make sure we don't lose time to accumulation error.
            // Not sure this gains us anything, so disabling -- BJG
            //_virtualTime = startTime + deltaTime;
            
            // We process scheduled items again after tick processing to ensure between-tick schedules are hit
            // Commenting this out because it can cause too-often calling of callLater methods. -- BJG
            // processScheduledObjects();
            
            // Update objects wanting OnFrame callbacks.
            //Profiler.enter("frame");
            duringAdvance = true;
            _interpolationFactor = elapsed / TICK_RATE_MS;
            for(var i:int=0; i<animatedObjects.length; i++)
            {
                var animatedObject:ProcessObject = animatedObjects[i] as ProcessObject;
                if(!animatedObject)
                    continue;
                
                //Profiler.enter(animatedObject.profilerKey);
                (animatedObject.listener as IAnimatedObject).onFrame(deltaTime / 1000);
                //Profiler.exit(animatedObject.profilerKey);
            }
            duringAdvance = false;
            //Profiler.exit("frame");

            // 如果需要的话，清空列表。
            if(needPurgeEmpty)
            {
                needPurgeEmpty = false;
                
                //Profiler.enter("purgeEmpty");
                
                for(j=0; j<animatedObjects.length; j++)
                {
                    if(animatedObjects[j])
                        continue;
                    
                    animatedObjects.splice(j, 1);
                    j--;
                }
                
                for(var k:int=0; k<tickedObjects.length; k++)
                {                    
                    if(tickedObjects[k])
                        continue;
                    
                    tickedObjects.splice(k, 1);
                    k--;
                }

                //Profiler.exit("purgeEmpty");
            }
            
            //Profiler.ensureAtRoot();
        }
        
        private function processScheduledObjects():void
        {
			//调用延迟的方法。
            var oldDeferredMethodQueue:Array = deferredMethodQueue;
            if(oldDeferredMethodQueue.length)
            {
                //Profiler.enter("callLater");

				//重置的延迟调用的数组。同时暂时不能破坏数组结构。
                deferredMethodQueue = [];
                
                for(var j:int=0; j<oldDeferredMethodQueue.length; j++)
                {
                    var curDM:DeferredMethod = oldDeferredMethodQueue[j] as DeferredMethod;
                    curDM.method.apply(null, curDM.args);
                }
                
				// 结束处理，清除旧的数组缓存。
                oldDeferredMethodQueue.length = 0;

                //Profiler.exit("callLater");      	
            }

            // Process any queued items.
			//
            if(thinkHeap.size)
            {
                //Profiler.enter("Queue");
                
                while(thinkHeap.front && thinkHeap.front.priority >= -_virtualTime)
                {
                    var itemRaw:IPrioritizable = thinkHeap.dequeue();
                    var qItem:IQueuedObject = itemRaw as IQueuedObject;
                    var sItem:ScheduleObject = itemRaw as ScheduleObject;
                    
                    //var type:String = TypeUtility.getObjectClassName(itemRaw);
                    
                    //Profiler.enter(type);
                    if(qItem)
                    {
						//检查是否为空，为空，表示没有注册。
                        if(qItem.nextThinkCallback != null)
                            qItem.nextThinkCallback();
                    }
                    else if(sItem && sItem.callback != null)
                    {
                        sItem.callback.apply(sItem.thisObject, sItem.arguments);                    
                    }
                    else
                    {
                        throw new Error("Unknown type found in thinkHeap.");
                    }
                    //Profiler.exit(type);                    
                    
                }
                
                //Profiler.exit("Queue");                
            }
        }
		
		public function destroy():void
		{
			stop();
		}
		
        protected var deferredMethodQueue:Array = [];
        protected var started:Boolean = false;
        protected var _virtualTime:int = 0.0;
        protected var _interpolationFactor:Number = 0.0;
        protected var _timeScale:Number = 1.0;
        protected var lastTime:int = -1.0;
        protected var elapsed:Number = 0.0;
        protected var animatedObjects:Array = new Array();
        protected var tickedObjects:Array = new Array();
        protected var needPurgeEmpty:Boolean = false;
        
        protected var _platformTime:int = 0;
        
        protected var duringAdvance:Boolean = false;
        
        protected var thinkHeap:SimplePriorityQueue = new SimplePriorityQueue(1024);
    }
}

final class ProcessObject
{
    public var profilerKey:String = null;
    public var listener:* = null;
    public var priority:Number = 0.0;
}

final class DeferredMethod
{
    public var method:Function = null;;
    public var args:Array = null;
}