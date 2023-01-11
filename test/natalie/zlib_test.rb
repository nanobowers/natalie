require_relative '../spec_helper'
require 'zlib'

describe 'Zlib' do
  LARGE_TEXT_PATH = File.expand_path('../support/large_text.txt', __dir__)
  LARGE_ZLIB_INPUT_PATH = File.expand_path('../support/large_zlib_input.txt', __dir__)

  describe 'Deflate' do
    it 'deflates' do
      deflated = Zlib::Deflate.deflate('hello world')
      deflated.should == "x\x9C\xCBH\xCD\xC9\xC9W(\xCF/\xCAI\x01\x00\x1A\v\x04]".force_encoding('ASCII-8BIT')
    end

    it 'deflates large inputs' do
      input = 'x' * 100_000
      deflated = Zlib::Deflate.deflate(input)
      deflated.bytes.should == [120, 156, 237, 193, 49, 1, 0, 0, 0, 194, 160, 218, 139, 111, 13, 15, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 87, 3, 126, 42, 37, 186]

      input = File.read(LARGE_TEXT_PATH)
      deflated = Zlib::Deflate.deflate(input, Zlib::BEST_COMPRESSION)
      deflated.should == File.read(LARGE_ZLIB_INPUT_PATH).force_encoding('ASCII-8BIT')
    end
  end

  describe 'Inflate' do
    it 'inflates' do
      deflated = "x\x9C\xCBH\xCD\xC9\xC9W(\xCF/\xCAI\x01\x00\x1A\v\x04]".force_encoding('ASCII-8BIT')
      Zlib::Inflate.inflate(deflated).should == 'hello world'
    end

    it 'inflates large inputs' do
      deflated = [120, 156, 237, 193, 49, 1, 0, 0, 0, 194, 160, 218, 139, 111, 13, 15, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 87, 3, 126, 42, 37, 186].map(&:chr).join.force_encoding('ASCII-8BIT')
      inflated = Zlib::Inflate.inflate(deflated)
      inflated.should == 'x' * 100_000

      deflated = File.read(LARGE_ZLIB_INPUT_PATH).force_encoding('ASCII-8BIT')
      inflated = Zlib::Inflate.inflate(deflated)
      inflated.should == File.read(LARGE_TEXT_PATH)
    end
  end
end
