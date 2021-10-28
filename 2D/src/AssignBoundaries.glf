package require PWI_Glyph 4.18.4




set _TMP(PW_2) [pw::BoundaryCondition create]
pw::Application markUndoLevel {Create BC}
set _TMP(PW_3) [pw::BoundaryCondition getByName bc-2]
unset _TMP(PW_2)


if {$MeshStrategy == "Unstructured"} {

  $_TMP(PW_3) apply [list [list $ActualMesh $_CN(5)] [list $ActualMesh $_CN(6)] [list $ActualMesh $_CN(4)] [list $ActualMesh $_CN(7)]]
  pw::Application markUndoLevel {Set BC}

}


if {$MeshStrategy == "Structured"} {

  $_TMP(PW_3) apply [list [list $ActualMesh $FarfieldExtruded]]
  pw::Application markUndoLevel {Set BC}

}

$_TMP(PW_3) setName Farfield
pw::Application markUndoLevel {Name BC}

unset _TMP(PW_3)


set i 3
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
