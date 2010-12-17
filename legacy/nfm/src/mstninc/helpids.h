/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   helpids.h  $						|
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $		|
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
#ifndef __helpidsH__
#define __helpidsH--

#include <mshelp.h>

/*----------------------------------------------------------------------+
|									|
|    PULLDOWN MENU HelpIds						|
|									|
+----------------------------------------------------------------------*/
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
|									|
|    DIALOG BOX HelpIds							|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Dialogs launched from the File Pulldown				|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Help ids used in CnvDgn dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Convert2Dto3D	    0
#define HELPID_DIALOG_Convert3Dto2D	    0
#define HELPID_OPTBUT_InputSource	    0
#define HELPID_OPTBUT_ElevationType	    0
#define HELPID_TGLBUT_ReferenceFiles	    0
#define HELPID_TEXT_ZElevation		    0

/*----------------------------------------------------------------------+
|    Help ids used in RMan dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_RmanMain		    0
#define HELPID_DIALOG_ShadOpts		    0
#define HELPID_PSHBUT_CreateFile	    0
#define HELPID_PSHBUT_ShadingOptions	    0
#define HELPID_PSHBUT_shDraft		    0
#define HELPID_PSHBUT_shFinal		    0
#define HELPID_TEXT_XRes		    0
#define HELPID_TEXT_YRes		    0
#define HELPID_TEXT_ShRate		    0
#define HELPID_TEXT_ShGrid		    0
#define HELPID_TEXT_ShTexMem		    0
#define HELPID_TEXT_ShEyeSplits		    0
#define HELPID_TEXT_ShPixSamp		    0
#define HELPID_TEXT_ShBucket		    0
#define HELPID_TEXT_ShShadRes		    0
#define HELPID_TGLBUT_GenerateShadowMap	    0
#define HELPID_TGLBUT_StrokeLinearElements  0
#define HELPID_OPTBUT_OutputFormat	    0
#define HELPID_OPTBUT_BinAscii		    0
#define HELPID_OPTBUT_ShType		    0
#define HELPID_OPTBUT_ShHider		    0

/*----------------------------------------------------------------------+
|    Help ids used in DXFExport dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_DXFExport		    0
#define HELPID_DIALOG_DXFImport		    0
#define HELPID_DIALOG_DXFExEConfigFile	    0
#define HELPID_DIALOG_DXFImEConfigFile	    0
#define HELPID_DIALOG_DXFEditTable	    0
#define HELPID_DIALOG_DXFEditTable3	    0
#define HELPID_LISTBOX_DXFTables	    0
#define HELPID_LISTBOX_DXFTableEdit	    0
#define HELPID_LISTBOX_DXFTableEdit3	    0
#define HELPID_OPTBUT_DXFUnits		    0
#define HELPID_OPTBUT_DXRFAttribType	    0
#define HELPID_PSHBUT_ChooseDXFConfig	    0
#define HELPID_PSHBUT_DXFEdit		    0
#define HELPID_PSHBUT_DXFSaveAs		    0
#define HELPID_PSHBUT_DXFAddEntry	    0
#define HELPID_PSHBUT_DXFDelEntry	    0
#define HELPID_TGLBUT_DXFProcessHeader	    0
#define HELPID_TGLBUT_DXFShowProgress	    0
#define HELPID_TGLBUT_DXFUseCellDefinition  0
#define HELPID_TGLBUT_DXFProcessRefFiles    0
#define HELPID_TGLBUT_DXFUseSharedCells	    0
#define HELPID_TEXT_DXFResolution	    0
#define HELPID_TEXT_DXFEditCol1		    0
#define HELPID_TEXT_DXFEditCol2		    0
#define HELPID_TEXT_DXFEditCol3		    0

/*----------------------------------------------------------------------+
|    Help ids used in Edges dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Edges		    0
#define HELPID_TEXT_EdgesLevel		    0
#define HELPID_TEXT_EdgesColor		    0
#define HELPID_TEXT_EdgesStyle		    0
#define HELPID_TEXT_EdgesWeight		    0
#define HELPID_TEXT_PolygonResolution	    0
#define HELPID_TEXT_ArcMinimum		    0
#define HELPID_TEXT_ArcMaximum		    0
#define HELPID_OPTBUT_Dimension		    0
#define HELPID_OPTBUT_MeshProfile	    0
#define HELPID_OPTBUT_EdgesStyle	    0
#define HELPID_OPTBUT_EdgesWeight	    0
#define HELPID_COLPCK_EdgesColor	    0
#define HELPID_TGLBUT_Intersections	    0
#define HELPID_TGLBUT_IncludeHidden	    0
#define HELPID_TGLBUT_LevelOverride	    0
#define HELPID_TGLBUT_ColorOverride	    0
#define HELPID_TGLBUT_StyleOverride	    0
#define HELPID_TGLBUT_WeightOverride	    0

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
|    Help ids used in RefAttach dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ReferenceAttach	    0
#define HELPID_TEXT_RefAttachLogicalName    TPC_REFATTACHINFO
#define HELPID_TEXT_RefAttachDesc	    TPC_REFATTACHINFO
#define HELPID_TEXT_RefAttachMastScale	    TPC_REFATTACHINFO
#define HELPID_TEXT_RefAttachRefScale	    TPC_REFATTACHINFO
#define HELPID_OPTBUT_RefAttachMode	    0
#define HELPID_LISTBOX_RefAttachViews	    0

/*----------------------------------------------------------------------+
|    Help ids used in RefFile dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ReferenceFile	    0
#define HELPID_DIALOG_ReferenceRotate	    0
#define HELPID_DIALOG_ReferenceScale	    0
#define HELPID_PULLDOWN_RefFileTools	    0	/* MainMenu */
#define HELPID_PULLDOWN_RefFileToolAttach   0
#define HELPID_PULLDOWN_RefFileToolDetach   0
#define HELPID_PULLDOWN_RefFileToolReload   0
#define HELPID_PULLDOWN_RefFileMove	    0
#define HELPID_PULLDOWN_RefFileScale	    0
#define HELPID_PULLDOWN_RefFileRotate	    0
#define HELPID_PULLDOWN_RefFileMirHorz	    0
#define HELPID_PULLDOWN_RefFileMirVert	    0
#define HELPID_PULLDOWN_RefFileClipBnd	    0
#define HELPID_PULLDOWN_RefFileClipMask	    0
#define HELPID_PULLDOWN_RefFileClipFront    0
#define HELPID_PULLDOWN_RefFileClipBack	    0
#define HELPID_PULLDOWN_RefFileSettings	    0	/* MainMenu */
#define HELPID_PULLDOWN_RefFileSetLevel	    TPC_REFLEVELS
#define HELPID_PULLDOWN_RefFileSetLevSymb   TPC_REFLVLSYMB
#define HELPID_LISTBOX_ReferenceFile	    0
#define HELPID_TEXT_RefFileDescr	    TPC_REFATTACHINFO
#define HELPID_TGLBUT_RefFileDisplay	    0
#define HELPID_TGLBUT_RefFileSnap	    0
#define HELPID_TGLBUT_RefFileLocate	    0
#define HELPID_PSHBUT_RefFileRotateOK	    0

