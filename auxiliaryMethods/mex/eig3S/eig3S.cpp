/*
  Usage:
    roots = eig3S(A)

  A:
    [6xN] array of double or single. Each column contains the
    entries of a real symmetric matrix. The i-th matrix is
    then given by

    [A(1,i), A(2,i),  A(3,i);
     A(2,i), A(4,i),  A(5,i);
     A(3,i), A(5,i),  A(6,i)]

  roots:
    [3xN] array of respective type containing the eigenvalues
    of the i-th matrix in the i-th column. Eigenvalues are sorted
    in increasing order.

  Author:
    Benedikt Staffler <benedikt.staffler@brain.mpg.de>
  Modified:
    Alessandro Motta <alessandro.motta@brain.mpg.de>
*/

#include <iostream>
#include <algorithm>
#include <array>
#include "mex.h"

template<typename Scalar>
void computeRoots(Scalar * m, Scalar * roots, int dim_x = 1)
{
    // Adapted from Eigen.SelfAdjointEigenSolver
    // see http://eigen.tuxfamily.org/dox/classEigen_1_1SelfAdjointEigenSolver.html

    // Inputs of the form
    // mat = m[0] m[1] m[2]
    //       m[1] m[3] m[4]
    //       m[2] m[4] m[5]

    using std::sqrt;
    using std::atan2;
    using std::cos;
    using std::sin;

    const Scalar s_inv3 = Scalar(1.0) / Scalar(3.0);
    const Scalar s_sqrt3 = sqrt(Scalar(3.0));

    Scalar c0, c1, c2;
    Scalar c2_over_3;
    Scalar a_over_3;
    Scalar half_b;
    Scalar q;
    Scalar rho;
    Scalar theta;
    Scalar cos_theta;
    Scalar sin_theta;
    Scalar * col;

    for (int i = 0; i < dim_x; i++)
    {
        // pointer to current colum
        col = &m[i * 6];

        c0 = col[0] * col[3] * col[5]
           + col[1] * col[2] * col[4] * Scalar(2)
           - col[0] * col[4] * col[4]
           - col[3] * col[2] * col[2]
           - col[5] * col[1] * col[1];

        c1 = col[0] * col[3] - col[1] * col[1]
           + col[0] * col[5] - col[2] * col[2]
           + col[3] * col[5] - col[4] * col[4];

        c2 = col[0] + col[3] + col[5];

        // Construct the parameters used in classifying the roots of the equation
        // and in solving the equation for the roots in closed form.
        c2_over_3 = c2 * s_inv3;
        a_over_3 = (c2 * c2_over_3 - c1) * s_inv3;

        if (a_over_3 < Scalar(0))
            a_over_3 = Scalar(0);

        half_b = Scalar(0.5) * (c0 + c2_over_3 * (Scalar(2) * c2_over_3 * c2_over_3 - c1));
        q = a_over_3 * a_over_3 * a_over_3 - half_b * half_b;

        if (q < Scalar(0))
            q = Scalar(0);

        // Compute the eigenvalues by solving for the roots of the polynomial.
        rho = sqrt(a_over_3);

        // since sqrt(q) > 0, atan2 is in [0, pi] and theta is in [0, pi/3]
        theta = atan2(sqrt(q), half_b) * s_inv3;
        cos_theta = cos(theta);
        sin_theta = sin(theta);

        // roots are already sorted, since cos is monotonically decreasing on [0, pi]
        roots[0 + i * 3] = c2_over_3 - rho * (cos_theta + s_sqrt3 * sin_theta);
        roots[1 + i * 3] = c2_over_3 - rho * (cos_theta - s_sqrt3 * sin_theta);
        roots[2 + i * 3] = c2_over_3 + Scalar(2) * rho * cos_theta;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //check inputs
    if (nlhs != 1 || nrhs != 1)
        mexErrMsgTxt("Syntax:\n\troots = eig3S(A)");

    if (mxIsComplex(prhs[0]))
        mexErrMsgTxt("Array must be real.");

    //get input
    const mwSize *dim_array;
    dim_array = mxGetDimensions(prhs[0]);

    if (dim_array[0] != 6)
        mexErrMsgTxt("Input array must be 6 x n.");

    if (mxIsDouble(prhs[0]))
    {
        //get input
        double *m = mxGetPr(prhs[0]);

        //prepare output
        plhs[0] = mxCreateNumericMatrix(3, dim_array[1], mxDOUBLE_CLASS, mxREAL);
        double *out = mxGetPr(plhs[0]);
        computeRoots(m, out, dim_array[1]);
    }
    else if (mxIsSingle(prhs[0]))
    {
        //get input
        float *m = (float*)mxGetData(prhs[0]);

        //prepare output
        plhs[0] = mxCreateNumericMatrix(3, dim_array[1], mxSINGLE_CLASS, mxREAL);
        float *out = (float*)mxGetData(plhs[0]);
        computeRoots(m, out, dim_array[1]);
    }
    else
    {
        mexErrMsgTxt("Array must be single or double");
    }
}
