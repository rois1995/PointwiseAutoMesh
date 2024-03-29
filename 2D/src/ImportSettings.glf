package require PWI_Glyph 4.18.4


set filename "settingsPointwise.cfg"
set filename $path$filename

# Read settings from file
set fp [open $filename r]
set file_data [read $fp]
close $fp


puts "----------------------------------------------------------------"

puts "SETTINGS:"
puts " "

set data [split $file_data "\n"]
foreach line $data {
     set words [split $line " "]

     # puts $line

     # Profile parameters
     if {[lindex $words 0]=="Chord="} {
      set Chord [lindex $words 1]
     }


     # Input variables
     if {[lindex $words 0]=="File2Import="} {
       set AirfoilLines [extractVectorSettings $words]
       # puts $AirfoilLines
     } elseif {[lindex $words 0]=="Is2Spline="} {
       set Is2Spline [extractVectorSettings $words]
       # puts $Is2Spline
     } elseif {[lindex $words 0]=="AirfoilOrientation="} {
       set AirfoilOrientation [lindex $words 1]
       # puts $AirfoilOrientation
     }

     if {[lindex $words 0]=="File2Import="} {
       set AirfoilLines [extractVectorSettings $words]
       # puts $AirfoilLines
     }

     # Profile parameters
     if {[lindex $words 0]=="UseFileDistribution="} {
      set UseFileDistribution [lindex $words 1]
     }



     # Trailing edge definitions
     if {[lindex $words 0]=="LinesConn2TE="} {
      set LinesConn2TE [extractVectorSettings $words]
     }


     # Boundary layer parameters
     if {[lindex $words 0]=="Euler="} {
      set Euler [lindex $words 1]
     }


     # Spacings definitions
     if {[lindex $words 0]=="SpacingsFun="} {
       set AirfoilSpacingsFun [extractVectorSettings $words]
       # puts $AirfoilSpacingsFun
     } elseif {[lindex $words 0]=="GrowthRates="} {
       set AirfoilGrowthRates [extractVectorSettings $words]
       # puts $AirfoilGrowthRates
     }


     # Save options

     if {[lindex $words 0]=="OneBoundaryTag="} {
      set OneBoundaryTag [lindex $words 1]
     }


     if {[lindex $words 0]=="MeshFormat="} {
      set MeshFormat [lindex $words 1]
     } elseif {[lindex $words 0]=="MeshName="} {
      set MeshName [lindex $words 1]
     } elseif {[lindex $words 0]=="SavePointwiseFile="} {
      set SavePointwiseFile [lindex $words 1]
     } elseif {[lindex $words 0]=="NCellFile="} {
      set NCellFile [lindex $words 1]
     }



}


if {$Euler == "OFF"} {
  foreach line $data {
       set words [split $line " "]

       if {[lindex $words 0]=="InitialSpacing="} {
        set InitialSpacing [lindex $words 1]
       } elseif {[lindex $words 0]=="GrowthRateBL="} {
        set GrowthRateBL [lindex $words 1]
       } elseif {[lindex $words 0]=="MeshStrategy="} {
        set MeshStrategy [lindex $words 1]
       }
  }

}

if {$Euler == "ON"} {
  set MeshStrategy "Unstructured"
}


