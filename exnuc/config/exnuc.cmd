#include "execcmd.h"
"ex",EXEx,EX_exit
"ret",EXRtFl,EX_retri
^"tog cmd",EXTest,EX_test,,
^"switch products",EXSwitch,COimswitch
^"~ p EXDummy",EXDummy,EX_ver,1
EXC_M_AttFunKey,EXAtFnKyMn,EX_funcky
EXC_M_PrintCmd,EXPrCm,EX_pricmd
EXC_M_EXFileName,EXShFl,EX_file
EXC_M_EXBackup,EXBc,EX_fbackup
EXC_M_EXClrStack,EXClSt,0,0,15
EXC_M_EXClose,EXClFl,EX_close
#if defined(ENV5) || (defined(CLIX) && defined(X11))
EXC_M_EXDelPMenu,EXDtPpMn,EX_dig,1
EXC_M_EXLdPMenu,EXAtPpMn,EX_dig
#endif
EXC_M_EXexit,EXEx,EX_exit
EXC_M_EXHelp,EXHl,0,0,6
^EXC_M_EXOden,EXOden,0,0,10
^EXC_M_EXOdin,EXOdin,0,0,10
^EXC_M_EXOMpms,EXOMpms,0,0,11
^EXC_M_EXOMpms1,EXOMpms1,0,0,11
EXC_M_EXPopCmd,EXPpCm,0,0,5
EXC_M_EXRclKeyin,EXRcKy,EX_rclkeyin
EXC_M_EXRetrFile,EXRtFl,EX_retri
EXC_M_EXSave,EXSvFl,EX_save
EXC_M_EXSaveAs,EXSvFlNwNm,EX_saveas
EXC_M_EXSetBTime,EXSBcTm,EX_bckup
EXC_M_EXVer,EXShVr,EX_ver
EXC_M_EXDefInGen,EXDfInGn,EX_defbut
EXC_M_AtPnMn,EXAtPnMn,EX_swapmenu,1
EXC_M_AtPcMn,EXAtPcMn,EX_swapmenu,2
EXC_M_AtBrMn,EXAtBrMn,EX_swapmenu,3
