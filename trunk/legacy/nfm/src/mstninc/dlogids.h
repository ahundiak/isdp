/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   dlogids.h  $
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
/*----------------------------------------------------------------------+
|									|
|   mgdsdlog.h  -- Bentley System Resource IDs used in MicroStation	|
|									|
|		   Bentley Systems uses NEGATIVE ids.  3rd party	|
|		   developers should use positive ids.			|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Dialog Box IDs							|
|									|
+----------------------------------------------------------------------*/
#define DIALOGID_Locks			(-1)
/* can be used again... */
#define DIALOGID_ElementAttributes	(-3)
#define DIALOGID_CoordReadout		(-4)
#define DIALOGID_CommandWindow		(-5)
#define DIALOGID_KitchenSink		(-6)
#define DIALOGID_ReferenceFile		(-7)
#define DIALOGID_Rendering		(-8)
#define DIALOGID_SavedViews	        (-9)
#define DIALOGID_AuxCoordSystems	(-10)
/* -11 can be used again */
#define DIALOGID_GetSecurityKey		(-12)
#define	DIALOGID_StandardAlert		(-13)

#define DIALOGID_DimStrings  	       	(-14)
#define DIALOGID_DimAttributes	       	(-15)
#define DIALOGID_DimGeometry	       	(-16)
#define DIALOGID_DimPlacement 	       	(-17)
#define DIALOGID_DimSymbols 	       	(-18)
#define DIALOGID_DimTemplate 	    	(-19)
#define DIALOGID_DimTerminators 	(-20)
#define DIALOGID_DimTextFormat	       	(-21)
#define DIALOGID_DimTolerance	       	(-29)

#define DIALOGID_Multiline    	    	(-30)
#define DIALOGID_WorkingUnits		(-31)
#define DIALOGID_NamedLevels		(-32)
#define DIALOGID_TextEdit		(-33)
#define DIALOGID_DBSettings		(-34)
#define DIALOGID_ViewRotation		(-35)
#define DIALOGID_CellMaintenance	(-36)
#define DIALOGID_CellEdit		(-37)
#define DIALOGID_CellCreate		(-38)
#define DIALOGID_ActiveAngle		(-40)
#define DIALOGID_ReferenceAttach	(-41)
#define DIALOGID_PreviewPlot		(-42)
#define DIALOGID_PlotPageSize		(-43)
#define DIALOGID_PlotOptions		(-44)
#define DIALOGID_ReferenceLevels	(-45)
#define DIALOGID_ViewSettings		(-46)
#define DIALOGID_ViewLevels		(-47)
#define DIALOGID_CmdBrowser		(-48)
#define DIALOGID_ActiveScale		(-49)
#define DIALOGID_PatternSettings	(-50)
#define DIALOGID_ColorSquare		(-51)
#define DIALOGID_StdFileSeedCreate	(-52)
#define DIALOGID_RotateACS    	    	(-53)
#define DIALOGID_Font			(-54)
#define DIALOGID_ColorPalette	    	(-55)
#define DIALOGID_LevSymb		(-56)
#define	DIALOGID_GridSettings		(-57)
#define DIALOGID_DesignOptions		(-58)
#define DIALOGID_Precision		(-59)
#define DIALOGID_Camera			(-60)
/* -61 can be used again */
#define DIALOGID_FunctionKeys	        (-62)
#define DIALOGID_TextSettings	        (-63)
#define DIALOGID_EnvVariables		(-64)
#define	DIALOGID_MDL			(-65)
#define DIALOGID_MDLDetail		(-66)
/* -67 can be used again */
#define DIALOGID_StdFileOpen		(-68)
/* -69 can be used again */
#define DIALOGID_Digitizing		(-70)
/* -71 can be used again */
/* -72 can be used again */
#define DIALOGID_ShowPlotter		(-73)
#define DIALOGID_UserPreferences	(-74)
#define DIALOGID_Display		(-75)
/* palette frames */
#define DIALOGID_MainFrame		(-76)
#define DIALOGID_FenceFrame		(-77)
#define DIALOGID_DimensioningFrame	(-78)

#define DIALOGID_ToolSettings		(-79)

#define DIALOGID_Image			(-80)
#define DIALOGID_ReferenceRotate	(-81)
#define DIALOGID_ReferenceScale		(-82)
#define DIALOGID_ImageSave		(-83)
#define DIALOGID_TextFileDisplay	(-84)
#define DIALOGID_AboutUstn		(-85)
#define DIALOGID_FileList		(-86)
#define DIALOGID_BasicLocks		(-87)
    
#define DIALOGID_FileListSingle		(-88)
#define DIALOGID_FileListMultiple	(-89)
#define DIALOGID_FileListDDSingle	(-90)
#define DIALOGID_FileListDDMultiple	(-91)
    
#define DIALOGID_LevelEdit		(-92)
#define DIALOGID_GroupEdit		(-93)

#define DIALOGID_DialogMessages		(-94)
#define DIALOGID_WindowManMenu		(-95)
#define DIALOGID_MoreUserPref		(-96)

#define	DIALOGID_StandardInfoBox	(-97)

#define DIALOGID_Help	    	    	(-98)
#define DIALOGID_HelpFind    	    	(-99)
	
#define DIALOGID_AppCmdWindow1		(-301)		/* REMINDER */
#define DIALOGID_AppCmdWindow99 	(-399)		/* REMINDER */
/*----------------------------------------------------------------------+
|									|
|   NOTE:  Never use dialogIds from -301 through -399 inclusive.	|
|	   These are reserved for application command windows. BJB.     |
|									|
+----------------------------------------------------------------------*/

/*----------------------------------------------------------------------+
|									|
|   Base IDs for Related Groups						|
|									|
+----------------------------------------------------------------------*/
#define BASEID_Locks		    (DIALOGID_Locks	       	    * 100)
#define BASEID_Animate		    (DIALOGID_Animate	       	    * 100)
#define BASEID_ElementAttributes    (DIALOGID_ElementAttributes	    * 100)
#define BASEID_CoordReadout	    (DIALOGID_CoordReadout     	    * 100)
#define BASEID_CommandWindow	    (DIALOGID_CommandWindow         * 100)
#define BASEID_KitchenSink	    (DIALOGID_KitchenSink	    * 100)
#define BASEID_ReferenceFile	    (DIALOGID_ReferenceFile	    * 100)
#define BASEID_Rendering	    (DIALOGID_Rendering	       	    * 100)
#define BASEID_SavedViews	    (DIALOGID_SavedViews	    * 100)
#define BASEID_AuxCoordSystems	    (DIALOGID_AuxCoordSystems       * 100)
#define BASEID_SplinePrefs	    (DIALOGID_SplinePrefs           * 100)
#define BASEID_GetSecurityKey	    (DIALOGID_GetSecurityKey        * 100)
#define	BASEID_StandardAlert	    (DIALOGID_StandardAlert         * 100)

#define BASEID_DimStrings  	    (DIALOGID_DimStrings	    * 100)
#define BASEID_DimAttributes	    (DIALOGID_DimAttributes         * 100)
#define BASEID_DimGeometry	    (DIALOGID_DimGeometry           * 100)
#define BASEID_DimPlacement 	    (DIALOGID_DimPlacement          * 100)
#define BASEID_DimSymbols 	    (DIALOGID_DimSymbols            * 100)
#define BASEID_DimTemplate 	    (DIALOGID_DimTemplate           * 100)
#define BASEID_DimTerminators	    (DIALOGID_DimTerminators        * 100)
#define BASEID_DimTextFormat	    (DIALOGID_DimTextFormat         * 100)
#define BASEID_DimTolerance	    (DIALOGID_DimTolerance          * 100)

#define BASEID_Multiline    	    (DIALOGID_Multiline             * 100)
#define BASEID_WorkingUnits	    (DIALOGID_WorkingUnits          * 100)
#define BASEID_NamedLevels	    (DIALOGID_NamedLevels    	    * 100)
#define BASEID_TextEdit		    (DIALOGID_TextEdit    	    * 100)
#define BASEID_DBSettings	    (DIALOGID_DBSettings	    * 100)
#define BASEID_ViewRotation	    (DIALOGID_ViewRotation          * 100)
#define BASEID_CellMaintenance	    (DIALOGID_CellMaintenance       * 100)
#define BASEID_CellEdit		    (DIALOGID_CellEdit	       	    * 100)
#define BASEID_CellCreate	    (DIALOGID_CellCreate	    * 100)
#define BASEID_ActiveAngle	    (DIALOGID_ActiveAngle           * 100)
#define BASEID_RefAttach	    (DIALOGID_ReferenceAttach       * 100)
#define BASEID_Plot		    (DIALOGID_PreviewPlot           * 100)
#define BASEID_PlotPageSize	    (DIALOGID_PlotPageSize          * 100)
#define BASEID_PlotOptions	    (DIALOGID_PlotOptions           * 100)
#define BASEID_PlotShow		    (DIALOGID_ShowPlotter           * 100)
#define BASEID_ReferenceLevels	    (DIALOGID_ReferenceLevels       * 100)
#define BASEID_ViewSettings	    (DIALOGID_ViewSettings          * 100)
#define BASEID_ViewLevels	    (DIALOGID_ViewLevels	    * 100)
#define BASEID_CmdBrowser	    (DIALOGID_CmdBrowser	    * 100)
#define BASEID_ActiveScale	    (DIALOGID_ActiveScale	    * 100)
#define BASEID_PatternSettings	    (DIALOGID_PatternSettings	    * 100)
#define BASEID_RotateACS	    (DIALOGID_RotateACS		    * 100)
#define BASEID_Font		    (DIALOGID_Font		    * 100)
#define BASEID_ColorPalette	    (DIALOGID_ColorPalette	    * 100)
#define BASEID_LevSymb		    (DIALOGID_LevSymb 		    * 100)
#define BASEID_GridSettings	    (DIALOGID_GridSettings	    * 100)
#define BASEID_Precision	    (DIALOGID_Precision		    * 100)
#define BASEID_DesignOptions	    (DIALOGID_DesignOptions	    * 100)
#define BASEID_Camera		    (DIALOGID_Camera		    * 100)
#define BASEID_Digitize		    (DIALOGID_FunctionKeys	    * 100)
#define BASEID_FunctionKeys	    (DIALOGID_FunctionKeys	    * 100)
#define BASEID_TextSettings	    (DIALOGID_TextSettings	    * 100)
#define BASEID_EnvVariables	    (DIALOGID_EnvVariables	    * 100)
#define	BASEID_MDL		    (DIALOGID_MDL		    * 100)
#define	BASEID_MDLDetail	    (DIALOGID_MDLDetail		    * 100)
#define BASEID_StdFileOpen	    (DIALOGID_StdFileOpen	    * 100)
#define BASEID_StdFileCreate	    (DIALOGID_StdFileCreate	    * 100)
#define	BASEID_Digitizing	    (DIALOGID_Digitizing	    * 100)
#define BASEID_Import		    (DIALOGID_Import		    * 100)
#define BASEID_Export		    (DIALOGID_Export		    * 100)
#define BASEID_UserPreferences	    (DIALOGID_UserPreferences	    * 100)
#define BASEID_Display		    (DIALOGID_Display		    * 100)
#define BASEID_StdFileSeedCreate    (DIALOGID_StdFileSeedCreate	    * 100)
#define BASEID_MainFrame	    (DIALOGID_MainFrame		    * 100)
#define BASEID_ToolSettings	    (DIALOGID_ToolSettings	    * 100)
#define BASEID_ReferenceRotate	    (DIALOGID_ReferenceRotate	    * 100)
#define BASEID_ReferenceScale	    (DIALOGID_ReferenceScale	    * 100)
#define BASEID_TextFileDisplay	    (DIALOGID_TextFileDisplay	    * 100)
#define BASEID_AboutUstn	    (DIALOGID_AboutUstn      	    * 100)
#define BASEID_FileList		    (DIALOGID_FileListSingle	    * 100)
#define BASEID_BasicLocks	    (DIALOGID_BasicLocks	    * 100)
#define BASEID_LevelEdit	    (DIALOGID_LevelEdit    	    * 100)
#define BASEID_GroupEdit	    (DIALOGID_GroupEdit    	    * 100)
#define BASEID_DialogMessages	    (DIALOGID_DialogMessages	    * 100)
#define BASEID_WindowManMenu	    (DIALOGID_WindowManMenu	    * 100)
#define BASEID_MoreUserPref	    (DIALOGID_MoreUserPref	    * 100)

/*----------------------------------------------------------------------+
|									|
|   Color Picker Id's							|
|									|
+----------------------------------------------------------------------*/
#define COLORPICKERID_ElementColor	(-1)
#define COLORPICKERID_DimElementColor	(-2)
#define COLORPICKERID_DimAlternateColor	(-3)
#define COLORPICKERID_DimTextColor	(-4)
#define COLORPICKERID_MLineColor     	(BASEID_Multiline-1)
#define COLORPICKERID_MLineFill     	(BASEID_Multiline-2)
#define COLORPICKERID_LSym		(BASEID_LevSymb-1)

/*----------------------------------------------------------------------+
|									|
|   Command Id's							|
|									|
+----------------------------------------------------------------------*/
#define COMMANDID_CommandWindow		(-1)

/*----------------------------------------------------------------------+
|									|
|   Generic Id's							|
|									|
+----------------------------------------------------------------------*/
#define GENERICID_ViewRotationDisplay	(BASEID_ViewRotation-1)
#define GENERICID_ViewRotationSystem	(BASEID_ViewRotation-2)

#define GENERICID_Cell		        (BASEID_CellMaintenance-1)

#define GENERICID_ActvScaleLock		(BASEID_ActiveScale-1)

#define GENERICID_ActvAngleIndicator	(BASEID_ActiveAngle-1)

#define GENERICID_Font			(BASEID_Font-1)

#define GENERICID_ColorPaletteDisplay   (BASEID_ColorPalette-1)
#define GENERICID_UpdateCellDisplay   	(BASEID_ColorPalette-2)
#define GENERICID_ColorSquareDisplay   	(BASEID_ColorPalette-3)
#define GENERICID_WedgeDisplay  	(BASEID_ColorPalette-4)

#define GENERICID_TextScaleLock		(BASEID_TextSettings-1)
#define GENERICID_TextStringJust	(BASEID_TextSettings-2)
#define GENERICID_TextNodeJust		(BASEID_TextSettings-3)

#define GENERICID_AdimTextScaleLock	(BASEID_DimAttributes-1)

#define	GENERICID_PlotPlacement		(BASEID_Plot-1)

#define GENERICID_PatternAngleIndicator	(BASEID_PatternSettings-1)

#define GENERICID_MLineDraw		(BASEID_Multiline-1)

#define GENERICID_AmbientColor   	(BASEID_Rendering-1)
#define GENERICID_FlashColor		(BASEID_Rendering-2)
#define GENERICID_SunColor		(BASEID_Rendering-3)

/*----------------------------------------------------------------------+
|									|
|   Icon Ids								|
|									|
+----------------------------------------------------------------------*/
#define ICONID_SmallRightTriangle   (-1)
#define ICONID_SmallDownTriangle    (-2)

#define ICONID_LineStyle0	    (-3)
#define ICONID_LineStyle1	    (-4)
#define ICONID_LineStyle2	    (-5)
#define ICONID_LineStyle3	    (-6)
#define ICONID_LineStyle4	    (-7)
#define ICONID_LineStyle5	    (-8)
#define ICONID_LineStyle6	    (-9)
#define ICONID_LineStyle7	    (-10)

#define ICONID_LineWeight0	    (-11)
#define ICONID_LineWeight1	    (-12)
#define ICONID_LineWeight2	    (-13)
#define ICONID_LineWeight3	    (-14)
#define ICONID_LineWeight4	    (-15)
#define ICONID_LineWeight5	    (-16)
#define ICONID_LineWeight6	    (-17)
#define ICONID_LineWeight7	    (-18)
#define ICONID_LineWeight8	    (-19)
#define ICONID_LineWeight9	    (-20)
#define ICONID_LineWeight10         (-21)
#define ICONID_LineWeight11         (-22)
#define ICONID_LineWeight12         (-23)
#define ICONID_LineWeight13         (-24)
#define ICONID_LineWeight14         (-25)
#define ICONID_LineWeight15         (-26)

#define ICONID_DimTmplCommonDot	    	(BASEID_DimTemplate   -1)
#define ICONID_DimTmplRightDot	    	(BASEID_DimTemplate   -2)
#define ICONID_DimTmplLeftDot	    	(BASEID_DimTemplate   -3)

#define ICONID_DimTmplJointCommon	(BASEID_DimTemplate   -4)
#define ICONID_DimTmplRightCommon	(BASEID_DimTemplate   -5)
#define ICONID_DimTmplLeftCommon	(BASEID_DimTemplate   -6)
#define ICONID_DimTmplRightSlash2	(BASEID_DimTemplate   -7)
#define ICONID_DimTmplLeftSlash2	(BASEID_DimTemplate   -8)
#define ICONID_DimTmplJointSlash	(BASEID_DimTemplate   -9)
#define ICONID_DimTmplRightSlash1	(BASEID_DimTemplate   -10)
#define ICONID_DimTmplLeftSlash1	(BASEID_DimTemplate   -11)
#define ICONID_DimTmplRightNone	    	(BASEID_DimTemplate   -12)
#define ICONID_DimTmplLeftNone	    	(BASEID_DimTemplate   -13)
#define ICONID_DimTmplJointNone	    	(BASEID_DimTemplate   -14)
#define ICONID_DimTmplJointArrow	(BASEID_DimTemplate   -15)
#define ICONID_DimTmplRightArrow	(BASEID_DimTemplate   -16)
#define ICONID_DimTmplLeftArrow	    	(BASEID_DimTemplate   -17)
#define ICONID_DimTmplBlank		(BASEID_DimTemplate   -18)
#define ICONID_DimTmplSymDiameter	(BASEID_DimTemplate   -19)
#define ICONID_DimTmplSymRadius	    	(BASEID_DimTemplate   -20)
#define ICONID_DimTmplSymSpDiameter	(BASEID_DimTemplate   -21)
#define ICONID_DimTmplSymSpRaddius	(BASEID_DimTemplate   -22)

#define ICONID_DimTmplLeaderOut	    	(BASEID_DimTemplate   -23)
#define ICONID_DimTmplLeaderOutExt	(BASEID_DimTemplate   -24)
#define ICONID_DimTmplLeaderIn	    	(BASEID_DimTemplate   -25)
#define ICONID_DimTmplLeaderInExt	(BASEID_DimTemplate   -26)

#define ICONID_DimTmplSquare		(BASEID_DimTemplate   -27)
#define ICONID_DimTmplNone		(BASEID_DimTemplate   -28)

/*----------------------------------------------------------------------+
|									|
|   LevelMap Ids							|
|									|
+----------------------------------------------------------------------*/
#define LEVELMAPID_ViewLevels		(BASEID_ViewLevels-1)
#define LEVELMAPID_ReferenceLevels	(BASEID_ReferenceLevels-1)

/*----------------------------------------------------------------------+
|									|
|   List Id's   							|
|									|
+----------------------------------------------------------------------*/
#define LISTID_Sample			(BASEID_KitchenSink-1)
#define LISTID_ReferenceFile		(BASEID_ReferenceFile-1)
#define LISTID_SavedViews	        (BASEID_SavedViews-1)
#define LISTID_AuxCoordSystems		(BASEID_AuxCoordSystems-1)
#define LISTID_MLineLines		(BASEID_Multiline-1)
#define LISTID_CellList			(BASEID_CellMaintenance-1)
#define LISTID_RefAttachViews		(BASEID_RefAttach-1)
#define LISTID_CmdBrowserLev0		(BASEID_CmdBrowser-1)
#define LISTID_CmdBrowserLev1		(BASEID_CmdBrowser-2)
#define LISTID_CmdBrowserLev2		(BASEID_CmdBrowser-3)
#define LISTID_CmdBrowserLev3		(BASEID_CmdBrowser-4)
#define LISTID_CmdBrowserLev4		(BASEID_CmdBrowser-5)
#define LISTID_Font			(BASEID_Font-1)
#define LISTID_LevSymb			(BASEID_LevSymb-1)
#define LISTID_FunctionKeys		(BASEID_FunctionKeys-1)
#define	LISTID_MDLLoaded		(BASEID_MDL-1)
#define	LISTID_MDLAvailable		(BASEID_MDL-2)
#define LISTID_EnvVariables		(BASEID_EnvVariables-1)
#define LISTID_FileOpenFiles		(BASEID_StdFileOpen-1)
#define LISTID_FileOpenDirs		(BASEID_StdFileOpen-2)
#define LISTID_TextFileDisplay		(BASEID_TextFileDisplay-1)
#define LISTID_NamedLevelsList 		(BASEID_NamedLevels-1)
#define LISTID_NamedLevelsGroups 	(BASEID_NamedLevels-2)
#define LISTID_FileListDirs		(BASEID_FileList-1)
#define LISTID_FileListFiles		(BASEID_FileList-2)
#define LISTID_FileListNames		(BASEID_FileList-3)
#define LISTID_DialogMessages		(BASEID_DialogMessages-1)

