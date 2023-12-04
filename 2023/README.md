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
