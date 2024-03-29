package require PWI_Glyph 4.18.4

set PointwiseFilename $path$PointwiseName
pw::Application save $PointwiseFilename




if {$MeshStrategy == "Unstructured"} {
  if {$OneBoundaryTag == "false"} {
    pw::DomainUnstructured setInitializeInterior 1

    set _TMP(mode_1) [pw::Application begin UnstructuredSolver [list $ActualMesh]]
      $_TMP(mode_1) run Initialize
    $_TMP(mode_1) end
    unset _TMP(mode_1)
    pw::Application markUndoLevel Solve

    # Now that I have the mesh done and with the final spacings and the Airofil edge
    # with the connectors aligned in order, I can go through each of these and
    # check if the connector spacing at the point of intersection is equal or not

    #checkConnectorSpacings $Airfoil $ConSpacings2Complete

    #pw::DomainUnstructured setInitializeInterior 1

    #set _TMP(mode_1) [pw::Application begin UnstructuredSolver [list $ActualMesh]]
    #  $_TMP(mode_1) run Initialize
    #$_TMP(mode_1) end
    #unset _TMP(mode_1)


  }


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
  GMSH {
    set MeshExtension ".msh"

    pw::Application setCAESolver Gmsh 2

    set MeshFilename $path$MeshName$MeshExtension

    set _TMP(mode_1) [pw::Application begin CaeExport [pw::Entity sort [list $ActualMesh]]]
      $_TMP(mode_1) initialize -strict -type CAE $MeshFilename
      $_TMP(mode_1) setAttribute FilePrecision Double
      $_TMP(mode_1) verify
      $_TMP(mode_1) write
    $_TMP(mode_1) end
    unset _TMP(mode_1)
  }
  WRL {
    set MeshExtension ".wrl"

    set MeshFilename $path$MeshName$MeshExtension

    set _TMP(mode_1) [pw::Application begin GridExport [pw::Entity sort [list $ActualMesh]]]
      $_TMP(mode_1) initialize -strict -type VRML97 $MeshFilename
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