/*----------------------------------------------------------------------+
|    Help ids used in ReferenceLevels dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ReferenceLevels	    0
#define HELPID_PSHBUT_ApplyRefLevelView	    0
#define HELPID_PSHBUT_AllRefLevelViews	    0
#define HELPID_OPTBUT_RefLevelsView	    0
#define HELPID_LEVMAP_ReferenceLevels	    0

/*----------------------------------------------------------------------+
|    Help ids used in PreviewPlot dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_PreviewPlot	    0
#define HELPID_DIALOG_ShowPlotter	    0
#define HELPID_DIALOG_PlotPageSize	    TPC_PAGESET
#define HELPID_DIALOG_PlotOptions	    TPC_PLOTOPT
#define HELPID_GEN_PlotPlacement	    0
#define HELPID_OPTBUT_PlotSelectView	    0
#define HELPID_OPTBUT_PlotPgSzName	    0
#define HELPID_OPTBUT_PlotPgSzManOrigin	    0
#define HELPID_PSHBUT_PlotSetPageSize	    TPC_PAGESET
#define HELPID_PSHBUT_PlotMaximize	    TPC_MAXPLOT
#define HELPID_PSHBUT_PlotCenter	    TPC_CTRPLOT
#define HELPID_PSHBUT_PlotOptions	    TPC_PLOTOPT
#define HELPID_PSHBUT_PlotDone		    0
#define HELPID_PSHBUT_PlotDoPlot	    TPC_PLOTTHIS
#define HELPID_PSHBUT_PlotPlotters	    TPC_PLOTTERS
#define HELPID_TEXT_PlotDrawSetWidth	    TPC_DRAWSET
#define HELPID_TEXT_PlotDrawSetHeight	    TPC_DRAWSET
#define HELPID_TEXT_PlotDrawSetScale	    TPC_DRAWSET
#define HELPID_TEXT_PlotOriginWidth	    TPC_PLOTORIGIN
#define HELPID_TEXT_PlotOriginHeight	    TPC_PLOTORIGIN
#define HELPID_TEXT_PlotOptComment	    TPC_PLOTOPT
#define HELPID_TEXT_PlotWidth		    0
#define HELPID_TEXT_PlotHeight		    0
#define HELPID_TEXT_PlotPageName	    0
#define HELPID_TEXT_PlotPgSzUnits	    0
#define HELPID_TEXT_PlotPgSzWidthDots	    0
#define HELPID_TEXT_PlotPgSzHeightDots	    0
#define HELPID_TEXT_PlotPgSzWidth	    0
#define HELPID_TEXT_PlotPgSzHeight	    0
#define HELPID_TEXT_PlotPgSzWidthOffset	    0
#define HELPID_TEXT_PlotPgSzHeightOffset    0
#define HELPID_TEXT_PlotShowCfgName	    0
#define HELPID_TEXT_PlotShowModel	    0
#define HELPID_TEXT_PlotShowPens	    0
#define HELPID_TEXT_PlotChangePens	    0
#define HELPID_TEXT_PlotShowName1	    0
#define HELPID_TEXT_PlotShowSize1	    0
#define HELPID_TEXT_PlotShowNumber1	    0
#define HELPID_TEXT_PlotShowOffset1	    0
#define HELPID_TEXT_PlotShowName2	    0
#define HELPID_TEXT_PlotShowSize2	    0
#define HELPID_TEXT_PlotShowNumber2	    0
#define HELPID_TEXT_PlotShowOffset2	    0
#define HELPID_TEXT_PlotShowName3	    0
#define HELPID_TEXT_PlotShowSize3	    0
#define HELPID_TEXT_PlotShowNumber3	    0
#define HELPID_TEXT_PlotShowOffset3	    0
#define HELPID_TEXT_PlotShowName4	    0
#define HELPID_TEXT_PlotShowSize4	    0
#define HELPID_TEXT_PlotShowNumber4	    0
#define HELPID_TEXT_PlotShowOffset4	    0
#define HELPID_TEXT_PlotShowName5	    0
#define HELPID_TEXT_PlotShowSize5	    0
#define HELPID_TEXT_PlotShowNumber5	    0
#define HELPID_TEXT_PlotShowOffset5	    0
#define HELPID_TGLBUT_PlotUseFence	    TPC_PLOTOPT
#define HELPID_TGLBUT_PlotOptDrawBorder	    TPC_PLOTOPT
#define HELPID_TGLBUT_PlotOptRotate	    TPC_PLOTOPT
#define HELPID_TGLBUT_PlotOptDrawFence	    TPC_PLOTOPT

/*----------------------------------------------------------------------+
|    Dialogs launched from the Element Pulldown				|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Help ids used in Analyze dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Analyze		    0
#define HELPID_TEXT_ShowLevel		    0
#define HELPID_TEXT_ShowColor		    0
#define HELPID_TEXT_ShowWeight		    0
#define HELPID_TEXT_ShowStyle		    0
#define HELPID_TEXT_ShowGgroup		    0
#define HELPID_TGLBUT_ShowFill		    0
#define HELPID_PSHBUT_Previous		    0
#define HELPID_PSHBUT_Next		    0
#define HELPID_PSHBUT_Definition	    0
#define HELPID_PSHBUT_Instance		    0
#define HELPID_PSHBUT_AnalyzeApply	    0
#define HELPID_COLPCK_ShowColor		    0
#define HELPID_TEXT_MlineFillColor	    0
#define HELPID_COLPCK_MlineFillColor	    0
#define HELPID_OPTBUT_ShowClass		    0
#define HELPID_OPTBUT_ShowPropS		    0
#define HELPID_OPTBUT_ShowStyle		    0
#define HELPID_OPTBUT_ShowWeight	    0
#define HELPID_OPTBUT_ShowPropH		    0
#define HELPID_OPTBUT_ShowPropP		    0
#define HELPID_OPTBUT_ShowPropR		    0
#define HELPID_OPTBUT_ShowPropA		    0
#define HELPID_OPTBUT_ShowPropM		    0
#define HELPID_OPTBUT_ShowPropN		    0
#define HELPID_OPTBUT_ShowPropL		    0
#define HELPID_OPTBUT_ShowCellType	    0
#define HELPID_LISTBOX_ElementDataList	    0

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
|    Help ids used in Geometric Tolerancing dialog 	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_GeometricTolerance    0
#define HELPID_PULLDOWN_GeomTolFonts	    0
#define HELPID_PULLDOWN_GeomTolFontsAnsi    0
#define HELPID_PULLDOWN_GeomTolFontFeatCtrl 0
#define HELPID_GEN_LeftBracket		    0
#define HELPID_GEN_RightBracket		    0
#define HELPID_GEN_PipeSymbol		    0
#define HELPID_GEN_PlusSign		    0
#define HELPID_GEN_LetterA		    0
#define HELPID_GEN_LetterB		    0
#define HELPID_GEN_LetterC		    0
#define HELPID_GEN_LetterD		    0
#define HELPID_GEN_LetterE		    0
#define HELPID_GEN_LetterF		    0
#define HELPID_GEN_LetterG		    0
#define HELPID_GEN_LetterH		    0
#define HELPID_GEN_LetterI		    0
#define HELPID_GEN_LetterJ		    0
#define HELPID_GEN_LetterK		    0
#define HELPID_GEN_LetterL		    0
#define HELPID_GEN_LetterM		    0
#define HELPID_GEN_LetterN		    0
#define HELPID_GEN_LetterO		    0
#define HELPID_GEN_LetterP		    0
#define HELPID_GEN_LetterQ		    0
#define HELPID_GEN_LetterR		    0
#define HELPID_GEN_LetterS		    0
#define HELPID_GEN_LetterT		    0
#define HELPID_GEN_LetterU		    0
#define HELPID_GEN_LetterV		    0
#define HELPID_GEN_LetterW		    0
#define HELPID_GEN_LetterX		    0

/*----------------------------------------------------------------------+
|    Help ids used in multiline dialogs					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Multiline		    0
#define HELPID_COLPCK_MLineColor	    0
#define HELPID_COLPCK_MLineFill		    0
#define HELPID_GEN_MLineDraw		    0
#define HELPID_LISTBOX_LMineLines	    0
#define HELPID_PULLDOWN_MLineStyle	    0	/* MainMenu */
#define HELPID_PULLDOWN_MLineSelect	    0
#define HELPID_PULLDOWN_LMineEdit	    TPC_EDMLINESTYLE
#define HELPID_OPTBUT_MLineType		    0
#define HELPID_OPTBUT_MLineStyle	    0
#define HELPID_OPTBUT_MLineWeight	    0
#define HELPID_OPTBUT_MlineClass	    0
#define HELPID_PSHBUT_MlineAddLine	    0
#define HELPID_PSHBUT_MLineDelLine	    0
#define HELPID_TEXT_MlineOffset		    0
#define HELPID_TEXT_MLineColor		    0
#define HELPID_TEXT_MLineStyle		    0
#define HELPID_TEXT_MLineWeight		    0
#define HELPID_TEXT_MLineFill		    0
#define HELPID_TEXT_MLineLevel		    0
#define HELPID_TEXT_MLineSCapAngle	    TPC_MLINECAP
#define HELPID_TEXT_MLineECapAngle	    TPC_MLINECAP
#define HELPID_TGLBUT_MLineDefColor	    0
#define HELPID_TGLBUT_MLineDefStyle	    0
#define HELPID_TGLBUT_MLineDefWeight	    0
#define HELPID_TGLBUT_MLineDispJoints	    TPC_MLINEJT
#define HELPID_TGLBUT_MLineECapLine	    TPC_MLINECAP
#define HELPID_TGLBUT_MLineECapArc	    TPC_MLINECAP
#define HELPID_TGLBUT_MLineECapInArc	    TPC_MLINECAP
#define HELPID_TGLBUT_MLineSCapLine	    TPC_MLINECAP
#define HELPID_TGLBUT_MLineSCapArc	    TPC_MLINECAP
#define HELPID_TGLBUT_MLineSCapInArc	    TPC_MLINECAP
#define HELPID_TGLBUT_MLineDefFill	    0
#define HELPID_TGLBUT_MLineDefLevel	    0
#define HELPID_TGLBUT_MLineDefClass	    0

