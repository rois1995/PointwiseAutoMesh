# Pointwise V18.4R3 Journal file - Fri Nov 19 17:15:18 2021

package require PWI_Glyph 4.18.4

pw::Application setUndoMaximumLevels 5

set _CN(1) [pw::GridEntity getByName con-2]
set _CN(2) [pw::GridEntity getByName con-3]
set _CN(3) [pw::GridEntity getByName con-1]
set _TMP(PW_1) [pw::Connector join -reject _TMP(ignored) -keepDistribution [list $_CN(1) $_CN(2) $_CN(3)]]
unset _TMP(ignored)
unset _TMP(PW_1)
pw::Application markUndoLevel Join

set _CN(4) [pw::GridEntity getByName con-1]
set _TMP(mode_1) [pw::Application begin Modify [list $_CN(4)]]
  $_CN(4) removeAllBreakPoints
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel Distribute

