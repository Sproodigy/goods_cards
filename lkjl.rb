class Bottle
    def capacity
        @capacity
    end

    def capacity=(new_cap)
        @capacity = new_cap
    end
end

a = Bottle.new
puts a.capacity = (38)