if {$MeshStrategy == "Unstructured"} {

  foreach line $data {
    set words [split $line " "]
    if {[lindex $words 0]== "FarfieldShape=" } {
      set FarfieldShape [lindex $words 1]
    }
  }

  # If Circle or Square farfield, then I need the farfield spacing and the farfield distance

  if { $FarfieldShape == "Circle" || $FarfieldShape == "Square" } {
    foreach line $data {
      set words [split $line " "]
      # Farfield parameters
      if {[lindex $words 0]=="FarfieldDistance="} {
       set FarfieldDistance [lindex $words 1]
      } elseif {[lindex $words 0]=="FarfieldSpacing="} {
       set FarfieldSpacing [lindex $words 1]
      }
    }
  }

  # If Gallery farfield, then I need the farfield spacing and the extrema of the gallery
  if { $FarfieldShape == "Gallery" } {
    foreach line $data {
      set words [split $line " "]
      # Farfield parameters
      if {[lindex $words 0]=="GalleryExtrema="} {
       set GalleryExtrema [extractVectorSettings $words]
      } elseif {[lindex $words 0]=="FarfieldSpacing="} {
       set FarfieldSpacing [lindex $words 1]
      } elseif {[lindex $words 0]=="FarfieldBC="} {
       set FarfieldBC [lindex $words 1]
      }
    }

    if { $FarfieldBC == "NS" } {
      foreach line $data {
        set words [split $line " "]
        # Farfield parameters
        if {[lindex $words 0]=="FarfieldInitialSpacing="} {
         set FarfieldInitialSpacing [lindex $words 1]
        }
      }
    }

  }


  pw::DomainUnstructured setInitializeInterior 0

  if {$Euler == "OFF"} {
    foreach line $data {
         set words [split $line " "]


         # T-Rex Boundary Layer extrusion parameters
         if {[lindex $words 0]=="NFullLayers="} {
          set NFullLayers [lindex $words 1]
         } elseif {[lindex $words 0]=="NMaxLayers="} {
          set NMaxLayers [lindex $words 1]
         } elseif {[lindex $words 0]=="CellTypeBL="} {
          set CellTypeBL [lindex $words 1]
         }
     }
   }

  foreach line $data {
       set words [split $line " "]


       # T-Rex Boundary Layer extrusion parameters
       if {[lindex $words 0]=="NFullLayers="} {
        set NFullLayers [lindex $words 1]
       } elseif {[lindex $words 0]=="NMaxLayers="} {
        set NMaxLayers [lindex $words 1]
       } elseif {[lindex $words 0]=="CellTypeBL="} {
        set CellTypeBL [lindex $words 1]
       }

       # Surface mesh parameters
       if {[lindex $words 0]=="BoundaryDecay="} {
        set BoundaryDecay [lindex $words 1]
       } elseif {[lindex $words 0]=="AlgorithmSurface="} {
        set AlgorithmSurface [lindex $words 1]
       } elseif {[lindex $words 0]=="CellType="} {
        set CellType [lindex $words 1]
       }

       # Trailing Edge refinement parameters
       if {[lindex $words 0]=="TERefinement="} {
        set TERefinement [lindex $words 1]
       }

  }

  if {$TERefinement == "ON"} {
    foreach line $data {
         set words [split $line " "]

        if {[lindex $words 0]=="RefinementLength="} {
          set RefinementLength [lindex $words 1]
        } elseif {[lindex $words 0]=="RadiusFar="} {
          set RadiusFar [lindex $words 1]
        } elseif {[lindex $words 0]=="TESpacingMult="} {
          set TESpacingMult [lindex $words 1]
        } elseif {[lindex $words 0]=="BDRefTE="} {
          set BDRefTE [lindex $words 1]
        } elseif {[lindex $words 0]=="BDRefFar="} {
          set BDRefFar [lindex $words 1]
        }

    }
  }
}

if {$MeshStrategy == "Structured"} {

  foreach line $data {
    set words [split $line " "]
    if {[lindex $words 0]=="FarfieldDistance="} {
     set FarfieldDistance [lindex $words 1]
    }
  }

}

if {$SavePointwiseFile == "ON"} {
  foreach line $data {
       set words [split $line " "]

       if {[lindex $words 0]=="PointwiseName="} {
        set PointwiseName [lindex $words 1]
      }

  }
}

if {$OneBoundaryTag == "true"} {
  foreach line $data {
       set words [split $line " "]

       if {[lindex $words 0]=="OneBoundaryTagName="} {
        set OneBoundaryTagName [lindex $words 1]
      }

  }
}


