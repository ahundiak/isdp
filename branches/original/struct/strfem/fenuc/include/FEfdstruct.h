#ifndef FEfdstruct_included
#define FEfdstruct_included

/* *****************************H H H H H****************************** */
/* Doc: FEfdstruct.h

   Abstract: This header file contains data structures for each feature
   	descriptor.  Some items are not explicitly declared in the form of
   	structures.
	
   Notes:	Feature Descriptor Data Classification

   		VAR-DATA is data that can potentially use graphic help in
   	its definition,i.e., quantities that could vary spatially.
   		UNIF-DATA is data for which graphic help is not applicable
   	to its definition,i.e., quantities that cannot vary spatially.

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      09-10-87	kk		Creation
      07-23-88	kk		Moved FE_FD_INFO to FEfdstruct.h
      08-15-88	ahs		Added rot_iner_pt for inertia load
      12-19-88	ahs		Added mass FD
      02-07-89	kk		Redefined mass matrix
      10-25-89	kk		Added beam end offset structure
      03-29-90	jlp		Added Dynamic Force Init conditions struct.
      11-01-91	kk	2.0.0	Renamed from fdstruct.h -> FEfdstruct.h
      01-31-92  smt	2.0.0	Added SPG_RSTIFF for Rot. stiffness on
      				spring structure.
      02-06-92	kk	2.0.0	Substituted bitfields with char on "struct rigprop_unif"
      02/20/92	raj	2.0.0	Added 'tot_or_dist' variable to
      				"struct fefrc_unif".
      03-21-92	kk/smt	2.0.0	Changed BM_NSM to BM_TORCON
      03-27-92  smt	2.0.0	Added COST to vars for ISO,ANISO, and ORTHO materials.
      04/20/92	raj	2.0.0	Added 'type' variable to "struct fe1frc_unif".
      06-30-92	smt	2.0.1	Added fenliso_var and fenliso_unif structs to
      				support nonlinear isotropic material (NAVAIR).
      06-29-92  ckc     2.0.1   Added ply_defid and lamprop_unif struct to
                                support laminate property for NAVAIR
      07-19-92	ak	2.0.1	Added Heat source, Convection & Radiation FD.
      07-27-92	ak/smt	2.0.1	Added trans_stiff to gap property and 
      				damping coefficient to nonlinear isotropic mat.
      09-10/92	smt/jc	2.1.0	Added FE_FORM1,FE_FORM2 #defines for dynamic loads.
				Also added unif/var data for damping element property.
      09/14/92	raj	2.1.0	Added Injection point FD for I/FLOW.
      09/16/92	raj	2.1.0	Added Material orientation FD.
      09-17-92	smt	2.1.0	Add fields for specific heat, therm. cond., and
      				emmisivity on all materials.
      09-25-92	smt	2.1.0	Added runner property for I/FLOW.
      11-06-92	smt	2.1.0	Added dimension beam property.
      02-04-93	ak	2.2.0	Added Initial Temperature FD (FEfdintemp).
      03-29-93	jc	2.2.0	Added Sacrificial Element FD
      08-16-93	smt	2.4.0	Added Non-prismatic beam property.
      09/22/93	raj	2.4.0	Added Axisymmetric force and moment types.
*/
/* *****************************H H H H H****************************** */


/* --------------------------------------------------------------
	FEfdmat : material descriptor					*/

#define		ISO_E		0
#define		ISO_V		1
#define		ISO_G		2
#define		ISO_ALPH	3
#define		ISO_DENS	4
#define		ISO_MAXT	5	
#define		ISO_MAXC	6	
#define		ISO_MAXS	7	
#define		ISO_FY		8
#define		ISO_FU		9
#define		ISO_DAMP	10	
#define		ISO_COST	11	
#define		ISO_SPH		12
#define		ISO_THCON	13
#define		ISO_EMIS	14

#define		MAX_ISO_VAR	15	/* Max num of iso variable data	*/
#define		MAX_ISO_UNIF	0	/* Max num of iso uniform data	*/

	struct  feiso_var {
		double		var[MAX_ISO_VAR];
		};

#define		ORTHO_EX	0
#define		ORTHO_EY	1
#define		ORTHO_EZ	2
#define		ORTHO_VXY	3
#define		ORTHO_VYZ	4
#define		ORTHO_VXZ	5
#define		ORTHO_GXY	6
#define		ORTHO_GYZ	7
#define		ORTHO_GXZ	8
#define		ORTHO_ALPHX	9
#define		ORTHO_ALPHY	10
#define		ORTHO_ALPHZ	11
#define		ORTHO_DENS	12
#define		ORTHO_MAXTX	13
#define		ORTHO_MAXTY	14
#define		ORTHO_MAXTZ	15
#define		ORTHO_MAXCX	16
#define		ORTHO_MAXCY	17
#define		ORTHO_MAXCZ	18
#define		ORTHO_MAXSXY	19
#define		ORTHO_MAXSYZ	20
#define		ORTHO_MAXSXZ	21
#define		ORTHO_FYX	22
#define		ORTHO_FYY	23
#define		ORTHO_FYZ	24
#define		ORTHO_FUX	25
#define		ORTHO_FUY	26
#define		ORTHO_FUZ	27
#define		ORTHO_DAMP	28
#define		ORTHO_COST	29
#define		ORTHO_SPH	30
#define		ORTHO_THCONX	31
#define		ORTHO_THCONY	32
#define		ORTHO_THCONZ	33
#define		ORTHO_EMIS	34

