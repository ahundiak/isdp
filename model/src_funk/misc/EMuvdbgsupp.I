/*
  DESCRIPTION

    This file contains the following functions useful in various debugging
    situations involving uv-boundary elements.

    IGRdouble EMask_ptol() : Prompts for a parametric tolerance.
    GRobjid EMmake_loopset(os) : Prompts for various components of a loopset

  HISTORY
 
    SS  :  07/13/93  :  Creation
*/

class implementation EMSloopset;

#include <stdio.h>

from EMSsubbs import EMpartolbasis;
from EMSloop import EMlpinit, EMset_props;
from EMSloop import EMmake_natural_loop;
from EMSlinedge import EMleinit;
from EMSptedge import EMpteinit;
from EMSopenloop import EMolpinit;
from EMSgraloop import EMglpinit;

extern OMuword OPP_EMSgraloop_class_id;

IGRdouble EMask_ptol()
{
  IGRchar keyin;
  IGRshort mattyp, world;
  IGRint sfosi;
  IGRlong msg_loc;
  IGRdouble ptol;
  IGRmatrix mat;
  GRobjid sfid;
  GRspacenum sfos;

  fflush (stdin);
  EFgetchar (stderr, "Extract p-tol from surface ? [n] ", &keyin);
  if (toupper (keyin) == 'Y')
    {
    printf ("Surface is _: ");
    scanf ("%d", &sfid);
    printf ("Object space (usually 2) _: ");
    scanf ("%d", &sfosi);
    sfos = sfosi;
 
    world = TRUE;
    EMidmatrix (&msg_loc, &mattyp, mat);
    ptol = EMS_HIGH_UVLENTOL;
    om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc, &mattyp, mat,
     &world, TRUE, &ptol), targetid = sfid, targetos = sfos, 
     senderid = NULL_OBJID);
    }
  else
    {
    printf ("Input p-tol (not lower than 1e-7) _: ");
    scanf ("%lf", &ptol);
    }
  printf ("Echoing p-tol _: %9lf\n", ptol);

  return (ptol);
}




GRobjid EMmakeloopset (os)
GRspacenum os;
{
  IGRchar resp;
  IGRlong msg_loc, stat_OM;
  GRobjid loopset;

  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  om$construct (classname = "EMSloopset", p_objid = &loopset,
   osnum = os);

  EFgetchar ("Natural Loopset y/n [n] _: ", &resp);
  if (toupper (resp) == 'Y')
    {
    om$send (msg = message EMSloopset.EMmake_natural_loopset (&msg_loc, 
     NULL, NULL, NULL), targetid = loopset, targetos = os,
     senderid = NULL_OBJID);
    }

  return (loopset);
}

