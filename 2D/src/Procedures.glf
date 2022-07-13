package require PWI_Glyph 4.18.4



# Extract vector quantities from settings
proc extractVectorSettings { settings } {
  set N [llength $settings]
  set OnlyQuantities [lrange $settings 2 [expr {$N-2}]]

  set ToExtract [list]

  foreach Quantity $OnlyQuantities {
    lappend ToExtract [string trimright $Quantity ,]
  }

  return $ToExtract
}



# Create a procedure for extracting the spacing
proc extractSpacing { connector whichSpacing } {

  set Dimension [$connector getDimension]

  if { $whichSpacing=="Begin" } {

    # Extract begin spacing
    set Point1 [$connector getXYZ -grid [list 1]]
    set Point2 [$connector getXYZ -grid [list 2]]

  } else {

    # Extract end spacing
    set Point1 [$connector getXYZ -grid [list $Dimension]]
    set Point2 [$connector getXYZ -grid [list [expr {$Dimension - 1}]]]

  }


  set Vec [pwu::Vector3 subtract $Point2 $Point1]
  set Distance [pwu::Vector3 length $Vec]
  return $Distance

}


proc setSpacing { connector Spacing whichSpacing} {

  set _TMP(mode_1) [pw::Application begin Modify [list $connector]]
    set Distr [$connector getDistribution 1]

    if { $whichSpacing=="Begin" } {
      $Distr setBeginSpacing $Spacing
    } else {
      $Distr setEndSpacing $Spacing
    }

    $connector setSubConnectorDimensionFromDistribution 1
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Distribute

}


proc extractAngularSpacing { connector angularSpacing whichSpacing } {

  set _TMP(mode_1) [pw::Application begin Modify [list $connector]]
    pw::Connector swapDistribution Shape [list [list $connector 1]]
    [$connector getDistribution 1] setNormalMaximumDeviation $angularSpacing
    $connector setSubConnectorDimensionFromDistribution 1
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Distribute

  return [extractSpacing $connector $whichSpacing]
}


# Re-orient connector so that it goes as the x-axis
proc ReOrientConnector { connector } {

   set Dimension [$connector getDimension]
   set Start [$connector getXYZ -grid [list 1]]
   set End [$connector getXYZ -grid [list $Dimension]]

   set XStart [lindex $Start 0]
   set XEnd [lindex $End 0]

   if { $XStart > $XEnd } {
      set ents [list $connector]
      set _TMP(mode_1) [pw::Application begin Modify $ents]
      $connector setOrientation IMaximum
      $_TMP(mode_1) end
      unset _TMP(mode_1)
      pw::Application markUndoLevel Orient
   }
}




proc setGrowthDistr { connector ExtremesSpacing GrowthRate MiddleSpacing} {

  set _TMP(mode_1) [pw::Application begin Modify [list $connector]]
    $connector replaceDistribution 1 [pw::DistributionGrowth create]
    set Distr [$connector getDistribution 1]

    $Distr setBeginSpacing [lindex $ExtremesSpacing 0]
    $Distr setEndSpacing [lindex $ExtremesSpacing 1]

    $Distr setMiddleMode ContinueGrowth

    $Distr setBeginRate [lindex $GrowthRate 0]
    $Distr setEndRate [lindex $GrowthRate 1]

    $Distr setMiddleSpacing $MiddleSpacing

    $connector setSubConnectorDimensionFromDistribution 1
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Distribute

}


proc setTanhDistr { connector Spacings} {

  set _TMP(mode_1) [pw::Application begin Modify [list $connector]]
    pw::Connector swapDistribution Tanh [list [list $connector 1]]
    set Distr [$connector getDistribution 1]
    [$Distr getBeginSpacing] setValue [lindex $Spacings 0]
    [$Distr getEndSpacing] setValue [lindex $Spacings 1]
    $connector setSubConnectorDimensionFromDistribution 1
  $_TMP(mode_1) end

}


proc findEdgeCompletion { edge } {

  set hint [pw::DomainUnstructured getAutoCompleteHint $edge]
  lassign $hint front end
  set frontNames {}; set endNames {}
  foreach ent $front {
      lappend frontNames [$ent getName]
  }
  foreach ent $end {
      lappend endNames [$ent getName]
  }
  # puts $frontNames;
  # puts $endNames

  return $end
}





proc extractPointFromLine { conName allConenctors} {

  set conName [split $conName "_"]
  set Name [lindex $conName 0]
  set whichSide [lindex $conName 1]


  foreach con $allConenctors {
    if {[lindex $con 0] == $Name} {
      if {$whichSide == "Begin"} {
        return [[lindex $con 1] getXYZ -grid [list 1]]
      } else {
        set Dimension [[lindex $con 1] getDimension]
        return [[lindex $con 1] getXYZ -grid [list $Dimension]]
      }
    }
  }

}



proc extractTESpacing { conName allConenctors} {

  set conName [split $conName "_"]
  set Name [lindex $conName 0]
  set whichSide [lindex $conName 1]


  foreach con $allConenctors {
    if {[lindex $con 0] == $Name} {
      return [extractSpacing [lindex $con 1] $whichSide]
    }
  }

}


