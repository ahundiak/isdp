/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   helpids1.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*              ONLY INCLUDE THIS FILE FROM HELPIDS.H		       */
/*----------------------------------------------------------------------+
|    Help ids used in File pulldown menu    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_File	    	    TPC_FILE
#define HELPID_PULLDOWN_FileNew  	    0
#define HELPID_PULLDOWN_FileOpen 	    0
#define HELPID_PULLDOWN_FileCell 	    0
#define HELPID_PULLDOWN_FileReference       0
#define HELPID_PULLDOWN_FileClose	    0
#define HELPID_PULLDOWN_FileSaveAs	    0
#define HELPID_PULLDOWN_FileCompress	    0
#define HELPID_PULLDOWN_FileSaveSettings    0
#define HELPID_PULLDOWN_FileRevertg	    0
#define HELPID_PULLDOWN_FilePageSet	    0
#define HELPID_PULLDOWN_FilePrint	    0
#define HELPID_PULLDOWN_FilePlot 	    0
#define HELPID_PULLDOWN_FileImport	    0
#define HELPID_PULLDOWN_FileExport	    0
#define HELPID_PULLDOWN_FileDisplay	    0
#define HELPID_PULLDOWN_FileSaveImage	    0
#define HELPID_PULLDOWN_FileExit 	    0
#define HELPID_PULLDOWN_SubCellLibrary	    0
#define HELPID_PULLDOWN_CellSub_New	    0
#define HELPID_PULLDOWN_CellSub_Attach	    0
#define HELPID_PULLDOWN_CellSub_Compress    0
#define HELPID_PULLDOWN_SubDisplay	    0	/* SubMenu */
#define HELPID_PULLDOWN_DispSub_Image	    0
#define HELPID_PULLDOWN_DispSub_Text	    0
#define HELPID_PULLDOWN_SubExport	    0	/* SubMenu */
#define HELPID_PULLDOWN_ExpSub_DXF	    TPC_DXFOUT
#define HELPID_PULLDOWN_ExpSub_2d3d	    0
#define HELPID_PULLDOWN_ExpSub_RIB	    TPC_RMAN
#define HELPID_PULLDOWN_ExpSub_Edges	    TPC_EDGES
#define HELPID_PULLDOWN_SubImport	    0	/* SubMenu */
#define HELPID_PULLDOWN_InpSub_DXF	    TPC_DXFIN
#define HELPID_PULLDOWN_InpSub_Text	    0

/*----------------------------------------------------------------------+
|    Help ids used in Edit pulldown menu    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_Edit		    TPC_EDIT	/* MainMenu */
#define HELPID_PULLDOWN_SubUndo		    TPC_UNDOING	/* SubMenu */
#define HELPID_PULLDOWN_Edit_Undo	    0
#define HELPID_PULLDOWN_Edit_UndoLast	    TPC_UNDOING
#define HELPID_PULLDOWN_Edit_Redo	    0
#define HELPID_PULLDOWN_Edit_SetMark	    0
#define HELPID_PULLDOWN_Edit_Cut	    0
#define HELPID_PULLDOWN_Edit_Copy	    0
#define HELPID_PULLDOWN_Edit_Paste	    0
#define HELPID_PULLDOWN_Edit_Clear	    0
#define HELPID_PULLDOWN_Edit_Dup	    0
#define HELPID_PULLDOWN_Edit_SelAll	    0
#define HELPID_PULLDOWN_Edit_Group	    0
#define HELPID_PULLDOWN_Edit_UnGroup	    0
#define HELPID_PULLDOWN_Edit_Lock	    0
#define HELPID_PULLDOWN_Edit_UnLock	    0
#define HELPID_PULLDOWN_UndoSub_ToMark	    0
#define HELPID_PULLDOWN_UndoSub_UndoAll	    0

/*----------------------------------------------------------------------+
|    Help ids used in Element pulldown menu 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_Element		    TPC_ELEMENT	/* MainMenu */
#define HELPID_PULLDOWN_ElementColor	    TPC_COLOR
#define HELPID_PULLDOWN_ElementWeight	    TPC_WEIGHT
#define HELPID_PULLDOWN_ElementStyle	    TPC_STYLE
#define HELPID_PULLDOWN_Element_Info	    TPC_ANALYZE
#define HELPID_PULLDOWN_Element_Attrib	    0
#define HELPID_PULLDOWN_Element_Bspline	    TPC_SPLINESBOX
#define HELPID_PULLDOWN_Element_Dimension   0
#define HELPID_PULLDOWN_Element_Mlines	    0
#define HELPID_PULLDOWN_Element_Text	    0
#define HELPID_PULLDOWN_SubDimension	    0	/* SubMenu */
#define HELPID_PULLDOWN_DimSub_Place	    0
#define HELPID_PULLDOWN_DimSub_Attrib	    0
#define HELPID_PULLDOWN_DimSub_Geom	    0
#define HELPID_PULLDOWN_DimSub_Text	    0
#define HELPID_PULLDOWN_DimSub_Attrib	    0
#define HELPID_PULLDOWN_DimSub_Geom	    0
#define HELPID_PULLDOWN_DimSub_Text	    0
#define HELPID_PULLDOWN_DimSub_Tol	    0
#define HELPID_PULLDOWN_DimSub_GeomTol	    TPC_GEOMTOL
#define HELPID_PULLDOWN_DimSub_Symbol	    0
#define HELPID_PULLDOWN_DimSub_Term	    0
#define HELPID_PULLDOWN_DimSub_Tool	    0