/*
  else
    {
    thislevel = 0;
    loopids[0] = loopsetid;
    numloops_thislevel = 1;
    more = TRUE;
    while (more)
      {
      loopinx = 0;
      numloops_nextlevel = 0;
      for (i=0; i<numloops_thislevel; i++)
        {
        printf ("Level %d, Loop %d [%d]: How many children to this loop?\n",
         thislevel, i, loopids[i]);
	fflush(stdin);
        scanf ("%d", &numloops);
        numloops_nextlevel += numloops;
        for (j=0; j<numloops; j++)
          {
	    regloop = ptloop = openloop = natloop = featurelp = FALSE;
          if (thislevel == 0)
            {
            printf ("Is this loop natural? (1/0) ");
	    fflush(stdin);
	    scanf ("%d", &yes);
            if(yes) natloop = TRUE;
            }

          if (!natloop)
            {
	     printf("regular/point/open/feature loop?(1/2/3/4) ");
	     fflush(stdin);
	     scanf("%d", &yes);
	     if(yes == 1) regloop = TRUE;
	     else if(yes == 2) ptloop = TRUE;
	     else if(yes == 3) openloop = TRUE;
	     else if(yes == 4) featurelp = TRUE;
	
            stat_OM = om$construct (classname = regloop ? "EMSloop" :
			ptloop ? "EMSptgralp" : openloop ? "EMSopenloop" :
			featurelp ? "EMSgraloop" : "EMSloop", 
			osnum = lpset_os, 
                       p_objid = &nextloopids[loopinx++]);
            EMomerr_hndlr (stat_OM, ret_end, "mklps: lpinit");
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
	    if(ptloop) numedges = 1;
	    else
	     {
              printf ("Level %d, Loop %d [%d]: How many edges?\n", thislevel+1,
                loopinx-1, nextloopids[loopinx-1]);
	      fflush(stdin);
              scanf ("%d", &numedges);
	     }
	
            printf ("Loop filename? ");
	    fflush(stdin);
            scanf ("%s", filename);
            fileptr = fopen (filename, "r");
            EMerr_hndlr (!fileptr, *msg, EMS_E_FileOpen, ret_end);
  
            for (k=0; k<numedges; k++)
              {
	      regedge = ptedge = FALSE;
              fscanf (fileptr, "%d", &poly.num_points);
              for (l=0; l<poly.num_points; l++)
                fscanf (fileptr, "%lf %lf", &poly.points[l*2],
                &poly.points[l*2+1]);
	      if(poly.num_points == 1) ptedge = TRUE;
	      else regedge = TRUE;
	  
              printf ("Edge %d: Specify edge props ",k);
	      fflush(stdin);
              scanf ("%x", &intprops);
              props = (IGRushort) intprops;
	      if(regedge)
	       {
                 stat_OM = om$construct (classname = "EMSlinedge", 
                         p_objid = &edgeids[k], osnum = lpset_os,msg = message 
                         EMSlinedge.EMleinit (&msg_loc, props, EMlinestring, 
			 &poly, &partol_basis,NULL, NULL_OBJID));
                 EMomerr_hndlr (stat_OM, ret_end, "mklps: leinit");
                 EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	       }
	      else if(ptedge)
	       {
                 stat_OM = om$construct (classname = "EMSptedge", 
                         p_objid = &edgeids[k], osnum=lpset_os, msg = message 
                         EMSptedge.EMpteinit (&msg_loc, props, poly.points)); 
                 EMomerr_hndlr (stat_OM, ret_end, "mklps: pteinit");
                 EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	       }
	
              stat_OM = om$send (msg = message Root.connect (chan_to_loop, 
                         MAXINT, nextloopids[loopinx-1], lpset_os, 
                         chan_to_edges, 0), targetid = edgeids[k], 
			 targetos = lpset_os, 
			 senderid = nextloopids[loopinx-1]);
              EMomerr_hndlr (stat_OM, ret_end, "mklps conn edges");
  
              printf ("Edge constructed and connected [%d]\n", edgeids[k]);

              } 

            fclose (fileptr);

            printf ("Loop %d: Specify this loop's props ", j);
	    fflush(stdin);
            scanf ("%x", &intprops);
            props = (IGRushort) intprops;
            props |= EMLP_ACTIVE;
	    if(regloop)
              stat_OM = om$send (msg = message EMSloop.EMlpinit (&msg_loc,
                       props, &partol_basis, NULL), 
                       targetid = nextloopids[loopinx-1],
		       targetos = lpset_os, 
                       senderid = NULL_OBJID);
	    else if(openloop)
              stat_OM = om$send (msg = message EMSopenloop.EMolpinit (&msg_loc,
                       props, &partol_basis, TRUE), 
                       targetid = nextloopids[loopinx-1],
		       targetos = lpset_os, 
                       senderid = NULL_OBJID);
	    else if(ptloop || featurelp)
              stat_OM = om$send (msg = message EMSgraloop.EMglpinit 
				(&msg_loc, props, &partol_basis, sfid), 
                       targetid = nextloopids[loopinx-1],
		       targetos = lpset_os, 
                       senderid = NULL_OBJID);
	
            EMomerr_hndlr (stat_OM, ret_end, "mklps lpint");
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

            } 

          else
            {
            stat_OM = om$construct (classname = "EMSloop", 
			osnum = lpset_os, 
                       p_objid = &nextloopids[loopinx++], msg = message
                       EMSloop.EMmake_natural_loop (&msg_loc,
                       NULL, NULL, natedges));
            EMomerr_hndlr (stat_OM, ret_end, "mklps:nat loop");
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    
            printf ("Natural Loop: %d\n", nextloopids[loopinx-1]);
            printf ("Natural edges: %d %d %d %d\n", natedges[0], natedges[1], 
             natedges[2], natedges[3]);

            props = EMLP_ACTIVE;
            stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc,
                       props, EMS_O_ON), targetid = nextloopids[loopinx-1],
			targetos = lpset_os, 
                       senderid = NULL_OBJID);
            EMomerr_hndlr (stat_OM, ret_end, "mklps:nat loop");
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

            } 

          if (thislevel == 0)
            from_channel = chan_to_loops;
          else
            from_channel = chan_to_inner;
          stat_OM = om$send (msg = message Root.connect (chan_to_outer, 
                     MAXINT, loopids[i], lpset_os, 
                     from_channel, 0), targetid = nextloopids[loopinx-1],
                     targetos = lpset_os, senderid = loopids[i]);
          EMomerr_hndlr (stat_OM, ret_end, "mklps conn loop");

          } 
        } 
  
      if (numloops_nextlevel)
        {
        tempids = loopids;
        loopids = nextloopids;
        nextloopids = tempids;
        numloops_thislevel = numloops_nextlevel;
        numloops_nextlevel = 0;
        thislevel++;
        }
      else
        more = FALSE;
      } 

    } 


ret_end:
  return (stat_OM);
}
*/
end implementation EMSloopset;

