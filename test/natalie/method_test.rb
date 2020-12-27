require_relative '../spec_helper'

def foo
  'foo'
end

def double(x)
  x * 2
end

def mul(x, y,
        z)
  x * y * z
end

def block_test
  yield
end

def block_with_args_test
  yield 1, 2, 3
end

def block_with_args_test2
  yield 4, 5
end

def block_arg_test(a, b, &block)
  [a, b, block.call]
end

def block_arg_is_nil(&block)
  block
end

def block_given_test
  block_given?
end

def default(x = 1)
  x
end

def default_calling_another_method(x = default)
  x
end

def default_calling_another_method2(x = default(2))
  x
end

def default_after_regular(x, y = 2)
  [x, y]
end

def default_with_splat_last(x, y = 2, *rest)
  [x, y, rest]
end

class Foo
  def foo
    'instance method foo'
  end

  def self.foo1
    'class method foo'
  end

  def Foo.foo2
    'class method foo2'
  end
end

class Bar
  define_method :bar do
    'bar'
  end
end

class YieldToBlock
  def yield_to_block
    yield
  end
end

class BlockPassTest < YieldToBlock
  def yield_to_block(&b)
    super(&b)
  end
end

describe 'method' do
  it 'can be called' do
    foo.should == 'foo'
  end

  it 'can receive arguments' do
    double(3).should == 6
    mul(1, 2, 3).should == 6
  end

  it 'raises an error when there are not enough arguments' do
    -> { double }.should raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
    -> { default_after_regular }.should raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1..2)')
  end

  it 'raises an error when there are too many arguments' do
    -> { double(1, 2) }.should raise_error(ArgumentError, 'wrong number of arguments (given 2, expected 1)')
    -> { default_after_regular(1, 2, 3) }.should raise_error(ArgumentError, 'wrong number of arguments (given 3, expected 1..2)')
  end

  it 'can receive and yield to a block' do
    r = block_test { 1 }
    r.should == 1
    x = 2
    r = block_test do
      x
    end
    r.should == 2
  end

  it 'can receive a block as a Proc argument' do
    r = block_arg_test(1, 2) { 3 }
    r.should == [1, 2, 3]
    r = block_arg_is_nil
    r.should == nil
    r = block_arg_is_nil(&nil)
    r.should == nil
  end

  it 'knows if it received a block' do
    without = block_given_test
    without.should == false
    with = block_given_test { p 'hi' }
    with.should == true
  end

  # FIXME: doesn't actually bubble up because LocalJumpError is trapped by the method
  xit 'raises an error when trying to yield without a block' do
    -> { YieldToBlock.new.yield_to_block }.should raise_error(LocalJumpError)
  end

  xit 'can call super with a block arg' do
    t = BlockPassTest.new
    it_worked = false
    t.yield_to_block do
      it_worked = true
    end
    it_worked.should == true
  end

  it 'can yield args to a block' do
    r = block_with_args_test { |x, y, z| [x, y, z] }
    r.should == [1, 2, 3]
    r = block_with_args_test2 do |x, y, z|
      [x, y, z]
    end
    r.should == [4, 5, nil]
    r = block_with_args_test2 do |x|
      [x]
    end
    r.should == [4]
  end

  it 'can be an instance method' do
    Foo.new.foo.should == 'instance method foo'
  end

  it 'can be a class method' do
    Foo.foo1.should == 'class method foo'
    Foo.foo2.should == 'class method foo2'
  end

  it 'can define a method dynamically' do
    Bar.new.bar.should == 'bar'
  end

  it 'can have default arguments' do
    default.should == 1
    default(2).should == 2
    default_after_regular(1).should == [1, 2]
    default_after_regular(2).should == [2, 2]
    default_after_regular(2, 3).should == [2, 3]
    default_with_splat_last(2).should == [2, 2, []]
    default_calling_another_method.should == 1
    default_calling_another_method2.should == 2
  end

  def default_first1(x = 1)
    x
  end

  def default_first2(a = 1, b = 2, c = 3, v, w, x, y, z)
    [a, b, c, v, w, x, y, z]
  end

  def default_first3(a = 1, b, c, v, w, x, y, z)
    [a, b, c, v, w, x, y, z]
  end

  it 'can have default arguments first' do
    default_first1.should == 1
    default_first1(2).should == 2
    default_first2(4, 5, 6, 7, 8).should == [1, 2, 3, 4, 5, 6, 7, 8]
    default_first2(0, 4, 5, 6, 7, 8).should == [0, 2, 3, 4, 5, 6, 7, 8]
    default_first2(0, 1, 4, 5, 6, 7, 8).should == [0, 1, 3, 4, 5, 6, 7, 8]
    default_first2(0, 1, 2, 4, 5, 6, 7, 8).should == [0, 1, 2, 4, 5, 6, 7, 8]
    default_first3(2, 3, 4, 5, 6, 7, 8).should == [1, 2, 3, 4, 5, 6, 7, 8]
    default_first3(0, 2, 3, 4, 5, 6, 7, 8).should == [0, 2, 3, 4, 5, 6, 7, 8]
  end

  def destructuring((a, b), c)
    [a, b, c]
  end

  it 'can destructure arguments' do
    destructuring([1, 2], 3).should == [1, 2, 3]
    destructuring([1], 3).should == [1, nil, 3]
    destructuring([], 3).should == [nil, nil, 3]
    destructuring(nil, 3).should == [nil, nil, 3]
  end

  def destructuring_with_splat((a, *b), c)
    [a, b, c]
  end

  it 'can destructure arguments with a splat' do
    destructuring_with_splat([1, 2, 3], 3).should == [1, [2, 3], 3]
    destructuring_with_splat([1, 2], 3).should == [1, [2], 3]
    destructuring_with_splat([1], 3).should == [1, [], 3]
    destructuring_with_splat([], 3).should == [nil, [], 3]
    destructuring_with_splat(nil, 3).should == [nil, [], 3]
  end

  def splat_first(*splat, x, y)
    [splat, x, y]
  end

  def blank_splat_first(*, x, y)
    [x, y]
  end

  it 'can have a splat first' do
    splat_first(1, 2, 3, 4).should == [[1, 2], 3, 4]
    blank_splat_first(1, 2, 3, 4).should == [3, 4]
  end

  def splat_middle(x, *splat, y)
    [x, splat, y]
  end

  def blank_splat_middle(x, *, y)
    [x, y]
  end

  it 'can have a splat in the middle' do
    splat_middle(1, 2, 3, 4).should == [1, [2, 3], 4]
    blank_splat_middle(1, 2, 3, 4).should == [1, 4]
  end

  def method_name
    __method__
  end

  def method_name_via_send
    send(:__method__)
  end

  def method_name_from_block
    [1].map do
      __method__
    end
  end

  it 'knows its own name' do
    method_name.should == :method_name
    method_name_via_send.should == :method_name_via_send
    method_name_from_block.should == [:method_name_from_block]
  end

  describe '#method_defined?' do
    it 'returns true for regular methods' do
      Foo.method_defined?(:foo).should == true
    end

    it 'returns false for class methods' do
      Foo.method_defined?('foo1').should == false
      Foo.method_defined?(:foo2).should == false
    end

    it 'returns false for undefined (removed) methods' do
      NilClass.method_defined?('new').should == false
    end
  end

  describe '#respond_to?' do
    it 'works for class methods' do
      Foo.respond_to?('foo1').should == true
      Foo.respond_to?(:foo2).should == true
      Foo.respond_to?('xxx').should == false
    end

    it 'works for instance methods' do
      Foo.new.respond_to?('foo').should == true
      Foo.new.respond_to?(:xxx).should == false
      Bar.new.respond_to?('bar').should == true
      Bar.new.respond_to?(:xxx).should == false
    end

    it 'returns false for undefined methods' do
      NilClass.respond_to?('new').should == false
    end
  end
