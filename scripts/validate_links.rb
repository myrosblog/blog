#!/usr/bin/env ruby

require 'find'
require 'uri'

def validate_links
  puts "Starting link validation..."
  
  markdown_links = []
  html_links = []
  issues = []
  
  # Find all markdown files
  Find.find('_posts') do |file|
    next unless file.end_with?('.md')
    
    content = File.read(file)
    
    # Extract markdown links
    content.scan(/\[([^\]]+)\]\(([^)]+)\)/).each do |text, url|
      next if url.start_with?('http') # Skip external links
      next if url.start_with?('{%') # Skip liquid tags
      
      markdown_links << {file: file, text: text, url: url}
    end
    
    # Extract HTML links
    content.scan(/<a\s+[^>]*href="([^"]+)"[^>]*>([^<]+)<\/a>/).each do |url, text|
      next if url.start_with?('http') # Skip external links
      
      html_links << {file: file, text: text, url: url}
    end
  end
  
  # Validate markdown links
  markdown_links.each do |link|
    url = link[:url]
    
    # Check for missing leading slash
    if url.start_with?('20') && !url.start_with?('/')
      issues << "Missing leading slash in #{link[:file]}: #{url}"
    end
    
    # Check for proper escaping
    if url.include?('&') && !url.include?('&amp;')
      issues << "Unescaped ampersand in #{link[:file]}: #{url}"
    end
    
    # Check if internal post links should use post_url (only for /YYYY/MM/ patterns, not assets)
    if url.match?(%r{/\d{4}/\d{2}/}) && !url.include?('/assets/')
      issues << "Consider using post_url for #{link[:file]}: #{url}"
    end
  end
  
  # Validate HTML links
  html_links.each do |link|
    url = link[:url]
    
    # Check for proper HTML escaping
    if url.include?('&') && !url.include?('&amp;')
      issues << "Unescaped ampersand in HTML link #{link[:file]}: #{url}"
    end
    
    if url.include?('<') || url.include?('>')
      issues << "Unescaped angle brackets in HTML link #{link[:file]}: #{url}"
    end
  end
  
  # Report results
  puts "Found #{markdown_links.length} markdown links"
  puts "Found #{html_links.length} HTML links"
  
  if issues.empty?
    puts "✅ All links are HTML-proof!"
  else
    puts "❌ Found #{issues.length} issues:"
    issues.each { |issue| puts "  - #{issue}" }
  end
  
  issues.empty?
end

if __FILE__ == $0
  success = validate_links
  exit(success ? 0 : 1)
end