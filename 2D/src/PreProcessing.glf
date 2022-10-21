package require PWI_Glyph 4.18.4



puts "Define connectors spacings..."


if {!$UseFileDistribution} {

  set i 0
  set ConSpacings2Complete [list]
  set ConSpacingsAll [list]
  # First compute all of the spacings for non uniform connectors
  # and define uniform connectors
  foreach AirfoilLine $AirfoilLinesList {


    set Name [lindex $AirfoilLine 2]
    set SpacFun [lindex $AirfoilLine 3]
    set SpaceTypes [lindex $AirfoilLine 4]
    set SpaceValues [lindex $AirfoilLine 5]
    set GrowthRates [lindex $AirfoilLine 6]


    set Con [lindex [lindex $Connectors $i] 1]


    if {$SpacFun == "Growth" || $SpacFun == "Tanh"} {

      # Extract beginning spacings
      if {[lindex $SpaceTypes 0] == "Angle"} {
        set BeginSpacing [extractAngularSpacing $Con [lindex $SpaceValues 0] "Begin"]
      } elseif {[lindex $SpaceTypes 0] == "Value"} {
        set BeginSpacing [lindex $SpaceValues 0]
      } else {
        set BeginSpacing [lindex $SpaceTypes 0]
      }

      # Extract End spacings
      if {[lindex $SpaceTypes 2] == "Angle"} {
        set EndSpacing [extractAngularSpacing $Con [lindex $SpaceValues 2] "End"]
      } elseif {[lindex $SpaceTypes 2] == "Value"} {
        set EndSpacing [lindex $SpaceValues 2]
      } else {
        set EndSpacing [lindex $SpaceTypes 2]
      }

      set bufferList [list]
      lappend bufferList $BeginSpacing
      lappend bufferList [lindex $SpaceValues 1]
      lappend bufferList $EndSpacing


      set bufferListBig [list]
      lappend bufferListBig $Con
      lappend bufferListBig $SpacFun
      lappend bufferListBig $bufferList
      if {$SpacFun == "Growth"} {
        lappend bufferListBig $GrowthRates
      }

      lappend ConSpacings2Complete $bufferListBig

    } elseif {$SpacFun == "Uniform"} {

      if {$SpaceTypes == "NPoints"} {
        set Dimension [lindex $AirfoilLine 5]
        $Con setDimension $Dimension

        set BeginSpacing [extractSpacing $Con "Begin"]
        set MidSpacing $BeginSpacing
        set EndSpacing [extractSpacing $Con "End"]

      } elseif {$SpaceTypes == "MeanSpace"} {
        set MeanSpace [lindex $AirfoilLine 5]
        $Con setDimensionFromSpacing -resetDistribution $MeanSpace

        set BeginSpacing $MeanSpace
        set MidSpacing $MeanSpace
        set EndSpacing $MeanSpace
      }


      set bufferList [list]
      lappend bufferList $BeginSpacing
      lappend bufferList $MidSpacing
      lappend bufferList $EndSpacing

    } elseif {$SpacFun == "Shape"} {

      # Extract angular spacing
      set angularSpacing [lindex $SpaceValues 0]

      # Extract max spacing
      set maxSpacing [lindex $SpaceValues 1]

      set bufferList [list]
      lappend bufferList $angularSpacing
      lappend bufferList $maxSpacing


      set bufferListBig [list]
      lappend bufferListBig $Con
      lappend bufferListBig $SpacFun
      lappend bufferListBig $bufferList
      if {$SpacFun == "Shape"} {
        lappend bufferListBig $GrowthRates
      }

      lappend ConSpacings2Complete $bufferListBig

    }

    set bufferListBig [list]
    lappend bufferListBig $Name
    lappend bufferListBig $bufferList
    lappend ConSpacingsAll $bufferListBig

    set i [expr {$i+1}]
  }


  set ConSpacings2CompleteSaved $ConSpacings2Complete

  # First do all of the connectors which have everything fixed

  # Now assign spacing values with their functions
  for {set j 0} {$j < [llength $ConSpacings2Complete]} {incr j} {

    set con [lindex $ConSpacings2Complete $j]

    # Extract spacing functions
    set SpacFun [lindex $con 2]




    # Begin
    set SpacFunBegin [lindex $SpacFun 0]
    set SpacFunBegin [split $SpacFunBegin "_"]

    if {[lindex $con 1] != "Shape"} {


      # End
      set SpacFunEnd [lindex $SpacFun 2]
      set SpacFunEnd [split $SpacFunEnd "_"]

      if {[llength $SpacFunBegin] == 1 && [llength $SpacFunEnd] == 1} {

        set BeginSpacing $SpacFunBegin
        set EndSpacing $SpacFunEnd

        if {[lindex $con 1] == "Growth"} {

          set connector [lindex $con 0]
          set Spacings [list]
          lappend Spacings $BeginSpacing
          lappend Spacings $EndSpacing
          set MidSpacing [lindex $SpacFun 1]
          set MidSpacing $MidSpacing
          set GrowthRates [lindex $con 3]

          # puts $connector
          # puts $Spacings
          # puts $MidSpacing
          setGrowthDistr $connector $Spacings $GrowthRates $MidSpacing
        } elseif {[lindex $con 1] == "Tanh"} {

          set connector [lindex $con 0]
          set Spacings [list]
          lappend Spacings $BeginSpacing
          lappend Spacings $EndSpacing

          setTanhDistr $connector $Spacings
        }

        set ConSpacings2Complete [lreplace $ConSpacings2Complete $j $j]
        set j [expr {$j - 1}]

      }
    } else {

      set connector [lindex $con 0]
      set BeginSpacing $SpacFunBegin
      set Angle $BeginSpacing

      setShapeDistr $connector $Angle

      set ConSpacings2Complete [lreplace $ConSpacings2Complete $j $j]
      set j [expr {$j - 1}]



    }

  }


  # puts $ConSpacings2Complete


  # Now assign spacing values with their functions
  foreach con $ConSpacings2Complete {

    # Extract spacing functions
    set SpacFun [lindex $con 2]


    # Begin
    set SpacFunBegin [lindex $SpacFun 0]
    set SpacFunBegin [split $SpacFunBegin "_"]


    # Check if it is in the form ConName_Begin or ConName_End
    if {[llength $SpacFunBegin] > 1 } {

      set conName2Find [lindex $SpacFunBegin 0]
      set whichSpacing [lindex $SpacFunBegin 1]

      if {$whichSpacing == "Begin"} {
        set whichSpacing 0
      } elseif {$whichSpacing == "End"} {
        set whichSpacing 2
      }

      # find the connector from which to take the spacing
      foreach Line $ConSpacingsAll {
        set conName [lindex $Line 0]
        if { $conName2Find == $conName} {
          set BeginSpacing [lindex [lindex $Line 1] $whichSpacing]
        }
      }

    } else {
      set BeginSpacing $SpacFunBegin
    }


    if {[lindex $con 1] != "Shape" } {

      # End
      set SpacFunEnd [lindex $SpacFun  2]
      set SpacFunEnd [split $SpacFunEnd "_"]

      # Check if it is in the form ConName_Begin or ConName_End
      if {[llength $SpacFunEnd] > 1 } {

        set conName2Find [lindex $SpacFunEnd 0]
        set whichSpacing [lindex $SpacFunEnd 1]

        if {$whichSpacing == "Begin"} {
          set whichSpacing 0
        } elseif {$whichSpacing == "End"} {
          set whichSpacing 2
        }

        # find the connector from which to take the spacing
        foreach Line $ConSpacingsAll {
          set conName [lindex $Line 0]
          if { $conName2Find == $conName} {
            set EndSpacing [lindex [lindex $Line 1] $whichSpacing]
          }
        }

      } else {
        set EndSpacing [lindex [lindex $con 2] 2]
      }
    }

    if {[lindex $con 1] == "Growth"} {

      set connector [lindex $con 0]
      set Spacings [list]
      lappend Spacings $BeginSpacing
      lappend Spacings $EndSpacing
      set MidSpacing [lindex $SpacFun 1]
      set MidSpacing $MidSpacing
      set GrowthRates [lindex $con 3]

      # puts $connector
      # puts $Spacings
      # puts $MidSpacing
      setGrowthDistr $connector $Spacings $GrowthRates $MidSpacing
    } elseif {[lindex $con 1] == "Tanh"} {

      set connector [lindex $con 0]
      set Spacings [list]
      lappend Spacings $BeginSpacing
      lappend Spacings $EndSpacing

      setTanhDistr $connector $Spacings
    }

    # if {[lindex $con 1] == "Shape"} {
    #
    #   set connector [lindex $con 0]
    #   set Angle $BeginSpacing
    #
    #   # puts $connector
    #   # puts $Spacings
    #   # puts $MidSpacing
    #   setShapeDistr $connector $Angle
    # }
  }

  set ConSpacings2Complete $ConSpacings2CompleteSaved

}









