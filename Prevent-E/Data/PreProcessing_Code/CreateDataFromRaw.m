function realNumberofKPIs = CreateDataFromRaw(nKPI, rawDirectory, finalDataDir, preProc, eliminateStringColumn, debug, training_ds_name, test_ds_names, loadmodel)
    %% Defining parameters for the data creation phase

    normalDir = rawDirectory + training_ds_name;
    anomalousDir = rawDirectory;


    %% Data creation phase

    for i = 1:length(preProc)

        Real_KPIs = 1720;
        [NormalSet, Real_KPIs] = NormalData(nKPI, preProc(i), normalDir, finalDataDir, eliminateStringColumn, debug);
        CsvToMat(finalDataDir, Real_KPIs, preProc(i), NormalSet, "Normal");
        if loadmodel == 0
            x = 1;
        end
        
        % my addition (dataset for the threshol definition
        % targetDataDir = rawDirectory + "targetNormal";
        % [targetNormalSet, Real_KPIs] = TargetData(nKPI, preProc(i), targetDataDir, finalDataDir, eliminateStringColumn, debug);
        % CsvToMat(finalDataDir, Real_KPIs, preProc(i), targetNormalSet, "targetNormal");
        % my addition end
        
        for j = 1:length(test_ds_names)
            disp(j)
            disp(anomalousDir)
            disp(test_ds_names(j))
           
            AnomalousSet = AnomalousData(Real_KPIs, preProc(i), (anomalousDir + test_ds_names(j)), test_ds_names(j), eliminateStringColumn, debug);
            CsvToMat(finalDataDir, Real_KPIs, preProc(i), AnomalousSet, "Anomalous", test_ds_names(j));
        end
    end
    
    realNumberofKPIs = Real_KPIs;
end