#define		MAX_ORTHO_VAR	35	/* Max number of ortho variable data */
#define		MAX_ORTHO_UNIF	0	/* Max num of ortho uniform data     */

	struct  feortho_var {
		double		var[MAX_ORTHO_VAR];
		};

#define		ANISO_D11	0
#define		ANISO_D21	1
#define		ANISO_D22	2
#define		ANISO_D31	3
#define		ANISO_D32	4
#define		ANISO_D33	5
#define		ANISO_D41	6
#define		ANISO_D42	7
#define		ANISO_D43	8
#define		ANISO_D44	9
#define		ANISO_D51	10
#define		ANISO_D52	11
#define		ANISO_D53	12
#define		ANISO_D54	13
#define		ANISO_D55	14
#define		ANISO_D61	15
#define		ANISO_D62	16
#define		ANISO_D63	17
#define		ANISO_D64	18
#define		ANISO_D65	19
#define		ANISO_D66	20
#define		ANISO_A1	21
#define		ANISO_A2	22
#define		ANISO_A3	23
#define		ANISO_A4	24
#define		ANISO_A5	25
#define		ANISO_A6	26
#define		ANISO_DENS	27
#define		ANISO_MAXT	28
#define		ANISO_MAXC	29
#define		ANISO_MAXS	30
#define		ANISO_FY	31
#define		ANISO_FU	32
#define		ANISO_DAMP	33
#define		ANISO_COST	34
#define		ANISO_SPH	35
#define		ANISO_THCONX	36
#define		ANISO_THCONY	37
#define		ANISO_THCONZ	38	
#define		ANISO_THCONXY	39
#define		ANISO_THCONYZ	40
#define		ANISO_THCONXZ	41
#define		ANISO_EMIS	42

#define		MAX_ANISO_VAR	43	/* Max num of aniso variable data */
#define		MAX_ANISO_UNIF	0	/* Max num of aniso uniform data  */

	struct  feaniso_var {
		double		var[MAX_ANISO_VAR];
		};

/*
 *	Nonlinear Isotropic Material
 */

	struct fenliso_unif {
	   char		behavior;	/* 0-Elastic-Plastic, 1-Nonlinear Elastic */
	   char		yld_crit;	/* 0-Von Mises, 1-Tresca,
	   				   2-Mohr-Coulomb, 3-Drucker-Prager*/
	   char		hard_rule;	/* 0-Isotropic, 1-Kinematic, 2-Combined */
	   };

#define		NLISO_V		0	/* Poisson Ratio			*/
#define		NLISO_ALPH	1	/* Thermal Expansion Coefficient	*/
#define		NLISO_DENS	2	/* Density				*/
#define		NLISO_COST	3	/* Cost					*/
#define		NLISO_MAXT	4	/* Maximum Tension			*/
#define		NLISO_MAXC	5	/* Maximum Compression			*/
#define		NLISO_MAXS	6	/* Maximum Shear			*/
#define		NLISO_COH	7	/* 2*Cohesion				*/
#define		NLISO_PHI	8	/* Phi - angle of internal friction	*/
#define		NLISO_DAMP	9	/* Damping Coefficient			*/
#define		NLISO_SPH	10
#define		NLISO_THCON	11
#define		NLISO_EMIS	12

#define		MAX_NLISO_VAR	13	/* Max num of non linear iso variable data	*/
#define		MAX_NLISO_UNIF	sizeof(struct fenliso_unif)

	struct  fenliso_var {
		double		var[MAX_NLISO_VAR];
		};

	union	femat_var {   	  /*  the combined variable material data */
		struct  feiso_var    iso;
		struct  feortho_var  ortho;
		struct  feaniso_var  aniso;
		struct  fenliso_var  nliso;
		};

	union	femat_unif {
		struct fenliso_unif	nliso;
 		};

/* --------------------------------------------------------------
	FEfdprop : property descriptor					*/

/*
	Line Element Properties
*/

	struct bmprop_unif {
	   long			relative_area;	/* For shear area
	   						TRUE: Relative,
							FALSE: absolute */
	   };
/*
*	Beam Cross Sectional Properties
*/

/*	     Y  ^ 		*/
/*		|		*/
/*	     -------		*/
/*	    |       |		*/
/*	    |       |		*/
/*	    |   .   |--> Z	*/
/*	    |       |		*/
/*	    |       |		*/
/*	     -------		*/

