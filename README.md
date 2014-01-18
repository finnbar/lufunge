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

<pre>
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
</pre>

for example code please consult main.lua
