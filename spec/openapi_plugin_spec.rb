# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Plugin::Openapi do
  it "reports its version" do
    expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
