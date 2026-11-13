# frozen_string_literal: true

require "markly"

describe Markly do
	with "Markly::NO_HTML_BLOCKS" do
		def nodes(source, flags: Markly::NO_HTML_BLOCKS)
			Markly.parse(source, flags: flags).walk.to_a
		end
		
		let(:markdown) {"<div>\n**bold** [link](https://example.com)\n</div>"}
		
		it "keeps default HTML block parsing unchanged" do
			document = Markly.parse(markdown)
			
			expect(document.first_child.type).to be == :html
			expect(document.first_child.string_content).to be == "#{markdown}\n"
		end
		
		it "parses Markdown between literal HTML tags" do
			nodes = nodes(markdown)
			
			expect(nodes.map(&:type)).to be(:include?, :strong)
			expect(nodes.find{|node| node.type == :link}&.url).to be == "https://example.com"
			expect(nodes.select{|node| node.type == :html}).to be == []
			expect(nodes.select{|node| node.type == :inline_html}.map(&:string_content)).to be == ["<div>", "</div>"]
		end
		
		it "does not open any raw HTML block type except comments" do
			{
				"<pre>" => "<pre>\n**x**\n</pre>",
				"<script>" => "<script>\n**x**\n</script>",
				"<?xml version=\"1.0\"?>" => "<?xml version=\"1.0\"?>\n**x**",
				"<!DOCTYPE html>" => "<!DOCTYPE html>\n**x**",
				"<![CDATA[ a ]]>" => "<![CDATA[ a ]]>\n**x**",
				"<table>" => "<table>\n**x**\n</table>",
				"<custom-tag>" => "<custom-tag>\n**x**\n</custom-tag>",
			}.each do |tag, source|
				nodes = nodes(source)
				
				expect(nodes.select{|node| node.type == :html}).to be == []
				expect(nodes.find{|node| node.type == :inline_html}&.string_content).to be == tag
				expect(nodes.map(&:type)).to be(:include?, :strong)
			end
		end
		
		it "retains HTML comments as blocks" do
			{
				"<!-- service -->\n**visible**" => "<!-- service -->\n",
				"<!-- service\n\ncomment -->\n**visible**" => "<!-- service\n\ncomment -->\n",
			}.each do |source, comment|
				document = Markly.parse(source, flags: Markly::NO_HTML_BLOCKS)
				
				expect(document.first_child.type).to be == :html
				expect(document.first_child.string_content).to be == comment
				expect(document.first_child.next.first_child.type).to be == :strong
			end
		end
		
		it "keeps an unclosed comment open until the end, as by default" do
			source = "<!-- service\n**hidden**"
			
			expect(Markly.parse(source, flags: Markly::NO_HTML_BLOCKS).to_html(flags: Markly::UNSAFE)).to be == Markly.parse(source).to_html(flags: Markly::UNSAFE)
		end
		
		it "preserves literal HTML and comments inside code" do
			source = "<div>\n```html\n<x>\n<!-- keep -->\n```\n`<!-- inline -->`\n</div>\n\n    <p>indented</p>"
			nodes = nodes(source)
			
			expect(nodes.select{|node| node.type == :code_block}.map(&:string_content)).to be == ["<x>\n<!-- keep -->\n", "<p>indented</p>\n"]
			expect(nodes.find{|node| node.type == :code}&.string_content).to be == "<!-- inline -->"
		end
		
		it "handles many blocks and deeply nested tags" do
			source = ("<div>\n**one**\n</div>\n\n" * 60) + ("<div>\n" * 30) + "**nested**\n" + ("</div>\n" * 30)
			nodes = nodes(source)
			
			expect(nodes.count{|node| node.type == :strong}).to be == 61
			expect(nodes.select{|node| node.type == :html}).to be == []
		end
		
		it "keeps source positions tied to the original Markdown" do
			strong = nodes("<div>\n**😀**\n</div>").find{|node| node.type == :strong}
			
			expect(strong&.source_position).to be == {start_line: 2, start_column: 1, end_line: 2, end_column: 8}
		end
	end
end
