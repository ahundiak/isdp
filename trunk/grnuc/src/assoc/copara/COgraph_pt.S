/*----


	JLA       : 23-Sep-86 first release


   Command object of graph printer

---- */



class specification COgraph_pt (0:1) of COpara;

instance COgraph_pt
{
variable struct GRid list_id[10]; /* located object for print */
IGRint p_count;		  /* nb of located object */

};

override wakeup, execute;


end specification COgraph_pt;
