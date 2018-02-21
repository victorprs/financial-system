# Financial System [![Build Status](https://travis-ci.org/victorprs/financial-system.svg?branch=master)](https://travis-ci.org/victorprs/financial-system) [![Coverage Status](https://coveralls.io/repos/github/victorprs/financial-system/badge.svg?branch=master)](https://coveralls.io/github/victorprs/financial-system?branch=master)
 
A financial system library that represents money values with arbitrary-precision arithmetic, instead of floating-point math. It takes advantage of Elixir's bignum arithmetic with integers and stores all values in its minor units. Thus, the Money data structure uses Elixir's integer basic type with ability to increase precision when needed. Further reading about why floating-point math is somewhat inaccurate in the further reading section.

## Features

This project includes the following features: 
- Currency representation independant of other modules (so that it is easier to import currencies with updated exchange rates)
- Currencies must be in compliance with the [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
- Money creation with arbitrary-precision arithmetics (no floating point math!)
- Money with basic math operations
- Money conversion to another currencies
- Account representation and the ability to withdraw and deposit from an account
- Financial System representation that enables money transfer between accounts
- Transfer Split - transfering money from one account to two or more different accounts

## Dependencies

There are some dependencies that have helped me to develop this project and mantain the code quality. They are:

- [ExDoc](https://github.com/elixir-lang/ex_doc) - Generate Html with the API Reference based on the documentation's annotations in the source code
- [ExCoveralls](https://github.com/parroty/excoveralls) - An Elixir library that reports test coverage statistics, with the option to post to coveralls.io service.
- [Credo](https://github.com/rrrene/credo) - Credo is a static code analysis tool for the Elixir language with a focus on teaching and code consistency.

## Basic commands

`mix deps.get` Gets all dependencies

`iex -S mix` Run in interactive mode

`mix test` Test the application

`MIX_ENV=test mix coveralls` Run coveralls for code coverage

`MIX_ENV=test mix coveralls.details` Display code coverage per line

`mix credo` Display credo's suggestions for code linting

`mix credo --strict` Enforce credo to suggest further style-guide

`mix docs` Generate documentation with ExDoc


## Documentation

The documentation was written to guide the user to fully understand this lib. It was generated with the [ExDoc module](https://github.com/elixir-lang/ex_doc) and it is one of the dependencies of this project. Hosted on this GitHub Pages and also in the docs folder at the root of this project. 

Go to my [GitHub Pages documentation site](https://victorprs.github.io/financial-system/)

Any questions or further explanations about this lib, you can open an issue and I'll be happy to answer it!

## Further reading

[Floating Point Math](https://0.30000000000000004.com/)

[Floating point - Wikipedia](http://en.wikipedia.org/wiki/Floating_point)

[What Every Computer Scientist Should Know About Floating-point Arithmetic](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)

[BigNum arithmetic](https://en.wikipedia.org/wiki/Arbitrary-precision_arithmetic)


