=begin

"<p class='foo bar' id='baz' name='fozzie'>"

"<div id = 'bim'>"

"<img src='http://www.example.com' title='funny things'>"

=end

def parse_tag(string)

  output = {}

  tag_match = string.match(/<([a-z]+[1-6]*)\s/)
  output[:tag] = tag_match[1]

  class_string = string.match(/class=['"](.+?)['"]/)
  class_matches = class_string[1].to_s.split(" ")
  output[:classes] = class_matches

  id_match = string.match(/id=['"](.+?)['"]/)
  output[:id] = id_match[1]

  name_match = string.match(/name=['"](.+?)['"]/)
  output[:name] = name_match[1]

  output

end