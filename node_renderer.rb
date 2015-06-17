require './dom_reader.rb'


class NodeRenderer

  def initialize(tree)
    @tree = tree
  end


  def render(node = nil)
    node = @tree.root if node.nil?

    descendant_stats = count_descendants(node)

    # All of the node's data attributes
    render_attributes(node)

    # How many total nodes there are in the sub-tree below this node
    puts "\nTotal descendant nodes: #{descendant_stats[0]}"

    # A count of each node type in the sub-tree below this node
    puts "\nDescendants by name:"
    render_descendants(descendant_stats[1])

  end


  private


  def count_descendants(node)

    queue = [node]
    total = 0
    types = {}

    until queue.empty?
      node = queue.shift

      node.children.each do |child|
        types[child.name] ||= 0
        types[child.name] += 1
        queue << child
      end

      total = types.values.inject { |sum, value| sum += value }

    end

    [total, types]

  end


  def render_attributes(node)
    puts "\nCURRENT NODE"
    puts "\tName: #{node.name}"
    puts "\tText: #{node.text}"
    puts "\tClasses: #{node.classes}"
    puts "\tID: #{node.id}"

    child_names = get_child_names(node)
    puts "\tChildren: #{child_names}"

    parent = get_parent_name(node)
    puts "\tParent: #{parent}"
  end


  def render_descendants(name_counts)
    name_counts.each { |key, value| puts "\t<#{key}> = #{value}"}
    return
  end


  def get_child_names(node)
    child_names = []
    node.children.each { |child| child_names << child.name }
    #node.children
    child_names.join(", ")
  end

  def get_parent_name(node)
    parent_name = ""
    parent_name = node.parent.name unless node.parent.nil?
  end

end