/*----------------------------------------------------------------------+
|									|
|   MenuBar Id's							|
|									|
+----------------------------------------------------------------------*/
#define MENUBARID_Main			(BASEID_CommandWindow	-1)
#define MENUBARID_ACS			(BASEID_AuxCoordSystems	-1)
#define MENUBARID_ReferenceFile		(BASEID_ReferenceFile	-1)
#define MENUBARID_DimPlacement          (BASEID_DimPlacement     -1)
#define MENUBARID_Digitizing		(BASEID_Digitizing	-1)
#define MENUBARID_FunctionKeys		(BASEID_FunctionKeys	-1)
#define MENUBARID_ColorPalette		(BASEID_ColorPalette	-1)
#define MENUBARID_NamedLevels		(BASEID_NamedLevels-1)
#define MENUBARID_MLine			(BASEID_Multiline-1)
    

/*----------------------------------------------------------------------+
|									|
|   Message List Id's							|
|									|
+----------------------------------------------------------------------*/
#define MESSAGELISTID_DMsgsHeaders	(BASEID_DialogMessages-1)
#define MESSAGELISTID_DMsgsItems	(BASEID_DialogMessages-2)
#define MESSAGELISTID_DMsgsDialogs	(BASEID_DialogMessages-3)
#define MESSAGELISTID_Modifiers		(BASEID_DialogMessages-4)

/*----------------------------------------------------------------------+
|                                                                       |
|   Option Button Id's  						|
|                                                                       |
+----------------------------------------------------------------------*/
#define OPTIONBUTTONID_LSymSty		    (BASEID_LevSymb  -1)
#define OPTIONBUTTONID_LSymWt		    (BASEID_LevSymb  -2)

#define OPTIONBUTTONID_KSinkExample	    (BASEID_KitchenSink	-1)

#define OPTIONBUTTONID_PlotSelectView	    (BASEID_Plot	    -1)
#define OPTIONBUTTONID_PlotPgSzManOrigin    (BASEID_Plot	    -2)
#define OPTIONBUTTONID_PlotPgSzName	    (BASEID_Plot	    -3)

#define OPTIONBUTTONID_LockSnapMode	    (BASEID_Locks    -1)
#define OPTIONBUTTONID_LockFenceMode	    (BASEID_Locks    -2)
#define OPTIONBUTTONID_IsoLockPlane	    (BASEID_Locks    -3)

#define OPTIONBUTTONID_ElementArea	    (BASEID_ElementAttributes	-1)
#define OPTIONBUTTONID_ElementClass	    (BASEID_ElementAttributes	-2)
#define OPTIONBUTTONID_ElementColor	    (BASEID_ElementAttributes	-3)
#define OPTIONBUTTONID_ElementStyle	    (BASEID_ElementAttributes	-4)
#define OPTIONBUTTONID_ElementWeight	    (BASEID_ElementAttributes	-5)

#define OPTIONBUTTONID_CoordFormat	    (BASEID_CoordReadout	-1)
#define OPTIONBUTTONID_CoordAccuracy	    (BASEID_CoordReadout	-2)
#define OPTIONBUTTONID_CoordAngleFormat	    (BASEID_CoordReadout	-3)
#define OPTIONBUTTONID_CoordAngleMode	    (BASEID_CoordReadout	-4)

#define OPTIONBUTTONID_ReSunMonth	    (BASEID_Rendering	-1)
#define OPTIONBUTTONID_ReSunAmPm	    (BASEID_Rendering	-2)
#define OPTIONBUTTONID_ReSunDayStd	    (BASEID_Rendering	-3)

#define OPTIONBUTTONID_SpCurveType	    (BASEID_SplinePrefs	-1)
#define OPTIONBUTTONID_SpSurfTypeU	    (BASEID_SplinePrefs	-2)
#define OPTIONBUTTONID_SpSurfTypeV	    (BASEID_SplinePrefs	-3)

#define OPTIONBUTTONID_DimTextWeight	    (BASEID_DimAttributes    -1)
#define OPTIONBUTTONID_DimElementStyle	    (BASEID_DimAttributes    -2)
#define OPTIONBUTTONID_DimElementWeight	    (BASEID_DimAttributes    -3)
#define OPTIONBUTTONID_DimAlternateStyle    (BASEID_DimAttributes    -4)
#define OPTIONBUTTONID_DimAlternateWeight   (BASEID_DimAttributes    -5)

#define OPTIONBUTTONID_DimJustify	    (BASEID_DimPlacement     -1)
#define OPTIONBUTTONID_DimAlignMode	    (BASEID_DimPlacement     -2)
#define OPTIONBUTTONID_DimTextOrientation   (BASEID_DimPlacement     -3)
#define OPTIONBUTTONID_DimTextPlacement	    (BASEID_DimPlacement     -4)

#define OPTIONBUTTONID_DimToleranceMode	    (BASEID_DimTolerance     -1)

#define OPTIONBUTTONID_DimAngularPrecision  (BASEID_DimTextFormat    -1)
#define OPTIONBUTTONID_DimEnglishPrecision  (BASEID_DimTextFormat    -2)
#define OPTIONBUTTONID_DimAngleMeasure	    (BASEID_DimTextFormat    -3)
#define OPTIONBUTTONID_DimAngleFormat	    (BASEID_DimTextFormat    -4)
#define OPTIONBUTTONID_DimLengthFormat	    (BASEID_DimTextFormat    -5)
#define OPTIONBUTTONID_DimAECLabels	    (BASEID_DimTextFormat    -6)
#define OPTIONBUTTONID_DimLengthUnits	    (BASEID_DimTextFormat    -7)
#define OPTIONBUTTONID_DimMetricPrecision   (BASEID_DimTextFormat    -8)
#define OPTIONBUTTONID_DimTextFrame	    (BASEID_DimTextFormat    -9)

#define OPTIONBUTTONID_DimTmplLeftTerm	    (BASEID_DimTemplate	    -1)
#define OPTIONBUTTONID_DimTmplRightTerm	    (BASEID_DimTemplate	    -2)
#define OPTIONBUTTONID_DimTmplFirstTerm	    (BASEID_DimTemplate	    -3)
#define OPTIONBUTTONID_DimTmplJointTerm	    (BASEID_DimTemplate	    -4)
#define OPTIONBUTTONID_DimTmplPrefix	    (BASEID_DimTemplate	    -5)
#define OPTIONBUTTONID_DimTmplSuffix	    (BASEID_DimTemplate	    -6)
#define OPTIONBUTTONID_DimTmplCommand	    (BASEID_DimTemplate	    -7)
#define OPTIONBUTTONID_DimTermArrowhead	    (BASEID_DimTemplate	    -8)
#define OPTIONBUTTONID_DimensionTools	    (BASEID_DimTemplate	    -9)
#define OPTIONBUTTONID_DimTmplRadialLeader  (BASEID_DimTemplate	    -10)
#define OPTIONBUTTONID_DimTmplVertText      (BASEID_DimTemplate	    -11)

#define OPTIONBUTTONID_DimSymbPrefix        (BASEID_DimSymbols	    -1)
#define OPTIONBUTTONID_DimSymbSuffix        (BASEID_DimSymbols	    -2)
#define OPTIONBUTTONID_DimSymbDiameter      (BASEID_DimSymbols	    -3)
#define OPTIONBUTTONID_DimSymbPlusMinus     (BASEID_DimSymbols	    -4)

#define OPTIONBUTTONID_DimTermArrow	    (BASEID_DimTerminators   -1)
#define OPTIONBUTTONID_DimTermStroke	    (BASEID_DimTerminators   -2)
#define OPTIONBUTTONID_DimTermOrigin	    (BASEID_DimTerminators   -3)
#define OPTIONBUTTONID_DimTermDot	    (BASEID_DimTerminators   -4)

#define OPTIONBUTTONID_MLineType	    (BASEID_Multiline	    -1)
#define OPTIONBUTTONID_MLineStyle	    (BASEID_Multiline	    -2)
#define OPTIONBUTTONID_MLineWeight	    (BASEID_Multiline	    -3)
#define OPTIONBUTTONID_MLineClass	    (BASEID_Multiline	    -4)

#define	OPTIONBUTTONID_DBLinkMode	    (BASEID_DBSettings	-1)

#define OPTIONBUTTONID_ACSType		    (BASEID_AuxCoordSystems  -1)

#define OPTIONBUTTONID_StandardViews	    (BASEID_ViewRotation     -1)
#define OPTIONBUTTONID_ViewRotationNumber   (BASEID_ViewRotation     -2)

#define OPTIONBUTTONID_CellType		    (BASEID_CellMaintenance  -1)
#define OPTIONBUTTONID_CellSort		    (BASEID_CellMaintenance  -2)

#define OPTIONBUTTONID_RefAttachMode	    (BASEID_RefAttach	     -1)
#define OPTIONBUTTONID_RefLevelsView	    (BASEID_ReferenceLevels  -1)

#define OPTIONBUTTONID_SavedViewNum	    (BASEID_SavedViews       -1)
#define OPTIONBUTTONID_SavedViewDestNum	    (BASEID_SavedViews	     -2)

#define OPTIONBUTTONID_ViewRenderMode	    (BASEID_ViewSettings     -1)
#define OPTIONBUTTONID_ViewSettingsNumber   (BASEID_ViewSettings     -2)

#define OPTIONBUTTONID_ViewLevelsNumber	    (BASEID_ViewLevels	     -1)

#define OPTIONBUTTONID_GridConfig	    (BASEID_GridSettings     -1)

#define OPTIONBUTTONID_CameraViewNumber	    (BASEID_Camera   -1)
#define OPTIONBUTTONID_CameraLens	    (BASEID_Camera   -2)

#define OPTIONBUTTONID_TextStringVertJust   (BASEID_TextSettings     -1)
#define OPTIONBUTTONID_TextStringHorizJust  (BASEID_TextSettings     -2)
#define OPTIONBUTTONID_TextNodeVertJust	    (BASEID_TextSettings     -3)
#define OPTIONBUTTONID_TextNodeHorizJust    (BASEID_TextSettings     -4)

#define OPTIONBUTTONID_DisplayType	    (BASEID_Display-1)
#define OPTIONBUTTONID_ImageType	    (BASEID_Display-2)
#define OPTIONBUTTONID_ImageRender	    (BASEID_Display-3)
#define OPTIONBUTTONID_ViewNumber	    (BASEID_Display-4)

#define OPTIONBUTTONID_NamedLevelsSort	    (BASEID_NamedLevels-1)

#define OPTIONBUTTONID_PrecisionUnits	    (BASEID_Precision-1)

#define OPTIONBUTTONID_PrefClick	    (BASEID_UserPreferences  -1)
#define OPTIONBUTTONID_PrefIconSize	    (BASEID_UserPreferences  -2)
#define OPTIONBUTTONID_PrefPointerSize	    (BASEID_UserPreferences  -3)
#define OPTIONBUTTONID_PrefDefCommand	    (BASEID_UserPreferences  -4)
#define OPTIONBUTTONID_PrefCompatability    (BASEID_UserPreferences  -5)
#define OPTIONBUTTONID_PrefPointerType	    (BASEID_UserPreferences  -6)
#define OPTIONBUTTONID_PrefHighlight	    (BASEID_UserPreferences  -7)
#define OPTIONBUTTONID_PrefLayout	    (BASEID_UserPreferences  -8)

#define OPTIONBUTTONID_ActivePointType	    (BASEID_MainFrame-1)

#define OPTIONBUTTONID_FontSize		    (BASEID_MoreUserPref-1)
    
/*----------------------------------------------------------------------+
|									|
|   Pulldown Menu Id's  						|
|									|
+----------------------------------------------------------------------*/
#define PULLDOWNMENUID_File		(BASEID_CommandWindow	-1)
#define PULLDOWNMENUID_Edit		(BASEID_CommandWindow	-2)
#define PULLDOWNMENUID_Element		(BASEID_CommandWindow	-3)
#define PULLDOWNMENUID_Settings 	(BASEID_CommandWindow	-4)
#define PULLDOWNMENUID_View		(BASEID_CommandWindow	-5)
#define PULLDOWNMENUID_Palettes 	(BASEID_CommandWindow	-6)
#define PULLDOWNMENUID_User		(BASEID_CommandWindow	-7)

#define PULLDOWNMENUID_SubCellLibrary	(BASEID_CommandWindow	-8)
#define PULLDOWNMENUID_SubOpenClose	(BASEID_CommandWindow	-9)
#define PULLDOWNMENUID_SubMainPalette	(BASEID_CommandWindow	-10)
#define PULLDOWNMENUID_SubFencePalette	(BASEID_CommandWindow	-11)
#define PULLDOWNMENUID_SubDimension 	(BASEID_CommandWindow	-12)
#define	PULLDOWNMENUID_NetworkSecurity	(BASEID_CommandWindow	-13)
#define PULLDOWNMENUID_SubUndo		(BASEID_CommandWindow	-14)
#define PULLDOWNMENUID_SubUpdate	(BASEID_CommandWindow	-15)
#define PULLDOWNMENUID_SubFit		(BASEID_CommandWindow	-16)
#define PULLDOWNMENUID_SubWindow	(BASEID_CommandWindow	-17)
#define PULLDOWNMENUID_SubZoom		(BASEID_CommandWindow	-18)
#define PULLDOWNMENUID_SubCamera	(BASEID_CommandWindow	-19)
#define PULLDOWNMENUID_SubRender	(BASEID_CommandWindow	-20)
#define PULLDOWNMENUID_SubDimensioningPalette (BASEID_CommandWindow -21)
#define PULLDOWNMENUID_Help		(BASEID_CommandWindow	-22)
#define PULLDOWNMENUID_SubDisplay	(BASEID_CommandWindow	-23)
#define PULLDOWNMENUID_Sub3dBsplinesPalette (BASEID_CommandWindow   -24)
#define PULLDOWNMENUID_SubExport	(BASEID_CommandWindow	-25)
#define PULLDOWNMENUID_SubImport	(BASEID_CommandWindow	-26)
#define PULLDOWNMENUID_SubLocks		(BASEID_CommandWindow	-27)

#define	PULLDOWNMENUID_ACSTools		(BASEID_AuxCoordSystems	-1)
#define	PULLDOWNMENUID_ACSDefineElement	(BASEID_AuxCoordSystems	-2)
#define	PULLDOWNMENUID_ACSDefinePoints	(BASEID_AuxCoordSystems	-3)
#define	PULLDOWNMENUID_ACSDefineView	(BASEID_AuxCoordSystems	-4)

#define PULLDOWNMENUID_RefFileFile	(BASEID_ReferenceFile	-1)
#define PULLDOWNMENUID_RefFileTools	(BASEID_ReferenceFile	-2)
#define PULLDOWNMENUID_RefFileClip	(BASEID_ReferenceFile	-3)
#define PULLDOWNMENUID_RefFileSettings  (BASEID_ReferenceFile	-4)

#define PULLDOWNMENUID_DimStyles	(BASEID_DimPlacement 	-1)
#define PULLDOWNMENUID_DimDialogs   	(BASEID_DimPlacement 	-2)

#define PULLDOWNMENUID_DigitizingTablet (BASEID_Digitizing 	-1)

#define PULLDOWNMENUID_FunctionKeyFile	(BASEID_FunctionKeys	-1)

#define PULLDOWNMENUID_ColorPaletteFile	(BASEID_ColorPalette	-1)

#define PULLDOWNMENUID_NamedLevelsFile		(BASEID_NamedLevels-1)
#define PULLDOWNMENUID_NamedLevelsLevels	(BASEID_NamedLevels-2)
#define PULLDOWNMENUID_NamedLevelsGroups	(BASEID_NamedLevels-3)
#define PULLDOWNMENUID_NamedLevelsDisplay 	(BASEID_NamedLevels-4)

#define PULLDOWNMENUID_MLineStyle		(BASEID_Multiline-1)

#define PULLDOWNMENUID_WindowManMenu		(BASEID_WindowManMenu-1)

/*----------------------------------------------------------------------+
|									|
|   Pulldown Option Menu Id's  						|
|									|
+----------------------------------------------------------------------*/
#define PULLDOWNOPTIONMENUID_ElementStyle   (BASEID_CommandWindow -1)
#define PULLDOWNOPTIONMENUID_ElementWeight  (BASEID_CommandWindow -2)

/*----------------------------------------------------------------------+
|									|
|   Pulldown Color Picker Id's  					|
|									|
+----------------------------------------------------------------------*/
#define PULLDOWNCPICKERMENUID_ElementColor  (BASEID_CommandWindow -1)

/*----------------------------------------------------------------------+
|									|
|	Precision Button Ids						|
|									|
+----------------------------------------------------------------------*/
#define PRECBTNID_X			(BASEID_Precision-1)
#define PRECBTNID_Y			(BASEID_Precision-2)
#define PRECBTNID_Z			(BASEID_Precision-3)
#define PRECBTNID_Dx      		(BASEID_Precision-4)
#define PRECBTNID_Dy      		(BASEID_Precision-5)
#define PRECBTNID_Dz      		(BASEID_Precision-6)
#define PRECBTNID_Angle   		(BASEID_Precision-7)
#define PRECBTNID_Dist    		(BASEID_Precision-8)

/*----------------------------------------------------------------------+
|									|
|   Push Button Id's							|
|									|
+----------------------------------------------------------------------*/
#define PUSHBUTTONID_Apply			(-1)
#define PUSHBUTTONID_Reset			(-2)
#define PUSHBUTTONID_OK				(-3)
#define PUSHBUTTONID_Cancel			(-4)
#define PUSHBUTTONID_Default			(-5)

#define PUSHBUTTONID_MLineAddLine		(BASEID_Multiline-1)
#define PUSHBUTTONID_MLineDelLine		(BASEID_Multiline-2)

#define PUSHBUTTONID_ACSDelete			(BASEID_AuxCoordSystems-1)
#define PUSHBUTTONID_ACSAttach			(BASEID_AuxCoordSystems-3)
#define PUSHBUTTONID_ACSSave			(BASEID_AuxCoordSystems-5)

#define PUSHBUTTONID_ViewRotationApply		(BASEID_ViewRotation-1)

#define PUSHBUTTONID_Create			(BASEID_CellMaintenance-1)
#define PUSHBUTTONID_Edit			(BASEID_CellMaintenance-2)
#define PUSHBUTTONID_Delete			(BASEID_CellMaintenance-3)
#define PUSHBUTTONID_Done			(BASEID_CellMaintenance-4)
#define PUSHBUTTONID_Active			(BASEID_CellMaintenance-5)
#define PUSHBUTTONID_Term			(BASEID_CellMaintenance-6)
#define PUSHBUTTONID_Point			(BASEID_CellMaintenance-7)
#define PUSHBUTTONID_Pattrn			(BASEID_CellMaintenance-8)
#define PUSHBUTTONID_Share			(BASEID_CellMaintenance-9)

#define	PUSHBUTTONID_ActvScale1			(BASEID_ActiveScale-1)
#define	PUSHBUTTONID_ActvScaleHalf		(BASEID_ActiveScale-2)
#define	PUSHBUTTONID_ActvScaleDouble		(BASEID_ActiveScale-3)

