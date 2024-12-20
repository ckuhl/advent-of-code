# Advent of Code 2024

Just doing Python (3.13, the latest stable release), for fun.

I don't have any concrete plans for any specific challenges / approaches I want to take.
I do have some ideas, such as:

- Developing solutions exclusively in a REPL
- Modularizing / extracting as much as possible
- Really focusing on tooling and reproducibility

This year I am also fixing-forward hiding my problem inputs for this year based on [the about page] that I missed in
previous years (oops):
> If you're posting a code repository somewhere, please don't include parts of Advent of Code like the puzzle text or
> your inputs.

[the about page]: https://adventofcode.com/2024/about

I suppose I also don't need to include test cases, as they can be found from the associated answer the problem text
describes.

## Daily Thoughts

### Day 1

- Solving the problem, relatively easy.
    - Writing coherent code? Harder.
    - The biggest challenge is code-golfing the earlier days, yo-yoing between different definitions of good
- So instead I'll stand up some tooling:
    - I'm going to use [uv] for package management
    - [ruff] for linting and formatting
    - [unittest] is still satisfactory for my use case for running the actual code
    - And, of course, the classic make for managing the project

### Day 2

- The second part of this felt like one of "there has got to be a better way to do this" kind of problem
    - However, I didn't want to start unrolling it to make it as optimal as possible.
    - So I think settling on making it obvious and clear is a nice compromise.

### Day 3

- Once again, I was very tempted to write an over-engineered "instruction-parser" type system
    - However, we have regular expressions that work just fine

### Day 4

- Part two is the first one that felt a bit like "I must be missing some key insight"
    - Then I got the key insight
- Again, a struggle between the sides of "simplicity of code" versus "efficiency of code"
    - I like to think that, at present, I've found something in the middle

### Day 5

- I am not sure if reversing the rule was strictly necessary, but it made the rest of the puzzle easy
    - If it was needed, I should think more on how I can work on that insight
    - If not, uh, it was fun I guess?

### Day 6

- The first day my code is slow
    - It solved part 1, but it was slow enough I didn't like it one bit.

### Day 7

- Approached this before solving part 2 of day six
- As a result, totally overthought this
- It turns out a naive fork at each step is totally valid:
    - Solving both parts takes about 1.2s.
    - Not, like, super performant, but not agonizingly slow.

[uv]: https://docs.astral.sh/uv/

[ruff]: https://docs.astral.sh/ruff/

[unittest]: https://docs.python.org/3.13/library/unittest.html

