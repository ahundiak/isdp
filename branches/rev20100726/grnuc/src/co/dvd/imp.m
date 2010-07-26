SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
#ifdef X11
#ifndef IRIX
$(GRNUC)/unix_include/$(CPUTYPE)
#endif
$(XINC)
#endif
$(INGRHOME)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

LIB
$(GRLIB)/lib/dpvd.o

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/co/dvd

SOURCE
DPvdi.I
DPvd_mvi.I
DPvd_rvi.I
DPvd_actwin.I
DPvd_event.I
DPvd_form.I
DPvd_gnomen.I
DPvd_mark.I
DPvd_rdwni.I
DPvd_select.I
DPvd_tdli.I
DPvd_transf.I
DPdsp_toli.I

CC 
acc -knr -o3

