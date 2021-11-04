import java.io.*;
import java.nio.file.*;
import java.util.*;
import bigwarp.landmarks.*;
import bigwarp.BigWarp.WrappedCoordinateTransform;
import net.imglib2.realtransform.*;
import jitk.spline.ThinPlateR2LogRSplineKernelTransform;

import bdv.gui.TransformTypeSelectDialog;

public class TransformPoints {
	
	public TransformPoints() {
		}

	public double[][] transform(String landmarksPath, double[][] inputPoints) {
		File f = new File(landmarksPath); // reads in the landmark csv file

		// loads in landmarks and gets the transform
		LandmarkTableModel ltm = new LandmarkTableModel( 3 );
		try
		{
			ltm.load( f );
		}
		catch ( IOException e )
		{
			e.printStackTrace();
		}

		ThinPlateR2LogRSplineKernelTransform tpsTransform = ltm.getTransform();

		// creates the point array to be outputted
		double[][] newPoints = new double[inputPoints.length][inputPoints[1].length];

		for (int row = 0; row < inputPoints.length; row++) {
			double[] point = inputPoints[row];
			double[] transformedPoint = tpsTransform.apply( point );
			newPoints[row] = transformedPoint;
		}

		return newPoints;


	}
}
