# frozen_string_literal: true

require "markly"

describe Markly do
	with "list markers disabled in this fork" do
		it "keeps list markers as literal text" do
			expect(Markly.render_html("- bullet\n* star\n1. one\n2) two\n")).to be == "<p>- bullet\n* star\n1. one\n2) two</p>\n"
		end
		
		it "keeps raw HTML lists" do
			html = "<ul>\n<li>one</li>\n</ul>\n<ol start=\"3\">\n<li>three</li>\n</ol>\n"
			expect(Markly.render_html(html, flags: Markly::UNSAFE)).to be == html
		end
		
		it "keeps footnotes" do
			html = Markly.render_html("Text[^note].\n\n[^note]: Definition.\n", flags: Markly::FOOTNOTES)
			expect(html).to be =~ /class="footnote-ref"/
		end
	end
end
