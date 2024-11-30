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

[uv]: https://docs.astral.sh/uv/

[ruff]: https://docs.astral.sh/ruff/

[unittest]: https://docs.python.org/3.13/library/unittest.html

