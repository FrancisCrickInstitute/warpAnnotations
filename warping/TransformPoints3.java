import java.io.*;
import java.nio.file.*;
import java.util.*;
import bigwarp.landmarks.*;
import bigwarp.*;
import net.imglib2.realtransform.*;
import net.imglib2.realtransform.inverse.*;
import jitk.spline.ThinPlateR2LogRSplineKernelTransform;

import bdv.gui.TransformTypeSelectDialog;

public class TransformPoints3 {
	
	public TransformPoints3() {
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
		
		//transform all points
		ThinPlateR2LogRSplineKernelTransform transform = ltm.getTransform();
		double[][] newPoints = new double[inputPoints.length][inputPoints[0].length];

		for (int row = 0; row < inputPoints.length; row++) {
			double[] point = inputPoints[row];
			double[] transformedPoint = new double[3];
			transform.inverseTol( point, transformedPoint, 0.1, 200);
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
		
		//transform all points
		ThinPlateR2LogRSplineKernelTransform transform = ltm.getTransform();
		double[][] newPoints = new double[inputPoints.length][inputPoints[0].length];

		for (int row = 0; row < inputPoints.length; row++) {
			double[] point = inputPoints[row];
			double[] transformedPoint = new double[3];
			transform.apply( point, transformedPoint);
			newPoints[row] = transformedPoint;
		}

		return newPoints;
	}

}
