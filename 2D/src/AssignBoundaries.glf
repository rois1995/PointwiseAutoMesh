package require PWI_Glyph 4.18.4




set _TMP(PW_2) [pw::BoundaryCondition create]
pw::Application markUndoLevel {Create BC}
set _TMP(PW_3) [pw::BoundaryCondition getByName bc-2]
$_TMP(PW_3) setName Farfield
unset _TMP(PW_2)


if {$MeshStrategy == "Unstructured"} {

  if { $FarfieldShape == "Square" } {
    $_TMP(PW_3) apply [list [list $ActualMesh $_CN(5)] [list $ActualMesh $_CN(6)] [list $ActualMesh $_CN(4)] [list $ActualMesh $_CN(7)]]
  }

  if { $FarfieldShape == "Circle" } {
    $_TMP(PW_3) apply [list [list $ActualMesh $_CN(4)]]
  }

  if {$FarfieldShape == "Gallery" } {

    $_TMP(PW_3) setName GalleryWalls

    set Outlet [pw::BoundaryCondition create]
    set Outlet [pw::BoundaryCondition getByName bc-3]
    $Outlet setName Outlet
    set Inlet [pw::BoundaryCondition create]
    set Inlet [pw::BoundaryCondition getByName bc-4]
    $Inlet setName Inlet

    $_TMP(PW_3) apply [list [list $ActualMesh $_CN(4)] [list $ActualMesh $_CN(6)]]
    $Outlet apply [list [list $ActualMesh $_CN(5)]]
    $Inlet apply [list [list $ActualMesh $_CN(7)]]

  }

  pw::Application markUndoLevel {Set BC}

}


if {$MeshStrategy == "Structured"} {

  $_TMP(PW_3) apply [list [list $ActualMesh $FarfieldExtruded]]
  pw::Application markUndoLevel {Set BC}

}

pw::Application markUndoLevel {Name BC}

unset _TMP(PW_3)

set OneConn 1
if { $OneBoundaryTag == "true" } {


  if {$MeshStrategy == "Unstructured"} {
    set _TMP(mode_1) [pw::Application begin UnstructuredSolver [list $ActualMesh]]
      $_TMP(mode_1) run Initialize
    $_TMP(mode_1) end
    unset _TMP(mode_1)
    pw::Application markUndoLevel Solve

    if {!$UseFileDistribution} {
      # Now that I have the mesh done and with the final spacings and the Airofil edge
      # with the connectors aligned in order, I can go through each of these and
      # check if the connector spacing at the point of intersection is equal or not

      checkConnectorSpacings $Airfoil $ConSpacings2Complete
    }

    pw::DomainUnstructured setInitializeInterior 1

    set _TMP(mode_1) [pw::Application begin UnstructuredSolver [list $ActualMesh]]
      $_TMP(mode_1) run Initialize
    $_TMP(mode_1) end
    unset _TMP(mode_1)

  }


  set OneBoundaryCon [list]
  foreach Con $Connectors {

    lappend OneBoundaryCon [lindex $Con 1]

  }

  set _TMP(PW_1) [pw::Connector join -reject _TMP(ignored) -keepDistribution $OneBoundaryCon]
  unset _TMP(ignored)
  unset _TMP(PW_1)
  pw::Application markUndoLevel Join

  set OneBoundaryName "con-"
  if { $MeshStrategy == "Structured" } {
    set OneBoundaryName "con-1"
  } else {
    set NConn [llength $OneBoundaryCon]
    set OneBoundaryName $OneBoundaryName$NConn

  }

  set OneBoundary [pw::GridEntity getByName $OneBoundaryName]
  # set _TMP(mode_1) [pw::Application begin Modify [list $OneBoundary]]
  #   $OneBoundary removeAllBreakPoints
  # $_TMP(mode_1) end
  # unset _TMP(mode_1)
  # pw::Application markUndoLevel Distribute

  set BCName "bc-3"
  if { $MeshStrategy == "Unstructured" && $FarfieldShape == "Gallery" } {
      set BCName "bc-5"
  }
  set TMP [pw::BoundaryCondition create]
  pw::Application markUndoLevel {Create BC}
  set TMP_1 [pw::BoundaryCondition getByName $BCName]


  $TMP_1 setName $OneBoundaryTagName
  pw::Application markUndoLevel {Name BC}

  $TMP_1 apply [list [list $ActualMesh $OneBoundary]]
  pw::Application markUndoLevel {Set BC}



}

if { $OneBoundaryTag == "false" } {
  set i 3
  if { $MeshStrategy == "Unstructured" && $FarfieldShape == "Gallery" } {
      set i 5
  }
  foreach Con $Connectors {

    set BCName "bc-"
    set BCName $BCName$i

    set TMP [pw::BoundaryCondition create]
    pw::Application markUndoLevel {Create BC}
    set TMP_1 [pw::BoundaryCondition getByName $BCName]
    # unset TMP

    $TMP_1 setName [lindex $Con 0]
    pw::Application markUndoLevel {Name BC}

    $TMP_1 apply [list [list $ActualMesh [lindex $Con 1]]]
    pw::Application markUndoLevel {Set BC}

    # unset $TMP_1

    set i [expr {$i+1}]

  }
}