#define		BM_AREA		0	/* cross section area		*/
#define		BM_IZZ		1	/* moment of inertia about major axis */
#define		BM_IYY		2	/* moment of inertia about minor axis */
#define		BM_IYZ		3	/* product moment of inertia	*/
#define		BM_JXX		4	/* polar moment of inertia	*/
#define		BM_SHRAZ	5	/* shear area/factor along (Z)	*/
#define		BM_SHRAY	6	/* shear area/factor along (Y)	*/
#define		BM_REC1Z	7	/* Z-coord of stress rec point 1*/
#define		BM_REC1Y	8	/* Y-coord of stress rec point 1*/
#define		BM_REC2Z	9	/* Z-coord of stress rec point 2*/
#define		BM_REC2Y	10	/* Y-coord of stress rec point 2*/
#define		BM_REC3Z	11	/* Z-coord of stress rec point 3*/
#define		BM_REC3Y	12	/* Y-coord of stress rec point 3*/
#define		BM_REC4Z	13	/* Z-coord of stress rec point 4*/
#define		BM_REC4Y	14	/* Y-coord of stress rec point 4*/
#define		BM_SHCTZ	15	/* Z-coord of shear center	*/
#define		BM_SHCTY	16	/* Y-coord of shear center	*/
#define		BM_WARP		17	/* Warping coefficient		*/
#define		BM_TORCON	18	/* Torsional constant of section*/

#define		MAX_BM_VAR	19	/* Max num of variable data	*/
#define		MAX_BM_UNIF	sizeof(struct bmprop_unif)

	struct bmprop_var {
	   double		var[MAX_BM_VAR];
	   };

/*
*	Non-prismatic Beam Cross Sectional Properties
*
*
*/
	struct npbmprop_unif {
	   long			rel_area_end1;	/* For shear area end 1
	   						TRUE: Relative, FALSE: absolute */
	   long			rel_area_end2;	/* For shear area end 2
	   						TRUE: Relative, FALSE: absolute */
	   };

#define		MAX_NPBM_VAR	38	/* Max num of variable data	*/
#define		MAX_NPBM_UNIF	sizeof(struct npbmprop_unif)

/*
*	Following #defines used for subscript 1 of 2 dimensional array to
*	designate beam end.  Subscript 2 Uses the same #defines as beam
*	property to define beam data for the end specified.
*/

#define		NPBM_END1	0	/* end 1 of non-prismatic beam */
#define		NPBM_END2	1	/* end 2 of non-prismatic beam */

	struct npbmprop_var {
	   double		var[2][MAX_BM_VAR];
	   };
        struct tpbmprop_unif {
           long                 rel_area_end1;  /* For shear area end 1
                                                  TRUE: Relative, FALSE: Absolute */
           long                 rel_area_end2;  /* For shear area end 2
                                                  TRUE: Relative, FALSE: Absolute */
           };

#define         MAX_TPBM_VAR    42     /* Max num of variable data     */
#define         MAX_TPBM_UNIF   sizeof(struct tpbmprop_unif)

        struct tpbmprop_var {
           double               var[MAX_TPBM_VAR];
           };

/*
	Dimension Beam Element Properties
*/

/*	Output "sec_props[]" from FEsection_properties()	*/

#define		INDAREA 0	/* 	Area of the Section	*/
#define 	INDIYY	1	/* 	Iyy - M.I About YY axis of the Section	*/
#define 	INDIZZ	2	/* 	Izz - M.I About ZZ axis of the Section	*/
#define 	INDIZY	3	/* 	Izy - Cross M.I 	*/
#define 	INDJ	4	/* 	J - Polar M.I 		*/
#define 	INDT	5	/* 	T - Torsional Constant( =J for circular
					Sections Only	*/
#define		INDCGY	6	/* 	CGy - Centroidal distance from Lower Left
					corner of the section in Y Direction	*/
#define		INDCGZ  7	/* 	CGz - Centroidal distance from Lower Left
					corner of the section in Z Direction	*/

/* cross-section type #defines for dimprop_unif below */
#define FE_CIRCULAR	0	/*	Circular Section		*/
#define FE_PIPE		1	/*	Pipe	 Section		*/
#define FE_RECTANGLE	2	/*	Rectangular Section		*/
#define FE_HOLLOW_RECT	3	/*	Hollow Rectangular Section	*/
#define FE_CHANNEL	4	/*	Channel Section			*/
#define FE_ANGLE	5	/*	Angle Section			*/
#define FE_I_BEAM	6	/*	I -  Section			*/

	struct dimprop_unif {
	   char			cross_type;	/* cross-section type shown above */
	   char			ext_usr_pt;	/* extreme or user stress
	   					   recovery points to be used
	   					   	0 - extreme
	   					   	1 - user defined */
	   };
/*	NOTE:  	DIST0 - DIST5 are used to define all of the distance values
		for the various dimension beam types.
*/			

#define		DIM_DIST0	0	/* Cross section distance 0	*/
#define		DIM_DIST1	1	/* Cross section distance 1	*/
#define		DIM_DIST2	2	/* Cross section distance 2	*/
#define		DIM_DIST3	3	/* Cross section distance 3	*/
#define		DIM_DIST4	4	/* Cross section distance 4	*/
#define		DIM_DIST5	5	/* Cross section distance 4	*/
#define		DIM_REC1Z	6	/* Z-coord of stress rec point 1*/
#define		DIM_REC1Y	7	/* Y-coord of stress rec point 1*/
#define		DIM_REC2Z	8	/* Z-coord of stress rec point 2*/
#define		DIM_REC2Y	9	/* Y-coord of stress rec point 2*/
#define		DIM_REC3Z	10	/* Z-coord of stress rec point 3*/
#define		DIM_REC3Y	11	/* Y-coord of stress rec point 3*/
#define		DIM_REC4Z	12	/* Z-coord of stress rec point 4*/
#define		DIM_REC4Y	13	/* Y-coord of stress rec point 4*/
#define		DIM_WARP	14	/* Warping coefficient		*/
#define		MAX_DIM_VAR	15	/* Max num of variable data	*/
#define		MAX_DIM_UNIF	sizeof(struct dimprop_unif)

