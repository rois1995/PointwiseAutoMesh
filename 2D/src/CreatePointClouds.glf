package require PWI_Glyph 4.18.4


set i 0

if {$Euler == "OFF"} {
  set initialSpacingOriginal $InitialSpacing
}

foreach AirfoilLine $AirfoilLinesList {

  # If the spacing distribution is anything but Shape, then simply
  # create a point cloud with points equal to the connector points and
  # spacing equal to the connettor spacing

  set SpacingFun [lindex $AirfoilLine 3]
  set Con [lindex [lindex $Connectors $i] 1]
  set Name [lindex $AirfoilLine 2]

  if {$SpacingFun == "Shape"} {


    # Then create a new point cloud source
    set cloud [pw::SourcePointCloud create]
    set name "Refinement_"
    set name $name$Name
    $cloud setName $name


    set SpaceValues [lindex $AirfoilLine 5]
    set maxSpacing [lindex $SpaceValues 1]

    # First extract the distribution
    set ShapeDistr [extractDistr $Con]

    set srcPts [list]

    set NPoints [llength $ShapeDistr]
    # set NPoints [expr {$NPoints - 1}]


    for {set j 1} { $j < $NPoints} {incr j} {
      set PointStart [lindex $ShapeDistr [expr {$j-1}]]
      set PointEnd [lindex $ShapeDistr $j]
      set Gap [PPDistance $PointEnd $PointStart]
      if {$Gap > $maxSpacing} {
        if {$Gap > [expr {$maxSpacing * 2}]} {

          set sum $maxSpacing
          set Direction [pwu::Vector3 subtract $PointEnd $PointStart]
          set Direction [pwu::Vector3 normalize $Direction]

          while {$sum < $Gap} {

            set scaledDir [pwu::Vector3 scale $Direction $sum]
            set newPoint [pwu::Vector3 add $PointStart $scaledDir]
            lappend srcPts [list $newPoint $maxSpacing 0.9]
            set sum [expr {$sum + $maxSpacing}]
          }
        } else {
          lappend srcPts [list $PointEnd $maxSpacing 0.9]
        }
      }
      if {$Euler == "OFF"} {
        if {$Gap < $InitialSpacing} {
          set InitialSpacing $Gap
        }
      }
    }

    # puts [llength $srcPts]

    $cloud addPoints $srcPts

  } else {

    # Then create a new point cloud source
    set cloud [pw::SourcePointCloud create]
    set name "Refinement_"
    set name $name$Name
    $cloud setName $name

    # First extract the distribution
    set ShapeDistr [extractDistr $Con]

    set srcPts [list]

    set NPoints [llength $ShapeDistr]
    # set NPoints [expr {$NPoints - 1}]


    for {set j 1} { $j < $NPoints} {incr j} {
      set PointStart [lindex $ShapeDistr [expr {$j-1}]]
      set PointEnd [lindex $ShapeDistr $j]
      set Gap [PPDistance $PointEnd $PointStart]
      lappend srcPts [list $PointEnd $Gap 0.9]
    }

    # puts [llength $srcPts]

    $cloud addPoints $srcPts

  }

  set i [expr {$i + 1}]
}

if {$Euler == "OFF" } {
  if {$initialSpacingOriginal != $InitialSpacing} {
    set InitialSpacing [expr {$InitialSpacing/2}]
  }
}
