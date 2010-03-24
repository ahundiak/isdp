

class implementation IGEgadget;

#include "igewinerr.h"
#include "igewindef.h"
		
method dep_extents(IGRlong *msg; IGRint *min_x; IGRint *min_y; 
		    IGRint *max_x; IGRint *max_y)
		
	{
	   
	   *msg = OM_S_SUCCESS;
	
	
	   *min_x = ME.IGEgadget->min_x_dep;
	   *min_y = ME.IGEgadget->min_y_dep;
	   *max_x = ME.IGEgadget->max_x_dep;
	   *max_y = ME.IGEgadget->max_y_dep;	
	   
	   return(OM_S_SUCCESS);
	}		


		
method indep_extents(IGRlong *msg; IGRdouble *min_x; IGRdouble *min_y; 
		    IGRdouble *max_x; IGRdouble *max_y)
		
	{
	   
	   *msg = OM_S_SUCCESS;
	
	
	   *min_x = ME.IGEgadget->min_x_indep;
	   *min_y = ME.IGEgadget->min_y_indep;
	   *max_x = ME.IGEgadget->max_x_indep;
	   *max_y = ME.IGEgadget->max_y_indep;	
	   
	   return(OM_S_SUCCESS);
	}		
	
	
method calc_dep_extents(IGRlong *msg;	IGRdouble min_x_indep; 
					IGRdouble min_y_indep; 
					IGRdouble max_x_indep; 
					IGRdouble max_y_indep; 
					IGRint *min_x_dep; IGRint *min_y_dep; 
		    			IGRint *max_x_dep; IGRint *max_y_dep)
		
	{
	   
   IGRint		status;
   IGRint		win_min_x;
   IGRint		win_min_y;
   IGRint		win_max_x;
   IGRint		win_max_y;

   
   OM_S_CHANSELECT	chandef;


	   *msg = OM_S_SUCCESS;

	   chandef.type = OM_e_name;
	   chandef.u_sel.name = "IGEgadget.to_parent";

	   status = om$send( msg = message IGEgadget.dep_extents( msg, 
			&win_min_x,&win_min_y, &win_max_x, &win_max_y), 
                 p_chanselect = &chandef );

           if ( ! ( status & 1) )
           {
              *msg = MSFAIL;
              goto wrapup;
           }
	

	   	   
	   *min_x_dep = (win_max_x - win_min_x) * min_x_indep + 0.5;
	   *min_y_dep = (win_max_y - win_min_y) * min_y_indep + 0.5;
	   *max_x_dep = (win_max_x - win_min_x) * max_x_indep + 0.5;
	   *max_y_dep = (win_max_y - win_min_y) * max_y_indep + 0.5;


wrapup:	   
	   return(status);
	}		


		
method calc_indep_extents(IGRlong *msg;	IGRint min_x_dep; IGRint min_y_dep; 
					IGRint max_x_dep; IGRint max_y_dep; 
					IGRdouble *min_x_indep; 
					IGRdouble *min_y_indep; 
		    			IGRdouble *max_x_indep; 
					IGRdouble *max_y_indep)
		
		
	{

   IGRint		status;
   IGRint		win_min_x;
   IGRint		win_min_y;
   IGRint		win_max_x;
   IGRint		win_max_y;

   
   OM_S_CHANSELECT	chandef;


	   *msg = OM_S_SUCCESS;

	   chandef.type = OM_e_name;
	   chandef.u_sel.name = "IGEgadget.to_parent";

	   status =om$send( msg = message IGEgadget.dep_extents( msg, 
			&win_min_x,&win_min_y, &win_max_x, &win_max_y), 
                 p_chanselect = &chandef );

           if ( ! ( status & 1) )
           {
              *msg = MSFAIL;
              goto wrapup;
           }
	

	   	   
	   *min_x_indep = ((IGRdouble) min_x_dep) / (win_max_x - win_min_x);
	   *min_y_indep = ((IGRdouble) min_y_dep) / (win_max_y - win_min_y);
	   *max_x_indep = ((IGRdouble) max_x_dep) / (win_max_x - win_min_x);
	   *max_y_indep = ((IGRdouble) max_y_dep) / (win_max_y - win_min_y);

	   
wrapup:	   
	   return(status);

	}		
	
	
		
