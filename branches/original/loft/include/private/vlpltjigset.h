#ifndef vlpltjigset_include
#define vlpltjigset_include

#define G_MESSAGE_FIELD         10
#define G_PLATE_LOCATE          14
#define G_PLATE_LIST            15
#define G_MINIMUM_HEIGHT        16
#define G_EXTENSION             20
#define G_CORNER_RADIUS         21
#define G_PLATE_REMOVE          22
#define G_BASE_PLANE            28
#define G_SECONDARY_DIR         31
#define G_PRIMARY_GRID          32
#define G_PRIMARY_SPACING       33
#define G_JIG_SIDE              35
#define G_PRIMARY_REFPLANE      36
#define G_PRIMARY_REFNAME       41
#define G_SECONDARY_GRID        42
#define G_SECONDARY_SPACING     43
#define G_SECONDARY_REFPLANE    44
#define G_SECONDARY_REFNAME     45
#define G_POST_PLACEMENT        49
#define G_EDGE_TEMPLATE         52

#define IDX_PJS_OUTSIDE		0
#define IDX_PJS_INSIDE		1
#define IDX_PJS_BOTH		2

#define NAM_PJS_OUTSIDE		"Outside"
#define NAM_PJS_INSIDE		"Inside"
#define NAM_PJS_BOTH		"Both"

#define IDX_PJS_BALANCED	0
#define IDX_PJS_BASEPL		1
#define IDX_PJS_CENTERLINE	2

#define NAM_PJS_BALANCED	"Balanced"
#define NAM_PJS_BASEPL		"Ship Base Plane"
#define NAM_PJS_CENTERLINE	"Ship Center Line"

#define IDX_PJS_FREE_GRID	0
#define IDX_PJS_FIXED_GRID	1

#define NAM_PJS_DIRECTION	"Direction"
#define NAM_PJS_PLATESIDE	"PlateSide"

#define PJS_PRIMARY_DIR		0
#define PJS_SECONDAY_DIR	1
#define PJS_EDGE_JIG		2

#define NAM_PJS_COGX		"cogX"
#define NAM_PJS_COGY		"cogY"
#define NAM_PJS_COGZ		"cogZ"
#define NAM_PJS_NRMX		"nrmX"
#define NAM_PJS_NRMY		"nrmY"
#define NAM_PJS_NRMZ		"nrmZ"
#define NAM_PJS_MAXD		"maxDist"

#define NB_PJS_ATTR		12

#define IDX_PJS_JIGSIDE		0
#define IDX_PJS_BASEPLANE	1
#define IDX_PJS_MINHEIGHT	2
#define IDX_PJS_EXTENSION	3
#define IDX_PJS_CORNER_RADIUS	4
#define IDX_PJS_POST_MACRO	5
#define IDX_PJS_PRM_GRID_TYPE	6
#define IDX_PJS_PRM_SPACING	7
#define IDX_PJS_SCD_SELCTED	8
#define IDX_PJS_SCD_GRID_TYPE	9
#define IDX_PJS_SCD_SPACING	10
#define IDX_PJS_SCD_EDGE_TEMP	11

#define NAM_PJS_JIGSIDE         "JigSide"
#define NAM_PJS_BASEPLANE       "Baseplane"
#define NAM_PJS_MINHEIGHT       "MinimumHeight"
#define NAM_PJS_EXTENSION       "Extension"
#define NAM_PJS_CORNER_RADIUS   "CornerRadius"
#define NAM_PJS_POST_MACRO      "PostPlacementMacroName"
#define NAM_PJS_PRM_GRID_TYPE   "PrimaryGridType"
#define NAM_PJS_PRM_SPACING     "PrimarySpacing"
#define NAM_PJS_SCD_SELECTED	"SecondarySelected"
#define NAM_PJS_SCD_GRID_TYPE   "SecondaryGridType"
#define NAM_PJS_SCD_SPACING     "SecondarySpacing"
#define NAM_PJS_SCD_EDGE_TEMP   "EdgeTemplates"

#endif
