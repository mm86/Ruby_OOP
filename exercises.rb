# The Object Model

1. How to create an object in Ruby?

Objects are created from classes. In order to create an object, we should
first create a class such as 
class Example
end
obj = Example.new

The new method is used to create an instance/object of a class.

2. Explain module

Modules are great to group reusable code in one place.
Modules can be used in classes by using the include reserved word.

Example:

module Message
  def message
    puts "hello"
  end
end

class Example
  include Message
end

a = Example.new
a.message

# Classes and Objects - Part 1




# Classes and Objects - Part 2

# Inheritance