#define PUSHBUTTONID_AllRefLevelViews		(BASEID_ReferenceLevels-1)
#define PUSHBUTTONID_ApplyRefLevelView		(BASEID_ReferenceLevels-2)

#define PUSHBUTTONID_PlotSetPageSize		(BASEID_Plot-1)
#define PUSHBUTTONID_PlotMaximize		(BASEID_Plot-2)
#define PUSHBUTTONID_PlotCenter			(BASEID_Plot-3)
#define PUSHBUTTONID_PlotOptions		(BASEID_Plot-4)
#define PUSHBUTTONID_PlotPlotters		(BASEID_Plot-5)
#define PUSHBUTTONID_PlotDone			(BASEID_Plot-6)
#define PUSHBUTTONID_PlotDoPlot			(BASEID_Plot-7)
#define PUSHBUTTONID_SaveSettings		(BASEID_Plot-8)

#define PUSHBUTTONID_AllViewSettings		(BASEID_ViewSettings-1)
#define PUSHBUTTONID_ApplyViewSettings		(BASEID_ViewSettings-2)
#define PUSHBUTTONID_AllViewLevels		(BASEID_ViewLevels-1)
#define PUSHBUTTONID_ApplyViewLevels		(BASEID_ViewLevels-2)

#define	PUSHBUTTONID_GetKey			(BASEID_GetSecurityKey-1)

#define PUSHBUTTONID_RotateACSAbsolute		(BASEID_RotateACS-1)
#define PUSHBUTTONID_RotateACSRelative		(BASEID_RotateACS-2)

#define	PUSHBUTTONID_PatternScale1		(BASEID_PatternSettings-1)
#define	PUSHBUTTONID_PatternMatch		(BASEID_PatternSettings-2)
#define PUSHBUTTONID_LevSymbFile		(BASEID_LevSymb-1)

#define PUSHBUTTONID_CameraApply		(BASEID_Camera-1)

#define PUSHBUTTONID_DOptDataReadout		(BASEID_DesignOptions - 1)
#define PUSHBUTTONID_DOptWorkingUnits		(BASEID_DesignOptions - 3)
#define PUSHBUTTONID_DOptAngle			(BASEID_DesignOptions - 4)
#define PUSHBUTTONID_DOptScale			(BASEID_DesignOptions - 5)
#define PUSHBUTTONID_DOptReferenceFile		(BASEID_DesignOptions - 6)
#define PUSHBUTTONID_DOptCellLibrary		(BASEID_DesignOptions - 7)
#define PUSHBUTTONID_DOptSavedViews		(BASEID_DesignOptions - 8)
#define PUSHBUTTONID_DOptACS			(BASEID_DesignOptions - 9)
#define PUSHBUTTONID_DOptEditUCI    	    	(BASEID_DesignOptions - 10)

#define PUSHBUTTONID_TextMatch			(BASEID_TextSettings - 1)

#define PUSHBUTTONID_TextEditApply		(BASEID_TextEdit-2)
#define PUSHBUTTONID_TextEditReset		(BASEID_TextEdit-3)

#define PUSHBUTTONID_MDLLoad			(BASEID_MDL-1)
#define PUSHBUTTONID_MDLUnload			(BASEID_MDL-2)
#define PUSHBUTTONID_MDLDetail			(BASEID_MDL-3)

#define PUSHBUTTONID_EnvVariablesNew		(BASEID_EnvVariables-1)
#define PUSHBUTTONID_EnvVariablesDelete		(BASEID_EnvVariables-2)
#define PUSHBUTTONID_EnvVariablesSave		(BASEID_EnvVariables-3)

#define PUSHBUTTONID_ColorPalette_Revert	(BASEID_ColorPalette-1)
#define PUSHBUTTONID_ColorPalette_Default	(BASEID_ColorPalette-2)
#define PUSHBUTTONID_ColorPalette_Attach	(BASEID_ColorPalette-3)

#define	PUSHBUTTONID_CmdBrowserExecute		(BASEID_CmdBrowser-1)
#define PUSHBUTTONID_StdFileSeed		(BASEID_StdFileSeedCreate-1)

#define PUSHBUTTONID_KSinkInsert		(BASEID_KitchenSink-1)
#define PUSHBUTTONID_KSinkDelete		(BASEID_KitchenSink-2)
#define PUSHBUTTONID_KSinkReset			(BASEID_KitchenSink-3)
#define PUSHBUTTONID_KSinkPalTest		(BASEID_KitchenSink-4)

#define PUSHBUTTONID_ReferenceRotateOK		(BASEID_ReferenceRotate-1)

#define PUSHBUTTONID_Precision          	(BASEID_Precision-1)

#define PUSHBUTTONID_FileListAdd		(BASEID_FileList-1)
#define PUSHBUTTONID_FileListRemove		(BASEID_FileList-2)
#define PUSHBUTTONID_FileListDone		(BASEID_FileList-3)
#define PUSHBUTTONID_FileListOK			(BASEID_FileList-4)

#define PUSHBUTTONID_PrefsMore			(BASEID_UserPreferences-1)

/*----------------------------------------------------------------------+
|									|
|   Raster Ids
|									|
+----------------------------------------------------------------------*/
#define RASTERID_ViewRotation		(BASEID_ViewRotation-1)
#define RASTERID_SmallClosedLock	(BASEID_ActiveScale-1)
#define RASTERID_SmallOpenLock		(BASEID_ActiveScale-2)

/*----------------------------------------------------------------------+
|									|
|   String List Ids							|
|									|
+----------------------------------------------------------------------*/
#define STRINGLISTID_KitchenSink	(BASEID_KitchenSink-1)

/*----------------------------------------------------------------------+
|									|
|   Text Item IDs							|
|									|
+----------------------------------------------------------------------*/
#define TEXTID_MasterPerGrid		(BASEID_GridSettings-1)
#define TEXTID_ReferenceGrid		(BASEID_GridSettings-2)
#define TEXTID_GridRatio		(BASEID_GridSettings-3)

#define TEXTID_SnapDivisor		(BASEID_Locks-1)
#define TEXTID_AxisStartAngle		(BASEID_Locks-2)
#define TEXTID_AxisIncrement		(BASEID_Locks-3)
#define TEXTID_UnitDistance		(BASEID_Locks-4)

#define TEXTID_ElementLevel		(BASEID_ElementAttributes-1)
#define TEXTID_ElementColor		(BASEID_ElementAttributes-2)
#define TEXTID_ElementStyle		(BASEID_ElementAttributes-3)
#define TEXTID_ElementWeight		(BASEID_ElementAttributes-4)

#define TEXTID_StrokeTolerance		(BASEID_Rendering-1)
#define TEXTID_MaxPolygonSize		(BASEID_Rendering-2)
#define TEXTID_StereoSeperation		(BASEID_Rendering-3)
#define TEXTID_AmbientIntensity		(BASEID_Rendering-4)
#define TEXTID_FlashIntensity		(BASEID_Rendering-5)
#define TEXTID_SolarIntensity		(BASEID_Rendering-6)
#define TEXTID_ReSunLatDeg		(BASEID_Rendering-7)
#define TEXTID_ReSunLatMin		(BASEID_Rendering-8)
#define TEXTID_ReSunLatSec		(BASEID_Rendering-9)
#define TEXTID_ReSunDay			(BASEID_Rendering-10)
#define TEXTID_ReSunHour		(BASEID_Rendering-11)
#define TEXTID_ReSunMinute		(BASEID_Rendering-12)
#define TEXTID_ReSunLonDeg		(BASEID_Rendering-13)
#define TEXTID_ReSunLonMin		(BASEID_Rendering-14)
#define TEXTID_ReSunLonSec		(BASEID_Rendering-15)

#define TEXTID_RefFileScale		(BASEID_ReferenceFile-1)
#define TEXTID_RefFileDescription	(BASEID_ReferenceFile-2)
#define TEXTID_RefFilePath		(BASEID_ReferenceFile-3)

#define	TEXTID_SpTolerance		(BASEID_SplinePrefs-1)
#define TEXTID_SpCurveOrder		(BASEID_SplinePrefs-2)
#define TEXTID_SpCurvePoles		(BASEID_SplinePrefs-3)
#define	TEXTID_SpSurfOrderU		(BASEID_SplinePrefs-4)
#define TEXTID_SpSurfOrderV		(BASEID_SplinePrefs-5)
#define TEXTID_SpSurfPolesU		(BASEID_SplinePrefs-6)
#define	TEXTID_SpSurfPolesV		(BASEID_SplinePrefs-7)
#define TEXTID_SpSurfRulesU		(BASEID_SplinePrefs-8)
#define TEXTID_SpSurfRulesV		(BASEID_SplinePrefs-9)

#define TEXTID_DimUMainString 	       	(BASEID_DimStrings	-1)
#define TEXTID_DimUUTolString 	       	(BASEID_DimStrings	-2)
#define TEXTID_DimULTolString 	       	(BASEID_DimStrings	-3)
#define TEXTID_DimLMainString 	       	(BASEID_DimStrings	-4)
#define TEXTID_DimLUTolString 	       	(BASEID_DimStrings	-5)
#define TEXTID_DimLLTolString 	       	(BASEID_DimStrings	-6)
#define TEXTID_DimUULimitString 	(BASEID_DimStrings	-7)
#define TEXTID_DimULLimitString 	(BASEID_DimStrings	-8)
#define TEXTID_DimLULimitString 	(BASEID_DimStrings	-9)
#define TEXTID_DimLLLimitString 	(BASEID_DimStrings     -10)

#define TEXTID_DimUpperTolerance       	(BASEID_DimTolerance    -1)
#define TEXTID_DimLowerTolerance       	(BASEID_DimTolerance    -2)

#define TEXTID_DimTextColor		(BASEID_DimAttributes	-1)
#define TEXTID_DimTextWeight		(BASEID_DimAttributes	-2)
#define TEXTID_DimTextFont		(BASEID_DimAttributes	-3)
#define TEXTID_DimElementColor		(BASEID_DimAttributes	-5)
#define TEXTID_DimElementWeight		(BASEID_DimAttributes	-6)
#define TEXTID_DimElementStyle		(BASEID_DimAttributes	-7)
#define TEXTID_DimAlternateColor	(BASEID_DimAttributes	-8)
#define TEXTID_DimAlternateWeight	(BASEID_DimAttributes	-9)
#define TEXTID_DimAlternateStyle	(BASEID_DimAttributes	-10)
#define TEXTID_DimPlacementLevel	(BASEID_DimAttributes	-11)
#define TEXTID_DimTextHeight	    	(BASEID_DimAttributes 	-12)
#define TEXTID_DimTextWidth 		(BASEID_DimAttributes 	-13)
#define TEXTID_DimTolTextScale	    	(BASEID_DimAttributes 	-14)

#define TEXTID_DimTermDotCell 		(BASEID_DimTerminators	-1)
#define TEXTID_DimTermOriginCell	(BASEID_DimTerminators	-2)
#define TEXTID_DimTermStrokeCell	(BASEID_DimTerminators	-3)
#define TEXTID_DimTermArrowCell 	(BASEID_DimTerminators	-4)
#define TEXTID_DimTermDotChar 		(BASEID_DimTerminators	-5)
#define TEXTID_DimTermOriginChar	(BASEID_DimTerminators	-6)
#define TEXTID_DimTermStrokeChar	(BASEID_DimTerminators	-7)
#define TEXTID_DimTermArrowChar		(BASEID_DimTerminators	-8)
#define TEXTID_DimTermDotFont		(BASEID_DimTerminators	-9)
#define TEXTID_DimTermOriginFont	(BASEID_DimTerminators	-10)
#define TEXTID_DimTermStrokeFont	(BASEID_DimTerminators	-11)
#define TEXTID_DimTermArrowFont		(BASEID_DimTerminators	-12)

#define TEXTID_DimSymbPrefixChar	(BASEID_DimSymbols 	-1)
#define TEXTID_DimSymbPrefixCell	(BASEID_DimSymbols 	-2)
#define TEXTID_DimSymbSuffixChar	(BASEID_DimSymbols 	-3)
#define TEXTID_DimSymbSuffixCell	(BASEID_DimSymbols 	-4)
#define TEXTID_DimSymbDiameterChar 	(BASEID_DimSymbols 	-5)
#define TEXTID_DimSymbPlusMinusChar 	(BASEID_DimSymbols 	-7)

#define TEXTID_DimSymbUpperPrefixChar	(BASEID_DimSymbols 	-9)
#define TEXTID_DimSymbMainPrefixChar 	(BASEID_DimSymbols 	-10)
#define TEXTID_DimSymbUpperSuffixChar	(BASEID_DimSymbols 	-11)
#define TEXTID_DimSymbLowerPrefixChar	(BASEID_DimSymbols 	-12)
#define TEXTID_DimSymbMainSuffixChar 	(BASEID_DimSymbols 	-13)
#define TEXTID_DimSymbTolrPrefixChar 	(BASEID_DimSymbols 	-14)
#define TEXTID_DimSymbLowerSuffixChar	(BASEID_DimSymbols 	-15)
#define TEXTID_DimSymbTolrSuffixChar 	(BASEID_DimSymbols 	-16)
#define TEXTID_DimSymbPrefixFont	(BASEID_DimSymbols 	-17)
#define TEXTID_DimSymbSuffixFont	(BASEID_DimSymbols 	-18)
#define TEXTID_DimSymbDiameterFont 	(BASEID_DimSymbols 	-19)
#define TEXTID_DimSymbPlusMinusFont 	(BASEID_DimSymbols 	-20)

#define TEXTID_DimCenterSize		(BASEID_DimGeometry    	-1)
#define TEXTID_DimStackOffset		(BASEID_DimGeometry    	-2)
#define TEXTID_DimTextMargin		(BASEID_DimGeometry    	-3)
#define TEXTID_DimScaleFactor		(BASEID_DimGeometry    	-4)
#define TEXTID_DimWitnessOffset		(BASEID_DimGeometry    	-5)
#define TEXTID_DimWitnessExtend		(BASEID_DimGeometry    	-6)
#define TEXTID_DimMainTextLift	    	(BASEID_DimGeometry    	-7)
#define TEXTID_DimTolTextLift	    	(BASEID_DimGeometry    	-8)
#define TEXTID_DimTolSeparation	    	(BASEID_DimGeometry    	-9)
#define TEXTID_DimMinimumLeader		(BASEID_DimGeometry    	-10)
#define TEXTID_DimTermWidth 		(BASEID_DimGeometry    	-11)
#define TEXTID_DimTermHeight		(BASEID_DimGeometry    	-12)

#define TEXTID_MLineOffset		(BASEID_Multiline    	-1)
#define TEXTID_MLineColor		(BASEID_Multiline    	-2)
#define TEXTID_MLineStyle		(BASEID_Multiline    	-3)
#define TEXTID_MLineWeight		(BASEID_Multiline    	-4)
#define TEXTID_MLineSCapAngle		(BASEID_Multiline    	-5)
#define TEXTID_MLineECapAngle		(BASEID_Multiline    	-6)
#define TEXTID_MLineFill		(BASEID_Multiline    	-7)
#define TEXTID_MLineLevel		(BASEID_Multiline    	-8)

/* Security key fields */
#define TEXTID_SecurityKeyDuration	(BASEID_GetSecurityKey-1)
#define	TEXTID_SecurityServerList	(BASEID_GetSecurityKey-2)

#define TEXTID_ACSName			(BASEID_AuxCoordSystems-1)
#define TEXTID_ACSDescrip		(BASEID_AuxCoordSystems-2)
#define TEXTID_ACSOriginX		(BASEID_AuxCoordSystems-3)
#define TEXTID_ACSOriginY		(BASEID_AuxCoordSystems-4)
#define TEXTID_ACSOriginZ		(BASEID_AuxCoordSystems-5)

/* working units */
#define TEXTID_WorkUnitsNameMU		(BASEID_WorkingUnits-1)
#define TEXTID_WorkUnitsNameSU		(BASEID_WorkingUnits-2)
#define TEXTID_WorkUnitsMU		(BASEID_WorkingUnits-3)
#define TEXTID_WorkUnitsSU		(BASEID_WorkingUnits-4)

#define TEXTID_ViewRotationAngle	(BASEID_ViewRotation-1)

#define TEXTID_EditCellName		(BASEID_CellMaintenance-1)
#define TEXTID_EditCellDescr		(BASEID_CellMaintenance-2)
#define TEXTID_CreateCellName		(BASEID_CellMaintenance-3)
#define TEXTID_CreateCellDescr		(BASEID_CellMaintenance-4)
#define TEXTID_LibraryName		(BASEID_CellMaintenance-5)

#define TEXTID_ActvAngleTol		(BASEID_ActiveAngle-1)
#define TEXTID_ActvAngle		(BASEID_ActiveAngle-2)

#define TEXTID_ActvScaleTol		(BASEID_ActiveScale-1)
#define TEXTID_ActvXScale		(BASEID_ActiveScale-2)
#define TEXTID_ActvYScale		(BASEID_ActiveScale-3)
#define TEXTID_ActvZScale		(BASEID_ActiveScale-4)

#define TEXTID_RefAttachLogicalName	(BASEID_RefAttach-1)
#define TEXTID_RefAttachDescription	(BASEID_RefAttach-2)
#define TEXTID_RefAttachMastScale	(BASEID_RefAttach-3)
#define TEXTID_RefAttachRefScale	(BASEID_RefAttach-4)

#define TEXTID_PlotDrawSetWidth		(BASEID_Plot-1)
#define TEXTID_PlotDrawSetHeight	(BASEID_Plot-2)
#define TEXTID_PlotDrawSetScale		(BASEID_Plot-3)
#define TEXTID_PlotOriginWidth		(BASEID_Plot-4)
#define TEXTID_PlotOriginHeight		(BASEID_Plot-5)
#define TEXTID_PlotOptComment		(BASEID_Plot-6)
#define TEXTID_PlotWidth		(BASEID_Plot-7)
#define TEXTID_PlotHeight		(BASEID_Plot-8)
#define TEXTID_PlotPageName		(BASEID_Plot-9)

#define TEXTID_PlotPgSzUnits		(BASEID_PlotPageSize-1)
#define TEXTID_PlotPgSzWidthDots	(BASEID_PlotPageSize-2)
#define TEXTID_PlotPgSzHeightDots	(BASEID_PlotPageSize-3)
#define TEXTID_PlotPgSzWidth		(BASEID_PlotPageSize-4)
#define TEXTID_PlotPgSzHeight		(BASEID_PlotPageSize-5)
#define TEXTID_PlotPgSzWidthOffset	(BASEID_PlotPageSize-6)
#define TEXTID_PlotPgSzHeightOffset	(BASEID_PlotPageSize-7)

#define TEXTID_PlotShowCfgName		(BASEID_PlotShow-1)
#define TEXTID_PlotShowModel		(BASEID_PlotShow-2)
#define TEXTID_PlotShowPens		(BASEID_PlotShow-3)
#define TEXTID_PlotShowName1		(BASEID_PlotShow-4)
#define TEXTID_PlotShowSize1		(BASEID_PlotShow-5)
#define TEXTID_PlotShowNumber1		(BASEID_PlotShow-6)
#define TEXTID_PlotShowOffset1		(BASEID_PlotShow-7)
#define TEXTID_PlotShowName2		(BASEID_PlotShow-8)
#define TEXTID_PlotShowSize2		(BASEID_PlotShow-9)
#define TEXTID_PlotShowNumber2		(BASEID_PlotShow-10)
#define TEXTID_PlotShowOffset2		(BASEID_PlotShow-11)
#define TEXTID_PlotShowName3		(BASEID_PlotShow-12)
#define TEXTID_PlotShowSize3		(BASEID_PlotShow-13)
#define TEXTID_PlotShowNumber3		(BASEID_PlotShow-14)
#define TEXTID_PlotShowOffset3		(BASEID_PlotShow-15)
#define TEXTID_PlotShowName4		(BASEID_PlotShow-16)
#define TEXTID_PlotShowSize4		(BASEID_PlotShow-17)
#define TEXTID_PlotShowNumber4		(BASEID_PlotShow-18)
#define TEXTID_PlotShowOffset4		(BASEID_PlotShow-19)
#define TEXTID_PlotShowName5		(BASEID_PlotShow-20)
#define TEXTID_PlotShowSize5		(BASEID_PlotShow-21)
#define TEXTID_PlotShowNumber5		(BASEID_PlotShow-22)
#define TEXTID_PlotShowOffset5		(BASEID_PlotShow-23)
#define TEXTID_PlotChangePens		(BASEID_PlotShow-24)
    
