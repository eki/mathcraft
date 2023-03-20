# Mathcraft

Mathcraft is a computer algebra system.

It can simplify and solve simple problems. It is likely at a "toy" level of
completeness. A couple examples:

    mathcraft> 10 = x - 3
    x = 13
    mathcraft> (4y - 8) / (2x - 4) = 2
    y = x
    mathcraft> x^4 - 15x^2 - 10x + 24 = 0
    x = 1, x = -2, x = -3, x = 4
    mathcraft> 5(- 3x - 2) - (x - 3) = -4(4x + 5) + 13
    all real numbers
    mathcraft> 3x / (x + 1) + 6 = -3 / (x + 1)
    no solution

There are likely many remaining equations that it is incapable of solving.

## Repo Recently Made Public

Until recently, this repo was private and still has some development
dependencies that are private. If time allows, I'll either replace the private
dependencies or make them public as well. My motivation for making this project
public is that I have occasionally wanted to show the code to some folks
because there are some bits that I think are kind of interesting. YMMV

## Installation

*If you are the author*, this gem is hosted privately on s3 and you can add
this to your application's Gemfile:

```ruby
source 's3://vying-gems', type: 'aws-s3' do
  gem 'mathcraft'
end
```

Others, can probably reference this repo directly like so:

```ruby
gem "mathcraft", :git => "git://github.com/eki/mathcraft.git"
```

And then execute:

    $ bundle

