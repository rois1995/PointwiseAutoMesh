package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5


set MeshQualityFile [open $NCellFile w]


set ToPrint "Number of cells is: "
set Metric [$ActualMesh getCellCount]
set ToPrint $ToPrint$Metric
puts $ToPrint

puts $MeshQualityFile $ToPrint


set ToPrint "Number of points is: "
set Metric [$ActualMesh getPointCount]
set ToPrint $ToPrint$Metric
puts $ToPrint

puts $MeshQualityFile $ToPrint



puts $MeshQualityFile " "
puts " "



set _TMP(exam_1) [pw::Examine create DomainCellType]
$_TMP(exam_1) addEntity [list $ActualMesh]
$_TMP(exam_1) examine
set TypeOfCells [$_TMP(exam_1) getCategories]

foreach Cell $TypeOfCells {
  set ToPrint "Number of "
  set ToPrint $ToPrint$Cell
  set buffer " is: "
  set ToPrint $ToPrint$buffer
  set Metric [$_TMP(exam_1) getCategoryCount $Cell]
  set ToPrint $ToPrint$Metric
  puts $ToPrint
  puts $MeshQualityFile $ToPrint
}

$_TMP(exam_1) delete
unset _TMP(exam_1)



puts $MeshQualityFile " "
puts " "




set _TMP(exam_1) [pw::Examine create DomainArea]
  $_TMP(exam_1) addEntity [list $ActualMesh]
  $_TMP(exam_1) examine

  set ToPrint "Max Area is: "
  set Metric [$_TMP(exam_1) getMaximum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


  set ToPrint "Min Area is: "
  set Metric [$_TMP(exam_1) getMinimum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


$_TMP(exam_1) delete
unset _TMP(exam_1)



puts $MeshQualityFile " "
puts " "




set _TMP(exam_1) [pw::Examine create DomainAreaRatio]
  $_TMP(exam_1) addEntity [list $ActualMesh]
  $_TMP(exam_1) examine

  set ToPrint "Max Area ratio is: "
  set Metric [$_TMP(exam_1) getMaximum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


  set ToPrint "Min Area ratio is: "
  set Metric [$_TMP(exam_1) getMinimum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


$_TMP(exam_1) delete
unset _TMP(exam_1)




puts $MeshQualityFile " "
puts " "




set _TMP(exam_1) [pw::Examine create DomainAspectRatio]
  $_TMP(exam_1) addEntity [list $ActualMesh]
  $_TMP(exam_1) examine

  set ToPrint "Max Aspect ratio is: "
  set Metric [$_TMP(exam_1) getMaximum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


  set ToPrint "Min Aspect ratio is: "
  set Metric [$_TMP(exam_1) getMinimum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


$_TMP(exam_1) delete
unset _TMP(exam_1)



puts $MeshQualityFile " "
puts " "



set _TMP(exam_1) [pw::Examine create DomainMinimumAngle]
  $_TMP(exam_1) addEntity [list $ActualMesh]
  $_TMP(exam_1) examine

  set ToPrint "Max Minimum Angle is: "
  set Metric [$_TMP(exam_1) getMaximum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


  set ToPrint "Min Minimum Angle is: "
  set Metric [$_TMP(exam_1) getMinimum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


$_TMP(exam_1) delete
unset _TMP(exam_1)



puts $MeshQualityFile " "
puts " "



set _TMP(exam_1) [pw::Examine create DomainMaximumAngle]
  $_TMP(exam_1) addEntity [list $ActualMesh]
  $_TMP(exam_1) examine

  set ToPrint "Max Maximum Angle is: "
  set Metric [$_TMP(exam_1) getMaximum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


  set ToPrint "Min Maximum Angle is: "
  set Metric [$_TMP(exam_1) getMinimum]
  set ToPrint $ToPrint$Metric
  puts $ToPrint

  puts $MeshQualityFile $ToPrint


$_TMP(exam_1) delete
unset _TMP(exam_1)




close $MeshQualityFile
