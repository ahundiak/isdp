SOURCE
#if ISDP_MAKE_SP
VSdrwbmvwtyp.I
VSdrwisbmhid.I
VSdrwutil.I
#else
EMpjProject.I
VSdirgooutcv.C
VSdrwarymgmt.C
VSdrwatt2ext.C
VSdrwcncprop.C
VSdrwcstsmbl.C
VSdrwcvrtval.C
VSdrwextrflg.C
VSdrwfmtnumb.C
VSdrwfcncall.C
VSdrwfcnqydb.C
VSdrwfcnsofa.C
VSdrwfcnstrg.C
VSdrwfprintf.C
VSdrwgarbage.C
VSdrwgrammar.C
VSdrwinfiles.C
VSdrwintptcv.C
VSdrwkwtable.C
VSdrwlexicon.C
VSdrwlexinpt.C
VSdrwoutdata.C
VSdrwsymsupp.C
VSdrwtxtsupp.C
VSdrwpplsupp.C
VSdrwupddbas.C
VSdrwverbose.C
VSdrwvrtable.C
VSxycurvedir.C
VSxycurvebox.C
VSxycvsetdir.C
VSdrwanchorc.I
VSdrwanchorp.I
VSdrwbmorien.I
VSdrwbmvwtyp.I
VSdrwcnsttyp.I
VSdrwcstbmax.I
VSdrwcstbmpf.I
VSdrwcstptpj.I
VSdrwcstmemb.I
VSdrwcvhid.I
VSdrwelmclpd.I
VSdrwexeccfg.I
VSdrwfcnsupp.I
VSdrwfntsupp.I
VSdrwgroutpt.I
VSdrwisbmhid.I
VSdrwismkhid.I
VSdrwisoftyp.I
VSdrwisplhid.I
VSdrwjnvwtyp.I
VSdrwjoint.I
VSdrwmcvwtyp.I
VSdrwparapls.I
VSdrwplatdir.I
VSdrwplbotsd.I
VSdrwplvwint.I
VSdrwplvwtyp.I
VSdrwprfldir.I
VSdrwsurface.I
VSdrwsolid.I
VSdrwutil.I
VSdrwobj2wfr.I
VSdrwbmaxisfc.I
/*
 * Dynamic-load overrides.
 */
ACndrawing.I
VDSdrwxtinfo.C
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXS)/include
$(SPXS)/include/prototypes
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(MODEL)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude
$(STRUCT)/include
$(STRUCT)/include/prototypes

OMCPP
$(EXNUC)/bin/omcpp

OPP
$(EXNUC)/bin/opp

LIB
#if ISDP_MAKE_SP
$(SPXS)/lib/vsdrawing.o
#else
$(STRUCT)/lib/vsdrawing.o
#endif

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__ _INGR_EXTENSIONS

CC
acc -ansi -O3
