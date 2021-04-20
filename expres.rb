class Demo
  OPERATORS = ["and", "or"]
  DICT = { "A" => "Hello", "B" => "World" }

  def self.const_data(data, variable = [])
    operator = ""
    data.each do |name|
      variable << name && next unless OPERATORS.include?(name)
      operator = name
    end
    if operator == "and"
      return DICT[variable[0]] + DICT[variable[1]]
    else
      return or_text(DICT[variable[0]], DICT[variable[1]])
    end
  end

  def self.or_text(one, two)
    return one if one && !one.empty?
    return two if two
  end

end


str = "A and B"

puts Demo.const_data(str.split(" "))

