class implementation NMintcurve;

method NMput_curve(IGRlong *EMmsg; struct IGRbsp_curve *curve;
		   unsigned char int_props)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRlong       		current_size, future_size;
 IGRdouble     		*double_ptr;
 IGRboolean		is_2d = FALSE;

 *EMmsg = EMS_S_Success;

 is_2d = (int_props & NMintobject_Is2d) ? TRUE : FALSE;

 ME.NMintcurve->order = curve->order;
 ME.NMintcurve->num_poles = curve->num_poles;
 ME.NMintcurve->bc_props = 0;
 if (curve->periodic) ME.NMintcurve->bc_props |= GRIS_PERIODIC;
 if (curve->non_uniform) ME.NMintcurve->bc_props |= GRIS_NON_UNIFORM;
 if (curve->rational) ME.NMintcurve->bc_props |= GRIS_RATIONAL;
 if (curve->phy_closed) ME.NMintcurve->bc_props |= GRIS_PHY_CLOSED;
 if (curve->planar) int_props |= NMintobject_IsPlanar;
 else int_props &= (~NMintobject_IsPlanar);

 ME.NMintcurve->int_props = int_props;

 /*
  * Fix the poles, weights, and knots
 */
 current_size = OM_DIMENSION_OF(ME.NMintcurve->packed_doubles);
 future_size = curve->num_poles * (curve->rational ? (is_2d ? 3 : 4) : 
               (is_2d ? 2 : 3)) +
               ((curve->non_uniform || curve->periodic)
               ? curve->num_knots : 0);
 if (future_size > current_size)
  OM_SET_DIMENSION(ME.NMintcurve->packed_doubles, future_size);

 /*
  * Fix the poles
 */
 double_ptr = &ME.NMintcurve->packed_doubles[0];
 OM_BLOCK_MOVE(curve->poles, double_ptr,
               curve->num_poles * (is_2d ? (2 * sizeof(IGRdouble)) :
				   sizeof(IGRpoint)));
 double_ptr += curve->num_poles * (is_2d ? 2 : 3);

 /*
  * Fix the weights
 */
 if (curve->rational)
  {
   OM_BLOCK_MOVE(curve->weights, double_ptr,
                 curve->num_poles * sizeof(IGRdouble));
   double_ptr += curve->num_poles;
  }

 /*
  * Fix the knots
  */
 if(curve->non_uniform || curve->periodic)
  {
   OM_BLOCK_MOVE(curve->knots, double_ptr,
                 curve->num_knots * sizeof(IGRdouble));
  }

EMWRAPUP(*EMmsg, sts, "NMintcurve.NMput_curve");
return(sts);
}


method NMget_curve(IGRlong *EMmsg; struct IGRbsp_curve *curve;
		   unsigned char *int_props)
{
 IGRlong	sts = OM_S_SUCCESS;
 IGRlong        num_knots, num_poles, num_bytes;
 IGRdouble	*double_ptr, *weight_ptr;
 IGRboolean	is_rational, is_2d = FALSE;

 *EMmsg = EMS_S_Success;
 is_2d = (ME.NMintcurve->int_props & NMintobject_Is2d) ? TRUE : FALSE;
 is_rational = ME.NMintcurve->bc_props & GRIS_RATIONAL;
 num_knots = ME.NMintcurve->num_poles + ME.NMintcurve->order;
 num_poles = ME.NMintcurve->num_poles;

 curve->poles = (IGRdouble *) om$malloc(size = num_poles * 
		 (is_2d ? 2 : 3) * sizeof(IGRdouble));
 curve->knots = (IGRdouble * ) om$malloc(size = num_knots * sizeof(IGRdouble));
 EMerr_hndlr(!curve->poles || !curve->knots, *EMmsg, EMS_E_NoDynamicMemory, 
	     wrapup);
	
 if(is_rational)
  {
   curve->weights = (IGRdouble *) om$malloc(size = num_poles * 
		     sizeof(IGRdouble));
   EMerr_hndlr(!curve->weights, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 else curve->rational = NULL;

 /*
 * Fill the the curve data
 */
 curve->order = ME.NMintcurve->order;
 curve->periodic = ME.NMintcurve->bc_props & GRIS_PERIODIC;
 curve->non_uniform = ME.NMintcurve->bc_props & GRIS_NON_UNIFORM;
 curve->num_poles = ME.NMintcurve->num_poles;
 curve->num_knots = num_knots;
 curve->rational = is_rational;
 curve->planar = ME.NMintcurve->int_props & NMintobject_IsPlanar;
 curve->phy_closed = ME.NMintcurve->bc_props & GRIS_PHY_CLOSED;
 curve->num_boundaries = 0;
 curve->bdrys = NULL;

 double_ptr = &ME.NMintcurve->packed_doubles[0];
 weight_ptr = double_ptr + (is_2d ? 2 : 3) * ME.NMintcurve->num_poles;

 num_bytes = (is_2d ? 2 : 3) * sizeof(IGRdouble) * num_poles;
 OM_BLOCK_MOVE(double_ptr, curve->poles, num_bytes);


 double_ptr = weight_ptr;
 /*
  * Get the weights
 */
 if (is_rational)
  {
   num_bytes = sizeof(IGRdouble) * ME.NMintcurve->num_poles;
   OM_BLOCK_MOVE( double_ptr, curve->weights, num_bytes);
   double_ptr += ME.NMintcurve->num_poles;
  }
/*
 * Get the knots
 */
 if (curve->non_uniform || curve->periodic)
  {
   num_bytes = sizeof(IGRdouble) * num_knots;
   OM_BLOCK_MOVE(double_ptr, curve->knots, num_bytes);
   double_ptr += num_knots;
  }
 else
  {
   IGRint	i;
   IGRdouble	knot_increment, knot;

   for (i = 0; i < ME.NMintcurve->order; i ++) curve->knots[i] = 0.0;

   knot_increment = 1.0 / (ME.NMintcurve->num_poles - 
                    ME.NMintcurve->order + 1.0);
   knot = 0.0;
   for (i = ME.NMintcurve->order; i < ME.NMintcurve->num_poles; i++)
    {
     knot += knot_increment;
     curve->knots[i] = knot;
    }
   for (i = ME.NMintcurve->num_poles; i < num_knots; i++)
    {
     curve->knots[i] = 1.0;
    }
  } 


 if(int_props) *int_props = ME.NMintcurve->int_props;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMintcurve.NMget_curve");
return(sts);
}


end implementation NMintcurve;
