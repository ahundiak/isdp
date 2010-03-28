/*----

     Abstract:  Create Delete or Modify an associative attribute

     D.P. 04/12/89: Design date.

----*/


class specification COattr_p (0:1) of COpara;

instance COattr_p
  {
  variable char attr_name[80];      /* Name of the attribute to add           */
  variable int  attr_index[10];     /* Where the name or syntax begins        */
  int           nb_attr;            /* Number of attributes                   */
  int 		current_size;       /* number of char in attr_name            */
  struct GRevent grevent;           /* first event on locate   		      */
};

override 
  init,
  wakeup,
  delete,
  execute;


message store_attrib(char *name,*syntax);

/* 
  Store an attribute defined by name and syntax 
*/

message form_notification (int f_label, g_label;double value;char *fp);

end specification COattr_p;
