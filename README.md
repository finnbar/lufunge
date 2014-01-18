lufunge
=======

a funge for lua! (a funge is a 2d programming language)


what's this for?
=======

it's for crazy people that like to write programming languages in a very difficult way! yay me!


ok, how do I use this?
======

run lufungeInit(code) and then luafungeStep() for each step.
lufunge code should probably be put into [[]] to have to avoid escaping the backslashes.

these are the individual commands and an explanation of how to use this (copied from main.lua):

<code>
--[[
  NOTE TO SELF: good idea -> a lang that you give the start and end to, and it works out the process.

  LuFunge: A Lua Funge Compiler Thingy.
  Simply put:
¬ @     start location, where a pointer can begin. will always start by going right. if another pointer hits it @ acts like >
¬ <^>v  four directions, go in that direction
¬ /     trigger: if "true" is carried turn right else turn left
¬ \     reverse trigger: if "true" is carried turn left else turn right
¬ ?     if false, kill this pointer. useful for ending the program
¬ !     reverse the pointer (if it would be true, explicitly set it to false, else if it is false or nil, make it true)
¬ 0-9   make the pointer equal to that value
¬ ;     sync: wait until another pointer has reached another one of these, then go
¬ |     jump: if given "true", jump to next one IN LINE (e.g. would skip ab: |ab|)
¬ +     increment pointer by next var
¬ -     decrement pointer by next var
¬ =     set next variable to pointer
¬ #     check if pointer is equal to next variable, and change pointer to true/false based on that
¬ .     print pointer
¬ %     modulus pointer with next var
¬ *     multiply pointer by next var
¬ $     divide pointer by next var
¬ "     assume everything is a string literal rather than a command until the next " (side effect: pointer is cleared)
¬ ~     lua code is contained in the tildas
¬ £     to the power of
¬ ]     greater than (changes pointer to true if so)
¬ [     less than

  Anything else:
  if a reference to a function, do it!
  if a variable, pointer equals it!
  if a variable AND there was an = before it, variable equals pointer!
  
  Example code:

  ~a,b,c = run(), check(), find()~

  >0!?
  c@av
  \bc<
  b
  >0!?

  this code would execute a(), go down, go left, execute b(). c() then if the pointer has a "true" value it will execute c() else b(). then it will make the pointer equal 0 and reverse that (so true -> false), and then quit as the ? is given a false. now for more example code!:

  ~a,b,c,d,e,p = run(), compare(), check(), false, 0, "0"~

  @4a;b;|0!?| v
  @4; b;p|0!?|v
  ^           <

  function compare(arg,point) if d then if arg==e return true else p=false return false end else e=arg p=true d=true end --in short, first pointer to run this records its value as e. second pointer compares its value with e and returns true if they are the same

  this example code starts two _pointers with 4 and then makes one of them run a(). then they both run b(), and if they are the same, p becomes true, so the second pointer returns true. if they are true, they jump over the 0!? (aka quit the program) and loop! however, this program can be written better with more advanced symbols:

  ~a,b,c = run(),0,false~

  @4a     ;v
           =
  @4;     #b=c;|0!?|v
           >;c|0!?| v
  ^                 <

  this starts with two pointers, executes a() on one of them and then records the result as b ("=b"), then the second one checks b and records that value as c ("#b=c"), then kills the program if that is false. then the second pointer is set to c, and if that is false, the second pointer is killed, else they loop back to the start.
]]
</code>