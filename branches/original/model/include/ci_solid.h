#ifndef ci_solid_include
#define ci_solid_include

#include "ci_setmd.h"

/************ mass properties stuff ***********************/
struct  GRlc_info InObj;
IGRboolean      isnatnrm,
                OtrD;
short           NdF,OsN,LpIn;
IGRlong         popt;
IGRint          FlG, 
                NsrF, 
                CinX;
IGRdouble       zleN,
                TmX[3], 
                TmY[3], 
                TmZ[3], 
                TmZ1[3], 
                octd[3], 
                actd[3],
                DnsY,
                Z0[3],
                CfaK,
                RnG,
                ScL;       
IGRdouble  solb3[3],solb4[3];
IGRchar            md_Unit[40], 
                c_name[50];
GRobj           TEMP_OBJIDS[100],
                TEMP_OBJID;
OM_S_CHANSELECT notify_chan, 
                to_object;
IGRushort  lpi;

extern int      MSget_active_csystem();
extern int      MScnvtprop();
extern void     MSdrawtriadn();
extern void     MSdisplay_prop();
extern int      EMoffset_surface_to_solid();
extern int      MSconvert_to_active_coordinates();
/***************************************************************************/
/************ DEFINE THE EASY MACROS HERE **********************************/
/***************************************************************************/
/*---------------------- md$place_cap_solid -----------------------------

#omdef  md$place_cap_solid( 
                        GRid_out = &TEMP_GRID_NEW,
                        GRid_in  = TEMP_GRID,
                        name = "0", 
                        disp = DRAW)

 Abstract:

        This macro will cap a surface into a solid.

 Arguments:

        GRid_out        O       struct GRid     Output GRid of the solid

        GRid_in         I       struct GRid     Input GRid of the surface

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.


 Sample Call:

        struct GRid     SURFACE, SOLID;
        char ele_name[255];

        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsurface",
                   prompt= "Identify surface to cap");
        strcpy(ele_name, "cap_solid");        

         md$place_cap_solid( 
                        GRid_out = &SOLID,
                        GRid_in  = SURFACE,
                        name = ele_name, 
                        disp = DRAW);

 Notes:

        All the arguments have defaults for easy of use.

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef  md$place_cap_solid( 
                        GRid_out = &TEMP_GRID_NEW,
                        GRid_in  = TEMP_GRID,
                        name = "0", 
                        disp = DRAW)

        cap_surface( GRid_in, GRid_out, name, disp);
#if   !om$specified(GRid_out)
        TEMP_GRID = TEMP_GRID_NEW;
#endif
#endomdef

/*---------------------- place$cap_solid -----------------------------

   place$cap_solid( GRid_out = TEMP_GRID_NEW,
		    GRid_in  = TEMP_GRID,
		    name     = "0",
		    disp     = DRAW )

   md$place_cap_solid( GRid_out = &TEMP_GRID_NEW,
                       GRid_in  =  TEMP_GRID,
                       name     =  "0", 
                       disp     =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$cap_solid( GRid_out = TEMP_GRID_NEW,
                        GRid_in  = TEMP_GRID,
                        name     = "0", 
                        disp     = DRAW )

   cap_surface( (GRid_in), &(GRid_out), (name), (disp) );

#if (! om$specified(GRid_out))
   TEMP_GRID = TEMP_GRID_NEW;
#endif

#endomdef

/*---------------------- md$solid_boolean -------------------------------

#omdef  md$solid_boolean(
                        num_objects,    
                        GRids_in,
                        op_type = DIFFERENCE,   
                        GRid_out = &TEMP_GRID,
                        name = "0",
                        disp = DRAW)
 Abstract:

        This macro will perform the 5 boolean operations on the input
        solids. The options are:

        #define INTERSECTION    0 
        #define UNION           1
        #define DIFFERENCE      2 
        #define SAVE_SIDE       3 
        #define DISJOINT_UNION  4
        #define HOLLOW_DIFF     5 

 Arguments:

        num_objects     I       IGRint          Input number of solids
        
        GRids_in        I       struct GRid     Input GRids of the solids

        op_type         I       IGRint          Input boolean operation type
        
        GRid_out        O       struct GRid     Output GRid of the solid

        name            I/O     IGRchar         Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:


        struct GRid     SOLIDS[15], SOLID;
        IGRint          i;
        char ele_name[255];
        i = 0;
        while(1)
        {

                if(!ci$locate(  obj     = &SOLIDS[i].objid,
                                osnum   = &SOLIDS[i].osnum,
                                classes = "EMSsolid",
                                prompt  = "Identify solid"))break;

                if( i > 13 ) break;

                i = i + 1;
        }
        strcpy(ele_name, "bool_op");
        md$solid_boolean(
                        num_objects = i,      
                        GRids_in = SOLIDS,
                        op_type = DIFFERENCE,   
                        GRid_out = &SOLID,
                        name = ele_name,
                        disp = DRAW);
        
 Notes:

        The first solid is the array is the base solid that the others in
        the array will act against. 

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef  md$solid_boolean(
                        num_objects,    
                        GRids_in,
                        op_type = DIFFERENCE,   
                        bool_disp = 1,  
                        GRid_out = &TEMP_GRID,
                        name = "0",
                        disp = DRAW)

        boolean(num_objects,GRids_in,op_type,bool_disp,GRid_out,name,disp);
#endomdef

/*---------------------- solid$boolean -------------------------------

   solid$boolean( num_objects,
		  GRids_in,
		  op_type   = DIFFERENCE,
		  bool_disp = 1,
		  GRid_out  = TEMP_GRID,
		  name      = "0",
		  disp      = DRAW )

   md$solid_boolean( num_objects,
                     GRids_in,
                     op_type   =  DIFFERENCE,
                     bool_disp =  1,
                     GRid_out  = &TEMP_GRID,
                     name      =  "0",
                     disp      =  DRAW )
-----------------------------------------------------------------------*/

