describe :string_to_sym, shared: true do
  it "returns the symbol corresponding to self" do
    "Koala".send(@method).should equal :Koala
    'cat'.send(@method).should equal :cat
    '@cat'.send(@method).should equal :@cat
    'cat and dog'.send(@method).should equal :"cat and dog"
    "abc=".send(@method).should equal :abc=
  end

  it "does not special case +(binary) and -(binary)" do
    "+(binary)".send(@method).should equal :"+(binary)"
    "-(binary)".send(@method).should equal :"-(binary)"
  end

  it "does not special case certain operators" do
    "!@".send(@method).should equal :"!@"
    "~@".send(@method).should equal :"~@"
    "!(unary)".send(@method).should equal :"!(unary)"
    "~(unary)".send(@method).should equal :"~(unary)"
    "+(unary)".send(@method).should equal :"+(unary)"
    "-(unary)".send(@method).should equal :"-(unary)"
  end

  it "returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" do
    sym = "foobar".send(@method)
    NATFIXME 'Implement Symbol#encoding', exception: NoMethodError, message: "undefined method `encoding'" do
      sym.encoding.should == Encoding::US_ASCII
    end
    sym.should equal :"foobar"
  end

  it "returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" do
    sym = "foobar".b.send(@method)
    NATFIXME 'Implement Symbol#encoding', exception: NoMethodError, message: "undefined method `encoding'" do
      sym.encoding.should == Encoding::US_ASCII
    end
    sym.should equal :"foobar"
  end

  it "returns a UTF-8 Symbol for a UTF-8 String containing non US-ASCII characters" do
    sym = "il était une fois".send(@method)
    NATFIXME 'Implement Symbol#encoding', exception: NoMethodError, message: "undefined method `encoding'" do
      sym.encoding.should == Encoding::UTF_8
    end
    sym.should equal :"il était une #{'fois'}"
  end

  it "returns a UTF-16LE Symbol for a UTF-16LE String containing non US-ASCII characters" do
    utf16_str = "UtéF16".encode(Encoding::UTF_16LE)
    sym = utf16_str.send(@method)
    NATFIXME 'Implement Symbol#encoding', exception: NoMethodError, message: "undefined method `encoding'" do
      sym.encoding.should == Encoding::UTF_16LE
    end
    sym.to_s.should == utf16_str
  end

  it "returns a binary Symbol for a binary String containing non US-ASCII characters" do
    binary_string = "binarí".b
    sym = binary_string.send(@method)
    NATFIXME 'Implement Symbol#encoding', exception: NoMethodError, message: "undefined method `encoding'" do
      sym.encoding.should == Encoding::BINARY
    end
    sym.to_s.should == binary_string
  end

  it "ignores exising symbols with different encoding" do
    source = "fée"

    iso_symbol = source.force_encoding(Encoding::ISO_8859_1).send(@method)
    NATFIXME 'Implement Symbol#encoding', exception: NoMethodError, message: "undefined method `encoding'" do
      iso_symbol.encoding.should == Encoding::ISO_8859_1
    end
    binary_symbol = source.force_encoding(Encoding::BINARY).send(@method)
    NATFIXME 'Implement Symbol#encoding', exception: NoMethodError, message: "undefined method `encoding'" do
      binary_symbol.encoding.should == Encoding::BINARY
    end
  end

  it "raises an EncodingError for UTF-8 String containing invalid bytes" do
    invalid_utf8 = "\xC3"
    invalid_utf8.should_not.valid_encoding?
    NATFIXME 'to_sym should raise EncodingError', exception: SpecFailedException do
      -> {
        invalid_utf8.send(@method)
      }.should raise_error(EncodingError, /invalid/)
    end
  end
end
