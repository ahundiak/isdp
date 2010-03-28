SLIC=$(EXNUC)/bin/slic -p $(GRNUC)/spec

ALL:	SI TFILES
IDRAW:	IDRAWSI IDRAWTFILES
SI:	COwindow.S COaxlocks.S COceocmds.S COcnstrpl.S COcolors.S \
	COdynsetvw.S COfillobj.S COgrid.S COlayer.S COmiscl.S \
	COviewmnpl.S COvwchar.S COwndmnpl.S COedtsv.S COedtly.S COlocly.S \
	COSetWinShp.S COdfls.S COactly.S COTogPerBh.S COpan.S COrotcoi.S \
	COroteye.S COtilt.S COvwangle.S COwnarea.S COzoom.S COswapcopy.S \
        COrclvw.S

TFILES: $(GRNUC)/config/commands/GRCpV \
	$(GRNUC)/config/commands/GRCrV \
	$(GRNUC)/config/commands/GRTgDl \
	$(GRNUC)/config/commands/GRShMnGrDv \
	$(GRNUC)/config/commands/GRShDsMjGr \
	$(GRNUC)/config/commands/GRFtV \
	$(GRNUC)/config/commands/GRTgGrLc \
	$(GRNUC)/config/commands/GRTgGrDs \
	$(GRNUC)/config/commands/GRTrOfLy \
	$(GRNUC)/config/commands/GRRtV3Pn \
	$(GRNUC)/config/commands/GRRtVAbPnK \
	$(GRNUC)/config/commands/GRSvV \
	$(GRNUC)/config/commands/GRSZDp \
	$(GRNUC)/config/commands/GRSVDsDp \
	$(GRNUC)/config/commands/GRSMnGrDvM \
	$(GRNUC)/config/commands/GRSDsMjGrD \
	$(GRNUC)/config/commands/GRSVRt \
	$(GRNUC)/config/commands/GRDrftSst \
	$(GRNUC)/config/commands/GRDrftFst \
	$(GRNUC)/config/commands/GRUpV \
	$(GRNUC)/config/commands/GRRtSvV \
	$(GRNUC)/config/commands/GRCVAr \
	$(GRNUC)/config/commands/GRCVCn \
	$(GRNUC)/config/commands/GRMvVCn \
	$(GRNUC)/config/commands/GRZmInV \
	$(GRNUC)/config/commands/GRSl3DPn \
	$(GRNUC)/config/commands/GRAlV \
	$(GRNUC)/config/commands/GRBelOnOff \
	$(GRNUC)/config/commands/GRTgCnPl \
	$(GRNUC)/config/commands/GRCCnPlOr \
	$(GRNUC)/config/commands/GRSlPnOnWr \
	$(GRNUC)/config/commands/GRPCnPl3Pn \
	$(GRNUC)/config/commands/GRShZ \
	$(GRNUC)/config/commands/GRRnV \
	$(GRNUC)/config/commands/GRRtVAbAx \
	$(GRNUC)/config/commands/GRSwV \
	$(GRNUC)/config/commands/GRSUnRnOf \
	$(GRNUC)/config/commands/GRSlPnOnVC \
	$(GRNUC)/config/commands/GRShVPr \
	$(GRNUC)/config/commands/GRTrOfV \
	$(GRNUC)/config/commands/GRTrOnV \
	$(GRNUC)/config/commands/GRCFlMdE \
	$(GRNUC)/config/commands/GRMdVVl \
	$(GRNUC)/config/commands/GRCPsPrTPl \
	$(GRNUC)/config/commands/GRCPlPrTPs \
	$(GRNUC)/config/commands/GRAtClTb \
	$(GRNUC)/config/commands/GRSvClTb \
	$(GRNUC)/config/commands/GRRvSvV \
	$(GRNUC)/config/commands/GREdLy \
	$(GRNUC)/config/commands/GRChLyLcEl \
	$(GRNUC)/config/commands/GRStWnSh \
	$(GRNUC)/config/commands/GRDfLnSt \
	$(GRNUC)/config/commands/GRSALy \
	$(GRNUC)/config/commands/GRRtVwUpVe \
	$(GRNUC)/config/commands/GRRtVwEyPn \
	$(GRNUC)/config/commands/GRTl \
	$(GRNUC)/config/commands/GRChPrAn \
	$(GRNUC)/config/commands/GRZm \
	$(GRNUC)/config/commands/GRRtSvV

IDRAWSI: COceocmds.S COcolors.S COgrid.S COmiscl.S COviewmnpl.S \
	COwindow.S COwndmnpl.S COlayer.S COedtsv.S COedtly.S COlocly.S \
	COdfls.S COactly.S COrclvw.S