#omdef solid$boolean( num_objects,
                      GRids_in,
                      op_type   = DIFFERENCE,
                      bool_disp = 1,
                      GRid_out  = TEMP_GRID,
                      name      = "0",
                      disp      = DRAW )

#if (! (om$specified(GRids_in) || om$specified(num_objects)))
#  omerror "Must specify GRids_in and num_objects"
#else
   boolean( (num_objects),(GRids_in),(op_type),
	    (bool_disp),&(GRid_out),(name),(disp))
#endif

#endomdef

/*---------------------- md$solid_compress ------------------------------

#omdef  md$solid_compress(
                        GRid_in = TEMP_GRID,    
                        GRid_out = &TEMP_GRID_NEW)

 Abstract:

        This macro compresses the boolean tree of the input solid. The
        input solid will be reduced to a general solid which is the 
        GRid_out object.

 Arguments:

        GRid_out        O       struct GRid     Output GRid of the compressed
                                                solid.

        GRid_in         I       struct GRid     Input GRid of the solid to
                                                compress

 Sample Call:

        struct GRid     SOLID, SOLID_OUT;

        ci$locate( obj   = &SOLID.objid,
                   osnum = &SOLID.osnum,
                   classes = "EMSsolid",
                   prompt= "Identify solid to compress");
        
        md$solid_compress(
                  GRid_in = SOLID,      
                  GRid_out = &SOLID_OUT);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef  md$solid_compress(
                        GRid_in = TEMP_GRID,    
                        GRid_out = &TEMP_GRID_NEW)

        solid_compress(GRid_in,GRid_out);
#if   !om$specified(GRid_out)
      TEMP_GRID = TEMP_GRID_NEW;
#endif
#endomdef

/*---------------------- solid$compress ------------------------------

   solid$compress( GRid_in  = TEMP_GRID,
		   GRid_out = TEM_GRID_NEW )

   md$solid_compress( GRid_in  = TEMP_GRID,
                      GRid_out = &TEMP_GRID_NEW )
-----------------------------------------------------------------------*/

#omdef solid$compress( GRid_in  = TEMP_GRID,
                       GRid_out = TEMP_GRID_NEW )

   solid_compress( (GRid_in),&(GRid_out));

#if (! om$specified (GRid_out))
   TEMP_GRID = TEMP_GRID_NEW;
#endif

#endomdef