/*----------------------------------------------------------------------+
|    Help ids used in Settings pulldown menu	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_Settings	    TPC_SETTINGS	/* MainMenu */
#define HELPID_PULLDOWN_Settings_Precision  0
#define HELPID_PULLDOWN_Settings_ActAngle   0
#define HELPID_PULLDOWN_Settings_ActScale   0
#define HELPID_PULLDOWN_Settings_AuxCoord   0
#define HELPID_PULLDOWN_Settings_Cell	    0
#define HELPID_PULLDOWN_Settings_Color	    0
#define HELPID_PULLDOWN_Settings_CoordRead  0
#define HELPID_PULLDOWN_Settings_Dbase	    0
#define HELPID_PULLDOWN_Settings_Digitize   0
#define HELPID_PULLDOWN_Settings_Font	    0
#define HELPID_PULLDOWN_Settings_Grid	    0
#define HELPID_PULLDOWN_Settings_LevNames   0
#define HELPID_PULLDOWN_Settings_LevSymb    0
#define HELPID_PULLDOWN_Settings_Locks	    0
#define HELPID_PULLDOWN_Settings_Render	    0
#define HELPID_PULLDOWN_Settings_WUnits	    0
#define HELPID_PULLDOWN_Settings_Tool	    0
#define HELPID_PULLDOWN_SubLocks	    0	/* SubMenu */
#define HELPID_PULLDOWN_SLockSub_FMenu	    0
#define HELPID_PULLDOWN_SLockSub_Toggle	    0
    
/*----------------------------------------------------------------------+
|    Help ids used in View pulldown menu    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_View		    TPC_VIEW	/* MainMenu */
#define HELPID_PULLDOWN_SubOpenClose	    0	/* SubMenu */
#define HELPID_PULLDOWN_OpenClose1	    0
#define HELPID_PULLDOWN_OpenClose2	    0
#define HELPID_PULLDOWN_OpenClose3	    0
#define HELPID_PULLDOWN_OpenClose4	    0
#define HELPID_PULLDOWN_OpenClose5	    0
#define HELPID_PULLDOWN_OpenClose6	    0
#define HELPID_PULLDOWN_OpenClose7	    0
#define HELPID_PULLDOWN_OpenClose8	    0
#define HELPID_PULLDOWN_View_OpenClose	    0
#define HELPID_PULLDOWN_View_BottomTop	    0
#define HELPID_PULLDOWN_View_Cascade	    0
#define HELPID_PULLDOWN_View_Tile	    0
#define HELPID_PULLDOWN_View_SwapScreen	    0
#define HELPID_PULLDOWN_View_Update	    0
#define HELPID_PULLDOWN_View_CopyView	    0
#define HELPID_PULLDOWN_View_Fit	    0
#define HELPID_PULLDOWN_View_Window	    0
#define HELPID_PULLDOWN_View_Zoom	    0
#define HELPID_PULLDOWN_View_Camera	    0
#define HELPID_PULLDOWN_View_Render	    0
#define HELPID_PULLDOWN_View_Attributes	    0
#define HELPID_PULLDOWN_View_Levels	    0
#define HELPID_PULLDOWN_View_Rotation	    0
#define HELPID_PULLDOWN_View_Saved	    0
#define HELPID_PULLDOWN_SubUpdate	    TPC_UPDATES	/* SubMenu */
#define HELPID_PULLDOWN_UpdateSub_View	    0
#define HELPID_PULLDOWN_UpdateSub_All	    0
#define HELPID_PULLDOWN_UpdateSub_IFence    0
#define HELPID_PULLDOWN_UpdateSub_OFence    0
#define HELPID_PULLDOWN_UpdateSub_Grid	    0
#define HELPID_PULLDOWN_SubFit		    TPC_FITS	/* SubMenu */
#define HELPID_PULLDOWN_FitSub_Active	    0
#define HELPID_PULLDOWN_FitSub_All	    0
#define HELPID_PULLDOWN_FitSub_Reference    0
#define HELPID_PULLDOWN_SubWindow	    TPC_WINDOWS	/* SubMenu */
#define HELPID_PULLDOWN_WindSub_Area	    0
#define HELPID_PULLDOWN_WindSub_Center	    0
#define HELPID_PULLDOWN_WindSub_Volume	    0
#define HELPID_PULLDOWN_SubZoom		    TPC_ZOOMS	/* SubMenu */
#define HELPID_PULLDOWN_ZoomSub_In	    0
#define HELPID_PULLDOWN_ZoomSub_Out	    0
#define HELPID_PULLDOWN_SubCamera	    TPC_CAMERAS	/* SubMenu */
#define HELPID_PULLDOWN_CamSub_Set	    0
#define HELPID_PULLDOWN_CamSub_Position	    0
#define HELPID_PULLDOWN_CamSub_Target	    0
#define HELPID_PULLDOWN_CamSub_Lens	    0
#define HELPID_PULLDOWN_SubRender	    TPC_RENDERS	/* SubMenu */
#define HELPID_PULLDOWN_RendSub_Wiremesh    0
#define HELPID_PULLDOWN_RendSub_XSect	    0
#define HELPID_PULLDOWN_RendSub_HLine	    0
#define HELPID_PULLDOWN_RendSub_FHLine	    0
#define HELPID_PULLDOWN_RendSub_Constant    0
#define HELPID_PULLDOWN_RendSub_Smooth	    0
#define HELPID_PULLDOWN_RendSub_Phong	    0
#define HELPID_PULLDOWN_RendSub_Stereo	    0