/* #define map for cross section types (THESE ALL MAP TO DIST0 - DIST5 ABOVE)
   ==========================================================================
*/
   
/* Solid Circle */
#define		FE_CIRC_RAD	0	/* solid circle radius		*/

/* Pipe */
#define		FE_HCIR_ORAD	0	/* pipe outside radius		*/
#define		FE_HCIR_IRAD	1	/* pipe inside radius		*/

/* Solid Rectangle */
#define		FE_SREC_HGT	0	/* solid rectangle height		*/
#define		FE_SREC_WDT	1	/* solid rectangle width		*/

/* Hollow Rectangle */
#define		FE_HREC_OHGT	0	/* hollow rectangle outside height	*/
#define		FE_HREC_OWDT	1	/* hollow rectangle outside width	*/
#define		FE_HREC_IHGT	2	/* hollow rectangle inside height	*/
#define		FE_HREC_IWDT	3	/* hollow rectangle inside width	*/
#define		FE_HREC_BTHK	4	/* hollow rectangle bottom wall thick	*/
#define		FE_HREC_LTHK	5	/* hollow rectangle left wall thick	*/

/* Channel */
#define		FE_CHAN_WHGT	0	/* channel web height			*/
#define		FE_CHAN_WTHK	1	/* channel web thickness		*/
#define		FE_CHAN_UFT	2	/* channel upper flange thickness	*/
#define		FE_CHAN_UFL	3	/* channel upper flange length		*/
#define		FE_CHAN_LFT	4	/* channel lower flange thickness	*/
#define		FE_CHAN_LFL	5	/* channel lower flange length		*/

/* Angle */
#define		FE_ANG_ZLL	0	/* angle z leg length			*/
#define		FE_ANG_YLL	1	/* angle y leg length			*/
#define		FE_ANG_ZLT	2	/* angle z leg thickness		*/
#define		FE_ANG_YLT	3	/* angle y leg thickness		*/

/* I-beam */
#define		FE_IBM_WHGT	0	/* I-beam web height			*/
#define		FE_IBM_WTHK	1	/* I-beam web thickness			*/
#define		FE_IBM_UFT	2	/* I-beam upper flange thickness	*/
#define		FE_IBM_UFL	3	/* I-beam upper flange length		*/
#define		FE_IBM_LFT	4	/* I-beam lower flange thickness	*/
#define		FE_IBM_LFL	5	/* I-beam lower flange length		*/

	struct dimprop_var {
	   double		var[MAX_DIM_VAR];
	   };
/*
	Rod Element Properties
*/
#define		ROD_AREA	0	/* Rod element area		*/
#define		ROD_TORCON	1	/* Torsional constant of section*/

#define		MAX_ROD_VAR	2	/* Max num of variable data	*/
#define		MAX_ROD_UNIF	0	/* Max num of uniform data	*/

	struct rodprop_var {
	   double		var[MAX_ROD_VAR];
	   };
/*
	Spring Element Properties
*/
#define		SPG_TSTIFF	0	/* Spring translational stiffness */
#define		SPG_RSTIFF	1	/* Spring rotational stiffness	  */

#define		MAX_SPG_VAR	2	/* Max num of variable data	*/
#define		MAX_SPG_UNIF	0	/* Max num of uniform data	*/

	struct spgprop_var {
	   double		var[MAX_SPG_VAR];
	   };
/*
	Plate Element Properties
*/
	struct panprop_unif {
	   long			opts;	/* == 1 membrane  
				   	   == 2 bending
				   	   == 3 bending/membrane	*/
	   long			high_order;	/*
				=0 if no incompatible modes desired 
				=1 if incompatible modes desired */
	   long			avg_type;	/* TRUE: wieghted stress
	   					   averaging at nodes
	   					   FALSE: no wieghted avg */
	   long			recdist_flag;	/* 0: absolute or 1: relative*/
	   };

#define		PAN_THK		0	/* plate thickness		*/
#define		PAN_TREC	1	/* top stress recovery distance	*/
#define		PAN_BREC	2	/* bottom stress "      "	*/
#define		PAN_SHTH	3	/* shear thickness ratio	*/
#define		PAN_FSTF	4	/* fictitious in-plane stiffness*/

#define		MAX_PAN_VAR	5	/* Max number of variable data	*/
#define		MAX_PAN_UNIF	sizeof(struct panprop_unif)

	struct panprop_var {
	   double		var[MAX_PAN_VAR];
	   };

/*
 *	NO Solid Element Properties
 */

#define		MAX_SOL_VAR	0	/* Max number of variable data	*/
#define		MAX_SOL_UNIF	0


/*
	Hook/Gap Element Properties
*/

	struct gapprop_unif {
		double		opening;
		double		open_stiff;
		double		closed_stiff;
		double		trans_stiff;
		double		preload;
		double		fric_y;
		double		fric_z;
		char		type_flag;
		char		uni_sp_flag;	/* 0-unidirectional, 1-spherical */
	};
