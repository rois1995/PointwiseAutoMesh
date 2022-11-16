package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5




#-------------------------------------------------------------------------------
# Farfield construction

puts "Constructing Farfield..."

set FarfieldPoint [list]
lappend FarfieldPoint 0
lappend FarfieldPoint 0
lappend FarfieldPoint 0
lset FarfieldPoint 2 0

if { $FarfieldShape == "Circle" || $FarfieldShape == "Square" } {
  set ActualFarfieldDistance [expr {$FarfieldDistance * $Chord}]
}


if { $FarfieldShape == "Square" } {


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

}

if { $FarfieldShape == "Circle" } {

  set _TMP(mode_1) [pw::Application begin Create]
    set _TMP(PW_1) [pw::SegmentCircle create]
    set Point [pwu::Vector3 set $ActualFarfieldDistance 0 0]
    $_TMP(PW_1) addPoint $Point
    $_TMP(PW_1) addPoint {0 0 0}
    $_TMP(PW_1) setEndAngle 360 {0 0 1}
    set _CN(4) [pw::Connector create]
    $_CN(4) addSegment $_TMP(PW_1)
    $_CN(4) calculateDimension
    unset _TMP(PW_1)
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel {Create Connector}


  set _TMP(PW_1) [pw::Collection create]
  $_TMP(PW_1) set [list $_CN(4)]
  $_TMP(PW_1) do setDimensionFromSpacing -resetDistribution [expr {$FarfieldSpacing * $Chord}]
  $_TMP(PW_1) delete
  unset _TMP(PW_1)
  pw::CutPlane refresh
  pw::Application markUndoLevel Dimension

}

if { $FarfieldShape == "Gallery" } {

  set _TMP(mode_1) [pw::Application begin Create]
    set _TMP(PW_1) [pw::SegmentSpline create]

    set UpperLeft_X [lindex $GalleryExtrema 0]
    set UpperLeft_Y [lindex $GalleryExtrema 1]

    set UpperRight_X [lindex $GalleryExtrema 2]
    set UpperRight_Y [lindex $GalleryExtrema 3]

    set LowerRight_X [lindex $GalleryExtrema 4]
    set LowerRight_Y [lindex $GalleryExtrema 5]

    set LowerLeft_X [lindex $GalleryExtrema 6]
    set LowerLeft_Y [lindex $GalleryExtrema 7]

    lset FarfieldPoint 0 $UpperLeft_X
    lset FarfieldPoint 1 $UpperLeft_Y
    $_TMP(PW_1) addPoint $FarfieldPoint

    lset FarfieldPoint 0 $UpperRight_X
    lset FarfieldPoint 1 $UpperRight_Y
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

    lset FarfieldPoint 0 $UpperRight_X
    lset FarfieldPoint 1 $UpperRight_Y
    $_TMP(PW_1) addPoint $FarfieldPoint

    lset FarfieldPoint 0 $LowerRight_X
    lset FarfieldPoint 1 $LowerRight_Y
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

    lset FarfieldPoint 0 $LowerRight_X
    lset FarfieldPoint 1 $LowerRight_Y
    $_TMP(PW_1) addPoint $FarfieldPoint

    lset FarfieldPoint 0 $LowerLeft_X
    lset FarfieldPoint 1 $LowerLeft_Y
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

    lset FarfieldPoint 0 $LowerLeft_X
    lset FarfieldPoint 1 $LowerLeft_Y
    $_TMP(PW_1) addPoint $FarfieldPoint

    lset FarfieldPoint 0 $UpperLeft_X
    lset FarfieldPoint 1 $UpperLeft_Y
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


}

#-------------------------------------------------------------------------------


