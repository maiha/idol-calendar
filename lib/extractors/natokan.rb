# -*- coding: utf-8 -*-
module Extractors
  class Natokan 
    URL = "http://natokan.syncl.jp/?p=custom&id=18030995"

    def self.execute
      new(fetch).execute
    end

    def self.fetch
      open(URL).read{}
    end

    def initialize(html)
      @html = html
    end

    def execute
      split(@html).map{|html| build_event(html)}.compact
    end

    private
      def split(html)
        divs = html.split(/[・]{10,}/)
        divs.shift; divs.pop
        return divs
      end

      def build_event(html)
        event = Event.new

        text = html.dup
        text.gsub!(%r{</div>}i,"\n")
        text.gsub!(/<br>/i, "\n")
        text.gsub!(/<.*?>/,'') # strip tags
        text.gsub!(/&nbsp;/, "\n")
        text.gsub!(/\s*\n+\s*/, "\n")
        text.strip!
        
        # "６/２１\n（金）池袋サンシャインシティ\nstart16:30\nナト☆カン選抜\n「遠藤遥/倉田みずき/音華花/國武成美/熊谷彩香/ともパン」 ※ともパンはライブ出演のみとな ります。物販は参加しませんのでご了承ください。 共演： amooour/ 多国籍軍/ 水森由菜/他"

        text.tr!('０-９ａ-ｚＡ-Ｚ（）', '0-9a-zA-Z()')
        # "6/21\n（金）池袋サンシャインシティ\nstart16:30\nナト☆カン選抜\n「遠藤遥/倉田みずき/音華花/國武成美/熊谷彩香/ともパン」 ※ともパンはライブ出演のみとなります。物販は参加しませんのでご了承ください。 共演： amooour/ 多国籍軍/ 水森由菜/他"

        event.description = text

        case text
        when %r{^(\d{1,2})/(\d{1,2})\n*\(.*?\)(.*?)\n}m
          year  = Time.now.year
          month = $1.to_i
          day   = $2.to_i
          start = Time.local(year, month, day)
          event.label = $3
        else
          raise "date not found: " + text
        end

        case text
        when %r{^start(\d{2}):(\d{2})}m
          start = start.change(:hour => $1.to_i, :min => $2.to_i)
        end

        event.start = start.to_datetime

        return event
      end
  end
end
