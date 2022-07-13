# Pointwise V18.4R3 Journal file - Wed Jul 13 19:37:45 2022

package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5
pw::Application reset
pw::Application markUndoLevel {Journal Reset}

pw::Application clearModified

set _TMP(mode_1) [pw::Application begin GridImport]
  $_TMP(mode_1) initialize -strict -type Segment /home/rausa/prova/PointwiseAutoMesh/2D/Test/NoPreProcessing/PointsCoords.dat
  $_TMP(mode_1) read
  $_TMP(mode_1) convert
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Import Grid}

