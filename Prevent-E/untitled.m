test_ds_names_general = ["cpu-stress", "mem-leak", "pack-loss", "pack-delay", "pack-corr"];
replicas_num = 3;


test_ds_names = strings(1, length(test_ds_names_general) * replicas_num);
for ii = 1:length(test_ds_names_general)
    for jj = 1:replicas_num
        test_ds_names((ii - 1) * replicas_num + jj) = strcat(test_ds_names_general(ii), "-", int2str(jj), "_rbm");
    end
end

disp(test_ds_names)