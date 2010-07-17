/****************************************************************************
/**
/**			Filename: VRattr_index.h
/**			Type:	  C include
/**			Product:  I/ROUTE
/**			Use:	  Definitions for index of arrays
/**				defining default active parameters.
/**				each is of the format NAME_I the _I
/**				denoting it's an INDEX and not a gadget label.
/**			Date:	  21 Jan 1991
/**
/**			Modif : Eric 03/05/91
/**
/***************************************************************************/


/*----------------------------------------------------------------------------*/
/*									      */
/*			Common parameters for HVAC and PIPING		      */
/*									      */
/*----------------------------------------------------------------------------*/


#define LINE_SEQ_NUMBER_I	0
#define ZONE_I			LINE_SEQ_NUMBER_I	+1
#define CONST_STS_I		ZONE_I			+1
#define APPROVAL_STS_I		CONST_STS_I		+1
#define INSULATION_THICKNESS_I	APPROVAL_STS_I		+1
#define INSULATION_I		INSULATION_THICKNESS_I	+1

#define MAX_PM_COMMON		INSULATION_I		+1


/*----------------------------------------------------------------------------*/
/*									      */
/*			Parameters for HVAC				      */
/*									      */
/*----------------------------------------------------------------------------*/


#define SHAPE_I 		MAX_PM_COMMON
#define G_WIDTH_I		SHAPE_I 		+1
#define G_DEPTH_I		G_WIDTH_I		+1
#define R_WIDTH_I		G_DEPTH_I		+1
#define R_DEPTH_I		R_WIDTH_I		+1
#define THROAT_RAD_I		R_DEPTH_I		+1
#define TRANS_LENGTH_I		THROAT_RAD_I		+1
#define CP_OFFSET_I		TRANS_LENGTH_I		+1
#define PRESS_CLASS_I		CP_OFFSET_I		+1
#define SERVICE_I		PRESS_CLASS_I		+1
#define DUCT_THICKNESS_I	SERVICE_I		+1
#define MATERIAL_I		DUCT_THICKNESS_I	+1
#define MAX_FRIC_PER_LNG_I	MATERIAL_I		+1
#define MAX_DEPTH_I		MAX_FRIC_PER_LNG_I	+1
#define MAX_VELOCITY_I		MAX_DEPTH_I		+1
#define AIR_FLOW_I		MAX_VELOCITY_I		+1
#define EQUIV_DIAM_I		AIR_FLOW_I		+1
#define SYSTEM_NAME_I		EQUIV_DIAM_I		+1
#define SIZE_METHOD_I		SYSTEM_NAME_I		+1

#define MAX_PM_HVAC		SIZE_METHOD_I		+1


/*----------------------------------------------------------------------------*/
/*									      */
/*			Paremeters for PIPING				      */
/*									      */
/*----------------------------------------------------------------------------*/

#define G_DIAMETER_I		MAX_PM_COMMON
#define R_DIAMETER_I		G_DIAMETER_I		+1
#define OPER_TEMP0_I		R_DIAMETER_I		+1
#define OPER_RATING0_I		OPER_TEMP0_I		+1
#define DESIGN_TEMP0_I		OPER_RATING0_I		+1
#define DESIGN_RATING0_I	DESIGN_TEMP0_I		+1
#define PDS_CLASS_I		DESIGN_RATING0_I	+1
#define LINE_ID_I		PDS_CLASS_I		+1
#define HEAT_TRACING_I		LINE_ID_I		+1
#define FLUID_CODE_I		HEAT_TRACING_I		+1

#define MAX_PM_PIPING		FLUID_CODE_I		+1
