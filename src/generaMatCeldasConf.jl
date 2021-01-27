function  generaMatCeldasConf(dc)

    M=dc.MATCELDASCONF;
    M=replace!(M, NaN=>-1);
    M=convert(Array{Int64,2},M);

    NumConfig, NumCeldasSelec =size(M);

    numCeldas=maximum(M);

    MATCELDASCONF=zeros(NumConfig,numCeldas);
    MATCONFHOR=zeros(NumConfig,numCeldas);
    MATCONFVERT=zeros(NumConfig,numCeldas);
    for i=1:NumConfig
        for j=1:NumCeldasSelec
            celdaSelec_i=dc.MATCELDASCONF[i,j];
            celdaSelec_i=floor(Int, celdaSelec_i);
            if celdaSelec_i>=1
                MATCELDASCONF[i,celdaSelec_i]=1;
                if dc.MATCONFHOR[i,j]==1
                    MATCONFHOR[i,celdaSelec_i]=1;
                else
                    MATCONFVERT[i,celdaSelec_i]=1;
                end
            end
        end
    end

    MATCELDASCONF, MATCONFHOR, MATCONFVERT


end