/*----------------------------------------------------------------------+
|    Help ids used in StyleEdit dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_StyleEdit		    0
#define HELPID_DIALOG_StyleSelect	    0
#define HELPID_LISTBOX_StyleList	    0
#define HELPID_LISTBOX_StyleSelectList	    0
#define HELPID_PSHBUT_StyleDelete	    0
#define HELPID_PSHBUT_StyleSave		    0
#define HELPID_PSHBUT_StyleLoad		    0
#define HELPID_PSHBUT_StyleNew		    0
#define HELPID_TEXT_StyleName		    0
#define HELPID_TEXT_StyleDescription	    0
#define HELPID_OPTBUT_StyleType		    0
#define HELPID_PULLDOWN_FileMenu	    0
#define HELPID_PULLDOWN_StyleFileNew	    0
#define HELPID_PULLDOWN_StyleFileOpen	    0

/*----------------------------------------------------------------------+
|    Help ids used in Cutter Palette (belongs with Multilines)		|
+----------------------------------------------------------------------*/
#define HELPID_ICMD_JoinCorner		    CUT_JOIN_CORNER
#define HELPID_ICMD_JoinCrossMerge	    CUT_JOIN_CROSS_MERGE
#define HELPID_ICMD_JoinCrossCut	    CUT_JOIN_CROSS_CLOSE
#define HELPID_ICMD_JoinCrossOpen	    CUT_JOIN_CROSS_OPEN
#define HELPID_ICMD_JoinTeeOpen		    CUT_JOIN_TEE_OPEN
#define HELPID_ICMD_JoinTeeClose	    CUT_JOIN_TEE_CLOSE
#define HELPID_ICMD_JoinTeeMerge	    CUT_JOIN_TEE_MERGE
#define HELPID_ICMD_CutSingle		    CUT_CUT_SINGLE
#define HELPID_ICMD_CutAll		    CUT_CUT_ALL
#define HELPID_ICMD_UnCut		    CUT_UNCUT

