function resultConverter_v2(x, V, anchoLado, matConexionVertices, vecVertices, vecAlturas)

    template = Int(x[end])
    alt = min(x[1], maximum(vecAlturas))
    theta = x[2]

    # Genera Poligono que corta VolTeor a altura alt 
    idAlt = findfirst(y -> y >= alt, vecAlturas) - 1
    vert_poly_0 = Int.(vecVertices[idAlt])
    vert_poly_1 = Int.(matConexionVertices[vert_poly_0,2])
    poly_0 = copy(V[vert_poly_0, 1:2])[:,1,:]
    poly_1 = copy(V[vert_poly_1, 1:2])[:,1,:]
    alfa_ = (vecAlturas[idAlt + 1] - alt) / (vecAlturas[idAlt + 1] - vecAlturas[idAlt])
    polyCorte_alt = alfa_ .* poly_0 .+ (1 - alfa_) .* poly_1


    if template == 1

        alfa = x[3]
        pos_x = x[4]
        pos_y = x[5]
        largo1 = x[6] 
        largo2 = x[7] 

        R1 = poly2D.rotationMatrix(theta);
        cr1 = [pos_x; pos_y]
        p1_1 = [pos_x; pos_y];
        p2_1 = R1 * ([pos_x + largo1; pos_y] - cr1) + cr1;
        p3_1 = R1 * ([pos_x + largo1; pos_y + anchoLado] - cr1) + cr1;
        p4_1 = R1 * ([pos_x ; pos_y + anchoLado] - cr1) + cr1;
        R2 = poly2D.rotationMatrix(alfa + theta);
        cr2 = [pos_x; pos_y]
        p1_2 = [pos_x; pos_y];
        p2_2 = R2 * ([pos_x + anchoLado; pos_y] - cr2) + cr2;
        p3_2 = R2 * ([pos_x + anchoLado; pos_y + largo2] - cr2) + cr2;
        p4_2 = R2 * ([pos_x; pos_y + largo2] - cr2) + cr2;    
        V1 = [p1_1';p2_1';p3_1';p4_1']
        V2 = [p1_2';p2_2';p3_2';p4_2'];        

        ps1 = PolyShape([V1], 1)
        ps2 = PolyShape([V2], 1)
        psCorte = PolyShape([polyCorte_alt], 1)

        ps_base = polyShape.polyUnion_v2(ps1, ps2)
        areaBasal = polyShape.polyArea_v2(ps_base)
        ps_baseSeparada = PolyShape([V1, V2], 2)

    elseif template == 2
        phi1 = x[3]
        phi2 = x[4]
        pos_x0 = x[5]
        pos_y0 = x[6]
        largo0 = x[7]
        largo1 = x[8] 
        largo2 = x[9] 

        R_theta = poly2D.rotationMatrix(theta);
        cr_theta  = [pos_x0; pos_y0];

        p1_0  = (R_theta * ([pos_x0; pos_y0] - cr_theta) + cr_theta)'
        p2_0  = (R_theta * ([pos_x0 + largo0; pos_y0] - cr_theta) + cr_theta)'
        p3_0  = (R_theta * ([pos_x0 + largo0; pos_y0 + anchoLado] - cr_theta) + cr_theta)'
        p4_0  = (R_theta * ([pos_x0; pos_y0 + anchoLado] - cr_theta) + cr_theta)'

        R_phi1 = poly2D.rotationMatrix(phi1);
        cr_phi1  = [pos_x0; pos_y0];        
        p1_1  = (R_theta * ((R_phi1 * ([pos_x0; pos_y0] - cr_phi1) + cr_phi1) - cr_theta) + cr_theta)';
        p2_1  = (R_theta * ((R_phi1 * ([pos_x0 + anchoLado; pos_y0] - cr_phi1) + cr_phi1) - cr_theta) + cr_theta)';
        p3_1  = (R_theta * ((R_phi1 * ([pos_x0 + anchoLado; pos_y0 + largo1] - cr_phi1) + cr_phi1) - cr_theta) + cr_theta)';
        p4_1  = (R_theta * ((R_phi1 * ([pos_x0; pos_y0 + largo1] - cr_phi1) + cr_phi1) - cr_theta) + cr_theta)';
        
        R_phi2 = poly2D.rotationMatrix(-phi2);
        cr_phi2  = [pos_x0 + largo0; pos_y0];        
        p1_2  = (R_theta * ((R_phi2 * ([pos_x0 + largo0 - anchoLado; pos_y0] - cr_phi2) + cr_phi2) - cr_theta) + cr_theta)';
        p2_2  = (R_theta * ((R_phi2 * ([pos_x0 + largo0; pos_y0] - cr_phi2) + cr_phi2) - cr_theta) + cr_theta)';
        p3_2  = (R_theta * ((R_phi2 * ([pos_x0 + largo0; pos_y0 + largo2] - cr_phi2) + cr_phi2) - cr_theta) + cr_theta)';
        p4_2  = (R_theta * ((R_phi2 * ([pos_x0 + largo0 - anchoLado; pos_y0 + largo2] - cr_phi2) + cr_phi2) - cr_theta) + cr_theta)';

        V0 = [p1_0;p2_0;p3_0;p4_0]
        V1 = [p1_1;p2_1;p3_1;p4_1]
        V2 = [p1_2;p2_2;p3_2;p4_2]

        ps0 = PolyShape([V0], 1)
        ps1 = PolyShape([V1], 1)
        ps2 = PolyShape([V2], 1)
        psCorte = PolyShape([polyCorte_alt], 1)

        ps_base = polyShape.polyUnion_v2(ps0, ps1)
        ps_base = polyShape.polyUnion_v2(ps_base, ps2)
        areaBasal = polyShape.polyArea_v2(ps_base)
        ps_baseSeparada = PolyShape([V0, V1, V2], 3)

    elseif template == 3
        

    elseif template == 4

        alfa = x[3]
        pos_x = x[4]
        pos_y = x[5]
    
        largo1 = x[6] # 
        largo2 = x[7] # 
    
        R1 = poly2D.rotationMatrix(theta);
        cr1 = [pos_x; pos_y]
        p1_1 = [pos_x; pos_y];
        p2_1 = R1 * ([pos_x + largo1; pos_y] - cr1) + cr1;
        p3_1 = R1 * ([pos_x + largo1; pos_y + anchoLado] - cr1) + cr1;
        p4_1 = R1 * ([pos_x ; pos_y + anchoLado] - cr1) + cr1;
        R2 = poly2D.rotationMatrix(theta - alfa);
        cr2 = [pos_x; pos_y]
        p1_2 = R2 * ([pos_x - anchoLado; pos_y] - cr2) + cr2;
        p2_2 = R2 * ([pos_x; pos_y] - cr2) + cr2;
        p3_2 = R2 * ([pos_x; pos_y + largo2] - cr2) + cr2;
        p4_2 = R2 * ([pos_x - anchoLado; pos_y + largo2] - cr2) + cr2;    
        V1 = [p1_1';p2_1';p3_1';p4_1']
        V2 = [p1_2';p2_2';p3_2';p4_2'];        
    
        ps1 = PolyShape([V1], 1)
        ps2 = PolyShape([V2], 1)
        psCorte = PolyShape([polyCorte_alt], 1)
    
    
        ps_base = polyShape.polyUnion_v2(ps1, ps2)
        areaBasal = polyShape.polyArea_v2(ps_base)
        ps_baseSeparada = PolyShape([V1, V2], 2)

     
    end

    return alt, areaBasal, ps_base, ps_baseSeparada, psCorte


end