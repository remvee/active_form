require 'rubygems'
require 'active_record'

require File.dirname(__FILE__) + '/../lib/active_form'
require 'test/unit'

class ActiveFormTest < Test::Unit::TestCase
  def test_class_loads
    assert_nothing_raised { ActiveForm }
  end
  
  def test_can_add_columns
    self.class.class_eval %q{
      class CanAddColumns < ActiveForm
        %w(foo bar test).each { |c| column c }
      end
    }
    assert_equal 3, CanAddColumns.columns.size
  end
  
  def test_type_properly_set
    self.class.class_eval %q{
      class TypeProperlySet < ActiveForm
        %w(string text date datetime boolean).each do |type|
          column "a_#{type}".to_sym, :type => type.to_sym
        end
      end
    }
    
    assert TypeProperlySet.columns.size > 0, 'no columns added'
    
    %w(string text date datetime boolean).each do |type|
      assert_equal type, TypeProperlySet.columns_hash["a_#{type}"].sql_type
    end
  end
  
  def test_default_properly_set
    self.class.class_eval %q{
      class DefaultPropertlySet < ActiveForm
        column :bicycle, :default => 'batavus'
      end
    }
    assert_equal 'batavus', DefaultPropertlySet.new.bicycle
  end
  
  def test_columns_are_humanizable
    self.class.class_eval %q{
      class Humanizable < ActiveForm
        column :bicycle, :human_name => 'fiets'
      end
    }
    
    assert_equal 'fiets', Humanizable.columns_hash['bicycle'].human_name
  end
  
  def test_fail_on_illegal_options
    assert_raises ArgumentError do
      self.class.class_eval %q{
        class FailOnIllegalOption < ActiveForm
          column :foo, :bar => 'yelp!'
        end
      }
    end
  end
  
  def test_after_and_before_save_callbacks_called_on_valid
    self.class.class_eval %q{
      class WithCallbackSuccess < ActiveForm
        attr_accessor :before_save_called, :after_save_called
        before_save do |obj|
          obj.before_save_called = true
        end
        after_save do |obj|
          obj.after_save_called = true
        end
      end
    }
    
    obj = WithCallbackSuccess.new
    assert obj.save
    assert obj.before_save_called
    assert obj.after_save_called
  end

  def test_old_before_save_callback_called_on_invalid
    self.class.class_eval %q{
      class WithCallbackFailure < ActiveForm
        column :required_field
        validates_presence_of :required_field
        attr_accessor :before_save_called, :after_save_called
        before_save do |obj|
          obj.before_save_called = true
        end
        after_save do |obj|
          obj.after_save_called = true
        end
      end
    }
    
    obj = WithCallbackFailure.new
    assert !obj.save
    assert obj.before_save_called
    assert !obj.after_save_called
  end

  def test_create_bang_raises_no_exception_on_valid
    self.class.class_eval %q{
      class CreateBangSuccess < ActiveForm; end
    }
    
    assert_nothing_raised do
      CreateBangSuccess.create!
    end
  end

  def test_create_bang_raises_exception_on_invalid
    self.class.class_eval %q{
      class CreateBangFailure < ActiveForm
        column :required_field
        validates_presence_of :required_field
      end
    }
    
    assert_raises ActiveRecord::RecordInvalid do
      CreateBangFailure.create!
    end
  end
end
