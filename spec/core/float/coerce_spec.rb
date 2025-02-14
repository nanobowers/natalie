require_relative '../../spec_helper'

describe "Float#coerce" do
  it "returns [other, self] both as Floats" do
    1.2.coerce(1).should == [1.0, 1.2]
    5.28.coerce(1.0).should == [1.0, 5.28]
    1.0.coerce(1).should == [1.0, 1.0]
    1.0.coerce("2.5").should == [2.5, 1.0]
    1.0.coerce(3.14).should == [3.14, 1.0]

    NATFIXME 'Coercion of Float with Bignum', exception: SpecFailedException do
      a, b = -0.0.coerce(bignum_value)
      a.should be_close(18446744073709551616.0, TOLERANCE)
      b.should be_close(-0.0, TOLERANCE)
      a, b = 1.0.coerce(bignum_value)
      a.should be_close(18446744073709551616.0, TOLERANCE)
      b.should be_close(1.0, TOLERANCE)
    end
  end
end