/*----------------------------------------------------------------------+
|    Help ids used in TextEdit dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_TextEdit		    TPC_TEXTEDIT
#define HELPID_MLTEXT_TextEdit		    0
#define HELPID_PSHBUT_TextEditApply	    0
#define HELPID_PSHBUT_TextEditReset	    0

/*----------------------------------------------------------------------+
|    Help ids used in TextSet dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_TextSettings	    0
#define HELPID_GEN_TextScaleLock	    0
#define HELPID_GEN_TextStringJust	    0
#define HELPID_GEN_TextNodeJust		    0
#define HELPID_OPTBUT_TextStringVertJust    0
#define HELPID_OPTBUT_TextNodeVertJust	    0
#define HELPID_OPTBUT_TextStringHorizJust   0
#define HELPID_OPTBUT_TextNodeHirizJust	    0
#define HELPID_PSHBUT_TextMatch		    0
#define HELPID_TEXT_TextFontNum		    0
#define HELPID_TEXT_TextHeight		    0
#define HELPID_TextWidth		    0
#define HELPID_TEXT_TextLineSpace	    0
#define HELPID_TEXT_TextLineLength	    0
#define HELPID_TGLBUT_TextMirror	    0
#define HELPID_TGLBUT_TextFractions	    0

/*----------------------------------------------------------------------+
|    Help ids used in TextSet dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_TextFileDisplay	    0
#define HELPID_LISTBOX_TextFileDisplay	    0

/*----------------------------------------------------------------------+
|    Dialogs launched from the Settings pulldown			|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Help ids used in Precision dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Precision		    0
#define HELPID_TEXT_PrecisionX		    0
#define HELPID_TEXT_PrecisionY		    0
#define HELPID_TEXT_PrecisionZ		    0
#define HELPID_TEXT_PrecisionDX		    0
#define HELPID_TEXT_PrecisionDY		    0
#define HELPID_TEXT_PrecisionDZ		    0
#define HELPID_TEXT_PrecisionAngle	    0
#define HELPID_TEXT_PrecisionDist	    0
#define HELPID_PRECBUT_X		    0
#define HELPID_PRECBUT_Y		    0
#define HELPID_PRECBUT_Z		    0
#define HELPID_PRECBUT_Dx		    0
#define HELPID_PRECBUT_Dy		    0
#define HELPID_PRECBUT_Dz		    0
#define HELPID_PRECBUT_Angle		    0
#define HELPID_PRECBUT_Dist		    0
#define HELPID_PSHBUT_Precision		    0
#define HELPID_OPTBUT_PrecisionUnits	    0

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
|    Help ids used in ACS dialog, Saved view dialog, and ACS palette	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_RotateACS		    0
#define HELPID_DIALOG_AuxCoordSystems	    0
#define HELPID_DIALOG_RotateACS		    0
#define HELPID_DIALOG_AuxCoordSystems	    0
#define HELPID_LISTBOX_AuxCoordSystems	    0
#define HELPID_PULLDOWN_ACSTools	    0	/* MainMenu */
#define HELPID_PULLDOWN_ACSDefineElement    0	/* Submenu */
#define HELPID_PULLDOWN_ACSDefinePoints	    0	/* Submenu */
#define HELPID_PULLDOWN_ACSDefineView	    0	/* Submenu */
#define HELPID_PULLDOWN_ACSToolsDefElm	    0
#define HELPID_PULLDOWN_ACSToolsDefPnt	    0
#define HELPID_PULLDOWN_ACSToolsDefView	    0
#define HELPID_PULLDOWN_ACSToolsMove	    0
#define HELPID_PULLDOWN_ACSToolsRotate	    0
#define HELPID_PULLDOWN_ACSToolsSelect	    0
#define HELPID_PULLDOWN_ACSTypeRect	    0
#define HELPID_PULLDOWN_ACSTypeCyl	    0
#define HELPID_PULLDOWN_ACSTypeSphere	    0
#define HELPID_OPTBUT_ACSType		    0
#define HELPID_PSHBUT_ACSDelete		    0
#define HELPID_PSHBUT_ACSAttach		    0
#define HELPID_PSHBUT_ACSSave		    0
#define HELPID_PSHBUT_RotateACSAbsolute	    0
#define HELPID_PSHBUT_RotateACSRelative	    0
#define HELPID_TEXT_ACSDescrip		    0
#define HELPID_TEXT_ACSName		    0
#define HELPID_TEXT_ACSOriginX		    0
#define HELPID_TEXT_ACSOriginY		    0
#define HELPID_TEXT_ACSOriginZ		    0
#define HELPID_TEXT_RotateACSX		    0
#define HELPID_TEXT_RotateACSY		    0
#define HELPID_TEXT_RotateACSZ		    0
#define HELPID_DIALOG_SavedViews	    0

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
|    Help ids used in Coordinate Readout dialog    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_CoordReadout	    0
#define HELPID_OPTBUT_CoordFormat	    0
#define HELPID_OPTBUT_CoordAccuracy	    0
#define HELPID_OPTBUT_CoordAngleFormat	    0
#define HELPID_OPTBUT_CoordAngleMode	    0

/*----------------------------------------------------------------------+
|    Help ids used in DBase dialogs					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Dbcheck		    0
#define HELPID_TGLBUT_OracleLink	    0
#define HELPID_TGLBUT_dBaseLink		    0
#define HELPID_TGLBUT_IXLink		    0
#define HELPID_TGLBUT_RISLink		    0
#define HELPID_TGLBUT_InfoOnly		    0
#define HELPID_TGLBUT_Move		    0
#define HELPID_TGLBUT_Detach		    0
#define HELPID_TGLBUT_DeleteEntity	    0
#define HELPID_TGLBUT_File		    0
#define HELPID_TEXT_FileName		    0
#define HELPID_TEXT_NewLevel		    0
#define HELPID_TGLBUT_List		    0
#define HELPID_PSHBUT_Go		    0
#define HELPID_PSHBUT_File		    0

#define HELPID_DIALOG_Dblist		    0
#define HELPID_LISTBOX_Dblist		    0
#define HELPID_OPTBUT_ID		    0
#define HELPID_TEXT_Entity		    0
#define HELPID_TEXT_Mslink		    0
#define HELPID_PSHBUT_DeleteEntity	    0
#define HELPID_DeleteLinkage		    0
#define HELPID_PSHBUT_ReplaceLinkage	    0

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
|    Help ids used in Font dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Font		    0
#define HELPID_LISTBOX_Font		    0
#define HELPID_GEN_Font			    0

/*----------------------------------------------------------------------+
|    Help ids used in GridSettings dialog				|
+----------------------------------------------------------------------*/
#define	HELPID_DIALOG_GridSettings	    0
#define HELPID_OPTBUT_GridConfig	    0
#define HELPID_TEXT_MasterPerGrid	    0
#define HELPID_TEXT_ReferenceGrid	    0
#define HELPID_TEXT_GridRatio		    0

