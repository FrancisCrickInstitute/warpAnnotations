function bipolarViewer()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
files = dir('Z:\CortexConnectomics\Manuel\2012_07_08\ek0563_BC_2012_07_08*.am');
fid = fopen('Z:\CortexConnectomics\Manuel\2012_07_08\automated.hx', 'w');

fprintf(fid,'# Amira Script\nremove -all\n');
fprintf(fid,'viewer setVertical 0\n');
fprintf(fid,'viewer 0 setBackgroundMode 0\n');
fprintf(fid,'viewer 0 setBackgroundColor 1 1 1\n');
fprintf(fid,'viewer 0 setBackgroundColor2 0.182292 0.220269 0.486111\n');
fprintf(fid,'viewer 0 setTransparencyType 5\n');
fprintf(fid,'viewer 0 setAutoRedraw 0\n');
fprintf(fid,'viewer 0 show\n');
fprintf(fid,'mainWindow show\n');

for i=1:length(files)
    fprintf(fid,'set hideNewModules 0\n');
    fprintf(fid,['[ load ' files(i).name ' ] setLabel ' files(i).name '\n']);
    fprintf(fid,[files(i).name ' setIconPosition 20 ' num2str(10+30*i) '\n']);
    fprintf(fid,[files(i).name ' fire\n']);
    fprintf(fid,[files(i).name ' setViewerMask 16383\n']);
end

for i=1:length(files)
    fprintf(fid,'set hideNewModules 0\n');
    fprintf(fid,['create HxDisplayLineSet {LineSetView' num2str(i) '}\n']);
    fprintf(fid,['LineSetView' num2str(i) ' setIconPosition 400 ' num2str(10+30*i) '\n']);
    fprintf(fid,['{LineSetView' num2str(i) '} setLineWidth 1\n']);
    fprintf(fid,['{LineSetView' num2str(i) '} setLineColor ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) '\n']);
    fprintf(fid,['{LineSetView' num2str(i) '} setSphereColor ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) '\n']);
    fprintf(fid,['{LineSetView' num2str(i) '} setStripeColorMapping 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' data connect ' files(i).name '\n']);
    fprintf(fid,['LineSetView' num2str(i) ' colormap setDefaultColor ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) '\n']);
    fprintf(fid,['LineSetView' num2str(i) ' colormap setDefaultAlpha 0.500000\n']);
    fprintf(fid,['LineSetView' num2str(i) ' colormap setLocalRange 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' alphamap setDefaultColor ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) ' ' num2str(rand(1,1)) '\n']);
    fprintf(fid,['LineSetView' num2str(i) ' alphamap setDefaultAlpha 0.500000\n']);
    fprintf(fid,['LineSetView' num2str(i) ' alphamap setLocalRange 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' fire\n']);
    fprintf(fid,['LineSetView' num2str(i) ' shape setIndex 0 6\n']);
    fprintf(fid,['LineSetView' num2str(i) ' circleComplexity setMinMax 3 30\n']);
    fprintf(fid,['LineSetView' num2str(i) ' circleComplexity setButtons 1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' circleComplexity setIncrement 1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' circleComplexity setValue 30\n']);
    fprintf(fid,['LineSetView' num2str(i) ' circleComplexity setSubMinMax 3 30\n']);
    fprintf(fid,['LineSetView' num2str(i) ' scaleMode setIndex 0 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' scaleFactor setMinMax 0 20\n']);
    fprintf(fid,['LineSetView' num2str(i) ' scaleFactor setButtons 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' scaleFactor setIncrement 0.166667\n']);
    fprintf(fid,['LineSetView' num2str(i) ' scaleFactor setValue 15\n']);
    fprintf(fid,['LineSetView' num2str(i) ' scaleFactor setSubMinMax 0 20\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateMode setIndex 0 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateMode setIndex 1 2\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateMode setIndex 2 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateFactor setMinMax 0 360\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateFactor setButtons 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateFactor setIncrement 24\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateFactor setValue 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' rotateFactor setSubMinMax 0 360\n']);
    fprintf(fid,['LineSetView' num2str(i) ' twistMode setIndex 0 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' twistMode setIndex 1 1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' twistFactor setMinMax -0.100000001490116 0.100000001490116\n']);
    fprintf(fid,['LineSetView' num2str(i) ' twistFactor setButtons 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' twistFactor setIncrement 0.0133333\n']);
    fprintf(fid,['LineSetView' num2str(i) ' twistFactor setValue 0.05\n']);
    fprintf(fid,['LineSetView' num2str(i) ' twistFactor setSubMinMax -0.100000001490116 0.100000001490116\n']);
    fprintf(fid,['LineSetView' num2str(i) ' colorMode setIndex 0 1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' colorMode setIndex 1 1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' colorMode setIndex 2 1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' spheres setIndex 0 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereScale setMinMax 0 2.5\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereScale setButtons 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereScale setIncrement 0.166667\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereScale setValue 0.1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereScale setSubMinMax 0 2.5\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereColor setIndex 0 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereColor setIndex 1 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereComplexity setMinMax 0.0560000017285347 1\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereComplexity setButtons 0\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereComplexity setIncrement 0.0629333\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereComplexity setValue 0.2\n']);
    fprintf(fid,['LineSetView' num2str(i) ' sphereComplexity setSubMinMax 0.0560000017285347 1\n']);
    fprintf(fid,['LineSetView' num2str(i) '  fire\n']);
    fprintf(fid,['LineSetView' num2str(i) '  setViewerMask 16383\n']);
    fprintf(fid,['LineSetView' num2str(i) '  setPickable 1\n']);
end

end