/*----------------------------------------------------------------------+
|    Help ids used in Palette pulldown menu 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_Palettes	    TPC_PALETTES	/* MainMenu */
#define HELPID_PULLDOWN_Palette_Main	    0
#define HELPID_PULLDOWN_Palette_Fence	    0
#define HELPID_PULLDOWN_Palette_3d	    0
#define HELPID_PULLDOWN_Palette_3dBspline   TPC_SPLINESPAL
#define HELPID_PULLDOWN_Palette_AuxCoord    0
#define HELPID_PULLDOWN_Palette_DBase	    0
#define HELPID_PULLDOWN_Palette_Dimen	    0
#define HELPID_PULLDOWN_Palette_Measure	    0
#define HELPID_PULLDOWN_Palette_MLJoin	    TPC_CUTTERPAL
#define HELPID_PULLDOWN_Palette_Pattern	    0
#define HELPID_PULLDOWN_Palette_RefFile	    0
#define HELPID_PULLDOWN_Palette_CloseSubs   0
#define HELPID_PULLDOWN_SubMainPalette	    0	/* SubMenu */
#define HELPID_PULLDOWN_SPMain_Arc	    0
#define HELPID_PULLDOWN_SPMain_Bspline	    0
#define HELPID_PULLDOWN_SPMain_Cells	    0
#define HELPID_PULLDOWN_SPMain_Chain	    0
#define HELPID_PULLDOWN_SPMain_Change	    0
#define HELPID_PULLDOWN_SPMain_Circle	    0
#define HELPID_PULLDOWN_SPMain_Copy	    0
#define HELPID_PULLDOWN_SPMain_Drop	    0
#define HELPID_PULLDOWN_SPMain_EDField	    0
#define HELPID_PULLDOWN_SPMain_Fillet	    0
#define HELPID_PULLDOWN_SPMain_Lines	    0
#define HELPID_PULLDOWN_SPMain_LString	    0
#define HELPID_PULLDOWN_SPMain_Mirror	    0
#define HELPID_PULLDOWN_SPMain_Modify	    0
#define HELPID_PULLDOWN_SPMain_Points	    0
#define HELPID_PULLDOWN_SPMain_Polygon	    0
#define HELPID_PULLDOWN_SPMain_Text	    0
#define HELPID_PULLDOWN_SPMain_View	    0
#define HELPID_PULLDOWN_SubFencePalette	    0	/* SubMenu */
#define HELPID_PULLDOWN_SPFence_Change	    0
#define HELPID_PULLDOWN_SPFence_Copy	    0
#define HELPID_PULLDOWN_SPFence_Delete	    0
#define HELPID_PULLDOWN_SPFence_Mirror	    0
#define HELPID_PULLDOWN_SPFence_Place	    0
#define HELPID_PULLDOWN_SubDimenPalette	    0	/* SubMenu */
#define HELPID_PULLDOWN_SPDim_Angle	    0
#define HELPID_PULLDOWN_SPDim_Linear	    0
#define HELPID_PULLDOWN_SPDim_Radial	    0
#define HELPID_PULLDOWN_SPDim_Misc	    0
#define HELPID_PULLDOWN_Sub3dSplinePalette  0	/* SubMenu */
#define HELPID_PULLDOWN_SP3DSpline_SpCurve  0
#define HELPID_PULLDOWN_SP3DSpline_Surf	    0
#define HELPID_PULLDOWN_SP3DSpline_DSurf    0
#define HELPID_PULLDOWN_SP3DSpline_CSurf    0

/*----------------------------------------------------------------------+
|    Help ids used in User pulldown menu    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_User		    TPC_USER	/* MainMenu */
#define HELPID_PULLDOWN_User_Pref	    0
#define HELPID_PULLDOWN_User_EnvirVar	    0
#define HELPID_PULLDOWN_User_Funckey	    0
#define HELPID_PULLDOWN_User_MDLAPPS	    0
#define HELPID_PULLDOWN_User_UserCommand    TPC_RUNUCM
#define HELPID_PULLDOWN_User_EditUCI	    0
#define HELPID_PULLDOWN_User_NetSecure	    0
#define HELPID_PULLDOWN_NetworkSecurity	    0	/* SubMenu */
#define HELPID_PULLDOWN_UserNLASub_Key	    0
#define HELPID_PULLDOWN_UserNLASub_Time	    TPC_TIMELEFT

/*----------------------------------------------------------------------+
|    Help ids used in Help pulldown menu    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PULLDOWN_Help		    TPC_HELP	/* MainMenu */
#define HELPID_PULLDOWN_Help_Context	    0
#define HELPID_PULLDOWN_Help_Keys	    0
#define HELPID_PULLDOWN_Help_Help	    0
#define HELPID_PULLDOWN_Help_Topics	    0
#define HELPID_PULLDOWN_Help_Version	    0
#define HELPID_PULLDOWN_Help_CmdBrowser	    0

