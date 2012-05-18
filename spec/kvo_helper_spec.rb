class Example
  include KVOHelper
  
  def initialize
    @label = UILabel.alloc.initWithFrame [[0,0],[320, 30]]
    @label.text = "Foo"
  end
  
  def label
    @label
  end
  
  def observe_label(&block)
    observe(@label, "text", &block)
  end
    
  def unobserve_all
    unobserve(@label, "text")
  end
  
end

describe "KVOHelper" do
  
  before do
    @example = Example.new
  end
  
  after do
    @example.unobserve_all
  end
  
  it "should be able to observe a key path" do
    observed = false
    @example.observe_label do |label, old_value, new_value|
      observed = true
      @example.label.should == label
      old_value.should == "Foo"
      new_value.should == "Bar"
    end
    @example.label.text = "Bar"
    observed.should == true
  end
  
  it "should be able to observe a key path with more than one block" do
    observed_one = false
    observed_two = false
    observed_three = false
    
    @example.observe_label do |label, old_value, new_value|
      observed_one = true
    end
    @example.observe_label do |label, old_value, new_value|
      observed_two = true
    end
    @example.observe_label do |label, old_value, new_value|
      observed_three = true
    end
    
    @example.label.text = "Bar"
    
    observed_one.should == true
    observed_two.should == true
    observed_three.should == true
  end
  
end