# Now check if airfoil orientation is as requested

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
set AirfoilReverse false
set hasBeenReversed false
if {[lindex $AirfoilProj 2] == 1 && $AirfoilOrientation == "Clockwise"} {

  foreach ConCouple $Connectors {
    [lindex $ConCouple 1] setOrientation IMaximum
  }

  set hasBeenReversed true

} elseif {[lindex $AirfoilProj 2] == -1 && $AirfoilOrientation == "CounterClockwise"} {
  foreach ConCouple $Connectors {
    [lindex $ConCouple 1] setOrientation IMaximum
  }
  set hasBeenReversed true
}

if {$hasBeenReversed} {
  set Con2Mod 0
  if {[lindex TEPointFirst 1] > [lindex TEPointSecond 1]} {
    set Con2Mod 1
  }
  set Con [lindex $LinesConn2TE $Con2Mod]
  set conName [split $Con "_"]
  set Name [lindex $conName 0]
  set whichSide [lindex $conName 1]
  if {$whichSide == "Begin"} {
    set whichSide "End"
  } elseif {$whichSide == "End"} {
    set whichSide "Begin"
  }
  set lowSpace "_"
  set cose $Name$lowSpace$whichSide
  set LinesConn2TE [lreplace $LinesConn2TE $Con2Mod $Con2Mod $cose]

  set Con2Mod 1
  if {[lindex TEPointFirst 1] > [lindex TEPointSecond 1]} {
    set Con2Mod 1
  }
  set Con [lindex $LinesConn2TE $Con2Mod]
  set conName [split $Con "_"]
  set Name [lindex $conName 0]
  set whichSide [lindex $conName 1]
  if {$whichSide == "Begin"} {
    set whichSide "End"
  } elseif {$whichSide == "End"} {
    set whichSide "Begin"
  }
  set lowSpace "_"
  set cose $Name$lowSpace$whichSide
  set LinesConn2TE [lreplace $LinesConn2TE $Con2Mod $Con2Mod $cose]
}


$AirfoilMesh_ToDelete delete

puts "Done!"
