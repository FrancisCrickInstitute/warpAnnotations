function measuredTimes = gpuBenchmark()

% Choose the "right" GPU
w = getCurrentWorker();
w = w.Name;
gpuDev = gpuDevice(str2double(w(end-1:end)));
reset(gpuDev);

% Set some data locations
cnetLocation = '/gaba/u/mberning/results/parameterSearch/20130516T204040/iter08/gpu03/saveNet0000002873.mat';
input.root = '/gaba/u/mberning/data/cortex/2012-09-28_ex145_07x2_corrected/color/1/'; 
input.prefix = '2012-09-28_ex145_07x2_corrected_mag1';
result.root = ['/gaba/u/mberning/temp/' w '/'];
result.prefix = input.prefix;

% Load data of different sizes
sizesToTest = 100:50:600;
for i=1:length(sizesToTest)
    load(cnetLocation, 'cnet');
    % Measure time to load data from HD
    tic;
    bbox = [3073 3073+sizesToTest(i); 3073 3073+sizesToTest(i); 2049 2049+127]; 
    raw = loadRawData(input, bbox);
    measuredTimes(i,1) = toc;
    % Measure time used for normalization
    tic;
    raw = normalizeStack(single(raw));
    measuredTimes(i,2) = toc;
    % Measure time for CPU classification (analog to onlyFwdPass.m)
    cnet.run.actvtClass = @single;
    cnet = cnet.forWeights(cnet.run.actvtClass);
    activity = cell(cnet.numLayer, max(cnet.numFeature));
    activity{1,1} = raw;
    tic;
    layer = 2;
    while size(activity,1) > 1
        for fm=1:cnet.layer{layer}.numFeature
            activity{2,fm} = zeros(size(activity{1,1}) - cnet.filterSize + [1 1 1], class(activity{1,1}));
            for oldFm=1:cnet.layer{layer-1}.numFeature
                activity{2, fm} = activity{2, fm} + convn(activity{1, oldFm}, cnet.layer{layer}.W{oldFm,fm}, 'valid');
            end
            activity{2, fm} = cnet.nonLinearity(activity{2, fm} + cnet.layer{layer}.Bcell{fm});
        end
        activity(1,:) = [];
        layer = layer + 1;
    end
    measuredTimes(i,3) = toc;
    % Measure time for transfer of cnet and raw data to GPU
    reset(gpuDev);
    tic;
    cnet.run.actvtClass = @gpuArray;
    cnet = cnet.forWeights(cnet.run.actvtClass);
    activity = cell(cnet.numLayer, max(cnet.numFeature));
    activity{1,1} = cnet.run.actvtClass(raw);
    wait(gpuDev);
    measuredTimes(i,4) = toc;
    % Measure time for GPU classification
    tic;
    layer = 2;
    while size(activity,1) > 1
        for fm=1:cnet.layer{layer}.numFeature
            activity{2,fm} = zeros(size(activity{1,1}) - cnet.filterSize + [1 1 1], class(activity{1,1}));
            for oldFm=1:cnet.layer{layer-1}.numFeature
                activity{2, fm} = activity{2, fm} + convn(activity{1, oldFm}, cnet.layer{layer}.W{oldFm,fm}, 'valid');
            end
            activity{2, fm} = cnet.nonLinearity(activity{2, fm} + cnet.layer{layer}.Bcell{fm});
        end
        activity(1,:) = [];
        layer = layer + 1;
    end
    wait(gpuDev);
    measuredTimes(i,5) = toc;
    % Measure time for collecting from GPU
    tic;
    classification = gather(activity{1,1});
    wait(gpuDev);
    measuredTimes(i,6) = toc;
    % Measure time for writing to HD
    tic;
    writeKnossosRoi(result.root, result.prefix, bbox(:,1)', classification, 'single');
    wait(gpuDev);
    measuredTimes(i,7) = toc;
    % Generate random matrices for test of performance critical routines for MPF test
    reset(gpuDev);
    a = randn(sizesToTest(i),sizesToTest(i),128);
    aGpu = gpuArray(a);
    % Test a big reshape 
    b = [sizesToTest(i) 2 sizesToTest(i)/2 128];
    bGpu = gpuArray(b);
    f = @(x,y) reshape(x,y);
    wait(gpuDev);
    tic;
    f(a,b);
    measuredTimes(i,8) = toc;
    tic;
    f(aGpu,bGpu);
    wait(gpuDev);
    measuredTimes(i,9) = toc;
    % Test a big permute
    c = [2 1 3 4];
    cGpu = gpuArray(c);
    f = @(x,y) permute(x,y);
    wait(gpuDev);
    tic;
    f(a,c);
    measuredTimes(i,10) = toc;
    tic;
    f(aGpu,cGpu);
    wait(gpuDev);
    measuredTimes(i,11) = toc;
    % Test a big indexing dilema xD
    d = randi(sizesToTest(i),[100 1]);
    dGpu = gpuArray(d);
    e = randi(sizesToTest(i),[100 1]);
    eGpu = gpuArray(e);
    wait(gpuDev);
    tic;
    idxDilemma(a,d,e);
    measuredTimes(i,12) = toc;
    tic;
    idxDilemma(aGpu,dGpu,eGpu);
    wait(gpuDev);
    measuredTimes(i,13) = toc;
end

function idxDilemma(x,y,z)
    for j=1:length(y)
        x(y(j),z(j)) = 1;
    end
end

end

