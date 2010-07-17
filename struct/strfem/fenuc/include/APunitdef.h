#ifndef APunitdef_included
#define	APunitdef_included

/* *****************************H H H H H******************************* */
/* Doc: APunitdef.h

   Abstract:  #defines for units of measure.  Use these for "type"
   	whenever required for APuints.C functions or macros including
   	griomacros.h
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      01-15-92	kk	2.0.0	Creation
*/
/* *****************************H H H H H******************************* */

/* The following are also defined in griodef.h */

#ifndef GRIO_DISTANCE
#define GRIO_DISTANCE			"UOM_DISTANCE"
#endif
#ifndef  GRIO_ANGLE
#define GRIO_ANGLE			"UOM_ANGLE"
#endif
#ifndef  GRIO_AREA
#define GRIO_AREA			"UOM_AREA"
#endif

/* The following are notdefined in griodef.h as of 15 Jan 92 */

#define GRIO_VOLUME			"UOM_VOLUME"
#define GRIO_SECOND_MOMENT_OF_AREA	"UOM_SECOND_MOMENT_OF_AREA"
#define GRIO_TIME			"UOM_TIME"
#define GRIO_MASS			"UOM_MASS"
#define GRIO_MASS_PER_LENGTH		"UOM_MASS_PER_LENGTH"
#define GRIO_MASS_PER_AREA		"UOM_MASS_PER_AREA"
#define GRIO_FORCE			"UOM_FORCE"
#define GRIO_MOMENT			"UOM_MOMENT"
#define GRIO_DENSITY			"UOM_DENSITY"
#define GRIO_FORCE_PER_LENGTH		"UOM_FORCE_PER_LENGTH"
#define GRIO_PRESSURE			"UOM_PRESSURE"
#define GRIO_BODY_FORCE			"UOM_BODY_FORCE"
#define GRIO_TRANS_STIFFNESS		"UOM_TRANS_STIFFNESS"
#define GRIO_ROT_STIFFNESS		"UOM_ROT_STIFFNESS"
#define GRIO_LINEAR_VELOCITY		"UOM_LINEAR_VELOCITY"
#define GRIO_LINEAR_ACCELERATION	"UOM_LINEAR_ACCELERATION"
#define GRIO_LINEAR_PER_ANGULAR		"UOM_LINEAR_PER_ANGULAR"
#define GRIO_ANGULAR_VELOCITY		"UOM_ANGULAR_VELOCITY"
#define GRIO_ANGULAR_ACCELERATION	"UOM_ANGULAR_ACCELERATION"
#define GRIO_ENERGY			"UOM_ENERGY"
#define GRIO_POWER			"UOM_POWER"
#define GRIO_ENERGY_DENSITY		"UOM_ENERGY_DENSITY"
#define GRIO_MECHANICAL_DAMPING		"UOM_MECHANICAL_DAMPING"
#define GRIO_TEMPERATURE		"UOM_TEMPERATURE"
#define GRIO_COEF_THERMAL_EXPANSION	"UOM_COEF_THERMAL_EXPANSION"
#define GRIO_THERMAL_CONDUCTIVITY	"UOM_THERMAL_CONDUCTIVITY"
#define GRIO_HEAT_CAPACITY		"UOM_HEAT_CAPACITY"
#define GRIO_VOLUME_FLOW_RATE		"UOM_VOLUME_FLOW_RATE"
#define GRIO_MASS_FLOW_RATE		"UOM_MASS_FLOW_RATE"
#define GRIO_VISCOSITY			"UOM_VISCOSITY"
#define GRIO_SHEAR_RATE			"UOM_SHEAR_RATE"
#define GRIO_MOMENT_OF_INERTIA		"UOM_MOMENT_OF_INERTIA"
#define GRIO_STRESS			"UOM_STRESS"
#define GRIO_HEAT_FLUX_PER_AREA		"UOM_HEAT_FLUX_PER_AREA"

#define FEU_SCALAR		0
#define FEU_VOLUME		1
#define FEU_SCND_MOM_AREA	2
#define FEU_TIME		3
#define FEU_MASS		4
#define FEU_MASS_P_LEN		5
#define FEU_MASS_P_AREA		6
#define FEU_FORCE		7
#define FEU_MOMENT		8
#define FEU_DENSITY		9
#define FEU_FORCE_P_LEN		10
#define FEU_PRESSURE		11
#define FEU_BODY_FORCE		12
#define FEU_TRANS_STIFF		13
#define FEU_ROT_STIFF		14
#define FEU_LIN_VEL		15
#define FEU_LIN_ACC		16
#define FEU_LIN_P_ANG		17
#define FEU_ANG_VEL		18
#define FEU_ANG_ACC		19
#define FEU_ENERGY		20
#define FEU_POWER		21
#define FEU_ENERGY_DENS		22
#define FEU_MECH_DAMP		23
#define FEU_TEMP		24
#define FEU_COEF_THERM_EXP	25
#define FEU_THERM_COND		26
#define FEU_HEAT_CAP		27
#define FEU_VOL_FLOW_RATE	28
#define FEU_MASS_FLOW_RATE	29
#define FEU_VISCOSITY		30
#define FEU_SHEAR_RATE		31
#define FEU_MOM_OF_INERT	32
#define FEU_DISTANCE		33
#define FEU_ANGLE		34
#define FEU_STRESS		35
#define FEU_STRAIN		36
#define	FEU_AREA		37
#define	FEU_HEAT_FLUX_PER_AREA	38
#endif