/*---------------------- md$solid_mass_properties -----------------------

#omdef md$solid_mass_properties(
                        GRid_in = TEMP_GRID,
                        ENV_in = env,
                        GRid_out = &TEMP_GRID_NEW,
                        density = 1.0,
                        want_triad = TRUE,
                        want_file  = TRUE,
                        append_file = TRUE,
                        props,
                        prop_name = "MASS.prop",
                        disp = DRAW)

 Abstract:

        this macro will compute the mass properties of a solid and possibly
        write the results out to a file of the same name as the mass property
        object.

 Arguments:

        GRid_in         I       struct GRid     Input GRid of the solid

        GRid_out        O       struct GRid     Output GRid of the mass
                                                properties triad.

        density         I       double          The density of the solid.

        want_triad      I       int             Do you want the mass property
                                                triad constructed ?
                                                TRUE = yes, FALSE = no.

        want_file       I       int             Do you want to create an
                                                ascii file of the results?
                                                TRUE = yes, FALSE = no.

        append_file     I       int             Do you want to append the
                                                results to previously created
                                                file? TRUE = yes, FALSE = no.


        props           O       IGRdouble[30]   Output array of mass property
                                                data.

        prop_name               I/O     IGRchar         Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:

        struct GRid     SOLID, MASS_PROPS;
        double          properties[30], density;
        char            prop_name[255];

        ci$locate( obj   = &SOLID.objid,
                   osnum = &SOLID.osnum,
                   classes = "EMSsolid",
                   prompt= "Identify solid for mass props");
        
        ci$get( value = density, prompt=" key in density");
        strcpy(prop_name, "mass_props");
        md$solid_mass_properties(
                        GRid_in = SOLID,
                        GRid_out = &MASS_PROPS,
                        density = density,
                        props = properties,
                        prop_name = prop_name);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.
        6/4/95  KNAP    Added ENV_in, to work for reference files.

-----------------------------------------------------------------------*/

#omdef md$solid_mass_properties
                        (GRid_in = TEMP_GRID,
                        ENV_in = &MOD_ENV,
                        GRid_out = &TEMP_GRID_NEW,
                        density = 1.0,
                        want_triad = TRUE,
                        want_file  = TRUE,
                        append_file = TRUE,
                        props,
                        prop_name = "MASS.prop",
                        disp = DRAW)
MSdo_mass_prop(GRid_in, ENV_in, GRid_out, density, want_triad, want_file,
               append_file, props, prop_name, disp);
#if !om$specified(GRid_out)
TEMP_GRID=TEMP_GRID_NEW;
#endif

#endomdef

/*---------------------- solid$mass_properties -----------------------

   solid$mass_properties( GRid_in     = TEMP_GRID,
                          ENV_in      = env,
			  GRid_out    = TEMP_GRID_NEW,
			  density     = 1.0,
			  want_triad  = TRUE,
			  want_file   = TRUE,
			  append_file = TRUE,
			  props       = double100,
			  name        = "MASS.prop",
			  disp        = DRAW )

   md$solid_mass_properties( GRid_in     =  TEMP_GRID,
                             ENV_in      =  env,
                             GRid_out    = &TEMP_GRID_NEW,
                             density     =  1.0,
                             want_triad  =  TRUE,
                             want_file   =  TRUE,
                             append_file =  TRUE,
                             props,
                             prop_name   = "MASS.prop",
                             disp        = DRAW)
-----------------------------------------------------------------------*/

#omdef solid$mass_properties( GRid_in     = TEMP_GRID,
                              ENV_in      =  &MOD_ENV,
			      GRid_out    = TEMP_GRID_NEW,
			      density     = 1.0,
			      want_triad  = TRUE,
			      want_file   = TRUE,
			      append_file = TRUE,
			      props       = double100,
			      name        = "MASS.prop",
			      disp        = DRAW )

   MSdo_mass_prop( (GRid_in), (ENV_in), &(GRid_out),(density),(want_triad),
		   (want_file),(append_file),(props),(name),(disp) );

#if (! om$specified (GRid_out))
   TEMP_GRID = TEMP_GRID_NEW;
#endif

#endomdef

