class Node
  include Comparable
  attr :data
  attr_accessor :left_child, :right_child, :data

  def <=>(other)
    data <=> other.data
  end

  def initialize(data,left=nil,right=nil)
    @data = data
    @left_child = left
    @right_child = right
  end

  def children
    children = 0
    children += 1 unless left_child.nil?
    children += 1 unless right_child.nil?
    children
  end
end

class Tree
  attr :root

  def initialize(array)
    @array = array 
    @root = build_tree(@array)
  end

  def build_tree(array)
    return nil if array.length-1 < 0
    array = array.sort.uniq
    mid = (array.length-1) / 2 
    node = Node.new(array[mid])
    node.left_child = build_tree(array[0,mid])
    node.right_child = build_tree(array[mid+1,array.length-1])
    return node
  end

  def insert(value)
    new_node = Node.new(value)
    pointer = root
    prev_pointer = nil
    until prev_pointer == pointer
      return if pointer == new_node
      prev_pointer = pointer
      pointer = pointer.left_child if new_node < pointer && !pointer.left_child.nil?
      pointer = pointer.right_child if new_node > pointer && !pointer.right_child.nil?
    end
    new_node > pointer ? pointer.right_child = new_node : pointer.left_child = new_node
  end

  def delete(value)
    value_node = Node.new(value)
    pointer = root
    parent_pointer = nil
    until pointer == value_node
      return "There's no such value in this tree" if pointer.nil?
      parent_pointer = pointer
      case value_node < pointer
        when true then pointer = pointer.left_child
        when false then pointer = pointer.right_child
      end
    end

    case pointer.children
    when 0 # case for leaf node
      parent_pointer.left_child.nil? ? parent_pointer.right_child = nil : parent_pointer.right_child = nil
    when 1 # case for node with only 1 child
      pointer_child = pointer.left_child.nil? ? pointer.right_child : pointer.left_child
      parent_pointer.left_child == pointer ? parent_pointer.left_child = pointer_child : parent_pointer.right_child = pointer_child
    when 2 # case for node with 2 children 
      right_child = pointer.right_child
      left_child = right_child.left_child
      prev_child = right_child
      if !left_child.nil?
        until left_child.left_child.nil?
          prev_child = left_child
          left_child = left_child.left_child
        end
        if left_child.children == 1
          prev_child.left_child = left_child.right_child # right child of the left child becomes left child of the node before last left node 
        end
        pointer.data = left_child.data
      else
        pointer.data = right_child.data
        pointer.right_child = right_child.right_child
      end
    end
  end

  def find(value, pointer=root)
    value = Node.new(value) unless value.class == Node
    return "There's no such value in this tree" if pointer.nil?
    return pointer if value == pointer
    case pointer > value
      when true then self.find(value, pointer.left_child)
      when false then self.find(value, pointer.right_child)
    end 
  end

  def level_order_iterative
    values = []
    queue = []
    queue << root
    until queue.empty?
      queue << queue[0].left_child unless queue[0].left_child.nil?
      queue << queue[0].right_child unless queue[0].right_child.nil? 
      values << queue.shift
    end
    values.map(&:data)
  end

  def level_order_recursive(queue=[root], values=[])
    return values.map(&:data) if queue.empty?
    queue << queue[0].left_child unless queue[0].left_child.nil?
    queue << queue[0].right_child unless queue[0].right_child.nil? 
    values << queue.shift
    level_order_recursive(queue, values)
  end

  def inorder(root=@root, values=[])
    return values if root.nil?
    inorder(root.left_child, values)
    values << root.data
    inorder(root.right_child, values)
  end
  
  def preorder(root=@root, values=[])
    return values if root.nil?
    values << root.data
    preorder(root.left_child, values)
    preorder(root.right_child, values)
  end

  def postorder(root=@root, values=[])
    return values if root.nil?
    postorder(root.left_child, values)
    postorder(root.right_child, values)
    values << root.data
  end

  def depth(node=root)
    unless node.nil?
      left_depth = depth(node.left_child)
      right_depth = depth(node.right_child)
      left_depth > right_depth ? left_depth + 1 : right_depth + 1
    else
      -1
    end
  end

  def balanced?
    if root.children == 2
      self.depth(root.right_child) - self.depth(root.left_child) > 1 ? false : true
    else
      self.depth(root) > 1 ? false : true
    end
  end

  def rebalance
    return puts "The tree is balanced" if self.balanced?
    level_order_array = self.level_order_recursive
    left_subtree = level_order_array.select{ |node| node < root.data}
    right_subtree = level_order_array.select{ |node| node > root.data}
    difference = left_subtree.length - right_subtree.length
    if difference < 0
      difference.abs.times do 
        level_order_array << (Array(1..root.data) - left_subtree).sample
      end
    else
      difference.times do 
        level_order_array << rand(root.data + 1..1337)
      end
    end
    @root = build_tree(level_order_array)
  end

  def to_s
    pretty_print
  end

  def pretty_print(node = @root, prefix="", is_left = true)
    pretty_print(node.right_child, "#{prefix}#{is_left ? "│ " : " "}", false) if node.right_child
    puts "#{prefix}#{is_left ? "└── " : "┌── "}#{node.data.to_s}"
    pretty_print(node.left_child, "#{prefix}#{is_left ? " " : "│ "}", true) if node.left_child
  end

end


array = Array.new(15) { rand(1..100) }
tree = Tree.new(array)

puts tree.balanced?
p tree.level_order_recursive
p tree.preorder
p tree.postorder
p tree.inorder
tree.insert(120)
tree.insert(140)
tree.insert(160)
puts tree.balanced?
puts tree
tree.rebalance
puts tree.balanced?
puts tree
p tree.level_order_recursive
p tree.preorder
p tree.postorder
p tree.inorder
p tree.depth
p tree.delete(array[5])