#define		GAP_TYPE	1	/* type_flag values */
#define		HOOK_TYPE	0

#define		MAX_GAP_VAR	0	/* Max number of variable data	*/
#define		MAX_GAP_UNIF	sizeof(struct gapprop_unif)

/*
	Hook/Gap Element Properties
*/

	struct rigprop_unif {
		char	swap_flag;	/* reverse ind/dep node order */
		char	dof_flag;	/* ind node does not xmit rotation */
		char	x_flag;		/* X dof derived from ind node */
		char	y_flag;		/* Y dof derived from ind node */
		char	z_flag;		/* Z dof derived from ind node */
		char	rx_flag;	/* RX dof derived from ind node */
		char	ry_flag;	/* RY dof derived from ind node */
		char	rz_flag;	/* RZ dof derived from ind node */
	};
#define		SIX_DOF		0	/* dof_flag values */
#define		THREE_DOF	1

#define		MAX_RIG_VAR	0	/* Max number of variable data	*/
#define		MAX_RIG_UNIF	sizeof(struct rigprop_unif)

struct ply_defid
  {
    double             thickness;
    double             orient_angle;
    char               output;
  };

struct lamprop_unif
  {
    double                    offset_dis;
    double                    reftemp;
    double                    damp_coeff;
    double                    nsm;
    char                      fail_theory;
    double                    intafct;
    double                    allow_shstres;
    char                      center_sym;
    int                       nply;
    struct ply_defid          ply_defid[300];
  };

#define		MAX_LAM_VAR	0	/* Max number of variable data	*/
#define		MAX_LAM_UNIF	sizeof(struct lamprop_unif)

/*
	Damper Element Properties
*/

#define		DMP_TRANSCO	0	/* Damping translational coefficient */
#define		DMP_ROTCO	1	/* Damping rotational coefficient    */
#define		MAX_DMP_VAR	2	/* Max num of variable data	*/
#define 	MAX_DMP_UNIF	0

	struct dmpprop_var {
	   double		var[MAX_DMP_VAR];
	   };

/*
	Runner Element Properties
*/

	struct runprop_unif 
	{
		char		runner_temp;	/* Temp.type of runner
						   0 - Hot
						   1 - Cold		*/
	};

#define 	MAX_RUN_VAR	1	/* Max number of variable data	*/
#define 	MAX_RUN_UNIF	sizeof( struct runprop_unif )
					/* Number of bytes for unif data*/
#define		DIAMETER	0	/* Runner diameter index	*/

	struct runprop_var 
	{
	   	double		var[MAX_RUN_VAR];	/* Runner	*/
	};

/*
 *	Union of Structures Previously Defined For All Properties
*/

	union	feprop_unif {
		struct bmprop_unif	beam;
		struct npbmprop_unif	npbeam;
		struct tpbmprop_unif    tpbeam;
		struct panprop_unif	plate;
		struct gapprop_unif	gap;
		struct rigprop_unif	rig;
                struct lamprop_unif     lam;
                struct runprop_unif     run;
		struct dimprop_unif	dim;
 		};
 	union	feprop_var {
		struct bmprop_var	beam;
		struct npbmprop_var	npbeam;
		struct tpbmprop_var	tpbeam;
		struct rodprop_var	rod;
		struct spgprop_var	spring;
		struct panprop_var	plate;
		struct dmpprop_var	damp;
		struct runprop_var	run;
		struct dimprop_var	dim;
 		};

/* ---------------------------------------------------------------------
	FEfdforce : force descriptor					*/
/*
	Load Types ( load_type variable )
*/
#define		FE_FORCE	0	/* Force type load		*/
#define		FE_MOMENT	1	/* Moment type load		*/
#define		FE_INER_T	2	/* Inertial translational load	*/
#define		FE_INER_R	3	/* Inertial rotational load	*/
#define		FE_BODY		4	/* Body load			*/
#define		FE_EDGE		5	/* Element edge load		*/
#define		FE_AXIS_FRC	6	/* Axisymmetric load		*/
#define		FE_AXIS_MOM	7	/* Axisymmetric moment		*/
/*
	1-D : Beam Element Load
*/
#define		FE_GLOBAL	0	/* Global reference frame	*/
#define		FE_LOCAL	1	/* Local reference frame	*/
#define		FE_PROJ		2	/* Global projected reference	*/

#define		FE_CONC_LOAD	0	/* Conc force on beam		*/
#define		FE_UNIF_LOAD	1	/* Unif Dist force on beam	*/
#define		FE_TRAP_LOAD	2	/* Trap force on beam		*/

#define		FE_X_DIR	1	/* X-direction force		*/
#define		FE_Y_DIR	2	/* Y-direction force		*/
#define		FE_Z_DIR	3	/* Z-direction force		*/
#define		FE_RX_DIR	4	/* RX-direction force		*/
#define		FE_RY_DIR	5	/* RY-direction force		*/
#define		FE_RZ_DIR	6	/* RZ-direction force		*/

struct fe1frc_unif {
	char		type;		/* FE_CONC_LOAD, FE_UNIF_LOAD...etc	*/
	char		ref_frame;	/* Load reference frame		*/
	char		direction;	/* Load Direction, FE_X_DIR,...	*/
	char		abs_dist;	/* TRUE: dist[2] is absolute values */
	double		dist[2];	/* Start & end distances of load  */
	double		mag[2];		/* Start & end magnitudes of load */
	};