/*---------------------- md$place_solid_box -----------------------------

#omdef  md$place_solid_box(
                        point1,
                        point2, 
                        point3 = solb3,
                        point4 = solb4,
                        ortho = TRUE,
                        GRid_out = &TEMP_GRID,
                        name = "0", 
                        disp = DRAW)

 Abstract:

        This macro will create a solid box by 2 or 4 points.

 Arguments:

        point1          I       IGRdouble[3]    Input point1 of box
                        
        point2          I       IGRdouble[3]    Input point2 of box

        point3          I       IGRdouble[3]    Input point3 of box

        point4          I       IGRdouble[3]    Input point4 of box

        ortho           I       int             Input whether the box
                                                has got 90 deg sides
                                                or not. TRUE = 90 deg
                                                FALSE = no.

        GRid_out        O       struct GRid     Output object GRid

        name            I/O     IGRchar        Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.


 Sample Call:

        double  point1[3], point2[3], point3[3], point4[3];
        struct GRid     BOX;
        char ele_name[255];  
        ci$get( point = point1, prompt="identify point 1");

        ci$get( point = point2, prompt="identify point 2");

        ci$get( point = point3, prompt="identify point 3");

        ci$get( point = point4, prompt="identify point 4");
        strcpy(ele_name, "sol_box");
        md$place_solid_box(
                        point1 = point1,
                        point2 = point2,        
                        point3 = point3,
                        point4 = point4,
                        GRid_out = &BOX,
                        name = ele_name);

 Notes:

        The box can be created from 2 points which will create an orthogonal
        box or with 4 points the box can be ortho or not.

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef  md$place_solid_box(
                        point1,
                        point2, 
                        point3 = solb3,
                        point4 = solb4,
                        ortho = TRUE,
                        GRid_out = &TEMP_GRID,
                        name = "0", 
                        disp = DRAW)


#if   !om$specified(point3) && !om$specified(point4)
  {
        solb3[0]=point2[0];
        solb3[1]=point1[1];
        solb3[2]=point1[2];
        solb4[0]=point1[0];
        solb4[1]=point2[1];
        solb4[2]=point1[2];
        solid_box( (GRid_out),(point1), solb3, solb4,(point2),
                        TRUE,(name),(disp));
  }
#else
  {

        solid_box( (GRid_out),(point1),(point2),(point3),(point4),
                        (ortho),(name),(disp));
  }
#endif

#endomdef

/*---------------------- place$solid_box -----------------------------

   place$solid_box( point1,
		    point2,
		    point3   = solb3,
		    point4   = solb4,
		    ortho    = TRUE,
		    GRid_out = TEMP_GRID,
		    name     = "0"
		    disp     = DRAW )

   md$place_solid_box( point1,
                       point2, 
                       point3   =  solb3,
                       point4   =  solb4,
                       ortho    =  TRUE,
                       GRid_out = &TEMP_GRID,
                       name     =  "0", 
                       disp     =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$solid_box( point1,
		        point2,
		        point3   = solb3,
		        point4   = solb4,
		        ortho    = TRUE,
		        GRid_out = TEMP_GRID,
		        name     = "0",
		        disp     = DRAW )

#if (! (om$specified(point1) || om$specified(point2)))
#  omerror "Must specify point1 and point2"
#elif (! (om$specified(point3) || om$specified(point4)))
 {
    solb3[0]=point2[0];
    solb3[1]=point1[1];
    solb3[2]=point1[2];
    solb4[0]=point1[0];
    solb4[1]=point2[1];
    solb4[2]=point1[2];
    solid_box( &(GRid_out),(point1),solb3,solb4,(point2),
                    TRUE,(name),(disp));
 }
#else
    solid_box( &(GRid_out),(point1),(point2),(point3),(point4),
                (ortho),(name),(disp) );
#endif

#endomdef

/*---------------------- md$place_solid_offset --------------------------

#omdef  md$place_solid_offset(
                        GRid_in = TEMP_GRID,    
                        GRid_out = &TEMP_GRID_NEW,
                        offset   = 1,
                        natural_normal = TRUE,
                        name     = "0",
                        disp     = DRAW)

 Abstract:

        This macro will create an offset solid, from a surface.

 Arguments:

        GRid_in         I       struct GRid     Input GRid of the surface to 
                                                offset.

        GRid_out        O       struct GRid     Output GRid of the solid

        offset          I       IGRdouble       Input offset value

        natural_normal  I       IGRint          Input is natural side for offset
                                                ok? TRUE = yes, FALSE = no.

        name            I/O     IGRchar         Input/output name of the object,
                                                in the event the name is not
                                                unique in the directoy then it
                                                will create a name which is the
                                                name with a number on the end.

        disp            I       IGRint          The display option for the 
                                                object which is defined in
                                                ci_easy.h.

 Sample Call:

        double          offset;
        struct GRid     SURFACE, SOLID;
        char            ele_name[255];

        ci$locate( obj   = &SURFACE.objid,
                   osnum = &SURFACE.osnum,
                   classes = "EMSsubbs",
                   prompt= "Identify surface to offset");

        ci$get(value = offset, prompt="key in offset value");

        strcpy(ele_name, "offset_solid");
        md$place_solid_offset(
                        GRid_in  = SURFACE,     
                        GRid_out = &SOLID,
                        offset   = offset,
                        natural_normal = TRUE,
                        name     = ele_name,
                        disp     = DRAW);

 Notes:

 Caveats:

 History:

        8/2/90  jvh     Created and documented.

-----------------------------------------------------------------------*/