/*----------------------------------------------------------------------+
|    Help ids used in NamedLevels dialog 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_NamedLevels	    0
#define HELPID_LISTBOX_NamedLevelsList	    0
#define HELPID_LISTBOX_NamedLevelsGroups    0
#define HELPID_OPTBUT_NamedLevelSort	    0
#define HELPID_PULLDOWN_NamedLevelsFile	    0
#define HELPID_PULLDOWN_LevNameFileOpen	    0
#define HELPID_PULLDOWN_LevelNameFileSave   0
#define HELPID_PULLDOWN_NamedLevelsLevels   0
#define HELPID_PULLDOWN_LevNameLevelsAdd    0
#define HELPID_PULLDOWN_LevNameLevelsDelete 0
#define HELPID_PULLDOWN_LevNAmeLevelsEdit   0
#define HELPID_PULLDOWN_LevNameGroupsAdd    0
#define HELPID_PULLDOWN_LevNameGroupsDelete 0
#define	HELPID_PULLDOWN_LevNameGroupsEdit   0
#define HELPID_PULLDOWN_LevNameGroupsOpen   0
#define HELPID_PULLDOWN_LevNameDispOn	    0
#define HELPID_PULLDOWN_LevNameDispOff	    0

/*----------------------------------------------------------------------+
|    Help ids used in NamedLevels Edit dialog 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_LevelEdit		    0
#define HELPID_TEXT_LevelEditNumber	    0
#define HELPID_TEXT_LevelEditName	    0
#define HELPID_TEXT_LevelEditComment	    0
#define HELPID_TEXT_GroupEditName	    0

/*----------------------------------------------------------------------+
|    Help ids used in NamedLevels GroupEdit dialog 	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_GroupEdit		    0
#define HELPID_TEXT_GroupEditName	    0

/*----------------------------------------------------------------------+
|    Help ids used in LevelSymbology dialog 	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_LevSymb		    0
#define HELPID_TEXT_LSymColor		    0
#define HELPID_TEXT_LSymStyl		    0
#define HELPID_TEXT_LSymWght		    0
#define HELPID_LISTBOX_LevSymb		    0
#define HELPID_COLPCK_LSym		    0
#define HELPID_OPTBUT_LSymSty		    0
#define HELPID_OPTBUT_LSymWt		    0
#define HELPID_TGLBUT_OverColor		    0
#define HELPID_TGLBUT_OverStyle		    0
#define HELPID_TGLBUT_OverWght		    0
#define HELPID_TGLBUT_SetColor		    0
#define HELPID_TGLBUT_SetStyle		    0
#define HELPID_TGLBUT_SetWght		    0

/*----------------------------------------------------------------------+
|    Help ids used in Locks dialog    	    	    	    	    	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Locks		    0
#define HELPID_DIALOG_BasicLocks	    0
#define HELPID_OPTBUT_LockSnapMode    	    0
#define HELPID_OPTBUT_LockFenceMode	    0
#define HELPID_TEXT_SnapDivisor		    0
#define HELPID_TEXT_AxisStartAngle	    0
#define HELPID_TEXT_AxisIncrement    	    0
#define HELPID_TEXT_UnitDistance	    0
#define HELPID_TGLBUT_LockGrid		    0
#define HELPID_TGLBUT_LockSnap		    0
#define HELPID_TGLBUT_LockAxis		    0
#define HELPID_TGLBUT_LockUnit		    0
#define HELPID_TGLBUT_LockGraphicGroup	    0
#define HELPID_TGLBUT_LockTextNode	    0
#define HELPID_TGLBUT_LockLevel		    0
#define HELPID_TGLBUT_LockBoreSite	    0
#define HELPID_TGLBUT_LockConstructPlane    0
#define HELPID_TGLBUT_LockConstrSnap	    0
#define HELPID_TGLBUT_LockAssociation	    0
#define HELPID_TGLBUT_LockIsometric	    0
#define HELPID_TGLBUT_LockIntersection	    0

/*----------------------------------------------------------------------+
|    Help ids used in Rendering dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Rendering		    0
#define HELPID_GEN_AmbientColor		    0
#define HELPID_GEN_FlashColor		    0
#define HELPID_GEN_SunColor		    0
#define HELPID_TEXT_StrokeTolerance	    0
#define HELPID_TEXT_MaxPolygonSize	    0
#define HELPID_TEXT_AmbientIntensity	    TPC_LITE
#define HELPID_TEXT_FlashIntensity	    TPC_LITE
#define HELPID_TEXT_SolarIntensity	    TPC_LITE
#define HELPID_TEXT_ReSunLonDeg		    TPC_LITE
#define HELPID_TEXT_ReSunLonMin		    TPC_LITE
#define HELPID_TEXT_ReSunLonSec		    TPC_LITE
#define HELPID_TEXT_ReSunLatDeg		    TPC_LITE
#define HELPID_TEXT_ReSunLatMin		    TPC_LITE
#define HELPID_TEXT_ReSunLatSec		    TPC_LITE
#define HELPID_TEXT_ReSunDay		    TPC_LITE
#define HELPID_TEXT_ReSunHour		    TPC_LITE
#define HELPID_TEXT_ReSunMinute		    TPC_LITE
#define HELPID_TGLBUT_ReAmbientOnOff	    TPC_LITE
#define HELPID_TGLBUT_ReFlashOnOff	    TPC_LITE
#define HELPID_TGLBUT_ReSunOnOff	    TPC_LITE
#define HELPID_TGLBUT_UseCurTime	    TPC_LITE
#define HELPID_OPTBUT_ReSunMonth	    TPC_LITE
#define HELPID_OPTBUT_ReSunAmPm		    TPC_LITE
#define HELPID_OPTBUT_ReSunDayStd	    TPC_LITE

/*----------------------------------------------------------------------+
|    Help ids used in WorkingUnits dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_WorkingUnits	    0
#define HELPID_TEXT_WorkUnitsNameMU	    0
#define HELPID_TEXT_WorkUnitsNameSU	    0
#define HELPID_TEXT_WorkUnitsMU		    0
#define HELPID_TEXT_WorkUnitsSU		    0

/*----------------------------------------------------------------------+
|    Help ids used in ToolSettings dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ToolSettings	    0

/*----------------------------------------------------------------------+
|    Dialogs launched from the View Pulldown				|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Help ids used in Camera dialog                             	|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Camera		    0
#define HELPID_OPTBUT_CameraViewNumber	    0
#define HELPID_TEXT_CameraLensAngle	    0
#define HELPID_TEXT_CameraLensLength	    0
#define HELPID_OPTBUT_CameraLens	    0
#define HELPID_PSHBUT_CameraApply	    0

/*----------------------------------------------------------------------+
|    Help ids used in ViewSet dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ViewSettings	    0
#define HELPID_OPTBUT_ViewSettingsNumber    0
#define HELPID_OPTBUT_ViewRenderMode	    0
#define HELPID_PSHBUT_AllViewSettings	    0
#define HELPID_PSHBUT_ApplyViewSettings	    0
#define HELPID_TGLBUT_ViewGrid		    0
#define HELPID_TGLBUT_ViewDimension	    0
#define HELPID_TGLBUT_ViewPattern	    0
#define HELPID_TGLBUT_ViewAreaFill	    0
#define HELPID_TGLBUT_ViewEnterData	    0
#define HELPID_TGLBUT_ViewConstructions	    0
#define HELPID_TGLBUT_ViewLevelSymb	    0
#define HELPID_TGLBUT_ViewTextNodes	    0
#define HELPID_TGLBUT_ViewText		    0
#define HELPID_TGLBUT_ViewFastFont	    0
#define HELPID_TGLBUT_ViewFastCurve	    0
#define HELPID_TGLBUT_ViewLineWeights	    0
#define HELPID_TGLBUT_ViewACSTriad	    0
#define HELPID_TGLBUT_ViewBackground	    0
#define HELPID_TGLBUT_ViewDynamics	    0
#define HELPID_TGLBUT_ViewCamera	    0
#define HELPID_TGLBUT_ViewRefBoundary	    0
#define HELPID_TGLBUT_ViewFastRefClip	    0
#define HELPID_TGLBUT_ViewDepthCueing	    0

/*----------------------------------------------------------------------+
|    Help ids used in ViewLevels dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ViewLevels	    0
#define HELPID_PSHBUT_ApplyViewLevels	    0
#define HELPID_PSHBUT_AllViewLevels	    0
#define HELPID_OPTBUT_ViewLevelsNumber	    0
#define HELPID_LEVMAP_ViewLevels	    0

/*----------------------------------------------------------------------+
|    Help ids used in ViewRotate dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_ViewRotation	    0
#define HELPID_GEN_ViewRotationDisplay	    0
#define HELPID_GEN_ViewRotationSystem	    0
#define HELPID_OPTBUT_StandardViews	    0
#define HELPID_OPTBUT_ViewRotationNumber    0
#define HELPID_PSHBUT_ViewRotationApply	    0
#define HELPID_TEXT_ViewRotationAngle	    0

/*----------------------------------------------------------------------+
|    Help ids used in SavedViews dialog					|
+----------------------------------------------------------------------*/
#define HELPID_LISTBOX_SavedViews	    0
#define HELPID_OPTBUT_SavedViewNum	    0
#define HELPID_OPTBUT_SavedViewDestNum	    0   