/*----------------------------------------------------------------------+
|    Help ids used in Element Attribute dialog 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ElementAttributes	    0
#define HELPID_TEXT_ElementLevel	    0
#define HELPID_TEXT_ElementColor	    TPC_COLOR
#define HELPID_COLPCK_ElementColor	    TPC_COLOR
#define HELPID_TEXT_ElementStyle	    TPC_STYLE
#define HELPID_OPTBUT_ElementStyle    	    TPC_STYLE
#define HELPID_TEXT_ElementWeight	    TPC_WEIGHT
#define HELPID_OPTBUT_ElementWeight    	    TPC_WEIGHT

/*----------------------------------------------------------------------+
|    Help ids used in Active Angle dialog 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ActiveAngle	    0
#define HELPID_GEN_ActvAnglIndicator	    0
#define HELPID_TEXT_ActiveAngle		    0
#define HELPID_TEXT_ActiveAngleTol	    0
#define HELPID_TGLBUT_AngleTolLock	    0

/*----------------------------------------------------------------------+
|    Help ids used in Active Scale dialog 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ActiveScale	    0
#define HELPID_GEN_ActiveScaleLock	    0
#define HELPID_PSHBUT_ActiveScale1	    0
#define HELPID_PSHBUT_ActiveScaleHalf	    0
#define HELPID_PSHBUT_ActiveScaleDouble	    0
#define HELPID_TEXT_ActiveXScale	    0
#define HELPID_TEXT_ActiveYScale	    0
#define HELPID_TEXT_ActiveZScale	    0
#define HELPID_TEXT_ActiveScaleTol	    0
#define HELPID_TGLBUT_ScaleTolLock	    0

/*----------------------------------------------------------------------+
|    Help ids used in Dimension Strings dialog 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimStrings  	    0
#define HELPID_TEXT_DimUMainString	    0
#define HELPID_TEXT_DimUUTolString	    0
#define HELPID_TEXT_DimULTolString	    0
#define HELPID_TEXT_DimUULimitString	    0
#define HELPID_TEXT_DimULLimitString	    0
#define HELPID_TEXT_DimLMainString	    0
#define HELPID_TEXT_DimLUTolString	    0
#define HELPID_TEXT_DimLLTolString	    0
#define HELPID_TEXT_DimLULimitString	    0
#define HELPID_TEXT_DimLLLimitString	    0
#define HELPID_PULLDOWN_DimStySelection	    0
#define HELPID_PULLDOWN_DimSty_Edit	    0
#define HELPID_PULLDOWN_DimSettingsAttr	    0
#define HELPID_PULLDOWN_DimSettingsGeom	    0
#define HELPID_PULLDOWN_DimSettingsText	    0
#define HELPID_PULLDOWN_DimSettingsTol	    0
#define HELPID_PULLDOWN_DimSetGeomTol	    0
#define HELPID_PULLDOWN_DimSetSymbols	    0
#define HELPID_PULLDOWN_DimSettingsTerm	    0
#define HELPID_PULLDOWN_DimSettingsTool	    0

/*----------------------------------------------------------------------+
|    Help ids used in Dimension Attributes dialog			|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimAttributes	    0
#define HELPID_COLPCK_DimTextColor	    0
#define HELPID_TEXT_DimTextColor	    0
#define HELPID_TGLBUT_DimTextColor	    0
#define HELPID_OPTBUT_DimTextWeight	    0
#define HELPID_TEXT_DimTextWeight	    0
#define HELPID_TGLBUT_DimTextWeight	    0
#define HELPID_TEXT_DimTextFont		    0
#define HELPID_TGLBUT_DimTextFont	    0
#define HELPID_TEXT_DimTextHeight	    0
#define HELPID_TGLBUT_DimTextHeight	    0
#define HELPID_TEXT_DimTextWidth	    0
#define HELPID_TGLBUT_DimTextWidth	    0
#define HELPID_GEN_AdimTextScaleLock	    0
#define HELPID_COLPCK_DimElementColor	    TPC_DIMSTYLE
#define HELPID_TEXT_DimElementColor	    TPC_DIMSTYLE
#define HELPID_TGLBUT_DimElementColor	    TPC_DIMSTYLE
#define HELPID_OPTBUT_DimElementStyle	    TPC_DIMSTYLE
#define HELPID_TEXT_DimElementStyle	    TPC_DIMSTYLE
#define HELPID_TGLBUT_DimElementStyle	    TPC_DIMSTYLE
#define HELPID_OPTBUT_DimElementWeight	    TPC_DIMSTYLE
#define HELPID_TEXT_DimElementWeight	    TPC_DIMSTYLE
#define HELPID_TGLBUT_DimElementWeight	    TPC_DIMSTYLE
#define HELPID_COLPCK_DimAlternateColor	    TPC_DIMALTSYMB
#define HELPID_TEXT_DimAlternateColor	    TPC_DIMALTSYMB
#define HELPID_TGLBUT_DimAlternateColor	    TPC_DIMALTSYMB
#define HELPID_OPTBUT_DimAlternateStyle	    TPC_DIMALTSYMB
#define HELPID_TEXT_DimAlternateStyle	    TPC_DIMALTSYMB
#define HELPID_TGLBUT_DimAlternateStyle	    TPC_DIMALTSYMB
#define HELPID_OPTBUT_DimAlternateWeight    TPC_DIMALTSYMB
#define HELPID_TEXT_DimAlternateWeight	    TPC_DIMALTSYMB
#define HELPID_TGLBUT_DimAlternateWeight    TPC_DIMALTSYMB
#define HELPID_TEXT_DimPlacementLevel	    0
#define HELPID_TGLBUT_DimPlacementLevel	    0

/*----------------------------------------------------------------------+
|    Help ids used in Dimension Geometry dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimGeometry	    0
#define HELPID_TGLBUT_DimGenerateWitness    TPC_DIMWIT
#define HELPID_TEXT_DimWitnessOffset	    TPC_DIMWIT
#define HELPID_TEXT_DimWitnessExtend	    TPC_DIMWIT
#define HELPID_TGLBUT_DimJoinExternal	    TPC_DIMWIT
#define HELPID_TEXT_DimTextMargin	    TPC_DIMMARGIN
#define HELPID_TEXT_DimMainTextLift	    TPC_DIMMARGIN  /* SP */
#define HELPID_TEXT_DimTolTextLift	    TPC_DIMMARGIN  /* SP */
#define HELPID_TEXT_DimTolSeparation	    TPC_DIMMARGIN
#define HELPID_TEXT_DimTermWidth	    TPC_DIMTERM
#define HELPID_TEXT_DimTermHeight	    TPC_DIMTERM
#define HELPID_OPTBUT_DimTermArrowhead	    TPC_DIMTERM
#define HELPID_TEXT_DimStackOffset	    TPC_DIMGEOM
#define HELPID_TEXT_DimMinimumLeader	    TPC_DIMGEOM
#define HELPID_TEXT_DimCenterSize	    TPC_DIMGEOM