proc extractDistr { connector } {

  set Points [list]

  # puts $connector

  set Dimension [$connector getDimension]

  for {set i 1} {$i <= $Dimension} { incr i } {
    lappend Points [$connector getXYZ -grid [list $i]]
  }

  return $Points

}


proc setShapeDistr { connector angle} {

  set _TMP(mode_1) [pw::Application begin Modify [list $connector]]
    pw::Connector swapDistribution Shape [list [list $connector 1]]
    set Distr [$connector getDistribution 1]

    $Distr setNormalMaximumDeviation $angle
    $Distr setCurveMaximumDeviation $angle

    $connector setSubConnectorDimensionFromDistribution 1
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Distribute

}

proc PPDistance {P1 P2} {

  set Gap [pwu::Vector3 subtract $P1 $P2]
  return [pwu::Vector3 length $Gap]

}




proc checkConnectorSpacings { AirfoilEdge Connectors } {

  # Otherwise it will take a lot to redo the mesh at each modification
  pw::DomainUnstructured setInitializeInterior 0


  set orderedConn [$AirfoilEdge getConnectors]
  set NConn [llength $orderedConn]
  # puts $orderedConn
  # puts $Connectors

  # Cycle on all of the sorted connectors
  for {set i 0} {$i < $NConn} {incr i} {

    # First set the index for the following connector
    set j [expr {$i + 1}]
    if {$i == [expr {$NConn - 1}]} {
      # if i is the last connector then the following one is the first one
      set j 0
    }

    # Extract connectors
    set Conn1 [lindex $orderedConn $i]
    set Conn2 [lindex $orderedConn $j]

    set index1 0
    # Find first connector among the list that contains them all
    for {set k 0} {$k < $NConn} {incr k} {
      if {$Conn1 == [lindex [lindex $Connectors $k] 0]} {
        set index1 $k
      }
    }

    set index2 0
    # Find second connector among the list that contains them all
    for {set k 0} {$k < $NConn} {incr k} {
      if {$Conn2 == [lindex [lindex $Connectors $k] 0]} {
        set index2 $k
      }
    }

    #Extract spacing functions
    set spaceFun1 [lindex [lindex $Connectors $index1] 1]
    set spaceFun2 [lindex [lindex $Connectors $index2] 1]

    # Check if any of the 2 conenctors has uniform spacing
    if {$spaceFun1 != "Uniform" && $spaceFun2 != "Uniform"} {

      # Now I have to check how the connectos are conencted.
      # If it is End-Begin or Begin-End
      set conDim1 [$Conn1 getDimension]
      set conDim2 [$Conn2 getDimension]

      set beginPoint1 [$Conn1 getXYZ -grid [list 1]]
      set endPoint1 [$Conn1 getXYZ -grid [list $conDim1]]

      set beginPoint2 [$Conn2 getXYZ -grid [list 1]]
      set endPoint2 [$Conn2 getXYZ -grid [list $conDim2]]

      # Pre-set the connection to be End of the first one -> Begin of the second one
      set connection "End_Begin"

      # Set tolerance for equality
      set toll 1e-4
      if {[pwu::Vector3 equal -tolerance $toll $beginPoint1 $endPoint2] } {
        # Set the connection to be Begin of the first one -> End of the second one
        set connection "Begin_End"
      }

      # Now split the string to obtain {"Begin" "End"} or {"End" "Begin"}
      set connection [split $connection "_"]


      # Now check if the first spacing function is a shape one
      if {$spaceFun1 == "Shape"} {

        # Extract spacing from the shape connector and set to the other connector
        set spacingShape [extractSpacing $Conn1 [lindex $connection 0]]

        # Now enforce spacing on the other connector
        setSpacing $Conn2 $spacingShape [lindex $connection 1]


      } elseif {$spaceFun2 == "Shape"} {
        # Check if the second spacing function is a shape one

        # Extract spacing from the shape connector and set to the other connector
        set spacingShape [extractSpacing $Conn2 [lindex $connection 1]]

        # Now enforce spacing on the other connector
        setSpacing $Conn1 $spacingShape [lindex $connection 0]

      } else {
        # if none of these are shape functions then it is easy

        # Extract spacing from both connectors
        set spacing1 [extractSpacing $Conn1 [lindex $connection 0]]
        set spacing2 [extractSpacing $Conn2 [lindex $connection 1]]

        # Enforce the smallest one
        if {$spacing1 < $spacing2} {
          setSpacing $Conn2 $spacing1 [lindex $connection 1]
        } else {
          setSpacing $Conn1 $spacing2 [lindex $connection 0]
        }

      }
    }
  }


  pw::DomainUnstructured setInitializeInterior 1

  global ActualMesh

  set _TMP(mode_1) [pw::Application begin UnstructuredSolver [list $ActualMesh]]
    $_TMP(mode_1) run Initialize
  $_TMP(mode_1) end
  unset _TMP(mode_1)

}
