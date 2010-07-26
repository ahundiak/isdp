COPT
#ifdef NT

#ifdef _DEBUG
-W3 -Zp8 -Gd -nologo -Od -Zi -MTd
#else /* _DEBUG */
-W3 -Zp8 -Gd -nologo -O2
#endif /* _DEBUG */

#else /* NT */
-DBASE_EMS
#endif /* NT */

SRC
$(EXNUC)/spec

SOURCE
DIbst.S
DIbstgr.S
DIbstob.S
DIbtree.S
DIlink.S
DImaster.S
DIrectory.S
DIroot.S
DIstorage.S
EX_bckup.S
EX_close.S
EX_defbut.S
#if defined(ENV5) || (defined(CLIX) && defined(X11))
EX_dig.S
IGEabsdig.S
IGEdigwin.S
#endif
EX_exit.S
EX_fbackup.S
EX_file.S
EX_funcky.S
EX_menuchk.S
EX_pricmd.S
EX_rclkeyin.S
EX_retri.S
EX_save.S
EX_saveas.S
EX_swapmenu.S
EX_test.S
EX_ver.S
GRoup.S
GRoups.S
IGRdir.S
OMGroup.S
OMbtree.S
OMlnkbtree.S
IGEgadget.S
IGEingen.S
IGEinlisnr.S
IGEwindow.S
IGEwsys.S
OMCluster.S
OMFiledOS.S
OMMOSD.S
OMObjSpace.S
OMSupGroup.S
OMTransOS.S
OMrtree.S
OMindex.S
Root.S
cmdserver.S
global_class.S
IGEcolsup.S
super_cmd.S
APPcolor2.S
IGEuserramp.S
module.S
#ifndef NT
exec.S
IGEcolor2.S
IGEcolor.S
APPcolor.S
CEO.S
#endif
#if defined(UNIX)
LIB
$(TARGET)/spec/exnucspec.o
#elif defined(NT)
ARCHIVE
$(TARGET)\spec\exnucspec.lib
#endif

INCLUDE
$(EXNUC)/include
$(UMS_INC_PATH)
#if defined(X11)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