#omdef  md$place_solid_offset(
                        GRid_in = TEMP_GRID,    
                        GRid_out = &TEMP_GRID_NEW,
                        offset   = 1,
                        natural_normal = TRUE,
                        name     = "0",
                        disp     = DRAW)


        solid_offset(GRid_out,GRid_in,offset,natural_normal,name,disp)
#endomdef

/*---------------------- place$solid_offset --------------------------

   place$solid_offset( GRid_in        = TEMP_GRID,
		       GRid_out       = TEMP_GRID_NEW,
		       offset         = 1,
		       natural_normal = TRUE,
		       name           = "0",
		       disp           = DRAW )

   md$place_solid_offset( GRid_in        =  TEMP_GRID,
                          GRid_out       = &TEMP_GRID_NEW,
                          offset         =  1,
                          natural_normal =  TRUE,
                          name           =  "0",
                          disp           =  DRAW )
-----------------------------------------------------------------------*/

#omdef place$solid_offset( GRid_in        = TEMP_GRID,
		           GRid_out       = TEMP_GRID_NEW,
		           offset         = 1,
		           natural_normal = TRUE,
		           name           = "0",
		           disp           = DRAW )

   solid_offset( &(GRid_out),(GRid_in),(offset),(natural_normal),(name),(disp))

#endomdef

/************ END OF MACRO DEFINITIONS ***********************************/










/*******
        THESE ARE THE SUPPORTING FUNCTIONS FOR EACH OF THE ABOVE
        MACROS. THESE ARE SUBJECT TO CHANGE SO I DON'T RECOMEND
        THE COPYING OF THE CODE BELOW FOR USE.
*******/

// CAP A SURFACE INTO A SOLID
#define cap_surface( surface_in, object ,name,disp)\
\
    set_up_easy();\