end

def method_with_kwargs1(a, b:)
  [a, b]
end

def method_with_kwargs2(a, b:, c:)
  [a, b, c]
end

def method_with_kwargs3(a, b:, c: 'c')
  [a, b, c]
end

def method_with_kwargs4(a, b: 'b', c:)
  [a, b, c]
end

def method_with_kwargs5(a, b: 'b')
  [a, b]
end

def method_with_kwargs6(a: 'a', b: 'b')
  [a, b]
end

def method_with_kwargs7(a:)
  [a]
end

def method_with_kwargs8(a:, b: nil)
  [a, b]
end

def method_with_kwargs9(a = 1, b: 2)
  [a, b]
end


describe 'method with keyword args' do
  it 'accepts keyword args' do
    method_with_kwargs1(1, b: 2).should == [1, 2]
    method_with_kwargs2(1, b: 2, c: 3).should == [1, 2, 3]
    method_with_kwargs3(1, b: 2, c: 3).should == [1, 2, 3]
    method_with_kwargs3(1, b: 2).should == [1, 2, 'c']
    method_with_kwargs4(1, b: 2, c: 3).should == [1, 2, 3]
    method_with_kwargs4(1, c: 3).should == [1, 'b', 3]
    method_with_kwargs5({ z: 1 }).should == [{ z: 1 }, 'b']
    method_with_kwargs6.should == ['a', 'b']
    method_with_kwargs6(a: 1).should == [1, 'b']
    method_with_kwargs6(a: 1, b: 2).should == [1, 2]
    method_with_kwargs8(a: 1).should == [1, nil]
    method_with_kwargs9.should == [1, 2]
    method_with_kwargs9('a').should == ['a', 2]
    method_with_kwargs9('a', b: 'b').should == ['a', 'b']
  end

  xit 'raises an error when there are too many positional arguments' do
    -> { method_with_kwargs1(1, 2, b: 3) }.should raise_error(ArgumentError, 'wrong number of arguments (given 2, expected 1; required keyword: b)')
  end

  it 'raises an error when a required keyword argument is not supplied' do
    -> { method_with_kwargs7 }.should raise_error(ArgumentError, "missing keyword: :a")
  end

  xit 'raises an error when an extra keyword argument is supplied' do
    -> { method_with_kwargs6(a: 1, b: 2, c: 3) }.should raise_error(ArgumentError, "unknown keyword: :c")
  end

  it 'raises an error when the method is not defined' do
    class Foo; end
    -> { Foo.new.not_a_method }.should raise_error(NoMethodError, /undefined method `not_a_method' for #<Foo:0x.+>/)
  end

  it 'does not loop infinitely when trying to call inspect on BasicObject' do
    -> { BasicObject.new.inspect }.should raise_error(NoMethodError, /undefined method `inspect' for #<BasicObject:0x.+>/)
  end
end

def returns_arg(arg)
  arg
end

describe 'safe navigation operator' do
  it 'returns nil if the receiver is nil, otherwise calls the method' do
    returns_arg(nil)&.first.should be_nil
    returns_arg([1])&.first.should == 1
  end
end
