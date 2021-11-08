package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5

set ConnectorList2Extrude [list]
foreach con $Connectors {
  lappend ConnectorList2Extrude [lindex $con 1]
}




pw::Application setGridPreference Structured

set _TMP(mode_1) [pw::Application begin Create]
  set _TMP(PW_1) [pw::Edge createFromConnectors $ConnectorList2Extrude]
  set _TMP(edge_1) [lindex $_TMP(PW_1) 0]
  unset _TMP(PW_1)
  set ActualMesh [pw::DomainStructured create]
  $ActualMesh addEdge $_TMP(edge_1)
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
  $ActualMesh setExtrusionSolverAttribute NormalMarchingVector {-0 -0 -1}

  $ActualMesh setExtrusionSolverAttribute StopAtHeight [expr {5*$Chord}]
  $ActualMesh setExtrusionSolverAttribute Mode NormalHyperbolic
  # $ActualMesh setExtrusionSolverAttribute Mode NormalAlgebraic
  $_TMP(mode_1) run 1000

  # Then the remaining steps will be done with standard volume smoothing up until farfield
  $ActualMesh setExtrusionSolverAttribute NormalVolumeSmoothing 0.5

  $ActualMesh setExtrusionSolverAttribute StopAtHeight $FarfieldDistance
  $_TMP(mode_1) run 1000

$_TMP(mode_1) end
unset _TMP(mode_1)
unset _TMP(edge_1)
pw::Application markUndoLevel {Extrude, Normal}

set NLines [llength $ConnectorList2Extrude]
set NLines [expr {$NLines+2}]
set farfieldName "con-"
set farfieldName $farfieldName$NLines
set FarfieldExtruded [pw::GridEntity getByName $farfieldName]