/*
	2-D : Surface and Plate Element Load
*/
#define		FE_NORMAL	0	/* Normal type define load	*/
#define		FE_TRACTION	1	/* Traction type load		*/
#define		FE_VECTOR	2	/* Vector type defined load	*/

struct fe2frc_unif {
	char		type;		/* FE_NORMAL, FE_TRACTION...etc	*/
	};
/*
 *	3-D : Solid Element Load
*/
struct fe3frc_unif {
	char		type;		/* FE_NORMAL, FE_TRACTION...etc	*/
	char		face_num;	/* Solid element face number	*/
	};
/*
 *	Edge Loading
*/
struct feedfrc_unif {
	char		type;		/* FE_NORMAL, FE_TRACTION...etc	*/
	char		edge_num;	/* Element edge	number		*/
	};
/*
 *	Rotational Inertia Loading
*/
struct feiner_unif {
	double		rot_iner_pt[3];	/* Point of application of load	*/
	};
/*
 *	Union Loading Structures
*/
union fefrc_unif_types {
	struct fe1frc_unif	frc1;
	struct fe2frc_unif	frc2;
	struct fe3frc_unif	frc3;
	struct feedfrc_unif	edge;
	struct feiner_unif	iner;
	};

struct fefrc_unif {
	char			load_type;	/* FE_FORCE,FE_BODY,...    */
	char			pull_or_push;	/* TRUE: Pull, FALSE: Push */
	char			mult_opt;	/* TRUE: load=vector[]*mag */
	char			tot_or_dist;	/* TRUE: Total.		   */
	double			vector[3];	/* Orientation vector	   */
	union fefrc_unif_types	sp;		/* Combined forces	   */
	};

#define 	FORCE_MAG	0	/* Spatially Varying Magnitude	*/

#define 	MAX_FORCE_VAR	1
#define 	MAX_FORCE_UNIF	sizeof(struct fefrc_unif)

struct fefrc_var {
	double		var[MAX_FORCE_VAR];	/* Force magnitude	*/
	};

/* ---------------------------------------------------------------------
	FEfddynload : dynamic load descriptor				*/

/*
	Domain	Type		( domain variable )
*/
#define		FE_TIME		0	/* Time domain definition	*/
#define		FE_FREQUENCY	1	/* Frequency domain definition	*/


/*
	Dynamic Load Types	( load_type variable )
*/
#define		FE_SIN		0	/* f = A * sin ( 2 * PI * F * t )	*/
#define		FE_COS		1	/* f = A * cos ( 2 * PI * F * t )	*/
#define		FE_HARMONIC	2	/* f = A * t^B * e^Ct * cos ( 2 * PI * F * t + P) */
#define		FE_TABLE	3	/* f = A * Y(table)		*/
#define		FE_FORM1	4	/* P = A [ C(f) + i * D(f) ] e ** (theta - 2*PI*f*tau)*/
#define		FE_FORM2	5	/* P = A [ B(f) ] e ** i(phi(f)+theta - 2*PI*f*tau)*/
#define		FE_TABLEA	6	/* f = A * w * sin ( w * tau )*/

/*
	Excitation Type		( excit_type variable )
*/
#define		FE_LOAD		0	/* Apply as load		  */
#define		FE_ENF_DISP	1	/* Apply as enforced displacement */
#define		FE_ENF_VELOCITY	2	/* Apply as enforced velocity	  */
#define		FE_ENF_ACCL	3	/* Apply as enforced acceleration */
#define		FE_TEMP_LOAD	4	/* Apply as thermal load (temperature) */

/*
	Component		( component variable )
        (same as above only commented here.)
#define		FE_X_DIR	1	 X-direction load
#define		FE_Y_DIR	2	 Y-direction load
#define		FE_Z_DIR	3	 Z-direction load
#define		FE_RX_DIR	4	 RX-direction load
#define		FE_RY_DIR	5	 RY-direction load
#define		FE_RZ_DIR	6	 RZ-direction load
*/

struct dyn_harmonic {
	double		growth_coef;	/* B in equation in type defn	*/
	double		exp_coef;	/* C in equation in type defn	*/
	double		phase;		/* P in equation in type defn	*/
	};

struct	fedynload_unif {
	char		domain;		/* Time or frequency		*/
	char		load_type;	/* sin, cos, table ..		*/
	char		excit_type;	/* Load, enf disp ..		*/
	char		component;	/* x, y, ... rz			*/
	double		frequency;	/* F in equations in type defn	*/
	double		start_time;	/* Of load application/time delay	*/
	double		end_time;	/* Of load application/phase lead	*/
	struct dyn_harmonic harmonic;	/* Harmonic specific data	*/
	};

#define		MAX_DYNLOAD_VAR	1
#define		MAX_DYNLOAD_UNIF sizeof ( struct fedynload_unif )

struct	fedynload_var {
	double		var[MAX_DYNLOAD_VAR];	/* A in equations in type defn	*/
	};


/* --------------------------------------------------------------
	FEfdintcon : Dynamic Force initial conditions descriptor.	*/

