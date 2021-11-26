#-------------------------------------------------------------------------------
# Main script of the Pointwise Auto mesher for D profiles
# Author: Andrea Rausa
# Institution: Politecnico di Milano
# Date of creation: 27-10-2021
#-------------------------------------------------------------------------------


package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5
pw::Application reset
pw::Application markUndoLevel {Journal Reset}

pw::Application clearModified


pw::Connector setDefault Dimension 100
pw::Application setGridPreference Unstructured
pw::Application setCAESolver CGNS 2

pw::Connector setCalculateDimensionMaximum 100000


set path [pwd]

set ToAdd "/"
set path $path$ToAdd
set ToAdd "src/"
set path2Scripts $path$ToAdd

set filename "Procedures.glf"
set filename $path2Scripts$filename
source $filename




puts " "
puts "########################################################################"

puts "Importing settings... "

set startTime [pwu::Time now]

set filename "ImportSettings.glf"
set filename $path2Scripts$filename
pw::Script source $filename
pw::Application markUndoLevel {Run Script}

set elapsedTime [pwu::Time elapsed $startTime]

puts "Done with the import of the settings! Elapsed time = [pwu::Time double $elapsedTime] secs"

puts "########################################################################"
puts " "


puts " "
puts "########################################################################"

puts "Importing settings... "

set startTime [pwu::Time now]

set filename "ImportSettings.glf"
set filename $path2Scripts$filename
pw::Script source $filename
pw::Application markUndoLevel {Run Script}

set elapsedTime [pwu::Time elapsed $startTime]

puts "Done with the import of the settings! Elapsed time = [pwu::Time double $elapsedTime] secs"

puts "########################################################################"
puts " "


puts " "
puts "########################################################################"

puts "Importing profile lines... "

set startTime [pwu::Time now]

set filename "ImportProfileLines.glf"
set filename $path2Scripts$filename
pw::Script source $filename
pw::Application markUndoLevel {Run Script}

set elapsedTime [pwu::Time elapsed $startTime]

puts "Done with the import of the profile lines! Elapsed time = [pwu::Time double $elapsedTime] secs"

puts "########################################################################"
puts " "


puts " "
puts "########################################################################"

puts "Pre-processing profile lines... "

set startTime [pwu::Time now]

set filename "PreProcessing.glf"
set filename $path2Scripts$filename
pw::Script source $filename
pw::Application markUndoLevel {Run Script}

set elapsedTime [pwu::Time elapsed $startTime]

puts "Done with the pre-processing of the profile lines! Elapsed time = [pwu::Time double $elapsedTime] secs"

puts "########################################################################"
puts " "




if {$MeshStrategy == "Unstructured"} {


  puts " "
  puts "########################################################################"

  puts "Creating Point Clouds... "

  set startTime [pwu::Time now]

  set filename "CreatePointClouds.glf"
  set filename $path2Scripts$filename
  pw::Script source $filename
  pw::Application markUndoLevel {Run Script}

  set elapsedTime [pwu::Time elapsed $startTime]

  puts "Done with the PointClouds! Elapsed time = [pwu::Time double $elapsedTime] secs"

  puts "########################################################################"
  puts " "



  puts " "
  puts "########################################################################"

  puts "Creating Unstructured Mesh... "

  set startTime [pwu::Time now]

  set filename "UnstructuredMeshing.glf"
  set filename $path2Scripts$filename
  pw::Script source $filename
  pw::Application markUndoLevel {Run Script}

  set elapsedTime [pwu::Time elapsed $startTime]

  puts "Done with the Unstructured Mesh! Elapsed time = [pwu::Time double $elapsedTime] secs"

  puts "########################################################################"
  puts " "

}


if {$MeshStrategy == "Structured"} {

  puts " "
  puts "########################################################################"

  puts "Creating Structured Mesh... "

  set startTime [pwu::Time now]

  set filename "StructuredMeshing.glf"
  set filename $path2Scripts$filename
  pw::Script source $filename
  pw::Application markUndoLevel {Run Script}

  set elapsedTime [pwu::Time elapsed $startTime]

  puts "Done with the Structured Mesh! Elapsed time = [pwu::Time double $elapsedTime] secs"

  puts "########################################################################"
  puts " "

}



puts " "
puts "########################################################################"

puts "Assigning boundaries... "

set startTime [pwu::Time now]
set filename "AssignBoundaries.glf"
set filename $path2Scripts$filename
pw::Script source $filename

pw::Application markUndoLevel {Run Script}

set elapsedTime [pwu::Time elapsed $startTime]

puts "Done with assigning boundaries! Elapsed time = [pwu::Time double $elapsedTime] secs"

puts "########################################################################"
puts " "



set initializeSurf 1

if {$initializeSurf == 1} {

  puts " "
  puts "########################################################################"

  puts "Creating and exporting mesh... "

  set startTime [pwu::Time now]
  set filename "Export.glf"
  set filename $path2Scripts$filename
  pw::Script source $filename

  pw::Application markUndoLevel {Run Script}

  set elapsedTime [pwu::Time elapsed $startTime]

  puts "Done with creating and exporting mesh! Elapsed time = [pwu::Time double $elapsedTime] secs"

  puts "########################################################################"
  puts " "

}

set PointwiseFilename $path$PointwiseName
pw::Application save $PointwiseFilename
