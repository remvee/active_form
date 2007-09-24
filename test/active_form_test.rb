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
end