#define 	MAX_IC_VAR		0

	struct feic_unif {
		double		disp;		/* Displacement */
		double		disp_vector[3];
		double		rot;		/* Rotational Displacement */
		double		rot_vector[3];
		double		linvel;		/* Linear velocity */
		double		linvel_vector[3];
		double		rotvel;		/* Rotational velocity */
		double		rotvel_vector[3];
	};

#define 	MAX_IC_UNIF		sizeof(struct feic_unif)

/* --------------------------------------------------------------
	FEfdconstr : constraint descriptor				*/

#define 	MAX_CONSTR_VAR		0

	struct fecnst_unif {
		char		conmap;		/* constraint bit map
						   bit  0  1  2  3  4  5
							DX DY DZ RX RY RZ */
	};

#define 	MAX_CONSTR_UNIF		sizeof(struct fecnst_unif)

/* --------------------------------------------------------------
	FEfdorient : Orientation Vector Descriptor			*/

#define 	ORIENT_X		0
#define 	ORIENT_Y		1
#define 	ORIENT_Z		2

#define 	MAX_ORIENT_VAR		3
#define 	MAX_ORIENT_UNIF		0

struct feorient_var {
	double		var[MAX_ORIENT_VAR];	/* Vector components	*/
		};

/* --------------------------------------------------------------
	FEfdmatornt : Material Orientation Vector(s) Descriptor			*/

#define 	X_AXIS		0	/* X-axis	*/
#define 	Y_AXIS		1	/* Y-axis	*/
#define 	Z_AXIS		2	/* Z-axis	*/

struct fematornt_unif {
	char			proj_axis;	/* Projection axis for 2d elem   */
		};

#define 	X_ANGLE		0
#define 	Y_ANGLE		1
#define 	Z_ANGLE		2

#define 	MAX_MATORNT_VAR		3
#define 	MAX_MATORNT_UNIF	sizeof(struct fematornt_unif)

struct fematornt_var {
	double		var[MAX_MATORNT_VAR];	/* x,y,z angles		*/
		};

/* --------------------------------------------------------------
	FEfdbeamofs : Beam Offset Descriptor			*/

#define		OFFSET_Y1		0
#define		OFFSET_Z1		1
#define		OFFSET_Y2		2
#define		OFFSET_Z2		3

#define 	MAX_BMOFS_VAR		4
#define 	MAX_BMOFS_UNIF		0

struct febmofs_var {
	double		var[MAX_BMOFS_VAR];	/* Offset components	*/
		};

/* --------------------------------------------------------------
	FEfdbeamrel : Beam End Releases Descriptor			*/

#define 	MAX_BMREL_VAR		0

struct febmrel_unif {
	char		pincode[2];	/* Beam end release codes	*/
	};

#define 	MAX_BMREL_UNIF		sizeof(struct febmrel_unif) 

/* --------------------------------------------------------------
	FEfdspdisp : specified displacements descriptor			*/

#define 	MAX_SPDISP_VAR		6
#define 	MAX_SPDISP_UNIF		0

	struct fespdisp_var {
		double		var[MAX_SPDISP_VAR];	/* DX DY DZ RX RY RZ */
		};


/* --------------------------------------------------------------
	FEfd_ht_src : heat source and conduction descriptor		*/

#define 	HT_SRC_0D		0	/* Node or Point	*/
#define 	HT_SRC_1D		1	/* Line element		*/
#define 	HT_SRC_2D		2	/* Surface or Plate	*/
#define 	HT_SRC_3D_SOL		3	/* Solid geom		*/
#define 	HT_SRC_3D_EL		4	/* Solid Element	*/
#define 	HT_SRC_3D_FAC		5	/* Face Solid Element	*/
#define 	HT_SRC_ED		6	/* Element Edge		*/
#define 	HT_SRC_GEOM_ED		7	/* Geometric Edge	*/


struct fe_ht_src_unif {
	char			type;		/* HT_SRC_ED,HT_SRC_1D..   */
	char			tot_or_dist;	/* TRUE: Total.		   */
	char			face_num;	/* For type 5		   */
	char			edge_num;	/* For type 6		   */
	};


#define 	HT_SRC_MAG	0		/* Spatially Varying Magnitude */
#define 	MAX_HT_SRC_VAR	1
#define 	MAX_HT_SRC_UNIF sizeof(struct fe_ht_src_unif)

struct fe_ht_src_var {
	double		var[MAX_HT_SRC_VAR];	/* Force magnitude	*/
	};
	
/* --------------------------------------------------------------
	FEfd_convec : heat convection descriptor			*/

#define 	CONVEC_1D		0	/* Line Element		*/
#define 	CONVEC_2D		1	/* Surface or Plate	*/
#define 	CONVEC_3D_FAC		2	/* Face Solid Element	*/
#define 	CONVEC_ED		3	/* Element Edge		*/
#define 	CONVEC_GEOM_ED		4	/* Geometric Edge	*/


struct fe_convec_unif {
	char			type;		/* CONVEC_2D,....	   */
	char			face_num;	/* For type 2		   */
	char			edge_num;	/* For type 3		   */
	};


#define 	FILM_COEF	0		/* Film Coefficient	   */
#define 	AMB_TEMP	1		/* Ambient temperature	   */
#define 	MAX_CONVEC_VAR	2
#define 	MAX_CONVEC_UNIF sizeof(struct fe_convec_unif)

