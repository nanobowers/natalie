# -*- encoding: utf-8 -*-
require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "String#capitalize" do
  it "returns a copy of self with the first character converted to uppercase and the remainder to lowercase" do
    "".capitalize.should == ""
    "h".capitalize.should == "H"
    "H".capitalize.should == "H"
    "hello".capitalize.should == "Hello"
    "HELLO".capitalize.should == "Hello"
    "123ABC".capitalize.should == "123abc"
    "abcdef"[1...-1].capitalize.should == "Bcde"
  end

  describe "full Unicode case mapping" do
    it "works for all of Unicode with no option" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        "äöÜ".capitalize.should == "Äöü"
      end
    end

    it "only capitalizes the first resulting character when upcasing a character produces a multi-character sequence" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        "ß".capitalize.should == "Ss"
      end
    end

    it "updates string metadata" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        capitalized = "ßeT".capitalize

        capitalized.should == "Sset"
        capitalized.size.should == 4
        capitalized.bytesize.should == 4
        capitalized.ascii_only?.should be_true
      end
    end
  end

  describe "ASCII-only case mapping" do
    it "does not capitalize non-ASCII characters" do
      "ßet".capitalize(:ascii).should == "ßet"
    end

    it "handles non-ASCII substrings properly" do
      "garçon"[1...-1].capitalize(:ascii).should == "Arço"
    end
  end

  describe "full Unicode case mapping adapted for Turkic languages" do
    it "capitalizes ASCII characters according to Turkic semantics" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        "iSa".capitalize(:turkic).should == "İsa"
      end
    end

    it "allows Lithuanian as an extra option" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        "iSa".capitalize(:turkic, :lithuanian).should == "İsa"
      end
    end

    it "does not allow any other additional option" do
      -> { "iSa".capitalize(:turkic, :ascii) }.should raise_error(ArgumentError)
    end
  end

  describe "full Unicode case mapping adapted for Lithuanian" do
    it "currently works the same as full Unicode case mapping" do
      "iß".capitalize(:lithuanian).should == "Iß"
    end

    it "allows Turkic as an extra option (and applies Turkic semantics)" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        "iß".capitalize(:lithuanian, :turkic).should == "İß"
      end
    end

    it "does not allow any other additional option" do
      -> { "iß".capitalize(:lithuanian, :ascii) }.should raise_error(ArgumentError)
    end
  end

  it "does not allow the :fold option for upcasing" do
    -> { "abc".capitalize(:fold) }.should raise_error(ArgumentError)
  end

  it "does not allow invalid options" do
    -> { "abc".capitalize(:invalid_option) }.should raise_error(ArgumentError)
  end

  ruby_version_is ''...'3.0' do
    it "returns subclass instances when called on a subclass" do
      StringSpecs::MyString.new("hello").capitalize.should be_an_instance_of(StringSpecs::MyString)
      StringSpecs::MyString.new("Hello").capitalize.should be_an_instance_of(StringSpecs::MyString)
    end
  end

  ruby_version_is '3.0' do
    it "returns String instances when called on a subclass" do
      StringSpecs::MyString.new("hello").capitalize.should be_an_instance_of(String)
      StringSpecs::MyString.new("Hello").capitalize.should be_an_instance_of(String)
    end
  end

  it "returns a String in the same encoding as self" do
    "h".encode("US-ASCII").capitalize.encoding.should == Encoding::US_ASCII
  end
end

describe "String#capitalize!" do
  it "capitalizes self in place" do
    a = "hello"
    a.capitalize!.should equal(a)
    a.should == "Hello"
  end

  it "modifies self in place for non-ascii-compatible encodings" do
    a = "heLLo".encode("utf-16le")
    a.capitalize!
    a.should == "Hello".encode("utf-16le")
  end

  describe "full Unicode case mapping" do
    it "modifies self in place for all of Unicode with no option" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        a = "äöÜ"
        a.capitalize!
        a.should == "Äöü"
      end
    end

    it "only capitalizes the first resulting character when upcasing a character produces a multi-character sequence" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        a = "ß"
        a.capitalize!
        a.should == "Ss"
      end
    end

    it "works for non-ascii-compatible encodings" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        a = "äöü".encode("utf-16le")
        a.capitalize!
        a.should == "Äöü".encode("utf-16le")
      end
    end

    it "updates string metadata" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        capitalized = "ßeT"
        capitalized.capitalize!

        capitalized.should == "Sset"
        capitalized.size.should == 4
        capitalized.bytesize.should == 4
        capitalized.ascii_only?.should be_true
      end
    end
  end

  describe "modifies self in place for ASCII-only case mapping" do
    it "does not capitalize non-ASCII characters" do
      a = "ßet"
      a.capitalize!(:ascii)
      a.should == "ßet"
    end

    it "works for non-ascii-compatible encodings" do
      a = "aBc".encode("utf-16le")
      a.capitalize!(:ascii)
      a.should == "Abc".encode("utf-16le")
    end
  end

  describe "modifies self in place for full Unicode case mapping adapted for Turkic languages" do
    it "capitalizes ASCII characters according to Turkic semantics" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        a = "iSa"
        a.capitalize!(:turkic)
        a.should == "İsa"
      end
    end

    it "allows Lithuanian as an extra option" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        a = "iSa"
        a.capitalize!(:turkic, :lithuanian)
        a.should == "İsa"
      end
    end

    it "does not allow any other additional option" do
      -> { a = "iSa"; a.capitalize!(:turkic, :ascii) }.should raise_error(ArgumentError)
    end
  end

  describe "modifies self in place for full Unicode case mapping adapted for Lithuanian" do
    it "currently works the same as full Unicode case mapping" do
      a = "iß"
      a.capitalize!(:lithuanian)
      a.should == "Iß"
    end

    it "allows Turkic as an extra option (and applies Turkic semantics)" do
      NATFIXME 'Pending unicode casemap support', exception: SpecFailedException do
        a = "iß"
        a.capitalize!(:lithuanian, :turkic)
        a.should == "İß"
      end
    end

    it "does not allow any other additional option" do
      -> { a = "iß"; a.capitalize!(:lithuanian, :ascii) }.should raise_error(ArgumentError)
    end
  end

  it "does not allow the :fold option for upcasing" do
    -> { a = "abc"; a.capitalize!(:fold) }.should raise_error(ArgumentError)
  end

  it "does not allow invalid options" do
    -> { a = "abc"; a.capitalize!(:invalid_option) }.should raise_error(ArgumentError)
  end

  it "returns nil when no changes are made" do
    a = "Hello"
    a.capitalize!.should == nil
    a.should == "Hello"

    "".capitalize!.should == nil
    "H".capitalize!.should == nil
  end

  it "raises a FrozenError when self is frozen" do
    ["", "Hello", "hello"].each do |a|
      a.freeze
      -> { a.capitalize! }.should raise_error(FrozenError)
    end
  end
end
