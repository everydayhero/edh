require 'spec_helper'

describe EDH::Utils do
  describe ".logger" do
    it "has an accessor for logger" do
      EDH::Utils.methods.map(&:to_sym).should include(:logger)
      EDH::Utils.methods.map(&:to_sym).should include(:logger=)
    end
    
    it "defaults to the standard ruby logger with level set to ERROR" do |variable|
      EDH::Utils.logger.should be_kind_of(Logger)
      EDH::Utils.logger.level.should == Logger::ERROR
    end
    
    logger_methods = [:debug, :info, :warn, :error, :fatal]
    
    logger_methods.each do |logger_method|
      it "should delegate #{logger_method} to the attached logger" do
        EDH::Utils.logger.should_receive(logger_method)
        EDH::Utils.send(logger_method, "Test #{logger_method} message")
      end
    end
  end
end