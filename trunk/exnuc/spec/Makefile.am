include $(top_srcdir)/build/makerules

# SUFFIXES = .I .S

# .S.c .I.c:
#	$(IG_OPP) $(IG_OPP_FLAGS) $(IG_OPP_INCLUDES) $(IG_OPP_DEFINES) $<

noinst_LTLIBRARIES  = libspec.la

libspec_la_SOURCES  = \
 DIbst.S \
 DIbstgr.S \
 DIbstob.S \
 DIbtree.S \
 DIlink.S \
 DImaster.S \
 DIrectory.S \
 DIroot.S \
 DIstorage.S \
 EX_bckup.S \
 EX_close.S \
 EX_defbut.S \
 EX_exit.S \
 EX_fbackup.S \
 EX_file.S \
 EX_funcky.S \
 EX_menuchk.S \
 EX_pricmd.S \
 EX_rclkeyin.S \
 EX_retri.S \
 EX_save.S \
 EX_saveas.S \
 EX_swapmenu.S \
 EX_test.S \
 EX_ver.S \
 GRoup.S \
 GRoups.S \
 IGRdir.S \
 OMGroup.S \
 OMbtree.S \
 OMlnkbtree.S \
 IGEgadget.S \
 IGEingen.S \
 IGEinlisnr.S \
 IGEwindow.S \
 IGEwsys.S \
 OMCluster.S \
 OMFiledOS.S \
 OMMOSD.S \
 OMObjSpace.S \
 OMSupGroup.S \
 OMTransOS.S \
 OMrtree.S \
 OMindex.S \
 Root.S \
 cmdserver.S \
 global_class.S \
 IGEcolsup.S \
 super_cmd.S \
 APPcolor2.S \
 IGEuserramp.S \
 module.S \
 exec.S \
 IGEcolor2.S \
 IGEcolor.S \
 APPcolor.S \
 CEO.S

libspec_la_CFLAGS   = $(gio_DEPS_CFLAGS)

CLEANFILES = Root.c