/*----------------------------------------------------------------------+
|    Help ids used in Dimension TextFormat dialog			|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimTextFormat	    0
#define HELPID_OPTBUT_DimAECLabels	    TPC_DIMAEC
#define HELPID_OPTBUT_DimLengthFormat	    TPC_DIMFORMAT
#define HELPID_OPTBUT_DimLengthUnits	    TPC_DIMUNITS
#define HELPID_OPTBUT_DimEnglishPrecision   TPC_DIMACCURACY
#define HELPID_OPTBUT_DimMetricPrecision    TPC_DIMACCURACY
#define HELPID_OPTBUT_DimAngularPrecision   TPC_DIMANGLE
#define HELPID_OPTBUT_DimAngleFormat	    TPC_DIMANGLE
#define HELPID_OPTBUT_DimAngleMeasure	    0
#define HELPID_TEXT_DimScaleFactor	    0
#define HELPID_TGLBUT_DimLeadingZero	    TPC_DIMZERO
#define HELPID_TGLBUT_DimTrailingZero	    TPC_DIMZERO
#define HELPID_TGLBUT_DimCommaDecimal	    TPC_DIMCOMMA

/*----------------------------------------------------------------------+
|    Help ids used in Dimension Symbols dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimSymbols 	    0
#define HELPID_TEXT_DimSymbPrefixChar	    0
#define HELPID_TEXT_DimSymbPrefixFont	    0
#define HELPID_TEXT_DimSymbPrefixCell	    0
#define HELPID_OPTBUT_DimSymbPrefix	    0
#define HELPID_TEXT_DimSymbSuffixChar	    0
#define HELPID_TEXT_DimSymbSuffixFont	    0
#define HELPID_TEXT_DimSymbSuffixCell	    0
#define HELPID_OPTBUT_DimSymbSuffix	    0
#define HELPID_TEXT_DimSymbDiameterChar	    0
#define HELPID_TEXT_DimSymbDiameterFont	    0
#define HELPID_OPTBUT_DimSymbDiameter	    0
#define HELPID_TEXT_DimSymbPlusMinusChar    0
#define HELPID_TEXT_DimSymbPlusMinusFont    0
#define HELPID_OPTBUT_DimSymbPlusMinus	    0
#define HELPID_TEXT_DimSymbMainPrefixChar   0
#define HELPID_TEXT_DimSymbMainSuffixChar   0
#define HELPID_TEXT_DimSymbTolrPrefixChar   0
#define HELPID_TEXT_DimSymbTolrSuffixChar   0
#define HELPID_TEXT_DimSymbUpperPrefixChar  0
#define HELPID_TEXT_DimSymbUpperSuffixChar  0
#define HELPID_TEXT_DimSymbLowerPrefixChar  0
#define HELPID_TEXT_DimSymbLowerSuffixChar  0

/*----------------------------------------------------------------------+
|    Help ids used in Dimension Template dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimTemplate 	    0
#define HELPID_OPTBUT_DimTmplLeftTerm	    0
#define HELPID_OPTBUT_DimTmplRightTerm	    0
#define HELPID_OPTBUT_DimTmplFirstTerm	    0
#define HELPID_OPTBUT_DimTmplJointTerm	    0
#define HELPID_OPTBUT_DimTmplRadialLeader   0
#define HELPID_OPTBUT_DimTmplPrefix	    0
#define HELPID_OPTBUT_DimTmplSuffix	    0
#define HELPID_OPTBUT_DimTmplVertText	    0
#define HELPID_TGLBUT_DimTmplLeftWitness    0
#define HELPID_TGLBUT_DimTmplRightWitness   0
#define HELPID_TGLBUT_DimTmplStack	    0
#define HELPID_TGLBUT_DimTmplArcSymbol	    0
#define HELPID_TGLBUT_DimTmplCenterMark	    TPC_DIMCEN
#define HELPID_OPTBUT_DimensionTools	    0
#define HELPID_OPTBUT_DimTmplCommand	    0

/*----------------------------------------------------------------------+
|    Help ids used in Dimension Terminators dialog      		|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimTerminators 	    0
#define HELPID_TEXT_DimTermArrowChar	    0
#define HELPID_TEXT_DimTermArrowFont	    0
#define HELPID_TEXT_DimTermArrowCell	    0
#define HELPID_OPTBUT_DimTermArrow	    0
#define HELPID_TEXT_DimTermStrokeChar	    0
#define HELPID_TEXT_DimTermStrokeFont	    0
#define HELPID_TEXT_DimTermStrokeCell	    0
#define HELPID_OPTBUT_DimTermStroke	    0
#define HELPID_TEXT_DimTermOriginChar	    0
#define HELPID_TEXT_DimTermOriginFont	    0
#define HELPID_TEXT_DimTermOriginCell	    0
#define HELPID_OPTBUT_DimTermOrigin	    0
#define HELPID_TEXT_DimTermDotChar	    0
#define HELPID_TEXT_DimTermDotFont	    0
#define HELPID_TEXT_DimTermDotCell	    0
#define HELPID_OPTBUT_DimTermDot	    0

/*----------------------------------------------------------------------+
|    Help ids used in Dimension Placement dialog			|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimPlacement 	    0
#define HELPID_OPTBUT_DimTextOrientation    TPC_DIMORIENT
#define HELPID_OPTBUT_DimJustify	    0
#define HELPID_OPTBUT_DimTextPlacement	    0
#define HELPID_OPTBUT_DimTextFrame	    0
#define HELPID_OPTBUT_DimAlignMode	    0
#define HELPID_TGLBUT_DimPlaceRefUnits	    0

#define HELPID_TGLBUT_DimPlaceRelative	    TPC_DIMREL
#define HELPID_TGLBUT_DimUnderlineText	    TPC_DIMUL
#define HELPID_PULLDOWN_DimStyles	    0
#define HELPID_PULLDOWN_DimStySelection	    0
#define HELPID_PULLDOWN_DimStyEdit	    TPC_EDDIMSTYLE
#define HELPID_PULLDOWN_DimDialogs	    TPC_DIMSETTINGS  /* ?? */
#define HELPID_PULLDOWN_DimSettingsAttr	    0
#define HELPID_PULLDOWN_DimSettingsGeom	    0
#define HELPID_PULLDOWN_DimSettingsText	    0
#define HELPID_PULLDOWN_DimSettingsTol	    0
#define HELPID_PULLDOWN_DimSetGeomTol	    0
#define HELPID_PULLDOWN_DimSetSymbols	    0
#define HELPID_PULLDOWN_DimSettingsTerm	    0
#define HELPID_PULLDOWN_DimSettingsTool	    0




