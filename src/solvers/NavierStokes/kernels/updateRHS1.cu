#include "updateRHS1.h"

#define BSZ 16

namespace kernels
{

// 1-d interpolation
__global__
void updateRHS1(real *rhs1, int numUV, int *tags)
{
	int	I = blockIdx.x*blockDim.x + threadIdx.x;
	
	if(I>=numUV)
		return;
	
	rhs1[I] = rhs1[I]*(tags[I]==-1);
}

__global__
void updateRHS1X(real *rhs1, int nx, int ny, real dt, real *dx, int *tags, real *coeffs, real *uv)
{
	int	I = blockIdx.x*blockDim.x + threadIdx.x;
	int i = I % (nx-1);
	
	if( I < (nx-1)*ny )
	{
		rhs1[I] = (tags[I]==-1)*rhs1[I] 
		          + ((tags[I]!=-1)*((1.0-coeffs[I])*uv[I])) * 0.5*(dx[i+1]+dx[i])/dt;
	}
}

__global__
void updateRHS1Y(real *rhs1, int nx, int ny, real dt, real *dy, int *tags, real *coeffs, real *uv)
{
	int numU = (nx-1)*ny;
	int	I = blockIdx.x*blockDim.x + threadIdx.x + numU;
	int j = (I-numU) / nx;
	
	if( I < numU + nx*(ny-1) )
	{
		rhs1[I] = (tags[I]==-1)*rhs1[I] 
		          + ((tags[I]!=-1)*((1.0-coeffs[I])*uv[I])) * 0.5*(dy[j+1]+dy[j])/dt;
	}
}

} // end of namespace kernels
