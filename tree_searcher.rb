#require './dom_reader.rb'


class TreeSearcher

  def initialize(tree)
    @tree = tree
  end


  def search_by(field, value)
    # Search for and return a collection with all nodes exactly matching the name, text, id, or class provided
    queue = [@tree.root]
    crawl_down_tree(queue, field, value)
  end


  def search_children(node, field, value)
    # Search just the tree beginning at a particular node
    queue = [node]
    crawl_down_tree(queue, field, value)
  end


  def search_ancestors(node, field, value)
    # Search just the direct ancestors of a particular node
    # Is this supposed to be just like search_children, but
    # Excluding the starting node?
    queue = []
    node.children.each { |child| queue << child }
    crawl_down_tree(queue, field, value)
  end


  private


  def crawl_down_tree(queue, field, value)
    output = []

    until queue.empty?
      check_node = queue.shift

      output << check_node if field_match?(check_node, field, value)

      check_node.children.each { |child| queue << child }
    end

    output

  end


  def field_match?(node, field, value)
    if field == :class
      node[:classes] ||= []
      node[:classes].include?(value)
    else
      node[field] == value
    end
  end

end