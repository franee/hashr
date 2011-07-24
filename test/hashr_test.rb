require 'test_helper'

class HashrTest < Test::Unit::TestCase
  def teardown
    Hashr.raise_missing_keys = false
  end

  test 'method access on an existing key returns the value' do
    assert_equal 'foo', Hashr.new({ :foo => 'foo' }).foo
  end

  test 'method access on a non-existing key returns nil when raise_missing_keys is false' do
    Hashr.raise_missing_keys = false
    assert_nil Hashr.new({ :foo => 'foo' }).bar
  end

  test 'method access on a non-existing key raises an IndexError when raise_missing_keys is true' do
    Hashr.raise_missing_keys = true
    assert_raises(IndexError) { Hashr.new({ :foo => 'foo' }).bar }
  end

  test 'method access on an existing nested key returns the value' do
    assert_equal 'bar', Hashr.new({ :foo => { :bar => 'bar' } }).foo.bar
  end

  test 'method access on a non-existing nested key returns nil when raise_missing_keys is false' do
    Hashr.raise_missing_keys = false
    assert_nil Hashr.new({ :foo => { :bar => 'bar' } }).foo.baz
  end

  test 'method access on a non-existing nested key raises an IndexError when raise_missing_keys is true' do
    Hashr.raise_missing_keys = true
    assert_raises(IndexError) { Hashr.new({ :foo => { :bar => 'bar' } }).foo.baz }
  end

  test 'method access with a question mark returns true if the key has a value' do
    assert_equal true, Hashr.new({ :foo => { :bar => 'bar' } }).foo.bar?
  end

  test 'method access with a question mark returns false if the key does not have a value' do
    assert_equal false, Hashr.new({ :foo => { :bar => 'bar' } }).foo.baz?
  end

  test 'method assignment works' do
    hashr = Hashr.new
    hashr.foo = 'foo'
    assert_equal 'foo', hashr.foo
  end

  test 'defining defaults' do
    klass = Class.new(Hashr) do
      define :foo => 'foo', :bar => { :baz => 'baz' }
    end
    assert_equal 'foo', klass.new.foo
    assert_equal 'baz', klass.new.bar.baz
  end

  test 'defining different defaults on different classes ' do
    foo = Class.new(Hashr) { define :foo => 'foo' }
    bar = Class.new(Hashr) { define :bar => 'bar' }

    assert_equal 'foo', foo.definition[:foo]
    assert_equal 'bar', bar.definition[:bar]
  end

  test 'defining different env_namespaces on different classes ' do
    foo = Class.new(Hashr) {extend Hashr::EnvDefaults; self.env_namespace = 'foo' }
    bar = Class.new(Hashr) {extend Hashr::EnvDefaults; self.env_namespace = 'bar' }

    assert_equal ['FOO'], foo.env_namespace
    assert_equal ['BAR'], bar.env_namespace
  end

  test 'defaults to env vars' do
    klass = Class.new(Hashr) do
      extend Hashr::EnvDefaults
      self.env_namespace = 'hashr'
      define :foo => 'foo', :bar => { :baz => 'baz' }
    end

    ENV['HASHR_FOO'] = 'env foo'
    ENV['HASHR_BAR_BAZ'] = 'env bar baz'

    hashr = klass.new
    assert_equal 'env foo', hashr.foo
    assert_equal 'env bar baz', hashr.bar.baz

    # ENV.delete('HASHR_FOO')
    # ENV.delete('HASHR_BAR_BAZ')

    # hashr = klass.new
    # assert_equal 'foo', hashr.foo
    # assert_equal 'bar baz', hashr.bar.baz
  end

  test 'a key :_include includes the given modules' do
    klass = Class.new(Hashr) do
      define :foo => { :_include => Module.new { def helper; 'helper'; end } }
    end
    assert_equal 'helper', klass.new.foo.helper
  end
end
