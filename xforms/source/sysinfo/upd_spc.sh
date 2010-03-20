
PROJ_ELE=examples/demo
ELE_LIST="EGdemo_p_all.h EGdemo_p_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=examples/dynamic
ELE_LIST="EGdyn_p_all.h EGdyn_p_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=examples/navigation
ELE_LIST="EGnav_p_all.h EGnav_p_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=examples/wall
ELE_LIST="EGwall_p_all.h EGwall_p_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=util/get_text
ELE_LIST="XFUproto_all.h XFUproto_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=util/menus
ELE_LIST="GMproto_all.h GMproto_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=util/set_text
ELE_LIST="XFUproto_all.h XFUproto_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=xfb/config/english/messages/src
ELE_LIST="src.m"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=xfb/include
ELE_LIST="FB.h XFBproto_all.h XFBproto_pri.h"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=xfb/src
ELE_LIST="chkproto.sh pri_ftr pri_hdr init_arch.c xfi.sl_clipper xfi.sl_mips"
set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=xfi/test
ELE_LIST=".dbg_init"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x

PROJ_ELE=xfi/testms
ELE_LIST="BAR_MENU makefile xPreviewMenu.c"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=xmb/config/english/messages/src
ELE_LIST="src.m"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=xmb/include
ELE_LIST="XMBproto_all.h XMBproto_pri.h"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


PROJ_ELE=xmb/src
ELE_LIST="chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x


exit

PROJ_ELE=examples/dec
ELE_LIST="EGdec_p_all.h EGdec_p_pri.h chkproto.sh pri_ftr pri_hdr"

set -x
cd $SYSSRC/$PROJ_ELE
pwd
#spc cre proj ele -comm "dmb:Adding new ANSI pieces" $PROJ_ELE
spc set lib $PROJ_ELE
spc cre ele -comm "dmb:Adding new ANSI pieces" $ELE_LIST
set +x

exit
