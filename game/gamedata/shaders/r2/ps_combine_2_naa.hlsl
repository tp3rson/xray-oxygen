#include "common.h"
#include "mblur.h"
#include "dof.h"
#include "MrProperCommon.h" // [FX to mrmnwar] Cheking includes, please
//////////////////////////////////////////////////////////////////////////////////////////
uniform sampler2D 	s_distort;
uniform half4 		e_barrier;	// x=norm(.8f), y=depth(.1f), z=clr
uniform half4 		e_weights;	// x=norm, y=depth, z=clr
uniform half4 		e_kernel;	// x=norm, y=depth, z=clr
#define	EPSDEPTH	0.001
//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
half4 	main		( /*v2p*/AntiAliasingStruct I )	: COLOR
{
#ifdef 	USE_DISTORT
  	half 	depth 	= tex2D(s_position, I.texCoord0).z;
	half4 	distort	= tex2D(s_distort, I.texCoord0);
	half2	offset	= (distort.xy-(127.0h/255.0h))*def_distort;  // fix newtral offset
	float2	center	= I.texCoord0 + offset;
	half 	depth_x	= tex2D(s_position, center).z;
	if ((depth_x+EPSDEPTH)<depth) center = I.texCoord0;	// discard new sample
#else
	float2	center 	= I.texCoord0;
#endif
	half3	img		= dof(center);
	half4 	bloom	= tex2D(s_bloom, center);
	
			img 	= mblur(center,tex2D(s_position,I.texCoord0),img.rgb);; 
	// end
#ifdef 	USE_DISTORT
 	half3	blurred	= bloom*def_hdr	;
	img		= lerp(img,blurred,distort.z);
#endif

 	return 	combine_bloom(img,bloom);
}
