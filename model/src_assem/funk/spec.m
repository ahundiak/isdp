SRC
$(MODEL)/src_assem/funk
OPP
$(EXTARG)/bin/opp
OMCPP
$(EXTARG)/bin/omcpp
INCLUDE
$(INGRHOME)/include
$(XINC)
#ifdef XGL
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
$(GRNUC)/ingrsys
$(MODEL)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/src/assoc/include_priv
$(BS)/include
$(BS)/include/prototypes
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
SPEC
$(EXNUC)/spec
$(OM)/spec
$(GRNUC)/spec
$(MODEL)/spec
LIB
$(MDTARG)/src_lib/EMSassemF.o
SOURCE
EMascii.C
EMasmtools.I
EMassemmath.C
EMattrfunk.I
EMbomfunk.I
EMchkcycle.I
EMcnstrfunk.I
EMconstr.I
EMconstrdbg.I
EMconstype.I
EMconvlprt.I
EMdelete.I
EMdescfunk.I
EMdispfunk.I
EMfindlevel.I
EMgetbasis.I
EMgetrelang.I
EMgetucons.I
EMhilitefunk.I
EMinstfunk.I
EMlayerfunk.I
EMmakepath.I
EMmisc.I
EMpassfunk.I
EMplistfunk.I
EMprintbasis.I
EMprtfilefrm.C
EMprtfunk.I
EMpuldwnlst.C
EMrectify.I
EMresetpath.I
EMrevasmfunk.I
EMrevasmipc.C
EMrevasmutil.I
EMrevpath.I
EMtblfunk.I
EMtranssymb.I
EMtreefunk.I
EMunmarkcons.I
EMupdrfdep.I
asmytool.I
