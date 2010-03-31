class implementation NMinters;

method debug()
{
 IGRlong		sts, rc;
 struct EMSinters	*inters[2];
 IGRchar		keyin;
 IGRint 		i;

 inters[0] = inters[1] = NULL;

 fprintf(stderr, "NMinters object:\n\tObjectid %d\n", my_id);
 fprintf(stderr, "\tProps: 0x%x\n", ME.NMinters->props);
 if(ME.NMinters->operation == NMbool_split)
  fprintf(stderr, "\tOperation: NM Split\n");
 else if(ME.NMinters->operation == NMbool_union)
  fprintf(stderr, "\tOperation: NM Union\n");
 else if(ME.NMinters->operation == NMbool_intersect)
  fprintf(stderr, "\tOperation: NM Intersection\n");
 else fprintf(stderr, "\tOperation: Unknown\n");

 sts = om$send(mode = OM_e_wrt_message, msg = message NMassoctrans.debug(), 
       targetid = my_id);

 sts = om$send(msg = message NMinters.NMget_inters(&rc, &inters[0], &inters[1],
       NULL, NULL, NULL, NULL, NULL), targetid = my_id);
 if(!(1&rc&sts)) goto wrapup;

 if(inters[0])
  {
   EFgetchar (stderr, "Output NM intersection to file y/n [n] ", &keyin);
   if (toupper (keyin) == 'Y') prtinters(inters[0]);
  }
 if(inters[1])
  {
   EFgetchar (stderr, "Output Vol intersection to file y/n [n] ", &keyin);
   if (toupper (keyin) == 'Y') prtinters(inters[1]);
  }


wrapup:
for(i=0; i<2; i++)
 {
  (void) NMset_object_data_to_null(inters[i], TRUE, TRUE);
  EMinters_data_free(&rc, inters[i], MAXINT, NULL, NULL);
  EMinters_free(inters[i], MAXINT);
 }

return(OM_S_SUCCESS);

}


end implementation NMinters;
