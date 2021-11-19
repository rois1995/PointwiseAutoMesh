package require PWI_Glyph 4.18.4



puts "Define connectors spacings..."


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

  }

  set bufferListBig [list]
  lappend bufferListBig $Name
  lappend bufferListBig $bufferList
  lappend ConSpacingsAll $bufferListBig

  set i [expr {$i+1}]
}


# puts $ConSpacings2Complete

# Now asign spacing values with their functions
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



  # End
  set SpacFunEnd [lindex $SpacFun 2]
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

  if {[lindex $con 1] == "Growth"} {

    set connector [lindex $con 0]
    set Spacings [list]
    lappend Spacings $BeginSpacing
    lappend Spacings $EndSpacing
    set MidSpacing [lindex $SpacFun 1]
    set MidSpacing [expr {$MidSpacing * $Chord}]
    set GrowthRates [lindex $con 3]

    # puts $connector
    # puts $Spacings
    # puts $MidSpacing
    setGrowthDistr $connector $Spacings $GrowthRates $MidSpacing
  }
}



puts "Done!"
