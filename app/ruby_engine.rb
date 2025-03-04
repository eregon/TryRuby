# await: true

# require 'ruby_engine/opal'
require 'ruby_engine/opal_webworker'
require 'ruby_engine/cruby_wasi'

class RubyEngine
  def run(source)
    raise NotImplementedError
  end

  def run_with_writer(source, writer, &block)
    @writer = writer
    @dots = 0
    run(source, &block).__await__
  end

  # Display a message while a block is being executed
  def loading(part = nil)
    # Debug option:
    # @writer.output = "*** Loading... #{"(#{part})" if part}"
    @dots += 1
    @writer.output = "*** Loading#{"." * @dots}"
    result = yield.__await__
    @writer.output = ""
    result
  end

  # When you update the engines, ensure that they are tested correctly.
  # Update the engine list also in spec/playground_spec.
  ENGINES = [
    # Opal.new,
    OpalWebWorker.new("1.7.1"),
    CRubyWASI.new(
      "https://cdn.jsdelivr.net/npm/ruby-head-wasm-wasi@0.5.0-2022-12-25-a/dist/ruby.wasm",
      "3.2.0"
    ),
    # FIXME(katei): Head build is no longer compatible with ruby-head-wasm-wasi@0.5.0,
    # so we should have a worker for each version of CRuby to load corresponding ruby-*-wasm-wasi
    # CRubyWASI.new(
    #   "https://cdn.jsdelivr.net/npm/ruby-head-wasm-wasi@next/dist/ruby.wasm",
    #   "3.3.0dev"
    # ),
  ].each_with_object({}) do |engine, hash|
    hash[engine.engine_id] = engine
  end
end
