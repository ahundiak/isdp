/* $Id $  */

/* I/VDS
 *
 * File:        $VDS/include/vdprodinfo.h
 *
 * Description:
 *      This include file provides constants and macro used 
 *      to get processing information
 *
 * Dependencies:
 *
 * Revision History:
 *	$ $
 *
 * History:
 *      12/04/97        YZHU        Creation 
 ******************************************************************/

#ifndef vd_procinfo_include
#       define vd_procinfo_include

/* flag type */
#define VD_PROC_MASS            1       /* 0000 0000 0000 0001 */
#define VD_PROC_VOLUME          2       /* 0000 0000 0000 0010 */
#define VD_PROC_AREA            4       /* 0000 0000 0000 0100 */
#define VD_PROC_COG             8       /* 0000 0000 0000 1000 */
#define VD_PROC_DIM            16       /* 0000 0000 0001 0000 */
#define VD_PROC_RANGE          32       /* 0000 0000 0010 0000 */
#define VD_PROC_MOMENT         64       /* 0000 0000 0100 0000 */
#define VD_PROC_LOC           128       /* 0000 0000 1000 0000 */
#define VD_PROC_AXIS          256       /* 0000 0001 0000 0000 */


/*
 * Structure defining a VDprcAttr: 
 */
struct VD_s_procAttr {
        IGRdouble       density;         
        IGRdouble       mass;         
        IGRdouble       volume;         
        IGRdouble       area;         
        IGRdouble       cog[3];
        IGRdouble       dim[3];
        IGRdouble       range[6];
        IGRdouble       moment[6];
        IGRdouble       loc[3];
	IGRdouble       axis[9];
} ;
typedef struct VD_s_procAttr VDprcAttr ;


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern long VDproc_Attr __(( IGRlong 	*msg,
                             struct 	GRid grid,
                             struct 	GRmd_env *md_env,
		             double     *mass,
			     double     *volume,
			     double     *area,
			     IGRpoint   cog, 
			     IGRpoint   dim, 
		             GRrange    range, 
			     GRrange    moment)); 


#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------

  MACRO

     vd$proc_attr(  );

  ABSTRACT

     Get processing information like, weight, center of gravity, mass and range

  ARGUMENTS

        data type       argument        description     I/O 
	IGRlong         *msg;                            O 
	struct GRid     grid;                            I 
	struct GRmd_env *md_env;                         I 
	double          *mass;                           O 
	double          *volume;                         O 
	double          *area;                           O 
	IGRpoint        cog;                             O 
	IGRpoint        dim;                             O 
	GRrange         range;                           O 
	GRrange         moment;                          O 
       
  EXAMPLE


  REMARKS


  Return Status
 		OM_S_SUCCESS ;

----------------------------------------------------------------------------*/
/*===========================================================================*/

#omdef  vd$proc_attr( msg,
                      grid,
                      md_env,
                      mass      = NULL,
                      volume 	= NULL,
                      area	= NULL,
                      cog	= NULL,
                      dim	= NULL,
                      range	= NULL,
                      moment    = NULL)

	VDproc_Attr( (msg), (grid), (md_env), (mass),
                     (volume), (area), (cog), (dim), (range), (moment)) 


#endomdef

/*============================================================================*/



#endif /* vd_procattr_include */
