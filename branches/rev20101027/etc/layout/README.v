/* $Id: README.v,v 1.1.1.1 2001/01/04 21:07:29 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/etc/layout / README.v
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: README.v,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:29  cvs
 *	Initial import to CVS
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

Modifications from the I/VDS 02.03.00.14 in VD* :
===============================================


ci_macros/				cimacros/

EMSFixes/				emsfixes/


VDSannot/				vdannot/
	VDSannot.m				vdannot.m
	lib/VDSannot.o				lib/vdannot.o


	VDCORevItem.sl				VDCmdRvItem.sl
	VDrevItemFn.I				VDCmdRvIt_Fn.I

	VDSftext.sl				VDCmdFtxt.sl
	VDftext_crt.I				VDCmdFtxt_Fn.I
	VDftext_fnc.I				VDCmdFtxt_Fn.I
	VDftext_fts.I				VDCmdFtxt_Pr.I
	Vdftext_msg.I				VDCmdFtxt_Ms.I
	VDftext_not.I				VDCmdFtxt_Nt.I
	VDftext_rd.I				VDCmdFtxt_IO.I
	VDftext_wrt.I				VDCmdFtxt_IO.I
	
	VDannot.S				VDCmdAnnot.S
	VDannoti.I				VDCmdAnnoti.I
	VDexecute.I				VDCmdAnnotEx.I

	VDitblnco.S				VDCmditbln.S
	VDtxldrco.S				VDCmdtxldr.S
	VDtxldrform.I				VDCmdtxldri.I
	VDtxldrmsg.I				VDCmdtxldri.I
	
	VDtxboxupd				VDCmdupdbox.sl

	VDtxbox_msg.I				VDtxboxi.I

	VDit_kludge.I				VDitblnCorr.I


VDScheckin/				vdcheckin/
	_makefile				removed.
	
	/imp					/imp
		VDScheckin.m				vdchkimp.m
		lib/VDScheckon.o			lib/vdchkimp.o	

	/ppl					/ppl
		VDScheckin.m				vdchkppl.m
		COPlItem.u				removed.
		ppl files renamed later.

VDScirce/				vdhulldbg
	VDScirce.m				vdhulldbg.m
	lib/VDScirce.o				lib/vdhulldbg.o

	VDDbgForm.h				vdinclude/VDCmdHull.h
	VDUtDbgIn.C				VDHllDbg_Fn.C
	VDCoDbgIn.sl				VDCmdHllDbg.sl

VDScppl					vdcppl
	VDScppl.m				vdcppl.m
	lib/VDScppl.o				lib/vdcppl.o

VDSdb					vddb
	/source					/source
		VDdb.m					vddbsrc.m
		

VDSdbarep				vddbarep
	VDSdbarep.m				vddbarep.m
	lib/VDSdbarep.o				lib/vddbarep.o
	VDCoRpts.sl				VDCmdRpts.sl
	VDRptsFn.I				VDCMdRptsFn.I

VDSdbg					vddbg

VDSdetail				vddetail
	VDSdetail.m				vddetail.m
	lib/VDSdetail.o				lib/vddetail.o

	!!! DO LATER the classes.

VDSdlassoc				vdassoc
	VDSdlassoc.m				vdassoc.m


VDSdrawing				vddrawing
	VDSdrawing.m				vddrawing.m
	lib/VDSdrawing.o			lib/vddrawing.o
	!!! DO LATER. the classes

VDSequip				vdequip
	ppl					fam
		VDgenfamfil.u				VDCmdGenFam.sl
							VDCmdGenFnc.I


VDSfit					vdfit
	VDFitCmd.sl				VDCmdFit.sl
	VDfit.m					vdfit.m
	lib/vdfot.o				lib/vdfit.o

	-> TRANSFER MESSAGES FROMSM -> VD.
	
VDSlocate				vdlocate
	VDSlocate.m				vdlocate.m
	lib/VDSlocate.o				lib/vdlocate.o

	Classes to be done.

VDSno_pdu				vdstartup
	File VDSnopdu_def.c integarted in vdtstartup directory.

VDSpdm					vdpdm
	/source					/source
		VDSpdm.m				vdpdmsrc.m

	Directory is obsolete -> review with Mallik.
	
VDSpoint				vdpoint
	VDSpoint.m				vdpoint.m
	lib/VDSpoint.o				lib/vdpoint.o

VDSppl					vdppl
	VDSppl.m				vdppl.m
	
VDSproject				vdproject
	VDSproject.m				vdproject.m
	lib/VDSproject.o			lib/vdproject.o

	VDCoProj				VDCmdProj
	VDPrFunc.I				VDCmdProjFn.I
	VDProjNb.I				VDCmdProjNb.I
	VDCompTrk.C				VDCmdProjDb.C

VDSquery				vdpocket

VDSrelhdr				vdrelhdr
	VDSrelhdr.m				vdrelhdr.m
	lib/VDSrelhdr.o				lib/vdrelhdr.o

VDSrep					vdrep
	VDSrep.m				vdrep.m
	lib/VDSrep.o				lib/vdrep.o

	VDSrep					VDCmdRep
	VDSChElRp				VDCmdChgRep
	VDSChElPt				VDCmdChgPth
	VDSgen_funi.I				VDCmdRepFnc.I
	VDSget_symb.I				VDMcGetSymb.I

	VDSsetrep.u				COsetActRep.u

VDSreports				vdreports
	NO changement done.

VDSrisdp				vdris
	/imp					/imp
		exec.m					risexec.m
		load.m					risload.m
		lib/VDSris.o				lib/vdris.o
		Exec.C					VdsExec.C
		Load.C					VdsLoad.C
		RisSql.C				VdsRisSql.C
	/ppl					/ppl
		VDSrisdp.m				vdrisdp.m
		
	/ris
		PROBLEM cann't find ris.a

VDSroot					vdroot
	VDSroot.m				vdroot.m
	lib/VDSroot.o				lib/vdroot.o

VDSspace				vsspace
	/ppl					/ppl
		VDSspace.m				vdspaceppl.m
	/imp					/imp
		VDSspace.m				vdspaceimp.m
		VDSspace.o				vsspace.o

VDSstartup				vdstartup
	VDSstartup.m				vdstartup.m
	lib/VDSstartup.o			lib/vdstartup.o
	VDStSer.S				VDCmdStrtup.S
	SMPocketInit.C		->	vdpocket

VDSsymb_hold				vdsymbhold
	VDSsymb_hold.m				vdsymbhold.m
	lib/VDSsymb_hold.o			lib/vdsymbhold.o


VDStable				vdtable
	VDStable.m				vdtable.m
	lib/VDStable.o				lib/vdtable.o
	VD_tableco.S				VDCmdTable.S

VDSudp					vdudp
	VDSudp.m				vdudp.m
	lib/VDSudp.o				lib/vdudp.o

	VDSpath					VDCmdPath
	VDSld_path				VDCmdPathLd
	VDSrd_path				VDCmdPathRd
	VDSwrt_path				VDCmdPathWr
	VDSset_act				VDCmdPathAc
	VDSset_path				VDCmdPathSt
	VDSset_srch				VDCmdPathSr
	VDSrevpath				VDCmdPathRv

		VDm_place.I	MOVE TO ....


VDSutil					vdutil
	VDSutil.m				vdutil.m
	lib/VDSutil.o				lib/vdutil.o

VDSvisual				vdvisual
	VDSvisual.m				vdvisual.m
	lib/VDSvisual.o				lib/vdvisual.o

	VDSdirform.S				VDCmdDirFrm.S
	VDsetWnGrid.sl				VDCmdGRidOn.sl
	VDwnGrToNot.sl				VDCmdGRidOn.sl
	VDdelGrid.I				VDCmdGridDel.I
	VDcrtwngrid.I				VDCmdGridCrt.I

	VDpktForm.C 		->	vdpocket
	

mv COaxisrep -> cimacros/obsolete/commands
mv COgetinfo -> cimacros/obsolete/commands


Done.:
	