/*----------------------------------------------------------------------+
|    Dialogs launched from the User Pulldown				|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Help ids used in User Prefs dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_UserPreferences	    0
#define HELPID_OPTBUT_PrefDefCommand        TPC_DEFTOOL
#define HELPID_OPTBUT_PrefClick		    TPC_SINGLE
#define HELPID_OPTBUT_PrefIconSize	    TPC_TOOLSIZE
#define HELPID_OPTBUT_PrefPointerType	    0
#define HELPID_OPTBUT_PrefPointerSize	    0
#define HELPID_OPTBUT_PrefCompatability	    TPC_COMPAT
#define HELPID_OPTBUT_PrefHighlight	    TPC_TOOLHIGHLIGHT
#define HELPID_OPTBUT_PrefLayout	    TPC_LAYOUT
#define HELPID_TEXT_PrefSmallestText	    0
#define HELPID_TEXT_PrefExactColors	    TPC_XACTCOLORS
#define HELPID_TEXT_PrefMaxRefFiles	    TPC_MAXREF
#define HELPID_TEXT_PrefLocateTolerance	    0
#define HELPID_TEXT_PrefGridPtsView	    0
#define HELPID_TEXT_PrefGridRefsView	    0
#define HELPID_TEXT_PrefEnterDataChar	    0
#define HELPID_TEXT_PrefMemCacheSize	    TPC_MEMORY
#define HELPID_TEXT_PrefMemRscCacheSize	    TPC_MEMORY
#define HELPID_TEXT_PrefMemUndoSize	    TPC_MEMORY
#define HELPID_TEXT_PrefMemTaskSize	    TPC_MEMORY
#define HELPID_TEXT_PrefMemTaskSizeExt	    TPC_MEMORY
#define HELPID_TGLBUT_PrefResetFence	    TPC_FENCEABORT
#define HELPID_TGLBUT_PrefTitleBars	    TPC_TITLEBARS
#define HELPID_TGLBUT_PrefBothVirt	    TPC_VIRTUAL
#define HELPID_TGLBUT_PrefInputFocus	    TPC_WINHIGHLIGHT
#define HELPID_TGLBUT_PrefConserveMem	    TPC_MEMORY
#define HELPID_PSHBUT_PrefsMore		    0

#define HELPID_DIALOG_MoreUserPref	    0
#define HELPID_TGLBUT_MorePrefLocateOn	    TPC_ADDLREFPREFS
#define HELPID_TGLBUT_MorePrefSnapOn	    TPC_ADDLREFPREFS
#define HELPID_TGLBUT_MorePrefTileIgds	    TPC_TILEIGDS
#define HELPID_TGLBUT_MorePrefUseCTable	    TPC_ADDLREFPREFS
#define HELPID_TGLBUT_MorePrefStartParse    TPC_STARTPARSE
#define HELPID_TGLBUT_MorePrefTextLineStyle TPC_TEXTLSTYLE
#define HELPID_OPTBUT_FontSize		    TPC_FONTSIZE

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
|    Help ids used in FunctionKeys dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_FunctionKeys	    0
#define HELPID_PULLDOWN_FunctionKeyFile	    0
#define HELPID_PULLDOWN_FnkeyFileOpen	    0
#define HELPID_PULLDOWN_FnkeyFileSaveAs	    0
#define HELPID_PULLDOWN_FnKeyFileSave	    0

/*----------------------------------------------------------------------+
|    Help ids used in MDL dialog					|
+----------------------------------------------------------------------*/
#define	HELPID_DIALOG_MDL		    0
#define HELPID_LISTBOX_MDLLoaded	    0
#define HELPID_LISTBOX_MDLAvailable	    0
#define HELPID_PSHBUT_MDLLoad		    0
#define HELPID_PSHBUT_MLDUnload		    0
#define HELPID_PSHBUT_MDLDetail		    0

