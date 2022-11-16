package require PWI_Glyph 4.18.4



puts "Define connectors spacings..."


# Now check if airfoil orientation is as requested

# First of all rotate every connector such that a connector starts where the previous one ends

# First of all I create the airfil edge
set Airfoil [pw::Edge create]
$Airfoil addConnector [lindex [lindex $Connectors 0] 1]

set  completion [findEdgeCompletion $Airfoil]
foreach con $completion {
  $Airfoil addConnector $con
}




for {set IthCon 2} {$IthCon <= [$Airfoil getConnectorCount]} {incr IthCon} {

    # puts $IthCon

    set ConSucc [$Airfoil getConnector $IthCon]
    set ConPrev [$Airfoil getConnector [expr {$IthCon -1}]]

    set StartPointSucc [ $ConSucc getXYZ -parameter 0.0]
    set EndPointPrec [ $ConPrev getXYZ -parameter 1.0]
    set Distance [PPDistance $StartPointSucc $EndPointPrec]
    # puts $ConPrev
    # puts $ConSucc
    if { $Distance > 1e-8 } {
      # puts $StartPointSucc
      # puts $EndPointPrec
      $ConSucc setOrientation IMaximum
      set StartPointSucc [ $ConSucc getXYZ -parameter 0.0]
      # puts $StartPointSucc
    }

}


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

# Set the desired airfoil projection as the counterclockwise value (1)
set DesiredAirfoilProj 1
if { $AirfoilOrientation == "Clockwise" } {
  set DesiredAirfoilProj -1
}


if {[expr {[lindex $AirfoilProj 2] * $DesiredAirfoilProj}] == -1} {

  for {set IthCon 1} {$IthCon <= [$Airfoil getConnectorCount]} {incr IthCon} {
    [$Airfoil getConnector $IthCon] setOrientation IMaximum
  }

}


$AirfoilMesh_ToDelete delete


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

    # puts $bufferListBig

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

    if {[lindex $con 1] != "Shape"} {


      # End
      set SpacFunEnd [lindex $SpacFun 2]

      if { $SpacFunBegin != "ToMakeEqual" && $SpacFunEnd != "ToMakeEqual" } {

        set BeginSpacing $SpacFunBegin
        set EndSpacing $SpacFunEnd

        if {[lindex $con 1] == "Growth"} {

          set connector [lindex $con 0]
          set Spacings [list]
          lappend Spacings $BeginSpacing
          lappend Spacings $EndSpacing

          # puts $connector
          # puts $Spacings

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


}











set Airfoil [pw::Edge create]
$Airfoil addConnector [lindex [lindex $Connectors 0] 1]

set  completion [findEdgeCompletion $Airfoil]
foreach con $completion {
  $Airfoil addConnector $con
}

# Now set spacings of all of the other connectors
if {!$UseFileDistribution} {

  # foreach Couple $Connectors {
  #   puts [lindex $Couple 0]
  #   puts [lindex $Couple 1]
  #   puts " "
  # }
  # for {set IthCon 1} {$IthCon <= [$Airfoil getConnectorCount]} {incr IthCon} {
  #   puts [$Airfoil getConnector $IthCon]
  # }


  # for {set i 0} {$i < [llength $ConSpacings2Complete]} {incr i} {
  #   puts [lindex [lindex $ConSpacings2Complete $i] 0]
  # }
  # puts " "

  for {set IthCon 1} {$IthCon <= [$Airfoil getConnectorCount]} {incr IthCon} {

    # Search for the corresponding connector in the spacing vectors
    set IthConOrigVector 0
    set IsIn 0
    for {set i 0} {$i < [llength $ConSpacings2Complete]} {incr i} {
      # puts [$Airfoil getConnector $IthCon]
      # puts [lindex [lindex $ConSpacings2Complete $i] 0]
      if { [$Airfoil getConnector $IthCon] == [lindex [lindex $ConSpacings2Complete $i] 0]} {
        set IthConOrigVector $i
        set IsIn 1
        set i [llength $ConSpacings2Complete]
      }
    }

    # Check if the connector is yet to be set
    if { $IsIn == 1} {
      # puts " "

      # puts [$Airfoil getConnector $IthCon]
      # puts  [lindex [lindex $ConSpacings2Complete $IthConOrigVector] 0]
      # puts " "
      # puts " "

      set Con [lindex $ConSpacings2Complete $IthConOrigVector]
      # puts [lindex $Con 2]
      # Begin Spacing
      set BeginSpacing [lindex [lindex $Con 2] 0]
      # puts $BeginSpacing
      # Check if the spacing has to be taken from another connector
      if { $BeginSpacing == "ToMakeEqual" } {
        set IthConHere [expr {$IthCon - 1}]
        if { $IthConHere == 0 } {
          set IthConHere [$Airfoil getConnectorCount]
        }
        set PrevCon [$Airfoil getConnector $IthConHere]
        set BeginSpacing [extractSpacing $PrevCon "End"]
      }

      set MidSpacing [lindex [lindex $Con 2] 1]

      # End spacing
      set EndSpacing [lindex [lindex $Con 2] 2]
      # Check if the spacing has to be taken from another connector
      if { $EndSpacing == "ToMakeEqual" } {
        set IthConHere [expr {$IthCon + 1}]
        if { $IthConHere > [$Airfoil getConnectorCount] } {
          set IthConHere 1
        }
        set SucCon [$Airfoil getConnector $IthConHere]
        set EndSpacing [extractSpacing $SucCon "Begin"]
      }



      set SpacType [lindex $Con 1]
      if {$SpacType == "Growth"} {


        set connector [lindex $Con 0]
        set GrowthRates [lindex $Con 3]
        set Spacings [list]
        lappend Spacings $BeginSpacing
        lappend Spacings $EndSpacing

        # puts $connector
        # puts $Spacings
        # puts $MidSpacing
        setGrowthDistr $connector $Spacings $GrowthRates $MidSpacing

      } elseif {$SpacType == "Tanh"} {

        set connector [lindex $Con 0]
        set Spacings [list]
        lappend Spacings $BeginSpacing
        lappend Spacings $EndSpacing

        setTanhDistr $connector $Spacings

      }
    }
  }

  # set ConSpacings2Complete $ConSpacings2CompleteSaved

}


# set PointwiseFilename $path$PointwiseName
# pw::Application save $PointwiseFilename
#
# a



# $AirfoilMesh_ToDelete delete



puts "Done!"
