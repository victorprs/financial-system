# Financial System [![Build Status](https://travis-ci.org/victorprs/financial-system.svg?branch=master)](https://travis-ci.org/victorprs/financial-system) [![Coverage Status](https://coveralls.io/repos/github/victorprs/financial-system/badge.svg?branch=master)](https://coveralls.io/github/victorprs/financial-system?branch=master)
 
A financial system library that represents money values with arbitrary-precision arithmetic, instead of floating-point math. It takes advantage of Elixir's bignum arithmetic with integers and stores all values in its minor units. Thus, the Money data structure uses Elixir's integer basic type with ability to increase precision when needed. Further reading about why floating-point math is somewhat inaccurate in the further reading section.

# Basic commands

`mix deps.get` Gets all dependencies

`iex -S mix` Run in interactive mode

`mix test` Test the application

`MIX_ENV=test mix coveralls` Run coveralls for code coverage

`MIX_ENV=test mix coveralls.details` Display code coverage per line

`mix credo` Display credo's suggestions for code linting

`mix credo --strict` Enforce credo to suggest further style-guide


# Documentation

WIP

# Further reading

[Floating Point Math](https://0.30000000000000004.com/)

[Floating point - Wikipedia](http://en.wikipedia.org/wiki/Floating_point)

[What Every Computer Scientist Should Know About Floating-point Arithmetic](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)

[BigNum arithmetic](https://en.wikipedia.org/wiki/Arbitrary-precision_arithmetic)