struct fe_convec_var {
	double		var[MAX_CONVEC_VAR];	
	};


/* --------------------------------------------------------------
	FEfd_radi : heat radiation descriptor			*/

#define 	RADI_1D		0	/* Line Element		*/
#define 	RADI_2D		1	/* Surface or Plate	*/
#define 	RADI_3D_FAC	2	/* Face Solid Element	*/
#define 	RADI_ED		3	/* Element Edge		*/
#define 	RADI_GEOM_ED	4	/* Geometric Edge	*/


struct fe_radi_unif {
	char			type;		/* RADI_2D,....	   */
	char			face_num;	/* For type 2		   */
	char			edge_num;	/* For type 3		   */
	};


#define 	EMISIV		0		/* Emissivity		   */
#define 	MAX_RADI_VAR	1
#define 	MAX_RADI_UNIF   sizeof(struct fe_radi_unif)

struct fe_radi_var {
	double		var[MAX_RADI_VAR];	
	};
	
/* --------------------------------------------------------------
	FEfd_trs_ther_bc : transient thermal BC, excluding temperature	*/


/* --------------------------------------------------------------
	FEfdintemp : initial temperature descriptor				*/

#define		INTEMP_VAL		0	/* initial temperature value */

#define 	MAX_INTEMP_VAR		1	/* Max num of varying data   */
#define 	MAX_INTEMP_UNIF		0	/* Max byte count unif data  */

	struct feintemp_var {
		double		var[MAX_INTEMP_VAR];
	};


/* --------------------------------------------------------------
	FEfdtemp : temperature descriptor				*/

#define		TEMP_REFT		0	/* reference temperature */
#define		TEMP_VAL		1	/* temperature value	 */

#define 	MAX_TEMP_VAR		2	/* Max num of varying data  */
#define 	MAX_TEMP_UNIF		0	/* Max byte count unif data */

	struct fetemp_var {
		double		var[MAX_TEMP_VAR];
	};

/* --------------------------------------------------------------
	FEfdmass : Mass Feature						*/

#define		MASS_X			0	/* Mass in x-direction	     */
#define		MASS_Y			1	/* Mass in y-direction	     */
#define		MASS_Z			2	/* Mass in z-direction	     */
#define		INER_XX			3	/* Inertia about x-direction */
#define		INER_YY			4	/* Inertia about y-direction */
#define		INER_ZZ			5	/* Inertia about z-direction */
#define		INER_XY			6	/* Cross Inertia about xy-dir */
#define		INER_YZ			7	/* Cross Inertia about yz-dir */
#define		INER_ZX			8	/* Cross Inertia about zx-dir */

#define 	MAX_MASS_VAR		9	/* Max num of varying data  */
#define 	MAX_MASS_UNIF		0	/* Max byte count unif data */

	struct femass_var {
		double		var[MAX_MASS_VAR];
	};

/* --------------------------------------------------------------
	FEfdinitstr : initial strain descriptor				*/

#define 	MAX_INITSTR_VAR		6
#define 	MAX_INITSTR_UNIF	0


/* ---------------------------------------------------------------------
	FEfdinjpt : inj pt descriptor					*/

#define 	MAX_INJPT_VAR	0	/* Max number of variable data	*/
#define 	MAX_INJPT_UNIF	0	/* Number of bytes for unif data*/


/*	-----------------------------
 *	BEGIN Sacrificial Elements FD
 */

#define		MAX_SACRIF_VAR	0		/* Max number of variable data	*/
#define		MAX_SACRIF_UNIF	0

/*	---------------------------
 *	END Sacrificial Elements FD
 */

/* --------------------------------------------------------------

	Define One Feature Descriptor Union Which is The Union of
	All Feature Descriptors Defined Above
*/
	union fefd_var {			/* combined fd unions 	*/
		union femat_var		mat;
  		union feprop_var	prop;
		struct fefrc_var	frc;
		struct fespdisp_var	spdisp;
		struct feorient_var	orient;
		struct femass_var	mass;
		struct fetemp_var	temp;
                struct febmofs_var      bmofs;
                struct fedynload_var	dynload;
                struct fematornt_var	matornt;
		struct fe_ht_src_var 	heat_source;
		struct fe_convec_var 	convec;
		struct fe_radi_var 	radi;
		struct feintemp_var 	intemp;
		};

	union fefd_unif {
		union feprop_unif	prop;
		struct fecnst_unif	cnst;
		struct fefrc_unif	frc;
		struct febmrel_unif	bmrel;
                struct feic_unif	initcond;
                struct fedynload_unif	dynload;
                struct fematornt_unif	matornt;
		struct fe_ht_src_unif	heat_source;
		struct fe_convec_unif	convec;
		struct fe_radi_unif 	radi;
	};

#define		MAX_VAR_DATA	42
				/* Tapered Beam Property			*/
				/* Prev max : Aniso var				*/
				/* Maximum number of variables in fd data	*/
#define		MAX_UNIF_DATA	128
				/* CANNOT use sizeof(union fefd_unif)		*/
				/* 128 Initial conditions unif is max;		*/
				/* Maximum size of uniform fd data		*/

#endif
