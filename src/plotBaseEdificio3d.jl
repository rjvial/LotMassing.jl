function plotBaseEdificio3d(fpe, x, alturaPiso, ps_predio,
                             ps_volteor, matConexionVertices_ss, vecVertices_ss, 
                            ps_restSombra, matConexionVertices_cs, vecVertices_cs, 
                            ps_publico, ps_calles, ps_base, ps_baseSeparada)

    f_predio = fpe.predio
    f_volTeor = fpe.volTeor
    f_restSombra = fpe.restSombra
    f_edif = fpe.edif

    f_sombraVolTeor_p = fpe.sombraVolTeor_p
    f_sombraVolTeor_o = fpe.sombraVolTeor_o
    f_sombraVolTeor_s = fpe.sombraVolTeor_s
    
    f_sombraEdif_p = fpe.sombraEdif_p
    f_sombraEdif_o = fpe.sombraEdif_o
    f_sombraEdif_s = fpe.sombraEdif_s

    alt = x[1]


    if f_predio
        # Grafica Predio
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_predio, 0, nothing, nothing, nothing, "green", .3)
    end

    if f_volTeor
        # Grafica Volumen Teórico
        V_volteor = ps_volteor.Vertices[1]
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v5(ps_volteor, matConexionVertices_ss, vecVertices_ss, fig, ax, ax_mat)
    end

    if f_restSombra
        # Grafica Volumen Teórico
        V_restSombra = ps_restSombra.Vertices[1]
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v5(ps_restSombra, matConexionVertices_cs, vecVertices_cs, fig, ax, ax_mat, "gray", 0.1)
    end

    #ps_calles = polyShape.polyUnion_v2(ps_calles, ps_calles)
    fig, ax = polyShape.plotPolyshape3d_v1(ps_calles, 0, fig, ax, "grey", 0.25)

    if f_edif
        # Grafica cabida óptima
        numPisos = Int(round(alt/alturaPiso))
        for k = 1:numPisos
            for j=1:ps_base.NumRegions
                V_base_j = ps_base.Vertices[j]
                numVerticesBase_j = size(V_base_j,1)
                V_kj = [V_base_j alturaPiso * (k - 1) * ones(numVerticesBase_j,1);
                        V_base_j alturaPiso * k * ones(numVerticesBase_j,1)]
                fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(PolyShape([V_kj],1), alturaPiso * (k - 1), fig, ax, ax_mat, "teal", 1)
            end
            fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_base, alturaPiso * k, fig, ax, ax_mat, "teal", 1)
        end
    end

    
    ps_SombraVolTeor_p, ps_SombraVolTeor_o, ps_SombraVolTeor_s = generaSombraTeor(ps_volteor, matConexionVertices_ss, vecVertices_ss, ps_publico, ps_calles)
    if f_sombraVolTeor_p
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_SombraVolTeor_p, 0, fig, ax, ax_mat, "gold", 0.3)
    end
    if f_sombraVolTeor_o
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_SombraVolTeor_o, 0, fig, ax, ax_mat, "gold", 0.3)
    end
    if f_sombraVolTeor_s
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_SombraVolTeor_s, 0, fig, ax, ax_mat, "gold", 0.3)
    end

    

    ps_sombraEdif_p, ps_sombraEdif_o, ps_sombraEdif_s = generaSombraEdificio(ps_baseSeparada, alt, ps_publico, ps_calles)
    if f_sombraEdif_p
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_sombraEdif_p, 0, fig, ax, ax_mat, "red", 0.25)
    end
    if f_sombraEdif_o
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_sombraEdif_o, 0, fig, ax, ax_mat, "red", 0.25)
    end
    if f_sombraEdif_s
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_sombraEdif_s, 0, fig, ax, ax_mat, "red", 0.25)
    end
    

    return fig
end