/* patterning settings */
#define TEXTID_PatternAngle		(BASEID_PatternSettings-1)
#define TEXTID_PatternAngleXHatch	(BASEID_PatternSettings-2)
#define TEXTID_PatternScale		(BASEID_PatternSettings-3)
#define TEXTID_PatternRows		(BASEID_PatternSettings-4)
#define TEXTID_PatternCols		(BASEID_PatternSettings-5)
#define TEXTID_PatternName		(BASEID_PatternSettings-6)

#define TEXTID_RotateACSX		(BASEID_RotateACS-1)
#define TEXTID_RotateACSY		(BASEID_RotateACS-2)
#define TEXTID_RotateACSZ		(BASEID_RotateACS-3)
#define TEXTID_LSymColor		(BASEID_LevSymb-1)
#define TEXTID_LSymStyl			(BASEID_LevSymb-2)
#define TEXTID_LSymWght			(BASEID_LevSymb-3)

#define TEXTID_DBDasType		(BASEID_DBSettings-1)

/* precision input */
#define TEXTID_PrecisionX		(BASEID_Precision-1)
#define TEXTID_PrecisionY		(BASEID_Precision-2)
#define TEXTID_PrecisionZ		(BASEID_Precision-3)
#define TEXTID_PrecisionDX      	(BASEID_Precision-4)
#define TEXTID_PrecisionDY      	(BASEID_Precision-5)
#define TEXTID_PrecisionDZ      	(BASEID_Precision-6)
#define TEXTID_PrecisionAngle   	(BASEID_Precision-7)
#define TEXTID_PrecisionDist    	(BASEID_Precision-8)

/* Color Square Text Fields */
#define TEXTID_ColorPal_Red		(BASEID_ColorPalette-1)
#define TEXTID_ColorPal_Green		(BASEID_ColorPalette-2)
#define TEXTID_ColorPal_Blue		(BASEID_ColorPalette-3)
#define TEXTID_ColorPal_Hue		(BASEID_ColorPalette-4)
#define TEXTID_ColorPal_Saturation	(BASEID_ColorPalette-5)
#define TEXTID_ColorPal_Value    	(BASEID_ColorPalette-6)
#define TEXTID_ColorPal_Index    	(BASEID_ColorPalette-7)

#define TEXTID_CameraLensLength		(BASEID_Camera-1)
#define TEXTID_CameraLensAngle		(BASEID_Camera-2)

#define TEXTID_TextFontNum		(BASEID_TextSettings-1)
#define TEXTID_TextWidth		(BASEID_TextSettings-2)
#define TEXTID_TextHeight		(BASEID_TextSettings-3)
#define TEXTID_TextLineSpace		(BASEID_TextSettings-4)
#define TEXTID_TextLineLength		(BASEID_TextSettings-5)
#define TEXTID_TextEDChar		(BASEID_TextSettings-6)

#define TEXTID_FunctionKeyString	(BASEID_FunctionKeys-1)

#define TEXTID_EnvVariablesName         (BASEID_EnvVariables-1)
#define TEXTID_EnvVariablesString	(BASEID_EnvVariables-2)

#define	TEXTID_MDLAppCodeSize		(BASEID_MDLDetail-1)
#define	TEXTID_MDLAppDataSize		(BASEID_MDLDetail-2)
#define	TEXTID_MDLAppStackSize		(BASEID_MDLDetail-3)
#define	TEXTID_MDLOpenFiles		(BASEID_MDLDetail-4)
#define	TEXTID_MDLOpenRscFiles		(BASEID_MDLDetail-5)
#define	TEXTID_MDLLoadedResources	(BASEID_MDLDetail-6)
#define	TEXTID_MDLResourceMem		(BASEID_MDLDetail-7)
#define TEXTID_MDLVersion		(BASEID_MDLDetail-8)

#define TEXTID_FileOpenFileName		(BASEID_StdFileOpen-1)
#define TEXTID_FileOpenFilter		(BASEID_StdFileOpen-2)
#define TEXTID_FileOpenDirLabel		(BASEID_StdFileOpen-3)

#define TEXTID_StreamDelta		(BASEID_Digitizing-1)
#define TEXTID_StreamTolerance  	(BASEID_Digitizing-2)
#define TEXTID_StreamAngle		(BASEID_Digitizing-3)
#define TEXTID_StreamArea		(BASEID_Digitizing-4)

#define TEXTID_KSinkExample		(BASEID_KitchenSink-1)

#define TEXTID_ImageXRes		(BASEID_Display-1)
#define TEXTID_ImageYRes		(BASEID_Display-2)

#define TEXTID_LevelEditNumber		(BASEID_NamedLevels-1)
#define TEXTID_LevelEditName		(BASEID_NamedLevels-2)
#define TEXTID_LevelEditComment		(BASEID_NamedLevels-3)
    
#define TEXTID_GroupEditName		(BASEID_GroupEdit-1)

#define TEXTID_PrefSmallestText		(BASEID_UserPreferences  -1)
#define TEXTID_PrefExactColors		(BASEID_UserPreferences  -2)
#define TEXTID_PrefLocateTolerance	(BASEID_UserPreferences  -3)
#define TEXTID_PrefMaxRefFiles		(BASEID_UserPreferences  -4)
#define TEXTID_PrefEnterDataChar	(BASEID_UserPreferences  -5)
#define TEXTID_PrefGridPtsView		(BASEID_UserPreferences  -6)
#define TEXTID_PrefGridRefsView		(BASEID_UserPreferences  -7)
#define TEXTID_PrefMemCacheSize		(BASEID_UserPreferences  -8)
#define TEXTID_PrefMemTaskSize		(BASEID_UserPreferences  -9)
#define TEXTID_PrefMemTaskSizeExt	(BASEID_UserPreferences  -10)
#define TEXTID_PrefMemUndoSize		(BASEID_UserPreferences  -11)
#define TEXTID_PrefMemRscCacheSize	(BASEID_UserPreferences  -12)

#define TEXTID_FileListFileName		(BASEID_FileList-1)
#define TEXTID_FileListFilter		(BASEID_FileList-2)
#define TEXTID_FileListDirLabel		(BASEID_FileList-3)

/*----------------------------------------------------------------------+
|									|
|   Multiline Text Ids  						|
|									|
+----------------------------------------------------------------------*/
#define MLTEXTID_TextEdit		(BASEID_TextEdit-1)
	
/*----------------------------------------------------------------------+
|									|
|   Scroll Bar Ids							|
|									|
+----------------------------------------------------------------------*/
/* Color Square Scroll Bars */
#define SCROLLID_ColorPal_Red		(BASEID_ColorPalette-1)
#define SCROLLID_ColorPal_Green		(BASEID_ColorPalette-2)
#define SCROLLID_ColorPal_Blue		(BASEID_ColorPalette-3)
#define SCROLLID_ColorPal_Hue		(BASEID_ColorPalette-4)
#define SCROLLID_ColorPal_Saturation	(BASEID_ColorPalette-5)
#define SCROLLID_ColorPal_Value    	(BASEID_ColorPalette-6)

/*----------------------------------------------------------------------+
|									|
|   Toggle Button IDs							|
|									|
+----------------------------------------------------------------------*/
#define TOGGLEID_LockGrid		(BASEID_Locks-1)
#define TOGGLEID_LockSnap		(BASEID_Locks-2)
#define TOGGLEID_LockAxis		(BASEID_Locks-3)
#define TOGGLEID_LockUnit		(BASEID_Locks-4)
#define TOGGLEID_LockGraphicGroup	(BASEID_Locks-5)
#define TOGGLEID_LockTextNode		(BASEID_Locks-6)
#define TOGGLEID_LockLevel		(BASEID_Locks-7)
#define TOGGLEID_LockBoreSite		(BASEID_Locks-8)
#define TOGGLEID_LockConstructPlane	(BASEID_Locks-9)
#define TOGGLEID_LockAssociation	(BASEID_Locks-10)
#define TOGGLEID_LockConstrSnap		(BASEID_Locks-11)
#define TOGGLEID_LockIsometric		(BASEID_Locks-12)
#define TOGGLEID_LockIntersection	(BASEID_Locks-13)

#define TOGGLEID_Example		(BASEID_KitchenSink-1)

#define TOGGLEID_ReAmbientOnOff		(BASEID_Rendering-1)
#define TOGGLEID_ReFlashOnOff		(BASEID_Rendering-2)
#define TOGGLEID_ReSunOnOff		(BASEID_Rendering-3)
#define TOGGLEID_UseCurTime		(BASEID_Rendering-4)

#define TOGGLEID_SpDispControlPoly	(BASEID_SplinePrefs-1)

#define TOGGLEID_CellShared		(BASEID_CellMaintenance  -1)

#define TOGGLEID_DimLeadingZero     	(BASEID_DimTextFormat	-4)
#define TOGGLEID_DimTrailingZero	(BASEID_DimTextFormat	-5)
#define TOGGLEID_DimCommaDecimal	(BASEID_DimTextFormat	-6)
#define TOGGLEID_DimUnderlineText	(BASEID_DimTextFormat	-7)

#define TOGGLEID_DimTmplLeftWitness 	(BASEID_DimTemplate     -1)
#define TOGGLEID_DimTmplRightWitness	(BASEID_DimTemplate     -2)
#define TOGGLEID_DimTmplStack 		(BASEID_DimTemplate     -3)
#define TOGGLEID_DimTmplArcSymbol 	(BASEID_DimTemplate     -4)
#define TOGGLEID_DimTmplCenterMark	(BASEID_DimTemplate     -6)

#define TOGGLEID_DimTextColor		(BASEID_DimAttributes	-1)
#define TOGGLEID_DimTextWeight		(BASEID_DimAttributes	-2)
#define TOGGLEID_DimTextFont		(BASEID_DimAttributes	-3)
#define TOGGLEID_DimElementColor	(BASEID_DimAttributes	-5)
#define TOGGLEID_DimElementWeight	(BASEID_DimAttributes	-6)
#define TOGGLEID_DimElementStyle	(BASEID_DimAttributes	-7)
#define TOGGLEID_DimAlternateColor	(BASEID_DimAttributes	-8)
#define TOGGLEID_DimAlternateWeight	(BASEID_DimAttributes	-9)
#define TOGGLEID_DimAlternateStyle	(BASEID_DimAttributes	-10)
#define TOGGLEID_DimPlacementLevel	(BASEID_DimAttributes	-11)
#define TOGGLEID_DimTextHeight		(BASEID_DimAttributes 	-12)
#define TOGGLEID_DimTextWidth		(BASEID_DimAttributes 	-13)

#define TOGGLEID_DimTolerance          	(BASEID_DimTolerance    -1)

#define TOGGLEID_DimPlaceRefUnits   	(BASEID_DimPlacement 	-1)
#define TOGGLEID_DimPlaceRelative   	(BASEID_DimPlacement 	-2)
#define TOGGLEID_DimJoinExternal    	(BASEID_DimPlacement 	-3)
#define TOGGLEID_DimGenerateWitness 	(BASEID_DimPlacement 	-4)

#define TOGGLEID_MLineDefColor		(BASEID_Multiline    	-1)
#define TOGGLEID_MLineDefStyle		(BASEID_Multiline    	-2)
#define TOGGLEID_MLineDefWeight		(BASEID_Multiline    	-3)
#define TOGGLEID_MLineDispJoints	(BASEID_Multiline    	-4)
#define TOGGLEID_MLineSCapLine		(BASEID_Multiline    	-5)
#define TOGGLEID_MLineSCapArc		(BASEID_Multiline    	-6)
#define TOGGLEID_MLineSCapInArc		(BASEID_Multiline    	-7)
#define TOGGLEID_MLineECapLine		(BASEID_Multiline    	-8)
#define TOGGLEID_MLineECapArc		(BASEID_Multiline    	-9)
#define TOGGLEID_MLineECapInArc		(BASEID_Multiline    	-10)
#define TOGGLEID_MLineDefFill		(BASEID_Multiline    	-11)
#define TOGGLEID_MLineDefLevel		(BASEID_Multiline    	-12)
#define TOGGLEID_MLineDefClass		(BASEID_Multiline    	-13)

/* Security key fields */

#define TOGGLEID_SecurityKeyOverwrite	(BASEID_GetSecurityKey-1)
#define TOGGLEID_SecurityDefaltOverride (BASEID_GetSecurityKey-2)

#define	TOGGLEID_DBDeleteLinked		(BASEID_DBSettings-1)
#define	TOGGLEID_DBFormsMode		(BASEID_DBSettings-2)
#define	TOGGLEID_DBConfirmMode		(BASEID_DBSettings-3)

#define TOGGLEID_AngleTolLock		(BASEID_ActiveAngle-1)

#define TOGGLEID_ScaleTolLock		(BASEID_ActiveScale-1)

#define TOGGLEID_RefFileDisplay		(BASEID_ReferenceFile-1)
#define TOGGLEID_RefFileSnap		(BASEID_ReferenceFile-2)
#define TOGGLEID_RefFileLocate		(BASEID_ReferenceFile-3)

#define TOGGLEID_PatternMatch		(BASEID_PatternSettings-1)

#define TOGGLEID_PlotUseFence		(BASEID_Plot-1)
#define TOGGLEID_PlotOptDrawBorder	(BASEID_Plot-2)
#define TOGGLEID_PlotOptRotate		(BASEID_Plot-3)
#define TOGGLEID_PlotOptDrawFence	(BASEID_Plot-4)

#define TOGGLEID_ViewGrid		(BASEID_ViewSettings-1)
#define TOGGLEID_ViewDimension		(BASEID_ViewSettings-2)
#define TOGGLEID_ViewPattern		(BASEID_ViewSettings-3)
#define TOGGLEID_ViewAreaFill		(BASEID_ViewSettings-4)
#define TOGGLEID_ViewEnterData		(BASEID_ViewSettings-5)
#define TOGGLEID_ViewConstructions	(BASEID_ViewSettings-6)
#define TOGGLEID_ViewLevelSymb		(BASEID_ViewSettings-7)
#define TOGGLEID_ViewTextNodes		(BASEID_ViewSettings-8)
#define TOGGLEID_ViewText		(BASEID_ViewSettings-9)
#define TOGGLEID_ViewFastFont		(BASEID_ViewSettings-10)
#define TOGGLEID_ViewFastCurve		(BASEID_ViewSettings-11)
#define TOGGLEID_ViewLineWeights	(BASEID_ViewSettings-12)
#define TOGGLEID_ViewACSTriad		(BASEID_ViewSettings-13)
#define TOGGLEID_ViewBackground		(BASEID_ViewSettings-14)
#define TOGGLEID_ViewDynamics		(BASEID_ViewSettings-15)
#define TOGGLEID_ViewCamera		(BASEID_ViewSettings-16)
#define TOGGLEID_ViewRefBoundary	(BASEID_ViewSettings-17)
#define TOGGLEID_ViewFastRefClip	(BASEID_ViewSettings-18)
#define TOGGLEID_ViewDepthCueing	(BASEID_ViewSettings-19)

#define TOGGLEID_OverColor		(BASEID_LevSymb-1)
#define TOGGLEID_OverStyle		(BASEID_LevSymb-2)
#define TOGGLEID_OverWght		(BASEID_LevSymb-3)
#define TOGGLEID_SetColor		(BASEID_LevSymb-4)
#define TOGGLEID_SetStyle		(BASEID_LevSymb-5)
#define TOGGLEID_SetWght		(BASEID_LevSymb-6)

#define TOGGLEID_TextMirror		(BASEID_TextSettings-1)
#define TOGGLEID_TextFractions		(BASEID_TextSettings-2)

#define TOGGLEID_StrDsply		(BASEID_Digitizing-1)

#define TOGGLEID_ImageStereo		(BASEID_Display-1)

#define TOGGLEID_ElementFill		(BASEID_ElementAttributes-1)

#define TOGGLEID_PrefResetFence		(BASEID_UserPreferences  -1)
#define TOGGLEID_PrefTitleBars		(BASEID_UserPreferences  -2)
#define TOGGLEID_PrefBothVirt		(BASEID_UserPreferences	 -3)
#define TOGGLEID_PrefInputFocus		(BASEID_UserPreferences	 -4)
#define TOGGLEID_PrefConserveMem	(BASEID_UserPreferences	 -5)


#define TOGGLEID_MorePrefLocateOn	(BASEID_MoreUserPref	 -1)
#define TOGGLEID_MorePrefSnapOn		(BASEID_MoreUserPref	 -2)
#define TOGGLEID_MorePrefTileIgds	(BASEID_MoreUserPref	 -4)
#define TOGGLEID_MorePrefTextLineStyle  (BASEID_MoreUserPref	 -3)
#define TOGGLEID_MorePrefStartParse	(BASEID_MoreUserPref	 -5)
#define TOGGLEID_MorePrefUseCTable	(BASEID_MoreUserPref	 -6)


/*----------------------------------------------------------------------+
|									|
|   Window Menu Id's							|
|									|
+----------------------------------------------------------------------*/
#define WINDOWMENUID_Main		(BASEID_WindowManMenu - 1)

/*----------------------------------------------------------------------+
|									|
|   Synonym Id's							|
|									|
+----------------------------------------------------------------------*/
#define SYNONYMID_ElementColor		(BASEID_ElementAttributes-1)
#define SYNONYMID_ElementStyle		(BASEID_ElementAttributes-2)
#define SYNONYMID_ElementWeight		(BASEID_ElementAttributes-3)
#define SYNONYMID_ElementArea		(BASEID_ElementAttributes-4)
#define SYNONYMID_ElementClass		(BASEID_ElementAttributes-5)
#define SYNONYMID_ElementFill		(BASEID_ElementAttributes-6)
#define SYNONYMID_SolidSurface		(BASEID_ElementAttributes-7)

#define SYNONYMID_MLineColor		(BASEID_Multiline-1)
#define SYNONYMID_MLineStyle		(BASEID_Multiline-2)
#define SYNONYMID_MLineWeight		(BASEID_Multiline-3)
#define SYNONYMID_MLineFill		(BASEID_Multiline-4)

#define SYNONYMID_DimElementColor	(BASEID_DimAttributes	-1)
#define SYNONYMID_DimElementStyle	(BASEID_DimAttributes	-2)
#define SYNONYMID_DimElementWeight	(BASEID_DimAttributes	-3)
#define SYNONYMID_DimAlternateColor	(BASEID_DimAttributes	-4)
#define SYNONYMID_DimAlternateStyle	(BASEID_DimAttributes	-5)
#define SYNONYMID_DimAlternateWeight	(BASEID_DimAttributes	-6)
#define SYNONYMID_DimTextColor		(BASEID_DimAttributes	-7)
#define SYNONYMID_DimTextWeight		(BASEID_DimAttributes	-8)
#define SYNONYMID_DimTemplate		(BASEID_DimTemplate  	-4)

#define SYNONYMID_ActiveScale		(BASEID_ActiveScale-1)
#define SYNONYMID_ActiveTermScale	(BASEID_ActiveScale-2)

#define SYNONYMID_ActiveAngle		(BASEID_ActiveAngle-1)
#define SYNONYMID_AngleTolLock		(BASEID_ActiveAngle-2)

#define SYNONYMID_RefLevelView		(BASEID_ReferenceLevels-1)

#define SYNONYMID_LSymWght		(BASEID_LevSymb-1)
#define SYNONYMID_LSymStyle		(BASEID_LevSymb-2)
#define SYNONYMID_LSymColor		(BASEID_LevSymb-3)

