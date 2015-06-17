=begin

Process to build the DOM tree:

0) Create Node struct with fields (name, text, classes, id, children, parent)
1) Identify and capture shallowest depth of nodes:
  - <h3>...<span>...</span>...</h3> should start capturing at <h3> and not end until that specific tag is closed </h3>
  - Saving the opening tag to a local variable will allow us to find the matching closing tag in regex, and not get stuck on interior closing tags like </span>
  - Parse Node text between tags into Node fields (special handling for Text below)
  - At that point, it should look for the next opening tag <..>
  - Repeat until no more tags
2) Repeat Step 1 inside each of the nodes already created to get the next layer of depth
3) Continue repeating inside each node until no tags left (note that this sounds recursive with the base case = no children)


  Text field needs to include "any non-HTML text contained within the node which is NOT another HTML tag or its contents"
  - We will have to store the entire contents between opening/closing tags as a separate field, "full_text", since that will be used to build out the child nodes
  - The "text" field will be created to select only the specific text from "full_text" matching the definition above using regex.


Second thoughts: it may be helpful to start with an ordered array of tags as they occur:
  <html>,<head>,<title>,</title>,</head> etc...
This array could then be used to build simple tree with just parent/child relationships (not worrying about parsing data just yet).
Then it's possible to start with innermost child for data parsing and spread outward, which will help with situations of divs within divs that can't be easily handled by regex alone.  If we know what children to expect inside tags, it makes it easier to properly identify the right closing tag.

=end


Node = Struct.new(:name, :full_text, :text, :classes, :id, :children, :parent)


class DOMReader

  def initialize
  end


  def build_tree(html_file)
    # load in .html file
    file_text = load_file(html_file)

    # create document node as everything between <html> tags

    # find first tag
    next_tag = find_next_tag(file_text)

    # capture everything between that tag and closing tag
    capture_data = capture_between(next_tag, file_text)

    # build node based on that capture
    build_node(capture_data)

  end


  private


  def load_file(filename)
    input = File.read(filename)

    # remove <!doctype html>
    input.match(/<!doctype html>/i).post_match.strip
  end


  def find_next_tag(string)
    string.match(/(<[a-z]+[1-6]*.*?>)/)[1]
  end


  def capture_between(tag, string)
    close_tag = tag.match(/<(\S+)\s?.*?>/)[1] # currently loses track if </div> w/in a </div>
    text_match = string.match(/#{tag}(.*?)<\/#{close_tag}>/m)[1]

    [tag, close_tag, text_match]
  end


  def parse_tag(data)

    output = {}

    # name_match = string.match(/<(\S+)\s?.*?>/)
    output[:name] = data[1]
    full_tag = data[0]

    output[:classes], output[:id] = nil, nil

    class_string = full_tag.match(/class=['"](.+?)['"]/)
    output[:classes] = class_string[1].to_s.split(" ") unless class_string.nil?

    id_match = full_tag.match(/id=['"](.+?)['"]/)
    output[:id] = id_match[1] unless id_match.nil?


    #name_match = full_tag.match(/name=['"](.+?)['"]/)
    #output[:name] = name_match[1]

    output

  end


  def build_document_node
    # new_node = Node.new()
  end


  def build_node(capture_data)
    tag_data = parse_tag(capture_data)

    new_node = Node.new(tag_data[:name], capture_data[2], "text", tag_data[:classes], tag_data[:id], "children", "parent")
  end

end