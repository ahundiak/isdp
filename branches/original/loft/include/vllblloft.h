
#ifndef vllblloft_include
#define vllblloft_include

typedef struct
{
  IGRdouble     	edgeLength;
  IGRvector		labelPoint;
  IGRchar      		labelString[20];
  IGRboolean		hole;
  struct GRid   	labelID;
  struct GRid		edgeID;
  struct GRobj_env	plateOE;

} LabelInfo;

#define FORM_NAME       "VLlblLoft.frm"

#define G_LABEL_FIELD   12

#endif