#define	SYNONYMID_GridSettings		(BASEID_GridSettings-1)
#define SYNONYMID_MasterPerGrid		(BASEID_GridSettings-2)
#define SYNONYMID_ReferenceGrid		(BASEID_GridSettings-3)
#define SYNONYMID_GridRatio		(BASEID_GridSettings-4)

#define SYNONYMID_TextString		(BASEID_TextSettings-1)
#define SYNONYMID_TextNode		(BASEID_TextSettings-2)
#define SYNONYMID_NodeSpace		(BASEID_TextSettings-3)
#define SYNONYMID_TagIncrement		(BASEID_TextSettings-4)
#define SYNONYMID_TextFontNum		(BASEID_TextSettings-5)
#define SYNONYMID_TextHeight		(BASEID_TextSettings-6)
#define SYNONYMID_TextWidth		(BASEID_TextSettings-7)
#define SYNONYMID_TextLineLength	(BASEID_TextSettings-8)

#define SYNONYMID_CameraView		(BASEID_Camera-1)
#define SYNONYMID_CameraLens		(BASEID_Camera-2)

#define SYNONYMID_ViewLevels		(BASEID_ViewLevels-1)

#define SYNONYMID_ViewSettings		(BASEID_ViewSettings-1)

#define SYNONYMID_PatternRowSpace	(BASEID_PatternSettings-1)
#define SYNONYMID_PatternColSpace	(BASEID_PatternSettings-2)
#define SYNONYMID_PatternScale		(BASEID_PatternSettings-3)
#define SYNONYMID_PatternAngle1		(BASEID_PatternSettings-4)
#define SYNONYMID_PatternAngle2		(BASEID_PatternSettings-5)
    
#define SYNONYMID_SetActiveCells	(BASEID_CellMaintenance-1)
    
#define SYNONYMID_WorkingUnitItems	(BASEID_WorkingUnits-1)

#define SYNONYMID_StreamDelta		(BASEID_Digitize-1)
#define SYNONYMID_StreamTolerance	(BASEID_Digitize-2)
#define SYNONYMID_StreamAngle		(BASEID_Digitize-3)
#define SYNONYMID_StreamArea		(BASEID_Digitize-4)

#define SYNONYMID_LockUnit		(BASEID_Locks-1)
#define SYNONYMID_SnapDivisor		(BASEID_Locks-2)
#define SYNONYMID_AxisStartAngle	(BASEID_Locks-3)
#define SYNONYMID_LockIntersection	(BASEID_Locks-4)
#define SYNONYMID_LockGrid		(BASEID_Locks-5)
#define SYNONYMID_LockTextNode		(BASEID_Locks-6)
#define SYNONYMID_LockLevel		(BASEID_Locks-7)
#define SYNONYMID_LockGraphicGroup	(BASEID_Locks-8)
#define SYNONYMID_LockBoreSite		(BASEID_Locks-9)
#define SYNONYMID_LockConstructPlane	(BASEID_Locks-10)
#define SYNONYMID_LockFenceMode		(BASEID_Locks-11)
#define SYNONYMID_LockSnap		(BASEID_Locks-12)
#define SYNONYMID_LockSnapMode		(BASEID_Locks-13)
#define SYNONYMID_LockAssociation	(BASEID_Locks-14)
#define SYNONYMID_LockConstrSnap	(BASEID_Locks-15)
#define SYNONYMID_LockAxis		(BASEID_Locks-16)
#define SYNONYMID_AxisIncrement		(BASEID_Locks-17)
#define SYNONYMID_UnitDistance		(BASEID_Locks-18)
#define SYNONYMID_LockIsometric		(BASEID_Locks-19)
#define SYNONYMID_IsoLockPlane		(BASEID_Locks-20)
#define SYNONYMID_CellStretch		(BASEID_Locks-21)

#define SYNONYMID_DBLinkMode		(BASEID_DBSettings-1)
#define SYNONYMID_DBDasType		(BASEID_DBSettings-2)
#define SYNONYMID_DBDeleteLinked	(BASEID_DBSettings-3)
#define SYNONYMID_DBFormsMode		(BASEID_DBSettings-4)
#define SYNONYMID_DBConfirmMode		(BASEID_DBSettings-5)

/*----------------------------------------------------------------------+
|									|
|   Hook Id's								|
|									|
+----------------------------------------------------------------------*/
#define HOOKITEMID_Command_CommandWindow    (BASEID_CommandWindow-1)
#define HOOKITEMID_MenuBar_CommandWindow    (BASEID_CommandWindow-2)
#define HOOKITEMID_ColorPicker_CmdWindow    (BASEID_CommandWindow-3)
#define HOOKITEMID_WeightPulldown_CmdWindow (BASEID_CommandWindow-4)
#define HOOKITEMID_StylePulldown_CmdWindow  (BASEID_CommandWindow-5) 

#define HOOKITEMID_Popup_CoordAccuracy	    (BASEID_CoordReadout-1)

#define HOOKDIALOGID_KitchenSink	    (BASEID_KitchenSink-1)
#define HOOKITEMID_Toggle_KitchenSink	    (BASEID_KitchenSink-2)
#define HOOKITEMID_List_KitchenSink	    (BASEID_KitchenSink-3)
#define HOOKITEMID_Text_KitchenSink	    (BASEID_KitchenSink-4)
#define HOOKITEMID_PushButton_KitchenSink   (BASEID_KitchenSink-5)
#define HOOKID_Dummy			    (BASEID_KitchenSink-6)

#define HOOKITEMID_List_ReferenceFile	    (BASEID_ReferenceFile-1)
#define HOOKITEMID_PullDown_RefLevels	    (BASEID_ReferenceFile-2)
#define HOOKITEMID_PullDown_RefLevSymb	    (BASEID_ReferenceFile-3)
#define HOOKITEMID_Toggle_ReferenceFile	    (BASEID_ReferenceFile-4)
#define HOOKITEMID_Text_ReferenceFileDesc   (BASEID_ReferenceFile-5)
#define HOOKITEMID_MenuBar_ReferenceFiles   (BASEID_ReferenceFile-6)

#define HOOKITEMID_List_SavedViews	    (BASEID_SavedViews-1)

#define HOOKDIALOGID_Rendering		    (BASEID_Rendering-1)
#define HOOKITEMID_Popup_Rendering	    (BASEID_Rendering-2)
#define HOOKITEMID_Text_Rendering	    (BASEID_Rendering-3)
#define HOOKITEMID_Generic_AmbientColor	    (BASEID_Rendering-4)
#define HOOKITEMID_Text_Intensity	    (BASEID_Rendering-5)
#define HOOKITEMID_Toggle_UseCurTime	    (BASEID_Rendering-6)

#define HOOKITEMID_Button_StandardAction    (-10)
#define HOOKITEMID_OptionButton_View	    (-11)

#define HOOKITEMID_Text_Splines		    (BASEID_SplinePrefs-1)

#define HOOKITEMID_List_MLine		    (BASEID_Multiline-1)
#define HOOKITEMID_Button_MLineAdd	    (BASEID_Multiline-2)
#define HOOKITEMID_Button_MLineDel	    (BASEID_Multiline-3)
#define HOOKITEMID_Button_MLineUpdate	    (BASEID_Multiline-4)
#define HOOKITEMID_Text_MLineUpdate	    (BASEID_Multiline-5)
#define HOOKDIALOGID_MLine		    (BASEID_Multiline-6)
#define HOOKITEMID_Option_MLine		    (BASEID_Multiline-7)
#define HOOKITEMID_Generic_MLine	    (BASEID_Multiline-8)
#define HOOKITEMID_Toggle_MLineFill	    (BASEID_Multiline-9)
#define HOOKITEMID_Toggle_MLineLevel	    (BASEID_Multiline-10)
#define HOOKITEMID_Toggle_MLineClass	    (BASEID_Multiline-11)

#define HOOKITEMID_DimTextPlaceMode	    (BASEID_DimPlacement  -1)
#define HOOKITEMID_DimPlaceMenuBar	    (BASEID_DimPlacement  -2)
#define HOOKITEMID_DimAxisOptionHook	    (BASEID_DimPlacement  -3)
#define HOOKITEMID_DimSymbPopupHook	    (BASEID_DimSymbols    -1)
#define HOOKITEMID_DimGreyPrevious	    (BASEID_DimAttributes -1)
#define HOOKITEMID_DimGreyHidePrevious	    (BASEID_DimAttributes -2)
#define HOOKITEMID_DimTextScaleLock	    (BASEID_DimAttributes -3)
#define HOOKITEMID_DimTextToggle	    (BASEID_DimAttributes -4)
#define HOOKITEMID_DimTextScale		    (BASEID_DimAttributes -5)
#define HOOKITEMID_DimTmplShowHide	    (BASEID_DimTemplate   -1)
#define HOOKDIALOGID_DimTextEdit	    (BASEID_DimStrings	  -1)
#define HOOKITEMID_DimLengthFormat	    (BASEID_DimTextFormat -1)

#define HOOKDIALOGID_TextEdit		    (BASEID_TextEdit-1)
#define	HOOKITEMID_Text_TextEdit	    (BASEID_TextEdit-2)
#define	HOOKITEMID_Startup_TextEdit	    (BASEID_TextEdit-3)

#define HOOKITEMID_Toggle_dbSettings	    (BASEID_DBSettings-1)
#define HOOKITEMID_Popup_dbSettings	    (BASEID_DBSettings-2)

#define HOOKDIALOGID_ViewRotation	    (BASEID_ViewRotation-1)
#define HOOKITEMID_ViewRotationDisplay	    (BASEID_ViewRotation-2)
#define HOOKITEMID_ViewRotationApply	    (BASEID_ViewRotation-3)
#define HOOKITEMID_ViewRotationStandard	    (BASEID_ViewRotation-4)
#define HOOKITEMID_ViewRotationButton	    (BASEID_ViewRotation-5)
#define HOOKITEMID_ViewRotationNumber	    (BASEID_ViewRotation-6)
#define HOOKITEMID_ViewRotationSystem	    (BASEID_ViewRotation-7)

#define HOOKDIALOGID_WorkingUnits	    (BASEID_WorkingUnits-1)

#define HOOKDIALOGID_AuxSystems		    (BASEID_AuxCoordSystems-1)
#define HOOKITEMID_Button_ACSAttach	    (BASEID_AuxCoordSystems-2)
#define HOOKITEMID_Button_ACSDelete	    (BASEID_AuxCoordSystems-3)
#define HOOKITEMID_Button_ACSSave	    (BASEID_AuxCoordSystems-4)
#define HOOKITEMID_Text_ACSDescrip	    (BASEID_AuxCoordSystems-5)
#define HOOKITEMID_Text_ACSName		    (BASEID_AuxCoordSystems-6)
#define HOOKITEMID_Text_ACSOrigin	    (BASEID_AuxCoordSystems-7)
#define HOOKITEMID_Popup_ACSType	    (BASEID_AuxCoordSystems-8)
#define HOOKITEMID_EnableFor3dOnly	    (BASEID_AuxCoordSystems-9)

#define HOOKDIALOGID_CellMaintenance	    (BASEID_CellMaintenance-1)
#define HOOKDIALOGID_CellCreate		    (BASEID_CellCreate-1)
#define HOOKITEMID_Text_EditCell	    (BASEID_CellCreate-2)
#define HOOKITEMID_Text_CreateCell          (BASEID_CellCreate-3)
#define HOOKITEMID_List_CellMaint	    (BASEID_CellCreate-4)
#define HOOKITEMID_Generic_Cell		    (BASEID_CellCreate-5)
#define HOOKITEMID_Popup_LinkMode	    (BASEID_CellCreate-6)
#define HOOKITEMID_Option_Cell		    (BASEID_CellCreate-7)

#define	HOOKITEMID_Text_ActvAngle	    (BASEID_ActiveAngle-1)
#define	HOOKITEMID_Generic_ActvAngle	    (BASEID_ActiveAngle-2)

#define	HOOKITEMID_Text_ActvScale	    (BASEID_ActiveScale-1)
#define	HOOKITEMID_Button_ActvScale	    (BASEID_ActiveScale-2)
#define	HOOKITEMID_Generic_ActvScale	    (BASEID_ActiveScale-3)

#define	HOOKDIALOGID_GetSecurityKey	    (BASEID_GetSecurityKey-1)
#define	HOOKITEMID_Text_secServerSearchList (BASEID_GetSecurityKey-2)
#define	HOOKITEMID_Toggle_secDurationORide  (BASEID_GetSecurityKey-3)
#define	HOOKITEMID_Button_secGetKey	    (BASEID_GetSecurityKey-4)
#define	HOOKITEMID_SubMenu_secTimeLeft	    (BASEID_GetSecurityKey-5)

#define HOOKITEMID_PreviewPlot		    (BASEID_Plot-1)
#define HOOKDIALOGID_PreviewPlot	    (BASEID_Plot-2)
#define HOOKDIALOGID_PlotPageSize	    (BASEID_Plot-3)
#define HOOKITEMID_PlotPageSize		    (BASEID_Plot-4)
#define HOOKDIALOGID_ShowPlotter	    (BASEID_Plot-5)
#define HOOKITEMID_PlotOptions		    (BASEID_Plot-6)

#define HOOKDIALOGID_ViewLevels		    (BASEID_ViewLevels-1)
#define HOOKITEMID_Button_ViewLevels	    (BASEID_ViewLevels-2)
#define HOOKITEMID_ViewLevelsView	    (BASEID_ViewLevels-3)

#define HOOKDIALOGID_RefLevels		    (BASEID_ReferenceLevels-1)
#define HOOKITEMID_Button_RefLevels	    (BASEID_ReferenceLevels-2)
#define HOOKITEMID_RefLevelsView	    (BASEID_ReferenceLevels-3)

#define HOOKDIALOGID_ViewSettings	    (BASEID_ViewSettings-1)
#define HOOKITEMID_Button_ViewSettings	    (BASEID_ViewSettings-2)
#define HOOKITEMID_ViewSettingsView	    (BASEID_ViewSettings-3)

#define HOOKDIALOGID_CmdBrowser		    (BASEID_CmdBrowser-1)
#define HOOKITEMID_List_CmdBrowser	    (BASEID_CmdBrowser-2)
#define	HOOKITEMID_Button_CmdBrowser	    (BASEID_CmdBrowser-3)

#define HOOKDIALOGID_PatternSettings	    (BASEID_PatternSettings-1)
#define	HOOKITEMID_Button_PatternHooks	    (BASEID_PatternSettings-2)
#define	HOOKITEMID_Text_PatternName	    (BASEID_PatternSettings-3)
#define	HOOKITEMID_Generic_PatternAngle	    (BASEID_PatternSettings-4)
#define	HOOKITEMID_Text_PatternAngle	    (BASEID_PatternSettings-5)

#define HOOKDIALOGID_Font		    (BASEID_Font-1)
#define HOOKITEMID_FontList		    (BASEID_Font-2)
#define HOOKITEMID_FontDisplay		    (BASEID_Font-3)

#define HOOKDIALOGID_ColorPalette    	    (BASEID_ColorPalette-1)
#define HOOKITEMID_ColorPaletteDisplay	    (BASEID_ColorPalette-2)
#define HOOKDIALOGID_ColorSquare    	    (BASEID_ColorPalette-3)
#define HOOKITEMID_Text_ColorSquare    	    (BASEID_ColorPalette-4)
#define HOOKITEMID_Generic_UpdateCell  	    (BASEID_ColorPalette-5)
#define HOOKITEMID_Generic_ColorSquare 	    (BASEID_ColorPalette-6)
#define HOOKITEMID_Scroll_ColorSquare       (BASEID_ColorPalette-7)
#define HOOKITEMID_Button_ColorPalette	    (BASEID_ColorPalette-8)
#define HOOKITEMID_Generic_Wedge    	    (BASEID_ColorPalette-9)
#define HOOKITEMID_PullDown_ColorPalette    (BASEID_ColorPalette-10)

#define HOOKDIALOGID_LevSymb		    (BASEID_LevSymb-1)
#define HOOKITEMID_List_LevSymb		    (BASEID_LevSymb-3)

#define HOOKITEMID_List_FunctionKeys	    (BASEID_FunctionKeys-1)
#define HOOKITEMID_Text_FunctionKeys	    (BASEID_FunctionKeys-2)
#define HOOKITEMID_PullDown_FunctionKeys    (BASEID_FunctionKeys-3)

#define HOOKITEMID_List_EnvVariables	    (BASEID_EnvVariables-1)
#define HOOKITEMID_Text_EnvVariablesName    (BASEID_EnvVariables-2)
#define HOOKITEMID_Text_EnvVariablesString  (BASEID_EnvVariables-3)
#define HOOKITEMID_PushButton_EnvVariables  (BASEID_EnvVariables-4)

#define HOOKITEMID_Popup_GridSettings	    (BASEID_GridSettings-1)
#define HOOKITEMID_Text_GridRatio	    (BASEID_GridSettings-2)
#define HOOKDIALOGID_GridSettings	    (BASEID_GridSettings-3)

#define	HOOKITEMID_Text_Scale		    (BASEID_TextSettings-1)
#define	HOOKITEMID_Generic_TextLock	    (BASEID_TextSettings-2)
#define	HOOKITEMID_Generic_TextStrJust	    (BASEID_TextSettings-3)
#define	HOOKITEMID_Generic_TextNodeJust	    (BASEID_TextSettings-4)
#define	HOOKITEMID_Popup_TextStrJust	    (BASEID_TextSettings-5)
#define	HOOKITEMID_Popup_TextNodeJust	    (BASEID_TextSettings-6)
#define	HOOKITEMID_Button_TextMatch	    (BASEID_TextSettings-7)

#define HOOKDIALOGID_MDL		    (BASEID_MDL-1)
#define	HOOKITEMID_Button_MDL		    (BASEID_MDL-2)
#define HOOKITEMID_List_MDLLoaded	    (BASEID_MDL-3)
#define HOOKITEMID_List_MDLAvailable	    (BASEID_MDL-4)
#define HOOKDIALOGID_MDLDetail		    (BASEID_MDLDetail-1)

#define	HOOKDIALOGID_Precision		    (BASEID_Precision-1)
#define HOOKITEMID_Precision		    (BASEID_Precision-2)
#define HOOKITEMID_PrecisionUnits	    (BASEID_Precision-3)

#define HOOKITEMID_List_FileOpenFiles	    (BASEID_StdFileOpen-1)
#define HOOKITEMID_List_FileOpenDirs	    (BASEID_StdFileOpen-2)
#define HOOKITEMID_Text_FileOpenFilename    (BASEID_StdFileOpen-3)
#define HOOKDIALOGID_FileSeedCreate	    (BASEID_StdFileOpen-4)
#define HOOKITEMID_Text_FileOpenFilter	    (BASEID_StdFileOpen-5)

#define HOOKITEMID_Text_Digitizing	    (BASEID_Digitizing-1)
#define HOOKITEMID_MenuBar_Digitizing	    (BASEID_Digitizing-2)

#define HOOKDIALOGID_ReferenceAttach	    (BASEID_RefAttach-1)
#define HOOKITEMID_List_ReferenceAttach	    (BASEID_RefAttach-2)
#define	HOOKITEMID_Text_RefAttachLogical    (BASEID_RefAttach-3)
#define HOOKITEMID_Text_RefAttachScale	    (BASEID_RefAttach-4)
    
#define HOOKDIALOGID_ReferenceScale	    (BASEID_ReferenceScale-1)

#define HOOKITEMID_Popup_DisplayType	    (BASEID_Display-1)
#define HOOKDIALOGID_Image		    (BASEID_Display-2)
#define HOOKDIALOGID_ImageSave		    (BASEID_Display-3)
#define HOOKITEMID_Option_ImageType	    (BASEID_Display-4)
#define HOOKITEMID_Text_ImageXRes	    (BASEID_Display-5)
#define HOOKITEMID_Text_ImageYRes	    (BASEID_Display-6)
#define HOOKITEMID_Option_ViewNumber	    (BASEID_Display-7)

#define HOOKITEMID_Button_SeedFile	    (BASEID_StdFileSeedCreate-2)