switch $MeshFormat {

  CGNS {
    foreach line $data {
         set words [split $line " "]

         if {[lindex $words 0]=="UnstrInterface="} {
          set UnstrInterface [lindex $words 1]
        } elseif {[lindex $words 0]=="ExpDonorInformation="} {
          set ExpDonorInformation [lindex $words 1]
        } elseif {[lindex $words 0]=="ExpParentElements="} {
          set ExpParentElements [lindex $words 1]
        }

    }
  }
  default {

  }
}




# Create list of lines spacings each one with the name of the line, the distribution
# and the spacings / number of points assigned


set AirfoilLinesList [list]
set NLines [llength $AirfoilLines]

set ValuesIterSpacings 0
set ValuesIterGrowthRates 0

for {set i 0} {$i < $NLines} {incr i} {

  set fileName [lindex $AirfoilLines $i]
  set is2BeSplined [lindex $Is2Spline $i]
  set lineName [string trimright [lindex $AirfoilLines $i] ".dat"]

  if {!$UseFileDistribution} {
    set SpacFun [lindex $AirfoilSpacingsFun $i]


    set SpacingValue [list]
    set SpacingType [list]
    set GrowthRates [list]

    set line2Find "Spacings_"
    set line2Find $line2Find$lineName
    set ToAdd "="
    set line2Find $line2Find$ToAdd

    set data [split $file_data "\n"]
    foreach line $data {
         set words [split $line " "]

         if {[lindex $words 0]==$line2Find} {
           set Spacings [extractVectorSettings $words]
         }

    }

    if {$SpacFun == "Growth"} {
      set NValuesGrowthRates 2

      set SpacingTypeBegin [lindex $Spacings 0]
      set SpacingTypeMid [lindex $Spacings 2]
      set SpacingTypeEnd [lindex $Spacings 4]
      lappend SpacingType $SpacingTypeBegin
      lappend SpacingType $SpacingTypeMid
      lappend SpacingType $SpacingTypeEnd
      # set SpacingType {$SpacingTypeBegin $SpacingTypeEnd}

      set SpacingBegin [expr {[lindex $Spacings 1] * $Chord }]
      set SpacingMid [expr {[lindex $Spacings 3] * $Chord }]
      set SpacingEnd [expr {[lindex $Spacings 5] * $Chord }]
      lappend SpacingValue $SpacingBegin
      lappend SpacingValue $SpacingMid
      lappend SpacingValue $SpacingEnd
      # set Spacing {$SpacingBegin $SpacingEnd}


      set GrBegin [lindex $AirfoilGrowthRates $ValuesIterGrowthRates]
      set GrEnd [lindex $AirfoilGrowthRates [expr {$ValuesIterGrowthRates+1}]]
      lappend GrowthRates $GrBegin
      lappend GrowthRates $GrEnd

    } elseif {$SpacFun == "Tanh"} {

      set NValuesGrowthRates 1

      set SpacingTypeBegin [lindex $Spacings 0]
      set SpacingTypeMid [lindex $Spacings 2]
      set SpacingTypeEnd [lindex $Spacings 4]
      lappend SpacingType $SpacingTypeBegin
      lappend SpacingType $SpacingTypeMid
      lappend SpacingType $SpacingTypeEnd
      # set SpacingType {$SpacingTypeBegin $SpacingTypeEnd}

      set SpacingBegin [expr {[lindex $Spacings 1] * $Chord }]
      set SpacingMid [expr {[lindex $Spacings 3] * $Chord }]
      set SpacingEnd [expr {[lindex $Spacings 5] * $Chord }]
      lappend SpacingValue $SpacingBegin
      lappend SpacingValue $SpacingMid
      lappend SpacingValue $SpacingEnd
      # set Spacing {$SpacingBegin $SpacingEnd}


      set GrBegin [lindex $AirfoilGrowthRates $ValuesIterGrowthRates]
      lappend GrowthRates $GrBegin

    } elseif {$SpacFun == "Uniform"} {

      set NValuesGrowthRates 1

      lappend SpacingType [lindex $Spacings $ValuesIterSpacings]
      set DummySpacing [lindex $Spacings [expr {$ValuesIterSpacings+1}]]
      if {[lindex $Spacings $ValuesIterSpacings] == "MeanSpace"} {
        set DummySpacing [expr {$DummySpacing * $Chord}]
      }
      lappend SpacingValue $DummySpacing

      set GrBegin 0
      lappend GrowthRates 0

    } elseif {$SpacFun == "Shape"} {

      set NValuesGrowthRates 2

      set SpacingTypeAngle [lindex $Spacings 0]
      set SpacingTypemaxSpacing [lindex $Spacings 2]
      set SpacingTypeMaxGR [lindex $Spacings 4]
      set SpacingTypeRefLevels [lindex $Spacings 6]
      lappend SpacingType $SpacingTypeAngle
      lappend SpacingType $SpacingTypemaxSpacing
      lappend SpacingType $SpacingTypeMaxGR
      lappend SpacingType $SpacingTypeRefLevels
      # set SpacingType {$SpacingTypeBegin $SpacingTypeEnd}

      set Angle [lindex $Spacings 1]
      set maxSpacing [expr {[lindex $Spacings 3] * $Chord }]
      set SpacingTypeMaxGR [lindex $Spacings 5]
      set SpacingTypeRefLevels [lindex $Spacings 7]
      lappend SpacingValue $Angle
      lappend SpacingValue $maxSpacing
      lappend SpacingValue $SpacingTypeMaxGR
      lappend SpacingValue $SpacingTypeRefLevels
      # set Spacing {$SpacingBegin $SpacingEnd}

      set GrBegin [lindex $AirfoilGrowthRates $ValuesIterGrowthRates]
      set GrEnd [lindex $AirfoilGrowthRates [expr {$ValuesIterGrowthRates+1}]]
      lappend GrowthRates $GrBegin
      lappend GrowthRates $GrEnd


    } else {

      # Default is Growth function. However, I do not think that it will work
      set SpacFun "Growth"

      set NValuesGrowthRates 2

      set SpacingTypeBegin [lindex $Spacings 0]
      set SpacingTypeMid [lindex $Spacings 2]
      set SpacingTypeEnd [lindex $Spacings 4]
      lappend SpacingType $SpacingTypeBegin
      lappend SpacingType $SpacingTypeMid
      lappend SpacingType $SpacingTypeEnd
      # set SpacingType {$SpacingTypeBegin $SpacingTypeEnd}

      set SpacingBegin [expr {[lindex $Spacings 1] * $Chord }]
      set SpacingMid [expr {[lindex $Spacings 3] * $Chord }]
      set SpacingEnd [expr {[lindex $Spacings 5] * $Chord }]
      lappend SpacingValue $SpacingBegin
      lappend SpacingValue $SpacingMid
      lappend SpacingValue $SpacingEnd
      # set Spacing {$SpacingBegin $SpacingEnd}

      set GrBegin [lindex $AirfoilGrowthRates $ValuesIterGrowthRates]
      set GrEnd [lindex $AirfoilGrowthRates [expr {$ValuesIterGrowthRates+1}]]
      lappend GrowthRates $GrBegin
      lappend GrowthRates $GrEnd

    }

    set ValuesIterGrowthRates [expr {$ValuesIterGrowthRates + $NValuesGrowthRates}]
  }



  set bufferList [list]
  lappend bufferList $fileName
  lappend bufferList $is2BeSplined
  lappend bufferList $lineName
  if {$UseFileDistribution} {
    lappend bufferList 0
    lappend bufferList 0
    lappend bufferList 0
    lappend bufferList 0
  } else {
    lappend bufferList $SpacFun
    lappend bufferList $SpacingType
    lappend bufferList $SpacingValue
    lappend bufferList $GrowthRates
  }

  lappend AirfoilLinesList $bufferList

}

# puts $AirfoilLinesList