method range_intersect(IGRlong *msg; IGRdouble min_x; IGRdouble min_y;
			IGRdouble max_x; IGRdouble max_y; 
			IGRboolean *intersect)
			
   {
      IGRint  status = OM_S_SUCCESS;

	if ((min_x > ME.IGEgadget->max_x_indep) ||
	    (max_x < ME.IGEgadget->min_x_indep) ||
	    (min_y > ME.IGEgadget->max_y_indep) ||
	    (max_y < ME.IGEgadget->min_y_indep))
	{
	   *intersect = FALSE;
	}
	else
	{
	   *intersect = TRUE;
	   status = OM_I_STOP_SENDING;
	}
	
        return(status);
   }			


method change_gadget_size(IGRlong *msg;IGRint dep_indep;
                           IGRdouble min_x, min_y, max_x, max_y)
{

IGRboolean intersect;
IGRint  status;
IGRint  min_x_dep;
IGRint  min_y_dep;
IGRint  max_x_dep;
IGRint  max_y_dep;

IGRdouble  min_x_indep;
IGRdouble  min_y_indep;
IGRdouble  max_x_indep;
IGRdouble  max_y_indep;
OM_S_CHANSELECT	chandef;


	chandef.type = OM_e_name;
	chandef.u_sel.name = "IGEgadget.to_parent";


	if (dep_indep == IGE_DEPENDENT)
	{
	   min_x_dep = min_x + 0.5;
	   min_y_dep = min_y + 0.5;
	   max_x_dep = max_x + 0.5;
	   max_y_dep = max_y + 0.5;

	   status = om$send( msg = message IGEgadget.calc_indep_extents(msg,
		                   min_x_dep,min_y_dep,max_x_dep,max_y_dep,
			      	   &min_x_indep,&min_y_indep,
			     	   &max_x_indep,&max_y_indep),
			     senderid = my_id,
			     targetid = my_id);

	  if (!(1 & status))
	  {
#ifdef DEBUG
	     om$report_error(sts = status);
#endif
	     goto wrapup;
	  }

	
	}
	else
	{
	   min_x_indep = min_x;
	   min_y_indep = min_y;
	   max_x_indep = max_x;
	   max_y_indep = max_y;

	   status = om$send( msg = message IGEgadget.calc_dep_extents(msg,
		                   min_x_indep,min_y_indep,max_x_indep,
				   max_y_indep,&min_x_dep,&min_y_dep,
			     	   &max_x_dep,&max_y_dep),
			     senderid = my_id,
			     targetid = my_id);

	  if (!(1 & status))
	  {
#ifdef DEBUG
	     om$report_error(sts = status);
#endif
	     goto wrapup;
	  }

	}


	status = om$sibling_send( msg = message IGEgadget.range_intersect(
					  msg,min_x_indep,min_y_indep,
					  max_x_indep,max_y_indep,&intersect),
				    senderid = my_id,
				    p_chanselect = &chandef,
				    inclusive = OM_e_exclusive);


	if (!(1 & status))
	{
#ifdef DEBUG
	   om$report_error(sts = status);
#endif
	   goto wrapup;
	}


	if (!intersect)
	{
	   ME.IGEgadget->min_x_dep = min_x_dep;
	   ME.IGEgadget->min_y_dep = min_y_dep;
	   ME.IGEgadget->max_x_dep = max_x_dep;
	   ME.IGEgadget->max_y_dep = max_y_dep;

	   ME.IGEgadget->min_x_indep = min_x_indep;
	   ME.IGEgadget->min_y_indep = min_y_indep;
	   ME.IGEgadget->max_x_indep = max_x_indep;
	   ME.IGEgadget->max_y_indep = max_y_indep;
	}
	else
	{
            *msg = DP_GADGET_OVERLAPED;
	    status = FALSE;
	}

wrapup:
	return(status);
}
	

method change_process_from(IGRlong *msg; IGRint pid; IGRint time_out)
{
	return(1);
}

method change_process_to(IGRlong *msg; IGRint pid; IGRint time_out)
{
	return(1);
}

end implementation IGEgadget;