#define HOOKITEMID_Palmain_SDActCellHook    (BASEID_MainFrame-1)
#define HOOKITEMID_Palmain_SDPointTypeHook  (BASEID_MainFrame-2)
#define HOOKITEMID_Palmain_SDPointCharHook  (BASEID_MainFrame-3)
#define HOOKITEMID_Palmain_SDPointCellHook  (BASEID_MainFrame-4)
#define HOOKITEMID_Text_PatCell		    (BASEID_MainFrame-5)
#define HOOKDIALOGID_3dPal_Close3dPalette   (BASEID_MainFrame-6)

#define HOOKDIALOGID_RotateACS		    (BASEID_RotateACS-1)

#define HOOKDIALOGID_Camera		    (BASEID_Camera-1)
#define HOOKITEMID_PopupMenu_CameraView	    (BASEID_Camera-2)
#define HOOKITEMID_PopupMenu_CameraLens	    (BASEID_Camera-3)
#define HOOKITEMID_Button_CameraApply	    (BASEID_Camera-4)
#define HOOKITEMID_Text_CameraLens	    (BASEID_Camera-5)

#define HOOKITEMID_List_TextFileDisplay	    (BASEID_TextFileDisplay-1)

#define HOOKITEMID_OptionButton_FenceLock    (BASEID_Locks-1)
#define HOOKITEMID_OptionButton_SnapLock     (BASEID_Locks-2)
#define HOOKITEMID_OptionButton_IsoLockPlane (BASEID_Locks-3)
#define HOOKITEMID_AssociationLock     	     (BASEID_Locks-4)

#define HOOKDIALOGID_NamedLevels	    (BASEID_NamedLevels-1)
#define HOOKITEMID_NamedLevels_Levels	    (BASEID_NamedLevels-2)
#define HOOKITEMID_NamedLevels_Groups	    (BASEID_NamedLevels-3)
#define HOOKITEMID_NamedLevels_Pulldown	    (BASEID_NamedLevels-4)
#define HOOKITEMID_NamedLevels_SortButton   (BASEID_NamedLevels-5)
#define HOOKITEMID_NamedLevels_MenuBar      (BASEID_NamedLevels-6)
#define HOOKDIALOGID_LevelEdit		    (BASEID_LevelEdit-1)
#define HOOKITEMID_LevelEdit_Text	    (BASEID_LevelEdit-2)
#define HOOKDIALOGID_GroupEdit		    (BASEID_GroupEdit-1)
#define HOOKITEMID_GroupEdit_Text	    (BASEID_GroupEdit-2)

#define HOOKDIALOGID_ToolSettings	    (BASEID_ToolSettings - 1)

#define HOOKDIALOGID_AboutUstn		    (BASEID_AboutUstn-1)

#define HOOKDIALOGID_UserPreferences	    (BASEID_UserPreferences-1)
#define HOOKITEMID_PrefLayout		    (BASEID_UserPreferences-2)
#define HOOKDIALOGID_MorePreferences	    (BASEID_MoreUserPref-1)

#define	HOOKDIALOGID_FileList		    (BASEID_FileList-1)
#define	HOOKITEMID_Button_FileListAdd	    (BASEID_FileList-2)
#define	HOOKITEMID_Button_FileListRemove    (BASEID_FileList-3)
#define	HOOKITEMID_List_FileListName	    (BASEID_FileList-4)
#define HOOKITEMID_List_FileListFile	    (BASEID_FileList-5)
#define	HOOKITEMID_List_FileListDirectory   (BASEID_FileList-6)
#define	HOOKITEMID_Text_FileListFilter	    (BASEID_FileList-7)
#define	HOOKITEMID_Text_FileListFilename    (BASEID_FileList-8)
#define	HOOKITEMID_Text_FileListDirLabel    (BASEID_FileList-9)
#define	HOOKITEMID_Button_FileListOK	    (BASEID_FileList-10)

#define HOOKDIALOGID_BasicLocks		    (BASEID_BasicLocks-1)

#define HOOKITEMID_List_DialogMessages      (BASEID_DialogMessages-1)
#define HOOKITEMID_Pulldown_WindowMenu	    (BASEID_WindowManMenu-1)


/*----------------------------------------------------------------------+
|									|
|   Command Window Menu Bar Item search Id's				|
|									|
|   Along with menuId's these item id's are used to find an item.	|
|   They only need to be unique within a given menu.			|
|									|
+----------------------------------------------------------------------*/
/* File Menu */
#define MENUSEARCHID_File_New		    1
#define MENUSEARCHID_File_Open		    2
#define MENUSEARCHID_File_CellLibrary	    3
#define MENUSEARCHID_File_Reference	    4
#define MENUSEARCHID_File_Close		    5
#define MENUSEARCHID_File_SaveAs	    6
#define MENUSEARCHID_File_CompressDgn	    7
#define MENUSEARCHID_File_SaveSettings	    8
#define MENUSEARCHID_File_Plot		    9
#define MENUSEARCHID_File_Import	    10
#define MENUSEARCHID_File_Export	    11
#define MENUSEARCHID_File_Display	    12
#define MENUSEARCHID_File_SaveImageAs	    13
#define MENUSEARCHID_File_Exit		    14

/* Cell Library Submenu */
#define	MENUSEARCHID_CellLibSub_New	    1
#define	MENUSEARCHID_CellLibSub_Attach	    2
#define MENUSEARCHID_CellLibSub_Compress    3

/* Display Submenu */
#define MENUSEARCHID_DisplaySub_Image	    1
#define MENUSEARCHID_DisplaySub_Text	    2

/* Export Submenu */
#define MENUSEARCHID_ExportSub_DXF	    1
#define MENUSEARCHID_ExportSub_RIB	    2
#define MENUSEARCHID_ExportSub_Edges	    3
#define	MENUSEARCHID_ExportSub_2d3d	    4

/* Import Submenu */
#define MENUSEARCHID_ImportSub_DXF	    1
#define MENUSEARCHID_ImportSub_Text	    2

/* Edit Menu */
#define MENUSEARCHID_Edit_Undo		    1
#define MENUSEARCHID_Edit_Redo		    2
#define MENUSEARCHID_Edit_SetMark	    3
#define MENUSEARCHID_Edit_Cut		    4
#define MENUSEARCHID_Edit_Copy		    5
#define MENUSEARCHID_Edit_Paste		    6
#define MENUSEARCHID_Edit_Clear		    7
#define MENUSEARCHID_Edit_Duplicate	    8
#define MENUSEARCHID_Edit_SelectAll	    9
#define MENUSEARCHID_Edit_Group		    10
#define MENUSEARCHID_Edit_Ungroup	    11
#define MENUSEARCHID_Edit_Lock		    12
#define MENUSEARCHID_Edit_Unlock	    13

/* Edit Undo Submenu */
#define MENUSEARCHID_EditUndoSub_Last	    1
#define MENUSEARCHID_EditUndoSub_ToMark	    2
#define MENUSEARCHID_EditUndoSub_All	    3

/* Element Menu */
#define MENUSEARCHID_Element_Color	    1
#define MENUSEARCHID_Element_Style	    2
#define MENUSEARCHID_Element_Weight	    3
#define MENUSEARCHID_Element_Info	    4
#define MENUSEARCHID_Element_Attributes	    5
#define MENUSEARCHID_Element_BSplines	    6
#define MENUSEARCHID_Element_Dimensions	    7
#define MENUSEARCHID_Element_MultiLines	    8
#define MENUSEARCHID_Element_Text	    9

/* Element Dimensioning Submenu */
#define MENUSEARCHID_EleDimSub_Placement    1
#define MENUSEARCHID_EleDimSub_Attributes   2
#define MENUSEARCHID_EleDimSub_Geometry	    3
#define MENUSEARCHID_EleDimSub_TextFormat   4
#define MENUSEARCHID_EleDimSub_Tolerance    5
#define MENUSEARCHID_EleDimSub_GeomTol	    6
#define MENUSEARCHID_EleDimSub_CustSymbols  7
#define MENUSEARCHID_EleDimSub_CustTerms    8
#define MENUSEARCHID_EleDimSub_ToolSettings 9

/* Settings Menu */
#define MENUSEARCHID_Settings_PrecInput	    1
#define MENUSEARCHID_Settings_ActiveAngle   2
#define MENUSEARCHID_Settings_ActiveScale   3
#define MENUSEARCHID_Settings_AuxCoords	    4
#define MENUSEARCHID_Settings_Cells	    5
#define MENUSEARCHID_Settings_ColorPalette  6
#define MENUSEARCHID_Settings_CoordReadout  7
#define MENUSEARCHID_Settings_Database	    8
#define MENUSEARCHID_Settings_Digitizing    9
#define MENUSEARCHID_Settings_Fonts	    10
#define MENUSEARCHID_Settings_Grid	    11
#define MENUSEARCHID_Settings_LevelNames    12
#define MENUSEARCHID_Settings_LevelSymb	    13
#define MENUSEARCHID_Settings_Locks	    14
#define MENUSEARCHID_Settings_Patterning    15
#define MENUSEARCHID_Settings_Rendering	    16
#define MENUSEARCHID_Settings_WorkingUnits  17
#define MENUSEARCHID_Settings_ToolSettings  18

/* Locks Submenu */
#define MENUSEARCHID_LocksSubFull	    1
#define MENUSEARCHID_LocksSubToggles	    2

/* View Menu */
#define MENUSEARCHID_View_OpenClose	    1
#define MENUSEARCHID_View_BottomToTop	    2
#define MENUSEARCHID_View_Cascade	    3
#define MENUSEARCHID_View_Tile		    4
#define MENUSEARCHID_View_Swap		    5
#define MENUSEARCHID_View_Update	    6
#define MENUSEARCHID_View_Copy		    7
#define MENUSEARCHID_View_Fit	    	    8
#define MENUSEARCHID_View_Window	    9
#define MENUSEARCHID_View_Zoom		    10
#define MENUSEARCHID_View_Camera	    11
#define MENUSEARCHID_View_Render	    12
#define MENUSEARCHID_View_Attributes	    13
#define MENUSEARCHID_View_Levels	    14
#define MENUSEARCHID_View_Rotation	    15
#define MENUSEARCHID_View_Saved		    16

/* View Open/Close Submenu */
#define MENUSEARCHID_ViewOpenCloseSub_1	    1
#define MENUSEARCHID_ViewOpenCloseSub_2	    2
#define MENUSEARCHID_ViewOpenCloseSub_3	    3
#define MENUSEARCHID_ViewOpenCloseSub_4	    4
#define MENUSEARCHID_ViewOpenCloseSub_5	    5
#define MENUSEARCHID_ViewOpenCloseSub_6	    6
#define MENUSEARCHID_ViewOpenCloseSub_7	    7
#define MENUSEARCHID_ViewOpenCloseSub_8	    8

/* View Update Submenu */
#define MENUSEARCHID_ViewUpdateSub_View	    1
#define MENUSEARCHID_ViewUpdateSub_All	    2
#define MENUSEARCHID_ViewUpdateSub_IFence   3
#define MENUSEARCHID_ViewUpdateSub_OFence   4
#define MENUSEARCHID_ViewUpdateSub_Grid	    5

/* View Fit Submenu */
#define MENUSEARCHID_ViewFitSub_Design	    1
#define MENUSEARCHID_ViewFitSub_All	    2
#define MENUSEARCHID_ViewFitSub_Reference   3

/* View Window Submenu */
#define MENUSEARCHID_ViewWinSub_Area	    1
#define MENUSEARCHID_ViewWinSub_Center	    2
#define MENUSEARCHID_ViewWinSub_Volume	    3

/* View Zoom Submenu */
#define MENUSEARCHID_ViewZoomSub_In	    1
#define MENUSEARCHID_ViewZoomSub_Out	    2

/* View Camera Submenu */
#define MENUSEARCHID_ViewCamSub_Setup	    1
#define MENUSEARCHID_ViewCamSub_Position    2
#define MENUSEARCHID_ViewCamSub_Target	    3
#define MENUSEARCHID_ViewCamSub_Lens	    4

/* View Render Submenu */
#define MENUSEARCHID_ViewRndrSub_WMesh	    1
#define MENUSEARCHID_ViewRndrSub_CSection   2
#define MENUSEARCHID_ViewRndrSub_HLine	    3
#define MENUSEARCHID_ViewRndrSub_FHLine	    4
#define MENUSEARCHID_ViewRndrSub_Constant   5
#define MENUSEARCHID_ViewRndrSub_Smooth	    6
#define MENUSEARCHID_ViewRndrSub_Phong	    7
#define MENUSEARCHID_ViewRndrSub_Stereo	    8

/* Palettes Menu */
#define MENUSEARCHID_Palettes_Main	    1
#define MENUSEARCHID_Palettes_Fence	    2
#define MENUSEARCHID_Palettes_3D	    3
#define MENUSEARCHID_Palettes_3DBSplines    4
#define MENUSEARCHID_Palettes_AuxCoords	    5
#define MENUSEARCHID_Palettes_Database	    6
#define MENUSEARCHID_Palettes_Dimensioning  7
#define MENUSEARCHID_Palettes_Measuring	    8
#define MENUSEARCHID_Palettes_MLineJoints   9
#define MENUSEARCHID_Palettes_Patterning    10
#define MENUSEARCHID_Palettes_RefFiles	    11
#define MENUSEARCHID_Palettes_CloseSubs	    12

/* Palettes Main Submenu */
#define MENUSEARCHID_PalMainSub_Arcs	    1
#define MENUSEARCHID_PalMainSub_BSplines    2
#define MENUSEARCHID_PalMainSub_Cells	    3
#define MENUSEARCHID_PalMainSub_Chain	    4
#define MENUSEARCHID_PalMainSub_ChgElement  5
#define MENUSEARCHID_PalMainSub_Circles	    6
#define MENUSEARCHID_PalMainSub_CopyElement 7
#define MENUSEARCHID_PalMainSub_DropElement 8
#define MENUSEARCHID_PalMainSub_EDF	    9
#define MENUSEARCHID_PalMainSub_Fillets	    10
#define MENUSEARCHID_PalMainSub_Lines	    11
#define MENUSEARCHID_PalMainSub_LineStrings 12
#define MENUSEARCHID_PalMainSub_MirrorEle   13
#define MENUSEARCHID_PalMainSub_ModifyEle   14
#define MENUSEARCHID_PalMainSub_Points	    15
#define MENUSEARCHID_PalMainSub_Polygons    16
#define MENUSEARCHID_PalMainSub_Text	    17
#define MENUSEARCHID_PalMainSub_ViewCntrl   18

/* Palettes Fence Submenu */
#define MENUSEARCHID_PalFencSub_Change	    1
#define MENUSEARCHID_PalFencSub_Copy	    2
#define MENUSEARCHID_PalFencSub_Delete	    3
#define MENUSEARCHID_PalFencSub_Mirror	    4
#define MENUSEARCHID_PalFencSub_Place	    5

/* Palettes Dimensioning Submenu */
#define MENUSEARCHID_PalDimSub_Angular	    1
#define MENUSEARCHID_PalDimSub_Linear	    2
#define MENUSEARCHID_PalDimSub_Radial	    3
#define MENUSEARCHID_PalDimSub_Misc	    4

/* Palettes 3d BSplines Submenu */
#define MENUSEARCHID_Pal3DBSSub_Surfaces    1
#define MENUSEARCHID_Pal3DBSSub_DSurfaces   2
#define MENUSEARCHID_Pal3DBSSub_ChngSurf    3
#define MENUSEARCHID_Pal3DBSSub_SpaceCurv   4

/* User Menu */
#define MENUSEARCHID_User_Preferences	    1
#define MENUSEARCHID_User_EnvVariables	    2
#define MENUSEARCHID_User_FunctionKeys	    3
#define MENUSEARCHID_User_SystemFonts	    4
#define MENUSEARCHID_User_MDLApps	    5
#define MENUSEARCHID_User_UserCommand	    6
#define MENUSEARCHID_User_NetSecurity	    7

/* User Network Security Submenu */
#define MENUSEARCHID_UserNetSecSub_Obtain   1
#define MENUSEARCHID_UserNetSecSub_TimeLeft 2

/* Help Menu */
#define MENUSEARCHID_Help_OnContext	    1
#define MENUSEARCHID_Help_OnWindow	    2
#define MENUSEARCHID_Help_OnKeys	    3
#define MENUSEARCHID_Help_Topics	    4
#define MENUSEARCHID_Help_OnHelp	    5
#define MENUSEARCHID_Help_OnVersion	    6
#define MENUSEARCHID_Help_KeyinBrowser	    7

/* Named Levels */
#define MENUSEARCHID_NamedLevels_Open		1
#define MENUSEARCHID_NamedLevels_Save		2
#define MENUSEARCHID_NamedLevels_Quit		3
#define MENUSEARCHID_NamedLevels_AddLevel	4
#define MENUSEARCHID_NamedLevels_DeleteLevel	5
#define MENUSEARCHID_NamedLevels_EditLevel	6
#define MENUSEARCHID_NamedLevels_AddGroup	7
#define MENUSEARCHID_NamedLevels_DeleteGroup	8
#define MENUSEARCHID_NamedLevels_EditGroup	9
#define MENUSEARCHID_NamedLevels_OpenGroup	10
#define MENUSEARCHID_NamedLevels_DisplayOn	11
#define MENUSEARCHID_NamedLevels_DisplayOff	12

/* Digitize Settings Submenu */
#define	MENUSEARCHID_Digitize_Partition	    1
#define	MENUSEARCHID_Digitize_Setup	    2
#define	MENUSEARCHID_Digitize_MenuCheck	    3
#define	MENUSEARCHID_Digitize_DigButton	    4

/* Reference File Tools */
#define	MENUSEARCHID_RefFile_Detach	    1
#define MENUSEARCHID_RefFile_Move	    2
#define MENUSEARCHID_RefFile_Scale	    3
#define MENUSEARCHID_RefFile_Rotate	    4
#define MENUSEARCHID_RefFile_MirHorz	    5
#define MENUSEARCHID_RefFile_MirVert	    6
#define MENUSEARCHID_RefFile_ClipBound	    7
#define MENUSEARCHID_RefFile_ClipMask	    8
#define MENUSEARCHID_RefFile_ClipFront	    9
#define MENUSEARCHID_RefFile_ClipBack	    10
#define MENUSEARCHID_RefFile_Reload	    11
    
/* Reference File Settings */
#define MENUSEARCHID_RefFile_Levels	    1
#define MENUSEARCHID_RefFile_LevSymb	    2

/* Window Menu */
#define MENUSEARCHID_WindowMenu_Restore	    1
#define MENUSEARCHID_WindowMenu_Move	    2
#define MENUSEARCHID_WindowMenu_Size	    3
#define MENUSEARCHID_WindowMenu_Minimize    4
#define MENUSEARCHID_WindowMenu_Maximize    5
#define MENUSEARCHID_WindowMenu_Lower	    6
#define MENUSEARCHID_WindowMenu_Sink	    7
#define MENUSEARCHID_WindowMenu_Close	    8

/*----------------------------------------------------------------------+
|									|
|   IconCmdFrameIDs   							|
|									|
+----------------------------------------------------------------------*/
#define ICONCMDFRAMEID_Main		    (DIALOGID_MainFrame		* 10)
#define ICONCMDFRAMEID_Fence		    (DIALOGID_FenceFrame	* 10)
#define ICONCMDFRAMEID_Dimensioning	    (DIALOGID_DimensioningFrame	* 10)

/*----------------------------------------------------------------------+
|									|
|   IconCmdPaletteIDs  							|
|									|
+----------------------------------------------------------------------*/
#define ICONCMDPALETTEID_Line		    (-1)
#define ICONCMDPALETTEID_LineString         (-2)
#define ICONCMDPALETTEID_Polygon	    (-3)
#define ICONCMDPALETTEID_Fillet		    (-4)
#define ICONCMDPALETTEID_Circle		    (-5)
#define ICONCMDPALETTEID_BSpline	    (-6)
#define ICONCMDPALETTEID_Arc		    (-7)
#define ICONCMDPALETTEID_EnterData	    (-8)
#define ICONCMDPALETTEID_Text		    (-9)
#define ICONCMDPALETTEID_Point		    (-10)
#define ICONCMDPALETTEID_Cell		    (-11)
#define ICONCMDPALETTEID_Change		    (-12)
#define ICONCMDPALETTEID_CopyElement	    (-13)
#define ICONCMDPALETTEID_MirrorElement	    (-14)
#define ICONCMDPALETTEID_Modify		    (-15)
#define ICONCMDPALETTEID_Chain		    (-16)
#define ICONCMDPALETTEID_Drop		    (-17)
#define ICONCMDPALETTEID_View		    (-18)

