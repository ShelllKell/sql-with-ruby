require "database_connection"

class SqlExercise

  attr_reader :database_connection

  def initialize
    @database_connection = DatabaseConnection.new
  end

  def all_customers
    database_connection.sql("SELECT * from customers")
  end

  def limit_customers(number)
    database_connection.sql("SELECT * from customers limit '#{number}'")
  end

  def order_customers(order)
    database_connection.sql("SELECT * FROM customers ORDER BY name #{order}")
  end

  def id_and_name_for_customers
    database_connection.sql("SELECT id, name FROM customers")
  end

  def all_items
    database_connection.sql("SELECT * from items")
  end

  def find_item_by_name(name)
    if name != []
    database_connection.sql("SELECT id, name, description FROM items WHERE name = '#{name}'")[0]
    else
     (nil)
    end
  end

  def count_customers
    hash = database_connection.sql("SELECT COUNT (name) FROM customers").first
    hash['count'].to_i
  end

    def sum_order_amounts
      hash = database_connection.sql("SELECT SUM (amount) FROM orders").first
      hash['sum'].to_f
    end

  def minimum_order_amount_for_customers
    database_connection.sql("SELECT customer_id, MIN (amount) FROM orders GROUP BY customer_id")
  end

  def customer_order_totals
      database_connection.sql(<<-SQL
      SELECT orders.customer_id, customers.name, SUM(orders.amount)
      FROM customers
      JOIN orders
      ON customers.id=orders.customer_id
      GROUP BY orders.customer_id, customers.name
      ORDER BY orders.customer_id")
      SQL
  end

  def items_ordered_by_user(number)
    array = database_connection.sql(<<-SQL
    select items.name
    from items
    join orderitems
    on items.id=orderitems.item_id
    join orders
    on orders.id=orderitems.order_id
    where customer_id = #{number})
    SQL
    array.collect {|x| x["name"]}
  end

  def customers_that_bought_item(id)
    command = <<-SQL
    SELECT customers.name AS customer_name, customers.id
    FROM customers
    JOIN orders
    ON customers.id=orders.customer_id
    JOIN orderitems
    ON orderitems.order_id=orders.id
    JOIN items
    ON items.id=orderitems.item_id
    WHERE items.name = '#{id}'
    GROUP BY customers.name, customers.id
    SQL
    database_connection.sql(command)
  end

  def customers_that_bought_item_in_state(item, state)
    command = <<-SQL
    SELECT customers.id, customers.name, customers.email, customers.address, customers.city, customers.state, customers.zipcode
    FROM customers
    JOIN orders
    ON customers.id=orders.customer_id
    JOIN orderitems
    ON orderitems.order_id=orders.id
    JOIN items
    ON items.id=orderitems.item_id
    WHERE items.name = '#{item}' AND customers.state = '#{state}'
    GROUP BY customers.name, customers.id
    SQL
    database_connection.sql(command).first
  end
end