#define HELPID_DIALOG_MDLDetail		    0
#define HELPID_TEXT_MDLVersion		    0
#define HELPID_TEXT_MDLAppCodeSize	    0
#define HELPID_TEXT_MDLAppDataSize	    0
#define HELPID_TEXT_MDLAppStackSize	    0
#define HELPID_TEXT_MDLOpenFiles	    0
#define HELPID_TEXT_MDLOpenRscFiles	    0
#define HELPID_TEXT_MDLLoadedResources	    0
#define HELPID_TEXT_MDLResourceMem	    0

/*----------------------------------------------------------------------+
|    Help ids used in SecurityKey dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_GetSecurityKey	    0
#define HELPID_PSHBUT_GetKey		    0
#define HELPID_TEXT_SecurityKeyDuration	    0
#define HELPID_TEXT_SecurityServerList	    0
#define HELPID_TGLBUT_SecurityKeyOverWrite  0
#define HELPID_TGLBUT_SecurityDefOverrd	    0

/*----------------------------------------------------------------------+
|    Dialogs launched from the Help Pulldown				|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Help ids used in Help dialogs					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Help		    0
#define HELPID_DIALOG_HelpFind		    0
#define HELPID_LISTBOX_HelpTopicsList	    0
#define HELPID_LISTBOX_HelpSubtopicList	    0
#define HELPID_OPTBUT_subwindowMode	    0
#define HELPID_OPTBUT_visitedTopic	    0
#define HELPID_OPTBUT_findDepth		    0
#define HELPID_OPTBUT_findApplication	    0
#define HELPID_OPTBUT_graphic		    0
#define HELPID_PSHBUT_HelpOpenTopic	    0
#define HELPID_PSHBUT_HelpFind		    0
#define HELPID_PSHBUT_HelpFindGo	    0
#define HELPID_TEXT_HelpFindString	    0
#define HELPID_TGLBUT_HelpTracking	    0

#define HELPID_DIALOG_CmdBrowser	    0
#define HELPID_PSHBUT_CmdBroswserExecute    0
#define HELPID_LISTBOX_CmdBrowserLev0	    0
#define HELPID_LISTBOX_CmdBrowserLev1	    0
#define HELPID_LISTBOX_CmdBrowserLev2	    0
#define HELPID_LISTBOX_CmdBrowserLev3	    0

#define HELPID_DIALOG_AboutUstn		    0

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
#define HELPID_PALETTE_Splines3D	    0
#define HELPID_PALETTE_Splines2D3D	    0
#define HELPID_PALETTE_SpaceCurve	    0
#define HELPID_PALETTE_Surface		    0
#define HELPID_PALETTE_DerSurf		    0
#define HELPID_PALETTE_Change3D		    0

/*----------------------------------------------------------------------+
|    Help ids used in PatternSettings dialog - No dialog, only popdowns |
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_PatternSettings	    0
#define HELPID_GEN_PatternAnglIndicator	    0
#define HELPID_TEXT_PatternScale	    0
#define HELPID_TEXT_PatternAngle	    0
#define HELPID_TEXT_PatternName		    0
#define HELPID_TEXT_PatternAngleXHatch	    0
#define HELPID_TEXT_PatternRows		    0
#define HELPID_TEXT_PatternCols		    0
#define HELPID_PSHBUT_PatternScale1	    0
#define HELPID_PSHBUT_PatternMatch	    0

/*----------------------------------------------------------------------+
|    MISCELLANEOUS Help ids						|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|    Help ids used in DesignOptions dialog (DES key-in)     	    	|
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
|    Help ids used For unclaimed dialogs				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_StdFileSeedCreate	    0
#define HELPID_DIALOG_StdFileCreate	    0
#define HELPID_DIALOG_Digitize		    0
#define HELPID_DIALOG_Import		    0
#define HELPID_DIALOG_Export		    0
#define HELPID_DIALOG_FileUtilities	    0

/*----------------------------------------------------------------------+
|    Help ids used in mgdsdlog - various dialogs			|
+----------------------------------------------------------------------*/
#define HELPID_OPTBUT_IsoLockPlane	    0
#define HELPID_OPTBUT_ElementArea	    0
#define HELPID_OPTBUT_ElementClass	    0
#define HELPID_OPTBUT_ElementColor	    0
#define HELPID_OPTBUT_ViewNumber	    0
#define HELPID_PSHBUT_Apply		    0
#define HELPID_PSHBUT_Reset		    0
#define HELPID_PSHBUT_OK		    0
#define HELPID_PSHBUT_Cancel		    0
#define HELPID_PSHBUT_Default		    0
#define HELPID_TGLBUT_ElementFill	    0

/*----------------------------------------------------------------------+
|    Help ids used in CommandWindow dialog    	    	    	       	|
+----------------------------------------------------------------------*/
#define HELPID_CMD_CommandWindow	    0
#define HELPID_DIALOG_CommandWindow	    0
#define HELPID_DIALOG_CommandWindowNoMenu   0
#define HELPID_DIALOG_CommandWindow3By2	    0
#define HELPID_DIALOG_StandardAlert	    0

