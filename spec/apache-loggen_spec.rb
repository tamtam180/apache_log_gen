# -*- coding: utf-8 -*-
require 'apache-loggen/base'

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

describe LogGenerator::Base do
  it '--limit=10を指定したときログを10行生成する' do
    log_gen = LogGenerator::Apache.new
    output = capture_stdout { LogGenerator.generate({:limit => 10}, log_gen) }
    expect(output.split("\n").length).to eq 10
  end

  it '--limit=10、--rate=5を指定したときログを10行生成する' do
    log_gen = LogGenerator::Apache.new
    output = capture_stdout { LogGenerator.generate({:limit => 10, :rate => 5}, log_gen) }
    expect(output.split("\n").length).to eq 10
  end

  it '--limit=10、--rate=10を指定したときログを10行生成する' do
    log_gen = LogGenerator::Apache.new
    output = capture_stdout { LogGenerator.generate({:limit => 10, :rate => 10}, log_gen) }
    expect(output.split("\n").length).to eq 10
  end

  it '--limit=10、--rate=100を指定したときログを10行生成する' do
    log_gen = LogGenerator::Apache.new
    output = capture_stdout { LogGenerator.generate({:limit => 10, :rate => 100}, log_gen) }
    expect(output.split("\n").length).to eq 10
  end
end
