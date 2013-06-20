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
    its(:label) { should == "池袋サンシャインシティ" }

    # descriptionの抽出
    its(:description) { should_not be_blank }
  end
end

__END__

      events.first.should == Event.new

id           | text                        | not null
 calendar_id  | integer                     |
 created      | timestamp without time zone |
 updated      | timestamp without time zone |
 start        | timestamp without time zone |
 end          | timestamp without time zone |
 summary      | text                        |
 description  | text                        |
 location     | text                        |
 htmlLink     | text                        |
 last_updated | timestamp without time zone |
 label        | text                        |

    end
  end
end
