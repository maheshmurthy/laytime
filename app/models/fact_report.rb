class FactReport
  attr_accessor :fact, :time_used, :running_total
  def initialize
    @fact = Fact.new
  end

  def fact
    @fact
  end
end
