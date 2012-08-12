package com.cenPush.engine.core
{
    import flash.utils.Dictionary;	
    
    /**
     * 一个权限队列去管理权限数据。
     * 这个是根据堆结构实现。
     * 
     * <p>实现基于 as3ds PriorityHeap.</p>
     */
    public class SimplePriorityQueue
    {
        private var _heap:Array;
        private var _size:int;
        private var _count:int;
        private var _posLookup:Dictionary;
        
        /**
         * 初始化权限队列，指定队列的大小。
         * 
         * @param size 权限队列的大小.
         */
        public function SimplePriorityQueue(size:int)
        {
            _heap = new Array(_size = size + 1);
            _posLookup = new Dictionary(true);
            _count = 0;
        }
        
        /**
		 * 最前面的子项，如果堆为空，则返回空。
         */
        public function get front():IPrioritizable
        {
            return _heap[1];
        }
        
        /**
         * 最大的容量。
         */
        public function get maxSize():int
        {
            return _size;
        }
        
        /**
         * 加入一个权限子项。
         * 
         * @param obj 权限子项数据.
         * @return 如果没有满则返回true.
         */
        public function enqueue(obj:IPrioritizable):Boolean
        {
            if (_count + 1 < _size)
            {
                _count++;
                _heap[_count] = obj;
                _posLookup[obj] = _count;
                walkUp(_count);
                return true;
            }
            return false;
        }
        
        /**
		 * 解除最前面并返回子项。
		 * 这个子项就是最高权限的子项。
         * 
         * @return 权限最高的子项.
         */
        public function dequeue():IPrioritizable
        {
            if (_count >= 1)
            {
                var o:* = _heap[1];
                delete _posLookup[o];
                
                _heap[1] = _heap[_count];
                walkDown(1);
                
                delete _heap[_count];
                _count--;
                return o;
            }
            return null;
        }
        
        /**
         * 变更优先级.
         * 
         * @param obj         需要改变权限的对象.
         * @param newPriority 新的权限.
         * @return True 	  变更成功更返回true.
         */
        public function reprioritize(obj:IPrioritizable, newPriority:int):Boolean
        {
            if (!_posLookup[obj]) return false;
            
            var oldPriority:int = obj.priority;
            obj.priority = newPriority;
            var pos:int = _posLookup[obj];
            newPriority > oldPriority ? walkUp(pos) : walkDown(pos);
            return true;
        }
        
        /**
         * 移除一个权限子项.
         * 
         * @param obj 	需要移除的子项.
         * @return True 如果移除成功返回true.
         */
        public function remove(obj:IPrioritizable):Boolean
        {
            if (_count >= 1)
            {
                var pos:int = _posLookup[obj];
                
                var o:* = _heap[pos];
                delete _posLookup[o];
                
                _heap[pos] = _heap[_count];
                
                walkDown(pos);
                
                delete _heap[_count];
                delete _posLookup[_count];
                _count--;
                return true;
            }
            
            return false;
        }
        
        /**
         * @inheritDoc
         */
        public function contains(obj:*):Boolean
        {
            for (var i:int = 1; i <= _count; i++)
            {
                if (_heap[i] === obj)
                    return true;
            }
            return false;
        }
        
        /**
         * @inheritDoc
         */
        public function clear():void
        {
            _heap = new Array(_size);
            _posLookup = new Dictionary(true);
            _count = 0;
        }
        
        /**
         * @inheritDoc
         */
        public function get size():int
        {
            return _count;
        }
        
        /**
         * @inheritDoc
         */
        public function isEmpty():Boolean
        {
            return _count == 0;
        }
        
        /**
         * @inheritDoc
         */
        public function toArray():Array
        {
            return _heap.slice(1, _count + 1);
        }
        
        /**
         * 字符串显示.
         * 
         * @return 返回的字符串.
         */
        public function toString():String
        {
            return "[SimplePriorityQueue, size=" + _size +"]";
        }
        
        /**
         * 输出所有子项的字符串显示(仅仅是为debug或者demo).
         */
        public function dump():String
        {
            if (_count == 0) return "SimplePriorityQueue (empty)";
            
            var s:String = "SimplePriorityQueue\n{\n";
            var k:int = _count + 1;
            for (var i:int = 1; i < k; i++)
            {
                s += "\t" + _heap[i] + "\n";
            }
            s += "\n}";
            return s;
        }
        
        private function walkUp(index:int):void
        {
            var parent:int = index >> 1;
            var parentObj:IPrioritizable;
            
            var tmp:IPrioritizable = _heap[index];
            var p:int = tmp.priority;
            
            while (parent > 0)
            {
                parentObj = _heap[parent];
                
                if (p - parentObj.priority > 0)
                {
                    _heap[index] = parentObj;
                    _posLookup[parentObj] = index;
                    
                    index = parent;
                    parent >>= 1;
                }
                else break;
            }
            
            _heap[index] = tmp;
            _posLookup[tmp] = index;
        }
        
        private function walkDown(index:int):void
        {
            var child:int = index << 1;
            var childObj:IPrioritizable;
            
            var tmp:IPrioritizable = _heap[index];
            var p:int = tmp.priority;
            
            while (child < _count)
            {
                if (child < _count - 1)
                {
                    if (_heap[child].priority - _heap[int(child + 1)].priority < 0)
                        child++;
                }
                
                childObj = _heap[child];
                
                if (p - childObj.priority < 0)
                {
                    _heap[index] = childObj;
                    _posLookup[childObj] = index;
                    
                    _posLookup[tmp] = child;
                    
                    index = child;
                    child <<= 1;
                }
                else break;
            }
            _heap[index] = tmp;
            _posLookup[tmp] = index;
        }
    }
}