/*
	I/STRUCT
*/
class specification VSimgFeature(0:0) of VSfeature, VDrelat_hdr ;

/*+c
	Class defining images of features.
	An image is the result a geometrical transformation of an element
	(mirror, translation, etc.). This image reflects the original without
	taking as much space as the original: it does not contain graphics
	or attributes. It only contains the transformation information so
	as to display itself at the desired location.
	Since it has no graphics or attributes, an image cannot be modified,
	but it can be queried.
-c*/

from VSfeature inherit	GRcopy,
			NDcopy_to_root ;

override

/*+o
Message DIgive_output

Abstract
	Print yourself in the Directory Form.
Arguments
	See message DIgive_output of class ACncpx.
-o*/
	DIgive_output,

/*+o
Message GRgetattr

Abstract
	Returns the attributes of the original.
Arguments
	See message GRgetattr of class GRvg.
-o*/
	GRgetattr,

/*+o
Message GRgetobjinfo

Abstract
	Reflects that object is an image of the original.
Arguments
	See message GRgetobjinfo of class GRgraphics.
-o*/
	GRgetobjinfo,

/*+o
Message ACgive_structure

Abstract
	If the wanted attribute is not found, see if model has it.
Arguments
	See message ACgive_structure of class NDmacro.
-o*/
	ACgive_structure,

/*+o
Message ACreturn_foot

Abstract
	If the wanted output is "", return yourself with the matrix from the
	model to yourself, otherwise resend message to self with respect
	to message.
Arguments
	See message ACreturn_foot of class NDmacro.
-o*/
	ACreturn_foot,

/*+o
Message NDdrawing_copy_geom

Abstract
	Forward message to model.
Arguments
	See message NDdrawing_copy_geom of class NDnode.
-o*/
	NDdrawing_copy_geom,

/*+o
Message ACget_db_info

Abstract
	Uses data base infiormation of model, but overrides the serial number
	to put its own.
Arguments
	See message ACget_db_info of class ACdb_info.
-o*/
	ACget_db_info,

/*+o
Message ACgive_db_structure

Abstract
	Forwards message to the original object with the ad hoc module environ-
	ment. Also intercept some values to modify them so as to reflect that
	the object is not the original, but an image.
Arguments
	See message ACgive_db_structure of class ACdb_info.
-o*/
	ACgive_db_structure,

/*+o
Message VSsetOrientation

Abstract
	Do not change orientation, ie. do nothing.
Arguments
	See message VSsetOrientation of class VSpart.
-o*/
	VSsetOrientation,

/*+o
Message VSshowOrientation

Abstract
	Forwards message to parent with ad hoc module environment.
Arguments
	See message VSshowOrientation of class VSpart.
-o*/
	VSshowOrientation,

/*+o
Message VSgetUserEditableAttr

Abstract
	Get type of parent, modifing it to reflect that object is an image.
	Returns no editable attributes.
Arguments
	See message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr,

/*+o
Message VSgetMassProperties

Abstract
	Forwards message to parent with ad hoc module environment.
Arguments
	See message VSgetMassProperties of class VSpart.
-o*/
	VSgetMassProperties,

/*+o
Message VSgetSupports

Abstract
	Returns the supports of the original.
Arguments
	See message VSgetMassProperties of class VSpart.
Note
	Beware that supports matrices will corresponds to how the original sees
	them (it will be the transformation matrixes supports -> original),
	NOT how the image sees them. To have the supports from the image's
	point of view, these matrices must be multiplied by the transformation
	matrix original -> image :

	mx_of_support( image's point of view ) :
	  mx( original -> image ) x mx_of_support( original's point of view )

	mx_of_support( original's point of view ) is returned by this message.
	mx( original -> image ) may be obtained by sending the message

		NDmacro.ACreturn_foot( &msg, "", &obj, matrix, &matrix_type )

	to the image (this here object).
-o*/
	VSgetSupports,

/*+o
Message VSdescribeOutput

Abstract
	Forwards message to original who knows the meaning of a output.
Arguments
	See message VSdescribeOutput of class VScpx.
-o*/
	VSdescribeOutput,

/*+o
Message VSgetResultType

Abstract
	Finds the result type of the original an modifies it so as to specify
	that object is an image, ie. cannot be modified.
Arguments
	See message VSgetResultType of class VSfeature.
-o*/
	VSgetResultType,

/*+o
Message VSgetOperationHistory

Abstract
	Returns the history of the original.
Arguments
	See message VSgetOperationHistory of class VSfeature.
-o*/
	VSgetOperationHistory,
	VSgetSupportedElements,
	
/*+o
Message VSforwardToOriginal

Abstract
	Forwards message to model.
Arguments
	See message VSforwardToOriginal of class VSfeature.
-o*/
	VSforwardToOriginal,

/*+o
Message VSsendToEveryoneUp

Abstract
	Forwards message to model.
Arguments
	See message VSsendToEveryoneUp of class VSfeature.
-o*/
	VSsendToEveryoneUp,

/*+o
Message VSforwardToSource

Abstract
	Forwards message to model.
Arguments
	See message VSforwardToSource of class VSfeature.
-o*/
	VSforwardToSource,

/*+o
Message VSfindCollection

Abstract
	Retrieves the named collection associated with this image.
Arguments
	See message VSfindCollection of class VSfeature.
-o*/
	VSfindCollection,

/*+o
Message VSgetUsrAttributes

Abstract
	Retrieves the collection of user attributes associated with the object.
	If there is no user attributes for this image, then sees if the model
	has such a collection; if so duplicates the collection for this image.
Arguments
	See message VSgetUsrAttributes of class VSfeature.
-o*/
	VSgetUsrAttributes,

/*+o
Message VScreateFrozenCopy

Abstract
	Creates a `frozen' ie. support-less, uneditable, unmodifable copy of
	yourself, using your model.
Arguments
	See message 'VScreateFrozenCopy' of class 'VSfeature'.
-o*/
	VScreateFrozenCopy,

/*+o
Message VSgetNormalOfComponent

Abstract
	Retrieves the component of the model and applies the mirror to its
	normal. Note that this is different from retrieving the component
	from the image and then computing its normal since the cross-product
	is not respected by a mirror:

                              |
          /  ^                |                    \
       v /   | n              |               n |   \ v
        /                     |                 v    \
	-->---------          |           ---------<--

	And we want to have a structural element and its image to have
	compatible normals, ie.:

                              |
          /  ^                |                 ^  \
       v /   | n              |               n |   \ v
        /                     |                      \
	-->---------          |           ---------<--

	Since, for instance, in the case of a plate, the normal of its
	bottom surface is supposed to indicate on which side the matter is.
Arguments
	See message 'VSgetNormalOfComponent' of class 'VSfeature'.
-o*/
	VSgetNormalOfComponent ;

/*+d
Message VSgetModel

Abstract
	Finds the id of the model and the module environment to be passed to
	the model in message sends so that geometrical operations will be
	performed on the original as if it were at the same location as me.
	The model is not necessarily the original -it may be a pointer object,
	eg. an image itself- but it will forward messages to the original.
Arguments
	OUT	struct GRid	*modelId	Id of the model.
	OUT	struct GRmd_env	*modelEnv	Module env. for operation on
						the geometry of the original
						(optional).
Note
	`modelEnv' may be NULL if not desired.
-d*/
message VSgetModel( struct GRid *modelId ; struct GRmd_env *modelEnv ) ;

reject	GRputattr ,
	VDget_prefix_name ,
	VDget_trans_table_entries ,
	VDSgetUsrAttributes ,
	VDSmodUsrAttributes ;

end specification VSimgFeature ;
