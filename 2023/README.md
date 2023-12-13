# Advent of Code: 2023

Now feeling slightly more ~overconfident~ _comfortable_ with Advent of Code, I am going to try it in a new-to-me
language this time: [Lua]!

Motivation is equal parts it is kind-of applicable (for scripting [NeoVim], [nginx (via OpenResty)], etc.) and it looks
fun to use [LÖVE].

[Lua]: https://www.lua.org/

[NeoVim]: https://neovim.io/doc/user/lua.html

[nginx (via OpenResty)]: https://github.com/openresty/lua-nginx-module#readme

[LÖVE]: https://www.love2d.org/

## Notes

- Version (`lua -v`): Lua 5.4.6
- Formatter: StyLua

## Notes on Lua

### Day 1

- There's no POSIX regex?
- Regex implementation _seems_ to vary by function?
    - Or at least, I couldn't get `.-` to work in `string.gfind`
- Multiple return hurts my brain

### Day 2

- There's no `string.split`???
- Tables are... interesting. Elegant but also hurt my brain.
    - Reminds me of PHP "arrays"

### Day 3

- There's no simple enumeration?
    - This one is less bothersome - can do a `for i = 1, #width` or a `for l in lines do` + `i = i + 1`
    - That being said it makes nested loops a bit more complex
- Okay, now... I start to miss other handy features from other languages
    - The lack of convenience methods isn't insurmountable
    - Every piece of code has a few more lines of boilerplate
- That being said... dang, Lua is _fast_!
    - According to hyperfine, solving day three (and the examples) takes... 21.8ms!

### Day 4

- There's no sets? Well, no built-in sets
- Instead: use a table with the keys as your items, and the values as `true`
    - I am told this is how Awk and Perl, languages that scare me, also did it
    - Ditto again for versions of Java older than I am

### Day 5

- Parsing in complex input: I need to think harder about how to do this well.

### Day 6

- Parallel iteration: Not there!
- Today's input is exactly two lists of integers
- What I want is to read the first of each list together
    - In Python terms, zip two lists together
- This isn't really directly achievable
- I could've made a table of tables
- Instead, I made two tables and iterated through them by increment

## Day 7

- Today, in "Lua doesn't have" default arguments
    - Man that would be nice to have for setting flags on Part 2

### Day 8

- Getting enough of my sea legs to no longer be flapped by odd lua behaviour
- Now observing second patterns I didn't in my first observations
- First among them:
    - Never, ever write an else case
    - Write if / elseif / elseif / etc. to match _all known cases_
    - Throw an error if you get to `else`!

### Day 9

- Today is the first day wherein the mutability of tables tripped me up
    - Perhaps I am getting lazy with my creation / management of them?
    - Tables are mutable within functions.
    - Need to determine how to copy instead of loading input once for each part

### Day 10

- Today is the day I give in: I need my creature comforts of non-Table data classes
    - Implemented a rudimentary `set` class (in `set.lua`) to track members of the loop
    - I have already implemented it once
    - Might as well do it once _well_ instead of repeating until I make an error
- Somehow in Part 1 I committed an excellent error
    - That then worked until part 2

### Day 11

- Today is the first day I really had to twist my brain
    - The offset business meant I could not just return to the standard "mapping of points"
    - Instead I needed to track the actual integer points so I could track their offsets

## Day 12

- Finally got the hang of Lua Regular Expressions, kinda
    - Part 1: Use the fact that Lua is fast-ish to brute force
    - Now I'm hooped for part 2...