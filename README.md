# tweaked-lua
This is Lua 5.4.8, released on 21 May 2025.

# tweaks

## debug.gethook(co?)
Always returns a function also by external hooks.

function type: `function(event, new_line, debug_ptr) : void`

## debug.sethook(co?, hook, mask, count)
Will invoke the given function with a third argument the debug_ptr which is the samething a c hook would get.
This is required to invoke wrapped c hooks returned from `debug.gethook()`.

## coroutine.yieldafterinstructions(co?, instructions_count)
Can be given a thread as first parameter to specify the intended thread.
Will queue the thread to yield after the specific amount of lua instructions have been executed.
Invoking with `instructions_count` set as `0` will remove the yield.