/*----------------------------------------------------------------------+
|    Help ids used in Dimension Tolerance dialog        		|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DimTolerance	    0
#define HELPID_TGLBUT_DimTolerance	    TPC_DIMTOLGEN
#define HELPID_OPTBUT_DimToleranceMode	    TPC_DIMTOLTYPE
#define HELPID_TEXT_DimUpperTolerance	    0
#define HELPID_TEXT_DimLowerTolerance	    0
#define HELPID_TEXT_DimTolTextScale	    0

/*----------------------------------------------------------------------+
|    Help ids used in Camera dialog     				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Camera		    0
#define HELPID_OPTBUT_CameraViewNumber	    0
#define HELPID_TEXT_CameraLensAngle	    0
#define HELPID_TEXT_CameraLensLength	    0
#define HELPID_OPTBUT_CameraLens	    0
#define HELPID_PSHBUT_CameraApply	    0

/*----------------------------------------------------------------------+
|    Help ids used in CellMaint dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_CellMaintenance	    0
#define HELPID_TEXT_LibraryName		    0
#define HELPID_TGLBUT_CellShared	    0
#define HELPID_OPTBUT_CellSort		    0
#define HELPID_LISTBOX_CellList		    0
#define HELPID_GEN_Cell			    0
#define HELPID_PSHBUT_Edit		    0
#define HELPID_PSHBUT_Delete		    0
#define HELPID_PSHBUT_Create		    0
#define HELPID_PSHBUT_Active		    0
#define HELPID_PSHBUT_Term		    0
#define HELPID_PSHBUT_Point		    0
#define HELPID_PSHBUT_Pattrn		    0
#define HELPID_PSHBUT_Share		    0

/*----------------------------------------------------------------------+
|    Help ids used in CellEdit dialog  	    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_CellEdit		    0
#define HELPID_TEXT_EditCellName	    0
#define HELPID_TEXT_EditCellDescr	    0
#define HELPID_PSHBUT_OK		    0
#define HELPID_PSHBUT_Cancel		    0

/*----------------------------------------------------------------------+
|    Help ids used in CellCreate dialog	    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_CellCreate	    0
#define HELPID_TEXT_CreateCellName	    0
#define HELPID_TEXT_CreateCellDescr	    0
#define HELPID_OPTBUT_CellType		    0
#define HELPID_PSHBUT_OK		    0
#define HELPID_PSHBUT_Cancel		    0

/*----------------------------------------------------------------------+
|    Help ids used in CommandWindow dialog    	    	    	       	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_CommandWindow	    0
#define HELPID_DIALOG_CommandWindowNoMenu   0
#define HELPID_DIALOG_CommandWindow3By2	    0

/*----------------------------------------------------------------------+
|    Help ids used in ColorSquare dialog    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ColorSquare	    TPC_COLORMOD
#define HELPID_GEN_UpdateCellDisplay	    0
#define HELPID_GEN_ColorSquareDisplay	    0
#define HELPID_GEN_WedgeDisplay		    0
#define HELPID_TEXT_ColorPal_Hue	    0
#define HELPID_TEXT_ColorPal_Sat	    0
#define HELPID_TEXT_ColorPal_Value	    0
#define HELPID_TEXT_ColorPal_Red	    0
#define HELPID_TEXT_ColorPal_Green	    0
#define HELPID_TEXT_ColorPal_Blue	    0

/*----------------------------------------------------------------------+
|    Help ids used in ColorPalette dialog    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ColorPalette	    0
#define HELPID_PULLDOWN_ColorPaletteFile    0
#define HELPID_PULLDOWN_ColorPalOpen	    0
#define HELPID_PULLDOWN_ColorPalSaveAs	    0
#define HELPID_GEN_ColorPaletteDisplay	    0
#define HELPID_PSHBUT_ColorPalRevert	    0
#define HELPID_PSHBUT_ColorPalDefault	    0
#define HELPID_PSHBUT_ColorPalAttach	    0

/*----------------------------------------------------------------------+
|    Help ids used in DBase dialog    	    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DBSettings	    0
#define HELPID_OPTBUT_DBLinkMode	    TPC_LINKMODE
#define HELPID_TEXT_DBDasType		    0
#define HELPID_TGLBUT_DBDeleteLinked	    0
#define HELPID_TGLBUT_DBFormsMode	    0
#define HELPID_TGLBUT_DBConfirmMode	    0

/*----------------------------------------------------------------------+
|    Help ids used in DesignOptions dialog    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DesignOptions	    0
#define HELPID_PSHBUT_DOptDataReadout	    0
#define HELPID_PSHBUT_DOptWorkingUnits	    0
#define HELPID_PSHBUT_DOptAngle		    0
#define HELPID_PSHBUT_DOptScale		    0
#define HELPID_PSHBUT_DOptReferenceFile	    0
#define HELPID_PSHBUT_DOptCellLibrary	    0
#define HELPID_PSHBUT_DOptSavedViews	    0
#define HELPID_PSHBUT_DOptACS		    0
#define HELPID_PSHBUT_DOptEditUCI    	    0

/*----------------------------------------------------------------------+
|    Help ids used in Digitizing dialog    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Digitizing	    0
#define HELPID_PULLDOWN_DigitizingTablet    TPC_TABLET	/* MainMenu */
#define HELPID_PULLDOWN_DigPartition	    0
#define HELPID_PULLDOWN_DigSetup	    0
#define HELPID_PULLDOWN_MenuCheck	    0
#define HELPID_PULLDOWN_DigButtonMenu	    0
#define HELPID_TEXT_StreamDelta		    0
#define HELPID_TEXT_StreamTolerance	    0
#define HELPID_TEXT_StreamArea		    0
#define HELPID_TEXT_StreamAngle		    0
#define HELPID_TGLBUT_StrDsply		    0

