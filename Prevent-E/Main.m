training_ds_names = ["normal_1_14"];
model_test_ds_name = "normal_test_24h";
test_ds_names_general = ["cpu-stress", "mem-leak", "pack-loss", "pack-delay", "pack-corr"];
test_data_set_code_for_fpr_test = "fpr_test";
replicas_num = 3;
loadmodel = 1;
KPI = 719;


training_ds_names(1) = strcat(training_ds_names(1), "_rbm");
test_ds_names_arr_len = length(test_ds_names_general) * replicas_num + 1;
test_ds_names = strings(1, test_ds_names_arr_len);
for ii = 1:length(test_ds_names_general)
    for jj = 1:replicas_num
        test_ds_names((ii - 1) * replicas_num + jj) = strcat(test_ds_names_general(ii), "-", int2str(jj - 1), "_rbm");
    end
end
test_ds_names(test_ds_names_arr_len) = strcat(test_data_set_code_for_fpr_test, "_rbm");
test_ds_names(test_ds_names_arr_len) = strcat(model_test_ds_name, "_rbm");

disp(test_ds_names)

% St.Deviations for the trendlines
Ks = [1, 2, 3];

for ii = 1:length(training_ds_names)
    clearvars -except training_ds_names test_ds_names loadmodel KPI Ks ii;

    training_ds_name = training_ds_names(ii);
    disp(training_ds_name)

    %% Remove cache
    delete('./Data/FinalData/Csv/*')
    delete('./Data/FinalData/Mat/*')
    delete('./Data/PreProcessing_Code/tmp/*')
    
    
    %% Initialisation
    
    addpath('./Data/PreProcessing_Code/');
    addpath('./Library_Code/Medal/');

    % Defines the preprocessing method(s) for data values allowed:
    %
    % - Stand: Standardization by column, in particular it's made by looping
    %          each COLUMN (= KPIs) value and replacing each value as follows:
    %          newValue = (oldValue - KPI_Mean)/ KPI_StndDev,
    %
    % - NormMatrix: Data-Scaling performed in order to have every value in
    %               range [0, 1], done as follows:
    %               newValue = (oldValue - minValueofMatrix)/ (maxValueofMatrix - minValueofMatrix),
    %
    % - NormKPI: Data-Scaling performed in order to have every value in
    %            range [0, 1], done as follows:
    %            newValue = (oldValue - minValueofColumn)/ (maxValueofColumn - minValueofColumn),
    %
    % - Raw: No preprocessing
    preProc = ["Stand"];

    % Insert every value(s) of Learning rate with which train the RBM, 
    % typically a value between 0.1 and 0.0001
    lr_to_test = [0.01]; 

    % Directory in which store the final data after pre-processing
    finalDataDir = "./Data/FinalData/";
    if (exist(finalDataDir, 'dir') ~= 7)
        mkdir(finalDataDir);
    end

    % Directory in which raw data is stored
    % rawDirectory = "./Data/InputData/";
    rawDirectory = "/Users/usi/DataHub/Data-Redis-2023/";

    % Directory in which store the final result,
    % divided into two different directories:
    % outDir/Csv (for Python) and outDir/Mat (for MatLab)
    outDir = "../resources/predictions-e/";

    % If outDir doesn't exist, create it
    if (exist(outDir, 'dir') ~= 7)
        mkdir(outDir);
    end

    % Since plotting FE's graphs (in particular the one concerning the normal 
    % data) requires a lot of time, you might consider to avoid its plotting
    plotNormal = false;

    %% Creation of the data

    % Starting from folders containintg different files of different length,
    % this step will unify them in a specified and unique dataset for each 
    % fault tipology.
    % realNumberofKPIs is required because the real numbers of KPI may change
    % from our expectation if we're going to enable the eliminateStringColumn
    % option.

    % if true, displays operations step-by-step
    debug = false;

    % if true, during the pre-processing phase every string column will be
    % discarded,
    % if false, it will replace every string with a unique int, for example: 
    % [ ['a', 'b', 'c'], ['b', 'e', 'a'] ] -> [ [1, 2, 3], [2, 4, 1] ]
    eliminateStringColumn = true;
    
    %% Data preprocessing
    realNumberofKPIs = CreateDataFromRaw(KPI, rawDirectory, finalDataDir, preProc, eliminateStringColumn, debug, training_ds_name, test_ds_names, loadmodel);
    
    %% Training RBM(s) and Plotting FE Distributions - MATLAB
    % After the training of the RBM, a model based on FE's trendline will be
    % used to evaluate the anomalous data.
    % This step will also create one image containing the plotted FE Distribution in the outDir
    % directory for each fault type of anomalous data.

    if ~exist('realNumberofKPIs', 'var')
        realNumberofKPIs = KPI;
    end

    finalDataDirMat = finalDataDir + "Mat/"; 

    for i = 1:length(preProc)
        for j = 1:length(lr_to_test)
            RBM_Train(finalDataDirMat, realNumberofKPIs, lr_to_test(j), outDir, preProc(i), plotNormal, Ks, loadmodel);
        end
    end

    disp("Finish for " + training_ds_name);
end
