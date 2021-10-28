package require PWI_Glyph 4.18.4


if {$MeshStrategy == "Unstructured"} {
  set _TMP(mode_1) [pw::Application begin UnstructuredSolver [list $ActualMesh]]
    $_TMP(mode_1) run Initialize
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Solve
}

puts "------------------------------------------------------------------------"

puts "Analysing mesh metrics... "

set startTime [pwu::Time now]

set filename "MeshProperties.glf"
set filename $path2Scripts$filename
pw::Script source $filename
pw::Application markUndoLevel {Run Script}

set elapsedTime [pwu::Time elapsed $startTime]

puts "Done! Elapsed time = [pwu::Time double $elapsedTime] secs"

puts "------------------------------------------------------------------------"

switch $MeshFormat {
  SU2 {
    set MeshExtension ".su2"

    pw::Application setCAESolver SU2 2

    set MeshFilename $path$MeshName$MeshExtension

    set _TMP(mode_1) [pw::Application begin CaeExport [pw::Entity sort [list $ActualMesh]]]
      $_TMP(mode_1) initialize -strict -type CAE $MeshFilename
      $_TMP(mode_1) setAttribute FilePrecision Double
      $_TMP(mode_1) verify
      $_TMP(mode_1) write
    $_TMP(mode_1) end
    unset _TMP(mode_1)

  }
  CGNS {
    set MeshExtension ".cgns"

    pw::Application setCAESolver CGNS 2

    set MeshFilename $path$MeshName$MeshExtension

    set _TMP(mode_1) [pw::Application begin CaeExport [pw::Entity sort [list $ActualMesh]]]
      $_TMP(mode_1) initialize -strict -type CAE $MeshFilename
      $_TMP(mode_1) setAttribute FilePrecision Double
      $_TMP(mode_1) setAttribute ExportParentElements $ExpParentElements
      $_TMP(mode_1) setAttribute ExportDonorInformation $ExpDonorInformation
      $_TMP(mode_1) setAttribute UnstructuredInterface $UnstrInterface
      $_TMP(mode_1) verify
      $_TMP(mode_1) write
    $_TMP(mode_1) end
    unset _TMP(mode_1)
  }
  default {

    puts "Mesh format $MeshFormat is unknown! Defaulting to CGNS with default options!"

    set MeshExtension ".cgns"

    pw::Application setCAESolver CGNS 2

    set MeshFilename $path$MeshName$MeshExtension

    set _TMP(mode_1) [pw::Application begin CaeExport [pw::Entity sort [list $ActualMesh]]]
      $_TMP(mode_1) initialize -strict -type CAE $MeshFilename
      $_TMP(mode_1) setAttribute FilePrecision Double
      $_TMP(mode_1) verify
      $_TMP(mode_1) write
    $_TMP(mode_1) end
    unset _TMP(mode_1)
  }
}



if {$SavePointwiseFile == "ON"} {
  set PointwiseFilename $path$PointwiseName
  pw::Application save $PointwiseFilename
}


puts "Done!"
