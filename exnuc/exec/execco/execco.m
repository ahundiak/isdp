SRC
$(EXNUC)/exec/execco

SOURCE
EX_bckupi.I
EX_veri.I
EX_filei.I
EX_funckyi.I
EX_digi.I
EX_defbuti.I 
EX_testi.I
EX_pricmdi.I
EX_saveasi.I
EX_fbackupi.I
EX_retrii.I
EX_savei.I
EX_exiti.I
EX_closei.I
EX_swapmenui.I
EX_menuchki.I
EX_rclkeyini.I

SPEC
$(EXNUC)/spec

INCLUDE
$(EXNUC)/include
$(UMS_INC_PATH)
$(LIBXC_INC_PATH)
#if defined (ENV5)
$(FORMS_INC_PATH)
#elif defined (X11)
$(XFORMSDP_INC_PATH)
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

