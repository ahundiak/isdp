SLIC = slic -p $(GRNUC)/spec

ALL:	DRAW_FILES DRAFT_FILES
IDRAW:	DRAW_FILES
DRAW_FILES:	$(GRNUC)/config/commands/StartDir \
                $(GRNUC)/config/commands/GRPL \
                $(GRNUC)/config/commands/GRPFl \
                $(GRNUC)/config/commands/GRPAnBs3Pn \
                $(GRNUC)/config/commands/GRPAr3Pn \
                $(GRNUC)/config/commands/GRPArCn \
                $(GRNUC)/config/commands/GRPArCnR \
                $(GRNUC)/config/commands/GRPBlDgPn \
                $(GRNUC)/config/commands/GRPCr3Pn \
                $(GRNUC)/config/commands/GRPCnCrCnR \
                $(GRNUC)/config/commands/GRPCrDmPn \
		$(GRNUC)/config/commands/GRPCrCEPnD \
                $(GRNUC)/config/commands/GRPCrCnDm \
                $(GRNUC)/config/commands/GRPCTnT1EC \
                $(GRNUC)/config/commands/GRDlVr \
                $(GRNUC)/config/commands/GRDltVwPt \
                $(GRNUC)/config/commands/GRPElBl \
                $(GRNUC)/config/commands/GRPElRtBl \
                $(GRNUC)/config/commands/GRPElAx \
                $(GRNUC)/config/commands/GRPElCn \
                $(GRNUC)/config/commands/GRPEqPnAlE \
                $(GRNUC)/config/commands/GRExETIn \
                $(GRNUC)/config/commands/GREx2ETIn \
                $(GRNUC)/config/commands/IDExEDyn \
                $(GRNUC)/config/commands/GRPHlElAx \
                $(GRNUC)/config/commands/GRPHrL \
                $(GRNUC)/config/commands/GRPInL \
                $(GRNUC)/config/commands/GRInVr \
                $(GRNUC)/config/commands/GRPLTr \
                $(GRNUC)/config/commands/GRPLMnDsBt \
                $(GRNUC)/config/commands/GRPLSg \
                $(GRNUC)/config/commands/GRPLSgTnT2 \
                $(GRNUC)/config/commands/GRPLn \
                $(GRNUC)/config/commands/GRPFlMnTr \
                $(GRNUC)/config/commands/GRMdE \
                $(GRNUC)/config/commands/GRMvSg \
                $(GRNUC)/config/commands/GRMDsBt2Pn \
                $(GRNUC)/config/commands/GRMLnAlE \
                $(GRNUC)/config/commands/GRMAnL \
                $(GRNUC)/config/commands/GRMArE \
                $(GRNUC)/config/commands/GRMCmDs \
                $(GRNUC)/config/commands/GRMDm \
                $(GRNUC)/config/commands/GRMMnDsBt2 \
                $(GRNUC)/config/commands/GRMDsBtPnE \
                $(GRNUC)/config/commands/GRMDsBtPn \
                $(GRNUC)/config/commands/GRMLnE \
                $(GRNUC)/config/commands/GRMsPtProj \
                $(GRNUC)/config/commands/GRMRE \
                $(GRNUC)/config/commands/GRPNsPl \
                $(GRNUC)/config/commands/GRPOrLn \
                $(GRNUC)/config/commands/GRPOrPl \
                $(GRNUC)/config/commands/GRPrDlE \
                $(GRNUC)/config/commands/GRPPn \
                $(GRNUC)/config/commands/GRPPl \
                $(GRNUC)/config/commands/GRAbsWldPt \
                $(GRNUC)/config/commands/GRSlPnDsAl \
                $(GRNUC)/config/commands/GRSlPnDsBt \
                $(GRNUC)/config/commands/GRPQrElAx \
                $(GRNUC)/config/commands/GRPRtBl \
                $(GRNUC)/config/commands/GRRvAnRdUn \
                $(GRNUC)/config/commands/GRRvLnRdUn \
                $(GRNUC)/config/commands/GRSpE \
                $(GRNUC)/config/commands/GRPTnPn \
                $(GRNUC)/config/commands/GRPVrL \
                $(GRNUC)/config/commands/GRMAn3Pn \
                $(GRNUC)/config/commands/GRHiLtEl \
                $(GRNUC)/config/commands/GRRnE \
                $(GRNUC)/config/commands/GRSlPnKyn \
                $(GRNUC)/config/commands/IDPAr3Pn

