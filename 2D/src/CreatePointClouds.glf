package require PWI_Glyph 4.18.4


if {!$UseFileDistribution} {

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

      $cloud addPoints $srcPts

      pw::Connector setDimensionFromSizeField -include $cloud -refineOnly $Con
      
      
      # Now try to smooth the distribution
      


      set SpaceValues [lindex $AirfoilLine 5]
      set maxSpacing [lindex $SpaceValues 1]


      set MaxGR [lindex $SpaceValues 2]


      set RefinementPasses [lindex $SpaceValues 3]

      set Continue 1
      set iRef 1

      while { $Continue } {

        
        $cloud delete

        set cloud [pw::SourcePointCloud create]
        set name "New_Refinement_"
        set name $name$Name
        $cloud setName $name

        set ShapeDistr [extractDistr $Con]

        set srcPts [list]

        set NPoints [llength $ShapeDistr]

        set ToWrite "Refinement level: "
        set ToWrite $ToWrite$iRef
        puts $ToWrite

        set ToWrite "NPoints Before: "
        set ToWrite $ToWrite$NPoints
        puts $ToWrite

        for {set j 2} { $j < [expr {$NPoints-1}]} {incr j} {

          set PointStart [lindex $ShapeDistr [expr {$j-2}]]
          set PointStartSeg [lindex $ShapeDistr [expr {$j-1}]]
          set PointEndSeg [lindex $ShapeDistr $j]
          set PointEnd [lindex $ShapeDistr [expr {$j+1}]]
          set Gap [PPDistance $PointEndSeg $PointStartSeg]
          set GapBefore [PPDistance $PointStart $PointStartSeg]
          set GapAfter [PPDistance $PointEnd $PointEndSeg]

          set MaxGap [expr {$Gap * $MaxGR}]
          if {$MaxGap > $maxSpacing} {
            set MaxGap $maxSpacing
          }

          if { $GapBefore > $MaxGap } {
            lappend srcPts [list $PointStartSeg $MaxGap 0.9]
          }
          if { $GapAfter > $MaxGap } {
            lappend srcPts [list $PointEndSeg $MaxGap 0.9]
          }
          
        }

        $cloud addPoints $srcPts

        pw::Connector setDimensionFromSizeField -include $cloud -refineOnly $Con


        set ShapeDistr [extractDistr $Con]
        set NPointsAfter [llength $ShapeDistr]

        set ToWrite "NPoints After: "
        set ToWrite $ToWrite$NPointsAfter
        puts $ToWrite

        puts " "

        set iRef [expr {$iRef + 1}]
        if { $iRef > $RefinementPasses || $NPoints == $NPointsAfter } {
          set Continue 0
        }
      }

    }

    set i [expr {$i + 1}]
  }

  if {$Euler == "OFF" } {
    if {$initialSpacingOriginal != $InitialSpacing} {
      set InitialSpacing [expr {$InitialSpacing/2}]
    }
  }

}
