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
      set _TMP(mode_1) [pw::Application begin Modify [list $Curve]]
        $Curve spline
      $_TMP(mode_1) end
      unset _TMP(mode_1)
      pw::Application markUndoLevel Spline
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