/*----------------------------------------------------------------------+
|    Help ids used in Image dialogs    	    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Display		    0
#define HELPID_DIALOG_Image		    0
#define HELPID_DIALOG_ImageSave		    0
#define HELPID_OPTBUT_DisplayType	    0
#define HELPID_OPTBUT_ImageType		    0
#define HELPID_OPTBUT_ImageRender	    0
#define HELPID_TEXT_ImageXRes		    0
#define HELPID_TEXT_ImageYRes		    0
#define HELPID_TGLBUT_ImageStereo	    0

/*----------------------------------------------------------------------+
|    Help ids used in EnvVariables dialog    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_EnvVariables	    0
#define HELPID_LISTBOX_EnvVariables	    0
#define HELPID_TEXT_EnvVariablesName	    0
#define HELPID_TEXT_EnvVariablesString	    0
#define HELPID_PSHBUT_EnvVariablesNew	    0
#define HELPID_PSHBUT_EnvVariablesDelete    0
#define HELPID_PSHBUT_EnvVariablesSave	    0

/*----------------------------------------------------------------------+
|    Help ids used in Font dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Font		    0
#define HELPID_LISTBOX_Font		    0
#define HELPID_GEN_Font			    0

/*----------------------------------------------------------------------+
|    Help ids used in FunctionKeys dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_FunctionKeys	    0
#define HELPID_PULLDOWN_FunctionKeyFile	    0
#define HELPID_PULLDOWN_FnkeyFileOpen	    0
#define HELPID_PULLDOWN_FnkeyFileSaveAs	    0
#define HELPID_PULLDOWN_FnKeyFileSave	    0

/*----------------------------------------------------------------------+
|    Help ids used in FunctionKeys dialog				|
+----------------------------------------------------------------------*/
#define	HELPID_DIALOG_GridSettings	    0
#define HELPID_OPTBUT_GridConfig	    0
#define HELPID_TEXT_MasterPerGrid	    0
#define HELPID_TEXT_ReferenceGrid	    0
#define HELPID_TEXT_GridRatio		    0

