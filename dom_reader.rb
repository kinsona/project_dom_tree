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


Second thoughts:
  It may be helpful to start with an ordered array of tags as they occur:
    <html>,<head>,<title>,</title>,</head> etc...
  This array could then be used to build simple tree with just parent/child relationships (not worrying about parsing data just yet).
  Then it's possible to start with innermost child for data parsing and spread outward, which will help with situations of divs within divs that can't be easily handled by regex alone.  If we know what children to expect inside tags, it makes it easier to properly identify the right closing tag.

  Now that I've got my tree, I can step through starting at the root to fill in the rest of the data:
  - full_text:
  - name:
  - text:
  - classes:
  - id:


=end


Node = Struct.new(:name, :text, :classes, :id, :children, :parent)


class DOMReader
  attr_reader :root

  def initialize
    @root = nil
  end


  def build_tree(html_file)
    # load in .html file
    file_text = load_file(html_file)

    # build array of tags to ID parent/child relationships
    build_relationships(file_text)

  end


  private


  def load_file(filename)
    input = File.read(filename)

    # This removes <!doctype html>
    input.match(/<!doctype html>/i).post_match.strip
  end


  def build_relationships(string)
    all_tags = string.scan(/(\/?[a-z]+[1-6]*.*?)>(.*?)</m) # currently misses last </html> -> does not impact results

    # use stack to handle parent/child relationships
    relationship_stack = []

    all_tags.each do |tag|
      build_base_node(tag, relationship_stack)
    end

  end


  def build_base_node(tag, stack)
    text = tag[1].strip

    # if </close> tag, pop top stack item, put any leftover text onto the new top stack item (aka parent)
    if tag[0].strip.include?("/")
      stack.pop
      stack.last[:text] << " #{text}" unless text.empty?

    # if <open> tag, assign top stack item as parent, add self to parent's children array, and put self on top of stack
    else
      tag_data = parse_tag(tag[0])

      parent = stack.last

      new_node = Node.new(tag_data[:name], text, tag_data[:classes], tag_data[:id], [], parent)
      parent[:children] << new_node unless parent.nil?
      @root = new_node if parent.nil?
      stack << new_node
    end
  end


  def parse_tag(full_tag)

    output = {}

    name_match = full_tag.match(/\A(\S+)\s?/)
    output[:name] = name_match[1]


    output[:classes], output[:id] = nil, nil

    class_string = full_tag.match(/class=['"](.+?)['"]/)
    output[:classes] = class_string[1].to_s.split(" ") unless class_string.nil?

    id_match = full_tag.match(/id=['"](.+?)['"]/)
    output[:id] = id_match[1] unless id_match.nil?


    output

  end


end