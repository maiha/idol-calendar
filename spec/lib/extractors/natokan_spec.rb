# -*- coding: utf-8 -*-
require 'spec_helper'

describe Extractors::Natokan  do
  describe "#execute" do
    let(:events) {
      html   = load_fixture("extractors/natokan/live.html")
      events = Extractors::Natokan.new(html).execute
    }

    subject { events[0] }

    specify "イベント情報を抽出" do
      events.size.should == 24
    end

    # startの抽出
    its(:start) { should == Time.local(2013,6,21,16,30).to_datetime }

    # titleの抽出
    its(:summary) { should == "池袋サンシャインシティ" }

    # descriptionの抽出
    its(:description) { should_not be_blank }

    specify "イベント情報2を抽出" do
      events[1].start.to_s.should == "2013-06-22T17:30:00+09:00"
    end
  end
end
