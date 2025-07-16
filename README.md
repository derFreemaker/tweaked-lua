# tweaked-lua
This is Lua 5.4.8, released on 21 May 2025.

# tweaks

## debug.gethook
Always returns a function also by external hooks.
Type: function(event, new_line, debug_ptr) : void

## debug.sethook
Will invoke the given function with a third argument the debug_ptr which is the samething a c hook would get.
This is required to invoke wraped c hooks retrived from `debug.gethook()`.

## coroutine.yieldafterinstructions
Can be given a thread as first parameter to specify the intended thread.
Will queue the thread to yield after the specific amount of lua instructions have been executed.
Calling with with 0 as arguments will remove the yield.

