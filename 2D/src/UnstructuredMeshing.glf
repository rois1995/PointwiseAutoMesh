package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5




#-------------------------------------------------------------------------------
# Farfield construction

puts "Constructing Fafield..."

set FarfieldPoint [list]
lappend FarfieldPoint 0
lappend FarfieldPoint 0
lappend FarfieldPoint 0
lset FarfieldPoint 2 0

set ActualFarfieldDistance [expr {$FarfieldDistance * $Chord}]


set _TMP(mode_1) [pw::Application begin Create]
  set _TMP(PW_1) [pw::SegmentSpline create]

  lset FarfieldPoint 0 [expr {-1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {-1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  lset FarfieldPoint 0 [expr {1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {-1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  set _CN(4) [pw::Connector create]
  $_CN(4) addSegment $_TMP(PW_1)
  unset _TMP(PW_1)
  $_CN(4) calculateDimension
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Create 2 Point Connector}

set _TMP(mode_1) [pw::Application begin Create]
  set _TMP(PW_1) [pw::SegmentSpline create]

  lset FarfieldPoint 0 [expr {1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {-1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  lset FarfieldPoint 0 [expr {1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  set _CN(5) [pw::Connector create]
  $_CN(5) addSegment $_TMP(PW_1)
  unset _TMP(PW_1)
  $_CN(5) calculateDimension
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Create 2 Point Connector}

set _TMP(mode_1) [pw::Application begin Create]
  set _TMP(PW_1) [pw::SegmentSpline create]

  lset FarfieldPoint 0 [expr {1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  lset FarfieldPoint 0 [expr {-1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  set _CN(6) [pw::Connector create]
  $_CN(6) addSegment $_TMP(PW_1)
  unset _TMP(PW_1)
  $_CN(6) calculateDimension
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Create 2 Point Connector}

set _TMP(mode_1) [pw::Application begin Create]
  set _TMP(PW_1) [pw::SegmentSpline create]

  lset FarfieldPoint 0 [expr {-1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  lset FarfieldPoint 0 [expr {-1*$ActualFarfieldDistance}]
  lset FarfieldPoint 1 [expr {-1*$ActualFarfieldDistance}]
  $_TMP(PW_1) addPoint $FarfieldPoint

  set _CN(7) [pw::Connector create]
  $_CN(7) addSegment $_TMP(PW_1)
  unset _TMP(PW_1)
  $_CN(7) calculateDimension
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Create 2 Point Connector}



set _TMP(PW_1) [pw::Collection create]
$_TMP(PW_1) set [list $_CN(4) $_CN(6) $_CN(7) $_CN(5)]
$_TMP(PW_1) do setDimensionFromSpacing -resetDistribution [expr {$FarfieldSpacing * $Chord}]
$_TMP(PW_1) delete
unset _TMP(PW_1)
pw::CutPlane refresh
pw::Application markUndoLevel Dimension


puts "Done!"


#-------------------------------------------------------------------------------


puts "Creating mesh..."

set _TMP(mode_1) [pw::Application begin Create]
  set Farfield [pw::Edge create]
  $Farfield addConnector $_CN(6)
  $Farfield addConnector $_CN(7)
  $Farfield addConnector $_CN(4)
  $Farfield addConnector $_CN(5)

  set FarfieldMesh [pw::DomainUnstructured create]
  $FarfieldMesh addEdge $Farfield
  set FarfieldProj [$FarfieldMesh getDefaultProjectDirection]

  set Airfoil [pw::Edge create]
  $Airfoil addConnector [lindex [lindex $Connectors 0] 1]

  set  completion [findEdgeCompletion $Airfoil]
  foreach con $completion {
    $Airfoil addConnector $con
  }

  set AirfoilMesh [pw::DomainUnstructured create]
  $AirfoilMesh addEdge $Airfoil

  set AirfoilProj [$AirfoilMesh getDefaultProjectDirection]
  set isReverse false
  if {[lindex $AirfoilProj 2] == [lindex $FarfieldProj 2]} {
    set isReverse true
  }

  pw::Entity delete [list $AirfoilMesh]
  pw::Entity delete [list $FarfieldMesh]
  unset Farfield
  unset Airfoil

  set Farfield [pw::Edge create]
  $Farfield addConnector $_CN(6)
  $Farfield addConnector $_CN(7)
  $Farfield addConnector $_CN(4)
  $Farfield addConnector $_CN(5)

  set Airfoil [pw::Edge create]
  $Airfoil addConnector [lindex [lindex $Connectors 0] 1]

  set  completion [findEdgeCompletion $Airfoil]
  foreach con $completion {
    $Airfoil addConnector $con
  }

  if {$isReverse} {
    $Airfoil reverse
  }

  set ActualMesh [pw::DomainUnstructured create]
  $ActualMesh addEdge $Farfield
  $ActualMesh addEdge $Airfoil


  unset Airfoil
  unset Farfield
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Assemble Domain}

set _TMP(mode_1) [pw::Application begin UnstructuredSolver [list $ActualMesh]]

  if {$Euler == "OFF"} {

    $ActualMesh setUnstructuredSolverAttribute TRexFullLayers $NFullLayers


    $ActualMesh setUnstructuredSolverAttribute TRexPushAttributes True
    $ActualMesh setUnstructuredSolverAttribute TRexCellType TriangleQuad
    $ActualMesh setUnstructuredSolverAttribute TRexMaximumLayers $NMaxLayers
    set _TMP(PW_1) [pw::TRexCondition create]
    unset _TMP(PW_1)
    set _TMP(PW_1) [pw::TRexCondition getByName bc-2]
    $_TMP(PW_1) setName Wall

    foreach con $Connectors {
      set conName [lindex $con 1]
      if { [catch {$_TMP(PW_1) apply [list [list $ActualMesh $conName Same]] } ] } {
        $_TMP(PW_1) apply [list [list $ActualMesh $conName Opposite]]
      } else {
        $_TMP(PW_1) apply [list [list $ActualMesh $conName Same]]
      }
    }

    $_TMP(PW_1) setConditionType Wall
    $_TMP(PW_1) setValue $InitialSpacing
    $ActualMesh setUnstructuredSolverAttribute TRexGrowthRate $GrowthRateBL
    $ActualMesh setUnstructuredSolverAttribute TRexCellType $CellTypeBL

    unset _TMP(PW_1)

  }

  $ActualMesh setSizeFieldDecay $BoundaryDecay
  $ActualMesh setUnstructuredSolverAttribute Algorithm $AlgorithmSurface
  $ActualMesh setUnstructuredSolverAttribute IsoCellType $CellType

$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel Solve



puts "Done!"




#-------------------------------------------------------------------------------
# TE Wake refinement


puts "Creating Wake refinement for TE..."



if {$TERefinement == "ON"} {

  set ActualRadiusFar [expr {$RadiusFar * $Chord}]
  set ActualRefinementLength [expr {$RefinementLength * $Chord}]

  set TEPointFirst [extractPointFromLine [lindex $LinesConn2TE 0] $Connectors]
  set TEPointSecond [extractPointFromLine [lindex $LinesConn2TE 1] $Connectors]
  set TESpacing [extractTESpacing [lindex $LinesConn2TE 0] $Connectors]


  set TEDirection [pwu::Vector3 subtract $TEPointFirst $TEPointSecond]
  set RadiusTE [pwu::Vector3 length $TEDirection]


  if {$RadiusTE <= 1e-6} {
    set RadiusTE [expr {$TESpacing*6}]
  }



  set TERefinementPoint [pwu::Vector3 add $TEPointFirst $TEPointSecond]
  set TERefinementPoint [pwu::Vector3 scale $TERefinementPoint 0.5]

  set X [lindex $TERefinementPoint 0]
  set Y [lindex $TERefinementPoint 1]

  set _TMP(mode_1) [pw::Application begin Create]
    set _TMP(PW_1) [pw::GridShape create]
    $_TMP(PW_1) delete
    unset _TMP(PW_1)
    set _SR(1) [pw::SourceShape create]
    $_SR(1) cylinder -radius $RadiusTE -topRadius $ActualRadiusFar -length $ActualRefinementLength

    $_SR(1) setTransform [list 1 -0 0 0 0 1 0 0 -0 -0 1 0 $X $Y 0 1]
    $_SR(1) setPivot Base
    $_SR(1) setSectionMinimum 0
    $_SR(1) setSectionMaximum 360
    $_SR(1) setSidesType Plane
    $_SR(1) setBaseType Sphere
    $_SR(1) setTopType Sphere
    $_SR(1) setEnclosingEntities {}
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel {Create Shape}


  set _TMP(mode_1) [pw::Application begin Modify [list $_SR(1)]]
    pw::Entity transform [pwu::Transform rotation -anchor $TERefinementPoint {0 1 0} 90] [$_TMP(mode_1) getEntities]
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Rotate

  set _TMP(mode_1) [pw::Application begin Modify [list $_SR(1)]]
    $_SR(1) setBeginSpacing $TESpacing
    $_SR(1) setBeginDecay $BDRefTE
    $_SR(1) setEndSpacing [expr {$TESpacing * $TESpacingMult}]
    $_SR(1) setEndDecay $BDRefFar
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Sources

}


puts "Done!"

#-------------------------------------------------------------------------------
