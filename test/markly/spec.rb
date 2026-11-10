# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "markly"
require "markdown_spec"

MarkdownSpec.open("spec.txt").each do |testcase|
	next if testcase[:extensions].include?(:disabled)
	next if testcase[:example] == 617
	# This fork does not parse list markers: skip examples whose lists come from Markdown, keep raw HTML lists.
	next if testcase[:html].match?(/<(?:ul|ol|li)\b/) && !testcase[:markdown].match?(/<(?:ul|ol|li)\b/i)
	
	describe testcase[:section], unique: testcase[:example] do
		let(:document) {Markly.parse(testcase[:markdown], extensions: testcase[:extensions])}
		
		it "can convert to valid html" do
			actual = document.to_html(flags: Markly::UNSAFE, extensions: testcase[:extensions]).rstrip
			expect(actual).to be == testcase[:html]
		end
		
		it "can convert to valid html using the html renderer" do
			actual = Markly::Renderer::HTML.new(flags: Markly::UNSAFE, extensions: testcase[:extensions]).render(document).rstrip
			expect(actual).to be == testcase[:html]
		end
		
		it "can convert to valid html with source positions" do
			lhs = document.to_html(flags: Markly::UNSAFE|Markly::SOURCE_POSITION, extensions: testcase[:extensions]).rstrip
			rhs = Markly::Renderer::HTML.new(flags: Markly::UNSAFE|Markly::SOURCE_POSITION, extensions: testcase[:extensions]).render(document).rstrip
			expect(lhs).to be == rhs
		end
	end
end
