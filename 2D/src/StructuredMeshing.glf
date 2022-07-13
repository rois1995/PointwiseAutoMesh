package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5

set ConnectorList2Extrude [list]
foreach con $Connectors {
  lappend ConnectorList2Extrude [lindex $con 1]
}


pw::Application setGridPreference Structured

set _TMP(mode_1) [pw::Application begin Create]
  set Airfoil [pw::Edge create]
  $Airfoil addConnector [lindex [lindex $Connectors 0] 1]

  set  completion [findEdgeCompletion $Airfoil]
  foreach con $completion {
    $Airfoil addConnector $con
  }
  set ActualMesh [pw::DomainStructured create]
  $ActualMesh addEdge $Airfoil
$_TMP(mode_1) end
unset _TMP(mode_1)
set _TMP(mode_1) [pw::Application begin ExtrusionSolver [list $ActualMesh]]
  $_TMP(mode_1) setKeepFailingStep false

  # First a bunch of steps to create the boundary layer without modifying too much
  # the shape of the profile during extrusion
  $ActualMesh setExtrusionSolverAttribute NormalInitialStepSize $InitialSpacing
  $ActualMesh setExtrusionSolverAttribute SpacingGrowthFactor $GrowthRateBL
  $ActualMesh setExtrusionSolverAttribute NormalVolumeSmoothing 0.01

  # Questo ancora non l'ho capito come fare per farlo bene..
  if {$AirfoilOrientation == "Clockwise"} {
    $ActualMesh setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
  }
  if {$AirfoilOrientation == "CounterClockwise"} {
    $ActualMesh setExtrusionSolverAttribute NormalMarchingVector {0 0 1}
  }

  $ActualMesh setExtrusionSolverAttribute StopAtHeight [expr {5*$Chord}]
  $ActualMesh setExtrusionSolverAttribute Mode NormalHyperbolic
  # $ActualMesh setExtrusionSolverAttribute Mode NormalAlgebraic
  $_TMP(mode_1) run 1000

  # Then the remaining steps will be done with standard volume smoothing up until farfield
  $ActualMesh setExtrusionSolverAttribute NormalVolumeSmoothing 0.5

  $ActualMesh setExtrusionSolverAttribute StopAtHeight $FarfieldDistance
  $_TMP(mode_1) run 1000

  set ExtremePoints [pw::Entity getExtents $ActualMesh]

  set Extension [pwu::Vector3 length [pwu::Vector3 subtract [lindex $ExtremePoints 0] [lindex $ExtremePoints 1]]]

  if { $Extension < [expr {$FarfieldDistance/2.0}] } {

    if {$AirfoilOrientation == "Clockwise"} {
      $ActualMesh setExtrusionSolverAttribute NormalMarchingVector {0 0 1}
    }
    if {$AirfoilOrientation == "CounterClockwise"} {
      $ActualMesh setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
    }
    $_TMP(mode_1) run Restart
    $ActualMesh setExtrusionSolverAttribute StopAtHeight [expr {5*$Chord}]
    # $ActualMesh setExtrusionSolverAttribute Mode NormalAlgebraic
    $_TMP(mode_1) run 1000

    # Then the remaining steps will be done with standard volume smoothing up until farfield
    $ActualMesh setExtrusionSolverAttribute NormalVolumeSmoothing 0.5

    $ActualMesh setExtrusionSolverAttribute StopAtHeight $FarfieldDistance
    $_TMP(mode_1) run 1000
  }


$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Extrude, Normal}

set NLines [llength $ConnectorList2Extrude]
set NLines [expr {$NLines+2}]
set farfieldName "con-"
set farfieldName $farfieldName$NLines
puts $farfieldName
set FarfieldExtruded [pw::GridEntity getByName $farfieldName]
