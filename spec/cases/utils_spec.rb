require 'spec_helper'

describe Koala::Utils do
  describe ".logger" do
    it "has an accessor for logger" do
      Koala::Utils.methods.map(&:to_sym).should include(:logger)
      Koala::Utils.methods.map(&:to_sym).should include(:logger=)
    end
    
    it "defaults to the standard ruby logger with level set to ERROR" do |variable|
      Koala::Utils.logger.should be_kind_of(Logger)
      Koala::Utils.logger.level.should == Logger::ERROR
    end
    
    logger_methods = [:debug, :info, :warn, :error, :fatal]
    
    logger_methods.each do |logger_method|
      it "should delegate #{logger_method} to the attached logger" do
        Koala::Utils.logger.should_receive(logger_method)
        Koala::Utils.send(logger_method, "Test #{logger_method} message")
      end
    end
  end
end