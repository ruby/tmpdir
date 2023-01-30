# frozen_string_literal: true
#
# tmpdir - retrieve temporary directory path
#
# $Id$
#

require_relative './tmpdir/tmpname'

class Dir
  ##
  # Returns the operating system's temporary file path.
  #
  def self.tmpdir
    Dir::Tmpname.tmpdir
  end

  # Dir.mktmpdir creates a temporary directory.
  #
  # The directory is created with 0700 permission.
  # Application should not change the permission to make the temporary directory accessible from other users.
  #
  # The prefix and suffix of the name of the directory is specified by
  # the optional first argument, <i>prefix_suffix</i>.
  # - If it is not specified or nil, "d" is used as the prefix and no suffix is used.
  # - If it is a string, it is used as the prefix and no suffix is used.
  # - If it is an array, first element is used as the prefix and second element is used as a suffix.
  #
  #  Dir.mktmpdir {|dir| dir is ".../d..." }
  #  Dir.mktmpdir("foo") {|dir| dir is ".../foo..." }
  #  Dir.mktmpdir(["foo", "bar"]) {|dir| dir is ".../foo...bar" }
  #
  # The directory is created under Dir.tmpdir or
  # the optional second argument <i>tmpdir</i> if non-nil value is given.
  #
  #  Dir.mktmpdir {|dir| dir is "#{Dir.tmpdir}/d..." }
  #  Dir.mktmpdir(nil, "/var/tmp") {|dir| dir is "/var/tmp/d..." }
  #
  # If a block is given,
  # it is yielded with the path of the directory.
  # The directory and its contents are removed
  # using FileUtils.remove_entry before Dir.mktmpdir returns.
  # The value of the block is returned.
  #
  #  Dir.mktmpdir {|dir|
  #    # use the directory...
  #    open("#{dir}/foo", "w") { something using the file }
  #  }
  #
  # If a block is not given,
  # The path of the directory is returned.
  # In this case, Dir.mktmpdir doesn't remove the directory.
  #
  #  dir = Dir.mktmpdir
  #  begin
  #    # use the directory...
  #    open("#{dir}/foo", "w") { something using the file }
  #  ensure
  #    # remove the directory.
  #    FileUtils.remove_entry dir
  #  end
  #
  def self.mktmpdir(prefix_suffix=nil, *rest, **options, &block)
    Dir::Tmpname.mktmpdir(prefix_suffix, *rest, **options, &block)
  end
end