#define ICONCMDPALETTEID_PlaceFence	    (-19)
#define ICONCMDPALETTEID_FenceCopy	    (-20)
#define ICONCMDPALETTEID_FenceChange	    (-21)
#define ICONCMDPALETTEID_FenceMirror	    (-22)
#define ICONCMDPALETTEID_FenceDelete        (-23)
    
#define ICONCMDPALETTEID_ThreeD		    (-24)
#define ICONCMDPALETTEID_ACS		    (-25)
#define ICONCMDPALETTEID_DataBase	    (-26)
#define ICONCMDPALETTEID_Patterning	    (-27)
#define ICONCMDPALETTEID_ReferenceFile	    (-28)
#define ICONCMDPALETTEID_3dBspline	    (-29) /* need room for more than*/
						 /* 20 ICONCMDIDs */

#define ICONCMDPALETTEID_LinearDimen        (-31)
#define ICONCMDPALETTEID_AngularDimen       (-32)
#define ICONCMDPALETTEID_RadialDimen	    (-33)
#define ICONCMDPALETTEID_MiscDimen	    (-34)

#define ICONCMDPALETTEID_Measure	    (-35)

/*----------------------------------------------------------------------+
|									|
|   IconCmdIDs   							|
|									|
+----------------------------------------------------------------------*/

/*--- Main Palette Icon IDs -------------------------------------------*/
#define ICONCMDID_ChooseElement		    (ICONCMDFRAMEID_Main -1)
#define ICONCMDID_DeleteElement		    (ICONCMDFRAMEID_Main -2)

#define ICONCMDID_PlaceLine		    (ICONCMDPALETTEID_Line*20-1)
#define ICONCMDID_PlaceLineAA		    (ICONCMDPALETTEID_Line*20-2)
#define ICONCMDID_ConstBisectorLine	    (ICONCMDPALETTEID_Line*20-3)
#define ICONCMDID_ConstBisectorAngle	    (ICONCMDPALETTEID_Line*20-4)
#define ICONCMDID_PlaceTerminator	    (ICONCMDPALETTEID_Line*20-5)
#define ICONCMDID_ConstLineMin		    (ICONCMDPALETTEID_Line*20-6)
#define ICONCMDID_ConstTanPerp		    (ICONCMDPALETTEID_Line*20-7)
#define ICONCMDID_ConstTanBetween	    (ICONCMDPALETTEID_Line*20-8)
#define ICONCMDID_ConstLineAAToPt	    (ICONCMDPALETTEID_Line*20-9)
#define ICONCMDID_ConstLineAAFromPt	    (ICONCMDPALETTEID_Line*20-10)
#define ICONCMDID_ConstLineAAToPtK	    (ICONCMDPALETTEID_Line*20-11)
#define ICONCMDID_ConstLineAAFromPtK	    (ICONCMDPALETTEID_Line*20-12)
#define ICONCMDID_ConstPerpToElem	    (ICONCMDPALETTEID_Line*20-13)
#define ICONCMDID_ConstPerpFromElem	    (ICONCMDPALETTEID_Line*20-14)
#define ICONCMDID_ConstTanToElem	    (ICONCMDPALETTEID_Line*20-15)
#define ICONCMDID_ConstTanFromElem 	    (ICONCMDPALETTEID_Line*20-16)

#define ICONCMDID_PlaceLineString          (ICONCMDPALETTEID_LineString*20-1)
#define ICONCMDID_PlaceLineStringStream    (ICONCMDPALETTEID_LineString*20-2)
#define ICONCMDID_PlacePointCurve          (ICONCMDPALETTEID_LineString*20-3)
#define ICONCMDID_PlacePointCurveStream    (ICONCMDPALETTEID_LineString*20-4)
#define ICONCMDID_PlaceMultiline	   (ICONCMDPALETTEID_LineString*20-5)

#define ICONCMDID_PlaceBlockOrthogonal	    (ICONCMDPALETTEID_Polygon*20-1)
#define ICONCMDID_PlaceBlockRotated	    (ICONCMDPALETTEID_Polygon*20-2)
#define ICONCMDID_PlaceShapeOrthogonal	    (ICONCMDPALETTEID_Polygon*20-3)
#define ICONCMDID_PlaceBlockIsometric	    (ICONCMDPALETTEID_Polygon*20-4)
#define ICONCMDID_PlaceShape		    (ICONCMDPALETTEID_Polygon*20-5)
#define ICONCMDID_PlaceInscribedPolygon	    (ICONCMDPALETTEID_Polygon*20-6)
#define ICONCMDID_PlaceCircumscribedPolygon (ICONCMDPALETTEID_Polygon*20-7)
#define ICONCMDID_PlacePolygonEdge	    (ICONCMDPALETTEID_Polygon*20-8)

#define ICONCMDID_CircularFilletAndMod	    (ICONCMDPALETTEID_Fillet*20-1)
#define ICONCMDID_CircularFilletNoMod	    (ICONCMDPALETTEID_Fillet*20-2)
#define ICONCMDID_CircularFilletModSingle   (ICONCMDPALETTEID_Fillet*20-3)
#define ICONCMDID_PlaceParabolaMod	    (ICONCMDPALETTEID_Fillet*20-4)
#define ICONCMDID_PlaceParabolaNoMod	    (ICONCMDPALETTEID_Fillet*20-5)
#define ICONCMDID_Chamfer		    (ICONCMDPALETTEID_Fillet*20-6)
#define ICONCMDID_PlaceParabolaHorizMod	    (ICONCMDPALETTEID_Fillet*20-7)
#define ICONCMDID_PlaceParabolaHorizNoMod   (ICONCMDPALETTEID_Fillet*20-8)

#define ICONCMDID_PlaceCircleByCenter	    (ICONCMDPALETTEID_Circle*20-1)
#define ICONCMDID_PlaceCircleByEdge	    (ICONCMDPALETTEID_Circle*20-2)
#define ICONCMDID_PlaceCircleKeyInRadius    (ICONCMDPALETTEID_Circle*20-3)
#define ICONCMDID_PlaceCircleByDiameter	    (ICONCMDPALETTEID_Circle*20-4)
#define ICONCMDID_PlaceCircleIsometric	    (ICONCMDPALETTEID_Circle*20-5)
#define ICONCMDID_ConstCircleTanToElement   (ICONCMDPALETTEID_Circle*20-6)
#define ICONCMDID_ConstCircleTanTo3Elements (ICONCMDPALETTEID_Circle*20-7)
#define ICONCMDID_PlaceEllipseByCenter	    (ICONCMDPALETTEID_Circle*20-8)
#define ICONCMDID_PlaceEllipseByEdge	    (ICONCMDPALETTEID_Circle*20-9)

#define ICONCMDID_PlaceOpenBSpline	    (ICONCMDPALETTEID_BSpline*20-1)
#define ICONCMDID_PlaceClosedBSpline 	    (ICONCMDPALETTEID_BSpline*20-2)
#define ICONCMDID_ChangeBSplineOrder 	    (ICONCMDPALETTEID_BSpline*20-3)
#define ICONCMDID_ToggleBSplinePolygon 	    (ICONCMDPALETTEID_BSpline*20-4)
#define ICONCMDID_ToggleBSplineCurve 	    (ICONCMDPALETTEID_BSpline*20-5)

#define ICONCMDID_PlaceArcByEdge	    (ICONCMDPALETTEID_Arc*20-1)
#define ICONCMDID_PlaceArcByCenter	    (ICONCMDPALETTEID_Arc*20-2)
#define ICONCMDID_PlaceArcByRadius	    (ICONCMDPALETTEID_Arc*20-3)
#define ICONCMDID_PlaceHalfEllipse	    (ICONCMDPALETTEID_Arc*20-4)
#define ICONCMDID_PlaceQuarterEllipse	    (ICONCMDPALETTEID_Arc*20-5)
#define ICONCMDID_ModifyArcRadius	    (ICONCMDPALETTEID_Arc*20-6)
#define ICONCMDID_ModifyArcAngle	    (ICONCMDPALETTEID_Arc*20-7)
#define ICONCMDID_ModifyArcAxis		    (ICONCMDPALETTEID_Arc*20-8)
#define ICONCMDID_CnstrTangentArcTo1	    (ICONCMDPALETTEID_Arc*20-9)
#define ICONCMDID_CnstrTangentArcTo3	    (ICONCMDPALETTEID_Arc*20-10)

#define ICONCMDID_FillInSingleEDF	    (ICONCMDPALETTEID_EnterData*20-1)
#define ICONCMDID_AutoFillInEDF		    (ICONCMDPALETTEID_EnterData*20-2)
#define ICONCMDID_CopyEDF                   (ICONCMDPALETTEID_EnterData*20-3)
#define ICONCMDID_CopyIncrementEDF          (ICONCMDPALETTEID_EnterData*20-4)

#define ICONCMDID_PlaceText		    (ICONCMDPALETTEID_Text*20-1)
#define ICONCMDID_PlaceFittedText 	    (ICONCMDPALETTEID_Text*20-2)
#define ICONCMDID_PlaceVIText 	 	    (ICONCMDPALETTEID_Text*20-3)
#define ICONCMDID_PlaceFittedVIText 	    (ICONCMDPALETTEID_Text*20-4)
#define ICONCMDID_PlaceAnnotation           (ICONCMDPALETTEID_Text*20-5)
#define ICONCMDID_CopyIncrementText 	    (ICONCMDPALETTEID_Text*20-6)
#define ICONCMDID_MatchTextParameters	    (ICONCMDPALETTEID_Text*20-7)
#define ICONCMDID_ChangeTextAttributes	    (ICONCMDPALETTEID_Text*20-8)
#define ICONCMDID_PlaceTextAboveElement	    (ICONCMDPALETTEID_Text*20-9)
#define ICONCMDID_PlaceTextBelowElement     (ICONCMDPALETTEID_Text*20-10)
#define ICONCMDID_PlaceTextOnElement        (ICONCMDPALETTEID_Text*20-11)
#define ICONCMDID_PlaceTextAlongElement     (ICONCMDPALETTEID_Text*20-12)
#define ICONCMDID_PlaceTextNode             (ICONCMDPALETTEID_Text*20-13)
#define ICONCMDID_PlaceVITextNode           (ICONCMDPALETTEID_Text*20-14)
#define ICONCMDID_DisplayTextAttributes     (ICONCMDPALETTEID_Text*20-15)
#define ICONCMDID_EditText                  (ICONCMDPALETTEID_Text*20-16)

#define ICONCMDID_PlacePoint		    (ICONCMDPALETTEID_Point*20-1)
#define ICONCMDID_ConstructPntsBtwnDatapnts (ICONCMDPALETTEID_Point*20-2)
#define ICONCMDID_ProjectPntOntoElement     (ICONCMDPALETTEID_Point*20-3)
#define ICONCMDID_ConstructPntAtIntersect   (ICONCMDPALETTEID_Point*20-4)
#define ICONCMDID_ConstructPntsAlongElement (ICONCMDPALETTEID_Point*20-5)
#define ICONCMDID_CnstrPntAtDistAlongElem   (ICONCMDPALETTEID_Point*20-6)

#define ICONCMDID_PlaceActiveCellAbsolute   (ICONCMDPALETTEID_Cell*20-1)
#define ICONCMDID_PlaceActiveCellRelative   (ICONCMDPALETTEID_Cell*20-2)
#define ICONCMDID_PlaceCellInteractAbsolut  (ICONCMDPALETTEID_Cell*20-3)
#define ICONCMDID_PlaceCellInteractRelativ  (ICONCMDPALETTEID_Cell*20-4)
#define ICONCMDID_PlaceCellMatrix           (ICONCMDPALETTEID_Cell*20-5)
#define ICONCMDID_SelectPlaceCellAbsolute   (ICONCMDPALETTEID_Cell*20-6)
#define ICONCMDID_SelectPlaceCellRelative   (ICONCMDPALETTEID_Cell*20-7)
#define ICONCMDID_DefineCellOrigin          (ICONCMDPALETTEID_Cell*20-8)
#define ICONCMDID_IdentifyCell              (ICONCMDPALETTEID_Cell*20-9)
#define ICONCMDID_ReplaceCell               (ICONCMDPALETTEID_Cell*20-10)

#define ICONCMDID_ChangeElementWeight	    (ICONCMDPALETTEID_Change*20-1)
#define ICONCMDID_ChangeElementStyle	    (ICONCMDPALETTEID_Change*20-2)
#define ICONCMDID_ChangeElementSymbology    (ICONCMDPALETTEID_Change*20-3)
#define ICONCMDID_ChangeElementColor        (ICONCMDPALETTEID_Change*20-4)
#define ICONCMDID_ChangeLevel               (ICONCMDPALETTEID_Change*20-5)
#define ICONCMDID_ChangeArea                (ICONCMDPALETTEID_Change*20-6)
#define ICONCMDID_ChangeAreaFill            (ICONCMDPALETTEID_Change*20-7)
#define ICONCMDID_ChangeClass               (ICONCMDPALETTEID_Change*20-8)

#define ICONCMDID_CopyElement		  (ICONCMDPALETTEID_CopyElement*20-1)
#define ICONCMDID_MoveElement		  (ICONCMDPALETTEID_CopyElement*20-2)
#define ICONCMDID_ScaleElementCopy	  (ICONCMDPALETTEID_CopyElement*20-3)
#define ICONCMDID_ScaleElementOriginal	  (ICONCMDPALETTEID_CopyElement*20-4)
#define ICONCMDID_CopyParallelByDistance  (ICONCMDPALETTEID_CopyElement*20-5)
#define ICONCMDID_CopyParallelByKeyin	  (ICONCMDPALETTEID_CopyElement*20-6)
#define ICONCMDID_SpinElementCopy	  (ICONCMDPALETTEID_CopyElement*20-7)
#define ICONCMDID_SpinElementOriginal	  (ICONCMDPALETTEID_CopyElement*20-8)
#define ICONCMDID_RotateElementCopy	  (ICONCMDPALETTEID_CopyElement*20-9)
#define ICONCMDID_RotateElementOriginal	  (ICONCMDPALETTEID_CopyElement*20-10)
#define ICONCMDID_RectangularArray	 (ICONCMDPALETTEID_CopyElement*20-11)
#define ICONCMDID_PolarArray	         (ICONCMDPALETTEID_CopyElement*20-12)
#define ICONCMDID_MoveParallelByDistance (ICONCMDPALETTEID_CopyElement*20-13)
#define ICONCMDID_MoveParallelByKeyin    (ICONCMDPALETTEID_CopyElement*20-14)

#define ICONCMDID_MirrorElementVertOrig	 (ICONCMDPALETTEID_MirrorElement*20-1)
#define ICONCMDID_MirrorElementVertCopy  (ICONCMDPALETTEID_MirrorElement*20-2)
#define ICONCMDID_MirrorElementHorizOrig (ICONCMDPALETTEID_MirrorElement*20-3)
#define ICONCMDID_MirrorElementHorizCopy (ICONCMDPALETTEID_MirrorElement*20-4)
#define ICONCMDID_MirrorElementLineOrig  (ICONCMDPALETTEID_MirrorElement*20-5)
#define ICONCMDID_MirrorElementLineCopy  (ICONCMDPALETTEID_MirrorElement*20-6)

#define ICONCMDID_CreateComplexString	    (ICONCMDPALETTEID_Chain*20-1)
#define ICONCMDID_AutoCreateChain           (ICONCMDPALETTEID_Chain*20-2)
#define ICONCMDID_CreateComplexShape        (ICONCMDPALETTEID_Chain*20-3)
#define ICONCMDID_AutoCreateShape           (ICONCMDPALETTEID_Chain*20-4)
#define ICONCMDID_AddToGraphicGroup         (ICONCMDPALETTEID_Chain*20-5)
#define ICONCMDID_DropFromGraphicGroup      (ICONCMDPALETTEID_Chain*20-6)
#define ICONCMDID_GroupHoles		    (ICONCMDPALETTEID_Chain*20-7)

#define ICONCMDID_ExtendElement	  	    (ICONCMDPALETTEID_Modify*20-1)
#define ICONCMDID_ExtendLineKeyin           (ICONCMDPALETTEID_Modify*20-2)
#define ICONCMDID_Extend2ElementsToIntersct (ICONCMDPALETTEID_Modify*20-3)
#define ICONCMDID_ExtendElementToIntersect  (ICONCMDPALETTEID_Modify*20-4)
#define ICONCMDID_ModifyElement		    (ICONCMDPALETTEID_Modify*20-5)
#define ICONCMDID_DeleteVertex              (ICONCMDPALETTEID_Modify*20-6)
#define ICONCMDID_InsertVertex              (ICONCMDPALETTEID_Modify*20-7)
#define ICONCMDID_DeletePartial             (ICONCMDPALETTEID_Modify*20-8)

#define ICONCMDID_DropComplexElement	    (ICONCMDPALETTEID_Drop*20-1)
#define ICONCMDID_DropString		    (ICONCMDPALETTEID_Drop*20-2)
#define ICONCMDID_DropText		    (ICONCMDPALETTEID_Drop*20-3)
#define ICONCMDID_DropAssociation	    (ICONCMDPALETTEID_Drop*20-4)
#define ICONCMDID_DropDimension		    (ICONCMDPALETTEID_Drop*20-5)
#define ICONCMDID_DropMline		    (ICONCMDPALETTEID_Drop*20-6)

#define ICONCMDID_UpdateView		    (ICONCMDPALETTEID_View*20-1)
#define ICONCMDID_WindowArea		    (ICONCMDPALETTEID_View*20-2)
#define ICONCMDID_WindowCenter		    (ICONCMDPALETTEID_View*20-3)
#define ICONCMDID_ZoomIn		    (ICONCMDPALETTEID_View*20-4)
#define ICONCMDID_ZoomOut		    (ICONCMDPALETTEID_View*20-5)
#define ICONCMDID_FitView		    (ICONCMDPALETTEID_View*20-6)
#define ICONCMDID_Pan			    (ICONCMDPALETTEID_View*20-7)

/*--- Fence Palette Icon IDs ------------------------------------------*/
#define ICONCMDID_ModifyFence		    (ICONCMDFRAMEID_Fence-1)
#define ICONCMDID_MoveFence		    (ICONCMDFRAMEID_Fence-2)
#define ICONCMDID_FenceStretch		    (ICONCMDFRAMEID_Fence-3)

#define ICONCMDID_PlaceFenceBlock	    (ICONCMDPALETTEID_PlaceFence*20-1)
#define ICONCMDID_PlaceFenceShape	    (ICONCMDPALETTEID_PlaceFence*20-2)

#define ICONCMDID_CopyFenceContents	    (ICONCMDPALETTEID_FenceCopy*20-1)
#define ICONCMDID_MoveFenceContents	    (ICONCMDPALETTEID_FenceCopy*20-2)
#define ICONCMDID_ScaleFenceContentsCopy    (ICONCMDPALETTEID_FenceCopy*20-3)
#define ICONCMDID_ScaleFenceContentsOrig    (ICONCMDPALETTEID_FenceCopy*20-4)
#define ICONCMDID_PolarArrayFenceContents   (ICONCMDPALETTEID_FenceCopy*20-5)
#define ICONCMDID_SpinFenceContentsCopy	    (ICONCMDPALETTEID_FenceCopy*20-6)
#define ICONCMDID_SpinFenceContentsOrig	    (ICONCMDPALETTEID_FenceCopy*20-7)
#define ICONCMDID_RotateFenceContentsCopy   (ICONCMDPALETTEID_FenceCopy*20-8)
#define ICONCMDID_RotateFenceContentsOrig   (ICONCMDPALETTEID_FenceCopy*20-9)
#define ICONCMDID_RectArrayFenceContents    (ICONCMDPALETTEID_FenceCopy*20-10)

