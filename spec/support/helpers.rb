module Helpers
  def capture_standard_output
    output = []
    original_stdout = $stdout
    $stdout = mock_stdout = ::StringIO.new
    mock_stdout.set_encoding('UTF-8')
    yield
    output << mock_stdout.string.chomp
  rescue ::SystemExit
    output << mock_stdout.string.chomp
  ensure
    $stdout = original_stdout
  end

  def capture_standard_error
    error = []
    original_stderr = $stderr
    $stderr = mock_stderr = ::StringIO.new
    mock_stderr.set_encoding('UTF-8')
    yield
  rescue ::SystemExit
    error << mock_stderr.string.chomp
  ensure
    $stderr = original_stderr
  end
end
