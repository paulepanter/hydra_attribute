When /^load all "([^"]+)" records$/ do |klass|
  @records = Object.const_get(klass).all
end

When /^select "(first|last)" "([^"]+)" record$/ do |method, klass|
  @record = Object.const_get(klass).send(method)
end

Then /^record (read attribute(?: before type cast)?) "([^"]+)" and value should be "([^"]+)"$/ do |method, attribute, value|
  method = method.gsub(/\s+/, '_')
  @record.send(method, attribute).should == type_cast_value(value)
end

Then /^"(first|last)" record should have "([^"]+)"$/ do |method, attribute|
  type_cast_attributes(attribute).each do |(name, value)|
    @records.send(method).send(name).should == value
  end
end

Then /^records should have the following attributes:$/ do |table|
  table.hashes.each do |hash|
    record = @records.detect { |r| r.send(hash[:field]) == type_cast_value(hash[:value]) }
    record.should_not be_nil
  end
end

Then /^records should have only the following "([^"]+)" names$/ do |attributes|
  @records.each do |record|
    record.attributes.keys.should =~ attributes.split(/\s+/)
  end
end

Then /^records should raise "([^"]+)" when call the following "([^"]+)"$/ do |error, methods|
  error_class = error.constantize
  @records.each do |record|
    methods.split(/\s+/).each do |method|
      lambda { record.send(method) }.should raise_error(error_class)
    end
  end
end

Then /^total records should be "([^"]+)"$/ do |count|
  @records.to_a.should have(count.to_i).records
end

Then /^total "([^"]+)" records should be "([^"]+)"$/ do |klass, count|
  @records = klass.constantize.scoped
  step %Q(total records should be "#{count}")
end

Then /^records "(should|should_not)" have loaded associations:$/ do |should, table|
  table.hashes.each do |hash|
    @records.each do |record|
      record.association(hash[:association].to_sym).send(should, be_loaded)
    end
  end
end

Then /^"([^"]+)" records "(should|should_not)" have loaded associations:$/ do |klass, should, table|
  table.hashes.each do |hash|
    records = @records.select { |record| record.class.name == klass }
    records.each do |record|
      record.association(hash[:association].to_sym).send(should, be_loaded)
    end
  end
end