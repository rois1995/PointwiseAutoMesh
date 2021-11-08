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



proc setTanhDistr { connector ExtremesSpacing } {

  set _TMP(mode_1) [pw::Application begin Modify [list $connector]]
    pw::Connector swapDistribution Tanh [list [list $connector 1]]
    set Distr [$connector getDistribution 1]

    $Distr setBeginSpacing [lindex $ExtremesSpacing 0]
    $Distr setEndSpacing [lindex $ExtremesSpacing 1]

    $connector setSubConnectorDimensionFromDistribution 1
  $_TMP(mode_1) end
  unset _TMP(mode_1)
  pw::Application markUndoLevel Distribute

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