/*----------------------------------------------------------------------+
|    Help ids used in Tool Palettes    	    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_PALETTE_ThreeD		    TPC_3D_SPECIFIC
#define HELPID_PALETTE_ACS		    TPC_ACS
#define HELPID_PALETTE_Dimensioning	    0
#define HELPID_PALETTE_LinearDimen	    TPC_DIMLINEAR
#define HELPID_PALETTE_AngularDimen	    TPC_DIMANGULAR
#define HELPID_PALETTE_RadialDimen	    TPC_DIMRADIAL
#define HELPID_PALETTE_MiscDimen	    0
#define HELPID_PALETTE_DataBase		    TPC_DATABASE
#define HELPID_PALETTE_Fence		    TPC_FENCE
#define HELPID_PALETTE_PlaceFence	    TPC_FENCE
#define HELPID_PALETTE_FenceCopy	    TPC_FENCE
#define HELPID_PALETTE_FenceChange	    TPC_FENCE
#define HELPID_PALETTE_FenceMirror	    TPC_FENCE
#define HELPID_PALETTE_FenceDelete	    TPC_FENCE
#define HELPID_PALETTE_Main		    0
#define HELPID_PALETTE_Line		    TPC_LINE
#define HELPID_PALETTE_LineString	    0
#define HELPID_PALETTE_Polygon		    TPC_POLYGON
#define HELPID_PALETTE_Fillet		    TPC_FILLETPARABOLA
#define HELPID_PALETTE_Circle		    TPC_CIRCLE
#define HELPID_PALETTE_Arc		    TPC_ARC
#define HELPID_PALETTE_EnterData	    TPC_ENTERDATACREATE
#define HELPID_PALETTE_Text		    TPC_TEXT
#define HELPID_PALETTE_Point		    TPC_POINT
#define HELPID_PALETTE_Cell		    TPC_CELLS
#define HELPID_PALETTE_Change		    TPC_CHANGE
#define HELPID_PALETTE_CopyElement	    TPC_COPYMOVE
#define HELPID_PALETTE_MirrorElement	    TPC_MIRROR
#define HELPID_PALETTE_Modify		    TPC_MODIFYEXTEND
#define HELPID_PALETTE_Chain		    TPC_CHAINSHAPE
#define HELPID_PALETTE_Drop		    TPC_DROP
#define HELPID_PALETTE_View		    0
#define HELPID_PALETTE_Measure		    TPC_MEASURE
#define HELPID_PALETTE_Patterning	    TPC_PATTERN
#define HELPID_PALETTE_ReferenceFile	    TPC_REFERENCE
#define HELPID_PALETTE_MultilineJoin	    0
#define HELPID_PALETTE_Splines		    0
#define HELPID_PALETTE_Splines3D		0
#define HELPID_PALETTE_Splines2D3D		0
#define HELPID_PALETTE_SpaceCurve		0
#define HELPID_PALETTE_Surface		    0
#define HELPID_PALETTE_DerSurf		    0
#define HELPID_PALETTE_Change3D		    0

/*----------------------------------------------------------------------+
|    Help ids used For IconCmds on Splines Palette			|
+----------------------------------------------------------------------*/
#define HELPID_ICMD_PlCrvPoles		    0
#define HELPID_ICMD_PlCrvPts		    0
#define HELPID_ICMD_PlCrvLsq		    0
#define HELPID_ICMD_CnsCrvPoles		    0
#define HELPID_ICMD_CnsCrvPts		    0
#define HELPID_ICMD_CnsCrvLsq		    0
#define HELPID_ICMD_PlSprlByAngle	    0
#define HELPID_ICMD_PlSprlByLength	    0
#define HELPID_ICMD_PlSprlByEndpts	    0
#define HELPID_ICMD_PlParab		    0
#define HELPID_ICMD_PlHelix		    0
#define HELPID_ICMD_PlSurfPoles		    0
#define HELPID_ICMD_PlSurfPts		    0
#define HELPID_ICMD_PlSurfLsq		    0
#define HELPID_ICMD_CnsSurfPoles	    0
#define HELPID_ICMD_CnsSurfPts		    0
#define HELPID_ICMD_CnsSurfLsq		    0
#define HELPID_ICMD_CnsSurfProj		    0
#define HELPID_ICMD_CnsSurfRevolv	    0
#define HELPID_ICMD_CnsSurfTube		    0
#define HELPID_ICMD_CnsSurfSkin		    0
#define HELPID_ICMD_CnsSurfXSect	    0
#define HELPID_ICMD_CnsSurfEdge		    0
#define HELPID_ICMD_CnsConvCopy		    0
#define HELPID_ICMD_CnsConvOrig		    0
#define HELPID_ICMD_ChgPoly		    0
#define HELPID_ICMD_ChgOrder		    0
#define HELPID_ICMD_ChgUOrder		    0
#define HELPID_ICMD_ChgVOrder		    0
#define HELPID_ICMD_ChgURules		    0
#define HELPID_ICMD_ChgVRules		    0
#define HELPID_ICMD_ExtrSrfBnd		    0
#define HELPID_ICMD_ImpsSrfBnd		    0
#define HELPID_ICMD_Fake		    0

/*----------------------------------------------------------------------+
|    Help ids used For 
+----------------------------------------------------------------------*/

/*----------------------------------------------------------------------+
|    Help ids used For unclaimed dialogs				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_StdFileSeedCreate	    0
#define HELPID_DIALOG_StdFileCreate	    0
#define HELPID_DIALOG_Digitize		    0
#define HELPID_DIALOG_Import		    0
#define HELPID_DIALOG_Export		    0
#define HELPID_DIALOG_FileUtilities	    0
#define HELPID_DIALOG_SplinePrefs	    0