IDRAWTFILES: $(GRNUC)/config/commands/GRCpV \
	$(GRNUC)/config/commands/GRCrV \
	$(GRNUC)/config/commands/GRTgDl \
	$(GRNUC)/config/commands/GRShMnGrDv \
	$(GRNUC)/config/commands/GRShDsMjGr \
	$(GRNUC)/config/commands/GRFtV \
	$(GRNUC)/config/commands/GRTgGrLc \
	$(GRNUC)/config/commands/GRTgGrDs \
	$(GRNUC)/config/commands/GRTrOfLy \
	$(GRNUC)/config/commands/GRRtV3Pn \
	$(GRNUC)/config/commands/GRRtVAbPnK \
	$(GRNUC)/config/commands/GRSvV \
	$(GRNUC)/config/commands/GRSZDp \
	$(GRNUC)/config/commands/GRSVDsDp \
	$(GRNUC)/config/commands/GRSMnGrDvM \
	$(GRNUC)/config/commands/GRSDsMjGrD \
	$(GRNUC)/config/commands/GRSVRt \
	$(GRNUC)/config/commands/GRDrftSst \
	$(GRNUC)/config/commands/GRDrftFst \
	$(GRNUC)/config/commands/GRRtSvV \
	$(GRNUC)/config/commands/GRCVAr \
	$(GRNUC)/config/commands/GRCVCn \
	$(GRNUC)/config/commands/GRMvVCn \
	$(GRNUC)/config/commands/GRZmInV \
	$(GRNUC)/config/commands/GRRvSvV \
	$(GRNUC)/config/commands/GREdLy \
	$(GRNUC)/config/commands/GRChLyLcEl \
	$(GRNUC)/config/commands/GRDfLnSt \
	$(GRNUC)/config/commands/GRSALy


COaxlocks.S: COaxlocks.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COcnstrpl.S: COcnstrpl.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COdynsetvw.S: COdynsetvw.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COfillobj.S: COfillobj.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COlayer.S: COlayer.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COmiscl.S: COmiscl.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COvwchar.S: COvwchar.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COceocmds.S: COceocmds.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COcolors.S: COcolors.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COgrid.S: COgrid.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COviewmnpl.S: COviewmnpl.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COwindow.S: COwindow.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COwndmnpl.S: COwndmnpl.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COedtsv.S: COedtsv.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COedtly.S: COedtly.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COlocly.S: COlocly.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COSetWinShp.S: COSetWinShp.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COdfls.S: COdfls.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COactly.S: COactly.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COTogPerBh.S: COpersptog.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COpan.S: COpan.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COrotcoi.S: COrotcoi.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COroteye.S: COroteye.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COtilt.S: COtilt.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COvwangle.S: COvwangle.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COwnarea.S: COwnarea.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COzoom.S: COzoom.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COswapcopy.S: COswapcopy.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COrclvw.S: COrclvw.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRCpV: COswapcopy.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRCrV: COcrtwin.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTgDl: COdelay.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRShMnGrDv: COdpnumgd.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRShDsMjGr: COdprefgd.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRFtV: COfit.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTgGrLc: COgrdlk.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTgGrDs: COgronoff.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTrOfLy: COlys.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRtV3Pn: COrot3pt.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRtVAbPnK: COrotkyval.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSvV: COsavvw.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSZDp: COsetactz.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSVDsDp: COsetdpvol.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSMnGrDvM: COsetnmgd.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSDsMjGrD: COsetrefgd.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSVRt: COsetvw.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRDrftSst: COstrtstop.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRDrftFst: COstrtsuper.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRUpV: COupdwnd.t
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRRtSvV: COsvvwmn.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRCVAr: COwnarea.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRCVCn: COwinctr.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRMvVCn: COpan.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRZmInV: COzoom.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSl3DPn: CO3dpt.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRAlV: COalignvw.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRBelOnOff: CObell.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTgCnPl: COcnsmn.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRCCnPlOr: COcnsorg.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSlPnOnWr: COdbaxlk.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRPCnPl3Pn: COdfncns.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRShZ: COdpdeps.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRnV: COrnmwin.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRtVAbAx: COrotdfnax.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSwV: COswapcopy.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRSUnRnOf: COunitlk.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSlPnOnVC: COvwaxlk.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRShVPr: COvwchar.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTrOfV: COwndoff.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTrOnV: COwndon.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRvSvV: COedtsv.t
	$(SLIC) $?

$(GRNUC)/config/commands/GREdLy: COedtly.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRChLyLcEl: COlocly.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRMdVVl: COdynsetvw.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRCPsPrTPl: COdynsetvw.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRCPlPrTPs: COdynsetvw.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRCFlMdE: COfillobj.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRAtClTb: COcolors.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRSvClTb: COcolors.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRStWnSh: COSetWinShp.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRDfLnSt: COdfls.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSALy: COactly.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRtVwUpVe: COrotcoi.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRRtVwEyPn: COroteye.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRTl: COtilt.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRChPrAn: COvwangle.sl
	$(SLIC) -si $?

$(GRNUC)/config/commands/GRZm: COzoom.sl
	$(SLIC) -si $?

