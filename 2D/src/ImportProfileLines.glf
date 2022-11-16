package require PWI_Glyph 4.18.4



puts "Importing profile lines..."

set i 1
set Databases [list]
set Connectors [list]

foreach AirfoilLine $AirfoilLinesList {

  set importName [lindex $AirfoilLine 0]
  set filename $path$importName

  # puts $filename

  if {$UseFileDistribution} {

    set _TMP(mode_1) [pw::Application begin GridImport]
      $_TMP(mode_1) initialize -strict -type Segment $filename
      $_TMP(mode_1) read
      $_TMP(mode_1) convert
    $_TMP(mode_1) end
    unset _TMP(mode_1)
    pw::Application markUndoLevel {Import Grid}

    set ConName "con-"
    set ConName $ConName$i

    set Connector [pw::GridEntity getByName $ConName]
    set ConName [lindex $AirfoilLine 2]

    set bufferList [list]
    lappend bufferList $ConName
    lappend bufferList $Connector

    lappend Connectors $bufferList

    set i [expr {$i + 1}]

  } else {


    set _TMP(mode_1) [pw::Application begin DatabaseImport]
      $_TMP(mode_1) initialize -strict -type Automatic $filename
      $_TMP(mode_1) read
      $_TMP(mode_1) convert
    $_TMP(mode_1) end
    unset _TMP(mode_1)
    pw::Application markUndoLevel {Import Database}

    set CurveName "curve-"
    set CurveName $CurveName$i

    set Curve [pw::DatabaseEntity getByName $CurveName]
    lappend Databases $Curve

    # Check if it has to be splined or not
    if {[lindex $AirfoilLine 1]} {

      # First extract start and end points
      set StartPoint [$Curve getXYZ -parameter 0.0]
      set EndPoint [$Curve getXYZ -parameter 1.0]

      # puts $StartPoint
      # puts $EndPoint

      set _TMP(mode_1) [pw::Application begin Modify [list $Curve]]
        $Curve spline $Curve
      $_TMP(mode_1) end
      unset _TMP(mode_1)
      pw::Application markUndoLevel Spline

      set StartPointNew [$Curve getXYZ -parameter 0.0]
      set EndPointNew [$Curve getXYZ -parameter 1.0]

      # puts $StartPointNew
      # puts $EndPointNew

      if { $StartPoint != $StartPointNew } {
        puts "Start point has been modified"
        set Segment [pw::SegmentSpline create]
        $Segment addPoint $StartPoint
        $Segment addPoint $StartPointNew
        $Curve insertSegment 1 $Segment
      }

      if { $EndPoint != $EndPointNew } {
        puts "End point has been modified"
        set Segment [pw::SegmentSpline create]
        $Segment addPoint $EndPointNew
        $Segment addPoint $EndPoint
        $Curve addSegment $Segment
      }
    }

    # Create connector
    set _TMP(PW_1) [pw::Connector createOnDatabase -parametricConnectors Aligned -merge 0 -reject _TMP(unused) [list $Curve]]
    unset _TMP(unused)
    unset _TMP(PW_1)
    pw::Application markUndoLevel {Connectors On DB Entities}

    set ConName "con-"
    set ConName $ConName$i

    set Connector [pw::GridEntity getByName $ConName]
    set ConName [lindex $AirfoilLine 2]

    set bufferList [list]
    lappend bufferList $ConName
    lappend bufferList $Connector

    lappend Connectors $bufferList

    set i [expr {$i + 1}]

  }

}

# puts $Connectors


puts "Done!"