DRAFT_FILES:    $(GRNUC)/config/commands/GRCArTCr \
                $(GRNUC)/config/commands/GRCArTDgCm \
                $(GRNUC)/config/commands/GRCAxCn \
                $(GRNUC)/config/commands/GRCDr \
                $(GRNUC)/config/commands/GRCDrPt \
                $(GRNUC)/config/commands/GRCrDr \
                $(GRNUC)/config/commands/GRDlDr \
                $(GRNUC)/config/commands/GRExArAn \
                $(GRNUC)/config/commands/GRFrE \
                $(GRNUC)/config/commands/GRGnEqSPAE \
                $(GRNUC)/config/commands/GRGnMtPn \
                $(GRNUC)/config/commands/GRGnPlArPn \
                $(GRNUC)/config/commands/GRGnPnAESp \
                $(GRNUC)/config/commands/GRMAn2Pn \
                $(GRNUC)/config/commands/GRMAnBt2L \
                $(GRNUC)/config/commands/GRMAnBt2Pn \
                $(GRNUC)/config/commands/GRMAnBtLAr \
                $(GRNUC)/config/commands/GRMSwAnE \
                $(GRNUC)/config/commands/GRMvEAlVc \
                $(GRNUC)/config/commands/GRMvdir \
                $(GRNUC)/config/commands/GRPATnTECD \
                $(GRNUC)/config/commands/GRPAnBsBtE \
                $(GRNUC)/config/commands/GRPArR2Pn \
                $(GRNUC)/config/commands/GRPArRPnTn \
                $(GRNUC)/config/commands/GRPCTnT1ED \
                $(GRNUC)/config/commands/GRPCTnTECD \
                $(GRNUC)/config/commands/GRPCr2PnDm \
                $(GRNUC)/config/commands/GRPCrTnT3E \
                $(GRNUC)/config/commands/GRPNsPlMdS \
                $(GRNUC)/config/commands/GRPPlLn \
                $(GRNUC)/config/commands/GRPPrBs \
                $(GRNUC)/config/commands/GRSCrSyTy \
                $(GRNUC)/config/commands/GRSVr \
                $(GRNUC)/config/commands/GRShCrPn \
                $(GRNUC)/config/commands/GRShDr \
                $(GRNUC)/config/commands/GRShNmEl \
                $(GRNUC)/config/commands/GRShVr \
                $(GRNUC)/config/commands/GRSlDlPIV \
                $(GRNUC)/config/commands/GRSlDlPIWC \
                $(GRNUC)/config/commands/GRSlPnDsDr \
                $(GRNUC)/config/commands/GRPSyOv \
                $(GRNUC)/config/commands/GRRvSyOv \
                $(GRNUC)/config/commands/GRDrSnSyOv \
                $(GRNUC)/config/commands/GRTgSmSk \
                $(GRNUC)/config/commands/GRSmSk

$(GRNUC)/config/commands/StartDir: StartDir.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPL: actangln.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPFl: afillet.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPAnBs3Pn:    angbs3pt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPAr3Pn:  arc3pt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPArCn:  arccnt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPArCnR: arcrct.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPBlDgPn:  block.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCr3Pn: cr3pts.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCrCEPnD: crcnt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCnCrCnR: crconcnt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCrDmPn: crdiam.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCrCnDm: crrad.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCTnT1EC: crtcnt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRDlVr: delvert.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRDltVwPt: dpt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPElBl: el2pts.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPElRtBl: el3pts.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPElAx: elaxis.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPElCn: elcnt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPEqPnAlE: eqsppt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRExETIn: ext1st.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GREx2ETIn: ext2st.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/IDExEDyn: extend.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPHlElAx:   halfel.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPHrL:     horizln.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPInL:     infln.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRInVr: insertv.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPLTr: lineterm.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPLMnDsBt:    lnmindis.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPLSg: lnseg.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPLSgTnT2: lnsegt2.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPLn: lnstr.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPFlMnTr: mfillet.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMdE: modelem.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMvSg:    moveseg.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMDsBt2Pn:    ms2pt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMLnAlE:    msalong.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMAnL:  msangln.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMArE:    msarea.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMCmDs:    mscumul.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMDm:    msdiam.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMMnDsBt2: msdis2el.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMDsBtPnE:  msdptel.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMDsBtPn:  msdptpt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMLnE:     mslen.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMsPtProj: msptproj.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMRE: msrad.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPNsPl: nspoly.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPOrLn:   orthline.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPOrPl: orthpoly.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPrDlE: pardelet.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPPn:   point.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPPl:     polygon.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRAbsWldPt: pt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSlPnDsAl: ptalong.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSlPnDsBt: ptbt2pt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPQrElAx:   qell.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPRtBl:  rotblk.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRRvAnRdUn: rvangrd.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRRvLnRdUn: rvlinrd.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSpE: split.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPTnPn:    tenpt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPVrL:    vertln.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMAn3Pn:  msang3pt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRHiLtEl:   hilite.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRRnE:     remove.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSlPnKyn: xy.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/IDPAr3Pn: arcendpt.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRCArTCr: arctocr.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRCArTDgCm: comparc.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRCAxCn: modaxis.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRCDr: cd.t 
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRCDrPt: cdpath.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRCrDr: mkdir.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRDlDr: rmdir.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRExArAn: arcxang.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRFrE: fragment.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRGnEqSPAE: geneqsppts.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRGnMtPn: genmxpts.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRGnPlArPn: polarpts.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRGnPnAESp: genptsalng.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMAn2Pn: msang2pt.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMAnBt2L: msang2ln.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMAnBt2Pn: msang2ptax.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMAnBtLAr: msanglnax.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMSwAnE: mssweep.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMvEAlVc: mvalongv.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRMvdir: mvdir.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPATnTECD: arcchd.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPAnBsBtE: angb2el.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPArR2Pn: arcrad.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPArRPnTn: arcrpt.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCTnT1ED: crtdiam.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCTnTECD: crchd.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCr2PnDm: cr2ptrad.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPCrTnT3E: crt3pts.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPNsPlMdS: nspymdpt.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPPlLn: lnstrpl.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPPrBs: perbis.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSCrSyTy: setactcsty.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSVr: setvar.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRShCrPn: dpcurpt.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRShDr: pwd.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRShNmEl: shownm.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRShVr: showvar.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSlDlPIV: dx.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSlDlPIWC: dl.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSlPnDsDr: di.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRDrSnSyOv: rmbound.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRPSyOv: placesoo.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRRvSyOv: showso.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRTgSmSk: sslock.t
	$(SLIC) -csi  $?
$(GRNUC)/config/commands/GRSmSk: smoption.t
	$(SLIC) -csi  $?
