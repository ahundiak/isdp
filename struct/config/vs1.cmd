/*
	I/STRUCT Command Table
*/
#include "VScmd.h"

"STRUCT Session Startup",VSstartup0,VSstrtupCmd,0,256,,,STRUCT.o
"STRUCT File Startup",VSstartup1,VSstrtupCmd,1,512,,,STRUCT.o

/*
	Command to update old objects to subclass of VDSroot object
*/
"Update to VDSroot Object",VSupdVDSrt,VSrtUpdCmd,0,512,,,STRUCT.o

/*
	Menu intitialization.
*/
^"Struct",IMTkInit,COci,0,0,,"BLANK"
^"Struct",IMTkVs,COci,0,0,,"VDswaptask IMTkVs IMVS BAR_VDS POCKET_MODEL"

/*
	Non-COB commands.
*/
"Review Structural Selector Object",VSRvStSl,COci,0,0,,"COz_selector"
"Associative Place Coordinate System By 2 Element",VSCSb2El,COci,0,0,,"COpla_cs2el"
"Place Mirror Image of Construction",VSPlMrImCn,COci,0,0,,"COrelat_hdr"
"Copy Surface Dependency",VSCpSfDp,COci,0,0,,"VScpsfdep"
"z Remove Protection",VSunPro,COci,0,0,,"COz_UnPro"
"Modify Stiffener Axis",VSbaModify,COci,0,0,,"CObaModify"
"Modify Edge Attributes",VSmodBevel,COci,0,0,,"COmodBevel"
"Migrate Individual Cutouts,VSMigCt1,COci,0,0,,"VStrmigrFea"
"Place Bevel",VSplBvl,COci,0,0,,"CObevel"
"Modify Bevel",VSmdBvl,COci,0,0,,"CObevelMod"
"Modify Bevel Attributes",VSmdBvlAtt,COci,0,0,,"COmodBvlAttr"
"Update Bevels",VSPPLupdBevels,COci,0,0,,"VSupdBevels"
"Verify Bevels",VSPPLverBevels,COci,0,0,,"VSverBevel"
""Create Rogue Surface macro",VScreRogSrf,COci,0,0,,"COsrf_rogue"
"Transform Edge to EJ_Bevel",VStrEdgToBvl,COci,0,0,,"VSedgToBvl"
"Modify Plate Operator",VSmdMopPlate,COci,0,0,,"VSmopPlate"
"Modify Beam Operator",VSmdMopBeam,COci,0,0,,"VSmopBeam"
"Piece Mark Fit",VSftPcMk,COci,0,0,,"COz_pcmk"
"Delete All Edges",VSdelAllEd,COci,0,0,,"COdelEdges"
"Place Neat Contour",VSPlNtCt,COci,0,0,,"COneat_cont"
"Validate Structure",VSvalidSt,COci,0,0,,"VSvalidate"
"Recompute Invalid Chocks",VSzcoChk,COci,0,0,,"COcomp_chk"
"Review Structural Objects",VSrevStrObj,COci,0,0,,"COrevStrObj"
VSC_M_VSTrOnStAx,VSTrOnStAx,COci,1,0,,"VSbaonoffCmd"
VSC_M_VSTrOfStAx,VSTrOfStAx,COci,0,0,,"VSbaonoffCmd"
VSC_M_VSTrOnMrIm,VSTrOnMrIm,COci,1,0,,"VSimonoffCmd"
VSC_M_VSTrOfMrIm,VSTrOfMrIm,COci,0,0,,"VSimonoffCmd"
VSC_M_VSMigCt,VSMigCt,COci,0,0,,"VStrmigrCmd"
VSC_M_VSMdSfOfPl,VSMdSfOfPl,COci,0,0,,"VSmdsfplCmd"
VSC_M_VSDfOpIMc,VSDfOpIMc,COci,0,0,,"VSopinmcCmd"
VSC_M_VSLdGCLb,VSLdGCLb,VSmacpalCmd,100
VSC_M_VSLdOPLb,VSLdOPLb,VSmacpalCmd,200
VSC_M_VSLdETLb,VSLdETLb,VSmacpalCmd,300
VSC_M_VSLdBRLb,VSLdBRLb,VSmacpalCmd,400
VSC_M_VSLdCTLb,VSLdCTLb,VSmacpalCmd,500
VSC_M_VSLdTRLb,VSLdTRLb,VSmacpalCmd,600
VSC_M_VSAcGCLb,VSAcGCLb,VSmacpalCmd,0
VSC_M_VSAcGHLb,VSAcGHLb,VSmacpalCmd,1
VSC_M_VSAcGPLb,VSAcGPLb,VSmacpalCmd,2
VSC_M_VSAcGSLb,VSAcGSLb,VSmacpalCmd,3
VSC_M_VSAcBRLb,VSAcBRLb,VSmacpalCmd,4
VSC_M_VSAcBFLb,VSAcBFLb,VSmacpalCmd,5
VSC_M_VSAcBCLb,VSAcBCLb,VSmacpalCmd,6
VSC_M_VSAcOPLb,VSAcOPLb,VSmacpalCmd,7
VSC_M_VSAcOHLb,VSAcOHLb,VSmacpalCmd,8
VSC_M_VSAcOSLb,VSAcOSLb,VSmacpalCmd,9
VSC_M_VSAcETLb,VSAcETLb,VSmacpalCmd,10
VSC_M_VSAcECLb,VSAcECLb,VSmacpalCmd,11
VSC_M_VSAcCTLb,VSAcCTLb,VSmacpalCmd,12
VSC_M_VSAcCRLb,VSAcCRLb,VSmacpalCmd,13
VSC_M_VSAcCWLb,VSAcCWLb,VSmacpalCmd,14
VSC_M_VSAcCCLb,VSAcCCLb,VSmacpalCmd,15
VSC_M_VSAcTRLb,VSAcTRLb,VSmacpalCmd,16
VSC_M_VSAcTBLb,VSAcTBLb,VSmacpalCmd,17
VSC_M_VSAcTDLb,VSAcTDLb,VSmacpalCmd,18
VSC_M_VSAcTFLb,VSAcTFLb,VSmacpalCmd,19
VSC_M_VSAcOCLb,VSAcOCLb,VSmacpalCmd,20
VSC_M_VSAcOBLb,VSAcOBLb,VSmacpalCmd,21
VSC_M_VSAcBHLb,VSAcBHLb,VSmacpalCmd,22
VSC_M_VSAcESLb,VSAcESLb,VSmacpalCmd,23
VSC_M_VSAcEJLb,VSAcEJLb,VSmacpalCmd,24
VSC_M_VSAcELLb,VSAcELLb,VSmacpalCmd,25
VSC_M_VSAcEMLb,VSAcEMLb,VSmacpalCmd,26





