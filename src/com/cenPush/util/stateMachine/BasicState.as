package com.cenPush.util.stateMachine
{
	import flash.events.Event;
	
	/**
	 * Simple state that allows for generic transition rules.
	 * 
	 * This tries each transition in order, and takes the first one that
	 * evaluates to true and that succesfully changes state.
	 * 
	 * More complex state behavior can probably be derived from this class.
	 */
	public class BasicState implements IState
	{
		/**
		 * List of subclasses of ITransition that are evaluated to transition to
		 * new states.
		 */ 
		[TypeHint(type="com.cenPush.util.stateMachine.ITransition")]
		public var transitions:Array = new Array();
		
		/**
		 * If we want an event to be fired on the container when this state is
		 * entered, it is specified here.
		 */ 
		public var enterEvent:String = null;
		
		public function addTransition(t:ITransition):void
		{
			transitions[transitions.length] = t;
		}
		
		public function tick(fsm:IMachine):void
		{
			// evaluate transitions in order until one goes.
			for each(var t:ITransition in transitions)
			{
				//Logger.print(this, "Evaluating transition '" + t); 
				if(t.evaluate(fsm) && fsm.setCurrentState(t.getTargetState()))
					return;
			}
		}
		
		public function enter(fsm:IMachine):void
		{
		}
		
		public function exit(fsm:IMachine):void
		{
			// NOP.
		}
	}
}