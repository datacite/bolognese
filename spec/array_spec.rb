# frozen_string_literal: true

require 'spec_helper'

describe Array do
  describe "unwrap" do
    it "to array" do
      arr = [1, 2, 3]
      expect(arr.unwrap).to eq(arr)
    end

    it "to integer" do
      arr = [1]
      expect(arr.unwrap).to eq(1)
    end

    it "to nil" do
      arr = []
      expect(arr.unwrap).to be_nil
    end
  end
end