/*----------------------------------------------------------------------+
|    Help ids used in WindMgrMenu dialog				|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_WindowManMenu	    0	/* not really a dialog */
#define HELPID_PULLDOWN_WindowManMenu	    0
#define HELPID_PULLDOWN_WindMgrRestore	    0
#define HELPID_PULLDOWN_WindMgrMove	    0
#define HELPID_PULLDOWN_WindMgrSize	    0
#define HELPID_PULLDOWN_WindMgrMinimize	    0
#define HELPID_PULLDOWN_WindMgrMaximize	    0
#define HELPID_PULLDOWN_WindMgrLower	    0
#define HELPID_PULLDOWN_WindMgrSink	    0
#define HELPID_PULLDOWN_WindMgrClose	    0

/*----------------------------------------------------------------------+
|    Help ids used For IconCmds on Splines Palette			|
+----------------------------------------------------------------------*/
#define HELPID_ICMD_PlCrvPoles		    SPL_PLACE_BSPLINE_CURVE_POLES
#define HELPID_ICMD_PlCrvPts		    SPL_PLACE_BSPLINE_CURVE_POINTS
#define HELPID_ICMD_PlCrvLsq		    SPL_PLACE_BSPLINE_CURVE_LEASTSQUARES
#define HELPID_ICMD_CnsCrvPoles		    SPL_CONSTRUCT_BSPLINE_CURVE_POLES
#define HELPID_ICMD_CnsCrvPts		    SPL_CONSTRUCT_BSPLINE_CURVE_POINTS
#define HELPID_ICMD_CnsCrvLsq		    SPL_CONSTRUCT_BSPLINE_CURVE_LEASTSQUARES
#define HELPID_ICMD_PlSprlByAngle	    SPL_PLACE_SPIRAL_ANGLE
#define HELPID_ICMD_PlSprlByLength	    SPL_PLACE_SPIRAL_LENGTH
#define HELPID_ICMD_PlSprlByEndpts	    SPL_PLACE_SPIRAL_ENDPOINTS
#define HELPID_ICMD_PlParab		    SPL_PLACE_PARABOLA_ENDPOINTS
#define HELPID_ICMD_PlHelix		    SPL_PLACE_HELIX
#define HELPID_ICMD_PlSurfPoles		    SPL_PLACE_BSPLINE_SURFACE_POLES
#define HELPID_ICMD_PlSurfPts		    SPL_PLACE_BSPLINE_SURFACE_POINTS
#define HELPID_ICMD_PlSurfLsq		    SPL_PLACE_BSPLINE_SURFACE_LEASTSQUARES
#define HELPID_ICMD_CnsSurfPoles	    SPL_CONSTRUCT_BSPLINE_SURFACE_POLES
#define HELPID_ICMD_CnsSurfPts		    SPL_CONSTRUCT_BSPLINE_SURFACE_POINTS
#define HELPID_ICMD_CnsSurfLsq		    SPL_CONSTRUCT_BSPLINE_SURFACE_LEASSQUARES
#define HELPID_ICMD_CnsSurfProj		    SPL_CONSTRUCT_BSPLINE_SURFACE_PROJECTION
#define HELPID_ICMD_CnsSurfRevolv	    SPL_CONSTRUCT_BSPLINE_SURFACE_REVOLUTION
#define HELPID_ICMD_CnsSurfTube		    SPL_CONSTRUCT_BSPLINE_SURFACE_TUBE
#define HELPID_ICMD_CnsSurfSkin		    SPL_CONSTRUCT_BSPLINE_SURFACE_SKIN
#define HELPID_ICMD_CnsSurfXSect	    SPL_CONSTRUCT_BSPLINE_SURFACE_CROSS
#define HELPID_ICMD_CnsSurfEdge		    SPL_CONSTRUCT_BSPLINE_SURFACE_EDGE
#define HELPID_ICMD_CnsConvCopy		    SPL_CONSTRUCT_BSPLINE_CONVERT_COPY
#define HELPID_ICMD_CnsConvOrig		    SPL_CONSTRUCT_BSPLINE_CONVERT_ORIGINAL
#define HELPID_ICMD_ChgPoly		    SPL_CHANGE_BSPLINE_POLYGON
#define HELPID_ICMD_ChgOrder		    SPL_CHANGE_BSPLINE_ORDER
#define HELPID_ICMD_ChgUOrder		    SPL_CHANGE_BSPLINE_UORDER
#define HELPID_ICMD_ChgVOrder		    SPL_CHANGE_BSPLINE_VORDER
#define HELPID_ICMD_ChgURules		    SPL_CHANGE_BSPLINE_URULES
#define HELPID_ICMD_ChgVRules		    SPL_CHANGE_BSPLINE_VRULES
#define HELPID_ICMD_ExtrSrfBnd		    SPL_EXTRACT_BSPLINE_SURFACE_BOUNDARY
#define HELPID_ICMD_ImpsSrfBnd		    SPL_IMPOSE_BSPLINE_SURFACE_BOUNDARY
#define HELPID_ICMD_Fake		    0

/*----------------------------------------------------------------------+
|    Help ids used in Splines dialog					|
+----------------------------------------------------------------------*/
#define HELPID_DIALOG_Splines		    0
#define HELPID_DIALOG_SplinePrefs	    0
#define HELPID_TEXT_SpTolerance		    0
#define HELPID_TEXT_SpCurveOrder	    0
#define HELPID_TEXT_SpCurvePoles	    0
#define HELPID_TEXT_SpSurfOrderU	    0
#define HELPID_TEXT_SpSurfOrderV	    0
#define HELPID_TEXT_SpSurfPolesU	    0
#define HELPID_TEXT_SpSurfPolesV	    0
#define HELPID_TEXT_SpSurfRulesU	    0
#define HELPID_TEXT_SpSurfRulesV	    0
#define HELPID_TGLBUT_SpDispControlPoly	    0
#define HELPID_OPTBUT_SpCurveType	    0
#define HELPID_OPTBUT_SpSurfTypeU	    0
#define HELPID_OPTBUT_SpSurfTypeV	    0
#define HELPID_OPTBUT_SpThreadDir	    0
#define HELPID_TEXT_SprlInitRad		    0
#define HELPID_TEXT_SprlFinalRad	    0
#define HELPID_TEXT_SprlLength		    0
#define HELPID_TEXT_SprlSweepAng	    0
#define HELPID_TEXT_SprlOrientAng	    0
#define HELPID_TEXT_SpSurfActAng	    0
#define HELPID_TEXT_HlxPitchHt		    0


#endif