\
    if( (surface_in).objid == NULL_OBJID || (surface_in).objid == 0 )\
        {\
          status(" no surface was found");\
        }\
    if( (surface_in).objid != NULL_OBJID && (surface_in).objid != 0  )\
        {\
        status("processing .");\
        (*(object)).objid = NULL_OBJID;\
        (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
        status("processing ...");\
        ci$send( msg = message EMSsfsolid.EMcap_thyself( \
                &rtcd,\
                &cst,\
                &(surface_in).objid ) ,\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
\
        status("processing .....");\
        if( rtcd != SOL_SUC )\
        {\
          status("cap surface failed");\
          (*(object)).objid = NULL_OBJID;\
        }\
        if( rtcd == SOL_SUC )\
        {\
           name_display(*(object), (name), (disp));\
           status("");\
        }\
       }


#ifndef ci_surface_include
#define INTERSECTION    0 
#define UNION           1
#define DIFFERENCE      2 
#define SAVE_SIDE       3 
#define DISJOINT_UNION  4
#define HOLLOW_DIFF     5 
#endif


#define boolean(num_obj,objects,operation,bdisp,object,name,disp)\
\
  set_up_easy();\
\
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;\
  cst.newflag    = FALSE;\
  (*(object)).objid = NULL_OBJID;\
  (*(object)).osnum = MOD_ENV.md_id.osnum;\
\
  for(LpIn=0;LpIn<(num_obj)-1; LpIn=LpIn+1) \
        {\
        TEMP_OBJIDS[LpIn] = (objects)[LpIn+1].objid;\
        }\
\
  ci$send( msg = message EMSslboolean.EMboolean( \
                &rtcd,\
                &MOD_ENV.md_env.matrix_type,\
                MOD_ENV.md_env.matrix,\
                (objects)[0].objid,\
                (num_obj)-1,\
                TEMP_OBJIDS,\
                &cst,\
                (operation),\
                (bdisp),\
                NULL,NULL,NULL,NULL,NULL),\
                targetid = (*(object)).objid,\
                targetos = (*(object)).osnum);\
\
  cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;\
  cst.newflag    = TRUE;\
  name_display((*(object)), (name), (disp));

#define  solid_compress(object_in,object_out)\
\
        set_up_easy();\
\
        ci$send(msg = message EMSdpr.EMmake_primitive1(\
                &rtcd,\
                &MOD_ENV,\
                (object_out)),\
                targetid = (object_in).objid,\
                targetos = (object_in).osnum);


#define solid_box(oB,p1,p2,p3,p4,oR,name,disp)\
\
set_up_easy();\
\
if((oR)==TRUE)\
{\
v_sub(p2,p1,p2);\
v_sub(p3,p1,p3);\
v_sub(p4,p1,p4);\
v_equal(p2,TmX);\
BSnorvec(&rtcd,TmX);\
BScrossp(&rtcd,p2,p3,TmZ);\
BSnorvec(&rtcd,TmZ);\
BScrossp(&rtcd,TmX,TmZ,TmY);\
zleN=BSdotp(&rtcd,TmY,p3);\
v_scale(TmY,zleN,p3);\
zleN=BSdotp(&rtcd,TmZ,p4);\
v_scale(TmZ,zleN,p4);\
}\
if((oR)!=TRUE)\
{\
v_sub(p2,p1,p2);\
v_sub(p3,p1,p3);\
v_sub(p4,p1,p4);\
}\
\
(*(oB)).objid = NULL_OBJID;\
(*(oB)).osnum = MOD_ENV.md_id.osnum;\
\
ci$send(msg=message EMSblock.GRconstruct(&cst),\
targetid = (*(oB)).objid);\
\
ci$send(msg=message EMSblock.EMboxbyhwd(&rtcd,&cst,p1,p2,p3,p4),\
targetid=(*(oB)).objid,targetos=(*(oB)).osnum);\
\
if((disp)>=DRAW&&(disp)<=ERASE_ERASEHILITE_OVER)\
{\
display=(disp);\
ci$send(msg = message GRgraphics.GRdisplay(\
&rtcd,\
&MOD_ENV.md_env.matrix_type,\
MOD_ENV.md_env.matrix,\
&display,\
&dspGRid),\
targetid = (*(oB)).objid,\
targetos = (*(oB)).osnum);\
}\
\
if(strcmp((name),"0") != 0)\
{\
put_name((name), (*(oB)));\
}


#define solid_offset(object,objin,offset,normal,name,disp)\
\
  set_up_easy();\
\
  InObj.located_obj = (objin);\
  InObj.module_info = MOD_ENV;\
\
  (*(object)).objid = NULL_OBJID;\
  (*(object)).osnum = MOD_ENV.md_id.osnum;\
  isnatnrm = (normal);\
\
  rtcd = EMoffset_surface_to_solid(\
                &InObj,\
                (offset),\
                isnatnrm,\
                &cst,\
                0,\
                &(*(object)).objid);\
  name_display((*(object)), (name), (disp));

MSdo_mass_prop(GRid_in, ENV_in, GRid_out, density, want_triad, want_file,
               append_file, props, prop_name, disp)
struct GRid GRid_in, *GRid_out;
struct GRmd_env *ENV_in;
double density;
int want_triad, want_file, append_file;
double *props;
char *prop_name;
int  disp;
{
  double *in_orient;
  double outprops[20];
  int i;
  char file_name[20];


  Dbl9=(double*)malloc(9*sizeof(double));
  Dbl6=(double*)malloc(6*sizeof(double));
  in_orient=(double*)malloc(9*sizeof(double));

  set_up_easy();
  strcpy(file_name,prop_name);

  OsN=GRid_in.osnum;
  for(lpi=0;lpi<9;lpi=lpi+1)Dbl9[lpi]=0.0;
  for(lpi=0;lpi<9;lpi=lpi+4)Dbl9[lpi]=1.0;

  om$make_chanselect(channame="GRnotify.notification",
                     p_chanselect=&notify_chan);

  om$make_chanselect(channame="EMSmassprop.to_object",
                     p_chanselect=&to_object);

  (*(GRid_out)).objid=NULL_OBJID;
  (*(GRid_out)).osnum=OsN;

  /*See if theres already an EMSmassprop object*/
  ci$send(msg=message EMSmassprop.EMget_objectid(&rtcd, GRid_out),
          targetid=GRid_in.objid,
          targetos=GRid_in.osnum,
          p_chanselect=&notify_chan);
                          
  if ((*(GRid_out)).objid != NULL_OBJID)
  {
    status("mass properties already exists");
    return;
  }

  ci$send(msg=message EMSmassprop.GRconstruct(&cst),
          targetid=(*(GRid_out)).objid,
          targetos=(*(GRid_out)).osnum);

  name_display((*(GRid_out)),(prop_name),(disp));
  if(append_file != TRUE)
    strcpy(file_name,prop_name);


  CinX=GRDGNLIMITS_MAX_I;
  ci$send(msg=message Root.connect(
              to_object,
              CinX,
              GRid_in.objid,
              GRid_in.osnum,
              notify_chan,
              0),
          targetid=(*(GRid_out)).objid,
          targetos=(*(GRid_out)).osnum);

  ci$send(msg=message EMSmassprop.EMinitialize(&rtcd),
          targetid=(*(GRid_out)).objid,
          targetos=(*(GRid_out)).osnum);

  DnsY=density;

  ci$send(msg=message EMSmassprop.EMset_density(&rtcd,DnsY),
          targetid=(*(GRid_out)).objid,
          targetos=(*(GRid_out)).osnum);

  ci$send(msg=message EMSmassprop.EMset_type(&rtcd,0),
          targetid=(*(GRid_out)).objid,
          targetos=(*(GRid_out)).osnum);

  OtrD=0;
  ci$send(msg=message GRgraphics.GRgetrang(
              &rtcd,
              &ENV_in->md_env.matrix_type,
              ENV_in->md_env.matrix,
              &OtrD,
              Dbl6),
          targetid=GRid_in.objid,
          targetos=GRid_in.osnum);

  v_sub(Dbl6,&Dbl6[3],Z0);
  RnG=v_len(Z0);v_identity(Z0);

  ci$send(msg=message GRowner.GRget_number_components(&rtcd, &NsrF),
          targetid=GRid_in.objid,
          targetos=GRid_in.osnum);

  ScL=1.0;
  ci$send(msg=message EMSsurface.EMmassprop(
              &rtcd,
              NsrF,
              RnG,
              ENV_in,
              ScL,
              Z0,
              &DnsY,
              props),
          targetid=GRid_in.objid,
          targetos=GRid_in.osnum);
  popt=1;
  OtrD=1;
  ci$send (msg = message EMSmassprop.EMget_gloloc(&rtcd,in_orient),
          targetid=(*(GRid_out)).objid,
          targetos=(*(GRid_out)).osnum);

  MSget_active_csystem(&rtcd, *ENV_in, Dbl9); 

  MScnvtprop(props,&props[2],in_orient,outprops,&props[2], 
             Dbl9);

  if(want_triad==TRUE)
    ScL =1.0;
      MSdrawtriadn(
                    (IGRlong *)&rtcd,
                    (IGRlong )popt,
                    (IGRdouble *)Dbl9,
                    (IGRdouble)ScL,
                    (IGRdouble *)outprops,
                    ENV_in,
                    (struct IGRdisplay *)&dis,
                    (OM_S_OBJID) ENV_in->md_id.objid,
                    (IGRboolean)OtrD,
                    (struct GRvg_construct *)&cst,
                    (struct GRid *)GRid_out);

  GRcvt_imp_to_wrk(&rtcd,"UOM_DISTANCE",OsN,1.0,0.0,0.0,&CfaK);

  FlG=0;
  NdF=1;

  GRget_default_units(&rtcd,"UOM_DISTANCE",OsN,&FlG,&NdF,md_Unit);

  v_equal(&outprops[2],octd);

  MSconvert_to_active_coordinates(&rtcd, *ENV_in,octd,actd,&FlG,c_name);

  for(i=0;i<3;i=i+1)
  {
   outprops[2+i] = actd[i];
  }

  if(want_file==TRUE)
  {
    MSdisplay_prop(FALSE,file_name,1,0,prop_name,Dbl9,NULL,outprops,
    CfaK,md_Unit,FlG,c_name,"");
  }

  MSdisplay_prop(TRUE,NULL,1,0,prop_name,Dbl9,NULL,outprops,
  CfaK,md_Unit,FlG,c_name,"");
  free(Dbl9);
  free(Dbl6);
  free(in_orient);
  return;
}

// THIS IS THE END OF "ci_solid.h"
#endif
