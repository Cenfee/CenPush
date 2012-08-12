package com.cenPush.util.stateMachine
{
    public interface IThinkingState extends IState
    {
		function getDuration(fsm:IMachine):int;
        function getTimeForNextTick(fsm:IMachine):int;
    }
}