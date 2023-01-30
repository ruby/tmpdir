# frozen_string_literal: true
#
# tmpdir - retrieve temporary directory path
#
# $Id$
#

require 'fileutils'
begin
  require 'etc.so'
rescue LoadError # rescue LoadError for miniruby
end
require_relative './insecure_world_writable'

class Dir
  # Temporary name generator
  module Tmpname # :nodoc:
    using InsecureWorldWritable

    module_function

    SYSTMPDIR = Etc.systmpdir rescue '/tmp'
    private_constant :SYSTMPDIR

    TRY_ENVS = %w{TMPDIR TMP TEMP}.freeze
    private_constant :TRY_ENVS

    TRY_DIRS = [['system temporary path', SYSTMPDIR], ['/tmp']*2, ['.']*2].map(&:freeze).freeze
    private_constant :TRY_DIRS

    PERM_CHECKS = [
      ['not a directory', :directory? ],
      ['not writable'   , :writable?  ],
      ['world-writable' , :not_insecure_world_writable? ]].map(&:freeze).freeze
    private_constant :PERM_CHECKS

    def tmpdir
      TRY_ENVS.each { |env|       d = self.verify_permissions(env, ENV[env]); return d if d }
      TRY_DIRS.each { |name, dir| d = self.verify_permissions(name, dir)    ; return d if d }
      raise ArgumentError, 'could not find a temporary directory'
    end

    private_class_method def verify_permissions(name, dir)
      return if dir.to_s.empty?
      dir = File.expand_path(dir)
      stat = File.stat(dir) rescue return
      dir if PERM_CHECKS.all? { |msg, ok| stat.send(ok) or warn "#{name} is #{msg}: #{dir}" }
    end

    def mktmpdir(prefix_suffix = nil, *rest, **options, &block)
      base = nil
      path = self.create(prefix_suffix || 'd', *rest, **options) do |path, _, _, d|
        base = d
        Dir.mkdir(path, 0700)
      end
      if block_given?
        self.mktmpdir_with_block(base, path, block)
      else
        path
      end
    end

    private_class_method def mktmpdir_with_block(base, path, block)
      block.call(path.dup)
    ensure
      if !base && File.stat(File.dirname(path))&.insecure_world_writable?
        raise ArgumentError, 'parent directory is world writable but not sticky'
      end
      FileUtils.remove_entry path
    end

    # Unusable characters as path name
    UNUSABLE_CHARS = '^,-.0-9A-Z_a-z~'

    # Generates and yields random names to create a temporary name
    def create(basename, tmpdir = nil, max_try: nil, **opts)
      raise ArgumentError, "empty parent path" if tmpdir&.empty?
      n = nil
      begin
        path = generate_path(basename, tmpdir, n)
        path = File.join(tmpdir || self.tmpdir, path)
        yield(path, n, opts, tmpdir)
        path
      rescue Errno::EEXIST
        n ||= 0
        retry if max_try&.>=(n += 1)
        raise "cannot generate temporary name using `#{basename}' under `#{tmpdir}'"
      end
    end

    private_class_method def generate_path(basename, tmpdir, n)
      prefix, suffix = self.make_prefix_suffix(basename)
      time = Time.now.strftime('%Y%m%d')
      rnd = Random.bytes(4).unpack1('L').to_s(36)[0..5]
      '%s%s-%d-%s%s%s' % [prefix, time, $$, rnd, n&.-@, suffix]
    end

    private_class_method def make_prefix_suffix(basename)
      prefix, suffix = basename
      prefix = self.make_str('prefix', prefix)
      suffix &&= self.make_str('suffix', suffix)
      [prefix, suffix]
    end

    private_class_method def make_str(msg, var)
      if x = String.try_convert(var)
        x.delete(UNUSABLE_CHARS)
      else
        raise ArgumentError, "unexpected #{msg}: #{var.inspect}"
      end
    end
  end
end
