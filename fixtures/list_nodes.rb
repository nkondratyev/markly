# frozen_string_literal: true

require "markly"

# The parser in this fork does not recognise list markers, so tests that need list nodes build them by hand.
module ListNodes
	def self.list(type, items, start: nil)
		list = Markly::Node.new(:list)
		list.list_type = type
		list.list_start = start if start
		list.list_tight = true
		
		items.each do |content|
			text = Markly::Node.new(:text)
			text.string_content = content
			paragraph = Markly::Node.new(:paragraph)
			paragraph.append_child(text)
			item = Markly::Node.new(:list_item)
			item.append_child(paragraph)
			list.append_child(item)
		end
		
		list
	end
	
	def self.document(type, items, start: nil)
		document = Markly::Node.new(:document)
		document.append_child(list(type, items, start: start))
		document
	end
end
