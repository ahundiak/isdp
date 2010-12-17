extern get_mod_info();
extern GRfindcontext();
extern ASmake_source();

GetLocTemplates( locatables, prompts, numloc )
int *locatables;
char **prompts;
int numloc;
{
int sts, msg, i, resp, owner_action, props, count;
OM_S_CLASSLIST elig_classes;
OMuword classes[2];
char mesg[512], temp[100];
struct GRid obj;
struct GRmd_env objenv;

/* TR# 139420019. 08/jun/94 - raj.	*/
OMuword ignore_classes[2];
int	no_of_ignore_classes;

	/* TR# 139420019. 08/jun/94 - raj.	*/
	/* Ignore Skmgr class objects.	*/
	om$get_classid(classname = "SKmgr",
			p_classid = &ignore_classes[0]);
	no_of_ignore_classes = 1;

        elig_classes.p_classes = classes;
        elig_classes.w_flags = OM_CLST_subclass;
        count = 1;

        props = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

        owner_action =         LC_RIGID_OWNER | LC_RIGID_COMP |
                               LC_FLEX_COMP   | LC_FLEX_OWNER |
                               LC_REF_OBJECTS | LC_ASSOCIATIVE |
			       LC_EXTERN_CONSTRAINED ;

/*
        locate_display  =  ALL_WINDOWS | NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR ;
*/

	for( i = 0; i < numloc ; i = i + 1 )
	{
		switch( locatables[i] )
		{
			case POINT_TYPE:
        			om$get_classid(classname = "GRpoint",
                        			p_classid = &classes[0]);
				break;
			case CS_TYPE:
/* 05/Sep/94 - raj. TR# 139311465. Using class "dim_plan" causes solids to be
   located since they sub-class from "dim_plan". Use "EMSdatpln" since the
   requirement is to locate "referece planes" and "coord. sys." only.
/*			        om$get_classid(classname = "dim_plan",	*/
			        om$get_classid(classname = "EMSdatpln",
                        			p_classid = &classes[1]);
        			om$get_classid(classname = "GRgencs",
                        			p_classid = &classes[0]);
        			count = 2;
                        	owner_action = owner_action | LC_HANDLES;
				break; 

			case LINE_TYPE:
        			om$get_classid(classname = "GRlineseg",
                        			p_classid = &classes[0]);
        			om$get_classid(classname = "GRlinestr",
                        			p_classid = &classes[1]);
				count = 2;
				break;

			case CONIC_TYPE:
			case CIRCLE_TYPE:
			case ARC_TYPE:
        			om$get_classid(classname = "GRconic",
                        			p_classid = &classes[0]);
				break;

			case LBS_TYPE:
        			om$get_classid(classname = "GRlbsys",
                        			p_classid = &classes[0]);
				break;
			case PLANE_TYPE: /* This is the problem one */
				break;
			case SURF_TYPE:
        			om$get_classid(classname = "EMSsurface",
                        			p_classid = &classes[0]);
				break;
			case CURVE_TYPE:
        			om$get_classid(classname = "GRcurve",
                        			p_classid = &classes[0]);
				break;
			case MACRO_TYPE:
			        om$get_classid(classname = "NDnodein",
                       			 	p_classid = &classes[0]);
				break;

			case SOLID_TYPE:
        			om$get_classid(classname = "EMSsolid",
                        			p_classid = &classes[0]);
				break;

			case REFCI_TYPE:
        			om$get_classid(classname = "GRgencs",
               					p_classid = &classes[0]);

        			om$get_classid(classname = "nci_macro",
               					p_classid = &classes[1]);
        			count = 2;
                        	owner_action = owner_action | LC_HANDLES;
				break;
			case GRAPH_TYPE:
				break;
			case UNKNOWN_TYPE:
        			om$get_classid(classname = "GRgraphics",
                        			p_classid = &classes[0]);
				break;
		}

/*
        	ex$message( msgnumb = PDR_P_LC,
  	                    buff    = temp);
*/

		sprintf( mesg, "Locate %s", prompts[i] ); 

		_pdm_debug("Calling ci$locate .....%s",mesg);

/* Now call ci$locate and fill up the grid_list

		ci$locate (obj   = &obj.objid,
		  osnum 	  = &obj.osnum,
                  prompt  	  = mesg, 
		  owner_action	  = owner_action,
                  properties	  = props,
		  response	  = &resp,
		  eligible_classes = &elig_classes );
*/
                sts =  pal$locate( msg = msg, 
                        		locate_str = mesg, 
                        		acc_str = "Accept/Reject", 
                        		relocate_str = "Relocate Object", 
					no_of_gr_classes = count, 
					gr_classes = classes, 
	/* TR# 139420019. 08/jun/94 - raj. Begin.	*/
	/* Ignore Skmgr class objects.	*/
					no_of_ignore_classes = no_of_ignore_classes, 
					ignore_classes = ignore_classes, 
	/* TR# 139420019. 08/jun/94 - raj. End		*/
					response = resp, 
					obj_md_env = &objenv,
					objid = obj.objid, 
					osnum = obj.osnum );

		_pdm_debug("resp = %d", resp );
		_pdm_debug("objid = %d", obj.objid);
		_pdm_debug("osnum = %d", obj.osnum);

		if( resp == DATA || resp == SPECIFIED_OBJ )
		{
			MakeSource ( &obj, &objenv );
			DYNA_GRID_LIST[i].objid = obj.objid;
			DYNA_GRID_LIST[i].osnum = obj.osnum;
		}
		else if( resp == RESET || resp == D_RESET ) 
		{
			if( i )
				i = i - 2; /* go back to prev prompt */
			else
				return(-1);
		}
		else
			write("Unknown response during locate\n");
	}
	return( 1 );
}

MakeSource ( locatedobj, locobjenv )
struct GRid *locatedobj;
struct GRmd_env *locobjenv;
{
long msg;
int status;
struct GRid context;
struct GRmd_env curenv;

   get_mod_info( &curenv );

   /*"look for the context matrix type: %d\n",mod_env->md_env.matrix_type*/
   status = GRfindcontext( &msg, &locobjenv->md_env.matrix_type,
                     locobjenv->md_env.matrix, &locatedobj->osnum, &context );
   if(status == OM_S_SUCCESS && msg == MSSUCC )
   {
          /*"context object found: %d, %d\n", context->objid, context->osnum */
          if(context.osnum == locatedobj->osnum)
          {
             /*|context dans le meme os */
          }
    }
    else
    {
        context.objid = NULL_OBJID;
    }
    /* Make source on the located object and return the source objid */

     status = as$make_source(go_grid = *locatedobj,
                    context_grid = context,
		    as_os = curenv.md_id.osnum,
                    as_grid = locatedobj);
}

