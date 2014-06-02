#include <math.h>
#include "mex.h"

// small value, used to avoid division by zero
#define eps 0.0001

// unit vectors used to compute gradient orientation
double uu[9] = {1.0000, 
                0.9397, 
                0.7660, 
                0.500, 
                0.1736, 
                -0.1736, 
                -0.5000, 
                -0.7660, 
                -0.9397
                };
                
double vv[9] = {0.0000, 
                0.3420, 
                0.6428, 
                0.8660, 
                0.9848, 
                0.9848, 
                0.8660, 
                0.6428, 
                0.3420
               };

static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }

static inline int min(int x, int y) { return (x <= y ? x : y); }
static inline int max(int x, int y) { return (x <= y ? y : x); }

// main function:
// takes a double color image and a bin size 
// returns HOG features
mxArray *process(const mxArray *mximage, const mxArray *mxsbin)
{
  double *im = (double *)mxGetPr(mximage);
  const int *dims = mxGetDimensions(mximage);
  if (mxGetNumberOfDimensions(mximage) != 3 ||
      dims[2] != 3 ||
      mxGetClassID(mximage) != mxDOUBLE_CLASS)
    mexErrMsgTxt("Invalid input");

  // size of a cell in pixel, used for both dimensions  
  int sbin = (int)mxGetScalar(mxsbin);

  // memory for caching orientation histograms & their norms
  int blocks[2];
  // compute number of cells fitting into current image given speficied cell size in pixel
  // use floor to prevent running over image borders
  blocks[0] = (int)floor( (double)dims[0] / (double)sbin );
  blocks[1] = (int)floor( (double)dims[1] / (double)sbin ); 
  
  // pre-allocate memory  
  double *hist = (double *)mxCalloc(blocks[0]*blocks[1]*18, sizeof(double));
  double *norm = (double *)mxCalloc(blocks[0]*blocks[1], sizeof(double));

  // memory for HOG features
  int out[3];
  // we compute as many blocks as possible given the specified cell size and the current image
  out[0] = max(blocks[0], 0);
  out[1] = max(blocks[1], 0);  
  // note: previously, a subtraction of 2 was done to guarantee identical bilinear interpolation behaviour in all cells
  // however, are more interested in obtaining a correct number of returned cells, rather than in slightly more consistent interpolation results...
  // apart from that, the only cells affected are the ones on the top and left border of the cell array
  
  out[2] = 27+4+1;
  mxArray *mxfeat = mxCreateNumericArray(3, out, mxDOUBLE_CLASS, mxREAL);
  double *feat = (double *)mxGetPr(mxfeat);
  
  int visible[2];
  visible[0] = blocks[0]*sbin;
  visible[1] = blocks[1]*sbin;
  
  // start by 1 and end by -1 to ensure safe gradient calculations on boundaries  
  for (int x = 1; x < visible[1]-1; x++)
  {
    for (int y = 1; y < visible[0]-1; y++)
    {
      // first color channel
      // NOTE: why minimum check? boundary safety is given by for loop ends      
      //               col offset                  current row position      
      double *s = im + min(x, dims[1]-1)*dims[0] + min(y, dims[0]-1);
      //gradient in y direction
      double dy = *(s+1) - *(s-1);
      // gradient in x direction
      double dx = *(s+dims[0]) - *(s-dims[0]);
      // squared gradient strength on current pixel
      double v = dx*dx + dy*dy;

      // second color channel
      s += dims[0]*dims[1];
      //gradient in y direction
      double dy2 = *(s+1) - *(s-1);
      // gradient in x direction
      double dx2 = *(s+dims[0]) - *(s-dims[0]);
      // squared gradient strength on current pixel
      double v2 = dx2*dx2 + dy2*dy2;

      // third color channel
      s += dims[0]*dims[1];
      //gradient in y direction
      double dy3 = *(s+1) - *(s-1);
      // gradient in x direction
      double dx3 = *(s+dims[0]) - *(s-dims[0]);
      // squared gradient strength on current pixel
      double v3 = dx3*dx3 + dy3*dy3;

      // pick channel with strongest gradient
      if (v2 > v)
      {
        v = v2;
        dx = dx2;
        dy = dy2;
      } 
      if (v3 > v)
      {
        v = v3;
        dx = dx3;
        dy = dy3;
      }

      //
      // now, discretize gradient orientation into one of 18 possible (oriented) bins 
      //
      
      // strength of strongest orientation in this pixel
      double best_dot = 0;
      // index of strongest orientation in this pixel
      int best_o = 0;
      
      for (int o = 0; o < 9; o++)
      {
        double dot = uu[o]*dx + vv[o]*dy;
        if (dot > best_dot)
        {
          best_dot = dot;
          best_o = o;
        }
        else if (-dot > best_dot)
        {
          best_dot = -dot;
          best_o = o+9;
        }
      }
      
      // add to 4 histograms around pixel using linear interpolation
      
      // current position normalized to cell scale, e.g. xp = 1.4 -> located in the left part of second cell
      // subtraction of 0.5 to move relative to cell center
      double xp  = ((double)x+0.5)/(double)sbin - 0.5;      
      double yp  = ((double)y+0.5)/(double)sbin - 0.5;   
      
      // that's the index of the cell, whose center is directly left of current position in x direction
      int ixp    = (int)floor(xp);
      // that's the index of the cell, whose center is directly on top of current position in y direction      
      int iyp    = (int)floor(yp);
      
      // distance to left, used for weighting the gradient strength by 1-distance, guaranteed to be in [0,1]      
      double vx0 = xp-ixp;
      // distance to top
      double vy0 = yp-iyp;
      // distance to right
      double vx1 = 1.0-vx0;
      // distance to bottom
      double vy1 = 1.0-vy0;
      
      // normalized gradient strength on current pixel
      v = sqrt(v);

      // if left upper cell exists
      if ( (ixp >= 0) && (iyp >= 0) )
      {
        *(hist + ixp*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) += 
        vx1*vy1*v; // i.e., (1-distX0)*(1-distY0)*v
      }

      // if right upper cell exists
      if ( (ixp+2 < blocks[1]) && (iyp >= 0) )
      {
        *(hist + (ixp+1)*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) += 
        vx0*vy1*v;
      }

      // if left lower cell exists
      if ( (ixp >= 0) && (iyp+2 < blocks[0]) )
      {
        *(hist + ixp*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) += 
        vx1*vy0*v;
      }

      // if right lower cell exists
      if ( (ixp+2 < blocks[1]) && (iyp+2 < blocks[0]) )
      {
        *(hist + (ixp+1)*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) += 
        vx0*vy0*v;
      }
    }
  }

  // compute energy in each block by summing over orientations
  for (int o = 0; o < 9; o++)
  {
    double *src1 = hist + o*blocks[0]*blocks[1];
    double *src2 = hist + (o+9)*blocks[0]*blocks[1];
    double *dst  = norm;
    double *end  = norm + blocks[1]*blocks[0];
    
    while (dst < end)
    {
      *(dst++) += (*src1 + *src2) * (*src1 + *src2);
      src1++;
      src2++;
    }
  }

  // compute features
  for (int x = 0; x < out[1]; x++)
  {
    for (int y = 0; y < out[0]; y++)
    {
      double *dst = feat + x*out[0] + y;      
      double *src, *p, n1, n2, n3, n4;

      // compute normalization factors for all 4 possible blocks of 2x2 cells
      
      
      // block with current, right, lower, and lower right cell
      if ( ( (x+1) < out[1] ) && ( (y+1) < out[0] ) )
      {
        p = norm + x*blocks[0] + y;
        n1 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
      }
      
      // block with current, upper, right, and upper right cell
      if ( ( (x+1) < out[1] ) && ( (y-1) > 0 ) )
      {      
        p = norm + x*blocks[0] + (y-1);
        n2 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
      }        
      
      // block with current, lower, left, and lower left cell
      if ( ( (x-1) > 0 ) && ( (y+1) < out[0] ) )
      {   
        p = norm + (x-1)*blocks[0] + y;
        n3 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
      }      
    
      // block with current, upper, left, and upper left cell
      if ( ( (x-1) > 0 ) && ( (y-1) > 0 ) )
      {
        p = norm + (x-1)*blocks[0] + (y-1);
        n4 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
      }
      
      
      // copy normalization factors for blocks on boundaries
      //   -----------------
      //   | n4 |     | n2 |
      //   -----------------
      //   |    | x,y |    |
      //   -----------------
      //   | n3 |     | n1 |
      //   -----------------      
      if ( (x-1) == 0 ) // left boundary
      {
        if ( (y-1) == 0 ) // left top corner
        {
          n4 = n1; n3 = n1; n2 = n1;
        }
        else if ( (y) == out[0] ) // left lower corner
        {
          n4 = n2; n3 = n2; n1 = n2;
        }
        else
        {
          n4 = n2; n3 = n1;
        }
      }
      else if ( (x) == out[1] ) // right boundary
      {
        if ( (y-1) == 0 ) // right top corner
        {
          n4 = n3; n2 = n3; n1 = n3;
        }
        else if ( (y) == out[0] ) // right lower corner
        {
          n3 = n4; n2 = n4; n1 = n4;
        }
        else
        {
          n2 = n4; n1 = n3; 
        }
      }
      if ( (y-1) == 0 ) // upper boundary ( corners already tackled)
      {
        if ( ( x > 0 ) && ( x < out[1] ) )
        {
          n4 = n3; n2 = n1;
        }
      }
      else if ( (y) == out[0] ) // lower boundary ( corners already tackled)
      {
        if ( ( x > 0 ) && ( x < out[1] ) )
        {
          n3 = n4; n1 = n2;
        }
      }      
      
    
      
      double t1 = 0;
      double t2 = 0;
      double t3 = 0;
      double t4 = 0;
      
      // contrast-sensitive features
      src = hist + (x)*blocks[0] + (y);
      for (int o = 0; o < 18; o++)
      {
        double h1 = min(*src * n1, 0.2);
        double h2 = min(*src * n2, 0.2);
        double h3 = min(*src * n3, 0.2);
        double h4 = min(*src * n4, 0.2);
        *dst = 0.5 * (h1 + h2 + h3 + h4);
        t1 += h1;
        t2 += h2;
        t3 += h3;
        t4 += h4;
        // move pointers to next position
        dst += out[0]*out[1];
        src += blocks[0]*blocks[1];
      }
      
      // contrast-insensitive features
      src = hist + (x)*blocks[0] + (y);
      for (int o = 0; o < 9; o++)
      {
        double sum = *src + *(src + 9*blocks[0]*blocks[1]);
        double h1 = min(sum * n1, 0.2);
        double h2 = min(sum * n2, 0.2);
        double h3 = min(sum * n3, 0.2);
        double h4 = min(sum * n4, 0.2);
        *dst = 0.5 * (h1 + h2 + h3 + h4);
        dst += out[0]*out[1];
        src += blocks[0]*blocks[1];
      }

      // texture features
      //to be complicable to FFLD code
      *dst = 0.2357 * t4;
      //*dst = 0.2357 * t1;
      dst += out[0]*out[1];
      *dst = 0.2357 * t2;
      dst += out[0]*out[1];
      *dst = 0.2357 * t3;
      dst += out[0]*out[1];
      //to be complicable to FFLD code
      *dst = 0.2357 * t1;
      //*dst = 0.2357 * t4;

      // truncation feature
      dst += out[0]*out[1];
      *dst = 0;
    }
  }

  mxFree(hist);
  mxFree(norm);
  return mxfeat;
}

// matlab entry point
// F = features(image, bin)
// image should be color with double values
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
  if (nrhs != 2)
    mexErrMsgTxt("Wrong number of inputs"); 
  if (nlhs != 1)
    mexErrMsgTxt("Wrong number of outputs");
  plhs[0] = process(prhs[0], prhs[1]);
}