puts "Creating mesh..."

  # I have to check if the orientation of the airfoil is correct or not
  set Airfoil [pw::Edge create]
  $Airfoil addConnector [lindex [lindex $Connectors 0] 1]

  set  completion [findEdgeCompletion $Airfoil]
  foreach con $completion {
    $Airfoil addConnector $con
  }

  set AirfoilMesh_ToDelete [pw::DomainUnstructured create]
  $AirfoilMesh_ToDelete addEdge $Airfoil

  set AirfoilProj [$AirfoilMesh_ToDelete getDefaultProjectDirection]


  # Then check if Farfield and Airfoil have the same orientation or not.
  # If yes, reverse the farfield

  set Farfield [pw::Edge create]

  if { $FarfieldShape == "Square" || $FarfieldShape == "Gallery" } {
    $Farfield addConnector $_CN(6)
    $Farfield addConnector $_CN(7)
    $Farfield addConnector $_CN(4)
    $Farfield addConnector $_CN(5)
  }

  if { $FarfieldShape == "Circle" } {
    $Farfield addConnector $_CN(4)
  }

  set FarfieldMesh_ToDelete [pw::DomainUnstructured create]
  $FarfieldMesh_ToDelete addEdge $Farfield
  set FarfieldProj [$FarfieldMesh_ToDelete getDefaultProjectDirection]
  set FarfieldReverse false
  if {[lindex $AirfoilProj 2] == [lindex $FarfieldProj 2]} {
    set FarfieldReverse true
  }

  $AirfoilMesh_ToDelete delete
  $FarfieldMesh_ToDelete delete

  set Farfield [pw::Edge create]

  if { $FarfieldShape == "Square" || $FarfieldShape == "Gallery" } {
    $Farfield addConnector $_CN(6)
    $Farfield addConnector $_CN(7)
    $Farfield addConnector $_CN(4)
    $Farfield addConnector $_CN(5)
  }

  if { $FarfieldShape == "Circle" } {
    $Farfield addConnector $_CN(4)
  }

  set Airfoil [pw::Edge create]
  $Airfoil addConnector [lindex [lindex $Connectors 0] 1]

  set  completion [findEdgeCompletion $Airfoil]
  foreach con $completion {
    $Airfoil addConnector $con
  }

  if { $FarfieldReverse } {
    $Farfield reverse
  }


  set ActualMesh [pw::DomainUnstructured create]
  $ActualMesh addEdge $Farfield
  $ActualMesh addEdge $Airfoil



  # unset Airfoil
  unset Farfield


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

    set iCon 0
    foreach con $Connectors {
      set conName [lindex $con 1]
      set spaceFun [lindex [lindex $AirfoilLinesList $iCon] 3]
      if {$spaceFun != "Shape"} {
        if { [catch {$_TMP(PW_1) apply [list [list $ActualMesh $conName Same]] } ] } {
          $_TMP(PW_1) apply [list [list $ActualMesh $conName Opposite]]
        } else {
          $_TMP(PW_1) apply [list [list $ActualMesh $conName Same]]
        }
      }

      set iCon [expr {$iCon+1}]
    }

    $_TMP(PW_1) setConditionType Wall
    $_TMP(PW_1) setAdaptation Off
    $_TMP(PW_1) setValue $InitialSpacing

    unset _TMP(PW_1)

  }


    set _TMP(PW_2) [pw::TRexCondition create]
    unset _TMP(PW_2)
    if {$Euler == "OFF"} {
      set _TMP(PW_2) [pw::TRexCondition getByName bc-3]
    } else {
      set _TMP(PW_2) [pw::TRexCondition getByName bc-2]
    }

    $_TMP(PW_2) setName Ice

    set iCon 0
    foreach con $Connectors {
      set conName [lindex $con 1]
      set spaceFun [lindex [lindex $AirfoilLinesList $iCon] 3]
      if {$spaceFun == "Shape"} {
        if { [catch {$_TMP(PW_2) apply [list [list $ActualMesh $conName Same]] } ] } {
          $_TMP(PW_2) apply [list [list $ActualMesh $conName Opposite]]
        } else {
          $_TMP(PW_2) apply [list [list $ActualMesh $conName Same]]
        }
      }

      set iCon [expr {$iCon+1}]
    }

    $_TMP(PW_2) setAdaptation On

  if {$Euler == "OFF"} {
    $_TMP(PW_2) setConditionType Wall
    $_TMP(PW_2) setValue $InitialSpacing

    $ActualMesh setUnstructuredSolverAttribute TRexGrowthRate $GrowthRateBL
    $ActualMesh setUnstructuredSolverAttribute TRexCellType $CellTypeBL

    if { $FarfieldShape == "Gallery"} {
      if { $FarfieldBC == "NS" } {
        set WallGallery [pw::TRexCondition create]
        set WallGallery [pw::TRexCondition getByName bc-4]
        $WallGallery setName GalleryWalls
        $WallGallery setConditionType Wall
        $WallGallery setValue $FarfieldInitialSpacing
        if { $FarfieldInitialSpacing == "Same" } {
            $WallGallery setValue $InitialSpacing
        }

        if { [catch {$WallGallery apply [list [list $ActualMesh $_CN(4) Same]] } ] } {
          $WallGallery apply [list [list $ActualMesh $_CN(4) Opposite]]
        } else {
          $WallGallery apply [list [list $ActualMesh $_CN(4) Same]]
        }
        if { [catch {$WallGallery apply [list [list $ActualMesh $_CN(6) Same]] } ] } {
          $WallGallery apply [list [list $ActualMesh $_CN(6) Opposite]]
        } else {
          $WallGallery apply [list [list $ActualMesh $_CN(6) Same]]
        }


        set WallMatch [pw::TRexCondition create]
        set WallMatch [pw::TRexCondition getByName bc-5]
        $WallMatch setName GalleryMatch
        $WallMatch setConditionType Match

        if { [catch {$WallMatch apply [list [list $ActualMesh $_CN(5) Same]] } ] } {
          $WallMatch apply [list [list $ActualMesh $_CN(5) Opposite]]
        } else {
          $WallMatch apply [list [list $ActualMesh $_CN(5) Same]]
        }
        if { [catch {$WallMatch apply [list [list $ActualMesh $_CN(7) Same]] } ] } {
          $WallMatch apply [list [list $ActualMesh $_CN(7) Opposite]]
        } else {
          $WallMatch apply [list [list $ActualMesh $_CN(7) Same]]
        }
      }
    }

  }





  $ActualMesh setSizeFieldDecay $BoundaryDecay
  $ActualMesh setSizeFieldBackgroundSpacing [expr {$FarfieldSpacing * $Chord}]
  $ActualMesh setUnstructuredSolverAttribute EdgeMaximumLength Boundary
  $ActualMesh setUnstructuredSolverAttribute IsoCellType $CellType
  $ActualMesh setUnstructuredSolverAttribute Algorithm $AlgorithmSurface

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

  # puts $TEPointFirst
  # puts $TEPointSecond


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

set PointwiseFilename $path$PointwiseName
pw::Application save $PointwiseFilename


puts "Done!"

#-------------------------------------------------------------------------------