Or install it yourself as (this will not work for everyone, yet, because this
gem hasn't been published to rubygems):

    $ gem install mathcraft

## Usage

There is an executable `mathcraft` which will open a repl that reads in
expressions or equations and then simplifies or solves them. This can also be
used as a calculator - if an expression is entirely numbers, it'll be reduced
down to a number.

To use Mathcraft in another Ruby program, use the `craft` method to create a
Mathcraft object which can then be simplified or solved.

Here is an example of an expression and simplfication:

```ruby
>> expr = Mathcraft.craft('3 + x + 4')
=> (+ (+ 3 x) 4)
>> expr.simplify
=> (+ x 7)
>> expr.simplify.to_s
=> "x + 7"
```

And, here is an example of an equation, simplification, and solving:

```ruby
>> eq = Mathcraft.craft('(x + 1)(2x - 2) = 0')
=> (= (* (+ x 1) (- (* 2 x) 2)) 0)
>> eq.to_s
=> "(x + 1)(2x - 2) = 0"
>> eq.simplify.to_s
=> "2x^2 - 2 = 0"
>> eq.solve
=> [(= x -1), (= x 1)]
>> eq.solve.map(&:to_s)
=> ["x = -1", "x = 1"]
```

## How does it work?

This library is based around translations between a couple data structures.

The `craft` method typically invokes a `Parser` to convert a `String` into a
lazy expression tree. However, `craft` will work equally well on `Numeric`
(producing a `Mathcraft::Number` or `Symbol` (producing a
`Mathcraft::Variable`). It is important to remember that `craft` always
produces a lazy value.

We can perform math operations on lazy objects and we will simply add to the
existing lazy expression tree. Nothing is resolved or simplified when working
with a lazy tree.

The output from `inspect` shows the underlying tree structure:

```ruby
>> Mathcraft.craft('1 + 2 + 3 + 4 + 5')
=> (+ (+ (+ (+ 1 2) 3) 4) 5)
>> Mathcraft.craft('1 + 2 + 3 + 4 + 5').to_s
=> "1 + 2 + 3 + 4 + 5"
```

The lazy expression tree structure is composed of `Mathcraft::Number`,
`Mathcraft::Variable`, and `Mathcraft::Expression`.

In the earlier example, we saw that calling `to_s` on our lazy produce human
readable representation which should be consistent with the input that can be
parsed by `craft` method.

In addition to the lazy representation of an expression, we also have an
immediate representation. The immediate representation is composed of
`Mathcraft::Term`, `Mathcraft::Sum`, and `Mathcraft::Ratio`. Math operations
performed on these immediate models happen, well, immediately.

We can get an immediate representation with the `craft!` method:

```ruby
>> Mathcraft.craft!('(3 + 2x - 2)4').to_s
=> "8x + 4"
```

As you can see, the expression was simplified as a side-effect of executing the
operations as we go.

The immediate representaion should also be a *canoncial* representation. Which
is to say, any two mathematically equivalent expressions should have the same
immediate representation. This can be seen in the following simple example:

```ruby
>> Mathcraft.craft!('y2 + 3x').to_s
=> "3x + 2y"
>> Mathcraft.craft!('3x + y + y').to_s
=> "3x + 2y"
```

The immediate model `Mathcraft::Term` represents the multiplication of some
number of numbers and variables. Calling `to_immediate` on either a
`Mathcraft::Number` or `Mathcraft::Variable` will produce a `Term`.

The immediate model 'Mathcraft::Sum' represents the addition of multiple terms.
The terms may be positive or negative and, in this way, `Sum` encompasses both
addition and subtraction. We automatically combine *like* terms. For example,
`2x` and `3x` may be combined to `5x`. Also, `1/x` + `2/x` may be combined into
`3/x`.

The immediate model `Mathcraft::Ratio` is much like Ruby's `Rational` class in
that it represents division by storing the numerator and denominator. It is the
ratio of two other immediate models.

You may change between lazy and immediate representations of an expression by
calling the `to_lazy` or `to_immediate` methods.

`Mathcraft::Equation` is somewhat unique in that it can be either lazy or
immediate. It has `left` and `right` sides which will be lazy or immediate
depending on whether the equation is lazy or immediate.

Math operations performed on an equation are applied to both the left and right
sides to guarantee the equation maintains equality (if it was a well-formed
equation, of course).

Finally, all `Mathcraft` models respond to Ruby's operator methods. For
example:

```ruby
>> eq = Mathcraft.craft('2x - 3 = 5')
=> (= (- (* 2 x) 3) 5)
>> eq.to_s
=> "2x - 3 = 5"
>> eq += 3
=> (= (+ (- (* 2 x) 3) 3) (+ 5 3))
>> eq.to_s
=> "2x - 3 + 3 = 5 + 3"
>> eq /= 2
=> (= (/ (+ (- (* 2 x) 3) 3) 2) (/ (+ 5 3) 2))
>> eq.to_s
=> "(2x - 3 + 3) / 2 = (5 + 3) / 2"
>> eq = eq.simplify
=> (= x 4)
>> eq.to_s
=> "x = 4"
```

In the above example, we worked with a lazy equation. First we added `3`
knowing that would cancel the `-3` on the left side. Then we divided by `2`,
knowing that would cancel the `2` in `2x` on the left side. We can see that the
operations accumulated in lazy fashion. Finally we call `simplify` and we've
"solved" the equation without the `solve` method.

On a side note: can you guess how `simplify` is implemented? If you guessed
that we only need to translate from lazy to immediate and back, you're right!
Simplify is just `to_immediate.to_lazy`.

## Development

This gem was private until recently and uses the same private tools that the
rest of my side projects use (for consistency across projects and to save
myself time).

Tests currently require my private gem `minitest-boost` which allows test to be
written in a Rails style with a block and a string name instead of the normal
minitest style. This is a development dependency and would not impact using
mathcraft in another project.

```ruby
# Tests are written in more of a Rails style, like this:
test 'parse numbers' do
  # ...
end

# As opposed to how it'd normally be written with minitest on its own:
def test_parse_numbers
  # ...
end
```

Tests, lint, and security tools are run via another private gem called `proj`
which simply ensures all my private projects have the same development
interface. Here, for example, is what the current out put of `proj check` looks
like on `mathcraft`:

```
eki@vorpal> proj check                                     ~/projects/mathcraft
Running tests

Run with: proj test -s 19791

.......................................................................................................................................................................................................................................................................................................................................................................................................

Loaded in 0.230s. Ran in 0.337543s, 1158.37 runs/s, 3430.67 assertions/s.
391 runs, 1158 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to
/Users/eki/projects/mathcraft/coverage. 797 / 803 LOC (99.25%) covered.


Running rubocop -c .../proj-0.23.8/rubocop.yml

Inspecting 33 files
.................................

33 files inspected, no offenses detected

Running bundle-audit check --update

Updating ruby-advisory-db ...
From https://github.com/rubysec/ruby-advisory-db
 * branch            master     -> FETCH_HEAD
Already up to date.
Updated ruby-advisory-db
ruby-advisory-db:
  advisories:   689 advisories
  last updated: 2023-03-17 16:41:49 -0700
  commit:       d15c57b99d90f5db77f9a42978aec3f086f4add5
No vulnerabilities found

All checks passed
```

And, here are some stats for this `mathcraft` as of this update to the README
(this uses `tokei` to collect the actual lines-of-code stats):

```
eki@vorpal> proj stat                                      ~/projects/mathcraft

| code                 | lang       |  files |    lines |     code | comments |
| -------------------- | ---------- | ------ | -------- | -------- | -------- |
| lib                  | Ruby       |     16 |     1561 |     1130 |       64 |
| test                 | Ruby       |     13 |     2823 |     2176 |       42 |
| test:support         | Ruby       |      2 |       42 |       28 |        4 |
| -------------------- | ---------- | ------ | -------- | -------- | -------- |
| total                | Ruby       |     31 |     4426 |     3334 |      110 |
| -------------------- | ---------- | ------ | -------- | -------- | -------- |
Code: 1130  Test: 2204  Ratio 1:1.95
```

Until `minitest-boost` and `proj` are either made public or replaced, it'll be
hard for outside developers to contribute to this project. If you are
interested in working on this project, please let me know. I'm not sure how
interested I am in making these changes if this is going to continue to be a
toy project in which I'm the only developer.
