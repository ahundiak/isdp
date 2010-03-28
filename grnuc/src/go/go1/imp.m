CC
acc -knr

SOURCE

GRbc2ptpartd.I
GRbc3ptpartd.I
GRbcarclengt.I
GRbcarea.I
GRbccentcurv.I
GRbcclip.I
GRbcconstruc.I
GRbccpparall.I
GRbcdetplane.I
GRbcdisexten.I
GRbcdisyours.I
GRbcendpts.I
GRbcgetatt.I
GRbcgetgeom.I
GRbcgetrang.I
GRbcgetsize.I

GRbckeypoint.I
GRbclnprojec.I
GRbclsproj.I
GRbcmidpoint.I
GRbcmodify.I
GRbcprismrel.I
GRbcptalong.I
GRbcptextend.I
GRbcptprojec.I
GRbcptseqspa.I
GRbcsplit.I
GRbcstretch.I
GRbctotlengt.I
GRbcxform.I
GRcagetobjin.I
GRcarptdef.I
GRcareport.I
GRcaupdgad.I
GRcnaltconst.I
GRcnapprojpt.I
GRcnarea.I
GRcncentcurv.I
GRcncenter.I
GRcncpparall.I
GRcndisexten.I
GRcngenabsg.I
GRcngeomprop.I
GRcngetexgeo.I
GRcngetexsiz.I
GRcngetrang.I
GRcnkeypoint.I
GRcnlnprojec.I
GRcnlocaldp.I
GRcnmodify.I
GRcnpostab.I
GRcnprojpt.I
GRcnptextend.I
GRcnptprojec.I
GRcrgeomprop.I
GRcrgetobjin.I
GRcrrptdef.I
GRcrreport.I
GRcrupdgad.I
GRcvendpoint.I
GReagetobjin.I
GRearptdef.I
GReareport.I
GReaupdgad.I
GRelgeomprop.I
GRelgetobjin.I
GRelrptdef.I
GRelreport.I
GRelupdgad.I
GRilcpparall.I
GRildisyours.I
GRilgetobjin.I
GRilstretch.I
GRlbdetplane.I
GRlbgeomprop.I
GRlbgetgeom.I
GRlbgetrang.I
GRlbgetsize.I

GRlbkeypoint.I
GRlblnprojec.I
GRlblocatepr.I
GRlbprismrel.I
GRlbptprojec.I
GRlbxform.I
GRlnaddpts.I
GRlnaltconst.I
GRlnapprojpt.I
GRlnarea.I
GRlncentcurv.I
GRlncenter.I
GRlncpparall.I
GRlndelverte.I
GRlndisyours.I
GRlngenabsg.I
GRlngeomprop.I
GRlninsverte.I
GRlnlocaldp.I
GRlnmidpoint.I
GRlnmoveseg.I
GRlnpostab.I
GRlnprojpt.I
GRlnremovept.I
GRlnsegfind.I
GRlnvtadjseg.I
GRlsgetobjin.I
GRolgetobjin.I
GRopgeomprop.I
GRopgetobjin.I
GRopremovept.I
GRordelverte.I
GRorinsverte.I
GRormodify.I
GRpggeomprop.I
GRpggetobjin.I
GRplinsverte.I
GRplmodify.I
GRpsgetobjin.I
GRptdisyours.I
GRptgetobjin.I
GRptmodify.I
GRpydisplay.I
GRslgetobjin.I
GRbcrevparm.I
GRlnrptdef.I
GRlnreport.I
GRlnupdgad.I

#ifndef IDRAW

GRcaaxmodify.I
GRcnaxmodify.I
GRcraxmodify.I
GRbcfragment.I
GRcvperbis.I
GRbcinplane.I
GRlbinplane.I
#endif
GRpt_dlist.I
GRbspl_dlist.I
GRorth_dlist.I
GRpoly_dlist.I


SPEC
$(GRNUC)/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SRC
$(GRNUC)/src/go/go1

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/go_I.o
#else
ARCHIVE
$(GRLIB)/lib/go_I.lib
#endif


#else

ARCHIVE
$GRMDS/lib/go_I.a

#endif	


OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
