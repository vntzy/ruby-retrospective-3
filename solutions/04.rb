module Registers
  def ax
    :@ax
  end

   def bx
     :@bx
  end

  def cx
    :@cx
  end

  def dx
    :@dx
  end
end

module Jump
  def jmp(where)
    if @finalization_flag
      if where.instance_of? Fixnum then
        @counter = where
      else
        @counter = @tasks.index [:label, where]
      end
    else
      @tasks << [:jmp, where]
    end
  end

  def je(where)
    if @finalization_flag then
      jmp where if @last_cmp == 0
    else
      @tasks << [:je, where]
    end
  end

  def jne(where)
    if @finalization_flag then
      jmp where if @last_cmp != 0
    else
      @tasks << [:jne, where]
    end
  end

  def jl(where)
    if @finalization_flag then
      jmp where if @last_cmp < 0
    else
      @tasks << [:jl, where]
    end
  end

  def jle(where)
    if @finalization_flag then
      jmp where if @last_cmp <= 0
    else
      @tasks << [:jle, where]
    end
  end

  def jg(where)
    if @finalization_flag then
      jmp where if @last_cmp > 0
    else
      @tasks << [:jg, where]
    end
  end

  def jge(where)
    if @finalization_flag then
      jmp where if @last_cmp >= 0
    else
      @tasks << [:jge, where]
    end
  end
end

module Asm
  class Evaluator
    include Jump
    include Registers
    def initialize
      @ax = 0
      @bx = 0
      @cx = 0
      @dx = 0
      @tasks = []
      @finalization_flag = false
      @last_cmp = 0
      @counter = 0
    end

    def mov(destination_register, source)
      if @finalization_flag then
        if source.instance_of? Symbol then
          source = instance_variable_get(source)
        end
        instance_variable_set(destination_register, source)
      else
        @tasks << [:mov, destination_register, source]
      end
    end

    def inc(destination_register, value = 1)
      if @finalization_flag then
        if value.instance_of? Symbol then
          value = instance_variable_get(value)
        end
        instance_variable_set(destination_register,
          instance_variable_get(destination_register) + value)
      else
        @tasks << [:inc, destination_register, value]
      end
    end

    def dec(destination_register, value = 1)
      if @finalization_flag then
        if value.instance_of? Symbol then
          value = instance_variable_get(value)
        end
        instance_variable_set(destination_register,
          instance_variable_get(destination_register) - value)
      else
        @tasks << [:dec, destination_register, value]
      end
    end

    def cmp(register, value)
      if @finalization_flag then
        if value.instance_of? Symbol then
          value = instance_variable_get(value)
        end
        instance_variable_set(:@last_cmp, instance_variable_get(register) <=> value)
      else
        @tasks << [:cmp, register, value]
      end
    end

    def label(label_name)
      @tasks << [:label, label_name]
    end

    def method_missing(name, *args, &block)
      name.to_s
    end

    def print
      @finalization_flag = true
      while @tasks[@counter]
        @counter += 1
        if [:mov,:inc,:dec,:cmp].include? @tasks[@counter-1].first then
          self.send @tasks[@counter-1][0], @tasks[@counter-1][1], @tasks[@counter-1][2]
        elsif [:jmp,:je,:jne,:jl,:jle,:jg,:jge].include? @tasks[@counter-1].first then
          self.send @tasks[@counter-1][0], @tasks[@counter-1][1]
        end
      end
      [@ax, @bx, @cx, @dx]
    end
  end

  def self.asm(&block)
    b = ->(x) do
      x.instance_eval &block
      x.print
    end
    Evaluator.new.instance_eval &b
  end
end