import java.io.*;
import java.nio.file.*;
import java.util.*;
import bigwarp.landmarks.*;
import bigwarp.*;
import net.imglib2.realtransform.*;
import net.imglib2.realtransform.inverse.*;
import jitk.spline.ThinPlateR2LogRSplineKernelTransform;

import bdv.gui.TransformTypeSelectDialog;

public class TransformPoints2 {
	
	public TransformPoints2() {
		}

	public double[][] transform(String landmarksPath, double[][] inputPoints) {
		File f = new File(landmarksPath); // reads in the landmark csv file

		// loads in landmarks and gets the transform
		LandmarkTableModel ltm = new LandmarkTableModel(3);
		try
		{
			ltm.load(f);
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}

		ThinPlateR2LogRSplineKernelTransform tpsTransform = ltm.getTransform();
		WrappedIterativeInvertibleRealTransform invertableTransform = new WrappedIterativeInvertibleRealTransform(new ThinplateSplineTransform(tpsTransform));
		InverseRealTransformGradientDescent invopt = invertableTransform.getOptimzer();
		invopt.setTolerance(0.1);
		invopt.setMaxIters(200);
		// creates the point array to be outputted
		double[][] newPoints = new double[inputPoints.length][inputPoints[0].length];

		for (int row = 0; row < inputPoints.length; row++) {
			double[] point = inputPoints[row];
			double[] transformedPoint = new double[3];
			invertableTransform.inverse().apply(point, transformedPoint);
			newPoints[row] = transformedPoint;
		}

		return newPoints;


	}

	public double[][] inverse_transform(String landmarksPath, double[][] inputPoints) {
		File f = new File(landmarksPath); // reads in the landmark csv file

		// loads in landmarks and gets the transform
		LandmarkTableModel ltm = new LandmarkTableModel(3);
		try
		{
			ltm.load(f);
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}

		ThinPlateR2LogRSplineKernelTransform tpsTransform = ltm.getTransform();
		WrappedIterativeInvertibleRealTransform invertableTransform = new WrappedIterativeInvertibleRealTransform(new ThinplateSplineTransform(tpsTransform));
		InverseRealTransformGradientDescent invopt = invertableTransform.getOptimzer();
		invopt.setTolerance(0.1);
		invopt.setMaxIters(200);
		// creates the point array to be outputted
		double[][] newPoints = new double[inputPoints.length][inputPoints[0].length];

		for (int row = 0; row < inputPoints.length; row++) {
			double[] point = inputPoints[row];
			double[] transformedPoint = new double[3];
			invertableTransform.apply(point, transformedPoint);
			newPoints[row] = transformedPoint;
		}

		return newPoints;


	}
}
