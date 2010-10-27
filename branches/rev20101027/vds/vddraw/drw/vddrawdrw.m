SOURCE
#if ISDP_MAKE_SP
VDdrwexeccfg.I
VDdrwunits.I
VDdrwtransp.I
VDdrwfdrefsf.I
#else
/* EMpjProject.I */
VDdrwarymgmt.C
VDdrwatt2ext.C
VDdrwcncprop.C
VDdrwcstsmbl.C
VDdrwcvrtval.C
VDdrwextrflg.C
VDdrwfmtnumb.C
VDdrwfcncall.C
VDdrwfcnqydb.C
VDdrwfcnsofa.C
VDdrwfcnstrg.C
VDdrwfprintf.C
VDdrwgarbage.C
VDdrwgramfcn.C
VDdrwgrammar.C
VDdrwinfiles.C
VDdrwintptcv.C
VDdrwkwtable.C
VDdrwlexicon.C
VDdrwlexinpt.C
VDdrwoutdata.C
VDdrwrngrngr.C
VDdrwsymsupp.C
VDdrwtxtsupp.C
VDdrwupddbas.C
VDdrwverbose.C
VDdrwvrtable.C
VDxycurvedir.C
VDxycurvebox.C
VDxycvsetdir.C

VDdrwanchorc.I
VDdrwanchorp.I
VDdrwcstCtLn.I		/* Construction of Centerlines */
VDdrwcstattr.I		/* Attribute Driven Symbology */
VDdrwcstedgV.I		/* Edges type process for visualization */
VDdrwcstedgE.I		/* Enveloppe Edges process for visualization */
VDdrwcstedgM.I		/* Member Edges process for visualization */
VDdrwcnsttyp.I
VDdrwcstsect.I		/* Volume Cuts graphic output function 	*/
VDdrwelembuf.I		/* Internal buffer management.		*/
VDdrwelmclpd.I
VDdrwexecatt.I		/* Parser caller for attribute driven symbology	*/
VDdrwexeccfg.I		/* Parser caller for visualization process.	*/
VDdrwexecsct.I		/* Parser caller for volume cuts process	*/
VDdrwfcnsupp.I
VDdrwfdhdedg.I
VDdrwfdrefsf.I		/* Find reference surfaces from set list	*/
VDdrwfdsetob.I		/* Find object from a set-list			*/
VDdrwfntsupp.I
VDdrwgroutpt.I
VDdrwisobjhd.I
VDdrwisoftVR.I
VDdrwisoftVS.I
VDdrwisoftVL.I
VDdrwisoftyp.I
VDdrwname.I
VDdrwmcvwtyp.I
VDdrwrmfmlst.I
VDdrwtransp.I
VDdrwutil.I
VDdrwPplFk.I
VDdrwunits.I

/*
 * Dynamic-load overrides.
 */
VDSdrwxtinfo.C
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
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

OMCPP
$(EXNUC)/bin/omcpp

OPP
$(EXNUC)/bin/opp

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdidrawdrw.o
#else
$(VDS)/lib/vdidrawdrw.o
#endif

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__ _INGR_EXTENSIONS

CC
acc -ansi -O3
