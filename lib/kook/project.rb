
require 'kook/exceptions'

module Kook
	class Project
		attr_reader :name, :path
		attr_accessor :description

		class MissingProjectFile < RuntimeError ; end
		class InvalidProjectName < RuntimeError ; end
		PROJECT_NAME_MIN_SIZE = 4
		PROJECT_NAME_MAX_SIZE = 12

		def initialize project_name
			self.class.validate_name project_name
			@name = project_name
			@description = nil
			@path = nil
			@views = {}

			yield self if block_given?
			self
		end

		def path= path
			# FIXME: validate current path exists
			#
			if not (File.exist? path and File.directory? path) then
				raise "PathDoesNotExist #{path}"
			end
			@path = path
		end

		def add_view view
			raise "ExistingView #{view.name}" if @views.has_key? view.name
			@views[view.name] = view
		end

		def remove_view view_name
			View.validate_name view_name
			return @view.delete(view_name)
		end

		def each_view 
			@views.each do |view_name, view_data|
				yield view_name, view_data
			end
		end

		def to_hash
			return { 
				'project' => @name,
				'description' => @description,
				#'path' => @path,
				'views' => @views.values.map{ |v| v.to_hash }
			}
		end

		def self.from_hash project_hash, project_path
			project = Project.new project_hash['project'] do |p|
				p.description = project_hash['description']
				p.path = project_path

				#project_hash[:views].each do |hash_view|
				#	view = View.new do |v|
				#		v.from_hash hash_view
				#	end
				#	p.add_view view
				#end
			end
		end

		def self.validate_name name
			raise "TooShortProjectIdentifier" if name.size < Project::PROJECT_NAME_MIN_SIZE
			raise "TooLongProjectIdentifier" if name.size > Project::PROJECT_NAME_MAX_SIZE
			if not name =~ /^\w(\S+)$/ then
				raise "BadProjectIdentifier #{name}" 
			end
			return true
		end
	end
end
