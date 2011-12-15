require 'emoji'

module GitHub::HTML
  # HTML filter that replaces :emoji: with images.
  class EmojiFilter < Filter
    # Build a regexp that matches all valid :emoji: names.
    EmojiPattern = /:(#{Emoji.names.map { |name| Regexp.escape(name) }.join('|')}):/

    def call
      doc.search('text()').each do |node|
        content = node.to_html
        next if !content.include?(':')
        next if node.ancestors('pre, code').any?
        html = self.class.emoji_image_filter(content)
        next if html == content
        node.replace(html)
      end
      doc
    end

    # Replace :emoji: with corresponding images.
    #
    # text - String text to replace :emoji: in.
    #
    # Returns a String with :emoji: replaced with images.
    def self.emoji_image_filter(text)
      return text unless text.include?(':')

      text.gsub EmojiPattern do |match|
        name = $1
        "<img class='emoji' title=':#{name}:' alt=':#{name}:' src='#{GitHub.asset_host_url}/images/icons/emoji/#{name}.png?v5' height='20' width='20' align='absmiddle' />"
      end
    end
  end
end
