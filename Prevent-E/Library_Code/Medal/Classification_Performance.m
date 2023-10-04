function TPs = Classification_Performance(tr_up, tr_dw, fileName, outDir, FE)
    
    predictions = [];
    for timestamp = 1:length(FE)
        if FE(timestamp) >= tr_up || FE(timestamp) <= tr_dw
            predictions(timestamp) = 1;
        else
            predictions(timestamp) = 0;
        end
    end

    % save the prediction history
    file_name = split(strrep(fileName,'mat','csv'), "_");
    file_name = file_name(1);
    predictions_file_name = outDir + file_name + ".csv";
 
    fileID = fopen(predictions_file_name,'w');
    for timestamp = 1:length(predictions)
        fprintf(fileID, "%d\n", predictions(timestamp));
    end
    fclose(fileID);
    
    TPs = [];
end