#define ICONCMDID_FenceChangeWeight	  (ICONCMDPALETTEID_FenceChange*20-1)
#define ICONCMDID_FenceChangeLineStyle	  (ICONCMDPALETTEID_FenceChange*20-2)
#define ICONCMDID_FenceChangeSymbology	  (ICONCMDPALETTEID_FenceChange*20-3)
#define ICONCMDID_FenceChangeColor	  (ICONCMDPALETTEID_FenceChange*20-4)
#define ICONCMDID_FenceChangeLevel	  (ICONCMDPALETTEID_FenceChange*20-5)

#define ICONCMDID_MirrorFenceContVertOrig  (ICONCMDPALETTEID_FenceMirror*20-1)
#define ICONCMDID_MirrorFenceContVertCopy  (ICONCMDPALETTEID_FenceMirror*20-2)
#define ICONCMDID_MirrorFenceContHorizOrig (ICONCMDPALETTEID_FenceMirror*20-3)
#define ICONCMDID_MirrorFenceContHorizCopy (ICONCMDPALETTEID_FenceMirror*20-4)
#define ICONCMDID_MirrorFenceContLineOrig  (ICONCMDPALETTEID_FenceMirror*20-5)
#define ICONCMDID_MirrorFenceContLineCopy  (ICONCMDPALETTEID_FenceMirror*20-6)

#define ICONCMDID_DeleteFenceContents	   (ICONCMDPALETTEID_FenceDelete*20-1)
#define ICONCMDID_DropFenceContents	   (ICONCMDPALETTEID_FenceDelete*20-2)

/*--- Three-D Palette Icon IDs ----------------------------------------*/
#define ICONCMDID_PlaceSpaceLineString	    (ICONCMDPALETTEID_ThreeD*20-1)
#define ICONCMDID_PlaceSpaceCurve     	    (ICONCMDPALETTEID_ThreeD*20-2)
#define ICONCMDID_PlaceCone           	    (ICONCMDPALETTEID_ThreeD*20-3)
#define ICONCMDID_PlaceCylinder             (ICONCMDPALETTEID_ThreeD*20-4)
#define ICONCMDID_PlaceRightCylinder        (ICONCMDPALETTEID_ThreeD*20-5)
#define ICONCMDID_ShowDisplayDepth    	    (ICONCMDPALETTEID_ThreeD*20-6)
#define ICONCMDID_ShowActiveDepth     	    (ICONCMDPALETTEID_ThreeD*20-7)
#define ICONCMDID_SurfaceOfProjection 	    (ICONCMDPALETTEID_ThreeD*20-8)
#define ICONCMDID_SurfaceOfRevolution 	    (ICONCMDPALETTEID_ThreeD*20-9)
#define ICONCMDID_PlaceRightConeRadius      (ICONCMDPALETTEID_ThreeD*20-10)
#define ICONCMDID_PlaceRightCylinderRadius  (ICONCMDPALETTEID_ThreeD*20-11)
#define ICONCMDID_PlaceRightCone     	    (ICONCMDPALETTEID_ThreeD*20-12)
#define ICONCMDID_SetDisplayDepth           (ICONCMDPALETTEID_ThreeD*20-13)
#define ICONCMDID_SetActiveDepth      	    (ICONCMDPALETTEID_ThreeD*20-14)
#define ICONCMDID_PlaceSlab		    (ICONCMDPALETTEID_ThreeD*20-15)
#define ICONCMDID_PlaceSphere		    (ICONCMDPALETTEID_ThreeD*20-16)

/*--- ACS Palette Icon IDs ----------------------------------------*/
#define ICONCMDID_DefineACSByElement	    (ICONCMDPALETTEID_ACS*20-1)
#define ICONCMDID_DefineACSByPoints	    (ICONCMDPALETTEID_ACS*20-2)
#define ICONCMDID_DefineACSByView	    (ICONCMDPALETTEID_ACS*20-3)
#define ICONCMDID_RotateACSAbsolute	    (ICONCMDPALETTEID_ACS*20-4)
#define ICONCMDID_RotateACSRelative	    (ICONCMDPALETTEID_ACS*20-5)
#define ICONCMDID_MoveACS		    (ICONCMDPALETTEID_ACS*20-6)
#define ICONCMDID_AttachACS		    (ICONCMDPALETTEID_ACS*20-7)

/*--- DataBase Pal. Icon IDs ----------------------------------------*/
#define ICONCMDID_AttachActiveEntity	    (ICONCMDPALETTEID_DataBase*20-1)
#define ICONCMDID_AttachActiveEntityFence   (ICONCMDPALETTEID_DataBase*20-2)
#define ICONCMDID_ShowLinkageMode	    (ICONCMDPALETTEID_DataBase*20-3)
#define ICONCMDID_ShowActiveEntity          (ICONCMDPALETTEID_DataBase*20-4)
#define ICONCMDID_DefineActiveEntityGraph   (ICONCMDPALETTEID_DataBase*20-5)
#define ICONCMDID_ReviewAttributes	    (ICONCMDPALETTEID_DataBase*20-6)
#define ICONCMDID_DetachLinkage		    (ICONCMDPALETTEID_DataBase*20-7)
#define ICONCMDID_DetachLinkageFence	    (ICONCMDPALETTEID_DataBase*20-8)
#define ICONCMDID_AttachDispAttributes	    (ICONCMDPALETTEID_DataBase*20-9)
#define ICONCMDID_LoadDispAttributes	    (ICONCMDPALETTEID_DataBase*20-10)
#define ICONCMDID_LoadDispAttributesFence   (ICONCMDPALETTEID_DataBase*20-11)
#define ICONCMDID_GenerateFenceReport	    (ICONCMDPALETTEID_DataBase*20-12)

/*--- Patterning Pal. Icon IDs ----------------------------------------*/
#define ICONCMDID_AreaPatClosedElement	   (ICONCMDPALETTEID_Patterning*20-1)
#define ICONCMDID_AreaPatFence		   (ICONCMDPALETTEID_Patterning*20-2)
#define ICONCMDID_ShowPatParameters	   (ICONCMDPALETTEID_Patterning*20-3)
#define ICONCMDID_SingleSegmentLinearPat   (ICONCMDPALETTEID_Patterning*20-4)
#define ICONCMDID_MultiSegmentLinearPat	   (ICONCMDPALETTEID_Patterning*20-5)
#define ICONCMDID_HatchArea		   (ICONCMDPALETTEID_Patterning*20-6)
#define ICONCMDID_CrosshatchArea	   (ICONCMDPALETTEID_Patterning*20-7)
#define ICONCMDID_MatchActivePattern	   (ICONCMDPALETTEID_Patterning*20-8)
#define ICONCMDID_UnscaledLinearPat	   (ICONCMDPALETTEID_Patterning*20-9)
#define ICONCMDID_ScaledLinearPat	   (ICONCMDPALETTEID_Patterning*20-10)

/*--- RefFile Palette Icon IDs ----------------------------------------*/
#define ICONCMDID_AttachRefFile		 (ICONCMDPALETTEID_ReferenceFile*20-1)
#define ICONCMDID_DetachRefFile	         (ICONCMDPALETTEID_ReferenceFile*20-2)
#define ICONCMDID_MoveRefFile		 (ICONCMDPALETTEID_ReferenceFile*20-3)
#define ICONCMDID_ScaleRefFile		 (ICONCMDPALETTEID_ReferenceFile*20-4)
#define ICONCMDID_RotateRefFile		 (ICONCMDPALETTEID_ReferenceFile*20-5)
#define ICONCMDID_MirrorRefFileVertical	 (ICONCMDPALETTEID_ReferenceFile*20-6)
#define ICONCMDID_MirrorRefFileHorizontal (ICONCMDPALETTEID_ReferenceFile*20-7)
#define ICONCMDID_SetRefFileClip	(ICONCMDPALETTEID_ReferenceFile*20-8)
#define ICONCMDID_SetRefFileClipBackZ	(ICONCMDPALETTEID_ReferenceFile*20-9)
#define ICONCMDID_SetRefFileClipFrontZ	(ICONCMDPALETTEID_ReferenceFile*20-10)
#define ICONCMDID_RefFileReload		(ICONCMDPALETTEID_ReferenceFile*20-11)
#define ICONCMDID_RefFileMask		(ICONCMDPALETTEID_ReferenceFile*20-12)

/*--- Dimension Pal. Icon IDs ----------------------------------------*/
#define ICONCMDID_DimensionSizeArrow       (ICONCMDPALETTEID_LinearDimen*20-1)
#define ICONCMDID_DimensionSizeStroke	   (ICONCMDPALETTEID_LinearDimen*20-2)
#define ICONCMDID_DimensionSingleLocation  (ICONCMDPALETTEID_LinearDimen*20-3)
#define ICONCMDID_DimensionStackedLocation (ICONCMDPALETTEID_LinearDimen*20-4)
#define ICONCMDID_DimensionAngleSize	  (ICONCMDPALETTEID_AngularDimen*20-1)
#define ICONCMDID_DimensionAngleLocation  (ICONCMDPALETTEID_AngularDimen*20-2)
#define ICONCMDID_DimensionArcSize	  (ICONCMDPALETTEID_AngularDimen*20-3)
#define ICONCMDID_DimensionArcLocation	  (ICONCMDPALETTEID_AngularDimen*20-4)
#define ICONCMDID_DimensionAngleBetwnLines (ICONCMDPALETTEID_AngularDimen*20-5)
#define ICONCMDID_DimensionAngleFromXAxis (ICONCMDPALETTEID_AngularDimen*20-6)
#define ICONCMDID_DimensionAngleFromYAxis (ICONCMDPALETTEID_AngularDimen*20-7)

#define ICONCMDID_DimensionDiameter	   (ICONCMDPALETTEID_RadialDimen*20-1)
#define ICONCMDID_DimensionRadius	   (ICONCMDPALETTEID_RadialDimen*20-2)
#define ICONCMDID_DimensionDiameterPerp	   (ICONCMDPALETTEID_RadialDimen*20-3)
#define ICONCMDID_DimensionDiameterParallel (ICONCMDPALETTEID_RadialDimen*20-4)
#define ICONCMDID_DimensionCenter	   (ICONCMDPALETTEID_RadialDimen*20-5)
#define ICONCMDID_DimensionRadiusCenter	   (ICONCMDPALETTEID_RadialDimen*20-6)
#define ICONCMDID_DimensionDiameterCenter  (ICONCMDPALETTEID_RadialDimen*20-7)

#define ICONCMDID_DimensionOrdinates	    (ICONCMDPALETTEID_MiscDimen*20-1)
#define ICONCMDID_LabelLine		    (ICONCMDPALETTEID_MiscDimen*20-2)
#define ICONCMDID_DimensionLeader	    (ICONCMDPALETTEID_MiscDimen*20-3)
#define ICONCMDID_DimensionElement	    (ICONCMDPALETTEID_MiscDimen*20-4)
#define ICONCMDID_DimensionCustomLinear     (ICONCMDPALETTEID_MiscDimen*20-5)

/*----------------------------------------------- Dimension Pal. Icon IDs -*/
#define ICONCMDID_PlBSCrvPoles		    (ICONCMDPALETTEID_3dBspline*20-1)
#define ICONCMDID_PlBSCrvPts		    (ICONCMDPALETTEID_3dBspline*20-2)
#define ICONCMDID_PlBSCrvLsq		    (ICONCMDPALETTEID_3dBspline*20-3)
#define ICONCMDID_SpiralByAngle		    (ICONCMDPALETTEID_3dBspline*20-4)
#define ICONCMDID_SpiralByLength	    (ICONCMDPALETTEID_3dBspline*20-5)
#define ICONCMDID_SpiralByEndpts	    (ICONCMDPALETTEID_3dBspline*20-6)
#define ICONCMDID_PlParabola		    (ICONCMDPALETTEID_3dBspline*20-7)
#define ICONCMDID_PlHelix		    (ICONCMDPALETTEID_3dBspline*20-8)
#define ICONCMDID_CnsCrvPoles		    (ICONCMDPALETTEID_3dBspline*20-9)
#define ICONCMDID_CnsCrvPoints		    (ICONCMDPALETTEID_3dBspline*20-10)
#define ICONCMDID_CnsCrvLsq		    (ICONCMDPALETTEID_3dBspline*20-11)
#define ICONCMDID_CnsConvert		    (ICONCMDPALETTEID_3dBspline*20-12)
#define ICONCMDID_CnsSurfProj		    (ICONCMDPALETTEID_3dBspline*20-13)
#define ICONCMDID_CnsSurfRevolv		    (ICONCMDPALETTEID_3dBspline*20-14)
#define ICONCMDID_CnsSurfRuled		    (ICONCMDPALETTEID_3dBspline*20-15)
#define ICONCMDID_CnsSurfTube		    (ICONCMDPALETTEID_3dBspline*20-16)
#define ICONCMDID_CnsSurfSkin		    (ICONCMDPALETTEID_3dBspline*20-17)
#define ICONCMDID_PlSurfPoles		    (ICONCMDPALETTEID_3dBspline*20-18)
#define ICONCMDID_PlSurfPoints		    (ICONCMDPALETTEID_3dBspline*20-19)
#define ICONCMDID_PlSurfLsq		    (ICONCMDPALETTEID_3dBspline*20-20)
#define ICONCMDID_CnsSurfXSect		    (ICONCMDPALETTEID_3dBspline*20-21)
#define ICONCMDID_CnsSurfBound		    (ICONCMDPALETTEID_3dBspline*20-22)
#define ICONCMDID_CnsSurfPoles		    (ICONCMDPALETTEID_3dBspline*20-23)
#define ICONCMDID_CnsSurfPoints		    (ICONCMDPALETTEID_3dBspline*20-24)

/*----------------------------------------------- Measure Palette Icon IDs -*/
#define ICONCMDID_MeasureAlongElement	    (ICONCMDPALETTEID_Measure*20-1)
#define ICONCMDID_MeasureDistance	    (ICONCMDPALETTEID_Measure*20-2)
#define ICONCMDID_MeasurePerpToElement	    (ICONCMDPALETTEID_Measure*20-3)
#define ICONCMDID_MeasureMinimumDistance    (ICONCMDPALETTEID_Measure*20-4)
#define ICONCMDID_MeasureRadius		    (ICONCMDPALETTEID_Measure*20-5)
#define ICONCMDID_MeasureAngle		    (ICONCMDPALETTEID_Measure*20-6)
#define ICONCMDID_MeasureArea		    (ICONCMDPALETTEID_Measure*20-7)
#define ICONCMDID_MeasureAreaOfElement	    (ICONCMDPALETTEID_Measure*20-8)

/*----------------------------------------------------------------------+
|									|
|   Slamdown Item ids  							|
|									|
+----------------------------------------------------------------------*/
#define OPTIONBUTTONID_IsoPlane		    (DIALOGID_MainFrame*20-1)
/* can be used */
#define OPTIONBUTTONID_SolidSurface	    (DIALOGID_MainFrame*20-3)
#define OPTIONBUTTONID_ACSTypeView	    (DIALOGID_MainFrame*20-4)
#define OPTIONBUTTONID_ACSTypeElement	    (DIALOGID_MainFrame*20-5)
#define OPTIONBUTTONID_ACSTypePoints	    (DIALOGID_MainFrame*20-6)
#define OPTIONBUTTONID_PatternArea	    (DIALOGID_MainFrame*20-7)

#define TOGGLEID_ArrayRotate		    (DIALOGID_MainFrame*20-1)
    
#define TEXTID_ActiveAngle		    (DIALOGID_MainFrame*50-1)
#define TEXTID_ConslineDistance		    (DIALOGID_MainFrame*50-2)
#define TEXTID_ActiveTermScale		    (DIALOGID_MainFrame*50-3)
#define TEXTID_ActiveTerminator		    (DIALOGID_MainFrame*50-4)
#define TEXTID_StreamTextField		    (DIALOGID_MainFrame*50-5)

#define TEXTID_ScribedPolygonEdges	    (DIALOGID_MainFrame*50-10)
#define TEXTID_ScribedPolygonRadius	    (DIALOGID_MainFrame*50-11)
#define TEXTID_FilletRadius		    (DIALOGID_MainFrame*50-12)
#define TEXTID_ChamferDistance1		    (DIALOGID_MainFrame*50-13)
#define TEXTID_ChamferDistance2		    (DIALOGID_MainFrame*50-14)
#define TEXTID_ParabolaDistance		    (DIALOGID_MainFrame*50-15)
#define TEXTID_ArcRadius		    (DIALOGID_MainFrame*50-16)
#define TEXTID_BsplineOrder		    (DIALOGID_MainFrame*50-17)

#define TEXTID_ActiveCell		    (DIALOGID_MainFrame*50-18)
#define TEXTID_XScale			    (DIALOGID_MainFrame*50-19)
#define TEXTID_YScale			    (DIALOGID_MainFrame*50-20)
#define TEXTID_ZScale			    (DIALOGID_MainFrame*50-21)

#define TEXTID_ArrayNumRows		    (DIALOGID_MainFrame*50-22)
#define TEXTID_ArrayNumColumns		    (DIALOGID_MainFrame*50-23)
#define TEXTID_ArrayRowDelta		    (DIALOGID_MainFrame*50-24)
#define TEXTID_ArrayColumnDelta		    (DIALOGID_MainFrame*50-25)
#define TEXTID_ArrayNumItems		    (DIALOGID_MainFrame*50-26)
#define TEXTID_DeltaAngle		    (DIALOGID_MainFrame*50-27)

#define TEXTID_AutoChainTolerance	    (DIALOGID_MainFrame*50-28)
#define TEXTID_CopparDistance		    (DIALOGID_MainFrame*50-29)

#define TEXTID_TagDel			    (DIALOGID_MainFrame*50-30)
#define TEXTID_ExtendDistance		    (DIALOGID_MainFrame*50-31)

#define TEXTID_ActivePointCell		    (DIALOGID_MainFrame*50-32)
#define TEXTID_ActivePointChar		    (DIALOGID_MainFrame*50-33)

#define TEXTID_TextAboveSpacing		    (DIALOGID_MainFrame*50-34)
#define TEXTID_NodeSpace		    (DIALOGID_MainFrame*50-35)

#define TEXTID_ConeRadius1		    (DIALOGID_MainFrame*50-36)
#define TEXTID_ConeRadius2		    (DIALOGID_MainFrame*50-37)
#define TEXTID_SurrevAngle		    (DIALOGID_MainFrame*50-38)

#define TEXTID_DispAttrType		    (DIALOGID_MainFrame*50-42)
#define TEXTID_ArcLength		    (DIALOGID_MainFrame*50-43)

#define TEXTID_PointsBetween		    (DIALOGID_MainFrame*50-44)
#define TEXTID_PointDistance		    (DIALOGID_MainFrame*50-45)

#define TEXTID_PatternCell		    (DIALOGID_MainFrame*50-46)
#define TEXTID_PatternScales		    (DIALOGID_MainFrame*50-47)
#define TEXTID_PatternAngle1		    (DIALOGID_MainFrame*50-48)
#define TEXTID_PatternAngle2		    (DIALOGID_MainFrame*50-49)
#define TEXTID_PatternRowSpace		    (DIALOGID_MainFrame*50-50)
#define TEXTID_PatternColSpace		    (DIALOGID_MainFrame*50-51)
    
#define TEXTID_SDRefAttachRefScale	    (DIALOGID_MainFrame*50-52)
#define TEXTID_SDRefAttachMastScale	    (DIALOGID_MainFrame*50-53)

#define TOGGLEID_CellStretch		    (DIALOGID_FenceFrame*50-1)

/*----------------------------------------------------------------------+
|									|
|   Misc ID's								|
|									|
+----------------------------------------------------------------------*/
#define SAVEKEYINID_CommandWindow	    (BASEID_CommandWindow-1)

#define ACCELERATORTABLEID_System	    -1

