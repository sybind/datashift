# Copyright:: (c) Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     Aug 2011
# License::   MIT
#
# Details::   Export a model to Excel '97(-2007) file format.
#
# TOD : Can we switch between .xls and XSSF (POI implementation of Excel 2007 OOXML (.xlsx) file format.)
#
#
module DataShift

  require 'generator_base'
      
  if(Guards::jruby?)

    require 'jruby/jexcel_file'

    class ExcelGenerator < GeneratorBase

      attr_accessor :filename
  
      def initialize(filename)
        @filename = filename
      end

      # Create an Excel file template (header row) representing supplied Model
    
      def generate(klass, options = {})
        MethodDictionary.find_operators( klass )

        @filename = options[:filename] if  options[:filename]

        excel = JExcelFile.new()

        if(options[:sheet_name] )
          excel.create_sheet( options[:sheet_name] ) 
        else
          excel.create_sheet( klass.name )
        end
        
        raise "Failed to create Excel WorkSheet for #{klass.name}" unless excel.sheet

        excel.set_headers(MethodDictionary.assignments[klass])

        excel.save( @filename )
      end

      
      # Create an Excel file from list of ActiveRecord objects
      # Specify which associations to export via :with or :exclude
      # Possible values are : [:assignment, :belongs_to, :has_one, :has_many]
      #
      def generate_with_associations(klass, options = {})

        excel = JExcelFile.new()

        if(options[:sheet_name] )
          excel.create_sheet( options[:sheet_name] ) 
        else
          excel.create_sheet( klass.name )
        end
        
        MethodDictionary.find_operators( klass )
         
        MethodDictionary.build_method_details( klass )
           
        work_list = options[:with] || MethodDetail::supported_types_enum
        
        headers = []
        puts "work_list :  [#{work_list.inspect}]"
      
        details_mgr = MethodDictionary.method_details_mgrs[klass]
                  
        work_list.each do |op_type|
          list_for_class_and_op = details_mgr.get_list(op_type)
       
          next if(list_for_class_and_op.nil? || list_for_class_and_op.empty?)
         #if(work_list.include?(md.operator_type))
              #each do |mdtype|
          #end
          #if(MethodDictionary.respond_to?("#{mdtype}_for") )
           # method_details = MethodDictionary.send("#{mdtype}_for", klass)
        
            list_for_class_and_op.each {|md| headers << "#{md.operator}" }
          #else
           # puts "ERROR : Unknown option in :with [#{mdtype}]"
         
        end
        
        excel.set_headers( headers )
                
        excel.save( filename() )
      end
    end # ExcelGenerator

  else
    class  ExcelGenerator < GeneratorBase
      
      def initialize(filename)
        @filename = filename
        raise DataShift::BadRuby, "Apologies but Datashift Excel facilities currently need JRuby. Please switch to, or install JRuby"
      end
    end
  end # jruby
  
end # DataShift