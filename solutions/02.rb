class TodoList
  include Enumerable
  attr_accessor :tasks

  def initialize(tasks)
    @tasks = tasks
  end

  def self.parse(text)
    TodoList.new(text.split("\n").map { |line| Task.new(line) })
  end

  def each(&block)
    @tasks.each(&block)
  end

  def filter(criteria)
    TodoList.new(self.tasks.select { |task|  criteria.fulfill(task) })
  end

  def adjoin(other)
    TodoList.new(self.tasks + other.tasks)
  end

  def tasks_todo
    tasks.select { |task| task.status == :todo}.size
  end

  def tasks_in_progress
    tasks.select { |task| task.status == :current}.size
  end

  def tasks_completed
    tasks.select { |task| task.status == :done}.size
  end
end

class Task
  attr_accessor :status, :description, :prior, :tags

  def initialize(text)
    info = text.split('|').map(&:strip)
    @status, @description = info[0].downcase.to_sym, info[1]
    @prior = info[2].downcase.to_sym
    @tags = info[3] == nil ? [] : info[3].split(',').map(&:strip)
  end
end

class Criteria
  attr_accessor :status, :prior, :tags

  def fulfill(task)
    status==task.status or prior==task.prior or tags&task.tags==tags
  end

  def !
    CompositionCriteria.new([self], :'!')
  end

  def |(other)
    CompositionCriteria.new([self, other], :|)
  end

  def &(other)
    CompositionCriteria.new([self, other], :&)
  end

  def initialize(*args)
      @status, @prior, @tags = args[0], args[1], args[2]
  end

  class << self
    def status(status)
      Criteria.new(status, nil, nil)
    end

    def priority(prior)
      Criteria.new(nil, prior, nil)
    end

    def tags(tags)
      Criteria.new(nil, nil, tags)
    end
  end
end

class CompositionCriteria < Criteria
  attr_accessor :criterias, :operator

  def fulfill(task)
    case @operator
      when :'!' then not @criterias[0].fulfill(task)
      when :& then @criterias[0].fulfill(task) and @criterias[1].fulfill(task)
      when :| then @criterias[0].fulfill(task) or @criterias[1].fulfill(task)
    end
  end

  def initialize(*args)
    @criterias, @operator = args[0], args[1]
  end
end